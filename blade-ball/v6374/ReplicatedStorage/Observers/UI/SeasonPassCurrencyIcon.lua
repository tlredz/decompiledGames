local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local module = require("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
return Observers.observeTagNoAncestry("UI_SeasonPassCurrencyIcon", function(guiObject)
	if guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton") then
		guiObject.Image = module.SeasonData.Currency.Icon
	end
end)