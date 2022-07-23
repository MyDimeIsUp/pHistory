pHistory = pHistory or {}

local tPrint = {
  ["print"] = {
    prefix = "", -- No prefix for normal print
    color = color_white
  },
  ["error"] = {
    prefix = "[ERROR]",
    color = Color(255, 0, 0)
  },
  ["success"] = {
    prefix = "[SUCCESS]",
    color = Color(0, 255, 0)
  }
}

function pHistory.print(sType, ...)
  MsgC(Color(0, 255, 0), "[pHistory] ", tPrint[sType].color, tPrint[sType].prefix, color_white, " ", ..., "\n")
end

if SERVER then
  include("phistory/phistory_config.lua")
  include("phistory/sv_phistory.lua")

  AddCSLuaFile("phistory/phistory_config.lua")
  AddCSLuaFile("phistory/cl_phistory.lua")

  /* VGUI elements */
  -- View TODO #39
  AddCSLuaFile("phistory/vgui/phistorytextinput.lua")
  AddCSLuaFile("phistory/vgui/phistoryplayerrow.lua")
  AddCSLuaFile("phistory/vgui/phistorybutton.lua")

  AddCSLuaFile("phistory/vgui/phistoryaddnote.lua")
  AddCSLuaFile("phistory/vgui/phistorymenu.lua")
end

if CLIENT then
  include("phistory/phistory_config.lua")
  include("phistory/cl_phistory.lua")

  /* VGUI elements */
  -- TODO: Move this to a foor loop so I don't have to put each file here manually
  include("phistory/vgui/phistorytextinput.lua")
  include("phistory/vgui/phistoryplayerrow.lua")
  include("phistory/vgui/phistorybutton.lua")

  include("phistory/vgui/phistoryaddnote.lua")
  include("phistory/vgui/phistorymenu.lua")

  function pHistory.chatPrint(...)
    chat.AddText(Color(0, 255, 0), "[pHistory] ", color_white, ...)
  end

  function pHistory.chatPrintNotice(sType, ...)
    chat.AddText(Color(0, 255, 0), "[pHistory] ", tPrint[sType].color, tPrint[sType].prefix, color_white, " ", ...)
  end
end

pHistory.print("success", "pHistory init success!")
