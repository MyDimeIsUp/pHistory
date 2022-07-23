local PANEL = {}

function PANEL:Init()
  self:SetContentAlignment(5)
  --
  -- These are Lua side commands
  -- Defined above using AccessorFunc
  --
  self:SetDrawBorder(true)
  self:SetPaintBackground(true)
  self:SetTall(22)
  self:SetMouseInputEnabled(true)
  self:SetKeyboardInputEnabled(true)
  self:SetCursor("hand")
  self:SetFont("DermaDefault")

  self:SetTextColor(color_white)
end

function PANEL:Paint(w, h)
  if self:IsDown() then
    surface.SetDrawColor(pHistory.Config.buttonPressedDown)
  elseif self:IsHovered() then
    surface.SetDrawColor(pHistory.Config.buttonHoverBackground)
  else
    surface.SetDrawColor(pHistory.Config.buttonBackground)
  end

  surface.DrawRect(0, 0, w, h)
end

vgui.Register("pHistoryButton", PANEL, "DButton")
