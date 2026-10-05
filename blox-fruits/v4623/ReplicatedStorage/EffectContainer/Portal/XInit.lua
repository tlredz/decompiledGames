local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(-1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { Workspace.Map }
local CreatePortal = require(script.Parent:WaitForChild("CreatePortal"))

local function scaleAttachmentsAndBeams(folder, modelScale)
	local modelScale2 = folder:GetAttribute("ModelScale")
	local v = modelScale / (modelScale2 == nil and 1 or modelScale2)

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("Attachment") then
			descendant.Position *= v
		elseif descendant:IsA("Beam") then
			descendant.TextureLength *= v
			descendant.CurveSize0 *= v
			descendant.CurveSize1 *= v
			descendant.Width0 *= v
			descendant.Width1 *= v
		end
	end

	folder:SetAttribute("ModelScale", modelScale)
end

local function BiasedRandomVectorOffset(p, p2)
	return (CFrame.lookAt(Vector3.new(), p) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		random:NextNumber(0, p2),
		0,
		0
	)).LookVector
end

return function(data)
	local player = data.player
	local _ = data.char
	local hrp = data.hrp
	local portalLastsFor = data.portalLastsFor
	local currentCamera = Workspace.CurrentCamera
	local origin = data.origin

	if (origin - currentCamera.CFrame.Position).Magnitude > 1100 or hrp == nil or hrp.Parent == nil then
		return
	end

	if localPlayer == player then
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "PortalXColor"
		colorCorrectionEffect.Contrast = 2
		colorCorrectionEffect.TintColor = Util.WrapColor3ConstructorForTintColor(
			Color3.fromRGB(41, 73, 255),
			player,
			"PortalFruitVFXColor"
		)
		Util.SetParentOverrideWithColor(colorCorrectionEffect, Lighting, player, "PortalFruitVFXColor")
		destroyAfter(colorCorrectionEffect, portalLastsFor)
		local clone = FX:WaitForChild("PortalEffects").XWorldParticles:Clone()
		clone.CFrame = currentCamera.CFrame + currentCamera.CFrame.LookVector * clone.Size.Z * 0.5
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "PortalFruitVFXColor")
		destroyAfter(clone, portalLastsFor)
		heartbeatLoopFor2(portalLastsFor, function()
			clone.CFrame = currentCamera.CFrame + currentCamera.CFrame.LookVector * clone.Size.Z * 0.5
		end)

		for i = 1, 6 do
			local clone2 = FX:WaitForChild("PortalEffects").XWorldChain:Clone()
			local lookVector = CFrame.Angles(0, i / 6 * 2 * 3.141592653589793, 0).LookVector
			clone2.CFrame = CFrame.lookAt(
				createVector(0, 0, 0),
				(BiasedRandomVectorOffset(createVector(0, 1, 0), 1.5707963267948966))
			) + origin + lookVector * random:NextNumber(150, 500) + createVector(0, 1, 0) * random:NextNumber(0, 250)
			Util.SetParentOverrideWithColor(clone2, clone, player, "PortalFruitVFXColor")
		end

		for i = 1, 6 do
			local clone2 = FX:WaitForChild("PortalEffects").XWorldChain:Clone()
			local lookVector = CFrame.Angles(0, i / 6 * 2 * 3.141592653589793, 0).LookVector
			clone2.CFrame = CFrame.lookAt(
				createVector(0, 0, 0),
				(BiasedRandomVectorOffset(createVector(0, 1, 0), 1.5707963267948966))
			) + origin + lookVector * random:NextNumber(750, 2000) + createVector(0, 1, 0) * random:NextNumber(0, 250)
			Util.SetParentOverrideWithColor(clone2, clone, player, "PortalFruitVFXColor")
		end

		for _, child in ipairs(FX:WaitForChild("PortalEffects").XAura:GetChildren()) do
			local clone2 = child:Clone()
			Util.SetParentOverrideWithColor(clone2, hrp, player, "PortalFruitVFXColor")
		end

		local v = Util.Sound:Play("PortalXAmbience", hrp)
		v.Name = "PortalXAmbience"
		destroyAfter(v, 7)
	end

	CreatePortal({
		player = player,
		origin = origin - hrp.CFrame.LookVector + createVector(0, 3.5, 0),
		lookDir = hrp.CFrame.LookVector,
		lastsFor = portalLastsFor
	})
	local clone = FX:WaitForChild("PortalEffects").XPortalSurround:Clone()
	scaleAttachmentsAndBeams(clone, 3)
	clone.CFrame = CFrame.lookAt(createVector(0, 0, 0), hrp.CFrame.LookVector) + origin - hrp.CFrame.LookVector + createVector(
		0,
		3.5,
		0
	)
	Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "PortalFruitVFXColor")
	destroyAfter(clone, portalLastsFor + 2)
	Util.Sound:Play("PortalXChain", clone.Position)
	local v = {
		clone.Beams0.left,
		clone.Beams0.right,
		clone.Beams1.left,
		clone.Beams1.right
	}
	heartbeatLoopFor2(0.5, function(_, _, p)
		for _, v2 in ipairs(v) do
			v2.Transparency = NumberSequence.new(1 - p)
		end
	end, function()
		for _, v2 in ipairs(v) do
			v2.Transparency = NumberSequence.new(0)
		end
	end)
	heartbeatLoopFor2(0.25, function(_, _, p)
		scaleAttachmentsAndBeams(clone, 3 - 2 * p)
	end, function()
		scaleAttachmentsAndBeams(clone, 1)
		heartbeatLoopFor2(0.5, function(_, _, p)
			for _, v2 in ipairs(v) do
				v2.Brightness = (1 - math.abs(1 - 2 * p)) * 47 + 3
			end
		end, function()
			for _, v2 in ipairs(v) do
				v2.Brightness = 3
			end
		end)
	end)
	task.delay(portalLastsFor - 0.5, function()
		for _, child in ipairs(clone.Particles:GetChildren()) do
			child.Enabled = false
		end

		heartbeatLoopFor2(0.5, function(_, _, p)
			for _, v2 in ipairs(v) do
				v2.Transparency = NumberSequence.new(p)
			end
		end, function()
			for _, v2 in ipairs(v) do
				v2.Transparency = NumberSequence.new(1)
			end
		end)
	end)
	local ray = Util.Ray
	local position = clone.Position
	local v2 = { Workspace.Characters, Workspace.Enemies, _WorldOrigin }
	local v3, _, _ = ray(position, createVector(-0, -9, -0), v2, false)

	if v3 then
		local clone2 = FX:WaitForChild("PortalEffects").XSpikes:Clone()
		clone2:PivotTo(clone.CFrame - createVector(0, 19, 0))
		Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "PortalFruitVFXColor")
		destroyAfter(clone2, portalLastsFor + 2)
		heartbeatLoopFor2(0.35, function(_, _, p)
			local v4 = p ^ 0.3
			clone2:PivotTo(clone.CFrame * CFrame.Angles(0, 1.5707963267948966, 0) + createVector(0, 1, 0) * (-20 + 17 * v4))
		end, function()
			clone2:PivotTo(clone.CFrame * CFrame.Angles(0, 1.5707963267948966, 0) + createVector(-0, -3, -0))
		end)
		task.delay(portalLastsFor - 0.5, function()
			heartbeatLoopFor2(0.2, function(_, _, p)
				clone2:PivotTo(clone.CFrame * CFrame.Angles(0, 1.5707963267948966, 0) + createVector(0, 1, 0) * (-3 - 17 * p))
			end, function()
				clone2:PivotTo(clone.CFrame * CFrame.Angles(0, 1.5707963267948966, 0) + createVector(-0, -20, -0))
			end)
		end)
	end
end