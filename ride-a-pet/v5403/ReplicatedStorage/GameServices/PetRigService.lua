local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local assets = ReplicatedStorage:WaitForChild("Assets")
local pets = assets:WaitForChild("Pets")
local v = { "InitialPoses", "AnimSaves" }
local v2 = { "Seat", "invisible_box" }

local function HideRideSeat(instance)
	for _, childName in v2 do
		local part = instance:FindFirstChild(childName, true)

		if not (part and part:IsA("BasePart")) then
			continue
		end

		part.Transparency = 1
		part.CanCollide = false
		part.CastShadow = false
	end
end

local isServer = RunService:IsServer()
local PetRigService = {}
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function HasEditorFolders(model)
	for _, childName in v do
		if model:FindFirstChild(childName) then
			return true
		end
	end

	return false
end

local function MakeLean(folder)
	for _, childName in v do
		local child = folder:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end

	HideRideSeat(folder)

	for _, descendant in folder:GetDescendants() do
		if not (descendant:IsA("LuaSourceContainer") or descendant:IsA("Humanoid") or descendant:IsA("ProximityPrompt")) then
			continue
		end

		descendant:Destroy()
	end

	folder.PrimaryPart = folder:FindFirstChild("RootPart") or folder:FindFirstChild("Handle") or folder:FindFirstChildWhichIsA(
		"BasePart",
		true
	)
	folder:RemoveTag("Pet")
	return folder
end

local function BuildLean(model)
	local clone = model:Clone()
	local parent

	if clone:IsA("Model") then
		parent = clone
	else
		parent = Instance.new("Model")
		parent.Name = clone.Name

		for _, child in clone:GetChildren() do
			child.Parent = parent
		end

		clone:Destroy()
	end

	return (MakeLean(parent))
end

PetRigService.BuildLean = BuildLean

function PetRigService.GetTemplate(childName)
	if typeof(childName) ~= "string" then
		return nil
	end

	local model = pets:FindFirstChild(childName)

	if isServer then
		if not model then
			return nil
		end

		if model:IsA("Model") then
			-- equivalent call inferred; original call site unknown
			if HasEditorFolders(model) then
				MakeLean(model)
			end

			return model
		else
			local lean = BuildLean(model)
			model:Destroy()
			lean.Parent = pets
			return lean
		end
	else
		if v3[childName] then
			return v3[childName]
		end

		local model2 = model or pets:WaitForChild(childName, 5)

		if not model2 then
			return nil
		end

		if model2:IsA("Model") then
			-- equivalent call inferred; original call site unknown
			if not HasEditorFolders(model2) then
				return model2
			end
		end

		local lean = BuildLean(model2)
		v3[childName] = lean
		return lean
	end
end

function PetRigService.Build(p)
	local template = PetRigService.GetTemplate(p)
	return template and template:Clone() or nil
end

local v4 = {}

function PetRigService.WarmAnimations(childName)
	if isServer or typeof(childName) ~= "string" or v4[childName] then
		return
	end

	local child = pets:FindFirstChild(childName)
	local animations = child and child:FindFirstChild("Animations")

	if not animations then
		return
	end

	v4[childName] = true
	task.spawn(function()
		local animations2 = {}

		for _, animation in animations:GetChildren() do
			if animation:IsA("Animation") then
				table.insert(animations2, animation)
			end
		end

		pcall(function()
			local ContentProvider = game:GetService("ContentProvider")
			ContentProvider:PreloadAsync(animations2)
		end)
	end)
end

local Pets = require(script.Parent.Parent:WaitForChild("GameData"):WaitForChild("Pets"))

local function SyncConfigSpeed(model)
	local pet = Pets[model.Name]
	local walkSpeed = pet and (tonumber(pet.WalkSpeed) or tonumber(pet.Speed) or tonumber(pet.FlySpeed))

	if not walkSpeed then
		return nil
	end

	local data = model:FindFirstChild("Data")

	if not data then
		return nil
	end

	local v5 = data:FindFirstChild("Speed")

	if not v5 then
		v5 = Instance.new("IntValue")
		v5.Name = "Speed"
		v5.Parent = data
	end

	if v5.Value == walkSpeed then
		return nil
	end

	local value = v5.Value
	v5.Value = walkSpeed
	return string.format("%s %s -> %d", model.Name, tostring(value), walkSpeed)
end

