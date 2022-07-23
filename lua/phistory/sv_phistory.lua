util.AddNetworkString("pHistory.OpenMenu")
util.AddNetworkString("pHistory.SendChatMsg")
util.AddNetworkString("pHistory.RequestSteamId")
util.AddNetworkString("pHistory.AddNote")
util.AddNetworkString("pHistory.ModifyNote")
util.AddNetworkString("pHistory.DeleteNote")

function pHistory:addChatMsg(ply, sType, sMessage)
  net.Start("pHistory.SendChatMsg")
  net.WriteString(sType)
  net.WriteString(sMessage)
  net.Send(ply)
end

function pHistory:findHistoryBySteamId(admin, sSteamId)
  pHistory.Data:GetFullPlayerHistory(admin, sSteamId, function(punishments, notes)

    -- Do this incase the player has no history. Prevents our vars from being null and instead set them to empty table
    punishments = punishments or {}
    notes = notes or {}

    local playerInfo = {
      punishments = punishments,
      notes = notes
    }

    net.Start("pHistory.RequestSteamId")
    net.WriteTable(playerInfo)
    net.Send(admin)
  end)
end

function pHistory:addNote(admin, sSteamId64, sNoteEntry)
  if string.len(sNoteEntry) <= pHistory.Config.minimumNoteLength then return end

  pHistory.Data:AddNote(admin, sSteamId64, sNoteEntry, function()
    -- Send new info to client
    pHistory:findHistoryBySteamId(admin, sSteamId64)
  end)
end

function pHistory:modifyNote(admin, iNoteId, sNoteEntry)
  pHistory.Data:GetNoteByID(admin, iNoteId, function(noteRow)

    if !noteRow or noteRow == nil or noteRow == false then return end -- Maybe it was already deleted?

    noteRow = noteRow[1] -- We exist so set us to the only returned row

    pHistory.Data:ModifyNote(admin, iNoteId, sNoteEntry, function()
      -- Send new info to client
      pHistory:findHistoryBySteamId(admin, noteRow["steamid64"])
    end)
  end)
end

function pHistory:deleteNote(admin, iNoteId)
  pHistory.Data:GetNoteByID(admin, iNoteId, function(noteRow)

    if !noteRow or noteRow == nil or noteRow == false then return end -- Maybe it was already deleted?

    noteRow = noteRow[1] -- We exist so set us to the only returned row

    pHistory.Data:DeleteNote(admin, iNoteId, function()
      -- Send new info to client
      pHistory:findHistoryBySteamId(admin, noteRow["steamid64"])
    end)
  end)
end

net.Receive("pHistory.RequestSteamId", function(_, admin)
  if !IsValid(admin) then return end
  if !pHistory.Config.allowedGroups[admin:GetUserGroup()] then return end

  local sSteamId = net.ReadString()

  pHistory:findHistoryBySteamId(admin, sSteamId)
end)

net.Receive("pHistory.AddNote", function(_, admin)
  if !IsValid(admin) then return end
  if !pHistory.Config.allowedGroups[admin:GetUserGroup()] then return end

  local sSteamId = net.ReadString()
  local sNoteEntry = net.ReadString()

  pHistory:addNote(admin, sSteamId, sNoteEntry)
end)

net.Receive("pHistory.ModifyNote", function(_, admin)
  if !IsValid(admin) then return end

  local iNoteId = net.ReadInt(16)
  local sNoteEntry = net.ReadString()

  pHistory:modifyNote(admin, iNoteId, sNoteEntry)
end)

net.Receive("pHistory.DeleteNote", function(_, admin)
  if !IsValid(admin) then return end

  local iNoteId = net.ReadInt(16)

  pHistory:deleteNote(admin, iNoteId)
end)

hook.Add("PlayerSay", "pMenu.CheckForOpen", function(ply, sMsg)
  if !IsValid(ply) then return end

  if string.lower(sMsg) == pHistory.Config.chatCommand then
    if !pHistory.Config.allowedGroups[ply:GetUserGroup()] then
      pHistory:addChatMsg(ply, "error", "You don't have access to this menu!")

      return false
    end

    net.Start("pHistory.OpenMenu")
    net.Send(ply)

    return false -- Don't show our command in the chat
  end
end)

pHistory.Data:Startup()
