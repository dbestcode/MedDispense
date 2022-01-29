@ECHO OFF
:loop
  cls
  type data\FacultyView.txt
  echo:
  echo Will refresh every 30 seconds, or press any key to refresh now.
  timeout /t 30 >nul
goto loop
