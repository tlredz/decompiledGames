local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("../ZoneController")
local module2 = require("../LightingController")
local module3 = require("../SettingsController")
local module4 = require("../DataController")
local playerDataReplicator = module4.PlayerDataReplicator
local Trove = require(ReplicatedStorage.packages.Trove)
local ZoneLighting = {
	ZoneTrove = Trove.new()
}

function ZoneLighting.Start(_)
	playerDataReplicator:WaitForLoaded()
	task.wait(0.1)
	local flag = false

	local function deferUpdate()
		if flag then
			return
		end

		flag = true
		task.defer(function()
			flag = false
			module2.UpdateLighting(1)
		end)
	end

	module:ObserveZone(function(_, instance)
		ZoneLighting.ZoneTrove:Clean()

		if instance then
			debug.profilebegin("ConnectZoneLighting")

			for className, _ in module2.Defaults do
				local firstChildOfClass = instance:FindFirstChildOfClass(className)

				if firstChildOfClass then
					ZoneLighting.ZoneTrove:Connect(firstChildOfClass.Changed, deferUpdate)
				end
			end

			local lightingProperties = instance:FindFirstChild("lightingProperties")

			if lightingProperties then
				ZoneLighting.ZoneTrove:Connect(lightingProperties.AttributeChanged, deferUpdate)
			end

			local lightingPropertiesNight = instance:FindFirstChild("lightingPropertiesNight")

			if lightingPropertiesNight then
				ZoneLighting.ZoneTrove:Connect(lightingPropertiesNight.AttributeChanged, deferUpdate)

				for className, _ in module2.Defaults do
					local firstChildOfClass = lightingPropertiesNight:FindFirstChildOfClass(className)

					if firstChildOfClass then
						ZoneLighting.ZoneTrove:Connect(firstChildOfClass.Changed, deferUpdate)
					end
				end
			end

			debug.profileend()
		end

		module2.UpdateLighting(1)
	end)

	local function applyZoneLighting(p)
		local currentZone = module.CurrentZone

		if currentZone == nil then
			return p
		end

		debug.profilebegin("ZoneLighting")
		local value = currentZone:FindFirstChild("underground") and currentZone.underground.Value

		if value then
			p.Lighting.ClockTime = 0
			p.Lighting.Brightness = 2
		end

		for className, v in p do
			debug.profilebegin(className)
			local firstChildOfClass = currentZone:FindFirstChildOfClass(className)

			if firstChildOfClass then
				local v2

				if className == "ColorCorrectionEffect" then
					v2 = not value
				else
					v2 = false
				end

				for k, v3 in v do
					if v2 and typeof(v3) == "number" then
						v[k] += firstChildOfClass[k]
					else
						v[k] = firstChildOfClass[k]
					end
				end
			end

			debug.profileend()
		end

		local maxExtraBrightness = 1e999
		local maxExtraSaturation = 1e999
		debug.profilebegin("clouds")
		local clouds = currentZone:FindFirstChild("clouds")

		if clouds then
			for attributeName, _ in p.Clouds do
				local attribute = clouds:GetAttribute(attributeName)

				if attribute ~= nil then
					p.Clouds[attributeName] = attribute
				end
			end
		end

		debug.profileend()
		debug.profilebegin("lightingProperties")
		local lightingProperties = currentZone:FindFirstChild("lightingProperties")

		if lightingProperties then
			for attributeName, _ in p.Lighting do
				local attribute = lightingProperties:GetAttribute(attributeName)

				if attribute ~= nil then
					p.Lighting[attributeName] = attribute
				end
			end

			local maxExtraBrightness2 = lightingProperties:GetAttribute("MaxExtraBrightness")
			local maxExtraSaturation2 = lightingProperties:GetAttribute("MaxExtraSaturation")
			maxExtraBrightness = maxExtraBrightness2 or maxExtraBrightness

			if maxExtraSaturation2 then
				maxExtraSaturation = maxExtraSaturation2
			end
		end

		debug.profileend()

		if not value then
			local clockTime = p.Lighting.ClockTime

			if clockTime >= 18 or clockTime < 6.5 then
				local lightingPropertiesNight = currentZone:FindFirstChild("lightingPropertiesNight")

				if lightingPropertiesNight then
					for className, v in p do
						debug.profilebegin("NightObj_" .. className)
						local firstChildOfClass = lightingPropertiesNight:FindFirstChildOfClass(className)

						if firstChildOfClass then
							for k, _ in v do
								v[k] = firstChildOfClass[k]
							end
						end

						debug.profileend()
					end

					debug.profilebegin("lightingPropertiesNightAttributes")

					for attributeName, _ in p.Lighting do
						local attribute = lightingPropertiesNight:GetAttribute(attributeName)

						if attribute ~= nil then
							p.Lighting[attributeName] = attribute
						end
					end

					maxExtraBrightness = lightingPropertiesNight:GetAttribute("MaxExtraBrightness") or maxExtraBrightness
					maxExtraSaturation = lightingPropertiesNight:GetAttribute("MaxExtraSaturation") or maxExtraSaturation
					debug.profileend()
				end
			end
		end

		debug.profilebegin("ApplyUserAccessibilitySettings")
		local settingValue = module3:GetSettingValue("brightness") or 0
		local settingValue2 = module3:GetSettingValue("saturation") or 0
		local v = math.clamp(settingValue, 0, maxExtraBrightness)
		local v2 = math.clamp(settingValue2, 0, maxExtraSaturation)
		p.ColorCorrectionEffect.Brightness += v
		p.ColorCorrectionEffect.Saturation += v2
		debug.profileend()
		debug.profileend()
		return p
	end

	module2.HookLighting:BindAtPriority(2000, function(p)
		if module.IsUnderground then
			applyZoneLighting(p)
		end
	end)
	module2.HookLighting:BindAtPriority(500, function(p)
		if not module.IsUnderground then
			applyZoneLighting(p)
		end
	end)
end

return ZoneLighting