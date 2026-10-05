local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local parentModule = require(script.Parent)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local now = tick()
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Level = UILabs.Slider(1, 1, 2600, 1),
		Exp = UILabs.Slider(40, 0, 1000, 1),
		ExpGoal = UILabs.Slider(100, 1, 1000, 1),
		ExpBoostDuration = UILabs.Slider(15, 15, 720, 15),
		FriendCount = UILabs.Slider(0, 0, 4, 1),
		FriendBoost = UILabs.Slider(0, 0, 1, 0.1),
		ExpBoost = UILabs.Slider(0, 0, 1, 0.1),
		FishFriendBoost = UILabs.Slider(0, 0, 100, 10),
		ExploreBoost = UILabs.Slider(0, 0, 4, 1),
		FishBoost = false
	}
}, function(p)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateMockState(p2: string, p3)
		local v = useMockState(p2, p3)

		if v and v:get() ~= p3 then
			v:set(p3)
		end
	end

	updateMockState("FriendCount", p.controls.FriendCount) -- equivalent call inferred; original call site unknown
	updateMockState("ExploreBoost", p.controls.ExploreBoost) -- equivalent call inferred; original call site unknown
	updateMockState("FishFriendBoost", p.controls.FishFriendBoost) -- equivalent call inferred; original call site unknown
	updateMockState("FriendBoost", p.controls.FriendBoost) -- equivalent call inferred; original call site unknown
	updateMockState("EXPBoost", p.controls.ExpBoost) -- equivalent call inferred; original call site unknown
	updateMockState("EXPBoostTick", now + p.controls.ExpBoostDuration * 60) -- equivalent call inferred; original call site unknown
	local v2 = useMockState("Level", p.controls.Level)

	if v2 and v2:get() ~= p.controls.Level then
		v2:set(p.controls.Level)
	end

	local v3 = useMockState("Exp", p.controls.Exp)

	if v3 and v3:get() ~= p.controls.Exp then
		v3:set(p.controls.Exp)
	end

	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1)
	}, {
		LevelBar = createElement(parentModule, {
			ExpGoal = p.controls.ExpGoal,
			Position = UDim2.new(0, 6, 0.4, 0),
			Size = UDim2.new(0.19, 0, 0.06, 5)
		})
	})
end)