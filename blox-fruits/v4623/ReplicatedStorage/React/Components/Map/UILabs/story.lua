local createVector = vector.create
local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local MaterialIconsHD = require(game.ReplicatedStorage.Packages.MaterialIconsHD)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local Map = require(game.ReplicatedStorage.Definitions.Map)
local parentModule = require(script.Parent)
local useMockStateWriter = require(game.ReplicatedStorage.React.Hooks.useMockStateWriter)
local islands = {}

for k, v in Map.DEFINITIONS do
	for _, island in v.Islands do
		if islands[island.Index.Key] then
			islands[`{island.Index.Key} ({k})`] = island
		else
			islands[island.Index.Key] = island
		end
	end
end

local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		recommended = UILabs.Choose(TableUtil.keys(islands)),
		pos_x = UILabs.Slider(0, -10000, 10000, 100),
		pos_z = UILabs.Slider(0, -10000, 10000, 100),
		rotation = UILabs.Slider(0, 0, 360, 15),
		level = UILabs.Slider(1, 1, 3000, 1)
	}
}, function(p)
	useMockStateWriter(
		"CameraCFrame",
		CFrame.new(p.controls.pos_x or 0, 0, p.controls.pos_z or 0) * CFrame.Angles(
			0,
			math.rad(p.controls.rotation or 0),
			0
		)
	)
	useMockStateWriter("Level", p.controls.level)
	local state, setState = React.useState(nil)
	local state2, setState2 = React.useState(nil)
	local state3, setState3 = React.useState(true)
	return createElement(parentModule, {
		IsOpen = state3,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.85, 0.85),
		Recommendation = islands[p.controls.recommended],
		UserId = 912348,
		Markers = {
			{
				Key = "Test",
				Position = createVector(600, 100, 100),
				FillColor = Color3.fromHex("78C8FF"),
				Icon = MaterialIconsHD.priority_high
			}
		},
		NavigationTarget = state,
		SelectedIsland = state2,
		Mode = "HUD",
		OnAction = function(data)
			print("action", data)

			if data.Type == "NavigateTo" then
				setState2(nil)
				setState(data.Target)
			elseif data.Type == "ClearNavigation" then
				setState(nil)
				setState2(nil)
			elseif data.Type == "Select" then
				setState2(data.Island)
			elseif data.Type == "Exit" then
				setState3(false)
			end
		end
	})
end)