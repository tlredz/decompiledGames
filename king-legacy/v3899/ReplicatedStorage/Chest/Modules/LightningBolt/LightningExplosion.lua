local createVector = vector.create
local parentModule = require(script.Parent)
local LightningSparks = require(script.Parent.LightningSparks)
local random = Random.new()
local clock = os.clock

function RandomVectorOffsetBetween(p, p2, p3)
	return (CFrame.lookAt(Vector3.new(), p) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p3), (math.cos(p2))))),
		0,
		0
	)).LookVector
end

local v = {}
local LightningExplosion = {}
LightningExplosion.__index = LightningExplosion

function LightningExplosion.new(p, value, value2, p2, p3, p4)
	local self = setmetatable({}, LightningExplosion)
	self.Size = value or 1
	self.NumBolts = value2 or 14
	self.Color = p2 or ColorSequence.new(Color3.new(1, 0, 0), Color3.new(0, 0, 1))
	self.BoltColor = p3 or Color3.new(0.3, 0.3, 1)
	self.UpVector = p4 or createVector(0, 1, 0)
	local currentCamera = workspace.CurrentCamera
	local part = Instance.new("Part")
	part.Name = "LightningExplosion"
	part.Anchored = true
	part.CanCollide = false
	part.Locked = true
	part.CastShadow = false
	part.Transparency = 1
	part.Size = createVector(0.05, 0.05, 0.05)
	part.CFrame = CFrame.lookAt(p + createVector(0, 0.5, 0), p + createVector(0, 0.5, 0) + self.UpVector) * CFrame.lookAt(
		Vector3.new(),
		createVector(0, 1, 0)
	):inverse()
	part.Parent = currentCamera
	local attachment = Instance.new("Attachment")
	attachment.Parent = part
	attachment.CFrame = CFrame.new()
	local clone = script.ExplosionBrightspot:Clone()
	local clone2 = script.GlareEmitter:Clone()
	local clone3 = script.PlasmaEmitter:Clone()
	local v2 = math.clamp(self.Size, 0, 1)
	clone2.Size = NumberSequence.new(v2 * 30)
	clone3.Size = NumberSequence.new(v2 * 18)
	clone3.Speed = NumberRange.new(v2 * 100)
	clone.Parent = attachment
	clone2.Parent = attachment
	clone3.Parent = attachment
	local color = self.Color

	if typeof(color) == "Color3" then
		local colorSequence = ColorSequence.new(color)
		local colorSequence2 = ColorSequence.new(color)
		clone2.Color = colorSequence
		clone3.Color = colorSequence2
		local HSV, _, v3 = color:ToHSV()
		clone.Color = ColorSequence.new(Color3.fromHSV(HSV, 0.5, v3))
	else
		clone2.Color = color
		clone3.Color = color
		local keypoints = color.Keypoints

		for i = 1, #keypoints do
			local HSV, _, v3 = keypoints[i].Value:ToHSV()
			keypoints[i] = ColorSequenceKeypoint.new(keypoints[i].Time, Color3.fromHSV(HSV, 0.5, v3))
		end

		clone.Color = ColorSequence.new(keypoints)
	end

	clone.Enabled = true
	clone2.Enabled = true
	clone3.Enabled = true
	local bolts = {}

	for _ = 1, self.NumBolts do
		local v4 = {
			WorldPosition = attachment.WorldPosition,
			WorldAxis = RandomVectorOffsetBetween(self.UpVector, 1.1344640137963142, 1.3962634015954636)
		}
		local v5 = {
			WorldPosition = attachment.WorldPosition + v4.WorldAxis * random:NextNumber(20, 40) * 1.4 * v2,
			WorldAxis = RandomVectorOffsetBetween(-self.UpVector, 1.2217304763960306, 1.9198621771937625)
		}
		local v9 = parentModule.new(v4, v5, 10)
		v9.AnimationSpeed = 0
		v9.Thickness = 1
		v9.Color = self.BoltColor
		v9.PulseLength = 0.8
		v9.ColorOffsetSpeed = 20
		v9.Frequency = 2
		local maxRadius = v2 * 4
		v9.MinRadius = 0
		v9.MaxRadius = maxRadius
		v9.FadeLength = 0.4
		v9.PulseSpeed = 5
		v9.MinThicknessMultiplier = 0.7
		v9.MaxThicknessMultiplier = 1
		local v11 = LightningSparks.new(v9, 5)
		v11.MinDistance = 7.5
		v11.MaxDistance = 10
		v9.Velocity = (v5.WorldPosition - v4.WorldPosition).Unit * 0.1 * v2
		bolts[#bolts + 1] = v9
	end

	self.Bolts = bolts
	self.Attachment = attachment
	self.Part = part
	self.StartT = clock()
	self.RefIndex = #v + 1
	v[self.RefIndex] = self
	return self
end

function LightningExplosion:Destroy()
	v[self.RefIndex] = nil
	self.Part:Destroy()

	for i = 1, #self.Bolts do
		self.Bolts[i] = nil
	end
end

local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
	for _, v2 in pairs(v) do
		local v3 = clock() - v2.StartT
		local attachment = v2.Attachment

		if v3 < 0.7 then
			if v3 > 0.2 then
				local explosionBrightspot = attachment.ExplosionBrightspot
				local glareEmitter = attachment.GlareEmitter
				local plasmaEmitter = attachment.PlasmaEmitter
				explosionBrightspot.Enabled = false
				glareEmitter.Enabled = false
				plasmaEmitter.Enabled = false
			end

			for i = 1, #v2.Bolts do
				local bolt = v2.Bolts[i]
				bolt.Attachment1.WorldPosition = bolt.Attachment1.WorldPosition + bolt.Velocity
			end
		else
			v2:Destroy()
		end
	end
end)
return LightningExplosion