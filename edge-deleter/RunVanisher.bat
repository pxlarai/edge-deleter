@echo off
title Edge Vanisher Launcher
:: This script launches the PowerShell version with Admin rights and bypasses execution policies
cd /d "%~dp0"

:: Check for Admin Rights
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Launching with Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Run the PowerShell Script
powershell -ExecutionPolicy Bypass -File "EdgeVanisher.ps1"

echo.
echo Process finished.
pause