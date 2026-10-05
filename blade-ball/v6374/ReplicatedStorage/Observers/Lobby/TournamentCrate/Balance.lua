local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Common.Utils)
local TournamentCrateController = require(ReplicatedStorage.Controllers.TournamentCrateController)
return Observers.observeTagNoAncestry("TournamentCrateNPC", function(p)
	p.Text = TournamentCrateController.BalanceText
	local balanceTextChangedConnection = TournamentCrateController.BalanceTextChanged:Connect(function(text)
		p.Text = text
	end)
	return function()
		balanceTextChangedConnection:Disconnect()
	end
end)