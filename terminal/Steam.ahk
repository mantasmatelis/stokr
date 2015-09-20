IfWinNotExist, Steam Login
{
        Process, Close, Steam.exe
        Run, C:\Program Files (x86)\Steam\Steam.exe
}
 
WinWait, Steam Login
 
FileRead, SUser, user.txt
FileRead, SPass, pass.txt
 
WinActivate
Click, 163, 98
Send, ^a{Backspace}
Send, %SUser%
Click, 173, 133
Send, ^a{Backspace}
Send, %SPass%
Click, 173, 193

