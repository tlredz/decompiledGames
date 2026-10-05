local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {
	REMOTE_EVENT = "NPCDrop",
	MAX_NPC_NAME_LENGTH = 64,
	POPUP_TEXT = "-$1"
}

function v.initClient()
	local CurrencyPopup = require(ReplicatedStorage.Controllers.UI.CurrencyPopup)
	local Net = require(ReplicatedStorage.Modules.Net)
	Net:RemoteEvent(v.REMOTE_EVENT).OnClientEvent:Connect(function()
		CurrencyPopup.show(v.POPUP_TEXT)
	end)
end

return table.freeze(v)