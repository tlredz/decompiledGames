local TweenService = game:GetService("TweenService")
local v = {
	Distance = 6,
	Duration = 1.4,
	Sway = 0,
	SwayDuration = 1.9,
	Style = Enum.EasingStyle.Sine
}
local parent = script.Parent
local position = parent.Position
local rotation = parent.Rotation
local v2 = table.create(3)
local count = 0
local completedConnection = nil

local function buildHover(parent2, data)
	local position2 = position - UDim2.fromOffset(0, data.Distance)
	local position3 = position + UDim2.fromOffset(0, data.Distance)
	local tweenInfo = TweenInfo.new(data.Duration, data.Style, Enum.EasingDirection.InOut, -1, true)
	local tween = TweenService:Create(parent2, TweenInfo.new(data.Duration / 2, data.Style, Enum.EasingDirection.Out), {
		Position = position2
	})
	count += 1
	v2[count] = tween
	completedConnection = tween.Completed:Connect(function(p)
		if p ~= Enum.PlaybackState.Completed then
			return
		end

		local tween2 = TweenService:Create(parent2, tweenInfo, {
			Position = position3
		})
		count += 1
		v2[count] = tween2
		completedConnection:Disconnect()
		completedConnection = nil
	end)

	if data.Sway and data.Sway > 0 then
		parent2.Rotation = rotation - data.Sway
		local tweenInfo2 = TweenInfo.new(data.SwayDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		count += 1
		v2[count] = TweenService:Create(parent2, tweenInfo2, {
			Rotation = rotation + data.Sway
		})
	end
end

buildHover(parent, v)
local v3 = {}
local ancestryChangedConnection = nil
local v4 = false

local function isVisible()
	local parent2 = parent

	while parent2 do
		if parent2:IsA("GuiObject") then
			if not parent2.Visible then
				return false
			end
		elseif parent2:IsA("LayerCollector") then
			return parent2.Enabled
		end

		parent2 = parent2.Parent
	end

	return false
end

local function setActive(p)
	if p == v4 then
		return
	end

	v4 = p

	if p then
		for i = 1, count do
			local v5 = v2[i]

			if v5.PlaybackState ~= Enum.PlaybackState.Completed then
				v5:Play()
			end
		end
	else
		for i = 1, count do
			local v5 = v2[i]

			if v5.PlaybackState == Enum.PlaybackState.Playing then
				v5:Pause()
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function evaluate()
	setActive(isVisible())
end

local function watchAncestors()
	for i = #v3, 1, -1 do
		v3[i]:Disconnect()
		v3[i] = nil
	end

	local parent2 = parent

	while parent2 do
		if parent2:IsA("GuiObject") then
			v3[#v3 + 1] = parent2:GetPropertyChangedSignal("Visible"):Connect(evaluate)
		elseif parent2:IsA("LayerCollector") then
			v3[#v3 + 1] = parent2:GetPropertyChangedSignal("Enabled"):Connect(evaluate)
			break
		end

		parent2 = parent2.Parent
	end

	evaluate() -- equivalent call inferred; original call site unknown
end

local function teardown()
	if v4 ~= false then
		v4 = false

		for i = 1, count do
			local v5 = v2[i]

			if v5.PlaybackState == Enum.PlaybackState.Playing then
				v5:Pause()
			end
		end
	end

	for i = #v3, 1, -1 do
		v3[i]:Disconnect()
		v3[i] = nil
	end

	if ancestryChangedConnection then
		ancestryChangedConnection:Disconnect()
		ancestryChangedConnection = nil
	end

	if completedConnection then
		completedConnection:Disconnect()
		completedConnection = nil
	end

	for i = 1, count do
		v2[i]:Cancel()
		v2[i] = nil
	end

	count = 0
	parent.Position = position
	parent.Rotation = rotation
end

script.Destroying:Once(teardown)
ancestryChangedConnection = parent.AncestryChanged:Connect(watchAncestors)
watchAncestors()