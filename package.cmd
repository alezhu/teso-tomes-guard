@echo off
setlocal
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0package.ps1" %*

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Packaging failed with exit code %ERRORLEVEL%.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo ========================================================
echo Package successfully generated in "dist\" folder.
echo You can upload the ZIP file directly to ESOUI.
echo ========================================================
echo.

pause
