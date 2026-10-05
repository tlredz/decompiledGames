local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local v = {
	Count = 110,
	FallSeconds = { 1.2, 2.1 },
	DriftPixels = 140,
	SpinDegrees = { 420, 1260 },
	SizePixels = { 13, 26 },
	StaggerSeconds = 2,
	FadeLastSeconds = 0.4,
	Sound = "Confetti",
	Colors = {
		Color3.fromRGB(255, 92, 92),
		Color3.fromRGB(255, 180, 60),
		Color3.fromRGB(255, 240, 90),
		Color3.fromRGB(105, 230, 120),
		Color3.fromRGB(90, 190, 255),
		Color3.fromRGB(170, 120, 255),
		Color3.fromRGB(255, 130, 220)
	}
}
local random = Random.new()

local function Opt(p, p2)
	local selected = p and p[p2]

	if selected == nil then
		return v[p2]
	end

	return selected
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Between(list)
	return random:NextNumber(list[1], list[2])
end

return {
	Burst = function(data)
		local localPlayer = Players.LocalPlayer
		local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")

		if not playerGui then
			return
		end

		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "Confetti"
		screenGui.IgnoreGuiInset = true
		screenGui.ResetOnSpawn = false
		screenGui.DisplayOrder = 1000
		screenGui.Parent = playerGui
		local sound = data and data.Sound

		if sound == nil then
			sound = v.Sound
		end

		local SFX = sound and SoundService:FindFirstChild("SFX")
		local sound2 = SFX and SFX:FindFirstChild(sound)

		if sound2 and sound2:IsA("Sound") then
			sound2:Play()
		end

		local count = data and data.Count

		if count == nil then
			count = v.Count
		end

		local colors = data and data.Colors

		if colors == nil then
			colors = v.Colors
		end

		local fallSeconds = data and data.FallSeconds

		if fallSeconds == nil then
			fallSeconds = v.FallSeconds
		end

		local driftPixels = data and data.DriftPixels

		if driftPixels == nil then
			driftPixels = v.DriftPixels
		end

		local spinDegrees = data and data.SpinDegrees

		if spinDegrees == nil then
			spinDegrees = v.SpinDegrees
		end

		local sizePixels = data and data.SizePixels

		if sizePixels == nil then
			sizePixels = v.SizePixels
		end

		local staggerSeconds = data and data.StaggerSeconds

		if staggerSeconds == nil then
			staggerSeconds = v.StaggerSeconds
		end

		local fadeLastSeconds = data and data.FadeLastSeconds

		if fadeLastSeconds == nil then
			fadeLastSeconds = v.FadeLastSeconds
		end

		local v2 = 0

		for _ = 1, count do
			local frame = Instance.new("Frame")
			local between = Between(sizePixels) -- equivalent call inferred; original call site unknown
			frame.Size = UDim2.fromOffset(between, between * random:NextNumber(0.45, 0.7))
			frame.AnchorPoint = Vector2.new(0.5, 0.5)
			frame.BackgroundColor3 = colors[random:NextInteger(1, #colors)]
			frame.BorderSizePixel = 0
			frame.Rotation = random:NextNumber(0, 360)
			local number = random:NextNumber(0, 1)
			frame.Position = UDim2.new(number, 0, 0, -random:NextNumber(10, 80))
			frame.Parent = screenGui
			local between2 = Between(fallSeconds) -- equivalent call inferred; original call site unknown
			local number2 = random:NextNumber(0, staggerSeconds)
			v2 = math.max(v2, number2 + between2)
			task.delay(number2, function()
				if not frame.Parent then
					return
				end

				local tweenInfo = TweenInfo.new(between2, Enum.EasingStyle.Linear)
				local v10 = {
					Position = UDim2.new(
						number,
						random:NextNumber(-driftPixels, driftPixels),
						1,
						random:NextNumber(20, 60)
					),
					Rotation = 0
				}
				local v11 = spinDegrees
				v10.Rotation = frame.Rotation + random:NextNumber(v11[1], v11[2]) * (random:NextNumber() < 0.5 and -1 or 1)
				TweenService:Create(frame, tweenInfo, v10):Play()
				task.delay(math.max(between2 - fadeLastSeconds, 0), function()
					if frame.Parent then
						TweenService:Create(frame, TweenInfo.new(fadeLastSeconds), {
							BackgroundTransparency = 1
						}):Play()
					end
				end)
			end)
		end

		task.delay(v2 + 0.2, function()
			screenGui:Destroy()
		end)
		return screenGui
	end
}