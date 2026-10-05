require(script.Parent.Parent.SpinnerTypes)

local function LerpSequence(headerTextColor, headerTextColor2, p: number)
	local colorSequenceKeypoints = {}

	for i, keypoint in ipairs(headerTextColor.Keypoints) do
		colorSequenceKeypoints[i] = ColorSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value:Lerp(headerTextColor2.Keypoints[i].Value, p)
		)
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

local ThemeTransition = {}
ThemeTransition.__index = ThemeTransition

function ThemeTransition.new(p, value: number?)
	return (setmetatable({
		Current = p,
		From = p,
		Target = p,
		Elapsed = 0,
		Duration = value or 0.5
	}, ThemeTransition))
end

function ThemeTransition:SetTarget(target, value)
	self.From = self.Current
	self.Target = target
	self.Elapsed = 0
	self.Duration = value or 0.5
end

function ThemeTransition:Update(p)
	debug.profilebegin("ThemeTransition.Update")
	self.Elapsed += p
	local v = math.clamp(self.Elapsed / self.Duration, 0, 1)
	local current = {
		Name = self.Target.Name,
		HeaderTitleText = self.Target.HeaderTitleText,
		Colors = 0
	}
	local underGlowColor

	if v == 1 then
		underGlowColor = self.Target.Colors.UnderGlowColor
	else
		underGlowColor = self.From.Colors.UnderGlowColor:Lerp(self.Target.Colors.UnderGlowColor, v)
	end

	local headerTextColor

	if v == 1 then
		headerTextColor = self.Target.Colors.HeaderTextColor
	else
		headerTextColor = LerpSequence(self.From.Colors.HeaderTextColor, self.Target.Colors.HeaderTextColor, v)
	end

	current.Colors = {
		UnderGlowColor = underGlowColor,
		HeaderTextColor = headerTextColor
	}
	self.Current = current
	debug.profileend()
	return self.Current
end

return ThemeTransition