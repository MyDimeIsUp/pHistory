pHistory.Config = pHistory.Config or {}
pHistory.Version = "1.0.0"

pHistory.Config.logType = "sqlite" -- Supports: "sqlite" (Local storage), "mysql" (Remote storage for future webpanel)
pHistory.Config.chatCommand = "!phistory" -- What is the command that opens the admin menu.

/*
 * If your logType method is "mysql", fill out your MySQL information below
 */
pHistory.Config.mysql = pHistory.Config.mysql or {}
pHistory.Config.mysql.address = "192.168.1.178" -- IP address of server
pHistory.Config.mysql.user = "TrueKnife" -- Username
pHistory.Config.mysql.password = "dcz*NTpE&8mQ4dj" -- Password
pHistory.Config.mysql.table = "phistory_logging" -- Create your database named "phistory_logging" in phpMyAdmin or your preferred MySQL interfacing
pHistory.Config.mysql.port = 3306 -- Do not edit unless you know you've changed your default MySQL port

/*
 * The admin mod you whish to use to log. Currently supported is ULX.
 * ULX:
 *    ulx: Uses ULX admin mod but doesn't show the reason in the chat message when someone is punished
 *
 * FAdmin (Coming Soon)
 * ServerGuard (Coming Soon)
 */
pHistory.Config.adminMod = "ulx"
pHistory.Config.minimumNoteLength = 15 -- Minimum amount of characters required for a note to be added

/*
 * Usergroups that may access the menu via the chatCommand.
 * Format:
 *  ["GroupNameHere"] = true,
 */
pHistory.Config.allowedGroups = {
  ["superadmin"] = true,
  ["admin"] = true,
  ["moderator"] = true,
}

/*
 * Usergroups that may edit/delete any note, even if not made by themselves.
 * Format:
 *  ["GroupNameHere"] = true,
 */
pHistory.Config.canDeleteEditNotes = {
  ["superadmin"] = true,
  ["admin"] = true,
}

/* Menu Customizations */

-- Main window
pHistory.Config.menuBackgroundColor = Color(48, 48, 48) -- Background of the admin menu
pHistory.Config.menuHeaderColor = Color(70, 70,  70) -- Background of the 48px header of the admin menu
pHistory.Config.menuAccentcolor = Color(150, 40, 40) -- The accent color of the admin menu. Accents the menu header, panel divisions, etc.

-- Window elements
pHistory.Config.warningBackground = Color(40, 40, 40) -- Background of text input

pHistory.Config.buttonBackground = Color(40, 40, 40)
pHistory.Config.buttonHoverBackground = Color(45, 45, 45)
pHistory.Config.buttonPressedDown = Color(30, 30, 30)

pHistory.Config.textEntryBackground = Color(65, 65, 65) -- Background of text input
pHistory.Config.textEntryBackgroundFocused = Color(58, 58, 58) -- Background of text input while focused
pHistory.Config.textEntryInputColor = color_white -- Color of text

/*
 * WARNING: DO NOT EDIT BELOW
 */
if SERVER then
  if !file.Exists("phistory/storage/" .. pHistory.Config.logType .. ".lua", "LUA") then
    pHistory.print("error", "Unable to load storage method: ", Color(255, 0, 0), pHistory.Config.logType)
  else
    include("phistory/storage/" .. pHistory.Config.logType .. ".lua")
    pHistory.print("success", "Loaded storage method: " .. pHistory.Config.logType)
  end

  -- Which admin mod to use for ULX
  if pHistory.Config.adminMod == "ulx" then
    -- Add the ULibCommandCalled hook. We don't need to delay this since its only a hook file
    include("phistory/admin_mods/ulx.lua")
  end
end
