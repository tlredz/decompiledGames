local game2 = script.Parent.Parent.Game
local ItemModule = require(game.ReplicatedStorage.Modules.ItemModule)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local newItem = game2.NewItem
local lFrame = nil
local v = {}
game.Lighting.NewItemBlur.Enabled = false
local v2 = 1
local v3 = 1

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateClaimText()
	if v3 > 1 then
		newItem.Container.Claim.Text = "Claim (" .. v2 .. "/" .. v3 .. ")"
	else
		newItem.Container.Claim.Text = "Claim"
	end
end

local function ShowItem()
	local v4 = v[1]
	local v5 = Sync[v4.Type][v4.ItemName]
	local amount = v4.Amount or nil
	ItemModule.DisplayItem(newItem.Container.NewItem, v5, amount)
	local color = Sync.Rarities[v5.Rarity].Color
	newItem.Container.Starburst.ImageColor3 = Color3.fromRGB(color.r, color.g, color.b) or Color3.new(1, 1, 1)
	newItem.Container.Title.Text = v4.TitleText

	if v4.LFrame then
		lFrame = v4.LFrame
		lFrame.Visible = false
	end

	game.Lighting.NewItemBlur.Enabled = true
	newItem.Visible = true
end

function _G.NewItem(itemName, value, lFrame2, value2, amount)
	table.insert(v, {
		ItemName = itemName,
		TitleText = value or "You Got...",
		LFrame = lFrame2,
		Type = value2 or "Weapons",
		Amount = amount
	})

	if newItem.Visible then
		v3 += 1
	else
		v2 = 1
		v3 = #v
		ShowItem()
	end

	UpdateClaimText() -- equivalent call inferred; original call site unknown
end

newItem.Container.Claim.MouseButton1Click:connect(function()
	ItemModule.AnimateItemIconIntoInventory(newItem.Container.NewItem.Container.Icon, game2.Dock.Inventory, game2)
	newItem.Visible = false
	_G.UnfinishedItem = nil
	_G.UnfinishedType = nil
	table.remove(v, 1)
	game.Lighting.NewItemBlur.Enabled = false

	if v[1] == nil then
		v3 = 1
		v2 = 1

		if lFrame then
			lFrame.Visible = true
		end
	else
		v2 += 1
		UpdateClaimText() -- equivalent call inferred; original call site unknown
		ShowItem()
	end
end)
game.ReplicatedStorage:WaitForChild("ItemGift").OnClientEvent:connect(function(p, p2)
	_G.NewItem(p, "You Got...", nil, p2)
end)