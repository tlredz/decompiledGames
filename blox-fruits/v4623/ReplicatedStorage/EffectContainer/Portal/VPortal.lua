local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
local inverse = CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
local inverse2 = CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local vPortal = FX:WaitForChild("PortalEffects").VPortal
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor

local function areShiftedColorsEqual(player, childName: string, color: Color3, color2: Color3, color3: Color3)
	local child = player:FindFirstChild(childName)

	if child == nil then
		return false
	end

	local shifted = child:FindFirstChild("Shifted")

	if shifted == nil then
		return false
	end

	local shifted_Color1 = shifted:GetAttribute("Shifted_Color1")
	local shifted_Color2 = shifted:GetAttribute("Shifted_Color2")
	local shifted_Color3 = shifted:GetAttribute("Shifted_Color3")

	if shifted_Color1 == nil or shifted_Color2 == nil or shifted_Color3 == nil then
		return false
	end

	return color == shifted_Color1 and color2 == shifted_Color2 and color3 == shifted_Color3
end

local function ScaleModel(folder, modelScale)
	local modelScale2 = folder:GetAttribute("ModelScale")
	local v = modelScale / (modelScale2 == nil and 1 or modelScale2)

	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Size *= Vector3.new(v, v, v)
		end
	end

	folder:SetAttribute("ModelScale", modelScale)
end

local new = NumberSequence.new

local function SamysSwirlSpline(data, p)
	local v = p * 11
	local v2 = -(createVector(0, 1, 0)):Cross(data)
	local v3 = math.exp(-0.19 * v)
	return (Vector3.new(
		v3 * (data.X * math.cos(0.8 * v) + (v2.X - -0.19 * data.X) / 0.8 * math.sin(0.8 * v)),
		((1 - v3) ^ 3 * 2 - (1 - v3) ^ 2 * 3 + 1) * data.Y + ((1 - v3) ^ 3 - (1 - v3) ^ 2 * 2 + (1 - v3)) * v2.Y,
		v3 * (data.Z * math.cos(0.8 * v) + (v2.Z - -0.19 * data.Z) / 0.8 * math.sin(0.8 * v))
	))
end

local function RandomVectorOffsetBetween(p, p2, p3)
	return (CFrame.lookAt(Vector3.new(), p) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p3), (math.cos(p2))))),
		0,
		0
	)).LookVector
end

