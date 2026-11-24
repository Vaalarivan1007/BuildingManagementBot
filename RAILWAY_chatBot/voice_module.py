"""
voice_module.py
===============
Standalone Multilingual Voice Search + Live Translation module for the
Building Management AI Master Agent (Streamlit).

Languages : English, Tamil, Hindi, Kannada, Telugu, Malayalam
Features  : * Speech-to-text in any of the 6 languages (browser speech engine)
            * Live translation of what you said into ALL 6 languages
            * Chat box is filled with the English translation (best for the
              Text-to-SQL engine) or with the original spoken text - your choice
            * Mic button pinned inside the chat input (same look as before)

Install   : pip install streamlit-mic-recorder deep-translator

Public API (the only 3 calls the main app needs)
------------------------------------------------
    import voice_module as vm

    vm.inject_voice_css()          # once, right after st.set_page_config / main CSS
    vm.render_voice_settings()     # inside `with st.sidebar:` (language pickers)
    vm.render_voice_input()        # just BEFORE st.chat_input(...)

Extra helper you can use anywhere (e.g. to translate AI answers):
    vm.translate_text("Hello", "en", "ta")
    vm.translate_to_all("Show latest readings", "en")
"""

from __future__ import annotations

import json
import time
from concurrent.futures import ThreadPoolExecutor

import streamlit as st
import streamlit.components.v1 as components

try:
    from streamlit_mic_recorder import speech_to_text
    _MIC_OK = True
except Exception:  # pragma: no cover
    speech_to_text = None
    _MIC_OK = False

try:
    from deep_translator import GoogleTranslator
    _TRANSLATOR_OK = True
except Exception:  # pragma: no cover
    GoogleTranslator = None
    _TRANSLATOR_OK = False


# -----------------------------------------------------------------------------
# 1. LANGUAGE TABLE
#    speech    -> BCP-47 code used by the browser speech recogniser
#    translate -> ISO code used by the translator
# -----------------------------------------------------------------------------
LANGUAGES: dict[str, dict[str, str]] = {
    "English (India)":     {"speech": "en-IN", "translate": "en", "short": "English"},
    "English (US)":        {"speech": "en-US", "translate": "en", "short": "English"},
    "Tamil (தமிழ்)":        {"speech": "ta-IN", "translate": "ta", "short": "Tamil"},
    "Hindi (हिंदी)":         {"speech": "hi-IN", "translate": "hi", "short": "Hindi"},
    "Kannada (ಕನ್ನಡ)":      {"speech": "kn-IN", "translate": "kn", "short": "Kannada"},
    "Telugu (తెలుగు)":      {"speech": "te-IN", "translate": "te", "short": "Telugu"},
    "Malayalam (മലയാളം)":  {"speech": "ml-IN", "translate": "ml", "short": "Malayalam"},
}

# One entry per language for the translation panel (English listed once)
TRANSLATION_TARGETS: dict[str, str] = {
    "English": "en",
    "Tamil (தமிழ்)": "ta",
    "Hindi (हिंदी)": "hi",
    "Kannada (ಕನ್ನಡ)": "kn",
    "Telugu (తెలుగు)": "te",
    "Malayalam (മലയാളം)": "ml",
}



# -----------------------------------------------------------------------------
# 2. CSS  (mic pinned to the left of the chat input)
# -----------------------------------------------------------------------------
def inject_voice_css() -> None:
    st.markdown(
        """
        <style>
        /* Room to the LEFT of the chat box for the mic button */
        div[data-testid="stChatInput"] {
            margin-left: 62px !important;
            width: calc(100% - 62px) !important;
        }
        /* Fallback placement; JS in render_voice_input() keeps it aligned */
        div[data-testid="stElementContainer"]:has(iframe[title*="mic_recorder"]),
        div[data-testid="element-container"]:has(iframe[title*="mic_recorder"]),
        div.element-container:has(iframe[title*="mic_recorder"]) {
            position: fixed !important;
            bottom: 24px;
            left: 40vw;
            width: 50px !important;
            height: 50px !important;
            min-height: 0 !important;
            margin: 0 !important;
            z-index: 999999 !important;
            background: transparent !important;
            mix-blend-mode: lighten;
        }
        iframe[title*="mic_recorder"] {
            width: 50px !important;
            height: 50px !important;
            background: transparent !important;
            border: none !important;
            color-scheme: normal;
        }
        .voice-card {
            background-color: #12151f; border: 1px solid #2a2f3d;
            border-radius: 10px; padding: 0.6rem 0.9rem; margin-bottom: 0.4rem;
        }
        .voice-card .vl { color: #a855f7; font-size: 0.78rem; font-weight: 600; }
        .voice-card .vt { color: #e6e6e6; font-size: 1.0rem; }
        </style>
        """,
        unsafe_allow_html=True,
    )


