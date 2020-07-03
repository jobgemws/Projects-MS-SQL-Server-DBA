robocopy \\SourceServer\Share \\DestinationServer\Share /MIR /FFT /Z /XA:H /W:5
if %ERRORLEVEL% EQU 1 sc stop myservice & sc start myservice