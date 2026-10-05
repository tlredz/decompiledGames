local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UILabs = require(ReplicatedStorage.Packages["UI-Labs"])
local Vide = require(ReplicatedStorage.Packages.Vide)
local NotificationBadge = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.NotificationBadge)
local TopBarButton = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.TopBarButton)
local Themes = require(ReplicatedStorage._FRAMEWORK.Features.eventQuests.Themes)
local create = Vide.create
local controls2 = {
	Theme = UILabs.Choose({ "halloween", "summer" }),
	LayoutOrder = UILabs.Slider(10, 0, 60),
	Visible = true,
	Badge = UILabs.Slider(2, 0, 5, 1)
}

local function story(p)
	local controls = p.controls
	return create("Frame")({
		Name = "TopButtons",
		Position = UDim2.fromScale(0, 0.05),
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundTransparency = 1,
		create("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8)
		}),
		create("UIPadding")({
			PaddingTop = UDim.new(0.125, 0),
			PaddingBottom = UDim.new(0.125, 0),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0.02, 0)
		}),
		TopBarButton({
			Name = "SettingsButton",
			LayoutOrder = 1,
			Emoji = "⚙️",
			BackgroundColor = Color3.fromRGB(62, 53, 170)
		}),
		TopBarButton({
			Name = "QuestButton",
			LayoutOrder = controls.LayoutOrder,
			Emoji = function()
				return Themes[controls.Theme()].buttonEmoji
			end,
			BackgroundColor = function()
				return Themes[controls.Theme()].buttonColor
			end,
			Visible = controls.Visible,
			OnActivated = function()
				print("[QuestButton.story] open quests")
			end
		}, NotificationBadge({
			Count = controls.Badge
		}))
	})
end

return UILabs.CreateVideStory({
	name = "Event Quests — Quest Button",
	vide = Vide,
	controls = controls2
}, story)