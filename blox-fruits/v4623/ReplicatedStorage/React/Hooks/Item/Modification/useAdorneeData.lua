local Players = game:GetService("Players")
local Modification = require(game.ReplicatedStorage.Util.Modification)
local ItemReplicationService = require(game.ReplicatedStorage.ItemReplicationService)
local IdMap = require(game.ReplicatedStorage.IdMap)
local useGlobalState = require(game.ReplicatedStorage.React.Hooks.useGlobalState)
local useTaskPool = require(game.ReplicatedStorage.React.Hooks.useTaskPool)
local useOnScreenEffect = require(game.ReplicatedStorage.React.Hooks.useOnScreenEffect)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local useDrawContext = require(game.ReplicatedStorage.React.Hooks.useDrawContext)
local adornee = Modification.Data.Adornee.new(
	{ IdMap.Moveset["Tiger-Tiger"], IdMap.Moveset["Bomb-Bomb"] },
	{ IdMap.Moveset["Bomb-Bomb"] }
)
return function()
	local v, v2 = useGlobalState("AdorneeData", Modification.Data.Adornee.empty())
	local v4 = useTaskPool("AdorneeDataListening", useDrawContext() ~= "Offscreen")
	useOnScreenEffect(function()
		if not (ItemReplicationService.IsInitialized and v4) then
			return
		end

		assert(ItemReplicationService.IS_CLIENT, "bad service")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateAdorneeData()
			v2(Modification.Data.Adornee.fromItemReplication(Players.LocalPlayer))
		end

		local v5 = {}

		for _, v6 in { ItemReplicationService.KEYS.IS_EQUIPPED, ItemReplicationService.KEYS.IS_OWNED } do
			table.insert(v5, ItemReplicationService:ConnectOnKeyChanged(v6, function(p: number, _: string?, _)
				if Modification.getIfAdornee(p) then
					updateAdorneeData() -- equivalent call inferred; original call site unknown
				end
			end))
		end

		updateAdorneeData() -- equivalent call inferred; original call site unknown
		return function()
			for _, v6 in v5 do
				v6()
			end
		end
	end, { ItemReplicationService.IsInitialized, v4 })
	local v5 = useMockState("AdorneeData", adornee)

	if v5 then
		return (v5:get())
	end

	return v
end