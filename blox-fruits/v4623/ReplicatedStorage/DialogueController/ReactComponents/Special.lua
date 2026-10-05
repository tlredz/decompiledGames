local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)

local function promptFastBoatsGamepassPurchase()
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	local nullable = ItemConfig.match("Fast Boats", "Redeemable"):asNullable()
	local gamepassId = nullable and nullable.Economy and nullable.Economy.GamepassId

	if gamepassId then
		MarketplaceService:PromptGamePassPurchase(localPlayer, gamepassId)
	else
		warn("[DIALOGUE]", "missing Fast Boats gamepass id")
	end
end

local registry = {
	FastBoatsGamepassPopup = {
		slot = "optionsList",
		component = require(script.FastBoatsGamepassPopup),
		defaultProps = {
			onActivated = promptFastBoatsGamepassPurchase
		}
	},
	ItemPurchaseSkillPreview = {
		slot = "dialogueWindow",
		component = require(script.ItemPurchaseSkillPreview)
	}
}
local v2 = {
	screen = true,
	dialogueWindow = true,
	optionsList = true
}
local v3 = {}

for k, list in registry do
	assert(v2[list.slot], (`[DIALOGUE] invalid special React component slot "{list.slot}"`))
	assert(list.component ~= nil, (`[DIALOGUE] missing special React component for "{k}"`))

	if v3[list.component] then
		error(`[DIALOGUE] special React component "{k}" repeats component "{v3[list.component]}"`, 2)
	end

	v3[list.component] = k
	table.freeze(list)
end

table.freeze(registry)
return table.freeze({
	registry = registry,
	get = function(p: string)
		return registry[p]
	end
})