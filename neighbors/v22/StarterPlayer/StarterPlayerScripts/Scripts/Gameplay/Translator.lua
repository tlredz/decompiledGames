local localPlayer = game.Players.LocalPlayer
local Network = require(game.ReplicatedStorage.Modules.Network)
local LocalizationService = game:GetService("LocalizationService")
local Chat = game:GetService("Chat")
game:GetService("HttpService")
local success, result = pcall(function()
	return LocalizationService:GetTranslatorForPlayerAsync(localPlayer)
end)
Network:listen("ShowTranslatedText", function(p, p2)
	if not success then
		Chat:Chat(p, p2)
		return
	end

	Chat:Chat(p, result:Translate(game, p2) or p2)
end)