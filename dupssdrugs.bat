::RemoveDups
::a utlitty for removing accidental duplicate ScannedDrugs and barcodes enmasse
::writen 12.3.2018 by N.Best
::1.0

@echo off
setlocal enabledelayedexpansion enableextensions
::add to admin log
set TechName=%1
echo dupssdrugs:LOGIN, %TechName%, %date%, %time%>>log\ADMINLOG.txt

:MAINMENU
cls
echo --- Duplicate Utility ---
type txt\dupmenu.txt
SET /P ScanerIO=Select an option and press enter:
::create report of duplicated items in scanneddrugs.csv
IF "%ScanerIO%"=="1" (
	cls
	echo dupssdrugs:DUPLICATE REPORT, %TechName%, %date%, %time%>>log\ADMINLOG.txt
	GOTO DUPREPORT
)
::will remove the duplicates
IF "%ScanerIO%"=="2" (
	cls
	echo dupssdrugs:REMOVE DUPS SELECTED, %TechName%, %date%, %time%>>log\ADMINLOG.txt
	GOTO REMOVEDUPS
)
GOTO CLOSEPROG
:DUPREPORT
echo Generating report... 
echo This can take between 10 seconds or 5 minutes depending on how many error there are...
::=========================================================
::------load all drugs and supplys from ScannedDrugs file
set /a i=0
FOR /F "tokens=1,2 delims=," %%A IN (data\ScannedDrugs.csv) DO (
	SET MedicationName[!i!]=%%A 
	SET MedCode[!i!]=%%B
	set /a i=!i!+1
)
set /a TotalSupplies=!i!-1
::add report header
type txt\dupreportheader.txt>log\Duplicate-report.txt 
echo %TechName% %TIME% %DATE%>>log\Duplicate-report.txt 
echo: >>log\Duplicate-report.txt 

set /a i=0
set /a j=0
set /a DuplicateCodes=0 
::search though all items and compare to all other items
::if they have mathcing barcode add tot he report, both item will be added the have the matching code
::also tally the number of duplicates
FOR /L %%i in (0,1,%TotalSupplies%) do (
	FOR /L %%j in (0,1,%TotalSupplies%) do (
		IF /I "%%i" NEQ "%%j" (
			IF /I "!MedCode[%%i]!" EQU "!MedCode[%%j]!" (
				echo !MedicationName[%%j]! - !MedCode[%%j]! >>log\Duplicate-report.txt 
				set /a DuplicateCodes=!DuplicateCodes!+1 
			)
		)
	)
)
echo !DuplicateCodes! duplicates found.
::open it in notepad for inspection
call notepad log\Duplicate-report.txt
GOTO MAINMENU

::--------------------removal of all duplicate barcodes from scanned drugs
:REMOVEDUPS
:: ask 3 times if this is what they want to do
SET /P input=Did you print a duplicate report(y/n)?
IF "%input%"=="n" (
	echo Process halted.
	timeout 2
	GOTO MAINMENU
)
SET /P input=Have ALL items listed been removed from the cart for inspection(y/n)?
IF "%input%"=="n" (
	echo Process halted.
	timeout 2
	GOTO MAINMENU
)
echo THIS IS AN IRREVERSIBLE OPERATION.
SET /P input=ARE YOU SURE???(y/n)
IF "%input%"=="n" (
	echo Process halted.
	timeout 2
	GOTO MAINMENU
)
echo dupssdrugs:DUPLICATES REMOVED, %TechName%, %date%, %time%>>log\ADMINLOG.txt
cls
set /a i=0
FOR /F "tokens=1,2 delims=," %%A IN (data\ScannedDrugs.csv) DO (
	SET MedicationName[!i!]=%%A 
	SET MedCode[!i!]=%%B
	set /a i=!i!+1
)
set /a TotalSupplies=!i!-1
type data\ScannedDrugs.csv>data\ScannedDrugs.bak
del data\ScannedDrugs.csv

echo Deleteing all duplicate items from the 'ScannedDrugs' File...
set /a i=0
set /a j=0
set /a DuplicateCodes=0
FOR /L %%i in (0,1,%TotalSupplies%) do (
	set /a dupboo=0
	FOR /L %%j in (0,1,%TotalSupplies%) do (
		IF /I "%%i" NEQ "%%j" (
			IF /I "!MedCode[%%i]!" EQU "!MedCode[%%j]!" (
				set /a dupboo=1 
				set /a DuplicateCodes=!DuplicateCodes!+1 
				echo removing...
			)
		)
	)
	IF /I "!dupboo!" EQU "0" (
		for /f "tokens=* delims= " %%a in ("!MedicationName[%%i]!") do set input=%%a
		for /l %%a in (1,1,100) do if "!input:~-1!"==" " set input=!input:~0,-1!
		set outp=!input!,!MedCode[%%i]!
		echo !outp!>>data\ScannedDrugs.csv
	)
)
echo !DuplicateCodes! duplicates found, and removed, exiting utility
timeout 4

:CLOSEPROG
endlocal
