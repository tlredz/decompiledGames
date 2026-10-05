local createVector = vector.create
local v = {
	"rbxassetid://8313797644",
	"rbxassetid://8313742436",
	"rbxassetid://8313749259",
	"rbxassetid://8313756846",
	"rbxassetid://8313761878",
	"rbxassetid://8313768156",
	"rbxassetid://8313773106",
	"rbxassetid://8313780127",
	"rbxassetid://8314338712",
	"rbxassetid://8314340888",
	"rbxassetid://8314344719",
	"rbxassetid://8314350294",
	""
}

for k, v2 in pairs(v) do
	local Graphics = require(game.ReplicatedStorage.Util.Graphics)
	v[k] = Graphics.ScaleDown(v2)
end

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local wind = FX:WaitForChild("SoulGuitarEffects").Wind
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor

local function WindWave(vector2: Vector3, p: number, p2: number, color: Color3?)
	local clone = wind:Clone()
	clone.Orientation = Vector3.new(clone.Orientation.X, math.random(-180, 180), clone.Orientation.Z)
	clone.Position = vector2 + createVector(0, 1.5, 0)
	clone.Mesh.Scale = createVector(1, 1, 1) * p
	clone.Parent = _WorldOrigin
	clone.Decal.Transparency = 0.8
	local decal = clone.Decal
	local Graphics = require(game.ReplicatedStorage.Util.Graphics)
	decal.Texture = Graphics.ScaleDown("rbxassetid://8313725039")
	clone.Decal.Color3 = color or Color3.fromRGB(255, 255, 255)
	TweenService:Create(clone.Mesh, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Scale = createVector(1, 1.2, 1) * p2
	}):Play()
	TweenService:Create(clone, TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1), {
		Orientation = clone.Orientation + createVector(0, 360, 0)
	}):Play()
	task.spawn(function()
		task.wait(0.25)

		for _, texture in ipairs(v) do
			clone.Decal.Texture = texture
			task.wait(0.0485)
		end
	end)
	heartbeatLoopFor2(1, function(_, _, p3)
		clone.Decal.Transparency = 0.8 + 0.2 * p3
	end)
	task.delay(2, function()
		clone:Destroy()
	end)
end

return WindWave