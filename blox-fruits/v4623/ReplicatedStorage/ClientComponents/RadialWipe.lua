local Component = require(game.ReplicatedStorage.Modules.Component)
require(game.ReplicatedStorage.Modules.Util.Trove)
local _ = game.Players.LocalPlayer
local v = Component.new({
	Tag = "RadialWipe"
})

function v.Construct(_) end

function v.Start(p)
	local instance = p.Instance
	local frame = instance.Frame1.Frame
	local frame2 = instance.Frame2.Frame

	local function updatePercentage()
		local attributes = instance:GetAttributes()
		local v2 = math.clamp((attributes.Percentage or 0) * 100 * 3.6, 0, 360)

		if attributes.DoFlip == nil then
			attributes.DoFlip = false
		end

		frame.UIGradient.Rotation = not attributes.DoFlip and math.clamp(v2, 180, 360) or 180 - math.clamp(v2, 0, 180)
		frame2.UIGradient.Rotation = not attributes.DoFlip and math.clamp(v2, 0, 180) or 180 - math.clamp(v2, 180, 360)
		frame.Visible = v2 > 0
		frame2.Visible = v2 > 0
		local fillColor = attributes.FillColor or Color3.fromRGB(255, 255, 255)
		local backgroundColor = attributes.BackgroundColor or Color3.fromRGB(0, 0, 0)
		frame.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, fillColor),
			ColorSequenceKeypoint.new(0.5, fillColor),
			ColorSequenceKeypoint.new(0.501, backgroundColor),
			ColorSequenceKeypoint.new(1, backgroundColor)
		})
		frame2.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, fillColor),
			ColorSequenceKeypoint.new(0.5, fillColor),
			ColorSequenceKeypoint.new(0.501, backgroundColor),
			ColorSequenceKeypoint.new(1, backgroundColor)
		})

		if not attributes.FillTransparency then
			attributes.FillTransparency = 0.5
		end

		if not attributes.BackgroundFrameTransparency then
			attributes.BackgroundFrameTransparency = 0.5
		end

		frame.UIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, attributes.FillTransparency),
			NumberSequenceKeypoint.new(0.5, attributes.FillTransparency),
			NumberSequenceKeypoint.new(0.501, attributes.BackgroundFrameTransparency),
			NumberSequenceKeypoint.new(1, attributes.BackgroundFrameTransparency)
		})
		frame2.UIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, attributes.FillTransparency),
			NumberSequenceKeypoint.new(0.5, attributes.FillTransparency),
			NumberSequenceKeypoint.new(0.501, attributes.BackgroundFrameTransparency),
			NumberSequenceKeypoint.new(1, attributes.BackgroundFrameTransparency)
		})
	end

	updatePercentage()
	instance:GetAttributeChangedSignal("Percentage"):Connect(updatePercentage)
end

function v.Stop(_) end

return v