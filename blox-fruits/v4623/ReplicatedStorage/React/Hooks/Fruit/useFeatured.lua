local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local ComingSoonUtil = require(game.ReplicatedStorage.Util.ComingSoonUtil)
local GetFeaturedFruits

if RunService:IsRunning() then
	GetFeaturedFruits = require(game.ReplicatedStorage.Modules.Asset.GetFeaturedFruits)
else
	GetFeaturedFruits = nil
end

local useAttribute = require(game.ReplicatedStorage.React.Hooks.Instance.useAttribute)
local frozen = table.freeze({
	IdMap.PhysicalMoveset["Rocket-Rocket"],
	IdMap.PhysicalMoveset["Spring-Spring"],
	IdMap.PhysicalMoveset["Flame-Flame"],
	IdMap.PhysicalMoveset["Magma-Magma"],
	IdMap.PhysicalMoveset["T-Rex-T-Rex"]
})
return function()
	local v = useAttribute(workspace, "FeaturedFruit")
	local v2 = { v, (useAttribute(workspace, ComingSoonUtil.ATTR_KEY)) }
	local v3 = React.useMemo(function()
		if not GetFeaturedFruits or type(v) ~= "string" then
			return nil
		end

		local featuredFruits = GetFeaturedFruits(v)
		local result = {}

		for _, v5 in ipairs(featuredFruits) do
			table.insert(result, ItemId.getId(v5, "Moveset"):unwrap())
		end

		table.freeze(result)
		return result
	end, v2)

	if GetFeaturedFruits then
		local _ = typeof(v) == "string"
	end

	return v3 or frozen
end