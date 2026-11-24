@echo off
title Railway Management Smart ChatBot (OMCS Central Operations)
echo ========================================================
echo Launching RAILWAY_chatBot on Live OMCS Database...
echo Host: 10.20.31.15:3306 (OMCSMGMT_2_0_0)
echo ========================================================
cd /d "c:\Users\Vallarivan\RAILWAY_chatBot"
python -m streamlit run app.py
pause
