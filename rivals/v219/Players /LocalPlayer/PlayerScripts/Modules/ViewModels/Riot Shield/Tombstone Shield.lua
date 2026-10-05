local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.BetterDebris)
local RiotShield = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ViewModels"):WaitForChild("Riot Shield"))
local object = setmetatable({}, RiotShield)
object.__index = object

function object.new(...)
	local self = setmetatable(RiotShield.new(...), object)
	self:_Init()
	return self
end

function object.AbsorbedHit(object2)
	object2:CreateSound("rbxassetid://126398565710312", 1, 0.9 + 0.2 * math.random(), true, 5)
end

function object.ShieldBroken(object2)
	object2:CreateSound("rbxassetid://90752806876857", 1, 0.9 + 0.2 * math.random(), true, 5)
end

function object:_Init() end

return object