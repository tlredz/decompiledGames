local module = require("@game/ReplicatedStorage/Omni")
return {
	PromptToFavorite = function()
		if module.Data.AntiAfk.PromptedFavorite then
			return
		end

		if pcall(function()
			return module.Services.AvatarEditorService:PromptSetFavorite(game.PlaceId, Enum.AvatarItemType.Asset, true)
		end) then
			module.Signal:Fire("Player", "AntiAfk", "SetValue", "PromptedFavorite", true)
		end
	end
}