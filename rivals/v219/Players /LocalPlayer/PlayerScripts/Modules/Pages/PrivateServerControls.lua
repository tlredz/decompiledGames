local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local SettingsInfo = require(ReplicatedStorage.Modules.SettingsInfo)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
require(ReplicatedStorage.Modules.Utility)
local PrivateServerController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PrivateServerController"))
require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ComplianceController"))
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local ArcadeController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ArcadeController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local privateServerPlayerSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PrivateServerPlayerSlot")
local settings = Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Settings")
local v = {
	{
		"ArcadeStart",
		"",
		"",
		"Private Arcade",
		"rbxassetid://81276179444570",
		"Launch a private Arcade duel",
		"DropdownConfirm",
		DuelLibrary:GetArcadeModeDisplayNames()[1],
		DuelLibrary:GetArcadeModeDisplayNames(),
		true
	},
	{
		"ArcadeCanPlayAllMaps",
		"",
		"",
		"Play Any Map",
		"rbxassetid://18129688386",
		"Allows you to vote for any map in this duel",
		"Toggle",
		false
	},
	{
		"ArcadeEnd",
		"",
		"",
		"Private Arcade",
		"rbxassetid://81276179444570",
		"End the private Arcade duel",
		"Confirm",
		false
	},
	{
		"FreecamEnabled",
		"",
		"",
		"Freecam Access",
		"rbxassetid://17548980857",
		"Activated by pressing [Shift] + [P]",
		"Dropdown",
		"Everyone",
		{ "Everyone", "Server Owner", "Nobody" }
	},
	{
		"UseLockedWeapons",
		"",
		"",
		"Use Locked Weapons",
		"rbxassetid://17229230506",
		"Allows all players to use locked weapons in duels",
		"Toggle",
		true
	},
	{
		"ShootingRangePVP",
		"",
		"",
		"Shooting Range PVP",
		"rbxassetid://119084789924359",
		"Allows you to battle each other in the Shooting Range",
		"Toggle",
		false
	}
}
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.CloseButton = self.PageFrame:WaitForChild("Close")
	self.LockedFrame = self.PageFrame:WaitForChild("Locked")
	self.List = self.PageFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.PlayersFrame = self.Container:WaitForChild("Players")
	self.PlayersContainer = self.PlayersFrame:WaitForChild("Container")
	self.PlayersLayout = self.PlayersContainer:WaitForChild("Layout")
	self.BannedPlayersFrame = self.Container:WaitForChild("BannedPlayers")
	self.BannedPlayersContainer = self.BannedPlayersFrame:WaitForChild("Container")
	self.BannedPlayersLayout = self.BannedPlayersContainer:WaitForChild("Layout")
	self._setting_objects = {}
	self._player_slots = {}
	self._arcade_mode_display_names = nil
	self._to_arcade_mode_name = nil
	self:_Init()
	return self
end

function object:Open(...)
	Page.Open(self, ...)
	self:_UpdatePlayers()
	self:_UpdateArcadeStatus()
end

function object:_UpdateArcade()
	local arcadeModeDisplayNames, to_arcade_mode_name = DuelLibrary:GetArcadeModeDisplayNames()
	self._arcade_mode_display_names = arcadeModeDisplayNames
	self._to_arcade_mode_name = to_arcade_mode_name
end

function object:_UpdateArcadeStatus()
	if not self:IsOpen() then
		return
	end

	local visible = ArcadeController.CurrentDuel ~= nil
	self._setting_objects.ArcadeStart.SettingFrame.Visible = not visible
	self._setting_objects.ArcadeCanPlayAllMaps.SettingFrame.Visible = not visible
	self._setting_objects.ArcadeEnd.SettingFrame.Visible = visible
end

function object:_CreatePlayerSlot(layoutOrder, parent, p2, text, p3, visible, visible2, visible3)
	local clone = privateServerPlayerSlot:Clone()
	clone.Kick.Visible = visible
	clone.Ban.Visible = visible2
	clone.Unban.Visible = visible3
	clone.Icon.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, p2)
	clone.DisplayName.Controls.Image = ""
	clone.DisplayName.Text = text
	clone.Username.Text = "@" .. p3
	clone.LayoutOrder = layoutOrder
	clone.Parent = parent
	self._player_slots[tostring(p2)] = clone

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		clone.DisplayName.Controls.Position = UDim2.new(0, clone.DisplayName.TextBounds.X, 0.5, 0)
	end

	clone.DisplayName:GetPropertyChangedSignal("TextBounds"):Connect(update)
	update() -- equivalent call inferred; original call site unknown
	ButtonEffect:Add(clone.Kick)
	ButtonEffect:Add(clone.Ban)
	ButtonEffect:Add(clone.Unban)
	return clone
end

