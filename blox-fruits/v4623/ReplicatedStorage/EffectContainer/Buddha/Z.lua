local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local v = 7.1
local vector2 = Vector3.new()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local windParts = FX:WaitForChild("BuddhaEffects").WindParts
local faceCameraPart = FX:WaitForChild("BuddhaEffects").FaceCameraPart
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local lightningBolt2 = Util.LightningBolt2
local promise = Util.Promise
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local awaitHeartbeatLoopFor = heartbeatLoopFor.AwaitHeartbeatLoopFor

-- equivalent calls inferred from this helper; original call sites unknown
local function spiralCurve(p, height, radius, cycles, angle)
	local v2 = 6.283185307179586 * cycles
	return (Vector3.new(
		radius * math.cos(v2 * p + angle),
		height - 1.005 * height * p,
		radius * math.sin(v2 * p + angle)
	))
end

local function NoiseBetween(p, p2, p3, p4, p5)
	return p4 + (p5 - p4) * (math.noise(p, p2, p3) + 0.5)
end

local function RandomVectorOffsetBetween(p, p2, p3)
	return (CFrame.lookAt(Vector3.new(), p) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p3), (math.cos(p2))))),
		0,
		0
	)).LookVector
end

local function setCharacterScale(instance, p)
	for _, child in pairs(instance:GetChildren()) do
		if child.ClassName == "NumberValue" then
			child.Value = (child:GetAttribute("OriginalValue") or child.Value) * p
		end
	end

	if not instance:GetAttribute("JumpPower") then
		instance:SetAttribute("JumpPower", instance.JumpPower)
	end

	instance.JumpPower = instance:GetAttribute("JumpPower") * (p > 1 and 2 or 1)
end

game:GetService("UserInputService")

