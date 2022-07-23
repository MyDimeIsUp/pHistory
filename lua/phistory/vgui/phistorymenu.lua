surface.CreateFont("pHistory.headerText", {
	font = "Tahoma",
	size = 30,
	weight = 1000, -- Bold
	antialias = true
})

surface.CreateFont("pHistory.warningHeader", {
	font = "Tahoma",
	size = 25,
	weight = 500, -- Bold
	antialias = true
})

surface.CreateFont("pHistory.tableHeader", {
	font = "Tahoma",
	size = 14,
	weight = 500,
	antialias = true
})

local PANEL = {}

function PANEL:Init()
	self.currentPlySteamId = nil -- Used to check if we are loading the same person twice

	local iPanelW, iPanelH = 900, 650

	self:SetSize(iPanelW, iPanelH)
	self:MakePopup()
	self:Center()

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

	-- The space below the header. Use this so we don't have to keep setting every elmenets 'Y-pos = 48 + integer'
	self.mainContainer = vgui.Create("DPanel", self)
	self.mainContainer:SetSize(self:GetWide(), self:GetTall() - 48)
	self.mainContainer:SetPos(0, 48)

	self.mainContainer.Paint = function(s, w, h)
		surface.SetDrawColor(pHistory.Config.menuBackgroundColor)
		surface.DrawRect(0, 0, w, h)
	end

	-- When a player's history is found, all data is presented here
	self.playerInfoContainer = vgui.Create("DPanel", self)
	self.playerInfoContainer:SetSize(self:GetWide(), self:GetTall() - 48)
	self.playerInfoContainer:SetPos(0, self:GetTall())

	self.playerInfoContainer.Paint = function(s, w, h)
		surface.SetDrawColor(pHistory.Config.menuBackgroundColor)
		surface.DrawRect(0, 0, w, h)
	end

	self:InitFirstOpen()
end