# -----------------------------------------------------------------------------
# 3. SESSION STATE
# -----------------------------------------------------------------------------
def _init_state() -> None:
    ss = st.session_state
    ss.setdefault("voice_lang_name", "English (India)")
    ss.setdefault("voice_lang", LANGUAGES[ss["voice_lang_name"]]["speech"])  # kept for compatibility


# -----------------------------------------------------------------------------
# 4. TRANSLATION ENGINE
# -----------------------------------------------------------------------------
def _google_direct(text: str, source: str, target: str) -> str:
    """Dependency-free fallback: calls the public Google Translate web endpoint."""
    import urllib.parse
    import urllib.request

    url = (
        "https://translate.googleapis.com/translate_a/single?client=gtx"
        f"&sl={source}&tl={target}&dt=t&q={urllib.parse.quote(text)}"
    )
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=10) as resp:
        data = json.loads(resp.read().decode("utf-8"))
    return "".join(seg[0] for seg in data[0] if seg and seg[0])


@st.cache_data(show_spinner=False, ttl=3600)
def _cached_translate(text: str, source: str, target: str) -> str:
    """Try deep-translator first, then the direct endpoint.
    RAISES if every backend fails (so failures are never cached or hidden)."""
    errors: list[str] = []
    result = ""

    if _TRANSLATOR_OK:
        try:
            result = (GoogleTranslator(source=source, target=target).translate(text) or "").strip()
            if result and result != text.strip():
                return result
        except Exception as e:
            errors.append(f"deep-translator: {type(e).__name__}: {e}")

    try:
        result2 = _google_direct(text, source, target).strip()
        if result2:
            return result2
    except Exception as e:
        errors.append(f"direct: {type(e).__name__}: {e}")

    if result and not errors:
        return result  # backend answered; text legitimately unchanged
    raise RuntimeError(" | ".join(errors) or "empty translation")


def _translate_safe(text: str, source: str, target: str) -> tuple[str, str | None]:
    text = (text or "").strip()
    if not text or source == target:
        return text, None
    try:
        return _cached_translate(text, source, target), None
    except Exception as e:
        return text, str(e)


def translate_text(text: str, source: str, target: str) -> str:
    """Translate one string. Returns the original text if translation fails."""
    return _translate_safe(text, source, target)[0]


def _translate_all(text: str, source: str) -> tuple[dict[str, str], dict[str, str]]:
    def _one(item):
        label, code = item
        out, err = _translate_safe(text, source, code)
        return label, out, err

    with ThreadPoolExecutor(max_workers=len(TRANSLATION_TARGETS)) as pool:
        rows = list(pool.map(_one, TRANSLATION_TARGETS.items()))
    return (
        {label: out for label, out, _ in rows},
        {label: err for label, _, err in rows if err},
    )


def translate_to_all(text: str, source: str) -> dict[str, str]:
    """Translate into all 6 languages in parallel (fast 'live' feel)."""
    return _translate_all(text, source)[0]


# -----------------------------------------------------------------------------
# 5. SIDEBAR SETTINGS
# -----------------------------------------------------------------------------
def render_voice_settings() -> None:
    """Call inside `with st.sidebar:`"""
    _init_state()
    st.markdown("### 🗣️ Multilingual Voice Settings")

    names = list(LANGUAGES.keys())
    st.selectbox(
        "Speech Language (what you will speak)",
        names,
        key="voice_lang_name",
    )
    st.session_state["voice_lang"] = LANGUAGES[st.session_state["voice_lang_name"]]["speech"]

    if not _MIC_OK:
        st.warning("Install the mic component: `pip install streamlit-mic-recorder`")
    if not _TRANSLATOR_OK:
        st.warning("Install the translator: `pip install deep-translator`")


