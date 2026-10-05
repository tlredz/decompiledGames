local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Slots = require(script.Slots)
local Spinner = require(script.Spinner)
local PageBrowser = require(ReplicatedStorage.CAM.Client.Components.Misc.PageBrowser)
local AdForOre = require(ReplicatedStorage.CAM.Client.Components.Misc.AdForOre)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local faye = require(ReplicatedStorage.Packages.faye)
local item = gameSettings.SellRobuxPayout and gameSettings.SellRobuxPayout.Item or "Ore"
local v = {
	{
		Name = "Robux",
		Icon = BunchaIcons.Robux,
		IdleColor = Color3.new()
	},
	{
		Name = "Ore",
		Icon = Items[item] and Items[item].Icon or "",
		IconColor = Color3.new(1, 1, 1)
	}
}
local info = faye.Info(0.45)
local uDim = UDim2.fromScale(0, 0.04)
local isMenu = workspace:GetAttribute("IsMenu")
return function(object, parent, _, _)
	local value = object:Value("Robux")
	return object:Create("CanvasGroup")({
		Parent = parent,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		GroupTransparency = object:Animation(0, info, {
			From = 1
		}),
		Position = object:Animation(UDim2.fromScale(0, 0), info, {
			From = uDim
		}),
		OnClean = function(object2)
			return {
				GroupTransparency = object2:Animation(1, info),
				Position = object2:Animation(uDim, info)
			}
		end,
		object:Create("Frame")({
			Name = "Holder",
			CleanDelay = info.Time,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8)
			}),
			object:Create("Frame")({
				Name = "CurrencyTabs",
				LayoutOrder = 1,
				CleanDelay = info.Time,
				Size = UDim2.fromScale(0.05, 0.25),
				object:Create("UIAspectRatioConstraint")({
					AspectRatio = 0.5
				}),
				BackgroundTransparency = 1,
				PageBrowser(object, value, v, {
					Key = function(_, p2)
						return p2.Name
					end,
					Icon = function(_, p2)
						return p2.Icon
					end,
					IconColor = function(_, p2)
						return p2.IconColor
					end,
					IconShadow = true,
					IdleColor = function(_, p2)
						return p2.IdleColor
					end,
					FillDirection = Enum.FillDirection.Vertical,
					Size = UDim2.fromScale(1, 1),
					Position = UDim2.fromScale(0, 0),
					TabSize = UDim2.fromScale(1, 0.2),
					Padding = UDim.new(0, 6),
					Backdrop = false,
					TextXAlignment = Enum.TextXAlignment.Left
				})
			}),
			object:Create("Frame")({
				Name = "SpinningFrame",
				LayoutOrder = 2,
				CleanDelay = info.Time,
				Size = UDim2.fromScale(0.15, 0.25),
				object:Create("UIAspectRatioConstraint")({
					AspectRatio = 1.5
				}),
				BackgroundTransparency = 1,
				Spinner(object, isMenu, info, value)
			}),
			object:Create("Frame")({
				Name = "RightFrame",
				LayoutOrder = 3,
				CleanDelay = info.Time,
				Size = UDim2.fromScale(0.08, 0.3),
				object:Create("UIAspectRatioConstraint")({
					AspectRatio = 1.4
				}),
				BackgroundTransparency = 1,
				Slots(object, isMenu),
				object:Create("Frame")({
					Name = "AdHolder",
					CleanDelay = info.Time,
					Size = UDim2.fromScale(1, 0.4),
					AnchorPoint = Vector2.new(0, 1),
					Position = UDim2.new(0, 0, 0, -6),
					BackgroundTransparency = 1,
					AdForOre(object)
				})
			})
		})
	})
end