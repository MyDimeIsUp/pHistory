![Big Banner](https://user-images.githubusercontent.com/8619739/180586350-56f57863-170b-4c7e-bf22-15a77cb87949.png)


# pHistory
 
 <details>
  <summary>Screenshots</summary>

  ![8bced4e1bab48bda68b6d226458c6254](https://user-images.githubusercontent.com/8619739/180586680-0777ab13-b2ba-401b-91a0-981d93673579.png)
  ![0aa883ad1dc30482b69a32a737c0e647](https://user-images.githubusercontent.com/8619739/180586683-344bfc04-bb05-4186-a4dd-a5b93870e6e3.png)
  ![b9436a631631fcd589e3ae56790c49f1](https://user-images.githubusercontent.com/8619739/180586689-e766fb98-fe99-4037-8c76-89d7797a9dc3.png)
  ![0add7d2eff50eac7a68a1213bc191d83](https://user-images.githubusercontent.com/8619739/180586694-5bb4c041-0f00-472d-b279-e3b1c6352906.png)
  ![44e4fa50012bc3bf3c28a92d8e299182](https://user-images.githubusercontent.com/8619739/180586698-1b3dd11e-42c5-45cb-98e4-e7ab50ade004.png)
</details>
 
pHistory allows you to view all punishment history of a player. Need to know whether to ban them for their 2nd offense of something? Do they have a history of spamming chat, being toxic, or loopholing? Now you know. You can also leave notes about a player's behavior, whether they are helpful and assistive or a pain the the rear-end, its all here for you and your staff team.

## Features:
* By default, tracks the following ULX commands
    * Slay
    * Mute
    * Gag
    * Jail
    * Kick
    * Ban
* Allows personalized notes on a player's behavior
* Add, edit, or delete notes
* Customization of the following
  * Chat command
  * All colors of the menu
  * Groups who may access the menu
  * Groups who may edit/delete notes that weren't made by them


## Supports:
* ALL GAMEMODES
* ULX

# Installation
Installation is easy! Once the addon has been downloaded, drag the `pHistory` folder into your addons folder. Then, navigate to `addons/pHistory/lua/phistory/phistory_config.lua` and edit to your liking. Listed below are the essentials for getting pHistory setup for your server.

`pHistory.Config.logType`: Where to log punishments and notes. Currently local storage and MySQL are supported. For MySQL to work, you must have MySQLOO module installed on your gmod server.

`pHistory.Config.chatCommand`: The chat message that staff members must enter to open the menu.

`pHistory.Config.adminMod`: The admin mod you are currently using. Only ULX supported right now. FAdmin and ServerGuard support in the future

`pHistory.Config.allowedGroups`: Which ranks have access to the menu. Access to the menu allows them to open the menu, search a player's history and make notes. The following format should be followed for adding a new rank:

`pHistory.Config.canDeleteEditNotes`:  Which ranks can delete notes not made by them. By  default, only staff members can modify/delete their own notes. Ranks in this usergroup can modify/delete notes not made by them.

# Developer Integration

Already using a ULX command: Go to `pHistory/admin_mods/ulx.lua` Below `commandTypeLogging["banid"]` add the following using how you would like to store the punishment. `{command}` is how the command is run if you were to use the console Ex("ban" since in console you use "ulx ban"; "kick" since in console you use "ulx kick")

```lua
commandTypeLogging["{command}"] = function(eAdmin, args)
	-- Code body
	pHistory.Data:AddPunishment(sPlySteamId, eAdmin, sType, sReason)
end
```



If you want to log outside of the file with your own style, just add the following function where you please
`pHistory.Data:AddPunishment(sPlySteamId, eAdmin, sType, sReason)`
Args:
* sPlySteamId: The SteamId64 of the player you want to add the punishment to
* eAdmin: The entity of the staff member who is punishing the player
* sType: The type of punishment that shows up in the menu (Gag, kick, etc.). Make it whatever best describes the punishment
* sReason: The reason associated with the command. If you don't want a reason to be associated with it, just fill it in as "N/A"
