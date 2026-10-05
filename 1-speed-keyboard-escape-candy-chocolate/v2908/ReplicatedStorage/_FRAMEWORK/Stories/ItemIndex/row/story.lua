local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.Packages
local UILabs = require(packages["UI-Labs"])
local Vide = require(packages.Vide)
local IndexRow = require(ReplicatedStorage._FRAMEWORK.Features.ItemIndex.IndexRow)
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
	StatLabel = "XP",
	Owned = true
}

local function bonusLabel(p: number, p2: number)
	local v2 = p + p2 * math.log(p + 2.0137527074704766 - 1) * 1.5
	return string.format("+%d%%", (math.floor(v2 * 100 + 0.5)))
end

return UILabs.CreateVideStory({
	name = "Item Index — Index Row",
	vide = Vide,
	controls = controls2
}, function(p)
	local controls = p.controls
	local source = Vide.source(3)
	return Vide.create("Frame")({
		Name = "IndexRowStory",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(32, 36, 48),
		Vide.create("Frame")({
			Name = "List",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.92, 0.92),
			BackgroundTransparency = 1,
			Vide.create("UIAspectRatioConstraint")({
				AspectRatio = 2
			}),
			Vide.create("UIListLayout")({
				Padding = UDim.new(0.02, 0),
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			IndexRow({
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 0.3),
				Variant = controls.Variant,
				Label = controls.Label,
				Icon = controls.Icon,
				Rarity = controls.Rarity,
				Bonus = function()
					return bonusLabel(0.25, source())
				end,
				NextBonus = function()
					local v2 = source()

					if v2 < 5 then
						local v3 = (v2 + 1) * 0.23408563376012187 * 1.5 + 0.25
						return (string.format("+%d%%", (math.floor(v3 * 100 + 0.5))))
					else
						return ""
					end
				end,
				StatLabel = controls.StatLabel,
				Tier = source,
				Owned = controls.Owned,
				OnActivated = function()
					source((source() + 1) % 6)
				end
			}),
			IndexRow({
				LayoutOrder = 2,
				Size = UDim2.fromScale(1, 0.3),
				Variant = controls.Variant,
				Label = "Golden Mask",
				Icon = "rbxassetid://129287120641819",
				Rarity = "Secret",
				Bonus = string.format("+%d%%", 625),
				StatLabel = "XP",
				Tier = 5,
				Owned = true
			}),
			IndexRow({
				LayoutOrder = 3,
				Size = UDim2.fromScale(1, 0.3),
				Variant = controls.Variant,
				Label = "Canada Earth",
				Icon = "rbxassetid://75652047877518",
				Rarity = "Exotic",
				Bonus = string.format("+%d%%", 200),
				NextBonus = string.format("+%d%%", 365),
				StatLabel = "XP",
				Tier = 0,
				Owned = false
			}),
			IndexRow({
				LayoutOrder = 4,
				Size = UDim2.fromScale(1, 0.3),
				Variant = controls.Variant,
				Label = "Broken Mask",
				Icon = "rbxassetid://129287120641819",
				Rarity = "Unreal",
				Bonus = string.format("+%d%%", 250),
				NextBonus = string.format("+%d%%", 439),
				StatLabel = "XP",
				Tier = 0,
				Owned = false
			})
		})
	})
end)