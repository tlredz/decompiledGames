local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Signal = require(ReplicatedStorage.Modules.Signal)
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local ScoreboardPlayerSlot = require(script:WaitForChild("ScoreboardPlayerSlot"))
local banIcon = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("BanIcon")
local Scoreboard = {}
Scoreboard.__index = Scoreboard

function Scoreboard.new(duelInterface)
	local self = setmetatable({}, Scoreboard)
	self.VisibilityChanged = Signal.new()
	self.DuelInterface = duelInterface
	self.Frame = self.DuelInterface.Frame:WaitForChild("Scoreboard")
	self.Container = self.Frame:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.TopFrame = self.Container:WaitForChild("Top")
	self.TopBackground = self.TopFrame:WaitForChild("Background")
	self.TopText = self.TopFrame:WaitForChild("Score")
	self.BottomFrame = self.Container:WaitForChild("Bottom")
	self.BottomBackground = self.BottomFrame:WaitForChild("Background")
	self.BottomInformationText = self.BottomFrame:WaitForChild("Information")
	self.ButtonsFrame = self.Container:WaitForChild("Buttons")
	self.ButtonsContainer = self.ButtonsFrame:WaitForChild("Container")
	self.BannedWeaponsFrame = self.Container:WaitForChild("BannedWeapons")
	self.BannedWeaponsContainer = self.BannedWeaponsFrame:WaitForChild("Container")
	self.PlayersFrame = self.Container:WaitForChild("Players")
	self.PlayersBottomFade = self.PlayersFrame:WaitForChild("BottomFade")
	self.PlayersTopFade = self.PlayersFrame:WaitForChild("TopFade")
	self.PlayersList = self.PlayersFrame:WaitForChild("List")
	self.PlayersContainer = self.PlayersList:WaitForChild("Container")
	self.PlayersLayout = self.PlayersContainer:WaitForChild("Layout")
	self._destroyed = false
	self._scoreboard_open = false
	self._scoreboard_player_slots = {}
	self._scoreboard_local_player_slot = nil
	self._neutral_team_color_index = 0
	self._banned_weapon_icons = {}
	self:_Init()
	return self
end

function Scoreboard:IsOpen()
	return not self._destroyed and self.Frame.Visible
end

function Scoreboard:GetTeamColor(p2)
	local teamColor = DuelLibrary:GetTeamColor(p2)

	if p2 then
		return teamColor
	end

	local HSV, v, v2 = teamColor:ToHSV()
	self._neutral_team_color_index += 1
	local v3 = v2 - (self._neutral_team_color_index % 2 == 0 and 0.05 or 0)
	return Color3.fromHSV(HSV, v, v3)
end

function Scoreboard:GetBackgroundTransparency()
	return 0 + 0.25 * GuiService.PreferredTransparency
end

function Scoreboard:Open(_scoreboard_open)
	if self._destroyed then
		return
	end

	if _scoreboard_open == nil then
		_scoreboard_open = self._scoreboard_open
	end

	self._scoreboard_open = _scoreboard_open
	self.Frame.Visible = self._scoreboard_open and not (self.DuelInterface:IsPageOpen() or self.DuelInterface.Voting:IsOpen()) and not self.DuelInterface.FinalResults:IsActive() and self.DuelInterface.ClientDuel:Get("Status") ~= "GameOver"
	self.VisibilityChanged:Fire()
	self:Generate()
end

function Scoreboard:UpdatePreferredTransparency()
	local backgroundTransparency = self:GetBackgroundTransparency()
	self.TopBackground.ImageTransparency = backgroundTransparency
	self.BottomBackground.ImageTransparency = backgroundTransparency

	for _, _scoreboard_player_slot in pairs(self._scoreboard_player_slots) do
		_scoreboard_player_slot:UpdatePreferredTransparency(backgroundTransparency)
	end
end

