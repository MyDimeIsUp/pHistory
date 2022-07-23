local commandTypeLogging = {} -- Commands are stored in here with their function as the value

-- TODO: Add a function that adds the commands to this table without doing it like im doing right now
-- There is no way to override the fancylog to show the reason in chat message but its better then
-- overwriting the ULX command.

/*
 * Accessory functions
 */
commandTypeLogging["slay"] = function(admin, args)
  local sReason = "N/A"
  local tTargets = ULib.getUsers(args[1], true, admin) -- Table of everyone who is targeted with this command

  for k, v in ipairs(args) do
    if k <= 1 then continue end -- Everything past the 1st index is part of the reason

    if sReason == "N/A" then
      -- Remove the N/A since a reason was defined
      sReason = v

      continue
    end

    sReason = sReason .. " " .. v
  end

  for _, target in ipairs(tTargets) do
    if !IsValid(target) then continue end

    pHistory.Data:AddPunishment(target:SteamID64(), admin, "Slay", sReason)
  end
end

commandTypeLogging["sslay"] = function(admin, args)
  local sReason = "N/A"
  local tTargets = ULib.getUsers(args[1], true, admin) -- Table of everyone who is targeted with this command

  for k, v in ipairs(args) do
    if k <= 1 then continue end -- Everything past the 1st index is part of the reason

    if sReason == "N/A" then
      -- Remove the N/A since a reason was defined
      sReason = v

      continue
    end

    sReason = sReason .. " " .. v
  end

  for _, target in ipairs(tTargets) do
    if !IsValid(target) then continue end

    pHistory.Data:AddPunishment(target:SteamID64(), admin, "Slay", sReason)
  end
end

commandTypeLogging["jail"] = function(admin, args)
  local sReason = "N/A"
  local tTargets = ULib.getUsers(args[1], true, admin) -- Table of everyone who is targeted with this command

  for k, v in ipairs(args) do
    if k <= 2 then continue end -- Everything past the 2nd index is part of the reason. 2nd index is the time for the jail

    if sReason == "N/A" then
      -- Remove the N/A since a reason was defined
      sReason = v

      continue
    end

    sReason = sReason .. " " .. v
  end

  sReason = "Reason: " .. sReason .. " | Length: " .. ULib.secondsToStringTime(args[2])

  for _, target in ipairs(tTargets) do
    if !IsValid(target) then continue end

    pHistory.Data:AddPunishment(target:SteamID64(), admin, "Jail", sReason)
  end
end

commandTypeLogging["gag"] = function(admin, args)
  local sReason = "N/A"
  local tTargets = ULib.getUsers(args[1], true, admin) -- Table of everyone who is targeted with this command

  for k, v in ipairs(args) do
    if k <= 1 then continue end -- Everything past the 1st index is part of the reason

    if sReason == "N/A" then
      -- Remove the N/A since a reason was defined
      sReason = v

      continue
    end

    sReason = sReason .. " " .. v
  end

  for _, target in ipairs(tTargets) do
    if !IsValid(target) then continue end

    pHistory.Data:AddPunishment(target:SteamID64(), admin, "Gag", sReason)
  end
end

commandTypeLogging["mute"] = function(admin, args)
  local sReason = "N/A"
  local tTargets = ULib.getUsers(args[1], true, admin) -- Table of everyone who is targeted with this command

  for k, v in ipairs(args) do
    if k <= 1 then continue end -- Everything past the 1st index is part of the reason

    if sReason == "N/A" then
      -- Remove the N/A since a reason was defined
      sReason = v

      continue
    end

    sReason = sReason .. " " .. v
  end

  for _, target in ipairs(tTargets) do
    if !IsValid(target) then continue end

    pHistory.Data:AddPunishment(target:SteamID64(), admin, "Mute", sReason)
  end
end

/*
 * Administration commands (kick/ban)
 */
 commandTypeLogging["kick"] = function(admin, args)
   local sReason = "N/A"
   local tTargets = ULib.getUsers(args[1], true, admin) -- Table of everyone who is targeted with this command

   for k, v in ipairs(args) do
     if k <= 1 then continue end -- Everything past the 1st index is part of the reason

     if sReason == "N/A" then
       -- Remove the N/A since a reason was defined
       sReason = v

       continue
     end

     sReason = sReason .. " " .. v
   end

   for _, target in ipairs(tTargets) do
     if !IsValid(target) then continue end

     pHistory.Data:AddPunishment(target:SteamID64(), admin, "Kick", sReason)
   end
 end

-- I would love to combine ban and banid using the ULibPlayerBanned hook but it doesn't have the admin who issued the ban
-- so there is no way to log their data. I have to do it the hard way like this :(
commandTypeLogging["ban"] = function(admin, args)
  local sReason = "N/A"
  local tTargets = ULib.getUsers(args[1], true, admin) -- Table of everyone who is targeted with this command

  for k, v in ipairs(args) do
    if k <= 2 then continue end -- Everything past the 2nd index is part of the reason. 2nd index is the time for the jail

    if sReason == "N/A" then
      -- Remove the N/A since a reason was defined
      sReason = v
      continue
    end

    sReason = sReason .. " " .. v
  end

  sReason = "Reason: " .. sReason .. " | Length: " .. ULib.secondsToStringTime(args[2] * 60)

  for _, target in ipairs(tTargets) do
    if !IsValid(target) then continue end
    pHistory.Data:AddPunishment(target:SteamID64(), admin, "Ban", sReason)
  end
end

commandTypeLogging["banid"] = function(admin, args)
  local sReason = "N/A"
  local sSteamId = args[1]

  if string.sub(sSteamId, 1, 7) == "STEAM_0" || string.sub(sSteamId, 1, 3) == "765" then -- Verify we have an actual steamid
    if string.sub(sSteamId, 1, 7) == "STEAM_0" then
      -- Convert to SteamID64 if we have 32
      sSteamId = util.SteamIDTo64(sSteamId)
    end

    for k, v in ipairs(args) do
      if k <= 2 then continue end -- Everything past the 2nd index is part of the reason. 2nd index is the time for the jail

      if sReason == "N/A" then
        -- Remove the N/A since a reason was defined
        sReason = v
        continue
      end

      sReason = sReason .. " " .. v
    end

    sReason = "Reason: " .. sReason .. " | Length: " .. ULib.secondsToStringTime(args[2] * 60)

    pHistory.Data:AddPunishment(sSteamId, admin, "Ban", sReason)
  end
end

local function checkCommandType(ply, sCommandType, args)
  sCommandType = string.gsub(sCommandType, "ulx ", "") -- Remove the ULX prefix of the command

  local commandLogFunc = commandTypeLogging[tostring(sCommandType)]

  if sCommandType ~= nil and sCommandType ~= "" and isfunction(commandLogFunc) then
    commandLogFunc(ply, args)
  end
end

hook.Add("ULibCommandCalled", "pHistory.ULXDefault.CheckCommand", checkCommandType)

pHistory.print("success", "Loaded ULX interface")
