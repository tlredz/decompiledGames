local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local parentModule = require(script.Parent)
local DrawContextProvider = require(game.ReplicatedStorage.React.Components.DrawContextProvider)
local useMockStateWriter = require(game.ReplicatedStorage.React.Hooks.useMockStateWriter)
require(game.ReplicatedStorage.AccessoriesShared)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {
	Empty = {},
	SuperOnly = {
		["00000000-0000-0000-0000-000000000003"] = {
			Equipped = true,
			Grade = 0,
			Modifiers = {},
			Name = "Divine Cloak",
			Type = "Super"
		}
	},
	Full = {
		["00000000-0000-0000-0000-000000000001"] = {
			Equipped = true,
			Grade = 1,
			Modifiers = { "Punchy", "Brutal" },
			Name = "Ring of Striking",
			Type = "Trinket"
		},
		["00000000-0000-0000-0000-000000000002"] = {
			Equipped = true,
			Grade = 2,
			Modifiers = { "Levitating", "Airborne" },
			Name = "Ring of Carving",
			Type = "Trinket"
		},
		["00000000-0000-0000-0000-000000000003"] = {
			Equipped = true,
			Grade = 0,
			Modifiers = {},
			Name = "Divine Cloak",
			Type = "Super"
		}
	}
}
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Accessories = UILabs.Choose({ "Full", "SuperOnly", "Empty" }, 1),
		WidthPx = UILabs.Slider(320, 120, math.round(workspace.CurrentCamera.ViewportSize.X), 1),
		HeightPx = UILabs.Slider(400, 120, math.round(workspace.CurrentCamera.ViewportSize.Y), 1)
	}
}, function(p)
	local widthPx = p.controls.WidthPx
	local heightPx = p.controls.HeightPx
	useMockStateWriter("PlayerDynamicAccessories", v[p.controls.Accessories])
	return createElement(DrawContextProvider, {
		Context = "Default"
	}, {
		Panel = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
			BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(widthPx, heightPx)
		}, {
			StatsPanel = createElement(parentModule, {})
		})
	})
end)