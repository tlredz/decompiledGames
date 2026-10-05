local React = require(game.ReplicatedStorage.Packages.React)
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
return function(value, p)
	return React.useMemo(function()
		if not value then
			return
		end

		local v

		if type(value) == "number" then
			v = ItemConfig.match(value):asNullable()
		elseif type(value) == "string" and p then
			v = ItemConfig.match(value, p):asNullable()
		else
			return
		end

		if v == nil then
			return nil
		end

		local rarity = v.Quality.Rarity

		if rarity then
			return (RarityUtil.tryGetRarity(rarity))
		end

		return nil
	end, { value, p })
end