/*
####################################################################################################
####################################################################################################
######                                                                                        ######
######                                 TM2 Dedicated Launcher                                 ######
######                                                                                        ######
####################################################################################################
####################################################################################################


     AutoHotkey Version:    1.1.09.02
     Language:              English_United_States
     Encoding:              Unicode
     Developed Using:       WIN_7(x64)
     Created On:            16/05/2013
     Author:                grayatrox
     Description:           Launch TM2 Dedicated, and keep XAseco2 running
     Notes:                 I have not extensively tested for bugs.
                            Also, I will be adding autoupdating, and read variables from a config file,
                            possibly with XML to keep with tradition in the future (if I have time)

*/
; >> BEGIN AUTO-EXECUTE SECTION
    #NoEnv  ; Don't read Environment Variables (Recommended for performance and compatibility)
    SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
; >> VARIABLES     
    
    /*
        The path to the Dedicated
    */
    sLocation := A_ScriptDir
     
    /*
        The parameters to launch the server with
    */
    sSettings := "/title=TMStadium /game_settings=MatchSettings/FSTracks.txt /dedicated_cfg=dedicated_cfg.txt" 
     
    /*
        Title of the server window
         - Don't change this unless you know what you are doing
    */
    sTitle := sLocation . "\ManiaPlanetServer.exe" 

    /*
        The path to php.exe
    */
    pLocation := "c:\xampp\php\php.exe"
    
    /*
        The path to XAseco2
    */
    xLocation := sLocation . "\xaseco2"
     
; >> PROGRAM - DON'T EDIT BELOW THIS LINE
	pTitle := "TM2 Dedicated Launcher"
    setupTray()
    /*  
        Check to see if the Dedicated is running. 
        If it is, we can go straight to launching XAseco2 
    */
    if(!WinExist(sTitle)) {
          
        Run, "%sLocation%\ManiaPlanetServer.exe" %sSettings%
         
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
            Msgbox,17,Dedicated Launcher, Please close ManiaPlanet
            IfMsgbox, Cancel
                ExitApp
        }
        RunWait, %pLocation% XAseco2.php
    }     
     
    /*     
        Close the Program when the Dedicated and XAsceo2 are no longer running.
    */
    ExitApp 
	 
	MenuHandler:
	{
		if (A_ThisMenu == "Tray") {
			if (A_ThisMenuItem == "Reload"){
				Reload
				return
			} else if (A_ThisMenuItem == "Exit"){
				ExitApp
				return
			} else
			if (A_ThisMenuItem == "Help"){
				SplitPath, A_AhkPath,, OutDir
				Run, %OutDir%\AutoHotkey.chm
				return
			} else
			if (A_ThisMenuItem == "Open"){
				ListLines
				return
			} else
			if (A_ThisMenuItem == "Suspend"){
				Menu, Tray, ToggleCheck, %A_ThisMenuItem%
				Suspend,Toggle
				return
			} else
			if (A_ThisMenuItem == "Pause"){
				Menu, Tray, ToggleCheck, %A_ThisMenuItem%
				Pause,Toggle
				return
			} else
			if (A_ThisMenuItem == "Edit"){
				Edit
				return
			}
			
				
			
		}
		; (else)
			Msgbox %A_ThisMenuItem% was selected from the menu %A_ThisMenu%.

		Return
		
	}

	setupTray(){
		global
		Menu, Tray, NoStandard
		Menu, Tray, Add, %pTitle%, MenuHandler
		Menu, Tray, Disable, %pTitle%
		if (!A_isCompiled) {
			Menu, Tray, Add, Help, MenuHandler
			Menu, Tray, Add
		}
		Menu, Tray, Add, Suspend, MenuHandler
		Menu, Tray, Add, Pause, MenuHandler
		Menu, Tray, Add
		if (!A_isCompiled) {
			Menu, Tray, Add, Open, MenuHandler
			Menu, Tray, Add, Edit, MenuHandler
		}
		Menu, Tray, Add, Reload, MenuHandler
		Menu, Tray, Add, Exit, MenuHandler
	}