function Scoreboard:Generate()
	for _, _scoreboard_player_slot in pairs(self._scoreboard_player_slots) do
		_scoreboard_player_slot:Destroy()
	end

	for _, _banned_weapon_icon in pairs(self._banned_weapon_icons) do
		_banned_weapon_icon:Destroy()
	end

	self._banned_weapon_icons = {}
	self._scoreboard_player_slots = {}
	self._scoreboard_local_player_slot = nil
	self._neutral_team_color_index = 0

	if self._destroyed or not self.Frame.Visible then
		return
	end

	local playSourceName = self.DuelInterface.ClientDuel:Get("PlaySourceName")
	local displayName = playSourceName and DuelLibrary.PlaySources[playSourceName].DisplayName
	local name = self.DuelInterface.ClientDuel.Map and self.DuelInterface.ClientDuel.Map.Name
	local scoreboardDisplay = self.DuelInterface.ClientDuel.Map and self.DuelInterface.ClientDuel.Map:GetScoreboardDisplay()
	local bottomInformationText = self.BottomInformationText

	if scoreboardDisplay then
		name = scoreboardDisplay
	elseif (not name or not displayName or name ~= displayName) and (not name or displayName) then
		if displayName and name then
			name = string.format("%s   •   %s", displayName, name)
		else
			name = (not displayName or name) and "" or displayName
		end
	end

	bottomInformationText.Text = name
	local currentSubject = SpectateController.CurrentSubject
	local weaponPool = currentSubject and currentSubject:Get("WeaponPool")

	if (currentSubject and currentSubject:Get("WeaponPoolFilterType")) == "Blacklist" and #weaponPool > 0 and not self.DuelInterface.ClientDuel:Get("ArcadeMode") then
		self.BannedWeaponsFrame.Visible = true

		for k, v in pairs(weaponPool) do
			local clone = banIcon:Clone()
			clone.ImageColor3 = Color3.fromRGB(127, 25, 25)
			clone.Icon.ImageColor3 = Color3.fromRGB(255, 50, 50)
			clone.LayoutOrder = k
			clone.Weapon.Icon.Image = ItemLibrary.ViewModels[v].ImageCentered or ItemLibrary.Items[v].Image
			clone.Weapon.ZIndex = 10
			clone.Weapon.Visible = true
			clone.Parent = self.BannedWeaponsContainer
			table.insert(self._banned_weapon_icons, clone)
		end
	else
		self.BannedWeaponsFrame.Visible = false
	end

	local loggedClientDuelers = self.DuelInterface:GetLoggedClientDuelers(true)

	for k, loggedClientDueler in pairs(loggedClientDuelers) do
		local _scoreboard_player_slot = self._scoreboard_player_slots[loggedClientDueler]

		if _scoreboard_player_slot then
			_scoreboard_player_slot.Frame.LayoutOrder = k
			_scoreboard_player_slot:Update()
		else
			local scoreboard_local_player_slot = ScoreboardPlayerSlot.new(self, loggedClientDueler)
			scoreboard_local_player_slot.Frame.LayoutOrder = k
			scoreboard_local_player_slot.Frame.Parent = self.PlayersContainer
			self._scoreboard_player_slots[loggedClientDueler] = scoreboard_local_player_slot

			if loggedClientDueler.IsLocalPlayer then
				self._scoreboard_local_player_slot = scoreboard_local_player_slot
			end
		end
	end

	local v = {}

	for k, _scoreboard_player_slot in pairs(self._scoreboard_player_slots) do
		if table.find(loggedClientDuelers, k) then
			continue
		end

		_scoreboard_player_slot:Destroy()
		v[k] = true

		if k.IsLocalPlayer then
			self._scoreboard_local_player_slot = nil
		end
	end

	for k in pairs(v) do
		self._scoreboard_player_slots[k] = nil
	end
end

function Scoreboard:Destroy()
	self._destroyed = true

	for _, _scoreboard_player_slot in pairs(self._scoreboard_player_slots) do
		_scoreboard_player_slot:Destroy()
	end

	self._scoreboard_player_slots = {}
	self._scoreboard_local_player_slot = nil
	self.VisibilityChanged:Destroy()
end

function Scoreboard:_UpdateFade()
	local v = self.PlayersFrame.AbsoluteSize.X * 0.2
	local v2 = math.max(
		0,
		self.PlayersList.AbsoluteCanvasSize.Y - self.PlayersList.AbsoluteWindowSize.Y - 5 - self.PlayersList.CanvasPosition.Y
	)
	local v3 = math.max(0, self.PlayersList.CanvasPosition.Y - 5)
	local v4 = math.clamp(1 - v2 / v, 0, 1)
	local v5 = math.clamp(1 - v3 / v, 0, 1)
	self.PlayersBottomFade.BackgroundTransparency = v4 * 0.5 + 0.5
	self.PlayersTopFade.BackgroundTransparency = v5 * 0.5 + 0.5
	self.PlayersList.ClipsDescendants = math.abs(self.PlayersList.AbsoluteCanvasSize.Y - self.PlayersList.AbsoluteWindowSize.Y) > 5
end

function Scoreboard:_UpdateLayout()
	local v = (self.DuelInterface.Frame.AbsoluteSize.Y - (self.Layout.AbsoluteContentSize.Y - self.PlayersFrame.AbsoluteSize.Y)) * 0.5
	self.PlayersFrame.Size = UDim2.new(1, 0, 0, (math.min(self.PlayersLayout.AbsoluteContentSize.Y, v)))
	self.PlayersList.CanvasSize = UDim2.new(0, 0, 0, self.PlayersLayout.AbsoluteContentSize.Y)
end

function Scoreboard:_UpdateButtonsVisibility()
	self.ButtonsFrame.Visible = #self.ButtonsContainer:GetChildren() > 0
end

function Scoreboard:_Setup()
	self.TopText.Text = SHOW_WEAPON_IN_GUNGAME and self.DuelInterface.ClientDuel:Get("IsGunGame") and "WEAPON" or self.DuelInterface.ClientDuel:Get("ScoresBehavior") == "Duelers" and "POINTS" or "DMG"
end

function Scoreboard:_Init()
	self.PlayersFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateLayout()
		self:_UpdateFade()
	end)
	self.PlayersLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateLayout()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateLayout()
	end)
	self.DuelInterface.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateLayout()
	end)
	self.PlayersList:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		self:_UpdateFade()
	end)
	self.PlayersList:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
		self:_UpdateFade()
	end)
	self.PlayersList:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
		self:_UpdateFade()
	end)
	self.DuelInterface.FinalResults.Activated:Connect(function()
		self:Open(nil)
	end)
	self.DuelInterface.Voting.VisibilityChanged:Connect(function()
		self:Open(nil)
	end)
	self.ButtonsContainer.ChildAdded:Connect(function()
		self:_UpdateButtonsVisibility()
	end)
	self.ButtonsContainer.ChildRemoved:Connect(function()
		self:_UpdateButtonsVisibility()
	end)
	self:_Setup()
	self:_UpdateLayout()
	self:_UpdateButtonsVisibility()
end

return Scoreboard