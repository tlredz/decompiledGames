local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Enclave = require(script.Enclave)
local enclave = Enclave("Settings")
local enclave2 = Enclave("GetRemote")
local DiscoveredSDK = {}

function DiscoveredSDK.PerkUsed(_)
	enclave2("DiscoveredSDK:PerkUsed"):Fire()
end

function DiscoveredSDK.PromptPassPurchase(_)
	MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, enclave.GAMEPASS_ID)
end

function DiscoveredSDK.PerkClaimed(_)
	enclave2("DiscoveredSDK:PerkClaimed"):Fire()
end

function DiscoveredSDK.PassSeen(_)
	enclave2("DiscoveredSDK:PassSeen"):Fire()
end

function DiscoveredSDK.PassViewed(_)
	enclave2("DiscoveredSDK:PassViewed"):Fire()
end

return DiscoveredSDK