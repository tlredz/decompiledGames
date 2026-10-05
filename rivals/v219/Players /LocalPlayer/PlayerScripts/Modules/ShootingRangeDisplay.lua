local Players = game:GetService("Players")
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local TeammateSlot = require(Players.LocalPlayer.PlayerScripts.Modules.TeammateSlot)
local shootingRangeGui = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("ShootingRangeGui")
local ShootingRangeDisplay = {}
ShootingRangeDisplay.__index = ShootingRangeDisplay

function ShootingRangeDisplay.new(part)
	local self = setmetatable({}, ShootingRangeDisplay)
	self.SurfaceGui = shootingRangeGui:Clone()
	self._part = part
	self._connections = {}
	self._is_enabled = false
	self._teammate_slots = {}
	self:_Init()
	return self
end

function ShootingRangeDisplay:SetEnabled(is_enabled)
	if is_enabled == self._is_enabled then
		return
	end

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}
	self._is_enabled = is_enabled

	if not self._is_enabled then
		self:_GeneratePlayers()
		return
	end

	table.insert(self._connections, FighterController.ObjectRemoved:Connect(function()
		self:_GeneratePlayers()
	end))

	local function client_fighter_added(object2, p)
		table.insert(self._connections, object2:GetDataChangedSignal("IsInShootingRange"):Connect(function()
			self:_GeneratePlayers()
		end))

		if not p then
			self:_GeneratePlayers()
		end
	end

	table.insert(self._connections, FighterController.ObjectAdded:Connect(client_fighter_added))

	for _, object2 in pairs(FighterController.Objects) do
		table.insert(self._connections, object2:GetDataChangedSignal("IsInShootingRange"):Connect(function()
			self:_GeneratePlayers()
		end))
	end

	self:_GeneratePlayers()
end

function ShootingRangeDisplay:Destroy()
	self:SetEnabled(false)
	self.SurfaceGui:Destroy()
end

function ShootingRangeDisplay:_GeneratePlayers()
	for _, _teammate_slot in pairs(self._teammate_slots) do
		_teammate_slot:Destroy()
	end

	self._teammate_slots = {}
	self.SurfaceGui.Title.Position = UDim2.new(0.5, 0, 0.5, 0)
	self.SurfaceGui.Title.Size = UDim2.new(0.25, 0, 0.4, 0)

	if not self._is_enabled then
		return
	end

	for _, object in pairs(FighterController.Objects) do
		if not object:Get("IsInShootingRange") then
			continue
		end

		local statisticDuelsWinStreak = object.Player:GetAttribute("StatisticDuelsWinStreak") or 0
		local v = TeammateSlot.new(
			object.Player.UserId,
			object:Get("Controls"),
			1,
			false,
			false,
			statisticDuelsWinStreak,
			object.Player:GetAttribute("Level")
		)
		v.SlotFrame.LayoutOrder = -statisticDuelsWinStreak
		v.SlotFrame.Parent = self.SurfaceGui.Players
		table.insert(self._teammate_slots, v)
	end

	if #self._teammate_slots > 0 then
		self.SurfaceGui.Title.Position = UDim2.new(0.5, 0, 0.375, 0)
		self.SurfaceGui.Title.Size = UDim2.new(0.5, 0, 0.1, 0)
	end
end

function ShootingRangeDisplay:_Setup()
	self.SurfaceGui.Adornee = self._part
	self.SurfaceGui.Parent = Players.LocalPlayer.PlayerGui
end

function ShootingRangeDisplay:_Init()
	self:_Setup()
end

return ShootingRangeDisplay