local function buddhaTransform(position, humanoid, p)
	if p then
		return
	end

	if Workspace:GetAttribute("MAP") == "Dungeons" then
		v /= 1.75
	end

	local currentCamera = Workspace.CurrentCamera
	local model = Instance.new("Model")
	model.Name = "buddhaTransform"
	model.Parent = _WorldOrigin
	local v2 = {
		WorldPosition = vector2,
		WorldAxis = vector2
	}
	local v3 = {
		WorldPosition = vector2,
		WorldAxis = vector2
	}
	local LB2 = lightningBolt2.new(v2, v3, 15)
	local LB3 = lightningBolt2.new(v2, v3, 15)
	local LB4 = lightningBolt2.new(v2, v3, 15)
	local v9 = {
		{},
		{},
		{}
	}
	local v10 = v9[1]
	local v11 = v9[1]
	local v12 = v9[1]
	local v13 = v9[1]
	local v14 = v9[1]
	v10.LB = LB2
	v11.height = 360
	v12.radius = 100
	v13.cycles = 3.7
	v14.angle = 0
	local v15 = v9[2]
	local v16 = v9[2]
	local v17 = v9[2]
	local v18 = v9[2]
	local v19 = v9[2]
	v15.LB = LB3
	v16.height = 364
	v17.radius = 96
	v18.cycles = 3.5
	v19.angle = 2
	local v20 = v9[3]
	local v21 = v9[3]
	local v22 = v9[3]
	local v23 = v9[3]
	local v24 = v9[3]
	v20.LB = LB4
	v21.height = 367
	v22.radius = 84
	v23.cycles = 2.9
	v24.angle = 4.5

	for i = 1, 3 do
		local LB = v9[i].LB
		local v25 = i

		function LB.SpaceCurveFunction(p2)
			return position + spiralCurve(p2, v9[v25].height, v9[v25].radius, v9[v25].cycles, v9[v25].angle)
		end

		v9[i].LB.RadialProfileFunction = function(_)
			return 1
		end

		LB.MaxRadius = 10
		LB.AnimationSpeed = 0
		LB.Thickness = 4
		LB.PulseSpeed = 10
		LB.Color = Color3.fromHSV(0.0761944, 0.472969, 0.870588)
		LB.Frequency = 4
	end

	heartbeatLoopFor2(1, function(_)
		v9[1].angle -= 0.34
		v9[2].angle -= 0.34
		v9[3].angle -= 0.34
	end)
	awaitHeartbeatLoopFor(0.1, function(p2)
		local v25 = p2 / 0.1

		for i = 1, 3 do
			v9[i].angle -= 0.14 - 0.3 * v25
			v9[i].radius -= 15.5
			v9[i].cycles -= 0.39999999999999997
			local LB = v9[i].LB
			LB.MaxRadius = 10 + 4 * v25
			LB.AnimationSpeed = 40 * v25
			LB.Frequency = 4 - 2.4 * v25
		end
	end)
	local clone = windParts:Clone()
	clone:SetPrimaryPartCFrame(CFrame.new(position + createVector(0, 72, 0)))
	clone.Parent = model
	local children = clone:GetChildren()
	local clone2 = faceCameraPart:Clone()
	clone2.Parent = model
	local v25 = position + createVector(0, 10, 0)
	clone2.CFrame = CFrame.new(v25)
	promise.delay(0.3):andThen(function()
		clone2.Burst.Burst1.Enabled = false
		clone2.Burst.Burst2.Enabled = false
	end)
	heartbeatLoopFor2(0.9, function(p2)
		local v26 = math.min(1, p2 / 0.4)
		clone2.CFrame = CFrame.lookAt(v25, v25 + (currentCamera.CFrame.Position - v25) * createVector(1, 0, 1))

		for i, v27 in ipairs(children) do
			v27.Transparency = 1 - v26
			v27.CFrame *= CFrame.Angles(0, 0.2 * (2 * (i % 2) - 1), 0)
		end

		clone2.Pulse.Sparkle.Size = NumberSequence.new(math.sin(30 * p2) ^ 2 * 30 + 40)

		if random:NextNumber() < 0.12 then
			local v27 = {}
			local v28 = {}
			local lookVector = RandomVectorOffsetBetween(createVector(0, 1, 0), 0, 0.5235987755982988)
			local worldAxis = RandomVectorOffsetBetween(lookVector, 0.3490658503988659, 1.3962634015954636)
			local lookVector2 = RandomVectorOffsetBetween(lookVector, 0.3490658503988659, 1.3962634015954636)
			v27.WorldPosition = position + 70 * worldAxis
			v27.WorldAxis = worldAxis
			local worldPosition = position + 70 * lookVector2
			local worldAxis2 = -lookVector2
			v28.WorldPosition = worldPosition
			v28.WorldAxis = worldAxis2
			local v34 = lightningBolt2.new(v27, v28, 10)
			v34.MaxRadius = 10
			v34.AnimationSpeed = 0
			v34.Thickness = 7
			v34.PulseSpeed = 1000
			v34.Color = Color3.fromHSV(0.0761944, 0.472969, 0.870588)
			v34.Frequency = 4
			v34.CurveSize0 = 70
			v34.CurveSize1 = 70
			heartbeatLoopFor2(0.5, function(p3)
				local v35 = 1 + p3 * 2
				local v36 = v34
				local v37 = v34
				local curveSize = 70 * v35
				local curveSize2 = 70 * v35
				v36.CurveSize0 = curveSize
				v37.CurveSize1 = curveSize2
				v27.WorldPosition = position + 70 * worldAxis * v35
				v28.WorldPosition = position + 70 * lookVector2 * v35
			end)
			v34:DestroyDissipate(0.5, 1)
		end
	end)

	if (position - currentCamera.CFrame.Position).Magnitude < 240 then
		Util.CameraShaker:ShakeOnce(25, 25, 0.1, 1.8)
	end

	for _, child in pairs(humanoid:GetChildren()) do
		if child.ClassName ~= "NumberValue" or child:GetAttribute("OriginalValue") then
			continue
		end

		child:SetAttribute("OriginalValue", child.Value)
	end

	local count = 0
	awaitHeartbeatLoopFor(0.9, function(p2)
		local v26 = p2 / 0.9
		count += 1

		if count % 3 == 0 then
			setCharacterScale(humanoid, 1 * (1 - v26) + v * v26 ^ 0.5)
		end
	end)
	setCharacterScale(humanoid, v)

	for _, descendant in pairs(model:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
		end

		if not descendant:IsA("BasePart") then
			continue
		end

		local TweenService = game:GetService("TweenService")
		TweenService:Create(descendant, TweenInfo.new(0.1), {
			Transparency = 1
		}):Play()
	end

	task.delay(2.5, function()
		model:Destroy()
	end)
	v9[1].LB:DestroyDissipate(nil, 2)
	v9[2].LB:DestroyDissipate(nil, 2)
	v9[3].LB:DestroyDissipate(nil, 2)
end

local function buddhaUntransform(p)
	setCharacterScale(p, 1)
end

local function clearBuddhaBillboards(billboardParent)
	for _, child in ipairs(billboardParent:GetChildren()) do
		if child.Name == "BuddhaBillboard" then
			child:Destroy()
		end
	end
end

return function(data)
	local player = data.player
	local billboardParent = data.billboardParent or player
	local cFrame = data.CFrame
	local humanoid = data.humanoid
	local isTransformed = data.isTransformed
	local billboard = data.billboard

	if isTransformed == false then
		if billboard then
			task.spawn(function()
				game:GetService("ReplicatedStorage")
				local Workspace2 = game:GetService("Workspace")
				local clock = os.clock

				if billboard.Adornee == nil or billboard.Adornee.Parent == nil then
					billboard:Destroy()
				end

				local adornee = billboard.Adornee
				local now = clock()
				local heartbeatConnection = nil
				local RunService = game:GetService("RunService")
				heartbeatConnection = RunService.Heartbeat:Connect(function()
					local v2 = clock() - now
					local v3 = math.min(1, v2 / 2)

					if billboard.Adornee == nil or not billboard.Adornee:IsDescendantOf(Workspace2) then
						heartbeatConnection:Disconnect()
						return
					end

					if not billboard:IsDescendantOf(Workspace2) then
						heartbeatConnection:Disconnect()
						return
					end

					if not billboard:FindFirstChild("ImageLabel") then
						heartbeatConnection:Disconnect()
						return
					end

					billboard.ImageLabel.ImageTransparency = Util.Tween.point(
						1,
						adornee and adornee.Transparency or 0,
						v3
					)
					billboard.ImageLabel.Rotation = 10 * v2 % 360
				end)
			end)
		end

		buddhaTransform(
			cFrame.Position,
			humanoid,
			(cFrame.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1800
		)
	else
		if billboardParent then
			clearBuddhaBillboards(billboardParent)
		end

		setCharacterScale(humanoid, 1)
	end
end