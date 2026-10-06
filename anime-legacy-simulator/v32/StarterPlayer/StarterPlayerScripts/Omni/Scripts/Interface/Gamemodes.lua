local module = require("@game/ReplicatedStorage/Omni")
local Controller = require(script.Controller)
local Gamemodes = {}

function Gamemodes.Init()
	local parties = module.Scripts.General.Parties

	if parties then
		parties.SyncEvent:Connect(Controller.OnSync)
		parties.DisbandedEvent:Connect(Controller.OnDisbanded)
		parties.KickedEvent:Connect(Controller.OnKicked)
		parties.LeftEvent:Connect(Controller.OnLeft)
		parties.BrowseChangedEvent:Connect(Controller.OnBrowseChanged)
	end

	Controller.Init()
end

function Gamemodes.Start(p: string)
	Controller.Start(p)
end

return Gamemodes