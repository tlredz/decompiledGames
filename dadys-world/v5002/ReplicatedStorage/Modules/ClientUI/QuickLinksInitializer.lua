local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)

local function resolveFolder(instance, items, p)
	if not instance then
		return
	end

	for childName, item in pairs(items) do
		local child = instance:FindFirstChild(childName)

		if child and child.Value then
			p[item] = child.Value
		end
	end
end

return {
	resolve = function()
		local gui = GameContext.Gui
		local v = {}
		local margin = gui.SelectionFrame:FindFirstChild("Margin")

		if not margin then
			warn("[QuickLinksInitializer] SelectionFrame.Margin not found")
			return v
		end

		local quickLinks = gui.SelectionFrame:FindFirstChild("QuickLinks")

		if not quickLinks then
			warn("[QuickLinksInitializer] QuickLinks folder not found in SelectionFrame")
			return v
		end

		v.QuickLinks = quickLinks
		local uI_Elements = quickLinks:FindFirstChild("UI_Elements")
		resolveFolder(uI_Elements, {
			ReadyUpButton = "readyUpButton",
			RoundTimer = "roundTimer",
			TeamFrame = "teamFrame",
			TeamFrameTemplate = "teamFrameTemplate"
		}, v)

		if uI_Elements then
			local playerIchorCount = uI_Elements:FindFirstChild("PlayerIchorCount")

			if playerIchorCount and playerIchorCount.Value then
				GameContext.playerIchorCount = playerIchorCount.Value
			end
		end

		resolveFolder(quickLinks:FindFirstChild("Shop"), {
			ShopFrame = "shopFrame"
		}, v)
		resolveFolder(quickLinks:FindFirstChild("Characters"), {
			ToonsTab = "toonsTab",
			ToonsCatalog = "toonsCatalog",
			ToonsButton = "toonsButton",
			ToonsEquipButton = "toonsEquipButton"
		}, v)
		resolveFolder(quickLinks:FindFirstChild("Trinkets"), {
			TrinketsTab = "trinketsTab",
			TrinketsCatalog = "trinketsCatalog",
			TrinketsButton = "trinketsButton",
			TrinketsEquipButton = "trinketsEquipButton",
			TrinketSlot1 = "trinketSlot1",
			TrinketSlot2 = "trinketSlot2"
		}, v)

		if v.trinketSlot1 and v.trinketSlot2 then
			return v
		end

		local catalogFrame = margin:FindFirstChild("CatalogFrame")
		local trinkets = catalogFrame and catalogFrame:FindFirstChild("Trinkets")
		local previewPane = trinkets and trinkets:FindFirstChild("PreviewPane")
		local equipped = previewPane and previewPane:FindFirstChild("Equipped")
		local equippedTrinkets = equipped and equipped:FindFirstChild("EquippedTrinkets")

		if equippedTrinkets then
			v.trinketSlot1 = v.trinketSlot1 or equippedTrinkets:FindFirstChild("EquippedTrinket1")
			v.trinketSlot2 = v.trinketSlot2 or equippedTrinkets:FindFirstChild("EquippedTrinket2")
		end

		return v
	end
}