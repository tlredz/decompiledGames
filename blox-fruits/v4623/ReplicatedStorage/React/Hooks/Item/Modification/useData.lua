local Players = game:GetService("Players")
local Modification = require(game.ReplicatedStorage.Util.Modification)
local ItemReplicationService = require(game.ReplicatedStorage.ItemReplicationService)
local IdMap = require(game.ReplicatedStorage.IdMap)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("Modifications"):tag("UI"):tag("React"):minLevel("WARN"):traceback():display():build()
local useDrawContext = require(game.ReplicatedStorage.React.Hooks.useDrawContext)
local useGlobalState = require(game.ReplicatedStorage.React.Hooks.useGlobalState)
local useTaskPool = require(game.ReplicatedStorage.React.Hooks.useTaskPool)
local useOnScreenEffect = require(game.ReplicatedStorage.React.Hooks.useOnScreenEffect)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local empty = Modification.Data.Modification.empty()
local v2 = Modification.Data.Modification.setUnlock(IdMap.Mutation.TIGERMUTWerewolf, empty, true)
local v3 = Modification.Data.Modification.setUnlock(IdMap.Skin.BOMBSKINazura, v2, true)
return function()
	local v4, v5 = useGlobalState("ModificationData", Modification.Data.Modification.empty())
	local v7 = useTaskPool("ModificationDataListening", useDrawContext() ~= "Offscreen")
	useOnScreenEffect(function()
		local extended = v.extend("useEffect", true)

		if not (ItemReplicationService.IsInitialized and v7) then
			extended.info((`skipping effect: isInit={ItemReplicationService.IsInitialized}, isListening={v7}`))
			return
		end

		assert(ItemReplicationService.IS_CLIENT, "bad service")
		extended.info("hooking up listeners")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateModificationData()
			v5(Modification.Data.Modification.fromItemReplication(Players.LocalPlayer))
		end

		local v8 = {}

		for _, v9 in { ItemReplicationService.KEYS.IS_PREFERRED, ItemReplicationService.KEYS.IS_OWNED } do
			table.insert(v8, ItemReplicationService:ConnectOnKeyChanged(v9, function(p: number, _: string?, _)
				if Modification.getIfModification(p) then
					updateModificationData() -- equivalent call inferred; original call site unknown
				end
			end))
		end

		updateModificationData() -- equivalent call inferred; original call site unknown
		return function()
			for _, v9 in v8 do
				v9()
			end
		end
	end, { ItemReplicationService.IsInitialized, v7 })
	local v8 = useMockState("ModificationData", v3)

	if v8 then
		return (v8:get())
	end

	return v4
end