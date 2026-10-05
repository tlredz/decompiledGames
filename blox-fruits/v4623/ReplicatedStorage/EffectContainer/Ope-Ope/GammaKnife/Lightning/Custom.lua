local createVector = vector.create

local function xzAim(p, p2)
	return CFrame.new(p, p2 * createVector(1, 0, 1) + Vector3.new(0, p.Y))
end

game:GetService("RunService")
workspace:WaitForChild("_WorldOrigin")
local util = game.ReplicatedStorage.Util
require(util.Debris)
require(game.ReplicatedStorage.Effect)
require(util.Tween)
require(util.LightningBolt.LightningExplosion)
local LightningBolt = require(util.LightningBolt)
local LightningSparks = require(util.LightningBolt.LightningSparks)

local function Bolt(p, p2, number, number2, thickness, p3, p4, p5, p6)
	Random.new()
	local v = LightningBolt.new(p, p2, number, number2, p3, p5)
	v.PulseLength = 1 / (0.5 * p4)
	v.FadeLength = 1 / (0.6 * p4)
	v.PulseSpeed = 1 / (0.4 * p4)
	v.MinThicknessMultiplier = 0.5
	v.MaxThicknessMultiplier = 0.75
	v.AnimationSpeed = 8
	v.Thickness = thickness
	v.AddTransparency = 0.1

	if p6 then
		LightningSparks.new(v, p3)
	end
end

return function(list)
	local v, v2, v3, v4, v5 = unpack(list)
	local v6 = v4 or 1
	local number = Random.new():NextNumber(v6 * 0.25, v6)
	local v7 = math.clamp((v2.WorldPosition - v.WorldPosition).Magnitude / 5, 3, 8)
	local number2 = Random.new():NextNumber(v7 * 0.75, v7 * 2)

	for i = 0, 1 do
		local color = math.random(2) == 1 and Color3.new() or Color3.new(1, 1, 1)
		local v8 = i == 1 and v3 or color
		Bolt(v, v2, number2, number2, number, v7 * 2, v5, v8, true)
	end
end