function PetRigService.EnsureAll()
	if not isServer then
		return
	end

	local v5 = {}
	local names = {}

	for _, model in pets:GetChildren() do
		local syncConfigSpeed = SyncConfigSpeed(model)

		if syncConfigSpeed then
			table.insert(v5, syncConfigSpeed)
		end

		if model:IsA("Model") then
			-- equivalent call inferred; original call site unknown
			if HasEditorFolders(model) then
				table.insert(names, model.Name)
			end
		else
			table.insert(names, model.Name)
		end

		local template = PetRigService.GetTemplate(model.Name)

		if template then
			MakeLean(template)
		end
	end

	if #names > 0 then
		warn("[PetRigService] stripped editor folders at boot from: " .. table.concat(names, ", ") .. " - keep the authored original in ServerStorage.PetSources and store the lean model in Assets.Pets, or every client downloads the baggage before this runs")
	end

	if #v5 > 0 then
		print("[PetRigService] rig Data.Speed realigned to GameData: " .. table.concat(v5, ", "))
	end
end

function PetRigService.HideRideSeat(p)
	HideRideSeat(p)
end

function PetRigService.VisibleExtentsY(folder)
	local v5 = nil
	local v6 = nil

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part.Transparency < 1) then
			continue
		end

		local cFrame = part.CFrame
		local size = part.Size
		local v7 = 0.5 * (math.abs(cFrame.XVector.Y) * size.X + math.abs(cFrame.YVector.Y) * size.Y + math.abs(cFrame.ZVector.Y) * size.Z)
		local v8 = cFrame.Position.Y - v7
		local v9 = cFrame.Position.Y + v7

		if not v5 or v8 < v5 then
			v5 = v8
		end

		if not v6 or v6 < v9 then
			v6 = v9
		end
	end

	if not v5 then
		local boundingBox, v7 = folder:GetBoundingBox()
		v5 = boundingBox.Position.Y - v7.Y / 2
		v6 = boundingBox.Position.Y + v7.Y / 2
	end

	return v5, v6
end

function PetRigService.RideScaleRatio(instance)
	local template = PetRigService.GetTemplate(instance:GetAttribute("PetName") or instance.Name)
	local scale = template and template:GetScale() or 0

	if scale <= 0 then
		return 1
	end

	return instance:GetScale() / scale
end

PetRigService.RideScaleInfluence = 0.6

function PetRigService.RideOffset(instance, p)
	local rideScaleRatio = PetRigService.RideScaleRatio(instance)
	local data = instance:FindFirstChild("Data")
	local rideScaleInfluence = data and data:FindFirstChild("RideScaleInfluence")
	local v5 = math.clamp(
		tonumber(rideScaleInfluence and rideScaleInfluence.Value) or PetRigService.RideScaleInfluence,
		0,
		1
	)
	local volcanoScaleFactor = instance:GetAttribute("VolcanoScaleFactor") or 1
	return p * (1 + (rideScaleRatio / volcanoScaleFactor - 1) * v5) * volcanoScaleFactor
end

function PetRigService:PinBillboard(instance, p2, value)
	if not (self and instance and instance.PrimaryPart) then
		return
	end

	if p2 then
		self.Size = p2.Size

		if self.MaxDistance ~= 1e999 then
			self.MaxDistance = p2.MaxDistance
		end
	end

	local v5 = value or 0
	local visibleExtentsY, v6 = PetRigService.VisibleExtentsY(instance)

	if v5 >= 0 then
		visibleExtentsY = v6 or visibleExtentsY
	end

	self.StudsOffset = Vector3.new(0, visibleExtentsY - instance.PrimaryPart.Position.Y + v5, 0)
end

local function VisibleBounds(folder)
	local vector = nil
	local vector2 = nil

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part.Transparency < 1) then
			continue
		end

		local cFrame = part.CFrame
		local size = part.Size
		local vector3 = Vector3.new(
			0.5 * (math.abs(cFrame.XVector.X) * size.X + math.abs(cFrame.YVector.X) * size.Y + math.abs(cFrame.ZVector.X) * size.Z),
			0.5 * (math.abs(cFrame.XVector.Y) * size.X + math.abs(cFrame.YVector.Y) * size.Y + math.abs(cFrame.ZVector.Y) * size.Z),
			0.5 * (math.abs(cFrame.XVector.Z) * size.X + math.abs(cFrame.YVector.Z) * size.Y + math.abs(cFrame.ZVector.Z) * size.Z)
		)
		local v5 = cFrame.Position - vector3
		local v6 = cFrame.Position + vector3

		if vector then
			vector = Vector3.new(math.min(vector.X, v5.X), math.min(vector.Y, v5.Y), (math.min(vector.Z, v5.Z))) or v5
		else
			vector = v5
		end

		if vector2 then
			vector2 = Vector3.new(math.max(vector2.X, v6.X), math.max(vector2.Y, v6.Y), (math.max(vector2.Z, v6.Z))) or v6
		else
			vector2 = v6
		end
	end

	if vector then
		return CFrame.new((vector + vector2) / 2), vector2 - vector
	end

	return folder:GetBoundingBox()
