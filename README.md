# Dayz Dedicated Server Mod Copy Script.

This script can help to install and update mods on your windows LAN, dedicated server.

# Requirements
1) LAN Windows Server
2) Powershell 5.1 (Default in Windows 10/11)

# Instructions

Download the script and copy it to an empty directory.
Open the Dayz Launcher and click 'Mods' -> 'More' -> 'Export list of mods to a file...'

![image](https://github.com/JTonyC/Dayz_Mod_Copy_To_Server_Script/assets/8288792/e1b2cfff-f7b5-430e-bc14-5952a287821e)

When asked What list to export, select 'Only loaded Mods' if you have a Preset saved and loaded, otherwise select 'All mods'.

Save this modlist into the same directory as the script.

Now, open powershell, change directory to the script folder and run the following command:

.\Dayz_Mod_Copy.ps1 -ModHTMLFile "Name_of_ModList.html" -UNCPathToServerRoot 'UNC Path to the DayzServer root'

Example
.\Dayz_Mod_Copy.ps1 -ModHTMLFile "Dayz_Mods.html" -UNCPathToServerRoot '\\Yourserveripaddress\sharename\steamCMD\Games\Dayz\DayzServer'

This may prompt you for credentials if your current credentials do not have access to the share.

Once entered, the script will proceed to upload the mods spoecified in the mods list.