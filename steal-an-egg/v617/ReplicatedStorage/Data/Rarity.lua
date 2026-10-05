local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local v = {
	"BrainrotGod",
	"Common",
	"Cosmic",
	"Divine",
	"Epic",
	"Eternal",
	"Legendary",
	"LightDark",
	"Limited",
	"Mythic",
	"Rainbow",
	"Rare",
	"Secret",
	"SuperRare",
	"Titan",
	"Transcendent",
	"Uncommon"
}
local v2 = {
	Prismatic = "Rainbow"
}
local interface = t.interface({
	_id = t.string,
	DisplayName = t.string,
	Rank = t.integer,
	Color = t.Color3,
	RarityGradient = t.instanceIsA("UIGradient"),
	ItemTemplate = t.instanceIsA("TextButton")
})

local function byName(p, p2)
	return p.Name < p2.Name
end

local function loadTiers(configs)
	local children = configs:GetChildren()
	table.sort(children, byName)
	local v3 = {}

	for _, moduleScript in children do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local module = require(moduleScript)
		local v4, v5 = interface(module)

		if not v4 then
			error((`rarity config {moduleScript.Name} is malformed: {v5}`))
		end

		if module._id ~= moduleScript.Name then
			error((`rarity config {moduleScript.Name} declares _id "{module._id}"`))
		end

		v3[moduleScript.Name] = module
	end

	for _, v4 in v do
		if v3[v4] == nil then
			error((`rarity tier "{v4}" has no config module`))
		end
	end

	for k, v4 in v2 do
		v3[k] = v3[v4]
	end

	return table.freeze(v3)
end

local rarities = loadTiers(script.Configs)
return table.freeze({
	Rarities = rarities,
	Get = function(p: string)
		local v4 = rarities[p]

		if v4 == nil then
			error(`"{p}" is not a registered rarity tier`, 2)
		end

		return v4
	end,
	RarityNameExists = function(p: string)
		if rarities[p] == nil then
			return false, (`"{p}" is not a registered rarity tier`)
		end

		return true
	end
})