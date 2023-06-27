# <h1 align="center">Dayz Dedicated Server Mod Copy Script.</h1>

<p align="center"><img width="500" src="https://github.com/JTonyC/Dayz_Mod_Copy_To_Server_Script/assets/8288792/b89f738f-0b83-48e6-8a24-f26bedf80c9e"></p>

This script can help to install and update mods on your windows LAN, dedicated server.

# Requirements
1) LAN Windows Server
2) Powershell 5.1 (Default in Windows 10/11)

# Instructions

Download the script and copy it to an empty directory.
Open the Dayz Launcher and click 'Mods' -> 'More' -> 'Export list of mods to a file...'

<p align="center"><img src="https://github.com/JTonyC/Dayz_Mod_Copy_To_Server_Script/assets/8288792/e1b2cfff-f7b5-430e-bc14-5952a287821e"></p>

When asked What list to export, select 'Only loaded Mods' if you have a Preset saved and loaded, otherwise select 'All mods'.

Save this modlist into the same directory as the script.

Now, open powershell, change directory to the script folder and run the following command:

.\Dayz_Mod_Copy.ps1 -ModHTMLFile "Name_of_ModList.html" -UNCPathToServerRoot 'UNC Path to the root of the DayzServer install'

Example
.\Dayz_Mod_Copy.ps1 -ModHTMLFile "Dayz_Mods.html" -UNCPathToServerRoot '\\Yourserveripaddress\sharename\steamCMD\Games\Dayz\DayzServer'

If you don't have access to the UNC path, you will be prompted for credentials. Once entered, the IPC$ share will be silently mapped and a retest will take place.
If this fails, then you'll need to look at what was entered for the UNC path to make sure its accurate or check your network credentials.

The script will then look to see if the mods list is present in the same directory. If it is then the script will proceed to upload mods to the root of the Dayz Dedicated Server install Folder.
(This is not the host root, it is specifically the Dayz Server install root, as specified by the UNC path you provided.)

In addition, this script isn't signed, so, you may need to update your shell by using the following command:

Set-ExecutionPolicy -ExecutionPolicy Unrestricted

You'll need an admin prompt to do that. Once you've run the script, its recommended to set it back to remote signed with this:

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
