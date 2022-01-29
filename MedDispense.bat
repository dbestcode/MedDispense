::MEDS Medication Education Dispensing System
::writen 3.12.2018 by Nicholai Best at PA College of Health Sciences
::website:  pacollege.edu
::email:nicholai.best@gmail.com

::============================================================================================
::MEDS Medication Education Dispensing System LICENSE AGREEMENT

::IMPORTANT-READ CAREFULLY: This End-User License Agreement ("EULA") is a legal agreement between you (either an individual or a single entity) and its AUTHOR .
::SOFTWARE(s) identified above, which includes the User's Guide, any associated SOFTWARE components,
::any media, any printed materials other than the User's Guide, and any "online" or electronic documentation ("SOFTWARE"). 
::By installing, copying, or otherwise using the SOFTWARE, you agree to be bound by the terms of this EULA. If you do not agree to the terms of this EULA,
::do not install or use the SOFTWARE.

::1. SHAREWARE

::You may use the SOFTWARE without charge. We may place announcement of other products into SOFTWARE. 
::AUTHOR will not monitor the content of your use (e.g., sites selected or files used).

::2. DISTRIBUTION OF SOFTWARE

::You may make copies of the SOFTWARE as you wish; give exact copies of the original SOFTWARE to anyone;
:: and distribute the SOFTWARE in its unmodified form via electronic means.
:: You may not charge any fees for the copy or use of the SOFTWARE itself.
:: You must not represent in any way that you are selling the SOFTWARE itself. 
::Your distribution of the SOFTWARE will not entitle you to any compensation from AUTHOR.
::You must distribute a copy of this EULA with any copy of the SOFTWARE and anyone to whom you distribute the SOFTWARE is subject to this EULA.

::3. RESTRICTIONS

::3.1 You may not reverse engineer, de-compile, or disassemble the SOFTWARE.
::3.2 You may not rent, lease, or lend the SOFTWARE.
::3.3 You may permanently transfer all of your rights under this EULA, provided the recipient agrees to the terms of this EULA.
::3.4 You may not use the SOFTWARE to perform any unauthorized transfer of information or for any illegal purpose.

::4. NO WARRANTIES

::AUTHOR expressly disclaims any warranty for the SOFTWARE. 
::THE SOFTWARE AND ANY RELATED DOCUMENTATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, 
::INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OR MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NONINFRINGEMENT. 
::THE ENTIRE RISK ARISING OUT OF USE OR PERFORMANCE OF THE SOFTWARE REMAINS WITH YOU.
::====================================================================================================================================

::Last worked date:		10/08/2021
set SoftVer=1.5.2
::a med record number is scanned and the corisponding MAR is opened
::a log file(\students\%UserLog%) contains user, and patients opened
::a master record of everthing dispense for student and patients is made in data/dispense.csv
::meds scanned will be added to a student log and a master log(\data\usedsupplies.csv) to record supplies used
::----Dev Log--
::csv file for student 10-9-18
::checking for inapropriate scanning times 10-16
::student id login
::ADMIN	utility live and student barcode badge logins 12-6
::4-2-19 changed beta to match or be improved on working version
::10-08-21 removed timeouts to speedup scrpit for interaction times






::=================================================================================================================
::-----warn user of eula
@echo off
echo By installing, copying, or otherwise using this SOFTWARE,
echo you agree to be bound by the terms of the EULA provided with it. 
echo If you do not agree to the terms of the EULA,
echo do not install or use this SOFTWARE.

timeout 10
title Medication Education Dispensing System
color f1
setlocal enabledelayedexpansion enableextensions

:LOADCSVS
::------load drugs/supplies, patients from 2 csv files
set /a i=0
FOR /F "tokens=1,2 delims=," %%A IN (data\drugs.csv) DO (
	SET MedicationName[!i!]=%%A 
	SET MedCode[!i!]=%%B
	set /a i=!i!+1
)

set /a TotalSupplies=!i!-1
::--Load patients
set /a i=0
FOR /F "tokens=1,2,3,4 delims=," %%A IN (data\patients.csv) DO (
	SET pln=%%A 
	SET pfn=%%B
	SET PatientName[!i!]=!pfn!-!pln!
	SET PatientCode[!i!]=%%C
	SET PatientPDF[!i!]=%%D
	set /a i=!i!+1
)
set /a TotalPatients=!i!-1
::--------------reload student file
set /a i=0
FOR /F "tokens=1,2,3 delims=," %%A IN (data\students.csv) DO (
	SET StudentCode[!i!]=%%A
	SET fName[!i!]=%%B
	SET lName[!i!]=%%C
	set /a i=!i!+1
)