function object:_UpdatePlayers()
	if self:IsOpen() then
		local v2 = {}

		for k, object3 in pairs(FighterController.Objects) do
			local player = object3.Player

			if not (CONSTANTS.IS_STUDIO or player ~= Players.LocalPlayer) then
				continue
			end

			v2[tostring(player.UserId)] = true

			if self._player_slots[tostring(player.UserId)] then
				continue
			end

			local _CreatePlayerSlot = self:_CreatePlayerSlot(
				k,
				self.PlayersContainer,
				player.UserId,
				player.DisplayName,
				player.Name,
				CONSTANTS.IS_STUDIO or player ~= Players.LocalPlayer,
				true,
				false
			)
			local player2 = player
			_CreatePlayerSlot.Kick.MouseButton1Click:Connect(function()
				PrivateServerController:ServerKick(player2)
			end)
			local player3 = player
			_CreatePlayerSlot.Ban.MouseButton1Click:Connect(function()
				PrivateServerController:ServerBan(player3)
			end)
		end

		for k, list in pairs(PrivateServerController.BannedPlayers) do
			local v3, v4, v5 = table.unpack(list)
			v2[tostring(v3)] = true

			if self._player_slots[tostring(v3)] then
				continue
			end

			local v6 = v3
			self:_CreatePlayerSlot(k, self.BannedPlayersContainer, v3, v4, v5, false, false, true).Unban.MouseButton1Click:Connect(function()
				ReplicatedStorage.Remotes.PrivateServer.UnbanPlayer:FireServer(v6)
			end)
		end

		local v3 = {}

		for k, _player_slot in pairs(self._player_slots) do
			if v2[k] then
				continue
			end

			v3[k] = true
			_player_slot:Destroy()
		end

		for k in pairs(v3) do
			self._player_slots[k] = nil
		end
	else
		for _, _player_slot in pairs(self._player_slots) do
			_player_slot:Destroy()
		end

		self._player_slots = {}
	end
end

function object:_Setup()
	for k, list in pairs(v) do
		local v2 = list[1]
		local v3 = SettingsInfo.new(select(2, table.unpack(list)))
		require(settings:WaitForChild(v3.InputType))
		local module = require(settings:WaitForChild(v3.InputType))
		local v4 = module.new(v3)
		v4.SettingFrame.LayoutOrder = k
		v4.SettingFrame.Parent = self.Container
		self._setting_objects[v2] = v4
	end

	self._setting_objects.UseLockedWeapons.Replicate:Connect(function(p)
		ReplicatedStorage.Remotes.PrivateServer.SetUseLockedWeapons:FireServer(p or false)
	end)
	self._setting_objects.ShootingRangePVP.Replicate:Connect(function(p)
		ReplicatedStorage.Remotes.PrivateServer.SetShootingRangePVP:FireServer(p or false)
	end)
	self._setting_objects.FreecamEnabled.Replicate:Connect(function(p)
		ReplicatedStorage.Remotes.PrivateServer.SetFreecamEnabled:FireServer(p)
	end)
	self._setting_objects.ArcadeCanPlayAllMaps.Replicate:Connect(function(p)
		ReplicatedStorage.Remotes.PrivateServer.SetArcadeCanPlayAllMaps:FireServer(p)
	end)
	self._setting_objects.ArcadeStart.Replicate:Connect(function(p)
		self:_UpdateArcade()
		ReplicatedStorage.Remotes.PrivateServer.StartArcadeMode:FireServer(self._to_arcade_mode_name[p])
	end)
	self._setting_objects.ArcadeEnd.Replicate:Connect(function()
		ReplicatedStorage.Remotes.PrivateServer.EndArcadeMode:FireServer()
	end)
	self._setting_objects.ArcadeEnd:SetConfirmColor("Red")
	self._setting_objects.ArcadeCanPlayAllMaps:Scale(0.95)
	local IS_PRIVATE_SERVER_OWNER = CONSTANTS.IS_PRIVATE_SERVER_OWNER(Players.LocalPlayer.UserId)
	self.LockedFrame.Visible = not IS_PRIVATE_SERVER_OWNER
	self.List.Visible = IS_PRIVATE_SERVER_OWNER
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
		self.List.Active = self.Layout.AbsoluteContentSize.Y >= self.List.AbsoluteSize.Y
	end)
	self.PlayersLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.PlayersFrame.Size = UDim2.new(1, 0, 0, self.PlayersLayout.AbsoluteContentSize.Y)
	end)
	self.PlayersFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self.PlayersFrame.Visible = self.PlayersFrame.AbsoluteSize.Y > 0
	end)
	self.BannedPlayersLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.BannedPlayersFrame.Size = UDim2.new(1, 0, 0, self.BannedPlayersLayout.AbsoluteContentSize.Y)
	end)
	self.BannedPlayersFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self.BannedPlayersFrame.Visible = self.BannedPlayersFrame.AbsoluteSize.Y > 0
	end)
	FighterController.ObjectAdded:Connect(function()
		self:_UpdatePlayers()
	end)
	FighterController.ObjectRemoved:Connect(function()
		self:_UpdatePlayers()
	end)
	PrivateServerController.BannedPlayersChanged:Connect(function()
		self:_UpdatePlayers()
	end)
	ArcadeController.DuelSet:Connect(function()
		self:_UpdateArcadeStatus()
	end)
	self:_Setup()
	self:_UpdateArcade()
	ButtonEffect:Add(self.CloseButton)
end

return object._new()