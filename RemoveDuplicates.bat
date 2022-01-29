::RemoveDups
::a utlitty for removing accidental duplicate ScannedDrugs and barcodes enmasse
::writen 12.3.2018 by N.Best
::1.0

@echo off
setlocal enabledelayedexpansion enableextensions
::add to admin log
echo DupStudentRun, AUTOtech, %date%, %time%>>log\ADMINLOG.txt

::===================================================================================
cls
if exist %1 (
   type %1>data\tempstudents.file
   del /s %1
) else (
	echo xxx,xxx,xxx,xxx>data\tempstudents.file
)

set /a i=0
::create array of held students 
FOR /F "tokens=1,2,3,4 delims=," %%A IN (data\students.csv) DO (
	SET sCode[!i!]=%%A 
	SET sfName[!i!]=%%B
	SET slName[!i!]=%%C
	SET sfDate[!i!]=%%D
	set /a i=!i!+1
)
set /a TotalStudents=!i!-1

set /a i=0
FOR /F "tokens=1,2,3,4 delims=," %%A IN (data\tempstudents.file) DO (
	SET CsCode[!i!]=%%A 
	SET CsfName[!i!]=%%B
	SET CslName[!i!]=%%C
	SET CsfDate[!i!]=%%D
	set /a i=!i!+1
)
set /a CTotalStudents=!i!-1

set /a i=0
set /a j=0
set /a DuplicateCodes=0
::each loop open a student from the copy file
FOR /L %%i in (0,1,%CTotalStudents%) do (
	set /a dupboo=0
	::each loop opens a student from the original
	FOR /L %%j in (0,1,%TotalStudents%) do (
		IF /I "!CsCode[%%i]!" EQU "!sCode[%%j]!" (
			set /a dupboo=1 
		)
	)
	IF /I "!dupboo!" EQU "0" (
		for /f "tokens=* delims= " %%a in ("!CsCode[%%i]!") do set input=%%a
		for /l %%a in (1,1,100) do if "!input:~-1!"==" " set input=!input:~0,-1!
		set outp=!input!,!CsfName[%%i]!,!CslName[%%i]!,!CsfDate[%%i]!
		echo Found Student !CsfName[%%i]!,!CslName[%%i]!
		echo !outp!>>data\students.csv
	)
)


del /s data\tempstudents.file
if exist data\desktop.ini (
   del /s data\desktop.ini
)



