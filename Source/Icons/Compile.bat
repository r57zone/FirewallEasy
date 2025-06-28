@echo off

set OUTPUT=Icons

echo.

REM Requires brcc32.exe to be on %PATH%
brcc32.exe .\%OUTPUT%.rc -fo .\%OUTPUT%.res
echo.

pause

exit /b 0