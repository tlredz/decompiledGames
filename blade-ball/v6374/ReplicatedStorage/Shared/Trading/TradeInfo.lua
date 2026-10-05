local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Freeze)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local v3 = require3(ReplicatedStorage2.Shared.t)
require3(ReplicatedStorage2.ServerInfo)
local frozen = table.freeze({
	Processing = 1,
	Completed = 2,
	Canceled = 3,
	Reverted = 4
})
local mapped = v2.Dictionary.map(frozen, function(p, p2)
	return p2, p
end)
return {
	DisabledTokensProducts = require3(script.DisabledTokensProducts),
	TradableItemTypes = { "Sword", "Emote", "Explosion" },
	Remotes = {
		SendTradeRequest = v:RemoteFunction("Trading/SendTradeRequest"),
		RespondToTradeRequest = v:RemoteFunction("Trading/RespondToTradeRequest"),
		ReceivedTradeRequest = v:RemoteEvent("Trading/ReceivedTradeRequest"),
		TradeStatus = v:RemoteEvent("Trading/TradeStatus"),
		SetFriendState = v:RemoteEvent("Trading/SetFriendState"),
		SetUIOpen = v:RemoteEvent("Trading/SetUIOpen"),
		CancelTrade = v:RemoteFunction("Trading/CancelTrade"),
		ReadyUp = v:RemoteFunction("Trading/ReadyUp"),
		ConfirmTrade = v:RemoteFunction("Trading/ConfirmTrade"),
		AddItemToTrade = v:RemoteFunction("Trading/AddItemToTrade"),
		AddTokensToTrade = v:RemoteFunction("Trading/AddTokensToTrade"),
		RemoveItemFromTrade = v:RemoteFunction("Trading/RemoveItemFromTrade"),
		ClearItemsFromTrade = v:RemoteFunction("Trading/ClearItemsFromTrade"),
		SendChatMessage = v:RemoteFunction("Trading/SendChatMessage"),
		ReceiveChatMessage = v:RemoteEvent("Trading/ReceiveChatMessage"),
		PurchaseProductWithTokens = v:RemoteFunction("Trading/PurchaseProductWithTokens"),
		ViewInventory = v:RemoteFunction("Trading/ViewInventory"),
		GetTradeHistoryPage = v:RemoteFunction("Trading/GetTradeHistoryPage"),
		AddToPageHistory = v:RemoteEvent("Trading/AddToPageHistory"),
		SetSetting = v:RemoteFunction("Trading/SetSetting"),
		Notification = v:RemoteEvent("Trading/Notification")
	},
	TradeRequestExpiration = 10,
	ItemChangeCountdown = 3,
	ConfirmedCountdown = 5,
	HistoryRequestsPerMinute = 3,
	TradeBoothTax = 0.01,
	MaxItemsInTrade = 100,
	MaxListingInBooth = 50,
	ViewInventoryCooldown = 5,
	ViewInventoryCooldownPerPlayer = 60,
	TradeStatusToId = frozen,
	TradeIdToStatus = mapped,
	Chat = {
		MinMessageLength = 1,
		MaxMessageLength = 200,
		Cooldown = 2,
		QuickMessages = {
			"Need to unlist from booth!",
			"Final offer",
			"Bad trade",
			"One sec",
			"Add more value",
			"Overpay?",
			"Fair?",
			"Best I can do",
			"No swords/explosions/emotes"
		}
	},
	Settings = {
		AllowRequests = {
			Validate = v3.union(v3.literal("Everyone"), v3.literal("Friends"), v3.literal("None")),
			Type = "Option",
			Options = { "Everyone", "Friends", "None" }
		},
		ViewInventory = {
			Validate = v3.union(v3.literal("Everyone"), v3.literal("Friends"), v3.literal("None")),
			Type = "Option",
			Options = { "Everyone", "Friends", "None" }
		},
		UnfairTradeWarning = {
			Validate = v3.boolean,
			Type = "Toggle"
		},
		LowPriceWarning = {
			Validate = v3.boolean,
			Type = "Toggle"
		}
	},
	SmallerSlotColors = {
		Default = {
			StrokeColor = Color3.fromRGB(56, 124, 198),
			Image = "rbxassetid://18762878556",
			HoverImage = "rbxassetid://18762879705"
		},
		Legendary = {
			StrokeColor = Color3.fromRGB(25, 25, 1),
			Image = "rbxassetid://18762878993",
			HoverImage = "rbxassetid://18762880108"
		},
		Unique = {
			StrokeColor = Color3.fromRGB(116, 1, 1),
			Image = "rbxassetid://18762878113",
			HoverImage = "rbxassetid://18762879306"
		},
		Limited = {
			StrokeColor = Color3.fromRGB(92, 2, 104),
			Image = "rbxassetid://18762878754",
			HoverImage = "rbxassetid://18762879868"
		},
		LimitedU = {
			StrokeColor = Color3.fromRGB(92, 2, 104),
			Image = "rbxassetid://18762878754",
			HoverImage = "rbxassetid://18762879868"
		},
		Secret = {
			StrokeColor = Color3.fromRGB(0, 0, 0),
			Image = "rbxassetid://18762878315",
			HoverImage = "rbxassetid://18762879508"
		}
	},
	SlotColors = {
		Default = {
			StrokeColor = Color3.fromRGB(56, 124, 198),
			Image = "rbxassetid://18613794501",
			HoverImage = "rbxassetid://18613794725"
		},
		Rare = {
			StrokeColor = Color3.fromRGB(17, 72, 131),
			Image = "rbxassetid://18598610277",
			HoverImage = "rbxassetid://18598629358"
		},
		Legendary = {
			StrokeColor = Color3.fromRGB(25, 25, 1),
			Image = "rbxassetid://18598610074",
			HoverImage = "rbxassetid://18598629071"
		},
		Unique = {
			StrokeColor = Color3.fromRGB(116, 1, 1),
			Image = "rbxassetid://18598610651",
			HoverImage = "rbxassetid://18598630116"
		},
		Limited = {
			StrokeColor = Color3.fromRGB(92, 2, 104),
			Image = "rbxassetid://18598610449",
			HoverImage = "rbxassetid://18598629663"
		},
		LimitedU = {
			StrokeColor = Color3.fromRGB(92, 2, 104),
			Image = "rbxassetid://18598610449",
			HoverImage = "rbxassetid://18598629663"
		},
		Secret = {
			StrokeColor = Color3.fromRGB(0, 0, 0),
			Image = "rbxassetid://18598611170",
			HoverImage = "rbxassetid://18598630628"
		}
	}
}