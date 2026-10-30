"""
weather_module.py
=================
Complete Weather Prediction / Research Analyst mode for the Building Management
AI Master Agent (Streamlit).  Replaces the IMD module - NO registration, NO API key.

Data source : Open-Meteo (https://open-meteo.com)  -  free weather + air-quality API
              (CC BY 4.0, free for NON-COMMERCIAL use; commercial use needs their paid plan)

Answers questions like
    "what's the temperature today?"            "probability of rain tomorrow in Madurai"
    "weather forecast for this week"           "is it going to be windy tonight?"
    "UV index and air quality in Chennai"      "will it rain on Saturday?"

What you get (any city in the world)
    * Right-now conditions: temp, feels-like, humidity, wind, gusts, pressure, cloud
    * REAL rain probability (% per hour and per day) + expected rainfall (mm)
    * 24-hour outlook (3-hourly) and 7-day forecast table
    * UV index, sunrise / sunset, wind gusts, visibility
    * Air quality (US AQI, PM2.5, PM10)  *optional*
    * Analyst notes: heat-stress, best outdoor-work window, rain windows, HVAC-load hint

Public API (what the main app needs)
------------------------------------
    import weather_module as wx

    wx.render_settings()                  # inside `with st.sidebar:`
    if wx.should_handle(question):        # at the chat-input hook
        wx.answer_in_chat(question)       # fetch + analyse + append to chat + rerun
    else:
        run_pipeline(question)
"""

from __future__ import annotations

import json
import re
import urllib.error
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timedelta

import pandas as pd
import streamlit as st

ATTRIBUTION = "Weather data by Open-Meteo.com (CC BY 4.0)"

GEOCODE_URL = "https://geocoding-api.open-meteo.com/v1/search"
FORECAST_URL = "https://api.open-meteo.com/v1/forecast"
AIR_URL = "https://air-quality-api.open-meteo.com/v1/air-quality"

CURRENT_VARS = ("temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,"
                "weather_code,cloud_cover,pressure_msl,wind_speed_10m,wind_direction_10m,wind_gusts_10m")
HOURLY_VARS = ("temperature_2m,relative_humidity_2m,apparent_temperature,precipitation_probability,"
               "precipitation,weather_code,cloud_cover,visibility,wind_speed_10m,wind_gusts_10m,uv_index")
DAILY_VARS = ("weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,"
              "apparent_temperature_min,sunrise,sunset,uv_index_max,precipitation_sum,"
              "precipitation_hours,precipitation_probability_max,wind_speed_10m_max,wind_gusts_10m_max")

# -----------------------------------------------------------------------------
# 1. CODE TABLES
# -----------------------------------------------------------------------------
WMO = {
    0: ("Clear sky", "☀️"), 1: ("Mainly clear", "🌤️"), 2: ("Partly cloudy", "⛅"), 3: ("Overcast", "☁️"),
    45: ("Fog", "🌫️"), 48: ("Rime fog", "🌫️"),
    51: ("Light drizzle", "🌦️"), 53: ("Moderate drizzle", "🌦️"), 55: ("Dense drizzle", "🌧️"),
    56: ("Freezing drizzle", "🌧️"), 57: ("Dense freezing drizzle", "🌧️"),
    61: ("Light rain", "🌦️"), 63: ("Moderate rain", "🌧️"), 65: ("Heavy rain", "🌧️"),
    66: ("Freezing rain", "🌧️"), 67: ("Heavy freezing rain", "🌧️"),
    71: ("Light snow", "🌨️"), 73: ("Moderate snow", "🌨️"), 75: ("Heavy snow", "❄️"), 77: ("Snow grains", "🌨️"),
    80: ("Light rain showers", "🌦️"), 81: ("Moderate rain showers", "🌧️"), 82: ("Violent rain showers", "⛈️"),
    85: ("Light snow showers", "🌨️"), 86: ("Heavy snow showers", "❄️"),
    95: ("Thunderstorm", "⛈️"), 96: ("Thunderstorm with slight hail", "⛈️"), 99: ("Thunderstorm with heavy hail", "⛈️"),
}
COMPASS = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
WEEKDAYS = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]


