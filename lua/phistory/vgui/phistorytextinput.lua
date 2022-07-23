surface.CreateFont("pHistory.inputHelperText", {
	font = "Tahoma",
	size = 15,
	weight = 500, -- Bold
	antialias = true
})

local PANEL = {}

function PANEL:Init()
	self:SetHistoryEnabled(false)
	self.History = {}
	self.HistoryPos = 0
	--
	-- We're going to draw these ourselves in
	-- the skin system - so disable them here.
	-- This will leave it only drawing text.
	--
	self:SetPaintBorderEnabled(false)
	self:SetPaintBackgroundEnabled(false)
	--
	-- These are Lua side commands
	-- Defined above using AccessorFunc
	--
	self:SetDrawBorder(true)
	self:SetPaintBackground(true)
	self:SetEnterAllowed(true)
	self:SetUpdateOnType(false)
	self:SetNumeric(false)
	self:SetAllowNonAsciiCharacters(true)
	-- Nicer default height
	self:SetTall(20)
	-- Clear keyboard focus when we click away
	self.m_bLoseFocusOnClickAway = true
	-- Beam Me Up Scotty
	self:SetCursor("beam")
	self:SetFont("DermaDefault")
	-- Helper text
	self._helperText = ""
end

function PANEL:SetHelperText(sText)
	self._helperText = sText
end

function PANEL:Paint(w, h)
	-- Draw helper text
	DisableClipping(true)
	surface.SetFont("pHistory.inputHelperText")
	surface.SetTextColor(pHistory.Config.textEntryInputColor)
	surface.SetTextPos(0, -15)
	surface.DrawText(self._helperText)
	DisableClipping(false)

	if self:HasFocus() then
		surface.SetDrawColor(pHistory.Config.textEntryBackgroundFocused)
		surface.DrawRect(0, 0, w, h)
	else
		surface.SetDrawColor(pHistory.Config.textEntryBackground)
		surface.DrawRect(0, 0, w, h)
	end

	-- Text color; highlight color; carrot color
	self:DrawTextEntryText(pHistory.Config.textEntryInputColor, Color(0, 0, 255, 100), color_black)
end

vgui.Register("pHistoryTextInput", PANEL, "DTextEntry")
