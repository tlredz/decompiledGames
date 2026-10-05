local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local GlobalStateProvider = require(game.ReplicatedStorage.React.Components.GlobalStateProvider)
local parentModule = require(script.Parent)
local HUDDebugContainer = require(game.ReplicatedStorage.React.Components.HUDDebugContainer)
local useMockStateWriter = require(game.ReplicatedStorage.React.Hooks.useMockStateWriter)
require(game.ReplicatedStorage.React.RobloxTypes)
local PRESETS = require(game.ReplicatedStorage.React.Components.HUDDebugContainer.PRESETS)
local createElement = React.createElement

local function MockControls(p)
	local controls = p.Controls
	useMockStateWriter("Level", controls.Level)
	useMockStateWriter("Exp", controls.Exp)
	useMockStateWriter("Beli", controls.Beli)
	useMockStateWriter("Fragments", controls.Fragments)
	useMockStateWriter("StatPoints", controls.StatPoints)
	useMockStateWriter("Health", controls.Health)
	useMockStateWriter("OverflowHP", controls.OverflowHP)
	useMockStateWriter("MaxHealth", controls.IsGod and 1e999 or controls.MaxHealth)
	useMockStateWriter("Energy", controls.Energy)
	useMockStateWriter("MaxEnergy", controls.MaxEnergy)
	useMockStateWriter("IsPainTransformed", controls.IsPainTransformed)
	useMockStateWriter("IsDungeon", controls.IsDungeon)
	return p.children
end

return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Background_Preset_1 = UILabs.Choose(TableUtil.keys(PRESETS), 1),
		Background_Preset_2 = UILabs.Choose(TableUtil.keys(PRESETS), 2),
		Background_Preset_3 = UILabs.Choose(TableUtil.keys(PRESETS), 3),
		Background_Preset_4 = UILabs.Choose(TableUtil.keys(PRESETS), 4),
		Background_Preset_5 = UILabs.Choose(TableUtil.keys(PRESETS), 5),
		Background_Preset_6 = UILabs.Choose(TableUtil.keys(PRESETS), 6),
		Background_Preset_7 = UILabs.Choose(TableUtil.keys(PRESETS), 7),
		Background_Preset_8 = UILabs.Choose(TableUtil.keys(PRESETS), 8),
		Background_Preset_9 = UILabs.Choose(TableUtil.keys(PRESETS), 9),
		Background_Dimmed = true,
		Background_KeepSafeZoneVisible = false,
		Level = UILabs.Slider(100, 100, 2800, 100),
		Exp = UILabs.Slider(0, 0, 10000000, 10000),
		Beli = UILabs.Slider(1284500, 0, 100000000, 1),
		Fragments = UILabs.Slider(9420, 0, 1000000, 1),
		StatPoints = UILabs.Slider(14, 0, 100, 1),
		Health = UILabs.Slider(820, 0, 1000, 10),
		OverflowHP = UILabs.Slider(0, 0, 1000, 10),
		MaxHealth = UILabs.Slider(1000, 1, 1000, 10),
		Energy = UILabs.Slider(450, 0, 1000, 1),
		MaxEnergy = UILabs.Slider(1000, 1, 1000, 1),
		IsDungeon = false,
		IsPainTransformed = false,
		IsGod = false
	}
}, function(p)
	local children = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 20),
			Wraps = true
		})
	}

	for k, presetKey in {
		p.controls.Background_Preset_1,
		p.controls.Background_Preset_2,
		p.controls.Background_Preset_3,
		p.controls.Background_Preset_4,
		p.controls.Background_Preset_5,
		p.controls.Background_Preset_6,
		p.controls.Background_Preset_7,
		p.controls.Background_Preset_8,
		p.controls.Background_Preset_9
	} do
		children[presetKey] = createElement(GlobalStateProvider, {}, {
			Mock = createElement(MockControls, {
				Controls = p.controls
			}, {
				HUD = createElement(HUDDebugContainer, {
					LayoutOrder = k,
					PresetKey = presetKey,
					VisualizeSafeZone = p.controls.Background_KeepSafeZoneVisible,
					ClipToScreen = true,
					BackgroundTransparency = p.controls.Background_Dimmed and 0.5 or 0
				}, {
					HUD = createElement(parentModule, {
						Size = UDim2.fromScale(1, 1),
						OnMenuAction = function(p2)
							print("action", p2)
						end
					})
				})
			})
		})
	end

	return createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(3, 2)
	}, children)
end)