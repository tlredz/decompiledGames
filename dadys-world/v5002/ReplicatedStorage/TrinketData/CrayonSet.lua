local CrayonSet = {
	Name = "Crayon Set",
	Icon = "rbxassetid://17653809753",
	Rarity = "Common",
	Description = "Grants a random item from the Uncommon tier every new Floor (If user's Inventory has a slot open). Dandy's Shop exclusive items are included.",
	TrinketType = "Passive",
	MonsterTrinket = true,
	Cost = 350
}
CrayonSet.Requirement1 = { "Coin", CrayonSet.Cost }
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {
	Common = {},
	Uncommon = {}
}

local function getnumberofitemsintier(p)
	local v2 = {}

	for _, v3 in pairs(v[p]) do
		table.insert(v2, v3)
	end

	return #v2
end

local function RandomItem()
	local v2 = {}

	for k, v3 in pairs({
		Uncommon = 100
	}) do
		local count = 0

		repeat
			table.insert(v2, k)
			count += 1
		until count == v3
	end

	local v3 = v2[math.random(1, #v2)]
	local v4 = v[v3]
	local v5 = {}

	for _, v7 in pairs(v[v3]) do
		table.insert(v5, v7)
	end

	return v4[math.random(1, #v5)]
end

local FloorItemPool = require(ReplicatedStorage.Modules.FloorItemPool)
v.Uncommon = FloorItemPool.Build(function(p, p2)
	return p2.Rarity == "Uncommon" and p ~= "Tape"
end).Uncommon

function CrayonSet.ApplyTrinket(instance, p)
	workspace.Info.Floor.Changed:Connect(function()
		local inventory = instance:WaitForChild("Inventory")
		local slot1 = inventory:WaitForChild("Slot1")
		local slot2 = inventory:WaitForChild("Slot2")
		local slot3 = inventory:WaitForChild("Slot3")
		local slot4 = inventory:FindFirstChild("Slot4")
		local v2 = false

		if p.Name == "Trinket2" then
			task.wait()
		end

		if slot1.Value == "None" then
			slot1.Value = tostring(RandomItem().Name)
			v2 = true
		end

		if slot2.Value == "None" and not v2 then
			slot2.Value = tostring(RandomItem().Name)
			v2 = true
		end

		if slot3.Value == "None" and not v2 then
			slot3.Value = tostring(RandomItem().Name)
			v2 = true
		end

		if slot4 and slot4.Value == "None" and not v2 then
			slot4.Value = tostring(RandomItem().Name)
		end
	end)
end

function CrayonSet.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	instance:WaitForChild("Stats")
	instance:WaitForChild("WalkSpeed")
	instance:WaitForChild("RunSpeed")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if trinket1.Value == script.Name then
		trinket1.Value = "None"
		return "Slot1"
	end

	if trinket2.Value ~= script.Name then
		return "CantRemove"
	end

	trinket2.Value = "None"
	return "Slot2"
end

return CrayonSet