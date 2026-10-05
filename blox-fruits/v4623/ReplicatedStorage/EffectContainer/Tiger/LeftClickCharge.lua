local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
local v = {
	"rbxassetid://9671078793",
	"rbxassetid://9671078446",
	"rbxassetid://9671078083",
	"rbxassetid://9671077754",
	"rbxassetid://9671077456",
	"rbxassetid://9671077179",
	"rbxassetid://9671076884",
	"rbxassetid://9671076664",
	"rbxassetid://9671076277",
	"rbxassetid://9671075851",
	"rbxassetid://9671075522",
	"rbxassetid://9671075035",
	"rbxassetid://9671074596",
	""
}

for k, v2 in pairs(v) do
	local Graphics = require(game.ReplicatedStorage.Util.Graphics)
	v[k] = Graphics.ScaleDown(v2)
end

Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
local inverse = CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local M1 = FX:WaitForChild("TigerEffects").M1
local slashPart = FX:WaitForChild("TigerEffects").SlashPart
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
local TweenService = game:GetService("TweenService")

local function RandomVectorOffsetBetween(vector2: Vector3, p: number, p2: number)
	return (CFrame.lookAt(Vector3.new(), vector2) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p2), (math.cos(p))))),
		0,
		0
	)).LookVector
end

local function Slash(p, p2, cframe: CFrame, p3: number, color: Color3, p4: number, p5: number)
	local clone = slashPart:Clone()
	clone.Decal.Texture = v[1]
	clone.Decal.Color3 = color
	clone.Mesh.Scale = Vector3.new(p4, p4 * 0.46153846153846156, p4)
	clone.Decal.Transparency = 0
	TweenService:Create(clone.Mesh, TweenInfo.new(p3 * 0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Scale = Vector3.new(p5, p4 * 0.46153846153846156, p5)
	}):Play()
	clone.CFrame = (cframe + p2.Position) * CFrame.new(0, 0, -7)
	Util.SetParentOverrideWithColor(clone, _WorldOrigin, p, "LeopardFruitVFXColor")
	task.delay(p3 + 0.2, function()
		clone:Destroy()
	end)
	local count = #v
	heartbeatLoopFor2(p3, function(_, _, p6)
		if clone.Parent ~= nil then
			local v2 = math.floor(p6 * (count - 1)) + 1

			if v2 ~= 1 then
				clone.Decal.Texture = v[v2]
			end

			clone.CFrame *= CFrame.Angles(0, -0.24434609527920614, 0)
			clone.CFrame += -clone.CFrame.Position + ((cframe + p2.Position) * CFrame.new(0, 0, -7 * (1 - p6) ^ 2)).Position
		end
	end, function()
		if clone.Parent ~= nil then
			clone.Decal.Transparency = 1
		end
	end)
end

return function(data)
	local DELAY_DURATION = 0.5
	local player = data.player
	local hrp = data.hrp
	local amount = data.amount or 3
	local createExtraSlashes = data.createExtraSlashes

	if hrp == nil or hrp.Parent == nil or (hrp.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1100 then
		return
	end

	for _ = 1, amount do
		task.spawn(
			Slash,
			player,
			hrp,
			CFrame.new(createVector(0, 0, 0), (RandomVectorOffsetBetween(createVector(0, 1, 0), 0, 0.4363323129985824))) * inverse * CFrame.Angles(
				0,
				0.6283185307179586 * math.random(),
				0
			),
			0.35,
			Util.WrapColor3Constructor(Color3.fromRGB(324, 702, 765), player, "LeopardFruitVFXColor"),
			random:NextNumber(10, 24) * 2.5,
			5
		)
	end

	for _ = 1, 2 do
		task.spawn(
			Slash,
			player,
			hrp,
			CFrame.new(createVector(0, 0, 0), (RandomVectorOffsetBetween(createVector(0, 1, 0), 0, 0.6108652381980153))) * inverse * CFrame.Angles(
				0,
				0.6283185307179586 * math.random(),
				0
			),
			0.25,
			Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), player, "LeopardFruitVFXColor"),
			random:NextNumber(14, 24) * 2.5,
			random:NextNumber(1, 4) * 1.5
		)
	end

	if createExtraSlashes == true then
		local clone = M1.ExtraSlashes:Clone()
		Util.SetParentOverrideWithColor(clone, hrp, player, "LeopardFruitVFXColor")
		task.delay(DELAY_DURATION, function()
			clone:Destroy()
		end)

		for _, child in ipairs(clone:GetChildren()) do
			child:Emit(1)
		end
	end

	local clone = M1.Attachment:Clone()
	Util.SetParentOverrideWithColor(clone, hrp, player, "LeopardFruitVFXColor")
	task.delay(DELAY_DURATION, function()
		clone:Destroy()
	end)

	for _, child in ipairs(clone:GetChildren()) do
		child:Emit(1)
	end

	local clone2 = M1.Light:Clone()
	Util.SetParentOverrideWithColor(clone2, hrp, player, "LeopardFruitVFXColor")
	task.delay(DELAY_DURATION, function()
		clone2:Destroy()
	end)
	local pointLight = clone2.PointLight
	pointLight.Brightness = 8
	pointLight.Range = 0
	pointLight.Enabled = true
	TweenService:Create(pointLight, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Range = 15
	}):Play()
	task.wait(0.15)
	TweenService:Create(pointLight, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Brightness = 0
	}):Play()
end