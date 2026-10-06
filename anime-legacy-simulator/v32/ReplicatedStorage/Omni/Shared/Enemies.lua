local ReplicatedStorage = game:GetService("ReplicatedStorage")
require("@game/ReplicatedStorage/Omni/Settings")
local Number = require(ReplicatedStorage.Omni.Utils.Number)
local v = {
	{
		Difficulty = "Easy",
		Amount = 20
	},
	{
		Difficulty = "Medium",
		Amount = 15
	},
	{
		Difficulty = "Hard",
		Amount = 10
	},
	{
		Difficulty = "Insane",
		Amount = 5
	},
	{
		Difficulty = "Boss",
		Amount = 1
	}
}
local v2 = {
	List = {},
	DifficultySizes = {
		Easy = 1,
		Medium = 1.15,
		Hard = 1.3,
		Insane = 1.45,
		Boss = 2.5,
		Secret = 0.5
	},
	BaseHitboxSize = vector.create(4, 5, 1),
	DamageSources = { "Fighter", "Weapon" },
	StaticModels = {
		["Small Chest"] = {
			Category = "Chests",
			DeathDuration = 0.35
		},
		["Medium Chest"] = {
			Category = "Chests",
			DeathDuration = 0.35
		},
		["Big Chest"] = {
			Category = "Chests",
			DeathDuration = 0.35
		},
		["Training Dummy"] = {
			Category = "Training",
			DeathDuration = 0.35
		}
	}
}

function v2.Register(p: string, items)
	for k, item in items do
		if v2.List[k] then
			items[k] = nil
			warn((`Repeated Enemy: {k}!`))
		else
			item.Name = k

			if typeof(item.Health) == "string" then
				item.Health = Number:Unformat(item.Health)
			end
		end
	end

	v2.List[p] = items
end

function v2.GetHitboxSize(p: string?)
	local v3 = p and v2.DifficultySizes[p] or 1
	return v2.BaseHitboxSize * v3
end

function v2.CreateMissionListForMap(p: string)
	local result = {}
	local v3 = v2.List[p]

	if not v3 then
		return result
	end

	for _, v4 in v do
		local v5 = nil

		for _, v7 in v3 do
			if v7.Difficulty ~= v4.Difficulty then
				continue
			end

			v5 = v7
			break
		end

		if v5 then
			table.insert(result, {
				Title = v5.Name,
				Description = `Kill {v5.Name} {not (v4.Amount > 1) and "once" or `{v4.Amount} times` or "once"}`,
				Type = "Kill",
				Name = v5.Name,
				Amount = v4.Amount
			})
		end
	end

	return result
end

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)

	if module then
		v2.Register(moduleScript.Name, module)
	end
end

return table.freeze(v2)