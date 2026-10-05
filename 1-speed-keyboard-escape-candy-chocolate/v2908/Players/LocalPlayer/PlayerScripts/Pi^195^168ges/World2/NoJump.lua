local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JumpHeightManager = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("JumpHeightManager"))
local parts = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function addPart(part)
	if part:IsA("BasePart") then
		table.insert(parts, part)
	end
end

local function removePart(p)
	local index = table.find(parts, p)

	if index then
		table.remove(parts, index)
	end
end

local function setupModel(folder)
	for _, descendant in ipairs(folder:GetDescendants()) do
		addPart(descendant) -- equivalent call inferred; original call site unknown
	end

	folder.DescendantAdded:Connect(addPart)
	folder.DescendantRemoving:Connect(removePart)
end

for _, v in ipairs(CollectionService:GetTagged("NoJump")) do
	setupModel(v)
end

CollectionService:GetInstanceAddedSignal("NoJump"):Connect(setupModel)
local localPlayer = Players.LocalPlayer
local v = nil
local humanoid = nil
local humanoidRootPart = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function onCharacterAdded(character)
	v = character
	humanoid = character:WaitForChild("Humanoid")
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	JumpHeightManager.setHumanoid(humanoid)
	JumpHeightManager.release("NoJump")
end

localPlayer.CharacterAdded:Connect(onCharacterAdded)

if localPlayer.Character then
	onCharacterAdded(localPlayer.Character) -- equivalent call inferred; original call site unknown
end

local function isPointInsidePart(p, instance)
	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(p)
	local halfSize = instance.Size / 2
	return math.abs(pointToObjectSpace.X) <= halfSize.X and math.abs(pointToObjectSpace.Y) <= halfSize.Y and math.abs(pointToObjectSpace.Z) <= halfSize.Z
end

RunService.RenderStepped:Connect(function()
	if not (v and humanoid and humanoidRootPart and humanoidRootPart.Parent) then
		return
	end

	local flag = false

	for _, v3 in ipairs(parts) do
		if not (v3 and v3.Parent) then
			continue
		end

		local position = humanoidRootPart.Position
		local pointToObjectSpace = v3.CFrame:PointToObjectSpace(position)
		local halfSize = v3.Size / 2
		local v5

		if math.abs(pointToObjectSpace.X) <= halfSize.X and math.abs(pointToObjectSpace.Y) <= halfSize.Y then
			v5 = math.abs(pointToObjectSpace.Z) <= halfSize.Z
		else
			v5 = false
		end

		if not v5 then
			continue
		end

		flag = true
		break
	end

	if flag then
		JumpHeightManager.set("NoJump", 0, 50)
	else
		JumpHeightManager.release("NoJump")
	end
end)