function PANEL:InitFirstOpen()
	self.steamIdSearch = vgui.Create("pHistoryTextInput", self.mainContainer)
	self.steamIdSearch:SetSize(self:GetWide() * 0.90, 25)
	self.steamIdSearch:SetPos(self:GetWide() / 2 - self.steamIdSearch:GetWide() / 2, 20)
	--steamIdSearch:SetPlaceholderText("SteamID")
	self.steamIdSearch:SetHelperText("Search for SteamID (32 or 64)")

	self.steamIdSearch.OnEnter = function(s)
		if string.sub(s:GetValue(), 1, 7) == "STEAM_0" or string.sub(s:GetValue(), 1, 3) == "765" then
			local iSteamId64 = s:GetValue()

			if string.sub(s:GetValue(), 1, 7) == "STEAM_0" then
				-- We aren't already a SteamID64, so lets convert
				iSteamId64 = util.SteamIDTo64(s:GetValue())
			end

			s:SetDisabled(true)

			if iSteamId64 == self.currentPlySteamId then
				-- Must have returned to search for another SteamID and changed mind. No need to request player info when we already have it
				self.playerInfoContainer:MoveTo(self:GetWide() / 2 - self.playerInfoContainer:GetWide() / 2, 48, 1, 0, -1)
				s:SetDisabled(false)

				return
			end

			if iSteamId64 == "0" then
				self:AlertHeader("You entered an invalid SteamID", "icon16/exclamation.png", Color(255, 0, 0))
				s:SetDisabled(false)

				return
			end

			net.Start("pHistory.RequestSteamId")
			net.WriteString(iSteamId64)
			net.SendToServer()

			self:AlertHeader("Searching...", "icon16/magnifier.png", Color(225, 225, 225), function() end)
		else
			self:AlertHeader("You entered an invalid SteamID", "icon16/exclamation.png", Color(255, 0, 0))
		end
	end

	self.searchSteamIdButton = vgui.Create("pHistoryButton", self.mainContainer)
	self.searchSteamIdButton:SetText("Search SteamID")
	self.searchSteamIdButton:SetSize(self.steamIdSearch:GetWide(), 25)
	self.searchSteamIdButton:SetPos(self:GetWide() / 2 - self.steamIdSearch:GetWide() / 2, 20 + self.steamIdSearch:GetTall() + 5)

	self.searchSteamIdButton.DoClick = function()
		self.steamIdSearch:OnEnter(self.steamIdSearch) -- Just run the OnEnter function since we already have the SteamID filled in
	end

	local headerConnectedPlayers = vgui.Create("DLabel", self.mainContainer)
	headerConnectedPlayers:SetText("Currently Connected Players:")
	headerConnectedPlayers:SetFont("pHistory.warningHeader")
	headerConnectedPlayers:SetTextColor(color_white)
	headerConnectedPlayers:SizeToContents()
	headerConnectedPlayers:SetPos(15, 50 + headerConnectedPlayers:GetTall())

	local connectedPlayersScroll = vgui.Create("DScrollPanel", self.mainContainer)
	connectedPlayersScroll:SetPos(15, 50 + headerConnectedPlayers:GetTall() * 2 + 10)
	connectedPlayersScroll:SetSize(self:GetWide() - 30, self.mainContainer:GetTall() - (50 + headerConnectedPlayers:GetTall() * 2 + 10))

	local List = vgui.Create("DIconLayout", connectedPlayersScroll)
	List:Dock(FILL)

	for _, ply in pairs(player.GetAll()) do
		playerPanel = List:Add("pHistoryPlayerInfo")
		playerPanel:SetSize(connectedPlayersScroll:GetWide(), 40)
		playerPanel:SetPlayer(ply)
		playerPanel.DoClick = function(s)
			self.steamIdSearch:SetValue(ply:SteamID())
		end
	end

	net.Receive("pHistory.RequestSteamId", function()
		-- Remove searching header alert
		local combinedTables = net.ReadTable()

		punishments = combinedTables["punishments"]
		notes = combinedTables["notes"]

		local sSteamId64 = util.SteamIDTo64(self.steamIdSearch:GetValue())

		if punishments[1] == false or notes[1] == false then
			if sSteamId64 ~= self.currentPlySteamId then
				self:AlertHeader("No player history found!", "icon16/error.png", Color(0, 153, 255))
			end
		else
			if sSteamId64 ~= self.currentPlySteamId then
				self:AlertHeader("Loaded player history!", "icon16/magnifier.png", Color(0, 255, 0))
			end
		end

		self.playerInfoContainer:Clear() -- Clear previous entries for new player info
		self:ShowPlayerHistory(punishments, notes, sSteamId64)
		self.currentPlySteamId = sSteamId64

		timer.Simple(3, function()
			-- Go back up
			if !IsValid(self.warningPanel) or !IsValid(self.playerInfoContainer) then return end -- They must have closed the menu

			self.warningPanel:MoveTo(self:GetWide() / 2 - self.warningPanel:GetWide() / 2, -100, 1, 0, -1)
			self.playerInfoContainer:MoveTo(self:GetWide() / 2 - self.playerInfoContainer:GetWide() / 2, 48, 1, 0, -1)
		end)
	end)
end

