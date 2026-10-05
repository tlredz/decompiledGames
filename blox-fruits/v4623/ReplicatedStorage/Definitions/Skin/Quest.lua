local Option = require(game.ReplicatedStorage.Packages.Option)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local FunctionCache = require(game.ReplicatedStorage.Util.FunctionCache)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local IdMap = require(game.ReplicatedStorage.IdMap)
local v = {
	{
		ItemId = IdMap.Skin["Yellow Sunshine"]
	},
	{
		ItemId = IdMap.Skin["Green Lizard"]
	},
	{
		ItemId = IdMap.Skin["Blue Jeans"]
	},
	{
		ItemId = IdMap.Skin["Plump Purple"]
	},
	{
		ItemId = IdMap.Skin["Fiery Rose"]
	},
	{
		ItemId = IdMap.Skin["Heat Wave"]
	},
	{
		ItemId = IdMap.Skin["Absolute Zero"]
	},
	{
		ItemId = IdMap.Skin["Snow White"]
	},
	{
		ItemId = IdMap.Skin["Pure Red"]
	},
	{
		ItemId = IdMap.Skin["Winter Sky"]
	},
	{
		ItemId = IdMap.Skin["Rainbow Saviour"]
	},
	{
		ItemId = IdMap.Skin.Aquamarine
	},
	{
		ItemId = IdMap.Skin["Light Pink"]
	},
	{
		ItemId = IdMap.Skin.Kitsune
	},
	{
		ItemId = IdMap.Skin.Dragon
	},
	{
		ItemId = IdMap.Skin.FALCSKINvelvet
	},
	{
		ItemId = IdMap.Skin.FALCSKINfalcon
	},
	{
		ItemId = IdMap.Skin.FALCSKINbluesky
	},
	{
		ItemId = IdMap.Skin.FALCSKINgoldmoss
	},
	{
		ItemId = IdMap.Skin.FALCSKINocreamsicle
	},
	{
		ItemId = IdMap.Skin.WSTDSKINfrostbite
	},
	{
		ItemId = IdMap.Skin.WSTDSKINemerald
	},
	{
		ItemId = IdMap.Skin.ESTDSKINfrostbite
	},
	{
		ItemId = IdMap.Skin.ESTDSKINemerald
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