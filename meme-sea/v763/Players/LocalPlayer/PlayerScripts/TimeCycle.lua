local v = nil
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local atmosphere = Lighting:WaitForChild("Atmosphere")
local tweenInfo = TweenInfo.new(
	Lighting:GetAttribute("time_Wait"),
	Enum.EasingStyle[Lighting:GetAttribute("tween_EasingStyle")],
	Enum.EasingDirection[Lighting:GetAttribute("tween_EasingDirection")],
	0,
	false,
	0
)
Lighting.ClockTime = Lighting:GetAttribute("Time")

function setupLight(enabled)
	if typeof(enabled) == "boolean" then
		for _, light in ipairs(workspace.Island:GetDescendants()) do
			if light:IsA("PointLight") then
				light.Enabled = enabled
			end
		end
	end
end

function roundNumber(p, value)
	return (tonumber(string.format("%." .. (value or 0) .. "f", p)))
end

Lighting:GetAttributeChangedSignal("Time"):Connect(function()
	if (Lighting:GetAttribute("Time") < 7 or Lighting:GetAttribute("Time") >= 17) and roundNumber(atmosphere.Haze, 2) ~= 0.01 and script:GetAttribute("Light") == false then
		atmosphere.Haze = 0.01
		Lighting.EnvironmentDiffuseScale = 1
		script:SetAttribute("Light", true)
		setupLight(true)

		if v and v.PlaybackState == Enum.PlaybackState.Playing then
			v:Pause()
		end

		Lighting.ClockTime = 17.9

		if Lighting.ClockTime > Lighting:GetAttribute("Time") then
			Lighting.ClockTime = 0
		else
			v = TweenService:Create(Lighting, tweenInfo, {
				ClockTime = Lighting:GetAttribute("Time")
			})
			v:Play()
		end
	elseif Lighting:GetAttribute("Time") >= 7 and Lighting:GetAttribute("Time") < 17 and atmosphere.Haze ~= 0 and script:GetAttribute("Light") == true then
		atmosphere.Haze = 0
		Lighting.EnvironmentDiffuseScale = 0.5
		script:SetAttribute("Light", false)
		setupLight(false)
	end

	if v and v.PlaybackState == Enum.PlaybackState.Playing then
		v:Pause()
	end

	if Lighting.ClockTime > Lighting:GetAttribute("Time") then
		Lighting.ClockTime = 0
		return
	end

	v = TweenService:Create(Lighting, tweenInfo, {
		ClockTime = Lighting:GetAttribute("Time")
	})
	v:Play()
end)
Lighting:GetAttributeChangedSignal("time_Wait")
tweenInfo = TweenInfo.new(
	Lighting:GetAttribute("time_Wait"),
	tweenInfo.EasingStyle,
	tweenInfo.EasingDirection,
	0,
	false,
	0
)
Lighting:GetAttributeChangedSignal("tween_EasingStyle")
tweenInfo = TweenInfo.new(
	tweenInfo.Time,
	Enum.EasingStyle[Lighting:GetAttribute("tween_EasingStyle")],
	tweenInfo.EasingDirection,
	0,
	false,
	0
)
Lighting:GetAttributeChangedSignal("tween_EasingDirection")
tweenInfo = TweenInfo.new(
	tweenInfo.Time,
	tweenInfo.EasingStyle,
	Enum.EasingDirection[Lighting:GetAttribute("tween_EasingDirection")],
	0,
	false,
	0
)