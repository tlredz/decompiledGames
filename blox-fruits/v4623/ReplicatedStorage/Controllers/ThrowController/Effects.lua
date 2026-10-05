local createVector = vector.create
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Result = require(game.ReplicatedStorage.Packages.Result)
require(game.ReplicatedStorage.Packages.SimpleError)
local ConversionUtil = require(game.ReplicatedStorage.Packages.ConversionUtil)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local Trajectory = require(game.ReplicatedStorage.Util.Trajectory)
require(script.Parent.Types)
local roblox = ConversionUtil.Velocity.MilesPerHour.toRoblox(35)
local circle = script:WaitForChild("Circle")
local crosshair = script:WaitForChild("Crosshair")
local knobs = script:WaitForChild("Knobs")

function evalNumberSequence(sequence, p: number)
	if p == 0 then
		return sequence.Keypoints[1].Value
	elseif p == 1 then
		return sequence.Keypoints[#sequence.Keypoints].Value
	end

	for i = 1, #sequence.Keypoints - 1 do
		local keypoint = sequence.Keypoints[i]
		local keypoint2 = sequence.Keypoints[i + 1]

		if not (keypoint.Time <= p and p < keypoint2.Time) then
			continue
		end

		local v = (p - keypoint.Time) / (keypoint2.Time - keypoint.Time)
		return keypoint.Value + (keypoint2.Value - keypoint.Value) * v
	end

	error((`t={p} is not a valid time for sequence`))
end

local Effects = {}
local class = {}
class.__index = class

function class.new(instance, instance2, p)
	if p.ItemName ~= "Grappling Hook" or not instance2 then
		return nil
	end

	local rightHand = instance:FindFirstChild("RightHand")
	local controller = instance2:FindFirstChild("Controller", true)

	if not (rightHand and rightHand:IsA("BasePart") and controller and controller:IsA("Bone")) then
		return nil
	end

	local bones = {}

	for i = 1, 9 do
		local bone = instance2:FindFirstChild(`Rope{i}`, true)

		if bone and bone:IsA("Bone") then
			bone.Transform = CFrame.identity
			table.insert(bones, bone)
		else
			return nil
		end
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "GrapplingHookThrowHandTarget"
	attachment.Parent = rightHand
	return (setmetatable({
		controllerBone = controller,
		handTarget = attachment,
		rightVector = instance2:GetPivot().RightVector,
		ropeBones = bones
	}, class))
end

function class:getProjectileCFrame(vector2: Vector3, vector3: Vector3)
	local v = -(not (vector3.Magnitude > 0.001) and createVector(-0, -1, -0) or vector3.Unit)
	local v2 = self.rightVector - v * self.rightVector:Dot(v)

	if v2.Magnitude < 0.001 then
		v2 = (math.abs(v.Y) < 0.98 and createVector(0, 1, 0) or createVector(0, 0, 1)):Cross(v)
	end

	local unit = v2.Unit
	self.rightVector = unit
	return CFrame.fromMatrix(vector2, unit, v, unit:Cross(v).Unit)
end

function class:update(p: number)
	local position = (self.controllerBone.TransformedWorldCFrame * self.ropeBones[1].CFrame).Position
	local worldPosition = self.handTarget.WorldPosition
	local magnitude = (worldPosition - position).Magnitude
	local v = math.min(magnitude * 0.15, 8)
	local v2 = math.sin(p * 7) * math.min(magnitude * 0.02, 0.6)
	local rightVector = self.rightVector

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getRopePosition(p2: number)
		local v3 = math.sin(3.141592653589793 * p2)
		return position:Lerp(worldPosition, p2) - createVector(0, 1, 0) * v3 * v + rightVector * v3 * v2
	end

	local count = #self.ropeBones
	local transformedWorldCFrame = self.controllerBone.TransformedWorldCFrame
	local v3 = position

	for k, ropeBone in self.ropeBones do
		local v4 = (k - 1) / (count - 1)
		local ropePosition = getRopePosition(v4) -- equivalent call inferred; original call site unknown
		local v5

		if k < count then
			v5 = getRopePosition(v4 + 1 / (count - 1)) - ropePosition
		else
			v5 = ropePosition - v3
		end

		local v6 = not (v5.Magnitude > 0.001) and createVector(0, 1, 0) or v5.Unit
		local v7 = rightVector - v6 * rightVector:Dot(v6)

		if v7.Magnitude < 0.001 then
			v7 = (math.abs(v6.Y) < 0.98 and createVector(0, 1, 0) or createVector(0, 0, 1)):Cross(v6)
		end

		local unit = v7.Unit
		local cframe = CFrame.fromMatrix(ropePosition, unit, v6, unit:Cross(v6).Unit)
		ropeBone.Transform = (transformedWorldCFrame * ropeBone.CFrame):Inverse() * cframe
		v3 = ropePosition
		transformedWorldCFrame = cframe
	end
end

Effects.MAX_SPEED = roblox

function Effects.getIgnoreInstances(p, vector2: Vector3)
	local throwIgnoreTag = p.ThrowIgnoreTag

	if not throwIgnoreTag then
		return {}
	end

	local tagged = CollectionService:GetTagged(throwIgnoreTag)

	if p.ItemName ~= "Grappling Hook" then
		return tagged
	end

	local v = 1e999
	local v2 = nil

	for _, instance in tagged do
		local position

		if instance:IsA("BasePart") then
			position = instance.Position
		elseif instance:IsA("Model") then
			position = instance:GetPivot().Position
		end

		local v3 = not position and 1e999 or (position - vector2).Magnitude

		if not (v3 < v) then
			continue
		end

		v2 = instance
		v = v3
	end

	if v2 then
		return { v2 }
	end

	return tagged
end

function Effects.aim(p, p2, vector2: Vector3?)
	local v = p2
	local vector3 = vector2
	local v2 = {}
	local connections = {}
	local folder = Instance.new("Folder")
	folder.Name = "ThrowAimEffect"
	table.insert(v2, folder)
	local beam = Instance.new("Beam")
	table.insert(v2, beam)
	local attachment = Instance.new("Attachment")
	table.insert(v2, attachment)
	attachment.Name = "Attachment0"
	attachment.Parent = workspace:WaitForChild("Terrain")
	beam.Attachment0 = attachment
	local attachment2 = Instance.new("Attachment")
	table.insert(v2, attachment2)
	attachment2.Name = "Attachment1"
	attachment2.Parent = workspace:WaitForChild("Terrain")
	beam.Attachment1 = attachment2
	beam.Segments = 30
	beam.Width0 = 2
	beam.Width1 = circle.Size.X
	beam.Texture = "rbxassetid://9659332922"
	beam.TextureLength = 10
	beam.Color = ColorSequence.new(Color3.new(1, 0, 0))
	beam.TextureMode = Enum.TextureMode.Wrap
	beam.TextureSpeed = 5
	beam.Brightness = 2
	beam.LightInfluence = 0
	beam.LightEmission = 1
	beam.Segments = 360
	beam.Transparency = NumberSequence.new(0)
	beam.FaceCamera = false
	beam.Parent = folder
	local clone = crosshair:Clone()
	table.insert(v2, clone)
	clone.Material = Enum.Material.Neon
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	clone.Parent = folder
	local clone2 = circle:Clone()
	table.insert(v2, clone2)
	clone2.Material = Enum.Material.Neon
	clone2.CanCollide = false
	clone2.CanTouch = false
	clone2.CanQuery = false
	clone2.Color = Color3.new(1, 1, 1):Lerp(Color3.new(), 0.2)
	clone2.Parent = folder
	local clone3 = knobs:Clone()
	table.insert(v2, clone3)
	clone3.Material = Enum.Material.Neon
	clone3.CanCollide = false
	clone3.CanTouch = false
	clone3.CanQuery = false
	clone3.Color = clone2.Color
	clone3.Parent = folder
	local clone4 = circle:Clone()
	clone4.Name = "RippleDisk"
	clone4.Material = Enum.Material.SmoothPlastic
	clone4.CanCollide = false
	clone4.CanTouch = false
	clone4.CanQuery = false
	clone4.Color = Color3.new(1, 0.4, 0.4):Lerp(Color3.new(), 0.05)
	table.insert(v2, clone4)
	clone4.Parent = folder
	local part = Instance.new("Part")
	part.Name = "RippleSphere"
	part.Shape = Enum.PartType.Ball
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = clone4.Transparency
	part.Size = createVector(0.2, 0.2, 0.2)
	part.Material = Enum.Material.SmoothPlastic
	part.Color = clone4.Color
	table.insert(v2, part)
	part.Parent = folder
	local parent

	if v then
		parent = workspace
	end

	folder.Parent = parent

	-- equivalent calls inferred from this helper; original call sites unknown
	local function toStep(total: number, p3: number)
		return (math.clamp(total % p3 / p3, 0, 1))
	end

	local function lerp(p3: number, p4: number, value: number)
		return p3 + (p4 - p3) * math.clamp(value, 0, 1)
	end

	local total = 0
	table.insert(connections, RunService.RenderStepped:Connect(function(dt)
		total += dt

		if v then
			folder.Parent = workspace
		else
			folder.Parent = nil
		end

		local step = toStep(total, 0.7) -- equivalent call inferred; original call site unknown
		local v5 = math.rad(step * 90)
		local v6 = math.sin(v5 * 2)
		local v7 = math.clamp(v6, 0, 1) * 0.19999999999999996 + 0.8
		local v8 = vector3 and vector3:Dot(createVector(0, 1, 0)) < 0.5 and true or false
		local v9 = not (v5 < 0.7853981633974483) and 1 or v6
		local v10 = v5 < 0.7853981633974483 and 0 or (step - 0.5) * 2
		local v11 = p.HitRadius * 2 * v9
		local transparency

		if v5 < 0.7853981633974483 then
			transparency = math.clamp(v9, 0, 1) * 0.30000000000000004 + 0.6
		else
			transparency = v10 * 0.09999999999999998 + 0.9
		end

		if v8 then
			clone4.Transparency = 1
			part.Size = createVector(1, 1, 1) * v11
			part.Transparency = transparency
		else
			clone4.Size = Vector3.new(v11, v11, 0)
			clone4.Transparency = transparency
			part.Transparency = 1
		end

		local v13 = not v and createVector(0, 0, 0) or v.Target
		local cframe

		if vector3 then
			cframe = CFrame.lookAt(v13, v13 + vector3)
		else
			cframe = CFrame.new(v13) * CFrame.Angles(1.5707963267948966, 0, 0)
		end

		local cFrame = cframe + cframe.LookVector * 0.5
		clone3.CFrame = cFrame
		clone.Color = Color3.new(1, 0.45, 0.45):Lerp(Color3.new(), 0.2)
		clone.CFrame = cFrame * CFrame.Angles(0, 0, v5)
		clone2.CFrame = cFrame
		clone3.Size = knobs.Size * v7
		clone2.Size = circle.Size * v7
		clone4.CFrame = cFrame
		part.CFrame = CFrame.new(v13)

		if v then
			Trajectory.alignBeam(beam, v, 0.2)
		end
	end))
	return {
		Type = "AimController",
		Destroy = function(self)
			for _, v4 in v2 do
				local v5 = v4
				pcall(function()
					v5:Destroy()
				end)
			end

			for _, connection in connections do
				connection:Disconnect()
			end
		end,
		Update = function(_, p3, vector4: Vector3?)
			v = p3
			vector3 = vector4

			if not v then
				folder.Parent = nil
			end
		end
	}
end

function Effects.splash(data)
	local Effect = require(game.ReplicatedStorage.Effect)
	Effect.new("ThrowablePotion.Splash"):play({
		pos = data.Position + data.Normal * 0.5,
		color1 = data.Throw.Throwable.InnerColor,
		color2 = data.Throw.Throwable.OuterColor
	})
end

function Effects.fire(instance, instance2, throwable, aim, callback, p2: number?)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return Result.err({
			Type = "InvalidCharacter",
			Message = "Character has no HumanoidRootPart"
		})
	end

	local position = humanoidRootPart.Position
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if not playerFromCharacter then
		return Result.err({
			Type = "BadPlayer",
			Message = "Could not find player for character"
		})
	end

	local v = position
	local v2 = position
	local maxSpeed = throwable.MaxSpeed or roblox
	local v3 = aim.InitialVelocity.Unit * math.min(aim.InitialVelocity.Magnitude, maxSpeed)
	local raycastParams = RaycastParams.new()
	local overlapParams = OverlapParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude

	if RunService:IsClient() then
		local _ = playerFromCharacter == Players.LocalPlayer
	end

	local filterDescendantsInstances = { instance }

	if instance2 then
		table.insert(filterDescendantsInstances, instance2)
	end

	for _, v5 in Effects.getIgnoreInstances(throwable, position) do
		table.insert(filterDescendantsInstances, v5)
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	overlapParams.FilterDescendantsInstances = filterDescendantsInstances
	raycastParams.RespectCanCollide = true

	if instance2 then
		instance2:PivotTo(CFrame.new(v))
		instance2.Parent = workspace._WorldOrigin
	end

	local handTargets = {}
	local v5 = class.new(instance, instance2, throwable)

	if v5 then
		table.insert(handTargets, v5.handTarget)
	end

	local primaryPart = instance2 and instance2.PrimaryPart

	if instance2 and primaryPart then
		local v6 = {
			"HalloweenPotions_Potion_Throw_01",
			"HalloweenPotions_Potion_Throw_02",
			"HalloweenPotions_Potion_Throw_03",
			"HalloweenPotions_Potion_Throw_04"
		}
		Sound:Play(v6[math.random(1, #v6)], primaryPart, nil, nil, nil, nil)
		local attachment = Instance.new("Attachment")
		attachment.Position = createVector(0, -0.5, 0)
		attachment.Parent = primaryPart
		local attachment2 = Instance.new("Attachment")
		attachment2.Position = createVector(0, 0.5, 0)
		attachment2.Parent = primaryPart
		local trail = Instance.new("Trail")
		trail.Attachment0 = attachment
		trail.Attachment1 = attachment2
		trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, throwable.InnerColor),
			ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
		})
		trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
		trail.WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
		trail.Lifetime = 0.5
		trail.LightInfluence = 0
		trail.LightEmission = 0.5
		trail.FaceCamera = true
		trail.Parent = primaryPart
	end

	local connections = {}
	local flag = true

	local function cleanUp()
		if not flag then
			return
		end

		flag = false

		for _, connection in connections do
			connection:Disconnect()
		end

		for _, v6 in handTargets do
			local v7 = v6
			pcall(function()
				v7:Destroy()
			end)
		end

		if instance2 then
			pcall(function()
				instance2:Destroy()
			end)
		end
	end

	local GUID = HttpService:GenerateGUID(false)
	local now = tick()
	local impact = nil

	local function onStep(p3: number, p4: number)
		v3 -= Vector3.new(0, workspace.Gravity, 0) * p3
		v2 = v
		v += v3 * p3

		if instance2 then
			if v5 then
				instance2:PivotTo(v5:getProjectileCFrame(v, v3))
				v5:update(p4)
			elseif throwable.ItemName == "Grappling Hook" then
				instance2:PivotTo(CFrame.lookAt(v, v + v3))
			else
				local v7 = 0.125 * v3.Magnitude / maxSpeed
				local v8 = math.rad(360 * (v7 * p4 % 0.8) / 0.8)
				local v9 = math.rad(360 * (v7 * p4 % 1.3) / 1.3)
				local v10 = math.rad(360 * (v7 * p4 % 0.5) / 0.5)
				instance2:PivotTo(CFrame.new(v) * CFrame.Angles(v8, v9, v10))
			end
		end

		local raycastResult

		if (v2 - v).Magnitude > 0.01 then
			raycastResult = workspace:Raycast(v2, v - v2, raycastParams)
		end

		if raycastResult then
			cleanUp()
			local partBoundsInRadius = workspace:GetPartBoundsInRadius(
				raycastResult.Position,
				throwable.HitRadius,
				overlapParams
			)
			local characters = {}

			for _, v8 in partBoundsInRadius do
				local parent = v8.Parent

				if not parent or not parent:IsA("Model") or characters[parent] or not parent:FindFirstChildOfClass("Humanoid") then
					continue
				end

				local primaryPart2 = parent.PrimaryPart

				if not primaryPart2 then
					continue
				end

				local v9 = math.clamp(
					(primaryPart2.Position - raycastResult.Position).Magnitude / throwable.HitRadius,
					0,
					1
				)
				characters[parent] = evalNumberSequence(throwable.Influence, v9)
			end

			local v8 = {
				Type = "ImpactData",
				Position = raycastResult.Position,
				Normal = raycastResult.Normal,
				Hit = raycastResult.Instance,
				InverseImpactNormal = -v3.Unit,
				Throw = {
					Type = "ThrowData",
					UID = GUID,
					Aim = aim,
					Throwable = throwable,
					Thrower = playerFromCharacter,
					Tags = {}
				},
				Characters = characters
			}
			TableUtil.deepFreeze(v8)
			impact = v8
			callback(v8)
		elseif now + 10 < p4 then
			cleanUp()
			callback(nil)
		end
	end

	if p2 then
		local v7 = 1 / p2
		local total = 0

		for _ = 1, math.ceil(10 * p2) do
			total += v7
			onStep(v7, now + total)

			if not flag then
				break
			end
		end

		if flag then
			cleanUp()
			callback(nil)
		end

		return Result.ok({
			Type = "Simulated",
			Impact = impact
		})
	else
		if RunService:IsClient() then
			table.insert(connections, RunService.RenderStepped:Connect(function(dt)
				onStep(dt, tick())
			end))
		else
			table.insert(connections, RunService.Heartbeat:Connect(function(dt)
				onStep(dt, tick())
			end))
		end

		return Result.ok({
			Type = "Async",
			CleanUp = cleanUp
		})
	end
end

return Effects