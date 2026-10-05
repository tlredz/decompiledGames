local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Type = require(game.ReplicatedStorage.Packages.Type)
local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.Spritesheets)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local ModificationController = require(game.ReplicatedStorage.Controllers.ModificationController)
local Modification = require(game.ReplicatedStorage.Util.Modification)
local useCharacter = require(game.ReplicatedStorage.React.Hooks.Player.useCharacter)
local useHasTag = require(game.ReplicatedStorage.React.Hooks.Instance.useHasTag)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local strictInterface = Type.strictInterface({
	SkinItemId = Type.integer,
	Level = Type.optional(Type.integer),
	MaxLevel = Type.integer
})
local unwrapped = ItemId.getId("Basic Aura", "Skin"):unwrap()
return function()
	local state, setState = React.useState(nil)
	React.useEffect(function()
		if not RunService:IsRunning() then
			return function() end
		end

		if ModificationController.IsInitialized == false then
			return function() end
		end

		local onEquipConnection = ModificationController.OnEquip:Connect(function(p: number)
			local unwrapped2 = ItemConfig.match(p):unwrap()

			if unwrapped2.Skin and unwrapped2.Skin.Type == "Aura" then
				setState(unwrapped2.Index.StorageKey)
			end
		end)
		local modification = Modification.Data.Modification.fromItemReplication(Players.LocalPlayer)
		local adornee = Modification.Data.Adornee.fromItemReplication(Players.LocalPlayer)

		for _, v in Modification.getEquipped(modification, adornee) do
			local unwrapped2 = ItemConfig.match(v):unwrap()

			if unwrapped2.Index.IdType == "Skin" and unwrapped2.Skin and unwrapped2.Skin.Type == "Aura" then
				setState(unwrapped2.Index.StorageKey)
			end
		end

		return function()
			onEquipConnection:Disconnect()
		end
	end, {})
	local v = useMockState("AuraSkin", "Blue Jeans")

	if v then
		state = v:get()
	end

	local v2 = React.useMemo(function()
		if state then
			return ItemId.getId(state, "Skin"):asNullable()
		end

		return nil
	end, { state })
	local v3 = useCharacter()
	local v4 = useHasTag("Buso", v3)
	local v5 = useMockState("HasAuraV1", true)

	if v5 then
		v4 = v5:get()
	end

	local level = useHasTag("BusoUpgrade", v3) and 2 or v4 and 1 or nil
	return (React.useMemo(function()
		local v7 = {
			SkinItemId = v2 or unwrapped,
			Level = level,
			MaxLevel = 5
		}
		table.freeze(v7)
		local v8, v9 = strictInterface(v7)

		if not v8 then
			warn((`bad aura info: {v9}`))
		end

		return v7
	end, { v2, level, ModificationController.IsInitialized }))
end