# -----------------------------------------------------------------------------
# 6. MIC + CHAT-BOX FILL + LIVE TRANSLATION PANEL
# -----------------------------------------------------------------------------
_MIC_SYNC_JS = """
<script>
(function () {
    const P = window.parent;
    const D = P.document;
    if (P.__micSync) { clearInterval(P.__micSync); }

    function sync() {
        const ifr  = D.querySelector('iframe[title*="mic_recorder"]');
        const chat = D.querySelector('div[data-testid="stChatInput"]');
        if (!ifr || !chat) return;

        const box = ifr.closest('[data-testid="stElementContainer"]')
                 || ifr.closest('[data-testid="element-container"]')
                 || ifr.closest('.element-container')
                 || ifr.parentElement;

        const r = chat.getBoundingClientRect();
        if (r.width === 0 || r.height === 0) return;

        const h = Math.min(Math.round(r.height), 56);
        const w = h;
        const top  = r.bottom - h;
        const left = r.left - w - 8;

        const set = (el, k, v) => el.style.setProperty(k, v, 'important');
        set(box, 'position', 'fixed');
        set(box, 'top', top + 'px');
        set(box, 'left', left + 'px');
        set(box, 'bottom', 'auto');
        set(box, 'width', w + 'px');
        set(box, 'height', h + 'px');
        set(box, 'margin', '0');
        set(box, 'z-index', '999999');
        set(box, 'background', 'transparent');
        set(ifr, 'width', w + 'px');
        set(ifr, 'height', h + 'px');
        set(ifr, 'border', 'none');
        set(ifr, 'background', 'transparent');

        try {
            const d = ifr.contentDocument;
            if (d && d.body) {
                d.documentElement.style.setProperty('background', 'transparent', 'important');
                d.body.style.setProperty('background', 'transparent', 'important');
                d.body.style.setProperty('margin', '0', 'important');
                d.body.style.setProperty('overflow', 'hidden', 'important');
                d.documentElement.style.setProperty('height', h + 'px', 'important');
                d.body.style.setProperty('height', h + 'px', 'important');
                const b = d.querySelector('button');
                if (b) {
                    b.style.setProperty('background', '#12151f', 'important');
                    b.style.setProperty('border', '1px solid #2a2f3d', 'important');
                    b.style.setProperty('border-radius', '10px', 'important');
                    b.style.setProperty('outline', 'none', 'important');
                    b.style.setProperty('box-shadow', 'none', 'important');
                    b.style.setProperty('width', w + 'px', 'important');
                    b.style.setProperty('height', h + 'px', 'important');
                    b.style.setProperty('display', 'flex', 'important');
                    b.style.setProperty('align-items', 'center', 'important');
                    b.style.setProperty('justify-content', 'center', 'important');
                    b.style.setProperty('padding', '0', 'important');
                    b.style.setProperty('margin', '0', 'important');
                    b.style.setProperty('line-height', '1', 'important');
                    b.style.setProperty('font-size', Math.round(h * 0.42) + 'px', 'important');
                    b.style.setProperty('cursor', 'pointer', 'important');
                }
            }
        } catch (e) {}
    }

    sync();
    P.__micSync = setInterval(sync, 150);
    P.addEventListener('resize', sync);
})();
</script>
"""

_FILL_JS = """
<script>
// nonce: __NONCE__
(function () {
    const text = __TEXT__;
    const PW = window.parent;
    const D = PW.document;
    let tries = 0;
    const t = setInterval(function () {
        tries++;
        const ta = D.querySelector('div[data-testid="stChatInput"] textarea')
                || D.querySelector('div[data-testid="stChatInput"] input');
        if (ta) {
            const proto = ta.tagName === 'TEXTAREA'
                ? PW.HTMLTextAreaElement.prototype
                : PW.HTMLInputElement.prototype;
            const setter = Object.getOwnPropertyDescriptor(proto, 'value').set;
            setter.call(ta, text);
            ta.dispatchEvent(new PW.Event('input', { bubbles: true }));
            ta.focus();
            clearInterval(t);
        } else if (tries > 30) {
            clearInterval(t);
        }
    }, 100);
})();
</script>
"""


def _fill_chat_box(text: str) -> None:
    js = (
        _FILL_JS
        .replace("__TEXT__", json.dumps(text).replace("</", "<\\/"))
        .replace("__NONCE__", str(time.time()))
    )
    components.html(js, height=0)


def render_voice_input() -> None:
    """Call right BEFORE st.chat_input(). Renders the mic, captures speech,
    translates it live and drops the result into the chat box."""
    _init_state()

    if not _MIC_OK:
        st.error("Voice input unavailable: `pip install streamlit-mic-recorder`")
        return

    speech_code = st.session_state["voice_lang"]
    lang_name = st.session_state["voice_lang_name"]
    src_code = LANGUAGES[lang_name]["translate"]

    recorded = speech_to_text(
        start_prompt="🎙️",
        stop_prompt="⏹️",
        language=speech_code,
        just_once=True,
        key=f"chat_mic_recorder_{speech_code}",
    )

    components.html(_MIC_SYNC_JS, height=0)

    if recorded and isinstance(recorded, str) and recorded.strip():
        original = recorded.strip()
        english, err = _translate_safe(original, src_code, "en")
        if err:
            st.toast("⚠️ Could not translate to English — check internet connection")
        _fill_chat_box(english)