IF "!COMPUTERNAME!" == "MEDDISPENSE" (
	set useraction=Dispensed
) ELSE (
	set useraction=Administered
)
		

::==============================================================================================================
::-----prompt for student name
:USERN
cls
type txt\logo.txt
echo:
echo %SoftVer%
type txt\login.txt
echo:
SET /P ScanerIO=Scan your badge:


::----- Check for System Administration -----------
FOR /F "tokens=1 delims=" %%A IN (data\xxx.txt) DO (
	IF %%A==%ScanerIO% (
		cls
		call AdministrationHelper.bat
		cls
		GOTO USERN
	)
)

::Vaildate that this is a ID barcode starting in "MedID"
::IF NOT VALID, DISPLAY INFO SCANNED IF DRUG OR PATIENT
ECHO.%ScanerIO%| FIND /I "MedID">Nul && ( 
  GOTO CHKSTUDENT
) || (
  ECHO.This is not a valid ID Barcode
  ::----------IF A DRUG IS SCANNED DISPLAY INFO AND RETURN TO LOGIN SCREEN
FOR /L %%i in (0,1,!TotalSupplies!) do (
	echo !MedCode[%%i]!>nul
	IF %ScanerIO%==!MedCode[%%i]! (
		cls
		echo:
		type txt\error.txt
		echo:
		echo Scaned: !MedicationName[%%i]!
		echo:
		echo but you cannot scan drugs till you login.
		timeout 1 >nul
		echo Please scan your ID badge.
		timeout 2 >nul
		echo If you need help ask the pharmacy.
		timeout 5 >nul
		goto USERN
	)	
)

::----------IF PATIENT IS SCANNED DISPLAY INFO AND RETURN TO LOGIN SCREEN
set /a i=0
FOR /L %%i in (0,1,!TotalPatients!) do (
	IF %ScanerIO%==!PatientCode[%%i]! (
		cls
		echo:
		type txt\error.txt
		echo:
		echo Scaned: !PatientName[%%i]!
		echo:
		echo But you need to login first.
		timeout 1 >nul
		echo Please scan your ID badge.
		timeout 2 >nul
		echo If you need help ask the pharmacy.
		timeout 5 >nul
		goto USERN
	)
)
)
:CHKSTUDENT
::------------check for current student
set /a TotalStudents=!i!-1
FOR /L %%i in (0,1,!TotalStudents!) do (
	IF %ScanerIO%==!StudentCode[%%i]! (
		SET NurseName=!fName[%%i]!-!lName[%%i]!
		SET UserLog=students\!NurseName!.log
		echo !NurseName!,LOGIN,%DATE%,%TIME%,%COMPUTERNAME%>>data\StudentLogin.csv
		goto SCANPATIENT
	)
)
IF "teacher"=="%ScanerIO%" (
	call View-Pulled-Meds.bat
	goto USERN
)
IF "3141592653589"=="%ScanerIO%" (
	echo Please scan your ID
	timeout 2
	goto USERN
)
IF "meds"=="%ScanerIO%" (
	call AddDrugs.bat
	cls
	GOTO USERN
)
IF "CANCE1"=="%ScanerIO%" (
	goto USERN
)
IF "C0NF1RM"=="%ScanerIO%" (
	goto USERN
)



::-------------------Unknown Valid badge found----------------------------
cls
echo Your badge has not been found in the system, 
echo We will register you now. It will only take a moment or two.
echo:
dialogboxes\InputBox.exe "Please enter your first name" "New User" >tmp
FOR /F "tokens=1 delims=" %%A IN (tmp) DO (SET fName=%%A)
dialogboxes\InputBox.exe "Please enter your last name" "New User" >tmp
FOR /F "tokens=1 delims=" %%A IN (tmp) DO (SET lName=%%A)
cls
echo First Name:%fName%
echo Last Name: %lName%
echo BarcodeID: %ScanerIO%
echo:
echo Scan accept to register.
echo    or
echo Scan cancel if you have mispelled.
SET /P yesno=:
IF "%yesno%"=="CANCE1" (
	cls
	echo Registration Canceled.
	timeout 2 >nul
	GOTO USERN
)


