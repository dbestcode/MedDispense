::MedAdd
::a utlitty for adding drugs and barcodes enmasse
::writen 4.13.2018 by N.Best
::1.0

@echo off
setlocal enabledelayedexpansion enableextensions
set TechName=%1
echo AddPatients:Login, %TechName%, %date%, %time%>>log\ADMINLOG.txt

echo --- Welcome to Patient add ---
echo:


echo Login:%TechName% %DATE% @ %TIME%

cls
goto MEDSCAN


:MEDSCAN
::=========================================================
setlocal EnableDelayedExpansion
::------load all drugs and supplys from csv file
set /a i=0
FOR /F "tokens=1,2,3,4 delims=," %%A IN (data\patients.csv) DO (
	SET PatLName[!i!]=%%A 
	SET PatFName[!i!]=%%B
	SET PatCode[!i!]=%%C
	SET PatFile[!i!]=%%C
	set /a i=!i!+1
)
set /a TotalPatients=!i!-1


::----print logo and tell how many drugs in sheet
cls 
type txt\logo.txt
echo %TotalPatients% - Items Loaded.


:: scan screen======
echo Barcode number will be the patient MRN.
SET /P ScanerIO=Scan a Patient Barcode(Press 'x' to Exit):
::exit if
IF "%ScanerIO%"=="x" (
	GOTO CLOSEEMR
)



FOR /L %%i in (0,1,!TotalSupplies!) do (
	echo !PatCode[%%i]!>nul
	IF %ScanerIO%==!PatCode[%%i]! (
		cls
		echo !PatFName[%%i]! !PatLName[%%i]! is present in system already.
		echo AddPatients:PT:!PatLName[%%i]! EXSITS, %TechName%, %date%, %time%>>log\ADMINLOG.txt
		timeout 5 
		goto MEDSCAN
	)
)


echo:
SET /p PatfName=What is the first name of the patient?:
echo:
SET /p PatlName=What is the last name of the patient? :
CLS
echo The patients full name is %PatfName% %PatlName% and MRN is %ScanerIO%.
SET /P yesno=Press 'n' to cancel, 'y' to save new patient:

IF "%yesno%"=="n" (
	echo AddPatients:DIDNT ADDED PT:%PatlName%, %PatfName%, %TechName%, %date%, %time%>>log\ADMINLOG.txt
	GOTO MEDSCAN
)
echo AddPatients:ADDED PT:%PatlName%, %PatfName%, %TechName%, %date%, %time%>>log\ADMINLOG.txt
echo %PatlName%,%PatfName%,%ScanerIO%,%PatlName%-%PatfName%-MAR.txt>>data\patients.csv

cls
echo %PatfName% %PatlName%, MRN: %ScanerIO%, Has been added to list of patients
timeout 5
GOTO MEDSCAN
::--------------------------------------------------------------


:CLOSEEMR
endlocal
