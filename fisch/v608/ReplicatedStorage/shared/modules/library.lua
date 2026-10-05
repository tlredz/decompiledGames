local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage.shared
local values = {}
local enchants = require(script.rods.enchants)
local Library = {
	enchants = enchants.Enchants
}
local items = require(script.items)
Library.items = items.Items
local items2 = require(script.items)
Library.keyItems = items2.KeyItems
local mutations = require(shared.modules.fishing.mutations)
Library.mutations = mutations.Mutations
local SkinCrates = require(shared.modules.SkinCrates)
Library.skinCrates = SkinCrates.List
local mastery = require(script.rods.mastery)
Library.masteries = mastery.Mastery
Library.zones = require(script.fish.zones)
Library.spears = require(script.spears)
Library.rarities = require(script.rarities)
Library.weathers = require(script.weathers)
local vessels = require(shared.modules.vessels)
Library.vessels = vessels.library
local bobbers = require(shared.modules.fishing.bobbers)
Library.bobbers = bobbers.Bobbers
local RodSkins = require(shared.modules.RodSkins)
Library.skins = RodSkins.Skins
local WitcherPotions = require(shared.modules.WitcherPotions)
Library.potions = WitcherPotions.Potions
local companions = require(script.companions)
Library.companions = companions.Companions
local Utilities = require(shared.modules.Utilities)
Library.utilities = Utilities.all

local function fn(script2, moduleScript)
	if values[moduleScript] then
		return values[moduleScript]
	end

	if moduleScript.Parent == script2 then
		return moduleScript.Name
	end

	local parent = moduleScript
	local names = {}

	while parent do
		table.insert(names, parent.Name)

		if parent.Parent == script2 then
			break
		else
			parent = parent.Parent
		end
	end

	local v = {}

	for i = #names, 1, -1 do
		table.insert(v, names[i])
	end

	local joined = table.concat(v, "/")
	values[moduleScript] = joined
	return joined
end

for _, moduleScript in script:GetDescendants() do
	local v = fn(script, moduleScript)

	if not moduleScript:IsA("ModuleScript") or Library[v] then
		continue
	end

	local module = require(moduleScript)
	Library[v] = module
end

return Library