pHistory.Data = pHistory.Data or {}

require("mysqloo")

/*
 * WARNING: DO NOT TOUCH BELOW UNLESS YOU KNOW WHAT YOU ARE DOING!
 * Requires mysqloo. Suports tmysql4 if wrapper is used. If you use tmysql4, your should get MySQLoo
 */

local pDBInfo = pHistory.Config.mysql
local pDB = mysqloo.connect(pDBInfo.address, pDBInfo.user, pDBInfo.password, pDBInfo.table, 3306)

function pDB:onConnected()
  pHistory.print("success", "MySQL Connected")
end

function pDB:onConnectionFailed(err)
  pHistory.print("error", "Error while attempting to connect to MySQL")
  phistory.print("error", err)
end

pDB:connect()

function pHistory.Data:Startup()
  local createFunc = pDB:query([[
  CREATE TABLE IF NOT EXISTS `pHistory_punishments` (
  `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
  `steamid64` TEXT(18) NOT NULL,
  `type` TEXT(25) NOT NULL,
  `issued_on` INT(10) NULL,
  `reason` TEXT(300) NULL DEFAULT NULL,
  `admin_nick` TEXT(300) NULL DEFAULT NULL,
  `admin_steamid64` text(18) NULL DEFAULT NULL
  );]])

  function createFunc:onSuccess(err)
    pHistory.print("success", "Table interface connected")
  end

  function createFunc:onError(err)
    pHistory.print("error", "Error while attempting to interface with table")
    pHistory.print("error", err)
  end

  createFunc:start()

  local createFuncNotes = pDB:query([[
  CREATE TABLE IF NOT EXISTS `pHistory_notes` (
  `id` INTEGER PRIMARY KEY AUTO_INCREMENT,
  `steamid64` TEXT(18) NOT NULL,
  `noted_on` INT(10) NULL,
  `reason` TEXT(300) NULL DEFAULT NULL,
  `admin_nick` TEXT(300) NULL DEFAULT NULL,
  `admin_steamid64` text(18) NULL DEFAULT NULL
  );]])

  function createFuncNotes:onSuccess(err)
    pHistory.print("success", "Table interface connected")
  end

  function createFuncNotes:onError(err)
    pHistory.print("error", "Error while attempting to interface with notes table:")
    pHistory.print("error", err)
  end

  createFuncNotes:start()

  pHistory.print("success", "Initialization startup")
end

function pHistory.Data:AddPunishment(sPlySteamId, admin, sType, sReason)
  local sAdminNick -- used if admin is passed as an entity of a string (for bans)

  if !isstring(admin) then
    if !pHistory.Config.allowedGroups[admin:GetUserGroup()] then return false end
    sAdminNick = admin:Nick()
  else
    sAdminNick = admin
  end

  local addPunQuery = pDB:prepare("INSERT INTO pHistory_punishments(steamid64, type, issued_on, reason, admin_nick, admin_steamid64) VALUES(?, ?, ?, ?, ?, ?)")

  function addPunQuery:onError(err)
    pHistory.print("error", "Error while attempting to insert a punishment:")
    pHistory.print("error", err)
  end

  addPunQuery:setString(1, sPlySteamId)
  addPunQuery:setString(2, sType)
  addPunQuery:setNumber(3, os.time())
  addPunQuery:setString(4, sReason)
  addPunQuery:setString(5, sAdminNick)
  addPunQuery:setString(6, admin:SteamID64())
  addPunQuery:start()
end

function pHistory.Data:AddNote(admin, sPlySteamId, sNote, fPostQuery)
  if !pHistory.Config.allowedGroups[admin:GetUserGroup()] then return false end

  local addNoteQuery = pDB:prepare("INSERT INTO pHistory_notes(steamid64, noted_on, reason, admin_nick, admin_steamid64) VALUES(?, ?, ?, ?, ?)")

  function addNoteQuery:onSuccess(err)
    fPostQuery()
  end

  function addNoteQuery:onError(err)
    pHistory.print("error", "Error while attempting to insert a note:")
    pHistory.print("error", err)
  end

  addNoteQuery:setString(1, sPlySteamId)
  addNoteQuery:setNumber(2, os.time())
  addNoteQuery:setString(3, sNote)
  addNoteQuery:setString(4, admin:Nick())
  addNoteQuery:setString(5, admin:SteamID64())
  addNoteQuery:start()
end

function pHistory.Data:GetFullPlayerHistory(admin, sSteamId64, fPostQuery)
  if !pHistory.Config.allowedGroups[admin:GetUserGroup()] then return false end

  local getPunQuery = pDB:prepare("SELECT * FROM pHistory_punishments WHERE steamid64 = ?")

  function getPunQuery:onError(err)
    pHistory.print("error", "Error while fetch punushments:")
    pHistory.print("error", err)

    returnVal = nil
  end

  -- Kinda shitty way but it works
  function getPunQuery:onSuccess(punishments)
    -- Begin fetching notes
    local getNotesQuery = pDB:prepare("SELECT * FROM pHistory_notes WHERE steamid64 = ?")


    function getNotesQuery:onSuccess(notes)
      fPostQuery(punishments, notes)
    end

    getNotesQuery:setString(1, sSteamId64)
    getNotesQuery:start()
  end

  getPunQuery:setString(1, sSteamId64)
  getPunQuery:start()
end


/*
 * TODO: DO this
 * do punishmentHistory
 * break
 */

 function pHistory.Data:GetNoteByID(admin, iNoteId, fPostQuery)
   if !pHistory.Config.allowedGroups[admin:GetUserGroup()] then return false end

   local getNoteQuery = pDB:prepare("SELECT * FROM pHistory_notes WHERE id = ?")

   function getNoteQuery:onSuccess(note)
     fPostQuery(note)
   end

   function getNoteQuery:onError(err)
     pHistory.print("error", "Error while attempting to fetch a note:")
     pHistory.print("error", err)
   end

   getNoteQuery:setNumber(1, iNoteId)
   getNoteQuery:start()
 end

/*
 * Update's the note entry by its unique ID
 * Check for permission was already performed in the serverside net.Recieve method. Lets not have to query the SQL database again
 */
function pHistory.Data:ModifyNote(admin, iNoteId, sNoteEntry, fPostQuery)
  if !pHistory.Config.allowedGroups[admin:GetUserGroup()] then return false end

  local updateNoteQuery = pDB:prepare("UPDATE pHistory_notes SET reason = ? WHERE id = ?")

  function updateNoteQuery:onSuccess(err)
    fPostQuery()
  end

  function updateNoteQuery:onError(err)
    pHistory.print("error", "Error while attempting to insert a note:")
    pHistory.print("error", err)
  end

  updateNoteQuery:setString(1, sNoteEntry)
  updateNoteQuery:setNumber(2, iNoteId)
  updateNoteQuery:start()
end

/*
 * Removes the note entry by its unique ID
 * Check for permission was already performed in the serverside net.Recieve method. Lets not have to query the SQL database again
 */
function pHistory.Data:DeleteNote(admin, iNoteId, fPostQuery)
  if !pHistory.Config.canDeleteEditNotes[admin:GetUserGroup()] then return false end

  local getNoteQuery = pDB:prepare("DELETE FROM pHistory_notes WHERE id = ?")

  function getNoteQuery:onSuccess(note)
    fPostQuery(note)
  end

  function getNoteQuery:onError(err)
    pHistory.print("error", "Error while delete a note:")
    pHistory.print("error", err)
  end

  getNoteQuery:setNumber(1, iNoteId)
  getNoteQuery:start()
end