function PANEL:ShowPlayerHistory(results, notes, sCurrentSteamId)
	local punishmentIdToMainId = {} -- Hacky way that takes the SQL row ID and references the main table's id
	local noteIdToMainId = {} -- Hacky way that takes the SQL row ID and references the main table's id

	self.returnToSearch = vgui.Create("pHistoryButton", self.playerInfoContainer)
	self.returnToSearch:SetText("Search another SteamID")
	self.returnToSearch:SizeToContents()
	self.returnToSearch:SetSize(self.returnToSearch:GetWide(), 40)
	self.returnToSearch:SetPos(self:GetWide() - self.returnToSearch:GetWide() - 15, 5)

	self.returnToSearch.DoClick = function(s)
		self.playerInfoContainer:MoveTo(self:GetWide() / 2 - self.playerInfoContainer:GetWide() / 2, self:GetTall(), 1, 0, -1)
	end

	local headerPunishments = vgui.Create("DLabel", self.playerInfoContainer)
	headerPunishments:SetText("Punishment History:")
	headerPunishments:SetFont("pHistory.warningHeader")
	headerPunishments:SetTextColor(color_white)
	headerPunishments:SizeToContents()
	headerPunishments:SetPos(15, 50 / 2 - headerPunishments:GetTall() / 2)

	local punishmentHistory = vgui.Create("DListView", self.playerInfoContainer)
	punishmentHistory:SetSize(self:GetWide() - 30, self.playerInfoContainer:GetTall() - 350) -- 15px padding each side.
	punishmentHistory:SetPos(15, 50)
	punishmentHistory:AddColumn("ID"):SetFixedWidth(50)
	punishmentHistory:AddColumn("Type"):SetFixedWidth(75)
	punishmentHistory:AddColumn("Admin Issuer"):SetFixedWidth(150)
	punishmentHistory:AddColumn("Reason")
	punishmentHistory:AddColumn("Issued On"):SetFixedWidth(100)

	punishmentHistory.Paint = function(s, w, h)
		draw.RoundedBoxEx(0, 1, 0, s:GetWide() - 2, s:GetTall(), Color(68, 68, 68, 200), true, true)
	end

	punishmentHistory.OnRowRightClick = function(line, lineId)
		line = line:GetLine(lineId)

		local punishmentRefTable = results[punishmentIdToMainId[line:GetColumnText(1)]] -- The main notes table index of the row

		local Menu = DermaMenu()
		Menu:Open()

		Menu:AddOption("Open Admin's Profile", function()
			gui.OpenURL("https://steamcommunity.com/profiles/" .. punishmentRefTable["admin_steamid64"])
		end):SetImage("icon16/user_red.png")

		Menu:AddOption("Copy Reason", function()
			SetClipboardText(punishmentRefTable["reason"])
			self:AlertHeader("Reason copied to clipboard!", "icon16/accept.png", Color(0, 255, 0))
		end):SetImage("icon16/table.png")

		Menu:AddOption("Copy All Info", function()
			SetClipboardText("ID: " .. line:GetColumnText(1) .. " | Type: " .. punishmentRefTable["type"] ..  " | Admin Issuer: " .. punishmentRefTable["admin_nick"] .. " | Reason: " .. punishmentRefTable["reason"])
			self:AlertHeader("Copied entire log to clipboard!", "icon16/accept.png", Color(0, 255, 0))
		end):SetImage("icon16/book.png")
	end

	self.addNoteToPlayer = vgui.Create("pHistoryButton", self.playerInfoContainer)
	self.addNoteToPlayer:SetText("Add Note")
	self.addNoteToPlayer:SizeToContents()
	self.addNoteToPlayer:SetSize(self.returnToSearch:GetWide(), 40)
	self.addNoteToPlayer:SetPos(self:GetWide() - self.returnToSearch:GetWide() - 15, punishmentHistory:GetTall() + 100 - self.addNoteToPlayer:GetTall() - 5)

	self.addNoteToPlayer.DoClick = function(s)
		local addNote = vgui.Create("pHistoryAddNote")
		addNote:SetPlayer(sCurrentSteamId)
	end

	local headerPlayerNotes = vgui.Create("DLabel", self.playerInfoContainer)
	headerPlayerNotes:SetText("Admin Notes:")
	headerPlayerNotes:SetFont("pHistory.warningHeader")
	headerPlayerNotes:SetTextColor(color_white)
	headerPlayerNotes:SizeToContents()
	headerPlayerNotes:SetPos(15, (punishmentHistory:GetTall() + 50) + 10)

	local playerNotes = vgui.Create("DListView", self.playerInfoContainer)
	playerNotes:SetSize(self:GetWide() - 30, self.playerInfoContainer:GetTall() - punishmentHistory:GetTall() - 120)
	playerNotes:SetPos(15, punishmentHistory:GetTall() + 100)
	playerNotes:AddColumn("ID"):SetFixedWidth(50)
	playerNotes:AddColumn("Admin Noted By"):SetFixedWidth(150)
	playerNotes:AddColumn("Note")
	playerNotes:AddColumn("Noted On"):SetFixedWidth(100)

	playerNotes.Paint = function(s, w, h)
		draw.RoundedBoxEx(0, 1, 0, s:GetWide() - 2, s:GetTall(), Color(68, 68, 68, 200), true, true)
	end

	playerNotes.OnRowRightClick = function(line, lineId)
		line = line:GetLine(lineId)

		local noteRefTable = notes[noteIdToMainId[line:GetColumnText(1)]] -- The main notes table index of the row

		local Menu = DermaMenu()
		Menu:Open()

		Menu:AddOption("Open Admin's Profile", function()
			gui.OpenURL("https://steamcommunity.com/profiles/" .. noteRefTable["admin_steamid64"])
		end):SetImage("icon16/user_red.png")

		Menu:AddOption("Copy Note", function()
			SetClipboardText(noteRefTable["reason"])
			self:AlertHeader("Note copied to clipboard!", "icon16/accept.png", Color(0, 255, 0))
		end):SetImage("icon16/table.png")

		Menu:AddOption("Copy All Info", function()
			SetClipboardText("ID: " .. line:GetColumnText(1) .. " | Admin Issuer: " .. noteRefTable["admin_nick"] .. " | Note: " .. noteRefTable["reason"])
			self:AlertHeader("Copied entire log to clipboard!", "icon16/accept.png", Color(0, 255, 0))
		end):SetImage("icon16/book.png")

		Menu:AddOption("Full Display", function()
			Derma_Message("Note by: " .. noteRefTable["admin_nick"] .. "\nNoted on: " .. os.date("%m/%d/%Y", noteRefTable["noted_on"]) .. "\n\n" .. noteRefTable["reason"], "Note Info", "Dismiss")
		end):SetImage("icon16/page.png")

		Menu:AddSpacer()

		if noteRefTable["admin_steamid64"] == LocalPlayer():SteamID64() or pHistory.Config.canDeleteEditNotes[LocalPlayer():GetUserGroup()] then
			Menu:AddOption("Edit Note ", function()
				Derma_StringRequest("Edit Note", "Type a new entry", noteRefTable["reason"], function(text)
					net.Start("pHistory.ModifyNote")
					net.WriteInt(line:GetColumnText(1), 16) -- The note ID for SQL
					net.WriteString(text)
					net.SendToServer()
				end, function(text)
				end)
			end):SetImage("icon16/pencil.png")

			Menu:AddOption("Delete Note", function()
				Derma_Query("Are you sure you want to delete the following note?", "Confirm Deletion", "Yes", function()
					net.Start("pHistory.DeleteNote")
					net.WriteInt(line:GetColumnText(1), 16)
					net.SendToServer()
				end, "No", function()
				end)
			end):SetImage("icon16/table_delete.png")
		end
	end

	if results ~= nil and results ~= false then
		for id, punishment in pairs(results) do
			local addedLine = punishmentHistory:AddLine(punishment["id"], punishment["type"], punishment["admin_nick"], punishment["reason"], os.date("%m/%d/%Y", punishment["issued_on"]))
			punishmentIdToMainId[punishment["id"]] = id
		end
	end

	if notes ~= nil and notes ~= false then
		for id, note in pairs(notes) do
			local playerNote = playerNotes:AddLine(note["id"], note["admin_nick"], note["reason"], os.date("%m/%d/%Y", note["noted_on"]))
			noteIdToMainId[note["id"]] = id
		end
	end

	self:DarkTableView(punishmentHistory) -- Run this at the end since it checks all lines
	self:DarkTableView(playerNotes) -- Run this at the end since it checks all lines
