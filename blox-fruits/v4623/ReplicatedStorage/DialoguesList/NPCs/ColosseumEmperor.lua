require(game.ReplicatedStorage.DialoguesList.Types)
local v = {
	"You bested my Gladiators in the sand, warrior. The crowd has not stopped talking about it.",
	"Rest easy. You have already proven yourself in my arena."
}
return {
	Title = "Emperor",
	Get = function(_)
		local BonusMomentsController = require(game.ReplicatedStorage.Controllers.BonusMomentsController)
		local kingsApprentice = BonusMomentsController:GetLoadedMoments()["King's Apprentice"]
		local kingsApprentice2 = script:FindFirstChild("King's Apprentice")

		if not kingsApprentice or kingsApprentice.Completed or not kingsApprentice2 then
			return {
				Text = table.clone(v)
			}
		end

		local module = require(kingsApprentice2)

		if typeof(module) == "function" then
			return (module())
		end

		return module
	end
}