echo %ScanerIO%,%fName%,%lName%,%DATE%>>data\students.csv
cls
echo Welcome %fName%, You have been added to the system.
timeout 1 >nul
GOTO LOADCSVS
::------------------------SCAN PATIENT SCREEN--------------------------
:SCANPATIENT
cls
echo:
type txt\IDSCAN.txt
echo --- User:   %NurseName%
SET /P ScanerIO=:

IF "3141592653589"=="%ScanerIO%" (
	ECHO ERROR NOCODE
	goto SCANPATIENT
)
IF "C0NF1RM"=="%ScanerIO%" (
	ECHO ERROR NOCODE
	goto SCANPATIENT
)
IF "%ScanerIO%"=="cance1" (
	GOTO USERN
)
IF "%ScanerIO%"=="CANCE1" (
	GOTO USERN
)
::-----------Insulin order
IF "%ScanerIO%"=="i" (
	cls
	type txt\InsulinProtocol.txt
	timeout 30 
	GOTO SCANPATIENT
)

IF "%ScanerIO%"=="h" ( 
	cls
	type txt\EMRHELP.txt
	timeout 30 
	cls
	GOTO SCANPATIENT
)
FOR /L %%i in (0,1,!TotalPatients!) do (
	IF %ScanerIO%==!PatientCode[%%i]! (
		echo !PatientName[%%i]! found.
		for /f "tokens=* delims= " %%a in ("!PatientName[%%i]!") do set input=%%a
		for /l %%a in (1,1,100) do if "!input:~-1!"==" " set input=!input:~0,-1!
		set CurrentPatient=!input!
		SET patientfile=patients\!CurrentPatient!.txt
		SET PatientMAR=MAR\!PatientPDF[%%i]! 
		echo %NurseName%, opened !CurrentPatient!,%DATE%,%TIME%,%COMPUTERNAME%>>data\StudentLogin.csv 
		goto MEDSCAN
	)
)
::scan though csv file to find correct patient for barcode
FOR /L %%i in (0,1,!TotalStudents!) do (
	IF %ScanerIO%==!StudentCode[%%i]! (
		cls
		echo You are not a patient at this hospital.
		timeout 2
		goto SCANPATIENT
	)
)

echo Error:Barcode is not listed, try again.
timeout 2
GOTO SCANPATIENT


:EMARHELP
::Print help file and wait 30 secs
::-------------------------------------------------------------------------


:MEDSCAN
::===============================================================
::create new faculty view page
type html\head.html>html\FacultyView.html
type html\info.html>>html\FacultyView.html
echo ^<^/table^>^<section id="bottom"^>^<^/section^>>>html\FacultyView.html 

cls 

type txt\scanmed.txt
echo --- PATIENT: %CurrentPatient%
echo --- USER:   %NurseName%
::print last 10 items for this patient
IF EXIST %patientfile%. (
	set /a i=0
	FOR /F "tokens=*" %%A IN (%patientfile%) DO (
		if "!i!"=="10" goto :typeten
		echo %%A
		set /a i=!i!+1
	)
)
:typeten
SET /P ScanerIO=:

