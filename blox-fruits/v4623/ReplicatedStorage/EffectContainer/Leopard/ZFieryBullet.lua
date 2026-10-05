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
local fieryBullet = FX:WaitForChild("LeopardEffects").FieryBullet
local zFieryHand = FX:WaitForChild("LeopardEffects").ZFieryHand
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))

local function ScaleParticle(descendant, p)
	local keypoints = descendant.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	descendant.Size = NumberSequence.new(numberSequenceKeypoints)
	descendant.Speed = NumberRange.new(descendant.Speed.Min * p, descendant.Speed.Max * p)
	descendant.Acceleration *= p
end

local function ScaleAttachmentsAndEmittersWithin(folder, fieryBulletSizeMult: number)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("Attachment") then
			descendant.Position *= fieryBulletSizeMult
		elseif descendant:IsA("ParticleEmitter") then
			ScaleParticle(descendant, fieryBulletSizeMult)
		end
	end
end

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

for k, v2 in pairs(v) do
	local Graphics = require(game.ReplicatedStorage.Util.Graphics)
	v[k] = Graphics.ScaleDown(v2)
end

local v2 = { "rbxassetid://9659478878" }

for k, v3 in pairs(v2) do
	local Graphics = require(game.ReplicatedStorage.Util.Graphics)
	v2[k] = Graphics.ScaleDown(v3)
end

