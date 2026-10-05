local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.5, 0),
	NumberSequenceKeypoint.new(0.501, 1),
	NumberSequenceKeypoint.new(1, 1)
})
local colorSequence = ColorSequence.new(Color3.new(1, 1, 1))
local RadialProgress = {}
RadialProgress.PROGRESS_TRAIL = 0
RadialProgress.OUTLINE_TRAIL = -0.75

function RadialProgress.bind(instance)
	if not instance then
		return nil
	end

	local function resolveHalf(childName)
		local child = instance:FindFirstChild(childName)

		if not child then
			warn(("[RadialProgress] %s is missing %s"):format(instance:GetFullName(), childName))
			return nil
		end

		local imageLabel = child:FindFirstChildWhichIsA("ImageLabel")

		if not imageLabel then
			warn(("[RadialProgress] %s has no ImageLabel"):format(child:GetFullName()))
			return nil
		end

		local uIGradient = imageLabel:FindFirstChildWhichIsA("UIGradient")

		if uIGradient then
			return imageLabel, uIGradient
		end

		warn(("[RadialProgress] %s has no UIGradient"):format(imageLabel:GetFullName()))
		return nil
	end

	local half, gradient = resolveHalf("Frame1")
	local half2, gradient2 = resolveHalf("Frame2")

	if not (gradient and gradient2) then
		return nil
	end

	gradient.Color = colorSequence
	gradient2.Color = colorSequence
	gradient.Transparency = numberSequence
	gradient2.Transparency = numberSequence
	return {
		image1 = half,
		image2 = half2,
		gradient1 = gradient,
		gradient2 = gradient2
	}
end

function RadialProgress.setPercent(p, value)
	if not p then
		return
	end

	local v = math.clamp(value, 0, 100) * 3.6
	p.gradient1.Rotation = math.clamp(v, 180, 360)
	p.gradient2.Rotation = math.clamp(v, 0, 180)
end

function RadialProgress.setTint(p, imageColor)
	if p and imageColor then
		p.image1.ImageColor3 = imageColor
		p.image2.ImageColor3 = imageColor
	end
end

function RadialProgress.setTransparency(p, imageTransparency)
	if not p then
		return
	end

	p.image1.ImageTransparency = imageTransparency
	p.image2.ImageTransparency = imageTransparency
end

return RadialProgress