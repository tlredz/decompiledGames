require(game.ReplicatedStorage.DungeonShared)
local RunService = game:GetService("RunService")
RunService:IsServer()
local Maid = require(game.ReplicatedStorage.Util.Maid)
local RunService2 = game:GetService("RunService")
local isClient = RunService2:IsClient()
local Util = require(game.ReplicatedStorage.DungeonShared.MapComponents.Util)
local Component = require(game.ReplicatedStorage.Modules.Component)
local new = Component.new
local v = {
	Tag = "WallGearProp",
	Ancestors = { workspace.Map },
	Extensions = 0
}
local BaseMapComponent = require(script.Parent.BaseMapComponent)
v.Extensions = { BaseMapComponent }
local v2 = new(v)

function v2:Start()
	self.Maid = Maid.new()
	assert(self.Maid)
	local v3 = assert(self.Instance)

	if not isClient then
		self.Instance:SetAttribute("Speed", 0)
		return
	end

	local v4 = 0
	Util.handleAttribute(v3, "Speed", function(value)
		v4 = value or 0
	end)
	local propMotor = assert(v3.PrimaryPart):WaitForChild("PropMotor", 120)
	local maid = self.Maid
	local RunService3 = game:GetService("RunService")
	maid:GiveTask(RunService3.Heartbeat:Connect(function(dt)
		propMotor.C0 *= CFrame.Angles(1.5707963267948966 * dt * v4, 0, 0)
	end))
end

function v2:Stop()
	if self.Maid then
		self.Maid:DoCleaning()
		self.Maid = nil
	end
end

return v2