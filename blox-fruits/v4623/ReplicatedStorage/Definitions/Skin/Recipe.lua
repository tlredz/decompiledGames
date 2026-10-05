local Option = require(game.ReplicatedStorage.Packages.Option)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local FunctionCache = require(game.ReplicatedStorage.Util.FunctionCache)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local IdMap = require(game.ReplicatedStorage.IdMap)
local v73 = {
	{
		ItemId = IdMap.Skin["Bright Yellow"],
		Ingredients = {
			[IdMap.Material["Yellow Star Berry"]] = 1
		}
	},
	{
		ItemId = IdMap.Skin["Orange Soda"],
		Ingredients = {
			[IdMap.Material["Orange Berry"]] = 1
		}
	},
	{
		ItemId = IdMap.Skin["Slimy Green"],
		Ingredients = {
			[IdMap.Material["Green Toad Berry"]] = 1
		}
	},
	{
		ItemId = IdMap.Skin["Yellow Sunshine"],
		Ingredients = {
			[IdMap.Material["Yellow Star Berry"]] = 1,
			[IdMap.Material["White Cloud Berry"]] = 1
		}
	},
	{
		ItemId = IdMap.Skin["Green Lizard"],
		Ingredients = {
			[IdMap.Material["Green Toad Berry"]] = 1,
			[IdMap.Material["White Cloud Berry"]] = 1
		}
	},
	{
		ItemId = IdMap.Skin["Blue Jeans"],
		Ingredients = {
			[IdMap.Material["Blue Icicle Berry"]] = 3
		}
	},
	{
		ItemId = IdMap.Skin["Plump Purple"],
		Ingredients = {
			[IdMap.Material["Purple Jelly Berry"]] = 3
		}
	},
	{
		ItemId = IdMap.Skin["Fiery Rose"],
		Ingredients = {
			[IdMap.Material["Pink Pig Berry"]] = 2,
			[IdMap.Material["Red Cherry Berry"]] = 2
		}
	},
	{
		ItemId = IdMap.Skin["Heat Wave"],
		Ingredients = {
			[IdMap.Material["Orange Berry"]] = 2,
			[IdMap.Material["Red Cherry Berry"]] = 2
		}
	},
	{
		ItemId = IdMap.Skin["Absolute Zero"],
		Ingredients = {
			[IdMap.Material["Blue Icicle Berry"]] = 5
		}
	},
	{
		ItemId = IdMap.Skin["Snow White"],
		Ingredients = {
			[IdMap.Material["White Cloud Berry"]] = 10
		}
	},
	{
		ItemId = IdMap.Skin["Pure Red"],
		Ingredients = {
			[IdMap.Material["Red Cherry Berry"]] = 15
		}
	},
	{
		ItemId = IdMap.Skin["Winter Sky"],
		Ingredients = {
			[IdMap.Material["Pink Pig Berry"]] = 15
		}
	},
	{
		ItemId = IdMap.Skin["Light Pink"],
		Ingredients = {
			[IdMap.Material["Pink Pig Berry"]] = 5,
			[IdMap.Material["Red Cherry Berry"]] = 3,
			[IdMap.Material["White Cloud Berry"]] = 1
		}
	},
	{
		ItemId = IdMap.Skin.Dragon,
		Ingredients = {
			[IdMap.Material["Red Cherry Berry"]] = 6,
			[IdMap.Material["Pink Pig Berry"]] = 8,
			[IdMap.Material["Orange Berry"]] = 3
		}
	},
	{
		ItemId = IdMap.Skin.FALCSKINvelvet,
		Ingredients = {
			[IdMap.Material["Purple Jelly Berry"]] = 4,
			[IdMap.Material["Fire Feather"]] = 2
		}
	},
	{
		ItemId = IdMap.Skin.FALCSKINfalcon,
		Ingredients = {
			[IdMap.Material["White Cloud Berry"]] = 2,
			[IdMap.Material["Fire Feather"]] = 3
		}
	},
	{
		ItemId = IdMap.Skin.FALCSKINbluesky,
		Ingredients = {
			[IdMap.Material["Green Toad Berry"]] = 3,
			[IdMap.Material["Yellow Star Berry"]] = 1,
			[IdMap.Material["Fire Feather"]] = 5
		}
	},
	{
		ItemId = IdMap.Skin.FALCSKINgoldmoss,
		Ingredients = {
			[IdMap.Material["Blue Icicle Berry"]] = 3,
			[IdMap.Material["Yellow Star Berry"]] = 1,
			[IdMap.Material["Fire Feather"]] = 5
		}
	},
	{
		ItemId = IdMap.Skin.FALCSKINocreamsicle,
		Ingredients = {
			[IdMap.Material["White Cloud Berry"]] = 4,
			[IdMap.Material["Orange Berry"]] = 1,
			[IdMap.Material["Fire Feather"]] = 8
		}
	},
	{
		ItemId = IdMap.Skin.WSTDSKINorange,
		Ingredients = {
			[IdMap.Material["Orange Berry"]] = 2
		}
	},
	{
		ItemId = IdMap.Skin.WSTDSKINyellow,
		Ingredients = {
			[IdMap.Material["Yellow Star Berry"]] = 2
		}
	},
	{
		ItemId = IdMap.Skin.WSTDSKINblue,
		Ingredients = {
			[IdMap.Material["Blue Icicle Berry"]] = 2
		}
	},
	{
		ItemId = IdMap.Skin.WSTDSKINred,
		Ingredients = {
			[IdMap.Material["Red Cherry Berry"]] = 5
		}
	},
	{
		ItemId = IdMap.Skin.WSTDSKINpurple,
		Ingredients = {
			[IdMap.Material["Purple Jelly Berry"]] = 8
		}
	},
	{
		ItemId = IdMap.Skin.WSTDSKINblack,
		Ingredients = {
			[IdMap.Material["Red Cherry Berry"]] = 1,
			[IdMap.Material["White Cloud Berry"]] = 1,
			[IdMap.Material["Yellow Star Berry"]] = 1,
			[IdMap.Material["Purple Jelly Berry"]] = 1,
			[IdMap.Material["Green Toad Berry"]] = 1,
			[IdMap.Material["Pink Pig Berry"]] = 1,
			[IdMap.Material["Orange Berry"]] = 1,
			[IdMap.Material["Blue Icicle Berry"]] = 1
		}
	},
	{
		ItemId = IdMap.Skin.WSTDSKINfrostbite,
		Ingredients = {
			[IdMap.Material["White Cloud Berry"]] = 3,
			[IdMap.Material["Blue Icicle Berry"]] = 5
		}
	},
	{
		ItemId = IdMap.Skin.WSTDSKINemerald,
		Ingredients = {
			[IdMap.Material["White Cloud Berry"]] = 3,
			[IdMap.Material["Green Toad Berry"]] = 5
		}
	},
	{
		ItemId = IdMap.Skin.ESTDSKINorange,
		Ingredients = {
			[IdMap.Material["Orange Berry"]] = 2
		}
	},
	{
		ItemId = IdMap.Skin.ESTDSKINyellow,
		Ingredients = {
			[IdMap.Material["Yellow Star Berry"]] = 2
		}
	},
	{
		ItemId = IdMap.Skin.ESTDSKINblue,
		Ingredients = {
			[IdMap.Material["Blue Icicle Berry"]] = 5
		}
	},
	{
		ItemId = IdMap.Skin.ESTDSKINred,
		Ingredients = {
			[IdMap.Material["Red Cherry Berry"]] = 5
		}
	},
	{
		ItemId = IdMap.Skin.ESTDSKINpurple,
		Ingredients = {
			[IdMap.Material["Purple Jelly Berry"]] = 8
		}
	},
	{
		ItemId = IdMap.Skin.ESTDSKINblack,
		Ingredients = {
			[IdMap.Material["Red Cherry Berry"]] = 1,
			[IdMap.Material["White Cloud Berry"]] = 1,
			[IdMap.Material["Yellow Star Berry"]] = 1,
			[IdMap.Material["Purple Jelly Berry"]] = 1,
			[IdMap.Material["Green Toad Berry"]] = 1,
			[IdMap.Material["Pink Pig Berry"]] = 1,
			[IdMap.Material["Orange Berry"]] = 1,
			[IdMap.Material["Blue Icicle Berry"]] = 1
		}
	},
	{
		ItemId = IdMap.Skin.ESTDSKINfrostbite,
		Ingredients = {
			[IdMap.Material["White Cloud Berry"]] = 3,
			[IdMap.Material["Blue Icicle Berry"]] = 5
		}
	},
	{
		ItemId = IdMap.Skin.ESTDSKINemerald,
		Ingredients = {
			[IdMap.Material["White Cloud Berry"]] = 3,
			[IdMap.Material["Green Toad Berry"]] = 5
		}
	}
}
TableUtil.deepFreeze(v73)
local v74 = FunctionCache.new(function(p, p2)
	local unwrapped = ItemConfig.match(p, p2):unwrap()

	for _, v75 in v73 do
		if v75.ItemId == unwrapped.Index.ItemId then
			return Option.some(v75)
		end
	end

	return Option.none()
end, function(p, p2)
	return (`{p}_{p2}`)
end)
return {
	match = function(p, p2)
		return v74:call(p, p2)
	end
}