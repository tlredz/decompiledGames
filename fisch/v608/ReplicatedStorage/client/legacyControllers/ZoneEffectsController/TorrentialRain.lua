local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Trove = require(ReplicatedStorage.packages.Trove)
local rain = require(ReplicatedStorage.shared.modules:WaitForChild("rain"))
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local currentCamera = workspace.CurrentCamera
local weather = ReplicatedStorage:WaitForChild("world"):WaitForChild("weather")
local clientWeather = ReplicatedStorage.world:WaitForChild("clientWeather")
local tweenInfo = TweenInfo.new(2)
local v = { "Rain", "Stormy" }
local v2 = {
	Color = Color3.fromRGB(173, 134, 84),
	SpeedRatio = 1,
	Direction = (createVector(0.35, -1, 0)).Unit,
	LightInfluence = 0.2
}
local v3 = {
	Color = Color3.new(1, 1, 1),
	SpeedRatio = 0.9,
	Direction = createVector(0, -1, 0),
	LightInfluence = 0.9
}
local v4 = {
	Brightness = -0.08,
	Contrast = 0.05,
	Saturation = -0.3,
	TintColor = Color3.fromRGB(209, 185, 152)
}
local v5 = {
	Brightness = 0,
	Contrast = 0,
	Saturation = 0,
	TintColor = Color3.new(1, 1, 1)
}

local function isNaturallyRaining()
	local value = clientWeather.Value

	if value == "" then
		value = weather.Value
	end

	return table.find(v, value) ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyRainStyle(data)
	rain:SetColor(data.Color)
	rain:SetSpeedRatio(data.SpeedRatio)
	rain:SetDirection(data.Direction)
	rain:SetLightInfluence(data.LightInfluence)
end

local function buildDownpour()
	local part = Instance.new("Part")
	part.Name = "TorrentialRain-Downpour"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = createVector(70, 1, 70)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxassetid://1822883048"
	particleEmitter.Color = ColorSequence.new(v2.Color)
	particleEmitter.Size = NumberSequence.new(11)
	particleEmitter.Transparency = NumberSequence.new(0.35)
	particleEmitter.Lifetime = NumberRange.new(0.8)
	particleEmitter.Rate = 400
	particleEmitter.Speed = NumberRange.new(90)
	particleEmitter.EmissionDirection = Enum.NormalId.Bottom
	particleEmitter.Orientation = Enum.ParticleOrientation.FacingCameraWorldUp
	particleEmitter.LightEmission = 0.05
	particleEmitter.LightInfluence = v2.LightInfluence
	particleEmitter.Parent = part
	part.Parent = currentCamera
	return part
end

local TorrentialRain = {}
TorrentialRain.__index = TorrentialRain

function TorrentialRain.new()
	local self = setmetatable({}, TorrentialRain)
	self._trove = Trove.new()
	applyRainStyle(v2) -- equivalent call inferred; original call site unknown

	if SettingsController:GetSettingValue("showRain") and not rain:IsEnabled() then
		rain:Enable()
	end

	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Name = "TorrentialRain-Correction"
	colorCorrectionEffect.Parent = Lighting
	TweenService:Create(colorCorrectionEffect, tweenInfo, v4):Play()
	local downpour = buildDownpour()
	local particleEmitter = downpour:FindFirstChildOfClass("ParticleEmitter")
	particleEmitter.Enabled = SettingsController:GetSettingValue("showRain")
	self._trove:Add(SettingsController:GetSettingChangedSignal("showRain"):Connect(function(enabled)
		particleEmitter.Enabled = enabled
	end))
	local total = 0
	self._trove:Add(RunService.Heartbeat:Connect(function(dt)
		downpour.CFrame = CFrame.new(currentCamera.CFrame.Position + createVector(0, 45, 0))
		total += dt

		if total < 1 then
			return
		end

		total = 0

		if SettingsController:GetSettingValue("showRain") and not rain:IsEnabled() then
			rain:Enable()
		end
	end))
	self._trove:Add(downpour)
	self._trove:Add(function()
		applyRainStyle(v3) -- equivalent call inferred; original call site unknown
		local value = clientWeather.Value

		if value == "" then
			value = weather.Value
		end

		if table.find(v, value) == nil and rain:IsEnabled() then
			rain:Disable()
		end

		local tween = TweenService:Create(colorCorrectionEffect, tweenInfo, v5)
		tween.Completed:Once(function()
			colorCorrectionEffect:Destroy()
		end)
		tween:Play()
	end)
	return self
end

function TorrentialRain:Destroy()
	self._trove:Destroy()
end

return TorrentialRain