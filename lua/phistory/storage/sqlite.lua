pHistory.Data = pHistory.Data or {}

--[[
  sql.SQLStr is used to sanitize the strings until prepared SQL statements are a thing
  thanks to @Multithreaded Lua for finally posting a suggestion on gmod requests
]]

function pHistory.Data:Startup()
  if !sql.TableExists("pHistory_punishments") then
    -- Create main punishments table
    sql.Query([[
    CREATE TABLE `pHistory_punishments` (
    `id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `steamid64` INT(18) NOT NULL,
    `type` TEXT(25) NOT NULL DEFAULT '',
    `issued_on` INT(10) NULL,
    `reason` TEXT(300) NULL DEFAULT NULL,
    `admin_nick` TEXT(300) NULL DEFAULT NULL,
    `admin_steamid64` INT(18) NULL DEFAULT NULL
    );]])

    pHistory.print("success", "Created punishments SQL table")
  end

  if !sql.TableExists("pHistory_notes") then
    -- Create notes table
    sql.Query([[
    CREATE TABLE `pHistory_notes` (
  	`id` INTEGER PRIMARY KEY AUTOINCREMENT,
    `steamid64` INT(18) NOT NULL,
    `noted_on` INT(10) NULL,
    `reason` TEXT(300) NULL DEFAULT NULL,
    `admin_nick` TEXT(300) NULL DEFAULT NULL,
    `admin_steamid64` INT(18) NULL DEFAULT NULL
    );]])

    pHistory.print("success", "Created notes SQL table")
  end

  pHistory.print("success", "SQLite startup")
end

function pHistory.Data:AddPunishment(sPlySteamId, admin, sType, sReason)
  local sAdminNick -- used if admin is passed as an entity of a string (for bans)

  if !isstring(admin) then
    if !pHistory.Config.allowedGroups[admin:GetUserGroup()] then return false end
    sAdminNick = admin:Nick()
  else
    sAdminNick = admin
  end

  sql.Query(string.format("INSERT INTO pHistory_punishments(steamid64, type, issued_on, reason, admin_nick, admin_steamid64) VALUES(%s, %s, %s, %s, %s, %s)", sql.SQLStr(sPlySteamId), sql.SQLStr(sType), sql.SQLStr(os.time()), sql.SQLStr(sReason), sql.SQLStr(sAdminNick), sql.SQLStr(admin:SteamID64())))
end

function pHistory.Data:AddNote(admin, sPlySteamId, sNote, fPostQuery)
  if !pHistory.Config.allowedGroups[admin:GetUserGroup()] then return false end

  sql.Query(string.format("INSERT INTO pHistory_notes(steamid64, noted_on, reason, admin_nick, admin_steamid64) VALUES(%s, %s, %s, %s, %s)", sql.SQLStr(sPlySteamId), sql.SQLStr(os.time()), sql.SQLStr(sNote), sql.SQLStr(admin:Nick()), sql.SQLStr(admin:SteamID64())))

  fPostQuery()
end

function pHistory.Data:GetFullPlayerHistory(admin, sSteamId64, fPostQuery)
  if !pHistory.Config.allowedGroups[admin:GetUserGroup()] then return false end

  local punishments = sql.Query(string.format("SELECT * FROM pHistory_punishments WHERE steamid64 = %s", sql.SQLStr(sSteamId64)))
  local notes = sql.Query(string.format("SELECT * FROM pHistory_notes WHERE steamid64 = %s", sql.SQLStr(sSteamId64)))

  fPostQuery(punishments, notes)
end

--[[
  Fetches the row of a note with the specified unique ID, referencing the primary key of each note
]]
function pHistory.Data:GetNoteByID(admin, iNoteId, fPostQuery)
  if !pHistory.Config.allowedGroups[admin:GetUserGroup()] then return false end

  local note = sql.Query(string.format("SELECT * FROM pHistory_notes WHERE id = %i", tonumber(iNoteId)))

  fPostQuery(note)
end

--[[
  Update's the note entry by its unique ID
  Check for permission was already performed in the serverside net.Recieve method. Lets not have to query the SQL database again
]]
function pHistory.Data:ModifyNote(admin, iNoteId, sNoteEntry, fPostQuery)
  if !pHistory.Config.allowedGroups[admin:GetUserGroup()] then return false end

  sql.Query(string.format("UPDATE pHistory_notes SET reason = %s WHERE id = %i", sql.SQLStr(sNoteEntry), tonumber(iNoteId)))

  fPostQuery()
end

--[[
  Removes the note entry by its unique ID
  Check for permission was already performed in the serverside net.Recieve method. Lets not have to query the SQL database again
]]
function pHistory.Data:DeleteNote(admin, iNoteId, fPostQuery)
  if !pHistory.Config.canDeleteEditNotes[admin:GetUserGroup()] then return false end

  sql.Query(string.format("DELETE FROm pHistory_notes WHERE id = %i", tonumber(iNoteId)))

  fPostQuery()
end
