local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local components = parent.Components
local hooks = parent.Hooks
local useStyleSheet = require(hooks.useStyleSheet)
local React = require(shared.React)
local State = require(parent.State)
local PillButtonBar = require(components.PillButtonBar)
local PlaylistsWidget = require(components.PlaylistsWidget)
local RecentsWidget = require(components.RecentsWidget)
require(components.ItemInventory)
local GridAuras = require(components.GridAuras)
local GridEmotes = require(components.GridEmotes)
local GridSkins = require(components.GridSkins)
local v = {
	"Playlists",
	"Recents",
	"Dances",
	"Auras",
	"Cosmetics"
}
local v2 = string.upper(v[1])

local function requireOwnership(p)
	return function(p2)
		local clone = table.clone(p2)
		clone.RequireOwnership = true
		return React.createElement(p, clone)
	end
end

local v3 = {
	Recents = RecentsWidget,
	Playlists = PlaylistsWidget
}
local v4 = {
	Cosmetics = function(p)
		local clone = table.clone(p)
		clone.RequireOwnership = true
		return React.createElement(GridSkins, clone)
	end,
	Dances = function(p)
		local clone = table.clone(p)
		clone.RequireOwnership = true
		return React.createElement(GridEmotes, clone)
	end,
	Auras = function(p)
		local clone = table.clone(p)
		clone.RequireOwnership = true
		return React.createElement(GridAuras, clone)
	end
}

local function LibraryWidget()
	local v5, v6 = useStyleSheet("Palette", "Color3")
	local v7 = React.useContext(State.Context)
	local features = v7.Features
	local libraryTab = v7.LibraryTab or v2
	local buttonInfo = React.useMemo(function()
		local result = {}

		for i, v9 in ipairs(v) do
			local upper = v9:upper()

			if (v9 ~= "Dances" or features.Emotes) and (v9 ~= "Auras" or features.Auras) and (v9 ~= "Cosmetics" or features.Skins) then
				result[upper] = {
					Order = i,
					Title = upper,
					Color = v5(`Color-Collection-{v9 .. "Pastel"}`, v5("Color-White")),
					Widget = v4[v9] or v3[v9]
				}
			end
		end

		return result
	end, { v6, features })
	local v9 = buttonInfo[libraryTab]
	React.useEffect(function()
		if not buttonInfo[libraryTab] then
			for _, v10 in ipairs(v) do
				local upper = v10:upper()

				if not buttonInfo[upper] then
					continue
				end

				v7.SetLibraryTab(upper)
				return
			end
		end
	end, { buttonInfo, libraryTab })
	local widget = v9 and v9.Widget
	local createElement = React.createElement
	local v11 = {
		[React.Tag] = "LibraryPageContainer"
	}
	local v12 = {
		ButtonBar = React.createElement(PillButtonBar, {
			[React.Tag] = "LibraryTabsButtonBar",
			ButtonInfo = buttonInfo,
			InitialSelection = libraryTab,
			InitialCanvasX = v7.LibraryCanvasX,
			OnTabSelected = function(p)
				v7.SetLibraryTab(p)
			end,
			OnCanvasXChanged = function(p)
				v7.SetLibraryCanvasX(p)
			end
		}),
		Widget = 0
	}

	if widget then
		widget = React.createElement(widget, {
			[React.Tag] = "ofLibraryPage"
		})
	end

	v12.Widget = widget
	return createElement("Frame", v11, v12)
end

return LibraryWidget