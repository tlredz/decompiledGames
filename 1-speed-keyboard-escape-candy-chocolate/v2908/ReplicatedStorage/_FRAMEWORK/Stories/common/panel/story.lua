local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.Packages
local UILabs = require(packages["UI-Labs"])
local Vide = require(packages.Vide)
local ItemRow = require(ReplicatedStorage._FRAMEWORK.Features.ItemIndex.ItemRow)
require(ReplicatedStorage._FRAMEWORK.Features.ItemIndex.Types)
local PanelModal = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.PanelModal)
local color = Color3.fromRGB(241, 204, 22)
local color2 = Color3.fromRGB(147, 91, 0)
local color3 = Color3.fromRGB(255, 237, 184)
local color4 = Color3.fromRGB(99, 0, 212)
local color5 = Color3.fromRGB(255, 243, 211)
local v = {
	{
		id = "chocoBar",
		label = "Choco Bar",
		icon = "rbxassetid://83707728604228",
		rarity = "Common",
		bonus = "+3%",
		stat = "XP",
		tier = 1,
		current = 12,
		max = 25,
		price = "1.2K"
	},
	{
		id = "muffinHat",
		label = "Muffin Hat",
		icon = "rbxassetid://79719009938160",
		rarity = "Uncommon",
		bonus = "+5%",
		stat = "XP",
		tier = 2,
		current = 6,
		max = 25,
		price = "4.5K"
	},
	{
		id = "dollars",
		label = "Dollars",
		icon = "rbxassetid://93366698506428",
		rarity = "Rare",
		bonus = "+10%",
		stat = "COINS",
		tier = 3,
		current = 3,
		max = 25,
		price = "18K"
	},
	{
		id = "watch",
		label = "Watch",
		icon = "rbxassetid://138133358872758",
		rarity = "Epic",
		bonus = "+15%",
		stat = "SPEED",
		tier = 3,
		current = 2,
		max = 25,
		price = "62K"
	},
	{
		id = "candyWings",
		label = "Candy Wings",
		icon = "rbxassetid://78731100327570",
		rarity = "Legendary",
		bonus = "+25%",
		stat = "SPEED",
		tier = 4,
		current = 1,
		max = 25,
		price = "250K"
	},
	{
		id = "candyCrown",
		label = "Candy Crown",
		icon = "rbxassetid://121997245505981",
		rarity = "Mythic",
		bonus = "+50%",
		stat = "LUCK",
		tier = 5,
		current = 1,
		max = 25,
		price = "1.4M"
	},
	{
		id = "goldenMask",
		label = "Golden Mask",
		icon = "rbxassetid://129287120641819",
		rarity = "Secret",
		bonus = "+100%",
		stat = "LUCK",
		tier = 5,
		current = 1,
		max = 25,
		price = "8M"
	},
	{
		id = "canadaEarth",
		label = "Canada Earth",
		icon = "rbxassetid://75652047877518",
		rarity = "Exotic",
		bonus = "+200%",
		stat = "ALL",
		tier = 5,
		current = 0,
		max = 25,
		price = "30M"
	}
}
local controls2 = {
	Variant = UILabs.Choose({ "Panel", "Soft" }),
	BannerText = "BUY UNIQUE ITEMS WITH YOUR COINS",
	StatusText = "FIND COINS BY PLAYING / RESTOCK IN: 60s",
	RowCount = UILabs.Slider(#v, 0, #v),
	OwnedCount = UILabs.Slider(2, 0, #v),
	ShowClose = true
}
return UILabs.CreateVideStory({
	name = "Common — Panel Modal",
	vide = Vide,
	controls = controls2
}, function(p)
	local controls = p.controls

	local function rows()
		local result = {}

		for i = 1, math.min(controls.RowCount(), #v) do
			result[i] = v[i]
		end

		return result
	end

	return PanelModal({
		Name = "ItemIndexPanel",
		BannerText = controls.BannerText,
		StatusText = controls.StatusText,
		ShowClose = controls.ShowClose,
		OnClose = function()
			print("[panel.story] close")
		end
	}, { Vide.indexes(rows, function(callback, layoutOrder: number)
			local function owned()
				return layoutOrder <= controls.OwnedCount()
			end

			return ItemRow({
				Name = callback().id,
				LayoutOrder = layoutOrder,
				Variant = controls.Variant,
				Label = function()
					return callback().label
				end,
				Icon = function()
					return callback().icon
				end,
				Rarity = function()
					return callback().rarity
				end,
				Bonus = function()
					return callback().bonus
				end,
				StatLabel = function()
					return callback().stat
				end,
				Tier = function()
					return callback().tier
				end,
				Current = function()
					return callback().current
				end,
				Max = function()
					return callback().max
				end,
				Owned = owned,
				Actions = {
					{
						Id = "BuyCoins",
						Text = function()
							return callback().price
						end,
						Icon = "rbxassetid://117582891502895",
						Color = color,
						TextColor = color2,
						StrokeColor = color3,
						WidthRatio = 3.78,
						OnActivated = function()
							print("[panel.story] buy", callback().id)
						end
					},
					{
						Id = "Gift",
						Icon = "rbxassetid://83146733185707",
						Color = color4,
						StrokeColor = color5,
						WidthRatio = 1,
						OnActivated = function()
							print("[panel.story] gift", callback().id)
						end
					}
				}
			})
		end) })
end)