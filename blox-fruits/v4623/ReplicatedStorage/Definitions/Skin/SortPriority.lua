local Option = require(game.ReplicatedStorage.Packages.Option)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local FunctionCache = require(game.ReplicatedStorage.Util.FunctionCache)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local IdMap = require(game.ReplicatedStorage.IdMap)
local v = {
	["Bright Yellow"] = {
		ItemId = IdMap.Skin["Bright Yellow"],
		Order = 1
	},
	["Orange Soda"] = {
		ItemId = IdMap.Skin["Orange Soda"],
		Order = 2
	},
	["Slimy Green"] = {
		ItemId = IdMap.Skin["Slimy Green"],
		Order = 4
	},
	["Yellow Sunshine"] = {
		ItemId = IdMap.Skin["Yellow Sunshine"],
		Order = 3
	},
	["Green Lizard"] = {
		ItemId = IdMap.Skin["Green Lizard"],
		Order = 5
	},
	["Blue Jeans"] = {
		ItemId = IdMap.Skin["Blue Jeans"],
		Order = 6
	},
	["Plump Purple"] = {
		ItemId = IdMap.Skin["Plump Purple"],
		Order = 7
	},
	["Fiery Rose"] = {
		ItemId = IdMap.Skin["Fiery Rose"],
		Order = 9
	},
	["Heat Wave"] = {
		ItemId = IdMap.Skin["Heat Wave"],
		Order = 10
	},
	["Absolute Zero"] = {
		ItemId = IdMap.Skin["Absolute Zero"],
		Order = 11
	},
	["Snow White"] = {
		ItemId = IdMap.Skin["Snow White"],
		Order = 12
	},
	["Pure Red"] = {
		ItemId = IdMap.Skin["Pure Red"],
		Order = 13
	},
	["Winter Sky"] = {
		ItemId = IdMap.Skin["Winter Sky"],
		Order = 14
	},
	["Rainbow Saviour"] = {
		ItemId = IdMap.Skin["Rainbow Saviour"],
		Order = 15
	},
	Aquamarine = {
		ItemId = IdMap.Skin.Aquamarine,
		Order = 16
	},
	["Light Pink"] = {
		ItemId = IdMap.Skin["Light Pink"],
		Order = 17
	},
	Kitsune = {
		ItemId = IdMap.Skin.Kitsune,
		Order = 18
	},
	Dragon = {
		ItemId = IdMap.Skin.Dragon,
		Order = 19
	},
	["Oni Aura"] = {
		ItemId = IdMap.Skin["Oni Aura"],
		Order = 20
	},
	["Celestial Aura"] = {
		ItemId = IdMap.Skin["Celestial Aura"],
		Order = 21
	},
	["Hacker Aura"] = {
		ItemId = IdMap.Skin["Hacker Aura"],
		Order = 22
	}
}
TableUtil.deepFreeze(v)
local v2 = FunctionCache.new(function(p, p2)
	local unwrapped = ItemConfig.match(p, p2):unwrap()

	for _, v3 in v do
		if v3.ItemId == unwrapped.Index.ItemId then
			return Option.some(v3)
		end
	end

	return Option.none()
end, function(p, p2)
	return (`{p}_{p2}`)
end)
return {
	match = function(p, p2)
		return v2:call(p, p2)
	end
}