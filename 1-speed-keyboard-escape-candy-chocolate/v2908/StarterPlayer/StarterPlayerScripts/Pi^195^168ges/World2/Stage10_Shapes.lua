local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local _ = {
	Tag = "DoorWall"
}
local v = { "GreenSquare", "RedTriangle", "YellowCircle" }
local v2 = {
	GreenSquare = "GreenDoorKillPart",
	RedTriangle = "RedDoorKillPart",
	YellowCircle = "YellowDoorKillPart"
}
local localPlayer = Players.LocalPlayer
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function pickRandomShape()
	return v[math.random(1, #v)]
end

local function updateIndicator(instance, p: string)
	local indicator = instance:FindFirstChild("Indicator")

	if not indicator then
		return
	end

	for _, part in ipairs(indicator:GetChildren()) do
		if not (part.Name ~= "Frame" and (part.Name == "GreenSquare" or part.Name == "RedTriangle" or part.Name == "YellowCircle")) then
			continue
		end

		local transparency = part.Name == p and 0 or 1

		if part:IsA("BasePart") then
			part.Transparency = transparency
		end

		for _, part2 in ipairs(part:GetDescendants()) do
			if part2:IsA("BasePart") then
				part2.Transparency = transparency
			end
		end
	end
end

local function updateDoors(instance, p: string)
	local doors = instance:FindFirstChild("Doors")

	if not doors then
		return
	end

	local v4 = v2[p]

	for _, part in ipairs(doors:GetChildren()) do
		if not (part.Name == "GreenDoorKillPart" or part.Name == "RedDoorKillPart" or part.Name == "YellowDoorKillPart") then
			continue
		end

		local v5 = part.Name == v4

		if part:IsA("BasePart") then
			part.CanCollide = not v5
		end

		for _, part2 in ipairs(part:GetDescendants()) do
			if part2:IsA("BasePart") then
				part2.CanCollide = not v5
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyRandomShape(p)
	local randomShape = pickRandomShape() -- equivalent call inferred; original call site unknown
	updateIndicator(p, randomShape)
	updateDoors(p, randomShape)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onSafeDoorTouched(p)
	if v3[p] then
		return
	end

	v3[p] = true
	task.delay(2, function()
		applyRandomShape(p) -- equivalent call inferred; original call site unknown
		v3[p] = nil
	end)
end

local function connectDoorTouch(model)
	local doors = model:FindFirstChild("Doors")

	if not doors then
		return
	end

	for _, part in ipairs(doors:GetChildren()) do
		if not (part.Name == "GreenDoorKillPart" or part.Name == "RedDoorKillPart" or part.Name == "YellowDoorKillPart") then
			continue
		end

		local parts = {}

		if part:IsA("BasePart") then
			table.insert(parts, part)
		end

		for _, part2 in ipairs(part:GetDescendants()) do
			if part2:IsA("BasePart") then
				table.insert(parts, part2)
			end
		end

		for _, v4 in ipairs(parts) do
			local v5 = v4
			v4.Touched:Connect(function(otherPart)
				if not otherPart.Parent then
					return
				end

				local character = localPlayer.Character

				if not character or otherPart.Parent ~= character then
					return
				end

				if v5.CanCollide == false then
					onSafeDoorTouched(model) -- equivalent call inferred; original call site unknown
				end
			end)
		end
	end
end

local function setupModel(model)
	if not model:IsA("Model") then
		return
	end

	applyRandomShape(model) -- equivalent call inferred; original call site unknown
	connectDoorTouch(model)
	localPlayer.CharacterAdded:Connect(function()
		task.wait(0.1)
		v3[model] = nil
		applyRandomShape(model) -- equivalent call inferred; original call site unknown
	end)
end

for _, v4 in ipairs(CollectionService:GetTagged("DoorWall")) do
	setupModel(v4)
end

CollectionService:GetInstanceAddedSignal("DoorWall"):Connect(setupModel)