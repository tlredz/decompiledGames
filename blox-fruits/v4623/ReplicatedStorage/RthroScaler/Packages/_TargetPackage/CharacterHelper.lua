local Players = game:GetService("Players")
local parent = script.Parent.Parent
local Deque = require(parent.Deque)
local CharacterHelper = {}
local v = nil

local function getAccurateSize(part)
	if not part:IsA("MeshPart") then
		return part.Size
	end

	local model = Instance.new("Model")
	local clone = part:Clone()
	clone:ClearAllChildren()
	clone.Parent = model
	local extentsSize = model:GetExtentsSize()
	model:Destroy()
	return extentsSize
end

local function getCorners(part0CF: CFrame, accurateSize: Vector3)
	local result = {}

	for i = 0, 7 do
		table.insert(
			result,
			part0CF * (accurateSize * Vector3.new(
				math.floor(i / 4) % 2 * 2 - 1,
				math.floor(i / 2) % 2 * 2 - 1,
				i % 2 * 2 - 1
			) * 0.5)
		)
	end

	return result
end

local function getBodyPartMotorsByPart0(instance, humanoid, rootPart)
	local v2 = {}
	local result = {}

	for _, part in instance:GetChildren() do
		if not (part:IsA("BasePart") and (part == rootPart or humanoid:GetBodyPartR15(part))) then
			continue
		end

		v2[part] = true
		result[part] = {}
	end

	for k, _ in v2 do
		for _, motor6D in k:GetChildren() do
			if not motor6D:IsA("Motor6D") then
				continue
			end

			local part0 = motor6D.Part0
			local part1 = motor6D.Part1

			if part0 and part1 and v2[part0] and v2[part1] then
				table.insert(result[part0], motor6D)
			end
		end
	end

	return result
end

function CharacterHelper.getHeight(instance)
	local humanoid = instance:FindFirstChildWhichIsA("Humanoid")
	local rootPart = humanoid and humanoid.RootPart
	assert(humanoid, "Cannot get the rig height because it's missing a humanoid.")
	assert(rootPart, "Cannot get the rig height because it's missing a root part.")
	local bodyPartMotorsByPart0 = getBodyPartMotorsByPart0(instance, humanoid, rootPart)
	local raw = Deque.raw({
		{
			part0 = rootPart,
			part0CF = CFrame.identity
		}
	})
	local Y = nil

	while raw:getLength() > 0 do
		local v2 = raw:popBack()

		if v2.part0 ~= rootPart then
			local accurateSize = getAccurateSize(v2.part0)

			for _, v3 in getCorners(v2.part0CF, accurateSize) do
				if not Y or Y < v3.Y then
					Y = v3.Y
				end
			end
		end

		for _, v3 in bodyPartMotorsByPart0[v2.part0] do
			local part0CF = v2.part0CF * v3.C0 * v3.C1:Inverse()
			raw:pushBack({
				part0 = v3.Part1,
				part0CF = part0CF
			})
		end
	end

	return humanoid.HipHeight + rootPart.Size.Y / 2 + (Y or 0)
end

function CharacterHelper.getClassicHeight()
	if v then
		return v
	end

	local humanoidDescription = Instance.new("HumanoidDescription")
	humanoidDescription.BodyTypeScale = 1
	humanoidDescription.DepthScale = 1
	humanoidDescription.HeadScale = 1
	humanoidDescription.HeightScale = 1.01
	humanoidDescription.ProportionScale = 1
	humanoidDescription.WidthScale = 1
	local humanoidModelFromDescription = Players:CreateHumanoidModelFromDescription(
		humanoidDescription,
		Enum.HumanoidRigType.R15
	)
	local height = CharacterHelper.getHeight(humanoidModelFromDescription)
	humanoidModelFromDescription:Destroy()
	v = height
	return v
end

return CharacterHelper