def wx_desc(code) -> str:
    try:
        d, e = WMO.get(int(code), (f"Weather code {code}", "🌡️"))
    except Exception:
        return "n/a"
    return f"{e} {d}"


def rain_label(p: float | None) -> str:
    if p is None:
        return "n/a"
    if p < 20:
        return "unlikely"
    if p < 40:
        return "low chance"
    if p < 60:
        return "moderate chance"
    if p < 80:
        return "likely"
    return "very likely"


def uv_label(u: float | None) -> str:
    if u is None:
        return "n/a"
    return ("Low" if u < 3 else "Moderate" if u < 6 else "High" if u < 8 else "Very high" if u < 11 else "Extreme")


def aqi_label(a: float | None) -> str:
    if a is None:
        return "n/a"
    return ("Good" if a <= 50 else "Moderate" if a <= 100 else "Unhealthy for sensitive groups" if a <= 150
            else "Unhealthy" if a <= 200 else "Very unhealthy" if a <= 300 else "Hazardous")


def wind_label(kmh: float | None) -> str:
    if kmh is None:
        return "n/a"
    return ("calm" if kmh < 6 else "light breeze" if kmh < 20 else "moderate breeze" if kmh < 39
            else "strong wind" if kmh < 62 else "gale-force wind")


def heat_label(feels: float | None) -> str:
    if feels is None:
        return "n/a"
    return ("comfortable" if feels < 27 else "warm" if feels < 32 else "hot - caution with prolonged exertion" if feels < 39
            else "very hot - heat-stress risk" if feels < 46 else "extreme heat danger")


def compass(deg) -> str:
    try:
        return COMPASS[int(round(float(deg) / 22.5)) % 16]
    except Exception:
        return ""


# -----------------------------------------------------------------------------
# 2. HTTP LAYER
# -----------------------------------------------------------------------------
class WeatherError(Exception):
    pass


def _ssl_context():
    import ssl
    try:
        import certifi
        return ssl.create_default_context(cafile=certifi.where())
    except Exception:
        return ssl.create_default_context()


