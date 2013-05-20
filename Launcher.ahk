/*
####################################################################################################
####################################################################################################
######                                                                                        ######
######                                 TM2 Dedicated Launcher                                 ######
######                                                                                        ######
####################################################################################################
####################################################################################################


     AutoHotkey Version:    1.1.09.02
     Program Version:       0.9.79
     Language:              English_United_States
     Encoding:              Unicode
     Developed Using:       WIN_7(x64)
     Created On:            16/05/2013
     Author:                grayatrox
     Description:           Launch TM2 Dedicated, and keep XAseco2 running
     Notes:                 I have not extensively tested for bugs.

*/
; >> BEGIN AUTO-EXECUTE SECTION
    #NoEnv  ; Don't read Environment Variables (Recommended for performance and compatibility)
    SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
	pTitle := "TM2 Dedicated Launcher"

	/* Old Defaults - used as reference (you shouldn't need to uncomment anything)
	pUpdate := True
    sLocation := A_ScriptDir
    sConfig := "/title=TMStadium /game_settings=MatchSettings/FSTracks.txt /dedicated_cfg=dedicated_cfg.txt" 
    sTitle := sLocation . "\ManiaPlanetServer.exe" 
    phpLocation := "c:\xampp\php\php.exe"
    xLocation := sLocation . "\xaseco2"
     */

     if (!FileExist("settings.txt")) {
     	MsgBox, 17, %pTitle% - Error, Error: settings.txt not found.`nClick Ok to create settings.txt and restart the application.
     	IfMsgBox OK
     	{
     		setDefaults()
     		MsgBox, 68, %pTitle%, Would you like to open settings.txt in your default text editor?
     		IfMsgbox, Yes
     		Run, settings.txt
     	}
     	ExitApp
     }

	XmlDoc := loadXML(loadSettings("settings.txt"))

	sError := ""

	pUpdate := getSetting("pUpdate",XmlDoc)
	pUpdate := pUpdate == "True" || pUpdate == "1" ? 1 : 0

	sLocation := getSetting("sLocation",XmlDoc)
	if (!FileExist(sLocation . "ManiaPlanetServer.exe"))
		sError .= "Error: cannot find the server.`n"

	if (!sConfig := getSetting("sConfig",XmlDoc))
		sWarning .= "You have no configuration options to launch the Server with."
	
	sTitle := getSetting("sTitle",XmlDoc)  
	sTitle := !sTitle ? sLocation . "ManiaPlanetServer.exe" : sTitle

	if (!FileExist(phpLocation := getSetting("phpLocation",XmlDoc)))
		sError .= "Error: cannot find the php installation.`n"

	xLocation := getSetting("xLocation",XmlDoc)
	xLocation := !xLocation ? sLocation . "xaseco2\" : xLocation
	if (!FileExist(xLocation . "xaseco2.php"))
		sError .= "Error: cannot locate XAseco2.`n"

	if (sError) {
		MsgBox, 16,%pTitle% - Error,%sError%`nIs settings.txt properly configured?
		ExitApp
	}

	if (sWarning)
		Msgbox, 48, %pTitle% - Warning, %sWarning%, 60

    setupTray()
	
	If (pUpdate){
		Result := Check_ForUpdate()
		if (Result)
			MsgBox, 64, %pTitle%, %Result%, 60
	}
	
    /*  
        Check to see if the Dedicated is running. 
        If it is, we can go straight to launching XAseco2 
    */
    if(!WinExist(sTitle)) {
          
        Run, "%sLocation%\ManiaPlanetServer.exe" %sConfig%
         
        WinWait, %sTitle%
    }
    SetWorkingDir, %xLocation%
     
    /*
        Launch XAseco2 and keep it running until the 
        server window no longer exists
    */
    While(WinExist(sTitle)) { 
          
        /*
            Check to see if Mania Planet is running. 
            There is a bug that doesn't allow XAseco2 to
            connect to the server if the game is running.
               
             - This will be removed if/when the bug is fixed
        */  
        While (WinExist("ManiaPlanet")) { 
            Msgbox,17,%pTitle%, Please close ManiaPlanet
            IfMsgbox, Cancel
                ExitApp
        }
        RunWait, "%phpLocation%" "%xLocation%XAseco2.php"
    }     
     
    /*     
        Close the Program when the Dedicated and XAsceo2 are no longer running.
    */
    ExitApp 

	MenuHandler:
	{
		If (A_ThisMenu == "Tray") {
			If (A_ThisMenuItem == "Reload"){
				Reload
				Return
			} Else If (A_ThisMenuItem == "Exit"){
				ExitApp
				Return
			} Else
			If (A_ThisMenuItem == "Help"){
				SplitPath, A_AhkPath,, OutDir
				Run, %OutDir%\AutoHotkey.chm
				Return
			} Else
			If (A_ThisMenuItem == "Open"){
				ListLines
				Return
			} Else
			If (A_ThisMenuItem == "Suspend"){
				Menu, Tray, ToggleCheck, %A_ThisMenuItem%
				Suspend,Toggle
				Return
			} Else
			If (A_ThisMenuItem == "Pause"){
				Menu, Tray, ToggleCheck, %A_ThisMenuItem%
				Pause,Toggle
				Return
			} Else
			If (A_ThisMenuItem == "Edit"){
				Edit
				Return
			} Else
			If (A_ThisMenuItem == "Forum Topic"){
				Run, http://www.tm-forum.com/viewtopic.php?t=30560
				Return
			}
			
		}
		; (Else)
			Msgbox %A_ThisMenuItem% was selected from the menu %A_ThisMenu%.

		Return
		
	}
	getSetting(setting, ByRef xmlDoc) {

		if (setting == "pUpdate") {
			return % xmlDoc.selectSingleNode("/tm2dedicatedlauncher/settings/program/update").text
		} 
		if (setting == "sConfig") {
			return % xmlDoc.selectSingleNode("/tm2dedicatedlauncher/settings/server/config").text
		} 
		if (setting == "sTitle") {
			return % xmlDoc.selectSingleNode("/tm2dedicatedlauncher/settings/server/title").text
		} 
		if (setting == "phpLocation") {
			return % xmlDoc.selectSingleNode("/tm2dedicatedlauncher/settings/xaseco2/php").text
		} 
		if (setting == "xLocation") {
			return % xmlDoc.selectSingleNode("/tm2dedicatedlauncher/settings/xaseco2/path").text
		} 
		if (setting := "sLocation") {
			return % xmlDoc.selectSingleNode("/tm2dedicatedlauncher/settings/server/location").text
		} 
	}

	loadSettings(file) {
		doc := FileOpen(file,"r")
		data := doc.Read()
		doc.Close()
		data = %data% ; Why do I even need to do this?
		Return %data%
	}


	loadXML(ByRef data)
	{
	  o := ComObjCreate("MSXML2.DOMDocument.6.0")
	  o.async := false
	  o.loadXML(data)
	  return o
	}

  setDefaults() {
			xmldata =
(
  <?xml version="1.0"?>
    <tm2dedicatedlauncher>
      <settings>
        <server>
          <!-- The path to the directory where ManiaPlanetServer.exe is
               eg: <location>C:\ManiaPlanet Dedicated Server\TMStadium\</location> 
          -->
          <location></location> 
          <!-- The parameters to launch the server with 
                - this is what you would be putting after 
               eg: <config>/title=TMStadium /game_settings=MatchSettings/TMStadiumA.txt /dedicated_cfg=dedicated_cfg.txt</config>
          -->
          <config></config>
          <!-- Title of the server window
               Leave blank for default value (path to the Dedicated) 
               - Don't change unless you know what you are doing! 
          -->
          <title></title> 
        </server>
        <xaseco2>
          <!-- The path to php.exe
               eg: <php>C:\Program Files\php\php.exe</php>
          -->
          <php></php>            
          <!-- The path to XAseco2 directory
               - This can be left blank as long as there is a directory labeled as 
                  "xaseco2" along side the Dedicated executable 
                   eg: <path>xasceo2\</path>
          -->
          <path></path> 
        </xaseco2>
        <program>
          <!-- Check for updates
              - Defaults to false if empty
               True = 1
               False = 0
           -->
          <update>0</update> 
        </program>
      </settings>
    </tm2dedicatedlauncher>
)

		file := FileOpen("settings.txt", "w")
		if !IsObject(file)
		{
			MsgBox,16,%pTitle%,  Can't open "settings.txt" for writing.
			return
		}

		file.Write(xmldata)
		file.Close()
	return
	}

	MD5_File(FileName)
	{
		Ptr := A_PtrSize ? "Ptr" : "UInt"
		
		;Adapted from SKAN's MD5 functions - http://www.autohotkey.com/forum/topic64211.html
		H := DllCall("CreateFile",Ptr,&FileName,"UInt",0x80000000,"UInt",3,"UInt",0,"UInt",3,"UInt",0,"UInt",0)
		, DllCall("GetFileSizeEx","UInt",H,"Int64*",FileSize)
		, FileSize := FileSize = -1 ? 0 : FileSize
		, VarSetCapacity(Data,FileSize,0)
		, DllCall("ReadFile",Ptr,H,Ptr,&Data,"UInt",FileSize,"UInt",0,"UInt",0)
		, DllCall("CloseHandle",Ptr,H)
		, VarSetCapacity(MD5_CTX,104,0)
		, DllCall("advapi32\MD5Init",Ptr,&MD5_CTX)
		, DllCall("advapi32\MD5Update",Ptr,&MD5_CTX,Ptr,&Data,"UInt",FileSize)
		, DllCall("advapi32\MD5Final",Ptr,&MD5_CTX)

		FileMD5 := ""
		Loop % StrLen(Hex:="123456789ABCDEF0")
			N := NumGet(MD5_CTX,87+A_Index,"Char"), FileMD5 .= SubStr(Hex,N>>4,1) . SubStr(Hex,N&15,1)

		VarSetCapacity(Data,FileSize,0)
		, VarSetCapacity(Data,0)

		Return FileMD5
	}

	setupTray(){
		global
		Menu, Tray, NoStandard
		Menu, Tray, Add, %pTitle%, MenuHandler
		Menu, Tray, Disable, %pTitle%
		Menu, Tray, Add, Forum Topic, MenuHandler
		Menu, Tray, Add
		If (!A_isCompiled) {
			Menu, Tray, Add, Help, MenuHandler
			Menu, Tray, Add
		}
		Menu, Tray, Add, Suspend, MenuHandler
		Menu, Tray, Add, Pause, MenuHandler
		Menu, Tray, Add
		If (!A_isCompiled) {
			Menu, Tray, Add, Open, MenuHandler
			Menu, Tray, Add, Edit, MenuHandler
		}
		Menu, Tray, Add, Reload, MenuHandler
		Menu, Tray, Add, Exit, MenuHandler
	}
/* 
	Check_ForUpdate_()  by Rseding91 from http://www.autohotkey.com/board/topic/72559-func-self-script-updater/
	with modifications
*/
Check_ForUpdate(_ReplaceCurrentScript = 1, _SuppressMsgBox = 0, _CallbackFunction = "", ByRef _Information = "")
{
	;Version.ini file format - this is just an example of what the version.ini file would look like
	;
	;[Info]
	;Version=1.8
	;URL=http://www.mywebsite.com/my%20file.ahk or .exe
	;MD5=00000000000000000000000000000000 or omit this key completly to skip the MD5 file validation
	
	global mUpdate, pTitle

	Static Script_Name := pTitle ;Your script name
	, Version_Number := "0.9.79" ;The script's version number
	, Update_URL := "https://raw.github.com/grayatrox/TM2DedicatedLauncher/master/Version" ((A_IsCompiled)?(".exe"):(".ahk")) . ".ini" ;The URL of the version.ini file for your script
	, Retry_Count := 3 ;Retry count for if/when anything goes wrong
	
	Random,Filler,10000000,99999999
	Version_File := A_Temp . "\" . Filler . ".ini"
	, Temp_FileName := A_Temp . "\" . Filler . ".tmp"
	, VBS_FileName := A_Temp . "\" . Filler . ".vbs"
	

	Loop % Retry_Count
	{
		_Information := ""
		
		UrlDownloadToFile,%Update_URL%,%Version_File%
		IniRead,Version,%Version_File%,Info,Version,N/A
		
		If (Version = "N/A"){
			FileDelete,%Version_File%
			
			If (A_Index = Retry_Count)
				_Information .= "The version info file doesn't have a ""Version"" key in the ""Info"" section or the file can't be downloaded."
			Else
				Sleep,500
			
			Continue
		}

		RegExMatch(Version_Number, "O)(\d\d?)(?:\.(\d\d?))(?:\.(\d\d?))", lVersion) ; Local Version
		RegExMatch(Version, "O)(\d\d?)(?:\.(\d\d?))(?:\.(\d\d?))", rVersion) ; Remote version stored on server

		;msgbox %Version_Number% %Version%

		Update := False
		Loop % ((lVersion.Count() > rVersion.Count())?( lVersion.Count()):(rVersion.Count())) {
			If (lVersion.Value(A_index) < rVersion.Value(A_index)) {
				Update := True
				break
			} Else If (lVersion.Value(A_index) > rVersion.Value(A_Index)) {
				break
			}
		}
		
		If (Update){
			If (_SuppressMsgBox != 1 and _SuppressMsgBox != 3){
				MsgBox,0x4,%pTitle% - New version available,There is a new version of %Script_Name% available.`nCurrent version: %Version_Number%`nNew version: %Version%`n`nWould you like to download it now?
				
				IfMsgBox,Yes
					MsgBox_Result := 1
			}
			
			If (_SuppressMsgBox or MsgBox_Result){
				IniRead,URL,%Version_File%,Info,URL,N/A
				
				If (URL = "N/A")
					_Information .= "The version info file doesn't have a valid URL key."
				Else {
					SplitPath,URL,,,Extension
					
					If (Extension = "ahk" And A_AHKPath = "")
						_Information .= "The new version of the script is an .ahk filetype and you do not have AutoHotKey installed on this computer.`r`nReplacing the current script is not supported."
					Else If (Extension != "exe" And Extension != "ahk")
						_Information .= "The new file to download is not an .EXE or an .AHK file type. Replacing the current script is not supported."
					Else {
						IniRead,MD5,%Version_File%,Info,MD5,N/A
						
						Loop % Retry_Count
						{
							UrlDownloadToFile,%URL%,%Temp_FileName%
							
							IfExist,%Temp_FileName%
							{
								If (MD5 = "N/A"){
									_Information .= "The version info file doesn't have a valid MD5 key."
									, Success := True
									Break
								} Else {
									Ptr := A_PtrSize ? "Ptr" : "UInt"
									, H := DllCall("CreateFile",Ptr,&Temp_FileName,"UInt",0x80000000,"UInt",3,"UInt",0,"UInt",3,"UInt",0,"UInt",0)
									, DllCall("GetFileSizeEx",Ptr,H,"Int64*",FileSize)
									, FileSize := FileSize = -1 ? 0 : FileSize
									
									If (FileSize != 0){
										VarSetCapacity(Data,FileSize,0)
										, DllCall("ReadFile",Ptr,H,Ptr,&Data,"UInt",FileSize,"UInt",0,"UInt",0)
										, DllCall("CloseHandle",Ptr,H)
										, VarSetCapacity(MD5_CTX,104,0)
										, DllCall("advapi32\MD5Init",Ptr,&MD5_CTX)
										, DllCall("advapi32\MD5Update",Ptr,&MD5_CTX,Ptr,&Data,"UInt",FileSize)
										, DllCall("advapi32\MD5Final",Ptr,&MD5_CTX)
										
										FileMD5 := ""
										Loop % StrLen(Hex:="123456789ABCDEF0")
											N := NumGet(MD5_CTX,87+A_Index,"Char"), FileMD5 .= SubStr(Hex,N>>4,1) . SubStr(Hex,N&15,1)
										
										VarSetCapacity(Data,FileSize,0)
										, VarSetCapacity(Data,0)
										
										
										If (FileMD5 != MD5){
											FileDelete,%Temp_FileName%
											
											If (A_Index = Retry_Count) 
												_Information .= "The MD5 hash of the downloaded file does not match the MD5 hash in the version info file."
											Else										
												Sleep,500
											
											Continue
										} Else
											Success := True
									} Else {
										DllCall("CloseHandle",Ptr,H)
										Success := True
									}
								}
							} Else {
								If (A_Index = Retry_Count)
									_Information .= "Unable to download the latest version of the file from " . URL . "."
								Else
									Sleep,500
								Continue
							}
						}
					}
				}
			}
		} Else if (mUpdate)
			_Information .= "No update was found."
		
		FileDelete,%Version_File%
		Break
	}
	
	If (_ReplaceCurrentScript And Success){
		SplitPath,URL,,,Extension
		Process,Exist
		MyPID := ErrorLevel
		
		VBS_P1 =
		(LTrim Join`r`n
			On Error Resume Next
			Set objShell = CreateObject("WScript.Shell")
			objShell.Run "TaskKill /F /PID %MyPID%", 0, 1
			Set objFSO = CreateObject("Scripting.FileSystemObject")
		)
		
		If (A_IsCompiled){
			If (Extension = "exe"){
				VBS_P2 =
				(LTrim Join`r`n
					objFSO.CopyFile "%Temp_FileName%", "%A_ScriptFullPath%", True
					objFSO.DeleteFile "%Temp_FileName%", True
					objShell.Run """%A_ScriptFullPath%"""
				)
				
				Return_Val :=  Temp_FileName
			} Else { ;Extension is ahk
				SplitPath,A_ScriptFullPath,,FDirectory,,FName
				FileMove,%Temp_FileName%,%FDirectory%\%FName%.ahk,1
				FileDelete,%Temp_FileName%
				
				VBS_P2 =
				(LTrim Join`r`n
					objFSO.DeleteFile "%A_ScriptFullPath%", True
					objShell.Run """%FDirectory%\%FName%.ahk"""
				)
				
				Return_Val := FDirectory . "\" . FName . ".ahk"
			}
		} Else {
			If (Extension = "ahk"){
				FileMove,%Temp_FileName%,%A_ScriptFullPath%,1
				If (Errorlevel)
					_Information .= "Error (" . Errorlevel . ") unable to replace current script with the latest version."
				Else {
					VBS_P2 = 
					(LTrim Join`r`n
						objShell.Run """%A_ScriptFullPath%"""
					)
					
					Return_Val :=  A_ScriptFullPath
				}
			} Else If (Extension = "exe"){
				SplitPath,A_ScriptFullPath,,FDirectory,,FName
				FileMove,%Temp_FileName%,%FDirectory%\%FName%.exe,1
				FileDelete,%A_ScriptFullPath%
				
				VBS_P2 =
				(LTrim Join`r`n
					objShell.Run """%FDirectory%\%FName%.exe"""
				)
				
				Return_Val :=  FDirectory . "\" . FName . ".exe"
			} Else {
				FileDelete,%Temp_FileName%
				_Information .= "The downloaded file is not an .EXE or an .AHK file type. Replacing the current script is not supported."
			}
		}
		
		VBS_P3 =
		(LTrim Join`r`n
			objFSO.DeleteFile "%VBS_FileName%", True
			Set objFSO = Nothing
			Set objShell = Nothing
		)
		
		If (_SuppressMsgBox < 2)
			VBS_P3 .= "`r`nWScript.Echo ""Update complected successfully."""
		
		FileDelete,%VBS_FileName%
		FileAppend,%VBS_P1%`r`n%VBS_P2%`r`n%VBS_P3%,%VBS_FileName%
		
		If (_CallbackFunction != ""){
			If (IsFunc(_CallbackFunction))
				%_CallbackFunction%()
			Else
				_Information .= "The callback function is not a valid function name."
		}
		
		RunWait,%VBS_FileName%,%A_Temp%,VBS_PID
		Sleep,2000
		
		Process,Close,%VBS_PID%
		_Information := "Error (?) unable to replace current script with the latest version.`r`nPlease make sure your computer supports running .vbs scripts and that the script isn't running in a pipe."
	}
	
	;_Information := _Information = "" ? "-1" : _Information
	
	Return %_Information%
}
