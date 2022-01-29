::MedAdd
::a utlitty for enrolling students
::writen 11.29.2018 by N.Best
::1.0

@echo off
setlocal enabledelayedexpansion enableextensions

set TechName=%1
echo AddStudents:Login, %TechName%, %date%, %time%>>log\ADMINLOG.txt
set /a numstuadded=0
:LOADSTDNTS
color 1f
cls
::------load all drugs and supplys from csv file
set /a i=0
FOR /F "tokens=1,2,3 delims=," %%A IN (data\students.csv) DO (
	SET StudentCode[!i!]=%%A
	SET fName[!i!]=%%B
	SET lName[!i!]=%%C
	set /a i=!i!+1
)
set /a TotalStudents=!i!-1


::----print logo and tell how many drugs in sheet
::cls 
echo -----	Signup New Students  	-----
type txt\logo.txt
echo %TotalStudents% - Students Enrolled.


:: scan screen======
timeout 1 >nul
cls
type txt\logo.txt
echo You will need a barcode on you badge to start,
SET /P ScanerIO=Please scan your badge barcode...
::exit if
IF "%ScanerIO%"=="C0NF1RM" (
	echo You can use that as a login...
	timeout 2
	goto LOADSTDNTS
)
IF "%ScanerIO%"=="CANCE1" (
	GOTO CLOSEEMR
)
IF "%ScanerIO%"=="3141592653589" (
	echo You can use that as a login...
	timeout 2
	goto LOADSTDNTS 
)
IF "%ScanerIO%"=="x" (
	GOTO CLOSEEMR
)



FOR /L %%i in (0,1,!TotalStudents!) do (
	IF %ScanerIO%==!StudentCode[%%i]! (
		cls
		color b0
		echo Thanks !fName[%%i]!, but you are already signed up^!
		timeout 1 >nul
		type txt\thumbsup.txt
		timeout 3 >nul
		color f0
		goto LOADSTDNTS
	)
)
SET /p fName=Type your first name, then press enter:
SET /p lName=Type your last name, then press enter:
cls
echo Your full name is %fName% %lName% and ID is %ScanerIO%.
SET /P yesno=Scan 'ACCEPT' or 'CANCEL'
IF "%yesno%"=="CANCE1" (
	GOTO LOADSTDNTS
)
set /a numstuadded=!numstuadded!+1
echo %ScanerIO%,%fName%,%lName%,%DATE%>>data\students.csv

endlocal

GOTO LOADSTDNTS
::--------------------------------------------------------------


:CLOSEEMR
echo AddStudents:ADDED !numstuadded! STUDENTS, %TechName%, %date%, %time%>>log\ADMINLOG.txt
