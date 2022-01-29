::Dioscorides administration help
::writen 11.xx.2018 by N.Best
::1.1
::last writen 11.28.18
::7.15.19
::----Dev Log--
::csv file for student 10-9
::checking for inapropriate scanning times 10-16
::simplified menu
::-----layout


:LOGIN

::cls
@echo off
title PACHS MedDispense Admin Helper
setlocal enabledelayedexpansion enableextensions


set /a i=0
FOR /F "tokens=1,2 delims=," %%A IN (data\drugs.csv) DO (
	set /a i=!i!+1
)
set /a TotalDrugs=!i!-1
::-added to same array
set /a i=0
FOR /F "tokens=1,2 delims=," %%A IN (data\ScannedDrugs.csv) DO (
	set /a i=!i!+1
)
set /a TotalSDrugs=!i!-1
::------------------------
set /a i=0
FOR /F "tokens=1,2,3,4 delims=," %%A IN (data\patients.csv) DO (
	set /a i=!i!+1
)
set /a TotalPatients=!i!-1
::------load all Students csv file
set /a i=0
FOR /F "tokens=1,2,3 delims=," %%A IN (data\students.csv) DO (
	set /a i=!i!+1
)
set /a TotalStudents=!i!-1	
::------Display inital screen
::-----no login, acces should ony be though the main med admin screen
::color 0c
::echo DO NOT MISS SPELL
::SET /P ScanerIO=Scan a your badge barcode(Press 'x' to Exit):
::set /a i=0
::FOR /F "tokens=1 delims=" %%A IN (data\xxx.txt) DO (
	::IF %%A==%ScanerIO% (
		::color 0f
		
		::echo Creating Backups... 
		::timeout 1
		type data\drugs.csv>data\drugs.bak
		type data\ScannedDrugs.csv>data\ScannedDrugs.bak
		type data\patients.csv>data\patients.bak
		type data\students.csv>data\students.bak
		goto USERN
		
	::)
::)

::cls
::color 0c
::echo:
::type txt\logo.txt
::timeout 1 >nul
::color 0f
::echo --- PACHS MedDispense Admin ---
::echo:
::timeout 1 >nul
::color 0c
::echo -----AUTHORIZED USERS ONLY-----
::timeout 1 >nul
::color 0f
::timeout 1 >nul
::color 0c

::timeout 1 >nul
::color 0f
::timeout 1 >nul
::exit
::shutdown.exe /s /t 00

::===========================================================================
:USERN
SET TechName=%1
::IF %TechName% == [] (
	::echo You must give a name to use this program.
	::timeout 4 >nul 
	::exit
::)
echo AdministrationHelper:Login, %TechName%, %date%, %time%>>log\ADMINLOG.txt
:MAINMENU
cls
echo:
type txt\adminmenu.txt
echo %TotalStudents% - Students Loaded.
echo %TotalPatients% - Patients Loaded.
echo %TotalDrugs% - Items Loaded.
SET /P ScanerIO=Select an option and press enter:

IF "%ScanerIO%"=="1" (
	cls
	call AddDrugs.bat %TechName%
	cls
	GOTO MAINMENU
)
IF "%ScanerIO%"=="9999" (
	cls
	call dupssdrugs.bat %TechName%
	cls
	GOTO MAINMENU
)
IF "%ScanerIO%"=="2" (

	echo AdministrationHelper:EDITING MASTER 'DRUGS.CSV', %TechName%, %date%, %time%>>log\ADMINLOG.txt
	cls
	type txt\csveditinstructions.txt
	call notepad data\drugs.csv
	GOTO MAINMENU
)
IF "%ScanerIO%"=="9999" (
	echo AdministrationHelper:EDITING 'ScannedDrugs.csv', %TechName%, %date%, %time%>>log\ADMINLOG.txt
	cls
	type txt\csveditinstructions.txt

	call notepad data\ScannedDrugs.csv
	cls
	GOTO MAINMENU
)
IF "%ScanerIO%"=="9999" (
	echo AdministrationHelper:ATTEMPTING TO COMBINE FILES, %TechName%, %date%, %time%>>log\ADMINLOG.txt
	cls
	echo ---ARE YOU SURE YOU WANT TO COMBINE THE FILES?---
	echo %TotalSDrugs% - Scanned Items Loaded.
	echo %TotalDrugs% - Items Loaded.
	echo This will add *STUDENT* entered information into the system.
	timeout 3 >nul
	echo Have you already reviewed the 'scanned medications file for errors?
	SET /P yesno=Enter 'y' then press enter to continue, ...
	IF "!yesno!"=="y" (
		echo AdministrationHelper:COMBINED SCANED MEDS, %TechName%, %date%, %time%>>log\ADMINLOG.txt
		type data\ScannedDrugs.csv>>data\drugs.csv
		echo: >data\ScannedDrugs.csv
		set /a i=0
		FOR /F "tokens=1,2 delims=," %%A IN (data\drugs.csv) DO (
			set /a i=!i!+1
		)
		set /a TotalDrugs=!i!-1
		::-added to same array
		set /a i=0
		FOR /F "tokens=1,2 delims=," %%A IN (data\ScannedDrugs.csv) DO (
			set /a i=!i!+1
		)
		set /a TotalSDrugs=!i!-1
		GOTO MAINMENU
	)
	cls
	echo Operation canceled, please review the student and staff entered information.
	timeout 4 >nul
	GOTO MAINMENU
)
IF "%ScanerIO%"=="3" (
	cls
	call AddPatients.bat %TechName%
	cls
	GOTO MAINMENU
)
IF "%ScanerIO%"=="4" (
	echo AdministrationHelper:EDITING PATIENTS, %TechName%, %date%, %time%>>log\ADMINLOG.txt
	cls
	type txt\csveditinstructions.txt
	call notepad data\patients.csv
	cls
	GOTO MAINMENU
)
IF "%ScanerIO%"=="5" (
	echo AdministrationHelper:HELP, %TechName%, %date%, %time%>>log\ADMINLOG.txt
	cls
	echo ---also add instructions---
	TIMEOUT 3 >NUL
	cls
	GOTO MAINMENU
)
IF "%ScanerIO%"=="6" (
	echo AdministrationHelper:EDITING 'MissingScans.csv', %TechName%, %date%, %time%>>log\ADMINLOG.txt
	cls
	echo This file is only a log, the items listed were entered manually by a user.
	echo Verify it was user error, and remove the lines and save the file or make a new drug for the requested item.
	timeout 3 >nul
	call notepad log\missingScans.csv & call AddDrugs.bat %TechName%
	GOTO MAINMENU
)
IF "%ScanerIO%"=="e" (
	cls
	call AddStudent.bat
	cls
	GOTO MAINMENU
)
::IF "%ScanerIO%"=="p" (
	::cls
	::SET /P newpass=new password:
	::SET /P againnewpass=again to confirm:
	
	::IF %newpass% == %againnewpass% (
		::echo %newpass%>data\xxx.txt
		::echo Password is now %newpass%
		::timeout 3 >NUL
		::GOTO MAINMENU
	::) 	
	::echo Those do not match, try again.
	::timeout 2 >nul
	::GOTO MAINMENU
::)
IF "%ScanerIO%"=="CANCE1" (
	echo LOGOUT------------------------------------------------------------------------------>>log\ADMINLOG.txt
	GOTO CLOSEPROG
)
GOTO MAINMENU
:CLOSEPROG

