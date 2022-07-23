local eOpenedPanel = nil -- I know panel isn't an entity, but I just put 'e' because it needed some time of identifier

local function pMenuOpen()
  if IsValid(eOpenedPanel) then
    eOpenedPanel:Remove()

    return
  else
    eOpenedPanel = vgui.Create("pHistoryMenu")
  end
end

net.Receive("pHistory.OpenMenu", function()
  pMenuOpen()
end)

net.Receive("pHistory.SendChatMsg", function()
  local sType = net.ReadString()
  local sMessage = net.ReadString()

  pHistory.chatPrintNotice(sType, sMessage)
end)
