local Maid = require(game.ReplicatedStorage.Util.Maid)
local v = {}
local v2 = nil
local v3 = false
local TavernDoors = {
	LoadForLocations = { "Pirate Village" },
	Maid = Maid.new()
}

local function teardown()
	local v4 = v2
	v2 = nil

	if v4 then
		v4:Destroy()
	end

	for _, v5 in v do
		local part = v5.Part

		if not part.Parent then
			continue
		end

		part.Transparency = v5.Transparency
		part.CanCollide = v5.CanCollide
		part.CanQuery = v5.CanQuery
		part.CanTouch = v5.CanTouch
	end

	table.clear(v)
end

local function build(folder)
	local models = {}

	for _, model in folder:GetDescendants() do
		if model:IsA("Model") and (model.Name == "Leftdoor" or model.Name == "Rightdoor") then
			table.insert(models, model)
		end
	end

	if #models == 0 then
		return nil
	end

	local folder2 = Instance.new("Folder")
	folder2.Name = "LocalTavernDoors"

	for _, folder3 in models do
		local clone = folder3:Clone()

		for _, part in clone:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			if part.Name == "door" then
				part.Anchored = false
			elseif part.Name == "hinge" then
				part.Anchored = true
			end
		end

		clone.Parent = folder2

		for _, part in folder3:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			table.insert(v, {
				Part = part,
				Transparency = part.Transparency,
				CanCollide = part.CanCollide,
				CanQuery = part.CanQuery,
				CanTouch = part.CanTouch
			})
			part.Transparency = 1
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
		end
	end

	folder2.Parent = folder
	return folder2
end

local function findTavernDoor()
	local map = workspace:FindFirstChild("Map")
	local pirate

	if map then
		pirate = map:FindFirstChild("Pirate")
	end

	local tavernNEW

	if pirate then
		tavernNEW = pirate:FindFirstChild("TavernNEW")
	end

	if tavernNEW then
		return (tavernNEW:FindFirstChild("TavernDoor"))
	end

	return nil
end

function TavernDoors.Rebuild(_)
	if not v3 then
		return
	end

	local map = workspace:FindFirstChild("Map")
	local pirate

	if map then
		pirate = map:FindFirstChild("Pirate")
	end

	local tavernNEW

	if pirate then
		tavernNEW = pirate:FindFirstChild("TavernNEW")
	end

	local tavernDoor

	if tavernNEW then
		tavernDoor = tavernNEW:FindFirstChild("TavernDoor")
	end

	if not tavernDoor then
		return
	end

	teardown()
	v2 = build(tavernDoor)
end

function TavernDoors.RegionEntered(p)
	v3 = true
	local maid = p.Maid
	maid:GiveTask(teardown)
	maid:GiveTask(task.spawn(function()
		local pirate = workspace:WaitForChild("Map"):WaitForChild("Pirate", 30)

		if not pirate then
			return
		end

		local tavernNEW = pirate:WaitForChild("TavernNEW", 30)

		if not tavernNEW then
			return
		end

		local tavernDoor = tavernNEW:WaitForChild("TavernDoor", 30)

		if not tavernDoor or not v3 or v2 then
			return
		end

		v2 = build(tavernDoor)

		if v2 then
			maid:GiveTask(v2)
		end
	end))
end

function TavernDoors.RegionLeaving(_)
	v3 = false
	teardown()
end

return TavernDoors