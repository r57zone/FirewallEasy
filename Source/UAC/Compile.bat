@echo off

echo.

REM Requires brcc32.exe to be on %PATH%
brcc32.exe .\UAC.rc
echo.

pause

exit /b