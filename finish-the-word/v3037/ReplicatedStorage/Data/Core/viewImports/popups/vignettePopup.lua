local import = _G.import("romodel")
local import2 = _G.import("viewImports")
local basic = import2:get("basic")
local sprite = import2:get("sprite").Sprite
local model = import.model("ScreenGui")

function model.init(data)
	local vignetteColor = data.VignetteColor or data.ImageColor
	local vignetteAnim = data.VignetteAnim
	return {
		Name = "VignettePopup",
		ResetOnSpawn = false,
		DisplayOrder = -1,
		IgnoreGuiInset = true
	}, {
		ImageLabel = vignetteColor and import.make(import.wrap("ImageLabel", basic.EmptyElement), {
			Image = "rbxassetid://77637233525621",
			ImageColor3 = vignetteColor,
			Size = UDim2.fromScale(1, 1)
		}) or nil,
		Sprite = vignetteAnim and import.make(sprite, {
			Images = vignetteAnim,
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			AspectRatio = 1.7777777777777777,
			ImageTransparency = 0.2
		}) or nil
	}
end

function model.prespawn(instance)
	local duration = instance.Duration or 2.5

	if instance.ImageLabel then
		instance.ImageLabel:tween(TweenInfo.new(duration, Enum.EasingStyle.Quint), {
			ImageTransparency = 1
		})
	end

	task.delay(duration, function()
		instance:Destroy()
	end)
end

return {
	VignettePopup = model
}