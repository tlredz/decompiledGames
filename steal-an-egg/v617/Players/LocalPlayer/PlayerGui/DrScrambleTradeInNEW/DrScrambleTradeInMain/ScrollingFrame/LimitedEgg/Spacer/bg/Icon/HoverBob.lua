local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiVisibility = require(ReplicatedStorage.Client.UIEffects.GuiVisibility)
local v = {
	Distance = 6,
	Duration = 1.4,
	Sway = 0,
	SwayDuration = 1.9,
	Style = Enum.EasingStyle.Sine
}

local function startHover(parent, data)
	local position = parent.Position
	local rotation = parent.Rotation
	local position2 = position - UDim2.fromOffset(0, data.Distance)
	local position3 = position + UDim2.fromOffset(0, data.Distance)
	local v4 = {}
	local flag = false

	local function syncTweens(p)
		for _, v5 in v4 do
			local playbackState = v5.PlaybackState

			if p and (playbackState == Enum.PlaybackState.Begin or playbackState == Enum.PlaybackState.Paused) then
				v5:Play()
			elseif not p and (playbackState == Enum.PlaybackState.Playing or playbackState == Enum.PlaybackState.Delayed) then
				v5:Pause()
			end
		end
	end

	local v5 = GuiVisibility.Watch(parent, syncTweens, script)
	local tweenInfo = TweenInfo.new(data.Duration, data.Style, Enum.EasingDirection.InOut, -1, true)
	local tween = TweenService:Create(parent, TweenInfo.new(data.Duration / 2, data.Style, Enum.EasingDirection.Out), {
		Position = position2
	})
	table.insert(v4, tween)
	tween.Completed:Connect(function(p)
		if p ~= Enum.PlaybackState.Completed then
			return
		end

		local tween2 = TweenService:Create(parent, tweenInfo, {
			Position = position3
		})
		table.insert(v4, tween2)
		syncTweens(v5.IsVisible())
	end)
	syncTweens(v5.IsVisible())

	if data.Sway and data.Sway > 0 then
		parent.Rotation = rotation - data.Sway
		local tweenInfo2 = TweenInfo.new(data.SwayDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		table.insert(v4, (TweenService:Create(parent, tweenInfo2, {
			Rotation = rotation + data.Sway
		})))
		syncTweens(v5.IsVisible())
	end

	local function stop()
		if flag then
			return
		end

		flag = true
		v5.Destroy()

		for _, v6 in v4 do
			v6:Cancel()
			v6:Destroy()
		end

		parent.Position = position
		parent.Rotation = rotation
	end

	parent.Destroying:Once(stop)
	script.Destroying:Once(stop)
	return stop
end

startHover(script.Parent, v)