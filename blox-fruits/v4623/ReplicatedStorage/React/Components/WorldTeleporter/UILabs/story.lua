local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local IdMap = require(game.ReplicatedStorage.IdMap)
local parentModule = require(script.Parent)
local useMockStateWriter = require(game.ReplicatedStorage.React.Hooks.useMockStateWriter)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local CONSTANTS2 = require(game.ReplicatedStorage.React.Components.WorldTeleporter.CONSTANTS)
local DEFAULT_THEME = CONSTANTS2.DEFAULT_THEME
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Race = UILabs.Choose(TableUtil.keys(IdMap.Race)),
		Level = UILabs.Slider(100, 0, 700, 25),
		IsOpen = true,
		IsGolden = false,
		Background = UILabs.Datatype.Color3(DEFAULT_THEME.Background),
		Primary = UILabs.Datatype.Color3(DEFAULT_THEME.Primary),
		Secondary = UILabs.Datatype.Color3(DEFAULT_THEME.Secondary),
		Text = UILabs.Datatype.Color3(DEFAULT_THEME.Text)
	}
}, function(p)
	useMockStateWriter("Level", p.controls.Level)
	useMockStateWriter("PlayerRaceId", IdMap.Race[p.controls.Race])
	local theme = React.useMemo(function()
		return table.freeze({
			Background = p.controls.Background,
			Primary = p.controls.Primary,
			Secondary = p.controls.Secondary,
			Text = p.controls.Text
		})
	end, {
		p.controls.Background,
		p.controls.Primary,
		p.controls.Secondary,
		p.controls.Text
	})
	return createElement(parentModule, {
		IsOpen = p.controls.IsOpen,
		IsGolden = p.controls.IsGolden,
		Theme = theme,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.85, 0.85),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		OnSelect = function(p2)
			print((`selected {p2}`))
		end,
		OnPuzzleComplete = function()
			print("puzzle complete")
		end
	})
end)