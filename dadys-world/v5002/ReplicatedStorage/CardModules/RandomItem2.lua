local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local cardModifiers = workspace.Info.CardModifiers
local _ = workspace.Info.PlayerStats
local FloorItemPool = require(ReplicatedStorage.Modules.FloorItemPool)
local v = FloorItemPool.Build(function(p, p2)
	return p ~= "Tape" and p ~= "Ornament" and not p2.AbilityOnlyItem
end)

local function getnumberofitemsintier(p, _)
	local v2 = {}

	for _, v3 in pairs(v[p]) do
		table.insert(v2, v3)
	end

	return #v2
end

function RandomItem(_)
	local v2

	if workspace.Info.CardModifiers:FindFirstChild("ItemRarity") and workspace.Info.CardModifiers:FindFirstChild("ItemRarity2") then
		v2 = {
			Common = 50,
			Uncommon = 35,
			Rare = 19,
			VeryRare = 7,
			UltraRare = 3
		}
	elseif workspace.Info.CardModifiers:FindFirstChild("ItemRarity") then
		v2 = {
			Common = 50,
			Uncommon = 35,
			Rare = 17,
			VeryRare = 6,
			UltraRare = 2
		}
	elseif workspace.Info.CardModifiers:FindFirstChild("ItemRarity2") then
		v2 = {
			Common = 50,
			Uncommon = 35,
			Rare = 17,
			VeryRare = 6,
			UltraRare = 2
		}
	else
		v2 = {
			Common = 50,
			Uncommon = 35,
			Rare = 15,
			VeryRare = 5,
			UltraRare = 1
		}
	end

	local v3 = {}

	for k, v4 in pairs(v2) do
		local count = 0

		repeat
			table.insert(v3, k)
			count += 1
		until count == v4
	end

	local v4 = v3[math.random(1, #v3)]
	local v5 = v[v4]
	local v6 = {}

	for _, v8 in pairs(v[v4]) do
		table.insert(v6, v8)
	end

	return v5[math.random(1, #v6)]
end

return {
	Name = "Lost and Found",
	Icon = "rbxassetid://17702363394",
	Description = "Every Toon will recieve one random Item if they have an inventory slot open.",
	ApplyCardEffects = function()
		if not cardModifiers:FindFirstChild(script.Name) then
			local numberValue = Instance.new("NumberValue")
			numberValue.Name = script.Name
			numberValue.Value = 10
			numberValue.Parent = cardModifiers

			for _, child in pairs(workspace.InGamePlayers:GetChildren()) do
				if not (child:FindFirstChild("Humanoid") and child.Humanoid.Health > 0) then
					continue
				end

				local inventory = child:WaitForChild("Inventory")
				local slot1 = inventory:WaitForChild("Slot1")
				local slot2 = inventory:WaitForChild("Slot2")
				local slot3 = inventory:WaitForChild("Slot3")
				local slot4 = inventory:FindFirstChild("Slot4")
				local v2 = false
				local v3 = RandomItem()
				local name

				if v3 then
					name = v3.Name
				else
					warn("No item found.")
					name = "Pop"
				end

				if slot1.Value == "None" then
					slot1.Value = tostring(name)
					v2 = true
				end

				if slot2.Value == "None" and not v2 then
					slot2.Value = tostring(name)
					v2 = true
				end

				if slot3.Value == "None" and not v2 then
					slot3.Value = tostring(name)
					v2 = true
				end

				if not slot4 or slot4.Value ~= "None" or v2 then
					continue
				end

				slot4.Value = tostring(name)
			end
		end
	end
}