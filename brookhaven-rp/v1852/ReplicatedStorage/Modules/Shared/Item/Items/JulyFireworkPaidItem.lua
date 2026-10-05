local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Shared.Advertisements.AdFeatures)
local DisplayItem = require(ReplicatedStorage.Modules.Shared.Item.DisplayItem)
local MenuItem = require(ReplicatedStorage.Modules.Shared.Item.MenuItem)
require(ReplicatedStorage.Modules.Shared.Fireworks.FireworkConstants)
local JulyFireworkPaidItem = {}
JulyFireworkPaidItem.__index = JulyFireworkPaidItem
JulyFireworkPaidItem.Inherits = { DisplayItem, MenuItem }

function JulyFireworkPaidItem.Cast(p)
	return p
end

function JulyFireworkPaidItem.new(id: string, displayName: string?, icon: string, fireworkType, fireworkCornerIcon: string?)
	local self = setmetatable({
		id = id,
		displayName = displayName,
		icon = icon,
		fireworkType = fireworkType,
		fireworkCornerIcon = fireworkCornerIcon
	}, JulyFireworkPaidItem)
	self.__index = JulyFireworkPaidItem
	return self
end

function JulyFireworkPaidItem.OnDenied(p, callback, value: string, _)
	local FireworkController = require(ReplicatedStorage.Modules.Client.Fireworks.FireworkController)
	local promptPurchase = FireworkController.PromptPurchase(p.fireworkType, value or "ToolsMenu")

	if promptPurchase == "AT_CAP" then
		callback("Purchase limit reached.")
	elseif promptPurchase == "BACKEND_ERROR" then
		callback("Could not start purchase. Try again.")
	end
end

function JulyFireworkPaidItem.GetName(p)
	return p.id
end

function JulyFireworkPaidItem.GetDisplayName(p)
	return p.displayName or p.id
end

function JulyFireworkPaidItem.GetIcon(p)
	return p.icon
end

function JulyFireworkPaidItem.GetCornerIcon(p)
	return p.fireworkCornerIcon
end

function JulyFireworkPaidItem.IsAlwaysVisible(_)
	return true
end

function JulyFireworkPaidItem.IsUnlockedServer(p, p2)
	local ServerScriptService = game:GetService("ServerScriptService")
	local FireworkService = require(ServerScriptService.Modules.Fireworks.FireworkService)
	return FireworkService.GetPaidRemainingUses(p2, p.fireworkType) > 0
end

function JulyFireworkPaidItem.IsUnlockedClient(p)
	local FireworkController = require(ReplicatedStorage.Modules.Client.Fireworks.FireworkController)
	return FireworkController.GetPaidRemainingUses(p.fireworkType) > 0
end

function JulyFireworkPaidItem.GetAdFeature(_)
	return nil
end

function JulyFireworkPaidItem.ShowCornerIcon(p)
	return p.fireworkCornerIcon ~= nil and p.fireworkCornerIcon ~= ""
end

return JulyFireworkPaidItem