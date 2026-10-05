local v = {
	"Common",
	"Uncommon",
	"Rare",
	"VeryRare",
	"UltraRare"
}
local FloorItemPool = {}

function FloorItemPool.IsInSeason(p, p2)
	if not p.Holiday then
		return true
	end

	if p2 and p2.ENABLED and p2.ContentFlag then
		return p[p2.ContentFlag] == true
	end

	return false
end

function FloorItemPool.Build(callback)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local result = {}

	for _, v2 in ipairs(v) do
		result[v2] = {}
	end

	local items = ReplicatedStorage:FindFirstChild("Items")

	if not items then
		warn("[FloorItemPool] ReplicatedStorage.Items missing — pool entries are UNVERIFIED (no Tool check)")
	end

	local itemModules = ReplicatedStorage:FindFirstChild("ItemModules")

	if not itemModules then
		warn("[FloorItemPool] ReplicatedStorage.ItemModules missing; returning empty pool")
		return result
	end

	for _, moduleScript in ipairs(itemModules:GetChildren()) do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local success, result2 = pcall(require, moduleScript)

		if success and type(result2) == "table" then
			if callback(moduleScript.Name, result2) then
				if result[result2.Rarity] then
					if items and not items:FindFirstChild(moduleScript.Name) then
						warn("[FloorItemPool] Module " .. moduleScript.Name .. " has no matching Tool in ReplicatedStorage.Items — skipping")
					else
						table.insert(result[result2.Rarity], {
							Name = moduleScript.Name,
							Rarity = result2.Rarity
						})
					end
				else
					warn("[FloorItemPool] " .. moduleScript.Name .. " has unknown Rarity: " .. tostring(result2.Rarity))
				end
			end
		else
			warn("[FloorItemPool] Failed to require " .. moduleScript.Name .. ": " .. tostring(result2))
		end
	end

	return result
end

return FloorItemPool