local attachmentPair = Util.AttachmentPair
return function(data)
	local player = data.player
	local origin = data.origin
	local upVector = data.upVector
	local lastsFor = data.lastsFor
	local currentCamera = Workspace.CurrentCamera

	if (origin - currentCamera.CFrame.Position).Magnitude > 1100 then
		return
	end

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude < 150 then
		Util.CameraShaker:ShakeOnce(12, 9, 0, lastsFor * 4)
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "PortalVColorContrast"
		colorCorrectionEffect.Contrast = 0
		Util.SetParentOverrideWithColor(colorCorrectionEffect, Lighting, player, "PortalFruitVFXColor")
		heartbeatLoopFor2(lastsFor, function(_, _, p)
			colorCorrectionEffect.Contrast = 2 * p
			currentCamera.FieldOfView = 70 - 20 * p
		end, function()
			colorCorrectionEffect.Contrast = 2
			currentCamera.FieldOfView = 50
			heartbeatLoopFor2(lastsFor, function(_, _, p)
				colorCorrectionEffect.Contrast = 2 - 2 * p
				currentCamera.FieldOfView = 50 + 20 * p
			end, function()
				colorCorrectionEffect:Destroy()
				currentCamera.FieldOfView = 70
			end)
		end)
	end

	local clone = vPortal:Clone()
	local v = CFrame.lookAt(createVector(0, 0, 0), upVector) * inverse2 + origin
	clone:PivotTo(v)
	ScaleModel(clone.BlackHole.Singularity, 0.01)
	local beams = {}

	for _, beam in ipairs(clone.BlackHole:GetDescendants()) do
		if not beam:IsA("Beam") then
			continue
		end

		beam:SetAttribute("Transp", beam.Transparency.Keypoints[1].Value)
		beam.Transparency = new(1)
		beam.Brightness *= 2
		table.insert(beams, beam)
	end

	Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "PortalFruitVFXColor")
	destroyAfter(clone, lastsFor + 3)

	if areShiftedColorsEqual(
		player,
		"PortalFruitVFXColor",
		Color3.fromRGB(255, 229, 97),
		Color3.fromRGB(255, 225, 30),
		Color3.fromRGB(255, 199, 16)
	) then
		Util.Sound:Play("DivinePortalV", v.Position + createVector(0, 5, 0))
	else
		Util.Sound:Play("PortalV", v.Position + createVector(0, 5, 0))
	end

	clone.GroundPortal.CirclePart.ChargeAttachment.Gradient:Emit(1)
	clone.GroundPortal.CirclePart.ChargeAttachment.Outline:Emit(1)
	clone.GroundPortal.CirclePart2.Particles.Gradient:Emit(1)
	clone.GroundPortal.CirclePart2.Particles.Outline:Emit(1)
	local singularity = clone.BlackHole.Singularity
	local singularity2 = singularity.Singularity
	local position = clone.BlackHole.Singularity.Singularity.Position
	heartbeatLoopFor2(lastsFor + 2, function()
		singularity2.CFrame = CFrame.lookAt(createVector(0, 0, 0), currentCamera.CFrame.Position - position) * inverse + position
	end)
	heartbeatLoopFor2(lastsFor * 0.98, function(_, _, p)
		ScaleModel(singularity, 0.01 + 1.49 * p ^ 0.5)

		for _, v2 in ipairs(beams) do
			v2.Transparency = new(1 + (v2:GetAttribute("Transp") - 1) * p)
		end
	end, function()
		ScaleModel(singularity, 1.5)

		for _, v2 in ipairs(beams) do
			v2.Transparency = new(v2:GetAttribute("Transp"))
		end
	end)
	local v2 = time()
	heartbeatLoopFor2(lastsFor, function()
		if time() - v2 > 0.02 then
			v2 = time()
			local v3 = attachmentPair.new(
				CFrame.new(0, -random:NextNumber(1, 5.8), 0),
				CFrame.new(0, random:NextNumber(1, 5.8), 0)
			)
			local clone2 = FX:WaitForChild("PortalEffects").VTrail:Clone()
			clone2.Color = ColorSequence.new(Util.WrapColor3Constructor(
				Color3.fromHSV(0.6225, random:NextNumber(0.54, 0.94), 1),
				player,
				"PortalFruitVFXColor"
			))
			clone2.Brightness = random:NextNumber(-2, 5)
			clone2.LightEmission = random:NextNumber(-1, 1)
			v3:hookUp(clone2)
			local v4 = CFrame.lookAt(createVector(0, 0, 0), upVector) * inverse2 + position
			local v5 = RandomVectorOffsetBetween(createVector(0, 1, 0), 0.8726646259971648, 1.5707963267948966) * random:NextNumber(
				60,
				80
			)
			heartbeatLoopFor2(0.75, function(_, _, p)
				local samysSwirlSpline = SamysSwirlSpline(v5, p * 0.99)
				local samysSwirlSpline2 = SamysSwirlSpline(v5, p)
				v3:setRelativeCFrame(v4 * CFrame.lookAt(samysSwirlSpline, samysSwirlSpline2))
			end, function()
				local samysSwirlSpline = SamysSwirlSpline(v5, 0.99)
				local samysSwirlSpline2 = SamysSwirlSpline(v5, 1)
				v3:setRelativeCFrame(v4 * CFrame.lookAt(samysSwirlSpline, samysSwirlSpline2))
				task.delay(0.5, function()
					v3:destroy()
				end)
			end)
		end
	end)
	task.wait(lastsFor)
	heartbeatLoopFor2(lastsFor * 0.4, function(_, _, p)
		ScaleModel(singularity, 1.5 - 1.49 * p ^ 2)

		for _, v3 in ipairs(beams) do
			v3.Transparency = new(v3:GetAttribute("Transp") + (1 - v3:GetAttribute("Transp")) * p)
		end
	end, function()
		singularity2.Transparency = 1
		singularity.Halo.Transparency = 1

		for _, v3 in ipairs(beams) do
			v3.Transparency = new(1)
		end
	end)

	for _, emitter in ipairs(clone.GroundPortal:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end
end