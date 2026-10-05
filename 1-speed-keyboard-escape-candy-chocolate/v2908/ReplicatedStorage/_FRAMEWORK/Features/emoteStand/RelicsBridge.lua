local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(script.Parent.Types)
local v = nil
local emotes = nil
local ownership = nil
local v2 = nil
local v3 = nil
local v4 = {}
local values = {}

local function waitForRelicsModule(p: number)
	local v5 = os.clock() + p

	while os.clock() < v5 do
		local relicsXYZ = ReplicatedStorage:FindFirstChild("RelicsXYZ", true)

		if relicsXYZ and relicsXYZ:IsA("ModuleScript") then
			return relicsXYZ
		else
			task.wait(0.5)
		end
	end

	return nil
end

local RelicsBridge = {}

function RelicsBridge.resolve(p: number)
	if v then
		return true
	end

	local v5 = waitForRelicsModule(p)

	if not v5 then
		return false
	end

	local module = require(v5)
	v = module
	emotes = v.Emotes
	ownership = v.Ownership
	local Marketplace = require(v5.Shared.Marketplace)
	v2 = Marketplace
	local RelicsPlayerClient = require((ReplicatedStorage:WaitForChild("UISystems"):WaitForChild("RelicsPlayerClient")))
	v3 = RelicsPlayerClient
	return true
end

function RelicsBridge.isReady()
	return v ~= nil
end

function RelicsBridge.getEmote(p: string)
	if emotes then
		return emotes.GetEmotes()[p]
	end

	return nil
end

function RelicsBridge.getLoadedEmoteNames()
	local result = {}

	if emotes then
		for k in emotes.GetEmotes() do
			table.insert(result, k)
		end
	end

	table.sort(result)
	return result
end

function RelicsBridge.connectEmoteAdded(onEmoteAdded)
	emotes.EmoteAdded:Connect(onEmoteAdded)
end

function RelicsBridge.connectEmoteRemoved(onEmoteRemoved)
	emotes.EmoteRemoved:Connect(onEmoteRemoved)
end

function RelicsBridge.connectOwnershipChanged(callback)
	emotes.OwnerAdded:Connect(callback)
	emotes.OwnerRemoved:Connect(callback)
end

function RelicsBridge.playerOwns(p)
	local v5 = v4[p]

	if v5 ~= nil then
		return v5
	end

	local localPlayer = Players.LocalPlayer
	local selected = p.Owners[localPlayer.UserId] == true or ownership.PlayerOwnsAsync(localPlayer, p)
	v4[p] = selected
	return selected
end

function RelicsBridge.invalidateOwnership(p)
	if p then
		v4[p] = nil
	else
		table.clear(v4)
	end
end

function RelicsBridge.getBuyText(p)
	local productId = p.ProductId
	local v5 = values[productId]

	if v5 then
		return v5
	end

	local productType = p.ProductType or Enum.InfoType.Asset
	local v6, v7 = v2.GetProductInfo(productId, productType):await()

	if v6 and v7 and v7.PriceInRobux then
		local formatted = `Buy {v7.PriceInRobux} R$`
		values[productId] = formatted
		return formatted
	else
		return "Buy"
	end
end

function RelicsBridge.promptPurchase(p)
	local localPlayer = Players.LocalPlayer
	local productType = p.ProductType

	if productType == Enum.InfoType.GamePass then
		MarketplaceService:PromptGamePassPurchase(localPlayer, p.ProductId)
	elseif productType == Enum.InfoType.Product then
		MarketplaceService:PromptProductPurchase(localPlayer, p.ProductId)
	else
		MarketplaceService:PromptPurchase(localPlayer, p.ProductId)
	end
end

function RelicsBridge.openEmoteMenu()
	v3.OpenEmoteWheelAndBoombox()
end

function RelicsBridge.buildEffect(p, p2, p3: number?)
	local v5 = emotes.SetupEffect(p, p3)

	if not v5 then
		return nil
	end

	local v6 = emotes.AttachEffectToCharacter(v5, p2, nil)
	v.Auras.BindEffect(v5)
	return v6
end

return RelicsBridge