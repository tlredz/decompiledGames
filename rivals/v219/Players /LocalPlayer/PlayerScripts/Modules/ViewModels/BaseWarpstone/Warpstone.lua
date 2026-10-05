local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local BaseWarpstone = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseWarpstone)
local object = setmetatable({}, BaseWarpstone)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseWarpstone.new(...), object)
	self:_Init()
	return self
end

function object:_Init()
	task.defer(function()
		self.ClientItem.ProjectileThrown:Connect(function(p, _)
			self:_PlayWarpstoneSounds(
				Utility:CreateSound("rbxassetid://115283360430297", 0.5, 1 + 0.125 * math.random(), p, true),
				Utility:CreateSound("rbxassetid://115283360430297", 0.375, 1.5 + 0.25 * math.random(), p, true)
			)
		end)
	end)
end

return object