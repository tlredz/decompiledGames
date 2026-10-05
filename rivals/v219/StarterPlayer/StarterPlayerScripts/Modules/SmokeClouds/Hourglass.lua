local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local SmokeCloud = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("SmokeCloud"))
local object = setmetatable({}, SmokeCloud)
object.__index = object

function object.new(...)
	local self = setmetatable(SmokeCloud.new(...), object)
	self:_Init()
	return self
end

function object:Update(p)
	if SmokeCloud.Update(self, p) then
		return
	end

	self.Model:PivotTo(CFrame.new(self._position_spring.Value, workspace.CurrentCamera.CFrame.Position) * CFrame.Angles(
		-self._spin,
		0,
		0
	))
end

function object._CreateIdleSound(_)
	return Utility:CreateSound("rbxassetid://94857514154727", 2, 1, nil, true)
end

function object:_Init() end

return object