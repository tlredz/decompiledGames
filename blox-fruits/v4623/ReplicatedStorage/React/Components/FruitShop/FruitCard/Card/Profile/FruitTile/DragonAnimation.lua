local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.Spritesheets)
local usePeriod = require(game.ReplicatedStorage.React.Hooks.Animation.usePeriod)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {
	Image = "http://www.roblox.com/asset/?id=115164378651932",
	ImageRectOffset = Vector2.new(5, 305),
	ImageRectSize = Vector2.new(140, 140)
}
local v2 = {
	Image = "http://www.roblox.com/asset/?id=115164378651932",
	ImageRectOffset = Vector2.new(455, 155),
	ImageRectSize = Vector2.new(140, 140)
}

function getAnimationSequence(p: number)
	local v3 = p * 1.25
	local v4 = 1
	local v5 = v3 - 0.25
	local total = 0
	local v6 = 0.001 - v5

	if v6 > 0 then
		total += v6 / 0.25
		v5 = 0.001
		v3 = math.max(v3, v5 + 0.25)
	end

	local v7 = v3 - 0.999

	if v7 > 0 then
		v4 -= v7 / 0.25
		v3 = 0.999
	end

	if v3 < v5 then
		v5 = v3 - 0.001
	end

	local v8 = {
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(v5, total),
		NumberSequenceKeypoint.new(v3, v4),
		NumberSequenceKeypoint.new(1, 1)
	}
	return NumberSequence.new(v8)
end

function getAnimationData(p: number)
	local v3 = p * 7.5
	local iconCycleCount = math.floor(v3 / 3.75)
	local v5 = v3 % 3.75
	return {
		IconCycleCount = iconCycleCount,
		IconScroll = math.round((not (v5 > 2.5) and 0 or (v5 - 2.5) / 1.25) / 0.01) * 0.01
	}
end

local createElement = React.createElement
return function(p)
	local imageTransparency = p.ImageTransparency or 0
	local v3 = usePeriod(true, 7.5)
	local v4 = React.useMemo(function()
		return getAnimationData(v3)
	end, { v3 })
	local transparency, transparency2 = React.useMemo(function()
		local getAnimationSequence2 = getAnimationSequence
		local v7

		if v4.IconCycleCount % 2 == 0 then
			v7 = v4.IconScroll
		else
			v7 = 1 - v4.IconScroll
		end

		local animationSequence = getAnimationSequence2(v7)
		local getAnimationSequence3 = getAnimationSequence
		local v8

		if v4.IconCycleCount % 2 == 1 then
			v8 = v4.IconScroll
		else
			v8 = 1 - v4.IconScroll
		end

		return animationSequence, getAnimationSequence3(v8)
	end, { v4.IconCycleCount, (math.round(v4.IconScroll / 0.01)) })
	return createElement("ImageLabel", RobloxTypes.mergeImageLabel({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		ImageTransparency = imageTransparency,
		Image = typeof(v2.Image) ~= "string" and "" or v2.Image,
		ImageRectOffset = v2.ImageRectOffset,
		ImageRectSize = v2.ImageRectSize
	}, p), {
		UIGradient = createElement("UIGradient", {
			Rotation = ((v4.IconCycleCount % 2 == 1 and 180 or 0) + 45) % 360,
			Transparency = transparency
		}),
		AltIcon = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ImageTransparency = imageTransparency,
			Image = typeof(v.Image) ~= "string" and "" or v.Image,
			ImageRectOffset = v.ImageRectOffset,
			ImageRectSize = v.ImageRectSize,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			ZIndex = CONSTANTS.LAYER.OVERLAY
		}, {
			UIGradient = createElement("UIGradient", {
				Rotation = ((v4.IconCycleCount % 2 == 0 and 180 or 0) + 45) % 360,
				Transparency = transparency2
			})
		})
	})
end