local module = require("@game/ReplicatedStorage/Omni/Utils/Number")
local Potions = require(script.Parent.Potions)
local v = {
	List = {}
}

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module2 = require(moduleScript)

	for k, v2 in module2 do
		v2.Name = k
		v2.Type = moduleScript.Name

		if not v2.Icon then
			v2.Icon = ""
		end

		if not v2.Rarity then
			v2.Rarity = "Item"
		end

		if not v2.Description then
			v2.Description = "No description given."
		end

		if v2.MaximumAmount then
			v2.MaximumAmount = module:Unformat(v2.MaximumAmount)
		end

		v.List[k] = v2
	end
end

for k, v2 in Potions.List do
	if Potions.IsConfigured(v2) then
		v.List[k] = {
			Name = k,
			Type = "Potions",
			Icon = v2.Icon or "",
			Rarity = v2.Rarity or "Item",
			Description = v2.Description or `{v2.Amount} {v2.Effect} for {v2.Duration} seconds.`
		}
	end
end

return table.freeze(v)