local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local weather = ReplicatedStorage2:WaitForChild("world"):WaitForChild("weather")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local clientWeather = ReplicatedStorage3:WaitForChild("world"):WaitForChild("clientWeather")
local modules = ReplicatedStorage.client.modules
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local legacyLocalPlayerData = require(modules.legacyLocalPlayerData)
local level = legacyLocalPlayerData.fetch():WaitForChild("Stats"):FindFirstChild("level")
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local aBNoRainFirstTime = script.ABNoRainFirstTime
local weather2 = playerGui:WaitForChild("sounds"):WaitForChild("weather")
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local rain = require(ReplicatedStorage4.shared.modules:WaitForChild("rain"))

local function ABAlwaysClearDayElegible(_)
	return true
end

local function isRainDisabledViaAB()
	return aBNoRainFirstTime.Value
end

if script.TransparencyConstraint.Value and script.CanCollideConstraint.Value then
	rain:SetCollisionMode(rain.CollisionMode.Function, function(p)
		return p.Transparency <= 0.97 and p.CanCollide
	end)
elseif script.TransparencyConstraint.Value then
	rain:SetCollisionMode(rain.CollisionMode.Function, function(p)
		return p.Transparency <= 0.97
	end)
elseif script.CanCollideConstraint.Value then
	rain:SetCollisionMode(rain.CollisionMode.Function, function(p)
		return p.CanCollide
	end)
end

function SetWeatherFX()
	local SOUND_ID = "rbxassetid://5113213873"
	local value

	if clientWeather.Value == "" then
		value = weather.Value
	else
		value = clientWeather.Value
	end

	rain:Disable()
	task.wait(3)

	if level.Value <= 25 and value ~= "Clear" then
		clientWeather.Value = "Clear"
		value = clientWeather.Value
	end

	if value == "Clear" then
		if weather2.Playing then
			local TweenService2 = game:GetService("TweenService")
			local tween = TweenService2:Create(
				weather2,
				TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Volume = 0
				}
			)
			tween:Play()
			tween.Completed:Connect(function()
				weather2:Stop()
				local TweenService3 = game:GetService("TweenService")
				TweenService3:Create(weather2, TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Volume = 0.5
				}):Play()
			end)
		end

		local SoundService = game:GetService("SoundService")
		TweenService:Create(
			SoundService:WaitForChild("weather"),
			TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Volume = 0
			}
		):Play()
	elseif value == "Rain" then
		weather2.SoundId = "rbxassetid://5911952995"
		local SoundService = game:GetService("SoundService")
		TweenService:Create(
			SoundService:WaitForChild("weather"),
			TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Volume = 0.45
			}
		):Play()
		local SoundService2 = game:GetService("SoundService")
		TweenService:Create(
			SoundService2:WaitForChild("weather"):WaitForChild("muffle"),
			TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				HighGain = -80,
				LowGain = 10,
				MidGain = -7.1
			}
		):Play()
		rain:SetCollisionMode(
			rain.CollisionMode.Blacklist,
			game.Workspace:WaitForChild("zones"):WaitForChild("player"):GetChildren()
		)

		if not aBNoRainFirstTime.Value then
			rain:Enable()
		end
	elseif value == "Stormy" then
		weather2.SoundId = "rbxassetid://5911952995"
		local SoundService = game:GetService("SoundService")
		TweenService:Create(
			SoundService:WaitForChild("weather"),
			TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Volume = 0.55
			}
		):Play()
		local SoundService2 = game:GetService("SoundService")
		TweenService:Create(
			SoundService2:WaitForChild("weather"):WaitForChild("muffle"),
			TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				HighGain = -80,
				LowGain = 10,
				MidGain = -7.1
			}
		):Play()
		rain:SetCollisionMode(
			rain.CollisionMode.Blacklist,
			game.Workspace:WaitForChild("zones"):WaitForChild("player"):GetChildren()
		)

		if not aBNoRainFirstTime.Value then
			rain:Enable()
		end
	elseif value == "Windy" then
		weather2.SoundId = SOUND_ID
		local SoundService = game:GetService("SoundService")
		TweenService:Create(
			SoundService:WaitForChild("weather"),
			TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Volume = 0.2
			}
		):Play()
		local SoundService2 = game:GetService("SoundService")
		TweenService:Create(
			SoundService2:WaitForChild("weather"):WaitForChild("muffle"),
			TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				HighGain = -67.4,
				LowGain = 1.9,
				MidGain = -4.4
			}
		):Play()
	elseif value == "Foggy" then
		weather2.SoundId = SOUND_ID
		local SoundService = game:GetService("SoundService")
		TweenService:Create(
			SoundService:WaitForChild("weather"),
			TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Volume = 0.2
			}
		):Play()
		local SoundService2 = game:GetService("SoundService")
		TweenService:Create(
			SoundService2:WaitForChild("weather"):WaitForChild("muffle"),
			TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				HighGain = -67.4,
				LowGain = 1.9,
				MidGain = -4.4
			}
		):Play()
	elseif value == "Aurora Borealis" then
		weather2.SoundId = SOUND_ID
		local SoundService = game:GetService("SoundService")
		TweenService:Create(
			SoundService:WaitForChild("weather"),
			TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Volume = 0.2
			}
		):Play()
		local SoundService2 = game:GetService("SoundService")
		TweenService:Create(
			SoundService2:WaitForChild("weather"):WaitForChild("muffle"),
			TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				HighGain = -67.4,
				LowGain = 1.9,
				MidGain = -4.4
			}
		):Play()
	else
		weather2.SoundId = SOUND_ID
		local SoundService = game:GetService("SoundService")
		TweenService:Create(
			SoundService:WaitForChild("weather"),
			TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Volume = 0.2
			}
		):Play()
		local SoundService2 = game:GetService("SoundService")
		TweenService:Create(
			SoundService2:WaitForChild("weather"):WaitForChild("muffle"),
			TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				HighGain = -67.4,
				LowGain = 1.9,
				MidGain = -4.4
			}
		):Play()
	end
end

weather.Changed:Connect(function()
	SetWeatherFX()
end)
clientWeather.Changed:Connect(function()
	SetWeatherFX()
end)
SettingsController:GetSettingChangedSignal("showRain"):Connect(function(p)
	if p or not rain:IsEnabled() then
		if p and (weather.Value == "Rain" or weather.Value == "Stormy") and not aBNoRainFirstTime.Value then
			rain:Enable()
		end
	else
		rain:Disable()
	end
end)
task.wait()
SetWeatherFX()