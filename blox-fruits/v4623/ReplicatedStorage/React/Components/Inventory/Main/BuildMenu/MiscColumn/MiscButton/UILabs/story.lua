local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local React = require(game.ReplicatedStorage.Packages.React)
local OutlinedMaterialIconsHD = require(game.ReplicatedStorage.Packages.OutlinedMaterialIconsHD)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local parentModule = require(script.Parent)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {
	Lock = Spritesheets.MAP["Badge Lock"] or OutlinedMaterialIconsHD.lock,
	Unlock = Spritesheets.MAP["Badge Unlock"] or OutlinedMaterialIconsHD.lock_open,
	Error = OutlinedMaterialIconsHD.broken_image
}
local createElement = React.createElement
return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		Text = "Flash Step",
		Icon = UILabs.Choose({ "Lock", "Unlock", "Error" }, 1),
		IsUnlocked = true,
		HasLevel = false,
		Level = UILabs.Slider(3, 1, 10, 1),
		IsClickable = true,
		SizePx = UILabs.Slider(90, 30, 300, 1)
	}
}, function(p)
	local sizePx = p.controls.SizePx
	local v4 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(math.round(sizePx * 2), (math.round(sizePx * 2)))
	}
	local v8 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(sizePx, sizePx),
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BorderColor3 = CONSTANTS.COLOR.PALETTE.GREY_800,
		IsUnlocked = p.controls.IsUnlocked,
		Icon = v[p.controls.Icon],
		Text = p.controls.Text,
		Level = 0,
		OnClick = 0
	}
	local level

	if p.controls.HasLevel then
		level = p.controls.Level
	end

	v8.Level = level
	v8.OnClick = p.controls.IsClickable and function()
		print("click", p.controls.Text)
	end or nil
	return createElement("Frame", v4, {
		MiscButton = createElement(parentModule, v8)
	})
end)