local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local parentModule = require(script.Parent)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		SeasonalTheme = UILabs.Choose({ "None", "Holiday" }, 1),
		StatPoints = UILabs.Slider(0, 0, 100, 1),
		GiftCount = UILabs.Slider(0, 0, 100, 1),
		NewItems = UILabs.Slider(0, 0, 100, 1)
	}
}, function(p)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateMockState(p2: string, p3)
		local v = useMockState(p2, p3)

		if v and v:get() ~= p3 then
			v:set(p3)
		end
	end

	updateMockState("StatPoints", p.controls.StatPoints) -- equivalent call inferred; original call site unknown
	updateMockState("TotalNewItems", p.controls.NewItems) -- equivalent call inferred; original call site unknown
	updateMockState("GiftCount", p.controls.GiftCount) -- equivalent call inferred; original call site unknown
	local v3 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1)
	}
	local shopTheme

	if p.controls.SeasonalTheme ~= "None" then
		shopTheme = p.controls.SeasonalTheme
	end

	return createElement("Frame", v3, {
		Menu = createElement(parentModule, {
			ShopTheme = shopTheme,
			Size = UDim2.fromScale(1, 1),
			OnMenuAction = function(p2)
				print("action", p2)
			end
		})
	})
end)