local createVector = vector.create
game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local M1 = script:WaitForChild("M1")
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = {
	"rbxassetid://9911742221",
	"rbxassetid://9911741863",
	"rbxassetid://9911741541",
	"rbxassetid://9911741307",
	"rbxassetid://9911741114",
	"rbxassetid://9911740959",
	"rbxassetid://9911740727",
	"rbxassetid://9911740519",
	"rbxassetid://9911740304",
	"rbxassetid://9911740020"
}
return function(p)
	local hrp = p.hrp
	local isForTransformation = p.isForTransformation

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local currentCamera = Workspace.CurrentCamera

	if (hrp.Position - currentCamera.CFrame.Position).Magnitude > 900 then
		return
	end

	if (hrp.Position - currentCamera.CFrame.Position).Magnitude < 140 then
		local blurEffect = Instance.new("BlurEffect")
		blurEffect.Name = "LeopardM1Blur"
		blurEffect.Size = 8
		blurEffect.Parent = Lighting
		task.delay(0.5, function()
			heartbeatLoopFor2(0.2, function(_, _, p2)
				blurEffect.Size = 8 * (1 - p2)
			end, function()
				blurEffect:Destroy()
			end)
		end)
	end

	local clone = M1.Explosion:Clone()
	clone.Parent = hrp
	task.delay(4, function()
		clone:Destroy()
	end)
	local clone2 = M1.GroundWave:Clone()
	clone2.Parent = hrp
	task.delay(1, function()
		clone2:Destroy()
	end)

	if isForTransformation then
		for _, emitter in ipairs(clone:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Color = ColorSequence.new(Color3.new(0.333333, 0, 1))
			end
		end

		for _, child in ipairs(clone2:GetChildren()) do
			child.Color = ColorSequence.new(Color3.new(0.235294, 0, 1))
		end
	end

	for _, emitter in ipairs(clone:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	for _, child in ipairs(clone2:GetChildren()) do
		child.Enabled = true
	end

	task.wait(0.35)

	for _, emitter in ipairs(clone:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	for _, child in ipairs(clone2:GetChildren()) do
		child.Enabled = false
	end
end