local scammerZiolesTrigger = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild(
	"ScammerZiolesTrigger",
	1000000
)
local GachaClient = require(game.ReplicatedStorage.Controllers.GachaClient)
scammerZiolesTrigger.OnClientEvent:Connect(function()
	local gachaAsync = GachaClient.GetGachaAsync("AprilFoolsGacha26")

	if not gachaAsync.ENABLED then
		return
	end

	game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", gachaAsync.BOX_NAME)
end)