end

local v5 = {}

local function WaitForPartsThenApply(instance, p, p2, p3)
	if v5[instance] == p3 then
		return
	end

	v5[instance] = p3
	task.spawn(function()
		local v6 = os.clock() + 10

		while os.clock() < v6 and instance.Parent do
			if instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true) then
				v5[instance] = nil
				PetRigService.ApplyMutationAura(instance, p, p2, p3)
				return
			else
				task.wait(0.1)
			end
		end

		v5[instance] = nil
	end)
end

function PetRigService.EggAuraBoost(instance)
	if not instance then
		return 1
	end

	local _, v6 = instance:GetBoundingBox()
	return math.clamp((v6.Magnitude - 6) / 6, 0, 1) * -0.5 + 2
end

function PetRigService.ApplyMutationAura(parent, childName, p, value)
	local name = value or "MutationHitbox"

	if not parent then
		return false
	end

	local primaryPart = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart", true)

	if primaryPart then
		local child = parent:FindFirstChild(name)

		if child then
			child:Destroy()
		end

		local mutationEffects = assets:FindFirstChild("MutationEffects")
		local child2 = mutationEffects and childName and mutationEffects:FindFirstChild(childName)

		if not child2 then
			return false
		end

		local cFrame, v8 = VisibleBounds(parent)
		local part = Instance.new("Part")
		part.Name = name
		local v9 = (childName == "Gold" or childName == "Diamond" or childName == "Rainbow") and 3 or 0
		part.Size = v8 + Vector3.new(v9 * 2, v9 * 2, v9 * 2)
		part.CFrame = cFrame
		part.Transparency = 1
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Massless = true
		part.Anchored = false
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = primaryPart
		weldConstraint.Part1 = part
		weldConstraint.Parent = part
		local v10 = math.min(math.clamp(v8.Magnitude / 14, 0.4, 4) * (tonumber(p) or 1), 4)

		local function ScaleEmitter(p2)
			if math.abs(v10 - 1) <= 0.01 then
				return
			end

			local numberSequenceKeypoints = {}

			for _, keypoint in p2.Size.Keypoints do
				table.insert(
					numberSequenceKeypoints,
					NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * v10, keypoint.Envelope * v10)
				)
			end

			p2.Size = NumberSequence.new(numberSequenceKeypoints)
		end

		for _, child3 in child2:GetChildren() do
			if child3:IsA("ParticleEmitter") then
				local clone = child3:Clone()
				ScaleEmitter(clone)
				clone.Parent = part
			elseif child3:IsA("Attachment") then
				local clone = child3:Clone()
				clone.Position *= v10

				for _, emitter in clone:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						ScaleEmitter(emitter)
					end
				end

				clone.Parent = part
			end
		end

		part.Parent = parent
		return true
	else
		if childName and v5[parent] ~= name then
			v5[parent] = name
			task.spawn(function()
				local v7 = os.clock() + 10

				while os.clock() < v7 and parent.Parent do
					if parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart", true) then
						v5[parent] = nil
						PetRigService.ApplyMutationAura(parent, childName, p, name)
						return
					else
						task.wait(0.1)
					end
				end

				v5[parent] = nil
			end)
		end

		return false
	end
end

local MutationSkinService = require(script.Parent:WaitForChild("MutationSkinService"))

function PetRigService.MutationSkin(p, p2)
	return MutationSkinService.Get(p, p2)
end

function PetRigService.ApplyMutationSkin(p, p2)
	return MutationSkinService.Apply(p, p2)
end

function PetRigService.PlayIdle(instance)
	local animations = instance and instance:FindFirstChild("Animations")
	local idle = animations and animations:FindFirstChild("Idle")

	if not (idle and idle:IsA("Animation")) then
		return nil
	end

	local animationController = instance:FindFirstChildWhichIsA("AnimationController", true)

	if not animationController then
		return nil
	end

	local v6 = animationController:FindFirstChildWhichIsA("Animator")

	if not v6 then
		v6 = Instance.new("Animator")
		v6.Parent = animationController
	end

	local success, result = pcall(function()
		return v6:LoadAnimation(idle)
	end)

	if not (success and result) then
		return nil
	end

	result.Looped = true
	result.Priority = Enum.AnimationPriority.Idle
	result:Play()
	return result
end

return PetRigService