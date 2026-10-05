local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Net = require(ReplicatedStorage.packages.Net)
local Trove = require(ReplicatedStorage.packages.Trove)
local remoteEvent = Net:RemoteEvent("LivingGarden/PlantSeed")
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local v = {
	"Violet Seed",
	"Cyan Seed",
	"Canary Seed",
	"Living Seed",
	"Rotted Seed"
}
local models = ReplicatedStorage.resources.models
local maid = nil
local maid2 = nil
local targetFilter = nil

local function getPlantableAreas()
	return CollectionService:GetTagged("PlantableArea")
end

local function isOverPlantableArea()
	for _, v3 in CollectionService:GetTagged("PlantableArea") do
		local pointToObjectSpace = v3.CFrame:PointToObjectSpace(mouse.Hit.Position)
		local halfSize = v3.Size / 2
		local v5

		if math.abs(pointToObjectSpace.X) <= halfSize.X and math.abs(pointToObjectSpace.Y) <= halfSize.Y + 2 then
			v5 = math.abs(pointToObjectSpace.Z) <= halfSize.Z
		else
			v5 = false
		end

		if v5 then
			return true
		end
	end

	return false
end

local function createPreviewModel(name: string)
	local child = models:FindFirstChild(name)

	if not child then
		return nil
	end

	local clone = child:Clone()
	clone.Name = "PlacementPreview"

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 0.5
	end

	local basePart = not clone.PrimaryPart and clone:FindFirstChildWhichIsA("BasePart")

	if basePart then
		clone.PrimaryPart = basePart
	end

	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopPlacing()
	if maid then
		maid:Clean()
		maid = nil
	end

	targetFilter = nil
	mouse.TargetFilter = nil
end

local function startPlacing(tool)
	if maid or #CollectionService:GetTagged("PlantableArea") == 0 then
		return
	end

	maid = Trove.new()
	targetFilter = createPreviewModel(tool.Name)

	if not targetFilter then
		return
	end

	targetFilter.Parent = workspace
	maid:Add(targetFilter)
	mouse.TargetFilter = targetFilter
	local folder = targetFilter
	local v3 = nil
	local total = 0
	local total2 = 0
	maid:Add(RunService.Heartbeat:Connect(function(dt)
		if not folder then
			return
		end

		local overPlantableArea = isOverPlantableArea()
		local transparency = overPlantableArea and 0.5 or 0.85

		for _, part in folder:GetDescendants() do
			if part:IsA("BasePart") then
				part.Transparency = transparency
			end
		end

		local position = mouse.Hit.Position
		local v5 = not v3 and 0 or (position.X - v3.X) / math.max(dt, 0.001)
		local v6 = not v3 and 0 or (position.Z - v3.Z) / math.max(dt, 0.001)
		total += (v5 - total) * math.min(1, 10 * dt)
		total2 += (v6 - total2) * math.min(1, 10 * dt)
		v3 = position

		if overPlantableArea then
			local now = os.clock()
			local vector2 = Vector3.new(total, 0, total2)
			local magnitude = vector2.Magnitude
			local cframe = CFrame.new()

			if magnitude > 0.5 then
				local cross = vector2.Unit:Cross(createVector(0, 1, 0))

				if cross.Magnitude > 0.001 then
					local v7 = math.clamp(magnitude / 18, 0, 1) * 0.4886921905584123
					cframe = CFrame.fromAxisAngle(cross.Unit, v7)
				end
			end

			local v7 = 1 - math.min(1, magnitude / 7.2)
			local v8 = math.sin(now * 2.4) * 0.19198621771937624 * v7
			local v9 = math.sin(now * 1.6 + 1.2) * 0.12217304763960307 * v7
			local v10 = math.sin(now * 0.85 + 2.7) * 0.08726646259971647 * v7 + 1.5707963267948966
			local v11 = position + Vector3.new(0, math.sin(now * 2.4) ^ 2 * 0.07 * v7, 0)
			local v12 = CFrame.Angles(1.5707963267948966, v10, 1.5707963267948966) * CFrame.Angles(v8, 0, v9)
			folder:PivotTo(CFrame.new(v11) * cframe * v12)
		end
	end))
	maid:Add(tool.Activated:Connect(function()
		if isOverPlantableArea() then
			remoteEvent:FireServer(mouse.Hit.Position, tool.Name)
		end
	end))
	maid:Add(tool.Unequipped:Connect(stopPlacing))
end

local function setupCharacter(character)
	if maid2 then
		maid2:Clean()
	end

	maid2 = Trove.new()
	stopPlacing() -- equivalent call inferred; original call site unknown
	local tool = character:FindFirstChildOfClass("Tool")

	if tool and table.find(v, tool.Name) then
		startPlacing(tool)
	end

	maid2:Add(character.ChildAdded:Connect(function(tool2)
		if tool2:IsA("Tool") and table.find(v, tool2.Name) then
			startPlacing(tool2)
		end
	end))
	maid2:Add(character.ChildRemoved:Connect(function(tool2)
		if tool2:IsA("Tool") and table.find(v, tool2.Name) then
			stopPlacing() -- equivalent call inferred; original call site unknown
		end
	end))
end

return {
	Start = function(_)
		if localPlayer.Character then
			setupCharacter(localPlayer.Character)
		end

		localPlayer.CharacterAdded:Connect(setupCharacter)
	end
}