return function(data)
	local _ = data.player
	local hrp = data.hrp
	local projectilePart = data.projectilePart
	local explodesAfter = data.explodesAfter
	local fieryBulletSizeMult = data.fieryBulletSizeMult
	local currentCamera = Workspace.CurrentCamera

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local position = hrp.Position

	if (position - currentCamera.CFrame.Position).Magnitude > 1100 then
		return
	end

	if (position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 110 then
		Util.CameraShaker:ShakeOnce(11, 11, 0.01, 0.25)
		local bloomEffect = Instance.new("BloomEffect")
		bloomEffect.Name = "LeopardZBloom"
		bloomEffect.Intensity = 4
		bloomEffect.Threshold = 0.4
		bloomEffect.Size = 64
		bloomEffect.Parent = Lighting
		heartbeatLoopFor2(0.2, function(_, _, p)
			bloomEffect.Intensity = 4 - 4 * p
			bloomEffect.Threshold = 0.4 + 0.6 * p
			bloomEffect.Size = 64 - 64 * p
		end, function()
			bloomEffect:Destroy()
		end)
	end

	if hrp.Parent:FindFirstChild("RightHand") then
		local clone = zFieryHand:Clone()
		local pointToWorldSpace = hrp.CFrame:PointToWorldSpace(createVector(1.5883179, 0.8143921, -1.8314514))
		clone.CFrame = CFrame.lookAt(createVector(0, 0, 0), projectilePart.CFrame.LookVector) * CFrame.lookAt(
			createVector(0, 0, 0),
			createVector(-1, -0, -0)
		):Inverse() + pointToWorldSpace
		clone.Parent = _WorldOrigin
		destroyAfter(clone, 2)

		for _, emitter in ipairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end

	if projectilePart == nil or projectilePart.Parent == nil then
		return
	end

	local clone = fieryBullet:Clone()
	ScaleAttachmentsAndEmittersWithin(clone, fieryBulletSizeMult)
	local clone2 = clone.Attachment0:Clone()
	local clone3 = clone.Attachment1:Clone()
	local clone4 = clone.FX:Clone()
	local clone5 = clone.HitFX:Clone()

	for _, child in ipairs(clone2:GetChildren()) do
		child.Attachment0 = clone2
		child.Attachment1 = clone3
	end

	local clone6 = clone.A0:Clone()
	local clone7 = clone.A1:Clone()
	local groundTrail = clone6.GroundTrail
	local groundTrail2 = clone6.GroundTrail
	groundTrail.Attachment0 = clone6
	groundTrail2.Attachment1 = clone7
	heartbeatLoopFor2(explodesAfter, function()
		local ray = Util.Ray
		local v3 = projectilePart.Position + createVector(0, 2, 0)
		local v4 = {
			Workspace.Characters,
			Workspace.Enemies,
			_WorldOrigin,
			projectilePart
		}
		local v5, v6, _ = ray(v3, createVector(-0, -6, -0), v4, false)

		if v5 == nil and clone6.GroundTrail.Enabled == true then
			clone6.GroundTrail.Enabled = false
			return
		end

		if v5 ~= nil and clone6.GroundTrail.Enabled == false then
			clone6.GroundTrail.Enabled = true
		end

		clone6.WorldPosition = clone6.WorldPosition * createVector(1, 0, 1) + (v6.Y + 0.1) * createVector(0, 1, 0)
		clone7.WorldPosition = clone7.WorldPosition * createVector(1, 0, 1) + (v6.Y + 0.1) * createVector(0, 1, 0)
	end)
	clone2.Parent = projectilePart
	clone3.Parent = projectilePart
	clone4.Parent = projectilePart
	clone5.Parent = projectilePart
	clone6.Parent = projectilePart
	clone7.Parent = projectilePart
	local clone8 = clone.FieryBulletLaunchSound:Clone()

	if data.transformedRig then
		clone8:SetAttribute("PlaybackSpeed", clone8:GetAttribute("PlaybackSpeed") * 0.8)
	end

	clone8.Parent = projectilePart
	Util.UtilSoundWrapper.Play(clone8)
	task.wait(explodesAfter + 0.125)

	for _ = 1, 100 do
		if projectilePart:FindFirstChild("Stopped") then
			break
		else
			task.wait()
		end
	end

	if not projectilePart:FindFirstChild("Stopped") then
		return
	end

	local cFrame = projectilePart.Stopped.Value
	projectilePart.Anchored = true
	projectilePart.CFrame = cFrame
	local clone9 = clone.FieryBulletExplosion:Clone()

	if data.transformedRig then
		clone9:SetAttribute("PlaybackSpeed", clone9:GetAttribute("PlaybackSpeed") * 0.8)
	end

	clone9.Parent = projectilePart
	Util.UtilSoundWrapper.Play(clone9, cFrame.Position)
	clone9:Destroy()

	for _, child in ipairs(clone5:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end

	for _, child in ipairs(clone2:GetChildren()) do
		child.Enabled = false
	end

	for _, child in ipairs(clone4:GetChildren()) do
		child.Enabled = false
	end

	if (cFrame.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 100 * fieryBulletSizeMult or (position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 100 * fieryBulletSizeMult then
		Util.CameraShaker:ShakeOnce(25, 25, 0.05, 0.35)
		local bloomEffect = Instance.new("BloomEffect")
		bloomEffect.Name = "LeopardZBloom"
		bloomEffect.Intensity = 4
		bloomEffect.Threshold = 0.4
		bloomEffect.Size = 64
		bloomEffect.Parent = Lighting
		heartbeatLoopFor2(0.4, function(_, _, p)
			bloomEffect.Intensity = 4 - 4 * p
			bloomEffect.Threshold = 0.4 + 0.6 * p
			bloomEffect.Size = 64 - 64 * p
		end, function()
			bloomEffect:Destroy()
		end)
	end

	local ray = Util.Ray
	local v3 = cFrame.Position + createVector(0, 2, 0)
	local v4 = { Workspace.Characters, Workspace.Enemies, _WorldOrigin }
	local v5, v6, _ = ray(v3, createVector(-0, -16, -0), v4, false)

	if v5 ~= nil then
		local cframe = CFrame.new(v6)
		local v7 = createVector(100, 0.05, 100) * fieryBulletSizeMult
		local v8, v9 = GroundCrack(v2, cframe, v7 * 2.5, 0.15, Color3.fromRGB(765, 255, 0), 0.2)
		heartbeatLoopFor2(0.1, function(_, _, p)
			v9.Color3 = Color3.fromRGB(765 * (1 - 0.8 * p), 255 * (1 - 0.8 * p), 0)
			v8.Size = v7 * 2.5 * (1 - 0.4 * p)
		end, function()
			v9.Color3 = Color3.fromRGB(152.99999999999997, 50.999999999999986, 0)
			v8.Size = v7 * 2.5 * 0.6
		end)
		local _, v10 = GroundCrack(v, cframe, v7, 0.15, Color3.fromRGB(85, 42, 0), 0.5, 1)
		local _, v11 = GroundCrack(
			v,
			cframe + createVector(0, 0.02, 0),
			v7 * 0.94,
			0.25,
			Color3.fromRGB(765, 255, 0),
			0.4,
			1
		)
		task.delay(0.2, function()
			heartbeatLoopFor2(0.35, function(_, _, p)
				v10.Color3 = Color3.fromRGB(85 * (1 - p), 42 * (1 - p), 0)
				v11.Color3 = Color3.fromRGB(765 * (1 - p), 255 * (1 - p), 0)
			end, function()
				v10.Color3 = Color3.fromRGB(0, 0, 0)
				v11.Color3 = Color3.fromRGB(0, 0, 0)
			end)
		end)
		local clone10 = clone.Rubble:Clone()
		clone10.Parent = projectilePart
		Util.UtilSoundWrapper.Play(clone10, cFrame.Position)
		clone10:Destroy()
	end
end