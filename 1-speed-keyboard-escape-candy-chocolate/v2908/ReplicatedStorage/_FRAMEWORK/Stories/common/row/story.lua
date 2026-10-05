local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.Packages
local UILabs = require(packages["UI-Labs"])
local Vide = require(packages.Vide)
local ItemRow = require(ReplicatedStorage._FRAMEWORK.Features.ItemIndex.ItemRow)
local color = Color3.fromRGB(241, 204, 22)
local color2 = Color3.fromRGB(21, 165, 13)
local color3 = Color3.fromRGB(99, 0, 212)
local controls2 = {
	Variant = UILabs.Choose({ "Panel", "Soft" }),
	Label = "Candy Cane Sword",
	Icon = "rbxassetid://70623031207656",
	Rarity = UILabs.Choose({
		"Legendary",
		"Common",
		"Uncommon",
		"Rare",
		"Epic",
		"Mythic",
		"Secret",
		"Exotic",
		"Unreal"
	}),
	Bonus = "+25%",
	StatLabel = "SPEED",
	Tier = UILabs.Slider(3, 0, 5),
	Current = UILabs.Slider(2, 0, 99),
	Max = UILabs.Slider(10, 1, 99),
	Owned = false,
	CoinPrice = "250K",
	RobuxPrice = "179"
}
return UILabs.CreateVideStory({
	name = "Common — Item Row",
	vide = Vide,
	controls = controls2
}, function(p)
	local controls = p.controls
	return Vide.create("Frame")({
		Name = "ItemRowStory",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(32, 36, 48),
		Vide.create("Frame")({
			Name = "List",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.55, 0.9),
			BackgroundTransparency = 1,
			Vide.create("UIListLayout")({
				Padding = UDim.new(0.02, 0),
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			ItemRow({
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 0.31),
				Variant = controls.Variant,
				Label = controls.Label,
				Icon = controls.Icon,
				Rarity = controls.Rarity,
				Bonus = controls.Bonus,
				StatLabel = controls.StatLabel,
				Tier = controls.Tier,
				Current = controls.Current,
				Max = controls.Max,
				Owned = controls.Owned,
				Actions = {
					{
						Id = "BuyCoins",
						Text = controls.CoinPrice,
						Icon = "rbxassetid://117582891502895",
						Color = color,
						TextColor = Color3.fromRGB(147, 91, 0),
						StrokeColor = Color3.fromRGB(255, 237, 184),
						WidthRatio = 3.78,
						OnActivated = function()
							print("[row.story] buy with coins")
						end
					},
					{
						Id = "BuyRobux",
						Text = controls.RobuxPrice,
						Icon = "rbxassetid://101691238677984",
						Color = color2,
						TextColor = Color3.fromRGB(26, 97, 0),
						StrokeColor = Color3.fromRGB(170, 255, 151),
						WidthRatio = 2.8,
						OnActivated = function()
							print("[row.story] buy with robux")
						end
					},
					{
						Id = "Gift",
						Icon = "rbxassetid://83146733185707",
						Color = color3,
						StrokeColor = Color3.fromRGB(255, 243, 211),
						WidthRatio = 1,
						OnActivated = function()
							print("[row.story] gift")
						end
					}
				}
			}),
			ItemRow({
				LayoutOrder = 2,
				Size = UDim2.fromScale(1, 0.31),
				Variant = "Soft",
				Label = "Golden Mask",
				Icon = "rbxassetid://129287120641819",
				Rarity = "Secret",
				Bonus = "+100%",
				StatLabel = "LUCK",
				Tier = 5,
				Current = 4,
				Max = 4,
				Owned = true
			}),
			ItemRow({
				LayoutOrder = 3,
				Size = UDim2.fromScale(1, 0.31),
				Variant = "Panel",
				Label = "Choco Bar",
				Icon = "rbxassetid://83707728604228",
				Rarity = "Common",
				Bonus = "+3%",
				StatLabel = "XP",
				Tier = 1,
				Current = 12,
				Max = 25,
				Actions = {
					{
						Id = "BuyCoins",
						Text = "1.2K",
						Icon = "rbxassetid://117582891502895",
						Color = color,
						TextColor = Color3.fromRGB(147, 91, 0),
						StrokeColor = Color3.fromRGB(255, 237, 184),
						WidthRatio = 3.78
					},
					{
						Id = "Gift",
						Icon = "rbxassetid://83146733185707",
						Color = color3,
						StrokeColor = Color3.fromRGB(255, 243, 211),
						WidthRatio = 1
					}
				}
			})
		})
	})
end)