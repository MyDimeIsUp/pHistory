surface.CreateFont("pHistory.playerInfoName", {
  font = "Tahoma",
  size = 18,
  weight = 1000, -- Bold
  antialias = true
})

surface.CreateFont("pHistory.playerInfoSteamId", {
  font = "Tahoma",
  size = 12,
  weight = 500, -- Bold
  antialias = true
})

local PANEL = {}

function PANEL:Init()
  self.ply = nil
  self:SetText("")
end

function PANEL:SetPlayer(ply)
  if not IsValid(ply) then return end

  self.ply = ply

  self.AvatarImage = vgui.Create("AvatarImage", self)
  self.AvatarImage:SetSize(32, 32)
  self.AvatarImage:SetPos(4, 4)
  self.AvatarImage:SetPlayer(ply, 32)

  self.PlayerName = vgui.Create("DLabel", self)
  self.PlayerName:SetFont("pHistory.playerInfoName")
  self.PlayerName:SetColor(color_white)
  self.PlayerName:SetText(ply:Nick())
  self.PlayerName:SizeToContents()
  self.PlayerName:SetPos(self.AvatarImage:GetWide() + 10, 4)

  self.PlayerSteamId = vgui.Create("DLabel", self)
  self.PlayerSteamId:SetFont("pHistory.playerInfoSteamId")
  self.PlayerSteamId:SetColor(color_white)
  self.PlayerSteamId:SetText(ply:SteamID())
  self.PlayerSteamId:SizeToContents()
  self.PlayerSteamId:SetPos(self.AvatarImage:GetWide() + 10, 4 + self.PlayerName:GetTall())
end

function PANEL:Paint(w, h)
  surface.SetDrawColor(56, 56, 56)
  surface.DrawRect(0, 0, w, h)
end

vgui.Register("pHistoryPlayerInfo", PANEL, "DButton")
