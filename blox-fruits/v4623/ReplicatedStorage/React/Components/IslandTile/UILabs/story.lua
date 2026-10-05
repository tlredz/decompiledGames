local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Map = require(game.ReplicatedStorage.Definitions.Map)
local parentModule = require(script.Parent)
local islands = {}
local map = Map.getMap("Sea1")

if map then
	for _, island in map.Islands do
		islands[island.Index.Key] = island
	end
end

local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		IsGlowEnabled = false,
		IsRecommended = false,
		IsLocked = false,
		IsSelected = false,
		Island = UILabs.Choose(TableUtil.keys(islands), 1),
		AwakenedBossStatus = UILabs.Choose({
			"Locked",
			"Unlocked",
			"Fighting",
			"Completed"
		}, 1),
		IconMode = UILabs.Choose({
			"Default",
			"OneStar",
			"TwoStar",
			"ThreeStar",
			"Completed"
		}, 1),
		HasLevel = false,
		SelectionEmblem = UILabs.Choose({ "Pirate", "Marines", "None" }, 3),
		StarsFilled = UILabs.Slider(0, 0, 3, 1),
		Stars = UILabs.Slider(0, 0, 3, 1)
	}
}, function(p)
	local v3 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.75, 0.5),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Sprite = SpriteMap.Islands["bandit-village-s1"],
		OutlineSprite = SpriteMap.Islands["bandit-village-s1-outline"],
		SelectionEmblem = 0,
		IsGlowEnabled = 0,
		IsLocked = 0,
		IsSelected = 0,
		Island = 0,
		IsRecommended = 0,
		Level = 0,
		IconMode = 0,
		AwakenedBossStatus = 0,
		StarsFilled = 0,
		Stars = 0,
		OnClick = 0
	}
	local selectionEmblem

	if p.controls.SelectionEmblem ~= "None" then
		selectionEmblem = p.controls.SelectionEmblem
	end

	v3.SelectionEmblem = selectionEmblem
	v3.IsGlowEnabled = p.controls.IsGlowEnabled
	v3.IsLocked = p.controls.IsLocked
	v3.IsSelected = p.controls.IsSelected
	v3.Island = islands[p.controls.Island]
	v3.IsRecommended = p.controls.IsRecommended
	v3.Level = p.controls.HasLevel and 500
	v3.IconMode = p.controls.IconMode
	v3.AwakenedBossStatus = p.controls.AwakenedBossStatus
	v3.StarsFilled = math.min(p.controls.StarsFilled, p.controls.Stars)
	v3.Stars = p.controls.Stars

	function v3.OnClick() end

	return createElement(parentModule, v3)
end)