::-----------Close the patient
IF "%ScanerIO%"=="CANCE1" (
	cls
	GOTO LOADCSVS
)
FOR /L %%i in (0,1,!TotalPatients!) do (
	IF %ScanerIO%==!PatientCode[%%i]! (
		cls
		GOTO LOADCSVS
	)
)
IF "%ScanerIO%"=="c" (
	cls
	GOTO LOADCSVS
)
IF "%ScanerIO%"=="C0NF1RM" (
	cls
	GO MEDSCAN
)
::-----------------------------------missing barcode
IF "%ScanerIO%"=="314159265389" (
	cls
	GOTO MISSINGCODE
)
::-----------Insulin order
IF "%ScanerIO%"=="i" (
	cls
	type txt\InsulinProtocol.txt
	timeout 30 
	GOTO MEDSCAN
)
::---------------help file-----
IF "%ScanerIO%"=="h" ( 
	cls
	type txt\EMRHELP.txt
	timeout 30 
	GOTO MEDSCAN
)
::---------------show mar-----
IF "%ScanerIO%"=="m" ( 
	cls
	echo:
	more %PatientMAR%
	timeout 30 
	cls
	GOTO MEDSCAN
)
::---------------show terms-----
IF "%ScanerIO%"=="t" ( 
	cls
	echo:
	more txt\Terms.txt
	timeout 30 
	cls
	GOTO MEDSCAN
)
::search for the barcode in question 
FOR /L %%i in (0,1,!TotalStudents!) do (
	IF %ScanerIO%==!StudentCode[%%i]! (
		cls
		echo ID badges cannot be scaned at this screen, only medications and supplies.
		timeout 2
		goto MEDSCAN
	)
)
FOR /L %%i in (0,1,!TotalSupplies!) do (
	echo !MedCode[%%i]!>nul
	IF %ScanerIO%==!MedCode[%%i]! (
		cls
		
		type %patientfile%>tmp.txt
		echo !useraction! to %CurrentPatient%, !MedicationName[%%i]! at %TIME% %DATE% by %NurseName%>%patientfile%
		type tmp.txt>>%patientfile%
		
		::add med to master record of what has been used
		echo %ScanerIO%,!MedicationName[%%i]!,%DATE%,%TIME%,%CurrentPatient%,%NurseName%,%COMPUTERNAME%>>data\usedsupplies.csv 
		echo !useraction! !MedicationName[%%i]! to %CurrentPatient% Nurse:%NurseName%, on %DATE% at %TIME% from %COMPUTERNAME%>>data\FacultyView.txt
		echo   ^<tr^>>>html\new.html
		echo     ^<td^>%DATE% at %TIME% ^<^/td^>>>html\new.html
		echo     ^<td^>%CurrentPatient%^<^/td^>>>html\new.html
		echo     ^<td^>!MedicationName[%%i]!^<^/td^>>>html\new.html
		echo     ^<td^>%NurseName%^<^/td^>>>html\new.html
		echo     ^<td^>%COMPUTERNAME%^<^/td^>>>html\new.html
		echo   ^</tr^>>>html\new.html
		type html\info.html>>html\new.html
		type html\new.html>html\info.html
		echo: >html/new.html
		goto MEDSCAN
	)
)
::--------------drug code not found or student has scanned missing barcode--------------------
:MISSINGCODE
cls
type txt\pchs.txt
echo BARCODE NOT IN SYSTEM.
::getting missing info, log it to the student file 
::add the drug to the missing barcode sheet for later checking
dialogboxes\InputBox.exe "Name of the missing item?:" "Missing Barcode" >tmp
FOR /F "tokens=1 delims=" %%A IN (tmp) DO (SET missingdrug=%%A)
echo %missingdrug%
echo Scan 'ACCEPT' if this is correct
echo or
SET /P yesno=Scan 'CANCEL' to abort:
IF "!yesno!"=="CANCE1" (
	cls
	echo canceled....
	timeout 1 >nul
	GOTO MEDSCAN
)	
::log the item in 'missingscans' for later review, used supplies and faculty view
echo %missingdrug%,%ScanerIO%,%NurseName%>>log\missingScans.csv

echo %ScanerIO%,%missingdrug%,%DATE%,%TIME%,%CurrentPatient%,%NurseName%,%COMPUTERNAME%>>data\usedsupplies.csv 
echo !useraction! %missingdrug% to %CurrentPatient% Nurse:%NurseName%, on %DATE% at %TIME%>>data\FacultyView.rtf
		echo   ^<tr^>>>html\new.html
		echo     ^<td^>%DATE% at %TIME% ^<^/td^>>>html\new.html
		echo     ^<td^>%CurrentPatient%^<^/td^>>>html\new.html
		echo     ^<td^>!missingdrug!^<^/td^>>>html\new.html
		echo     ^<td^>%NurseName%^<^/td^>>>html\new.html
		echo     ^<td^>%COMPUTERNAME%^<^/td^>>>html\new.html
		echo   ^</tr^>>>html\new.html
		type html\info.html>>html\new.html
		type html\new.html>html\info.html
		echo: >html/new.html

::add to student log
type %patientfile%>tmp.txt
echo !useraction! to %CurrentPatient%, !MedicationName[%%i]! at %TIME% %DATE% by %NurseName%>%patientfile%
type tmp.txt>>%patientfile%
::echo !useraction!	!ScanerIO!		%TIME%	%DATE%,		Nurse:%NurseName%>>%PatientFile%


GOTO MEDSCAN
::--------------------------------------------------------------
:CLOSEEMR
