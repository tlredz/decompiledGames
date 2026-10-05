local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local v = require3(script.Parent.ClansUpgradeData)
require3(script.Parent.ClansData)
local v2 = {
	Abilities = {
		["Calming Deflection"] = {
			Level = 2,
			Upgrades = {
				Luck = 4,
				CoinEarning = 6,
				Welfare = 6,
				Size = 5
			}
		},
		["Quantum Arena"] = {
			Level = 2,
			Upgrades = {
				Luck = 6,
				CoinEarning = 7,
				Welfare = 7,
				Size = 7
			}
		}
	}
}

local function checkRequirements(p, k: string)
	local v3 = assert(v2.Abilities[k], (`{k} is not a valid ability!`))

	if p.clanLevel < v3.Level then
		return false
	end

	for k2, upgrade in v3.Upgrades do
		local _, v4 = v.getClanUpgrade(p, k2)

		if v4 - 1 < upgrade then
			return false
		end
	end

	return true
end

v2.checkRequirementsFor = checkRequirements

function v2.getClanAbilities(p)
	local abilities = {}

	for k, ability in v2.Abilities do
		if checkRequirements(p, k) then
			abilities[k] = ability
		end
	end

	return abilities
end

return table.freeze(v2)