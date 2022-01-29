::MedAdd
::a utlitty for adding drugs and barcodes enmasse
::writen 4.13.2018 by N.Best
::1.0

@echo off
::SET /P ScanerIO=Password:
::exit if
::IF "%ScanerIO%"=="$imlab" (
	::goto STRTPRG
::) else (
	::goto UNAUTH
::)
:STRTPRG
set TechName=%1
echo AddDrugs:Login, %TechName%, %date%, %time%>>log\ADMINLOG.txt
type data\drugs.csv>data\drugs.tmp


setlocal enabledelayedexpansion enableextensions
color f0
set currentdrug=0

::=========================================================
:MEDSCAN
cls
echo --- Welcome to Medication Add and Edit ---
type txt\manualadd.txt
echo:
echo Note: 	Do not run while anyone is using system.
echo		You will be prompted to save when you are finished.
echo 	This program DOES NOT SAVE until you close out properly.
echo:
setlocal EnableDelayedExpansion
::------load all drugs and supplys from csv file
set /a i=0
FOR /F "tokens=1,2 delims=," %%A IN (data\drugs.tmp) DO (
	SET MedicationName[!i!]=%%A 
	SET MedCode[!i!]=%%B
	::echo Loading %%A, %%B
	set /a i=!i!+1
)
set /a TotalSupplies=!i!-1


::----print logo and tell how many drugs in sheet

::type txt\logo.txt
echo %TotalSupplies% - Items Loaded.


:: scan screen======
SET /P ScanerIO=Scan a medication barcode(Scan 'CANCEL' to close and save):
::exit if
IF "%ScanerIO%"=="CANCE1" (
	GOTO CLOSEEMR
)



FOR /L %%i in (0,1,!TotalSupplies!) do (
	echo !MedCode[%%i]!>nul
	IF %ScanerIO%==!MedCode[%%i]! (
		set currentdrug=%%i
		goto DRUGFOUND
	)
)

cls
echo New Barcode Detected!
SET /p missingdrug=What is the name of the drug or supply?:
echo The drug is %missingdrug% Barcode:%ScanerIO%
SET /P yesno=Scan 'ACCEPT' to save, 'CANCEL' to cancel.
IF "%yesno%"=="CANCE1" (
	cls
	echo Canceled...
	timeout 2
	GOTO MEDSCAN
)
echo %missingdrug%,%ScanerIO%>>data\drugs.tmp


echo AddDrugs:ADDED ITEM:%ScanerIO%,%missingdrug%, %TechName%, %date%, %time%>>log\ADMINLOG.txt
echo %ScanerIO%,%missingdrug%,%DATE%,%TechName%>>log\addedinv.csv

endlocal

GOTO MEDSCAN
::--------------------------------------------------------------
:DRUGFOUND
cls
type txt\thumbsup.txt
echo !MedicationName[%currentdrug%]! is present in system already.
echo:
echo Do you want to change it?
SET /P yesno=Scan 'ACCEPT' to edit, 'CANCEL' to cancel:
IF "%yesno%"=="C0NF1RM" (
	GOTO MEDEDIT
)
goto MEDSCAN

::--------------------------------------------------------------
:MEDEDIT
cls
SET /p missingdrug=What would you like to change to?:
echo !MedicationName[%currentdrug%]! will be change to %missingdrug%
SET /P yesno=Scan 'ACCEPT' to save, 'CANCEL' to cancel:
IF "%yesno%"=="CANCE1" (
	GOTO MEDSCAN
)
::clear drugs.tmp and then add the library -minus the old drug and add the new one to the end of the file
echo Writing changes, wait a moment...
type NUL > data\drugs.tmp
set /A beforeedit = %currentdrug%-1
set /A afteredit = %currentdrug%+1
FOR /L %%i in (0,1,!beforeedit!) do (
	set input=!MedicationName[%%i]!
	for /f "tokens=* delims= " %%a in ("%input%") do set input=%%a
	for /l %%a in (1,1,100) do if "!input:~-1!"==" " set input=!input:~0,-1!
	echo !input!,!MedCode[%%i]!>>data\drugs.tmp
)
FOR /L %%i in (!afteredit!,1,!TotalSupplies!) do (
	set input=!MedicationName[%%i]!
	for /f "tokens=* delims= " %%a in ("!input!") do set input=%%a
	for /l %%a in (1,1,100) do if "!input:~-1!"==" " set input=!input:~0,-1!
	echo !input!,!MedCode[%%i]!>>data\drugs.tmp
)

echo %missingdrug%,!MedCode[%currentdrug%]!>>data\drugs.tmp

GOTO MEDSCAN
::--------------------------------------------------------------

:CLOSEEMR
color fc
cls
echo Would you like to save your work? 
echo If you cancel all work will be lost.
echo:
SET /P yesno=Scan 'ACCEPT' to save, 'CANCEL' to cancel:
IF "%yesno%"=="C0NF1RM" (
	type data\drugs.csv>data\drugs.bak
	type data\drugs.tmp>data\drugs.csv
)
del data\drugs.tmp

color f1
:UNAUTH
::--------------------------------------------------------------

