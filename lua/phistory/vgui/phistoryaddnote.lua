surface.CreateFont("pHistory.addNoteHeader", {
  font = "Tahoma",
  size = 25,
  weight = 1000, -- Bold
  antialias = true
})

surface.CreateFont("pHistory.addNoteHelperLabel", {
  font = "Tahoma",
  size = 20,
  weight = 500,
  antialias = true
})

local PANEL = {}

function PANEL:Init()
  self.ply = nil

  self:SetSize(350, 350)
  self:Center()
  self:MakePopup()
end

function PANEL:SetPlayer(sSteamId64)
  self.ply = player.GetBySteamID64(sSteamId64)

  local mainContainer = vgui.Create("EditablePanel", self)
  mainContainer:SetPos(0, 48)
  mainContainer:SetSize(self:GetWide(), self:GetTall() - 48)

  -- Close button. Use Microsoft's marlett font
  local closeButton = vgui.Create("DButton", self)
  closeButton:SetText("X")
  closeButton:SetColor(Color(255, 255, 255))
  closeButton:SetSize(32, 32)
  closeButton:SetPos(self:GetWide() - 40, 8)
  closeButton.Paint = function() end

  closeButton.DoClick = function()
    self:Remove()
  end

  local steamIdSelectd = vgui.Create("DLabel", mainContainer)
  steamIdSelectd:SetText("Selected SteamID: ")
  steamIdSelectd:SetFont("pHistory.addNoteHelperLabel")
  steamIdSelectd:SizeToContents()
  steamIdSelectd:SetPos(5, 5)

  local steamId = vgui.Create("DLabel", mainContainer)
  steamId:SetText(sSteamId64)
  steamId:SetFont("pHistory.addNoteHelperLabel")
  steamId:SetColor(pHistory.Config.menuAccentcolor)
  steamId:SizeToContents()
  steamId:SetPos(5 + steamIdSelectd:GetWide(), 5)

  local noteEntry = vgui.Create("pHistoryTextInput", mainContainer)
  noteEntry:SetPos(5, 40)
  noteEntry:SetSize(mainContainer:GetWide() - 10, mainContainer:GetTall() - 40 - 50)
  noteEntry:SetMultiline(true)
  noteEntry:SetHelperText("Note Entry")

  local addNoteButton = vgui.Create("pHistoryButton", self)
  addNoteButton:SetText("Add Note (More than " .. pHistory.Config.minimumNoteLength .. " characters)")
  addNoteButton:SetSize(self:GetWide(), 40)
  addNoteButton:SetPos(0, self:GetTall() - 40)

  addNoteButton.DoClick = function(s)
    if string.len(noteEntry:GetValue()) <= pHistory.Config.minimumNoteLength then return end -- Must enter more than 10 characters for a note

    net.Start("pHistory.AddNote")
    net.WriteString(sSteamId64)
    net.WriteString(noteEntry:GetValue())
    net.SendToServer()

    self:Remove()
  end
end

function PANEL:Paint(w, h)
  Derma_DrawBackgroundBlur(self)

  surface.SetDrawColor(pHistory.Config.menuBackgroundColor)
  surface.DrawRect(0, 0, w, w)

  -- Header
  surface.SetDrawColor(pHistory.Config.menuHeaderColor)
  surface.DrawRect(0, 0, w, 48)

  -- Header accent color
  surface.SetDrawColor(pHistory.Config.menuAccentcolor)
  surface.DrawRect(0, 48 - 5, w, 5)

  surface.SetFont("pHistory.addNoteHeader")

  local iProductNameW, iProductNameH = surface.GetTextSize("pHistory | Player History Manager")
  surface.SetTextPos(iProductNameH / 2, (48 - 5) / 2 - iProductNameH / 2)
  surface.DrawText("pHistory | Add Note")
end

vgui.Register("pHistoryAddNote", PANEL, "EditablePanel")
