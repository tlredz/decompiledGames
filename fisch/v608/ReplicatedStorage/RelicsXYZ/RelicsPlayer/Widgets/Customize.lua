local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local React = require(shared.React)
local hooks = parent.Hooks
local useStyleSheet = require(hooks.useStyleSheet)
local useTabOrder = require(hooks.useTabOrder)
local State = require(parent.State)
local components = parent.Components
local PillButtonBar = require(components.PillButtonBar)
local SettingsWidget = require(components.SettingsWidget)
local FavoritesWidget = require(components.FavoritesWidget)
local v = {
	Equip = require(components.EquipWheelWidget),
	Settings = SettingsWidget,
	Favorites = FavoritesWidget
}

local function Customize(_)
	local v2, v3 = useStyleSheet("Palette")
	local v4 = useTabOrder()
	local v5 = React.useContext(State.Context)
	local customizeTab = v5.CustomizeTab
	local setCustomizeTab = v5.SetCustomizeTab
	local features = v5.Features
	local buttonInfo = React.useMemo(function()
		local result = {}

		for i, v7 in ipairs(v4) do
			local upper = v7:upper()
			local v8

			if v7 == "Settings" then
				v8 = "Playlists"
			elseif v7 == "Equip" then
				if not features.EmoteWheel then
					continue
				end

				v8 = "Cosmetics"
			else
				v8 = v7
			end

			result[upper] = {
				Order = i,
				Title = upper,
				Color = v2(`Color-Collection-{v8}Pastel`, v2("Color-White", Color3.new())),
				Widget = v[v7]
			}
		end

		return result
	end, { v4, v3 })
	local v7 = buttonInfo[customizeTab]
	local widget = v7 and v7.Widget
	local createElement = React.createElement
	local v9 = {
		[React.Tag] = "CustomizePageContainer"
	}
	local v10 = {
		ButtonBar = React.createElement(PillButtonBar, {
			[React.Tag] = "CustomizeButtonsBar",
			ButtonInfo = buttonInfo,
			InitialSelection = customizeTab,
			OnTabSelected = function(p)
				setCustomizeTab(p)
			end
		}),
		Widget = 0
	}

	if widget then
		widget = React.createElement("CanvasGroup", {
			[React.Tag] = "CustomizePageContentContainer"
		}, { React.createElement(widget) })
	end

	v10.Widget = widget
	return createElement("Frame", v9, v10)
end

return Customize