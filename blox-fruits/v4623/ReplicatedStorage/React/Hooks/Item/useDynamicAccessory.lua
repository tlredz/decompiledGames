local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local AccessoriesShared = require(game.ReplicatedStorage.AccessoriesShared)
local ItemReplication = require(game.ReplicatedStorage.React.Factories.Hooks.ItemReplication)
local IS_EQUIPPED = ItemReplication.use(ItemReplication.KEYS.IS_EQUIPPED)
local ACCESSORY_GRADE = ItemReplication.use(ItemReplication.KEYS.ACCESSORY_GRADE)
local ACCESSORY_TYPE = ItemReplication.use(ItemReplication.KEYS.ACCESSORY_TYPE)
local v = ItemReplication.use(ItemReplication.KEYS.ACCESSORY_MODIFIERS, function(value: string?)
	if value and value ~= "" then
		return (value:split(","))
	end

	return {}
end)
return function(value, p, p2: string?)
	local v2 = nil

	if type(value) == "string" and p then
		v2 = ItemId.getId(value, p):asNullable()
	elseif type(value) == "number" then
		p2 = p
		v2 = value
	end

	local v3 = IS_EQUIPPED(v2, p2)
	local v4 = ACCESSORY_GRADE(v2, p2)
	local v5 = ACCESSORY_TYPE(v2, p2)
	local v6 = v(v2, p2)
	return React.useMemo(function()
		if v2 and p2 and RunService:IsRunning() then
			return AccessoriesShared.getReplicatedAccessoryItem(v2, p2)
		end
	end, {
		v2,
		p2,
		v3,
		v4,
		v5,
		v6
	})
end