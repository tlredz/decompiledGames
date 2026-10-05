local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SettingsLibrary = require(ReplicatedStorage.Modules.SettingsLibrary)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local SettingsController = require(Players.LocalPlayer.PlayerScripts.Controllers.SettingsController)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local PlayerListSlot = require(script:WaitForChild("PlayerListSlot"))
local options = SettingsLibrary.Info["PlayerList Leaderstat"].Options
local v = { "rbxassetid://17094014569", "rbxassetid://112281518716191", "rbxassetid://117835427046796" }
local Elements = {}
Elements.__index = Elements

function Elements.new(playerList)
	local self = setmetatable({}, Elements)
	self.PlayerListSlotAdded = Signal.new()
	self.PlayerListSlotRemoved = Signal.new()
	self.PlayerList = playerList
	self.Frame = self.PlayerList.Container:WaitForChild("Elements")
	self.Container = self.Frame:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.TopFrame = self.Container:WaitForChild("Top")
	self.TopCloseButton = self.TopFrame:WaitForChild("Close")
	self.TopLeaderstatFrame = self.TopFrame:WaitForChild("Leaderstat")
	self.TopLeaderstatIcon = self.TopLeaderstatFrame:WaitForChild("Icon")
	self.TopLeaderstatButton = self.TopLeaderstatFrame:WaitForChild("Button")
	self.MiddleFrame = self.Container:WaitForChild("Middle")
	self.MiddleList = self.MiddleFrame:WaitForChild("List")
	self.MiddleContainer = self.MiddleList:WaitForChild("Container")
	self.MiddleLayout = self.MiddleContainer:WaitForChild("Layout")
	self.BottomFrame = self.Container:WaitForChild("Bottom")
	self.PlayerListSlots = {}
	self._leaderstat_name = nil
	self:_Init()
	return self
end

function Elements.GetPlayerListSlot(p, p2)
	for k, playerListSlot in pairs(p.PlayerListSlots) do
		if k.Player == p2 then
			return playerListSlot
		end
	end
end

function Elements:SetLeaderstat(leaderstat_name)
	if leaderstat_name == self._leaderstat_name then
		return
	end

	self._leaderstat_name = leaderstat_name
	self.TopLeaderstatIcon.Image = v[table.find(options, self._leaderstat_name)] or ""

	for _, playerListSlot in pairs(self.PlayerListSlots) do
		playerListSlot:SetLeaderstat(self._leaderstat_name)
	end
end

function Elements:OnOpened()
	self.PlayerList:AddOpenedConnection(self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateVisuals()
	end))
	self.PlayerList:AddOpenedConnection(self.MiddleLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateVisuals()
	end))
	self.PlayerList:AddOpenedConnection(self.PlayerList.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateVisuals()
	end))
	self.PlayerList:AddOpenedConnection(self.BottomFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateVisuals()
	end))
	self.PlayerList:AddOpenedConnection(self.TopFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateVisuals()
	end))
	self.PlayerList:AddOpenedConnection(PlayerDataController:GetSettingChangedSignal("PlayerList Leaderstat"):Connect(function()
		self:_UpdateLeaderstatFromSetting()
	end))
	self.PlayerList:AddOpenedConnection(FighterController.ObjectRemoved:Connect(function(p)
		self:_FighterRemoved(p)
	end))
	self.PlayerList:AddOpenedConnection(FighterController.ObjectAdded:Connect(function(p)
		self:_FighterAdded(p)
	end))
	self:_UpdateVisuals()
	self:_UpdateLeaderstatFromSetting()

	for k, playerListSlot in pairs(self.PlayerListSlots) do
		if k.Player:IsDescendantOf(Players) then
			playerListSlot:OnOpened()
		else
			task.spawn(self._FighterRemoved, self, k)
		end
	end

	for _, object2 in pairs(FighterController.Objects) do
		if not self.PlayerListSlots[object2] then
			task.spawn(self._FighterAdded, self, object2)
		end
	end
end

function Elements:_UpdateLeaderstatFromSetting()
	local setting = PlayerDataController:GetSetting("PlayerList Leaderstat")

	if not table.find(options, setting) then
		setting = options[1]
	end

	self:SetLeaderstat(setting)
end

function Elements:_UpdateVisuals()
	self.MiddleList.CanvasSize = UDim2.new(0, 0, 0, self.MiddleLayout.AbsoluteContentSize.Y)
	self.MiddleFrame.Size = UDim2.new(
		1,
		0,
		0,
		(math.min(
			self.MiddleLayout.AbsoluteContentSize.Y,
			self.PlayerList.Frame.AbsoluteSize.Y - self.TopFrame.AbsoluteSize.Y - self.BottomFrame.AbsoluteSize.Y
		))
	)
	self.Frame.Size = UDim2.new(1, 0, 0, self.Layout.AbsoluteContentSize.Y)
end

function Elements:_FighterRemoved(p2)
	local playerListSlot = self.PlayerListSlots[p2]

	if not playerListSlot then
		return
	end

	playerListSlot:Destroy()
	self.PlayerListSlots[p2] = nil
	self.PlayerListSlotRemoved:Fire(playerListSlot)
end

function Elements:_FighterAdded(p)
	self:_FighterRemoved(p)

	if not p.Player then
		return
	end

	local v2 = PlayerListSlot.new(self, p)
	v2:SetLeaderstat(self._leaderstat_name)
	v2:SetParent(self.MiddleContainer)
	self.PlayerListSlots[p] = v2
	self.PlayerListSlotAdded:Fire(v2)
end

function Elements:_Init()
	self.TopCloseButton.MouseButton1Click:Connect(function()
		self.PlayerList:SetClosedByInputs(true)
	end)
	self.TopLeaderstatButton.MouseButton1Click:Connect(function()
		SettingsController:ChangeSetting(
			"PlayerList Leaderstat",
			options[(table.find(options, self._leaderstat_name) or 0) % #options + 1]
		)
	end)
	ButtonEffect:Add(self.TopCloseButton, true)
	ButtonEffect:Add(self.TopLeaderstatButton, true)
end

return Elements