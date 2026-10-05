local Players = game:GetService("Players")
local ClientViewModel = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientFighter"):WaitForChild("ClientItem"):WaitForChild("ClientViewModel"))
local object = setmetatable({}, ClientViewModel)
object.__index = object

function object.new(...)
	local self = setmetatable(ClientViewModel.new(...), object)
	self:_Init()
	return self
end

function object:_UpdateAnimationState()
	local v = self.ClientItem:Get("NumReloadsSoFar") % 2 + 1
	local v2 = v == 1 and "Equip" or "State2Equip"
	local v3 = v == 1 and "Idle" or "State2Idle"
	local v4 = v == 1 and "Sprint" or "State2Sprint"
	local v5 = v == 1 and "Inspect" or "State2Inspect"
	local v6 = v == 1 and "Shoot" or "State2Shoot"
	self:ChangeEquipAnimation(v2)
	self:ChangeIdleAnimation(v3)
	self:ChangeSprintAnimation(v4)
	self:ChangeInspectAnimation(v5)
	self.ClientItem:ChangeShootAnimationNamePrefix(v6)
end

function object:_Init()
	self.ClientItem:GetDataChangedSignal("NumReloadsSoFar"):Connect(function()
		self:_UpdateAnimationState()
	end)
	task.defer(self._UpdateAnimationState, self)
end

return object