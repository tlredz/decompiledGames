require(game.ReplicatedStorage.Packages.SimpleError)
local Result = require(game.ReplicatedStorage.Packages.Result)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Modification = require(game.ReplicatedStorage.Util.Modification)
local Appearance = require(script.Appearance)
local Quest = require(script.Quest)
local Recipe = require(script.Recipe)
local SortPriority = require(script.SortPriority)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("SkinDefinition"):display():traceback():build()
local Skin = {}
Skin.Definition = {
	Appearance = Appearance,
	Quest = Quest,
	Recipe = Recipe,
	SortPriority = SortPriority
}

function Skin.getIfCanPurchase(_, p: number, buf: buffer, buf2: buffer)
	local unwrapped = ItemConfig.match(p):unwrap()

	if Modification.getIfCanUnlock(unwrapped.Index.ItemId, buf, buf2) then
		return Result.ok(true)
	end

	return Result.err("You aren't qualified to unlock this skin")
end

function Skin.getIfCanCraft(p, p2: number, p3: number, p4, p5, buf: buffer, buf2: buffer)
	local unwrapped = ItemConfig.match(p2):unwrap()
	local extended = v.extend("getIfCanCraft", true)
	extended.info((`called fn: (player={p},itemId={unwrapped.Index.DebugLabel},fragments={p3},craftingInventory,skinRecipes,modificationData,adorneeData)`))
	extended.trace(function()
		return "craftingInventory", p4
	end)
	extended.trace(function()
		return "skinRecipes", p5
	end)
	extended.trace(function()
		return "modificationData", Modification.Data.Modification.debug(buf)
	end)
	extended.trace(function()
		return "adorneeData", Modification.Data.Adornee.debug(buf2)
	end)

	if Modification.getIfCanUnlock(unwrapped.Index.ItemId, buf, buf2) then
		local nullable = Recipe.match(unwrapped.Index.ItemId):asNullable()
		extended.trace(function()
			return "recipeDef"
		end)
		local nullable2 = Quest.match(unwrapped.Index.ItemId):asNullable()
		extended.trace(function()
			return "questDef", nullable2
		end)

		if nullable2 then
			if not nullable then
				return Result.err("This skin can only be obtained through a quest")
			end

			if not p5[unwrapped.Index.StorageKey] then
				return Result.err("You need the recipe to craft this skin.")
			end
		end

		if not nullable then
			return Result.err("Skin is not craftable")
		end

		if Modification.getIfCanUnlock(unwrapped.Index.ItemId, buf, buf2) then
			if unwrapped.Quality.FragmentsPrice and p3 < unwrapped.Quality.FragmentsPrice then
				return Result.err("You don't have enough <Color=Purple>ƒ<Color=/>")
			end

			for k, ingredient in nullable.Ingredients do
				local unwrapped2 = ItemConfig.match(k):unwrap()

				if (p4[unwrapped2.Index.StorageKey] or 0) < ingredient then
					return Result.err((`You don't have enough <Color=Yellow>{unwrapped2.Display.Name or unwrapped2.Index.StorageKey}<Color=/>`))
				end
			end

			return Result.ok(true)
		end
	end

	local unwrapped2 = ItemConfig.match(Modification.matchAdornee(unwrapped.Index.ItemId):unwrap()):unwrap()
	local name = unwrapped2.Display.Name or unwrapped2.Index.StorageKey
	return Result.err((`You need to equip <Color=Yellow>{name}<Color=/> to craft this skin.`))
end

return Skin