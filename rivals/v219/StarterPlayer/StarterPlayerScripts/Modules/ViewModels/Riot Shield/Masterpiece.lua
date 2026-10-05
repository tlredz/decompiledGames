local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.BetterDebris)
local RiotShield = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ViewModels"):WaitForChild("Riot Shield"))
local v = {
	{ "rbxassetid://105059726931047", "rbxassetid://79914271483818" },
	{ "rbxassetid://77461546699017", "rbxassetid://76552313877907" }
}
local object = setmetatable({}, RiotShield)
object.__index = object

function object.new(...)
	local self = setmetatable(RiotShield.new(...), object)
	self._painting_data = v[math.random(#v)]
	self:_Init()
	return self
end

function object:GetImage()
	return self._painting_data[2]
end

function object.AbsorbedHit(object2)
	object2:CreateSound("rbxassetid://134671375134755", 1, 0.9 + 0.2 * math.random(), true, 5)
end

function object:_Setup()
	local decal = self.ItemModel:WaitForChild("Body"):WaitForChild("Canvas"):WaitForChild("Decal")
	decal.Texture = self._painting_data[1]
end

function object:_Init()
	self:_Setup()
end

return object