end

function PANEL:DarkTableView(panel)
	if !IsValid(panel) then return end

	for _, line in pairs(panel:GetLines()) do
		function line:Paint(w, h)
			if self:IsHovered() then
				draw.RoundedBoxEx(0, 1, 0, self:GetWide() - 2, self:GetTall(), Color(54, 54, 54, 200), true, true)
			elseif self:IsSelected() then
				draw.RoundedBoxEx(0, 1, 0, self:GetWide() - 2, self:GetTall(), Color(54, 54, 54, 200), true, true)
			end
		end

		-- Text for each of the lines
		for _, column in pairs(line["Columns"]) do
			column:SetFont("pHistory.tableHeader")
			column:SetTextColor(Color(255, 255, 255, 255))
		end
	end

	for _, v in pairs(panel.Columns) do
		function v.Header:Paint(w, h)
			draw.RoundedBoxEx(0, 1, 0, v.Header:GetWide() - 2, v.Header:GetTall(), Color(100, 100, 100, 200), true, true)
		end

		v.Header:SetFont("pHistory.tableHeader")
		v.Header:SetTextColor(Color(255, 255, 255, 255))
	end
end

function PANEL:AlertHeader(sWarning, sIcon, cTextColor, fDismissCondition)
	if !IsValid(self) then return end -- Player must have closed menu while waiting

	local mIcon = Material(sIcon)

	if !self.warningPanel then
		self.warningPanel = vgui.Create("DPanel", self)
		self.warningPanel:SetSize(self:GetWide() * .85, 50)
		self.warningPanel:SetPos(self:GetWide() / 2 - self.warningPanel:GetWide() / 2, - 100)
	end

	self.warningPanel.Paint = function(s, w, h)
		surface.SetDrawColor(pHistory.Config.warningBackground)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(color_white)
		surface.SetMaterial(mIcon)
		surface.DrawTexturedRect(15, 50 / 2 - 16 / 2, 16, 16)

		surface.SetFont("pHistory.warningHeader")
		local _, iWarningH = surface.GetTextSize(sWarning)
		surface.SetTextColor(cTextColor)
		surface.SetTextPos(16 + 15 + 5, 50 / 2 - iWarningH / 2)
		surface.DrawText(sWarning)
	end

	-- Slide down
	self.warningPanel:MoveTo(self:GetWide() / 2 - self.warningPanel:GetWide() / 2, 55, 1, 0, -1, function()
		if fDismissCondition then
			-- We may not want to slide up after 3 seconds since we may be waiting for a response (like searching server)
			fDismissCondition()
		else
			timer.Simple(3, function()
				if !IsValid(self) then return end -- Player must have closed menu while waiting

				-- Go back up
				self.warningPanel:MoveTo(self:GetWide() / 2 - self.warningPanel:GetWide() / 2, -100, 1, 0, -1)
			end)
		end
	end)
end

function PANEL:Paint(iPanelW, iPanelH)
	surface.SetDrawColor(pHistory.Config.menuBackgroundColor)
	surface.DrawRect(0, 0, iPanelW, iPanelH)

	-- Header
	surface.SetDrawColor(pHistory.Config.menuHeaderColor)
	surface.DrawRect(0, 0, iPanelW, 48)

	-- Header accent color
	surface.SetDrawColor(pHistory.Config.menuAccentcolor)
	surface.DrawRect(0, 48 - 5, iPanelW, 5)
	surface.SetFont("pHistory.headerText")

	local iProductNameW, iProductNameH = surface.GetTextSize("pHistory | Player History Manager")
	surface.SetTextPos(iProductNameH / 2, (48 - 5) / 2 - iProductNameH / 2)
	surface.DrawText("pHistory | Player History Manager")
end

vgui.Register("pHistoryMenu", PANEL, "EditablePanel")
