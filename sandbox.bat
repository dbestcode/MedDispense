::SET fileloc=file1
::FOR /F "tokens=*" %%A in ('dialogboxes\OpenFileBox.exe') do SET fileloc=%%A
::type %fileloc%



ECHO Patient file closing...
timeout 2 >nul
ECHO Saving Data...
timeout 2 >nul
ECHO Logging out... please wait...
timeout 3 >nul
