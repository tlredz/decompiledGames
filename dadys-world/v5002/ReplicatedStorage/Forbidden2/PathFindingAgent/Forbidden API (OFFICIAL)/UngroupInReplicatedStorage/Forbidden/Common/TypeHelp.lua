local createVector = vector.create
local Debris = game:GetService("Debris")
local v = {}
local TypeHelp = {}
local Storage = require(script.Parent.Parent.Common.Storage)
local count = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function GetNumberedName()
	count += 1
	return "AUTO-NAMED " .. tostring(count)
end

local function _MakePart(position: Vector3, p)
	local v2

	if p then
		v2 = v[p]
	end

	if v2 == nil then
		v2 = Instance.new("Part")
		v2.Transparency = 1
		v2.CanCollide = false
		v2.Anchored = true
		v2.CastShadow = true
		v2.Material = Enum.Material.Neon
		v2.Color = Color3.fromHex("#FFFF00")
		v2.Size = createVector(1, 1, 1)
		v2.Name = GetNumberedName()
		v2.Parent = Storage.GetForbiddenWSPartsFolder()

		if p then
			v[p] = v2
		end
	end

	v2.Position = position
	return v2
end

local function GetBasePartFromModel(instance)
	if instance:FindFirstChildOfClass("Humanoid") then
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart ~= nil then
			return humanoidRootPart
		end

		local torso = instance:FindFirstChild("Torso")

		if torso ~= nil then
			return torso
		end
	end

	if instance.PrimaryPart then
		return instance.PrimaryPart
	end

	local basePart = instance:FindFirstChildOfClass("BasePart")
	return basePart or nil
end

function TypeHelp.GetBasePart(instance, flag: boolean?, p)
	local typeName = typeof(instance)

	if typeName == "Instance" then
		if instance:IsA("BasePart") then
			return instance
		end

		if instance:IsA("Model") then
			return (GetBasePartFromModel(instance))
		end

		local character = instance:IsA("Player") and instance.Character

		if character then
			return (GetBasePartFromModel(character))
		end
	end

	if typeName == "CFrame" and flag then
		return (_MakePart(instance.Position, p))
	end

	if typeName == "Vector3" and flag then
		return (_MakePart(instance, p))
	end

	return nil
end

function TypeHelp.GetDistanceFromNPCToTarget(p, p2)
	local basePart = TypeHelp.GetBasePart(p)
	local basePart2 = TypeHelp.GetBasePart(p2, true, p)

	if basePart == nil then
		error("NPC Actual nil")
	end

	if basePart2 == nil then
		error("Target Actual nil")
	end

	return (basePart.CFrame.Position - basePart2.CFrame.Position).Magnitude
end

function TypeHelp.TriggerCleanup(p)
	if not v[p] then
		return
	end

	Debris:AddItem(v[p], 0)
	v[p] = nil
end

return TypeHelp