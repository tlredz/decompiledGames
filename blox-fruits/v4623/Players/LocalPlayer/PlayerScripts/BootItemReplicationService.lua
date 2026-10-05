local ItemReplicationService = require(game.ReplicatedStorage.ItemReplicationService)
local BuildInfo = require(game.ReplicatedStorage.BuildInfo)

if not ItemReplicationService.IsInitialized then
	ItemReplicationService.init()
end

if BuildInfo.BRANCH == "workspace/cj_oyer" then
	local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
	assert(ItemReplicationService.IsInitialized and ItemReplicationService.IS_CLIENT, "bad service")
	ItemReplicationService:ConnectOnChanged(function(p, p2, value, p3, p4)
		local unwrapped = ItemConfig.match(p2):unwrap()
		print((`received {unwrapped.Index.DebugLabel}{not value and "" or `({value:sub(1, 6)})`} "{p}": {p4} -> {p3}`))
	end)
end