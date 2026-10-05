local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local M1 = FX:WaitForChild("LeopardEffects").M1
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
require(script.Parent:WaitForChild("Modules"):WaitForChild("WindWave"))
local GroundCrack = require(script.Parent:WaitForChild("Modules"):WaitForChild("GroundCrack"))
local v = {
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
return function(data)
	local _ = data.player
	local hrp = data.hrp
	local isForTransformation = data.isForTransformation

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local currentCamera = Workspace.CurrentCamera

	if (hrp.Position - currentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	if (hrp.Position - currentCamera.CFrame.Position).Magnitude < 140 then
		Util.CameraShaker:ShakeOnce(25, 25, 0.1, 0.8)

		if currentCamera:GetAttribute("FOVInterpActive") ~= true then
			currentCamera:SetAttribute("FOVInterpActive", true)
			local fieldOfView = currentCamera.FieldOfView
			heartbeatLoopFor2(0.04, function(_, _, p)
				currentCamera.FieldOfView = fieldOfView + (90 - fieldOfView) * p
			end, function()
				currentCamera.FieldOfView = 90
			end)
			task.delay(0.5, function()
				heartbeatLoopFor2(0.2, function(_, _, p)
					currentCamera.FieldOfView = 90 + (fieldOfView - 90) * p
				end, function()
					currentCamera.FieldOfView = fieldOfView
					currentCamera:SetAttribute("FOVInterpActive", false)
				end)
			end)
		end

		local blurEffect = Instance.new("BlurEffect")
		blurEffect.Name = "LeopardM1Blur"
		blurEffect.Size = 8
		blurEffect.Parent = Lighting
		task.delay(0.5, function()
			heartbeatLoopFor2(0.2, function(_, _, p)
				blurEffect.Size = 8 * (1 - p)
			end, function()
				blurEffect:Destroy()
			end)
		end)
	end

	local clone = M1.Explosion:Clone()
	clone.Parent = hrp
	local ray = Util.Ray
	local position = hrp.Position
	local v2 = { Workspace.Characters, Workspace.Enemies, _WorldOrigin }
	local v3, v4, _ = ray(position, createVector(-0, -18, -0), v2, false)

	if v3 ~= nil and not isForTransformation then
		local cframe = CFrame.new(v4)
		local parent = GroundCrack(v, cframe, createVector(100, 0.05, 100), 0.15, Color3.fromRGB(0, 0, 0), 0.2)
		GroundCrack(
			v,
			cframe + createVector(0, 0.02, 0),
			createVector(70, 0.035, 70),
			0.25,
			Color3.fromRGB(0, 0, 0),
			0.1
		)
		GroundCrack(
			v,
			cframe * CFrame.Angles(0, 0.4, 0) + createVector(0, 0.01, 0),
			createVector(140, 0.07, 140),
			0.35,
			Color3.fromRGB(0, 0, 0),
			0.1
		)
		task.delay(0.1, function()
			local clone2 = script.RockEmitter:Clone()
			clone2.Parent = parent

			for _ = 1, 4 do
				task.wait()
				clone2:Emit(24)
			end
		end)

		if not isForTransformation then
			Util.UtilSoundWrapper.Play(clone.M1Explosion)
			Util.UtilSoundWrapper.Play(clone.Rubble)
		end
	end

	Util.UtilSoundWrapper.Play(clone.LeopardRoar)
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
				emitter.Color = ColorSequence.new(Color3.new(1, 0.615686, 0))
			end
		end

		for _, child in ipairs(clone2:GetChildren()) do
			child.Color = ColorSequence.new(Color3.new(1, 0.615686, 0))
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