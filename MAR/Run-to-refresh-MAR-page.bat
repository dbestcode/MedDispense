@echo off
setlocal enabledelayedexpansion enableextensions
echo: >list.txt
echo Scanning for PDF MAR files....
timeout 1
FOR %%i IN (*.pdf) DO (
	echo %%i >> list.txt
)
set /a i=0
type head.html>links.htm

FOR /F "tokens=1 delims=" %%A IN (list.txt) DO (

	set filename=%%A
	::echo ^<a href=^'!filename!^'^>!filename!^<^/a^>^<br^>>>links.htm
	echo: Found: %%A
	echo added to links...
	echo   ^<tr^>>>links.htm
		echo     ^<td^>^<a href=^'!filename!^' target=^'mar^'^>!filename!^<^/a^>^<^/td^>>>links.htm
		echo   ^</tr^>>>links.htm
	set /a i=!i!+1
)
echo ^<^/table^>^<section id="bottom"^>^<^/section^>^<^/body^>^<^/html^>>>links.htm
set /a TotalFiles=!i!-1
echo Made !i! links.
echo Page has been updated
del list.txt
timeout 90