@st.cache_data(show_spinner=False, ttl=600)
def _get_json(url: str):
    req = urllib.request.Request(url, headers={"User-Agent": "BMS-AI-Agent/1.0", "Accept": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=15, context=_ssl_context()) as resp:
            return json.loads(resp.read().decode("utf-8", errors="replace"))
    except urllib.error.HTTPError as e:
        body = ""
        try:
            body = json.loads(e.read().decode()).get("reason", "")
        except Exception:
            pass
        raise WeatherError(f"HTTP {e.code} from weather server {('- ' + body) if body else ''}".strip())
    except urllib.error.URLError as e:
        raise WeatherError(f"Cannot reach weather server ({e.reason}). Check your internet connection / proxy.")
    except Exception as e:
        raise WeatherError(f"{type(e).__name__}: {e}")


def geocode(name: str) -> dict | None:
    name = (name or "").strip()
    if not name:
        return None
    url = f"{GEOCODE_URL}?name={urllib.parse.quote(name)}&count=5&language=en&format=json"
    results = _get_json(url).get("results") or []
    return results[0] if results else None


def fetch_forecast(lat: float, lon: float, days: int) -> dict:
    url = (f"{FORECAST_URL}?latitude={lat}&longitude={lon}&current={CURRENT_VARS}"
           f"&hourly={HOURLY_VARS}&daily={DAILY_VARS}&timezone=auto&forecast_days={days}")
    return _get_json(url)


def fetch_air(lat: float, lon: float) -> dict:
    url = f"{AIR_URL}?latitude={lat}&longitude={lon}&current=us_aqi,pm2_5,pm10,ozone&timezone=auto"
    return _get_json(url)


# -----------------------------------------------------------------------------
# 3. QUESTION UNDERSTANDING
# -----------------------------------------------------------------------------
INTENT_WORDS = {
    "temperature": ["temperature", "temp", "hot", "heat", "cold", "warm", "cool", "celsius", "degree", "degrees",
                    "sunny", "feels", "feel"],
    "humidity": ["humidity", "humid", "muggy", "dew"],
    "wind": ["wind", "windy", "breeze", "gust", "gusts", "pressure"],
    "rain": ["rain", "rainfall", "raining", "rainy", "precipitation", "shower", "showers", "drizzle", "monsoon",
             "umbrella", "wet", "thunderstorm", "thunder", "storm", "chance", "probability", "likely"],
    "uv": ["uv", "sunburn", "sunscreen", "sunrise", "sunset"],
    "air": ["aqi", "air", "pollution", "pm2", "smog"],
    "hourly": ["hourly", "tonight", "tonite", "morning", "afternoon", "evening", "night", "next hours", "hours"],
    "week": ["week", "weekly", "7 day", "7-day", "seven day", "next days", "coming days", "outlook", "weekend"],
    "forecast": ["forecast", "prediction", "predict", "tomorrow", "will it"],
}
GENERIC = ["weather", "climate", "forecast", "outside", "mausam", "imd", "meteorolog"]
DB_HINTS = [
    "vinereadings", "vineid", "subsystemid", "virv", "viyv", "vibv", "viri", "viyi", "vibi", "vitemp",
    "vienergy", "telemetry", "sensor", "enclosure", "panel", "imbalance", "battery", "voltage",
    "readings", "reading", "device", "kwh", "hourwise", "database", "table", "sql",
]
_PLACE_STOP = {
    "today", "tomorrow", "tonight", "now", "currently", "this", "next", "week", "weekend", "please", "right", "is",
    "will", "be", "going", "to", "the", "like", "forecast", "weather", "temperature", "rain", "raining", "morning",
    "evening", "afternoon", "night", "and", "or", "for", "hot", "outside", "what", "whats", "what's", "how", "tell",
    "me", "give", "show", "get", "a", "an", "it", "on", "of", "at", "in", "near", "around", "chance", "probability",
    "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday", "day", "days", "uv", "aqi", "wind",
    "humidity", "complete", "full", "detailed", "predictions", "prediction", "report", "can", "you", "do", "does",
    "any", "there", "going", "feels", "feel", "much", "many", "latest", "current", "check", "see", "i", "we", "my",
}


def _has_word(text: str, word: str) -> bool:
    return re.search(r"\b" + re.escape(word) + r"\b", text) is not None


def detect_intents(question: str) -> list[str]:
    q = question.lower()
    return [k for k, ws in INTENT_WORDS.items() if any(_has_word(q, w) for w in ws)]


def _strip_prefix(question: str) -> tuple[str, bool]:
    m = re.match(r"^\s*(/weather|/imd|weather\s*:|imd\s*:)\s*", question, flags=re.I)
    if m:
        return question[m.end():].strip() or question, True
    return question, False


def is_enabled() -> bool:
    return bool(st.session_state.get("wx_enabled", False))


def should_handle(question: str) -> bool:
    """True if this question should be answered with weather data."""
    _, forced = _strip_prefix(question)
    if forced:
        return True
    if not is_enabled():
        return False
    q = question.lower()
    if any(h in q for h in DB_HINTS):
        return False
    if any(_has_word(q, w) for w in GENERIC):
        return True
    strong = {"temperature", "humidity", "wind", "rain", "uv", "air", "week", "forecast"}
    return bool(strong & set(detect_intents(question)))


def extract_place(question: str) -> str:
    """Pull a place name out of the question ('rain in new york tomorrow' -> 'new york')."""
    q = re.sub(r"[?!,;]", " ", question)

    def clean(cand: str) -> str:
        words = cand.split()
        keep = []
        for w in words:
            if w.lower().strip(".'") in _PLACE_STOP:
                if keep:
                    break
                continue
            keep.append(w)
        return " ".join(keep).strip(" .-'")

    for m in re.finditer(r"\b(?:in|at|for|near|around)\s+([A-Za-z][A-Za-z.\-' ]{1,40})", q, flags=re.I):
        c = clean(m.group(1))
        if len(c) >= 3:
            return c
    m = re.search(r"([A-Za-z][A-Za-z\-' ]{2,30}?)\s+(?:weather|forecast|temperature|climate|rain)\b", q, flags=re.I)
    if m:
        c = clean(m.group(1))
        if len(c) >= 3:
            return c
    return ""


def target_day_indexes(question: str, dates: list[str]) -> tuple[list[int], str]:
    """Which forecast days the user is asking about -> (indexes, label)."""
    q = question.lower()
    if not dates:
        return [0], "Today"
    if "day after tomorrow" in q and len(dates) > 2:
        return [2], "Day after tomorrow"
    if "tomorrow" in q and len(dates) > 1:
        return [1], "Tomorrow"
    if "weekend" in q:
        idx = [i for i, d in enumerate(dates) if datetime.strptime(d, "%Y-%m-%d").weekday() >= 5][:2]
        if idx:
            return idx, "This weekend"
    for wd_i, wd in enumerate(WEEKDAYS):
        if _has_word(q, wd):
            for i, d in enumerate(dates):
                if datetime.strptime(d, "%Y-%m-%d").weekday() == wd_i and (i > 0 or "today" in q):
                    return [i], wd.capitalize()
    if any(_has_word(q, w) for w in ("week", "weekly", "7 day", "7-day", "outlook")):
        return list(range(len(dates))), "This week"
    return [0], "Today"


# -----------------------------------------------------------------------------
# 4. REPORT BUILDER (pure logic - no network, no streamlit)
# -----------------------------------------------------------------------------
def _n(x):
    try:
        if x is None:
            return None
        v = float(x)
        return None if v != v else v
    except Exception:
        return None


def _f(x, unit="", dec=1):
    v = _n(x)
    return "n/a" if v is None else f"{v:.{dec}f}{unit}"


def _col(block: dict, key: str) -> list:
    return (block or {}).get(key) or []


def _hour_windows(times: list[str], probs: list, threshold: float = 40) -> list[str]:
    """Contiguous hour ranges where rain probability >= threshold."""
    wins, start, prev = [], None, None
    for t, p in zip(times, probs):
        pv = _n(p)
        hit = pv is not None and pv >= threshold
        hh = t[11:16]
        if hit and start is None:
            start = hh
        if not hit and start is not None:
            wins.append(f"{start}–{prev}" if start != prev else start)
            start = None
        prev = hh
    if start is not None:
        wins.append(f"{start}–{prev}" if start != prev else start)
    return wins


def build_report(question: str, place: dict, fc: dict, air: dict | None, depth: str) -> dict:
    intents = detect_intents(question)
    cur = fc.get("current") or {}
    hr = fc.get("hourly") or {}
    dl = fc.get("daily") or {}
    dates = _col(dl, "time")
    h_times = _col(hr, "time")

    name = ", ".join(x for x in [place.get("name"), place.get("admin1"), place.get("country")] if x)
    idxs, label = target_day_indexes(question, dates)
    full = depth == "Full analyst brief"

    # index of the current hour in the hourly arrays
    now_key = str(cur.get("time", ""))[:13]
    h_now = next((i for i, t in enumerate(h_times) if t[:13] == now_key), 0)

    def day(i):
        g = lambda k: (_col(dl, k)[i] if i < len(_col(dl, k)) else None)
        return {
            "date": dates[i], "dow": datetime.strptime(dates[i], "%Y-%m-%d").strftime("%a %d %b"),
            "code": g("weather_code"), "tmax": g("temperature_2m_max"), "tmin": g("temperature_2m_min"),
            "fmax": g("apparent_temperature_max"), "fmin": g("apparent_temperature_min"),
            "sunrise": g("sunrise"), "sunset": g("sunset"), "uv": g("uv_index_max"),
            "rain_mm": g("precipitation_sum"), "rain_h": g("precipitation_hours"),
            "rain_p": g("precipitation_probability_max"), "wind": g("wind_speed_10m_max"),
            "gust": g("wind_gusts_10m_max"),
        }

    days = [day(i) for i in range(len(dates))]

    def hours_of(date: str):
        return [i for i, t in enumerate(h_times) if t.startswith(date)]

    md = [f"### 🌤️ Weather Prediction — {name}",
          f"*Local time {str(cur.get('time', ''))[:16].replace('T', ' ')} · {fc.get('timezone', '')} · "
          f"{_f(place.get('latitude'), '', 2)}°, {_f(place.get('longitude'), '', 2)}°*"]

    # ---- right now ----------------------------------------------------------------------------
    now_lines = []
    if cur:
        p_now = _n(_col(hr, "precipitation_probability")[h_now]) if h_now < len(_col(hr, "precipitation_probability")) else None
        now_lines = [
            f"- **{wx_desc(cur.get('weather_code'))}** · **{_f(cur.get('temperature_2m'), ' °C')}** "
            f"(feels like {_f(cur.get('apparent_temperature'), ' °C')} — {heat_label(_n(cur.get('apparent_temperature')))})",
            f"- **Humidity:** {_f(cur.get('relative_humidity_2m'), '%', 0)} · **Cloud cover:** {_f(cur.get('cloud_cover'), '%', 0)} "
            f"· **Pressure:** {_f(cur.get('pressure_msl'), ' hPa', 0)}",
            f"- **Wind:** {_f(cur.get('wind_speed_10m'), ' km/h')} {compass(cur.get('wind_direction_10m'))} "
            f"({wind_label(_n(cur.get('wind_speed_10m')))}), gusts {_f(cur.get('wind_gusts_10m'), ' km/h')}",
            f"- **Rain this hour:** {_f(p_now, '%', 0)} chance ({rain_label(p_now)}) · "
            f"{_f(cur.get('precipitation'), ' mm')} falling now",
        ]

    # ---- per-day summaries (headline) -----------------------------------------------------------
    day_lines = []
    for i in idxs:
        d = days[i]
        hs = hours_of(d["date"])
        wins = _hour_windows([h_times[j] for j in hs], [_col(hr, "precipitation_probability")[j] for j in hs])
        p = _n(d["rain_p"])
        line = (f"- **{d['dow']}** — {wx_desc(d['code'])} · High **{_f(d['tmax'], '°')}** / Low **{_f(d['tmin'], '°')}** "
                f"(feels up to {_f(d['fmax'], '°')}) · 🌧️ **{_f(p, '%', 0)}** chance of rain ({rain_label(p)}), "
                f"{_f(d['rain_mm'], ' mm')} expected over {_f(d['rain_h'], ' h', 0)}"
                + (f", most likely around **{', '.join(wins[:3])}**" if wins else "")
                + f" · 💨 up to {_f(d['wind'], ' km/h', 0)} (gusts {_f(d['gust'], ' km/h', 0)}) · "
                  f"☀️ UV {_f(d['uv'], '', 0)} ({uv_label(_n(d['uv']))})")
        day_lines.append(line)

    # ---- hourly outlook (3-hourly, next 24 h) ----------------------------------------------------
    hourly_rows = []
    for j in range(h_now, min(h_now + 24, len(h_times)), 3):
        hourly_rows.append(
            f"| {h_times[j][5:10]} {h_times[j][11:16]} | {wx_desc(_col(hr, 'weather_code')[j])} | "
            f"{_f(_col(hr, 'temperature_2m')[j], '°', 0)} | {_f(_col(hr, 'apparent_temperature')[j], '°', 0)} | "
            f"{_f(_col(hr, 'precipitation_probability')[j], '%', 0)} | {_f(_col(hr, 'precipitation')[j], ' mm')} | "
            f"{_f(_col(hr, 'wind_speed_10m')[j], ' km/h', 0)} | {_f(_col(hr, 'uv_index')[j], '', 0)} |")
    hourly_tbl = ("| Time | Sky | Temp | Feels | Rain % | Rain mm | Wind | UV |\n|---|---|---|---|---|---|---|---|\n"
                  + "\n".join(hourly_rows)) if hourly_rows else ""

    # ---- sections in the order that matches the question -----------------------------------------
    focus_rain = "rain" in intents
    focus_temp = "temperature" in intents
    generic = not intents or intents == ["forecast"]

    if now_lines and (label == "Today" or full or generic):
        md.append("#### 📍 Right now\n" + "\n".join(now_lines))
    if day_lines:
        md.append(f"#### 📅 {label}\n" + "\n".join(day_lines))

    if focus_rain or generic or full:
        rl = []
        if len(idxs) > 1:                      # week / weekend: one compact line per day
            for i in idxs:
                d = days[i]
                pp = _n(d["rain_p"])
                rl.append(f"- **{d['dow']}:** {_f(pp, '%', 0)} → {rain_label(pp)} · {_f(d['rain_mm'], ' mm')} expected")
        for i in idxs[:1] if len(idxs) == 1 else []:
            d = days[i]
            hs = hours_of(d["date"])
            wins = _hour_windows([h_times[j] for j in hs], [_col(hr, "precipitation_probability")[j] for j in hs])
            p = _n(d["rain_p"])
            rl.append(f"- **{d['dow']}:** {_f(p, '%', 0)} peak probability → rain is **{rain_label(p)}**; "
                      f"expected total {_f(d['rain_mm'], ' mm')}.")
            if wins:
                rl.append(f"- **Wettest periods (≥40% chance):** {', '.join(wins)}")
            elif p is not None:
                rl.append("- No hour reaches a 40% chance of rain — mostly dry.")
            if p is not None and p >= 40:
                rl.append("- ☂️ Carry an umbrella / protect outdoor equipment during those windows.")
        rain_days = [d["dow"] for d in days if (_n(d["rain_p"]) or 0) >= 50]
        rl.append(f"- **Rain ≥50% likely on {len(rain_days)} of the next {len(days)} days**"
                  + (f": {', '.join(rain_days)}" if rain_days else "."))
        md.append("#### 🌧️ Rain probability\n" + "\n".join(rl))

    if hourly_tbl and (full or "hourly" in intents or (label == "Today" and (generic or focus_rain or focus_temp))):
        md.append("#### ⏱️ Next 24 hours (3-hourly)\n" + hourly_tbl)

    if "wind" in intents or "humidity" in intents or full:
        d0 = days[idxs[0]] if idxs else None
        extra = []
        if d0:
            extra.append(f"- **Wind:** up to {_f(d0['wind'], ' km/h', 0)}, gusts {_f(d0['gust'], ' km/h', 0)} "
                         f"({wind_label(_n(d0['wind']))})")
            if d0.get("sunrise"):
                extra.append(f"- **Sunrise / Sunset:** {str(d0['sunrise'])[11:16]} / {str(d0['sunset'])[11:16]}")
        vis = _n(_col(hr, "visibility")[h_now]) if h_now < len(_col(hr, "visibility")) else None
        if vis is not None:
            extra.append(f"- **Visibility:** {vis / 1000:.1f} km")
        if extra:
            md.append("#### 🌬️ Wind, humidity & light\n" + "\n".join(extra))

    aq = (air or {}).get("current") or {}
    if aq and ("air" in intents or full or generic):
        a = _n(aq.get("us_aqi"))
        md.append("#### 🏭 Air quality\n"
                  f"- **US AQI:** {_f(a, '', 0)} — **{aqi_label(a)}** · PM2.5 {_f(aq.get('pm2_5'), ' µg/m³')} · "
                  f"PM10 {_f(aq.get('pm10'), ' µg/m³')} · Ozone {_f(aq.get('ozone'), ' µg/m³', 0)}")

    # ---- analyst notes ------------------------------------------------------------------------------
    notes = []
    if days:
        mx = [_n(d["tmax"]) for d in days if _n(d["tmax"]) is not None]
        if len(mx) >= 3:
            delta = mx[-1] - mx[0]
            notes.append(f"{len(mx)}-day high-temperature trend is **{'warming' if delta >= 1.5 else 'cooling' if delta <= -1.5 else 'steady'}** "
                         f"({mx[0]:.0f} → {mx[-1]:.0f} °C, range {min(mx):.0f}–{max(mx):.0f} °C).")
        wettest = max(days, key=lambda d: _n(d["rain_p"]) or 0)
        if (_n(wettest["rain_p"]) or 0) >= 40:
            notes.append(f"Wettest day ahead: **{wettest['dow']}** ({_f(wettest['rain_p'], '%', 0)} chance, {_f(wettest['rain_mm'], ' mm')}).")
        d0 = days[0]
        if (_n(d0["tmax"]) or 0) >= 34:
            notes.append(f"High daytime temperature ({_f(d0['tmax'], ' °C', 0)}) → expect **higher cooling (HVAC) load** in the afternoon.")
        if (_n(d0["fmax"]) or 0) >= 39:
            notes.append(f"Feels-like reaches {_f(d0['fmax'], ' °C', 0)} → **heat-stress precautions** for outdoor staff.")
        if (_n(d0["gust"]) or 0) >= 50:
            notes.append(f"Wind gusts up to {_f(d0['gust'], ' km/h', 0)} → secure rooftop / outdoor equipment.")
        # best outdoor-work window today (daylight, dry, not too hot, UV < 8)
        hs = hours_of(d0["date"])
        good = [h_times[j][11:16] for j in hs
                if 7 <= int(h_times[j][11:13]) <= 18 and j >= h_now
                and (_n(_col(hr, "precipitation_probability")[j]) or 0) < 30
                and (_n(_col(hr, "apparent_temperature")[j]) or 0) < 36
                and (_n(_col(hr, "uv_index")[j]) or 0) < 8]
        if good:
            notes.append(f"Best remaining outdoor-work window today: **{good[0]}–{good[-1]}** (dry, tolerable heat, UV < 8).")
        elif hs:
            notes.append("No comfortable dry daylight window left today.")
    if notes and (full or generic or len(idxs) == 1):
        md.append("#### 🧠 Analyst notes\n" + "\n".join(f"- {n}" for n in notes[:6 if full else 3]))

    md.append(f"*{ATTRIBUTION}. Forecasts are model predictions and can change.*")

    df = None
    if days:
        df = pd.DataFrame([{
            "Date": d["date"], "Day": d["dow"].split()[0], "Max °C": _n(d["tmax"]), "Min °C": _n(d["tmin"]),
            "Rain %": _n(d["rain_p"]), "Rain mm": _n(d["rain_mm"]), "Wind km/h": _n(d["wind"]),
            "UV": _n(d["uv"]), "Sky": WMO.get(int(d["code"]), ("", ""))[0] if d["code"] is not None else "",
        } for d in days])
    return {"found": True, "markdown": "\n\n".join(md), "df": df}


# -----------------------------------------------------------------------------
# 5. FETCH + ANALYSE
# -----------------------------------------------------------------------------
def analyze(question: str) -> dict:
    question, _ = _strip_prefix(question)
    default_city = st.session_state.get("wx_default_city", "Chennai")
    depth = st.session_state.get("wx_depth", "Quick answer")
    days = int(st.session_state.get("wx_days", 7))
    want_air = bool(st.session_state.get("wx_air", True))

    place = None
    asked = extract_place(question)
    try:
        if asked:
            place = geocode(asked)
            if place is None:
                return {"found": False, "df": None, "markdown": (
                    f"### 🌤️ Weather\nI couldn't find a place called **{asked}**. "
                    "Please check the spelling or try the nearest big city.")}
        if place is None:
            place = geocode(default_city)
        if place is None:
            return {"found": False, "df": None, "markdown": (
                "### 🌤️ Weather\nI couldn't tell which city you mean. Include a city "
                "(e.g. *“rain tomorrow in Madurai”*) or set a default city in the sidebar.")}

        lat, lon = place["latitude"], place["longitude"]
        intents = detect_intents(question)
        need_air = want_air and ("air" in intents or depth == "Full analyst brief" or not intents)
        with ThreadPoolExecutor(max_workers=2) as pool:
            f_fc = pool.submit(fetch_forecast, lat, lon, days)
            f_air = pool.submit(fetch_air, lat, lon) if need_air else None
            fc = f_fc.result()
            air = None
            if f_air is not None:
                try:
                    air = f_air.result()
                except WeatherError:
                    air = None          # air quality is optional - never block the forecast
        return build_report(question, place, fc, air, depth)
    except WeatherError as e:
        return {"found": False, "df": None, "markdown": (
            "### 🌤️ Weather\nI could not fetch the forecast, so I will not guess any numbers.\n\n"
            f"**Reason:** {e}")}


def answer_in_chat(question: str) -> None:
    """Fetch weather, append user + assistant messages to the chat, rerun."""
    clean_q, _ = _strip_prefix(question)
    msgs = st.session_state.setdefault("messages", [])
    msgs.append({"role": "user", "content": question})
    with st.status("🌤️ Weather analyst: fetching live forecast...", expanded=True) as status:
        st.write("• Locating the city and downloading forecast, rain-probability and air-quality data...")
        result = analyze(clean_q)
        status.update(label="✅ Weather analysis complete" if result["found"] else "⚠️ Weather data unavailable",
                      state="complete" if result["found"] else "error", expanded=False)
    msg = {"role": "assistant", "content": result["markdown"], "question": question}
    if result.get("df") is not None:
        msg["df"] = result["df"]
    msgs.append(msg)
    st.rerun()


# -----------------------------------------------------------------------------
# 6. SIDEBAR
# -----------------------------------------------------------------------------
def render_settings() -> None:
    """Call inside `with st.sidebar:`"""
    ss = st.session_state
    ss.setdefault("wx_enabled", False)
    ss.setdefault("wx_default_city", "Chennai")
    ss.setdefault("wx_depth", "Quick answer")
    ss.setdefault("wx_days", 7)
    ss.setdefault("wx_air", True)

    st.markdown("### 🌤️ Weather Prediction Analyst")
    st.toggle("Enable weather mode (live forecasts)", key="wx_enabled",
              help="When ON, weather questions (temperature, rain probability, wind, UV, air quality...) are "
                   "answered with live forecast data. Building/sensor questions still go to your database. "
                   "You can also type '/weather <question>' any time.")
    st.text_input("Default city", key="wx_default_city", help="Used when your question names no city.")
    st.radio("Answer depth", ["Quick answer", "Full analyst brief"], key="wx_depth", horizontal=True)
    c1, c2 = st.columns(2)
    with c1:
        st.select_slider("Forecast days", options=[3, 5, 7, 10, 14, 16], key="wx_days")
    with c2:
        st.checkbox("Air quality", key="wx_air")
    if st.button("Test weather connection", key="wx_test_btn", use_container_width=True):
        try:
            _get_json.clear()
        except Exception:
            pass
        try:
            p = geocode(ss.get("wx_default_city") or "Chennai")
            if not p:
                st.error("Connected, but the default city was not found.")
            else:
                fc = fetch_forecast(p["latitude"], p["longitude"], 3)
                st.success(f"✅ Connected — {p['name']}: {fc['current']['temperature_2m']} °C right now")
        except Exception as e:
            st.error(f"❌ {e}")