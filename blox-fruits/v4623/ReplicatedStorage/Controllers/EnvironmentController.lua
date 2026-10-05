local createVector = vector.create
local Flags = require(game.ReplicatedStorage.Modules.Flags)
require(game.ReplicatedStorage.Modules.Weather.EnvironmentUtilShared)
local SimpleZone = require(game.ReplicatedStorage.Modules.SimpleZone)
local Tracking = require(game.ReplicatedStorage.Modules.Tracking)
require(script.Types)
local EnvironmentUtil = require(script.EnvironmentUtil)
local WeatherUtil = require(game.ReplicatedStorage.Controllers.WeatherController.WeatherUtil)
local WeatherData = require(game.ReplicatedStorage.Modules.Weather.WeatherData)
local Environment = require(script.Environment)
local CollectionService = game:GetService("CollectionService")
local v = nil
local localPlayer = game.Players.LocalPlayer
local v2 = nil
local v3 = nil
local v4 = {}

local function addEnvironment(instance)
	if not EnvironmentUtil.Environments[instance:GetAttribute("UID")] then
		local v5 = Environment.new(instance)
		local uid = v5.configuration.uid
		local group = v5.configuration.group
		EnvironmentUtil.Environments[uid] = v5
		EnvironmentUtil.Signals.GetRegionAddedSignal:Fire(uid, group)
		v5:Destroyed(function()
			if EnvironmentUtil.ClosestEnvironment and EnvironmentUtil.ClosestEnvironment.configuration.uid == uid then
				EnvironmentUtil.ClosestEnvironment = nil
			end

			EnvironmentUtil.Signals.GetRegionRemovedSignal:Fire(uid, group)
			EnvironmentUtil.Environments[uid] = nil
		end)
	end
end

local function updateCameraEnvironment(items)
	local v5 = #EnvironmentUtil.WithinZonesByGroup.IslandEvent > 0
	local environment = EnvironmentUtil.Environments[EnvironmentUtil.WithinZonesByGroup.Island[#EnvironmentUtil.WithinZonesByGroup.Island]]

	if v5 and environment then
		debug.profilebegin("EnvironmentController:IslandEvent")
		local v6 = {
			EnvironmentUtil.WithinZonesByGroup.Island,
			EnvironmentUtil.WithinZonesByGroup.Sea,
			EnvironmentUtil.WithinZonesByGroup.SeaEvent,
			EnvironmentUtil.WithinZonesByGroup.IslandEvent
		}

		for _, v7 in ipairs(v6) do
			for _, v8 in pairs(v7) do
				local environment2 = EnvironmentUtil.Environments[v8]
				local weather = environment2.weather

				for k, item in pairs(items) do
					item.numOfType = 1
					item.intensity = 0
					item.cover = 0
					item.density = 0
					item.color = nil
					local environment3 = item.environments[v8]

					if not environment3 then
						continue
					end

					if environment2.configuration.group == "IslandEvent" then
						if weather[k] then
							item.intensity = environment3.intensityRatio
							item.cover = environment3.coverRatio
							item.density = environment3.densityRatio
							item.color = environment3.colorRaw
						end
					else
						print("not IslandEvent", environment2.configuration.name, environment2.configuration.group)
					end
				end
			end
		end
	else
		local v6 = #EnvironmentUtil.WithinZonesByGroup.SeaEvent > 0
		local v7 = #EnvironmentUtil.WithinZonesByGroup.Sea > 0

		if v7 and v6 and not environment then
			debug.profilebegin("EnvironmentController:seaSubLayer_withinIsland")
			local v8 = { EnvironmentUtil.WithinZonesByGroup.Sea, EnvironmentUtil.WithinZonesByGroup.SeaEvent }
			local v9 = {
				Default = {
					Intensity = 0
				},
				Clouds = {
					Cover = 0,
					Density = 0
				}
			}

			for _, v10 in ipairs(v8) do
				for _, v11 in pairs(v10) do
					local weather = EnvironmentUtil.Environments[v11].weather

					for k, item in pairs(items) do
						if not weather[k] then
							continue
						end

						local environment2 = item.environments[v11]

						if not environment2 then
							continue
						end

						item.numOfType = 1
						local intensityRatio = environment2.intensityRatio
						local coverRatio = environment2.coverRatio
						local densityRatio = environment2.densityRatio

						if v9.Default.Intensity < intensityRatio then
							item.intensity = intensityRatio
							v9.Default.Intensity = intensityRatio
						end

						if v9.Clouds.Cover < coverRatio then
							item.cover = coverRatio
							v9.Clouds.Cover = coverRatio
						end

						if v9.Clouds.Density < densityRatio then
							item.density = densityRatio
							v9.Clouds.Density = densityRatio
						end

						item.color = item.color
					end
				end
			end

			debug.profileend()
		elseif environment and (v7 or v6) then
			debug.profilebegin("EnvironmentController:withinIsland_withinSea")
			local bounds = environment.region.bounds
			local intensityForWeather = environment:GetIntensityForWeather({
				RadiusType = environment.region.radiusType,
				Bounds = NumberRange.new(bounds.Min * 0.5, bounds.Max * 0.5)
			}, v3)
			debug.profileend()
			debug.profilebegin("EnvironmentController:Update:Calculate")
			local weatherSettings = {}

			for _, v8 in pairs(EnvironmentUtil.WithinZonesByGroup.Island) do
				local environment2 = EnvironmentUtil.Environments[v8]

				if not environment2 then
					continue
				end

				local weather = environment2.weather

				for k, v9 in pairs(weather) do
					weatherSettings[k] = v9.weatherSettings
				end
			end

			for k, item in pairs(items) do
				local v8 = {}

				for k2, v9 in pairs(WeatherData.properties[k]) do
					if weatherSettings[k] then
						v9 = weatherSettings[k][k2] or v9
					end

					v8[k2] = v9
				end

				item.numOfType = 1

				for k2, v9 in v8 do
					local lower = k2:lower()

					if typeof(v9) == "number" then
						local v10 = item[lower]

						if v10 then
							local v11 = v9 * intensityForWeather + (v10 - v9) * (1 - intensityForWeather)

							if item[lower] or lower == "color" then
								item[lower] = v11
							end
						end
					elseif typeof(v9) == "Color3" then
						item[lower] = item[lower]:lerp(v9, intensityForWeather)
					end
				end
			end

			debug.profileend()
		end
	end

	v4 = items
end

local v5 = nil
local EnvironmentController = {
	Mute = function(_, flag: boolean)
		if v5 then
			v5:Cancel()
			v5 = nil
		end

		local TweenService = game:GetService("TweenService")
		local tween = TweenService:Create(EnvironmentUtil.Soundgroup, TweenInfo.new(1), {
			Volume = flag and 0 or 1
		})
		tween:Play()
		v5 = tween
	end
}
local v6 = nil

function notify(p: string?)
	if not (Flags.ENVIRONMENT_MUSIC_ENABLED ~= false and v6 ~= p) then
		return
	end

	if p then
		v.new(string.format("<%s>", p), nil, true):Display()
	end

	v6 = p
end

function EnvironmentController.OnStart(_)
	local Notification = require(game.ReplicatedStorage.Notification)
	v = Notification
	local locations = workspace:WaitForChild("_WorldOrigin"):WaitForChild("Locations")

	for _, part in pairs(locations:GetChildren()) do
		if part:IsA("BasePart") then
			part.Transparency = 1
		else
			warn("part is not a base part.. what", part)
		end
	end

	EnvironmentUtil.playClosestSound()

	for _, tag in pairs({ "ClientEnvironment" }) do
		CollectionService:GetInstanceAddedSignal(tag):Connect(function(p)
			addEnvironment(p)
		end)
		CollectionService:GetInstanceRemovedSignal(tag):Connect(function(instance)
			local environment = EnvironmentUtil.Environments[instance:GetAttribute("UID")]

			if environment then
				environment:_Destroy()
			end
		end)
		local tagged = CollectionService:GetTagged(tag)

		for _, v7 in ipairs(tagged) do
			task.spawn(addEnvironment, v7)
		end
	end

	local v7 = false
	v2, v3 = Tracking:WaitForTrackerAsync(localPlayer):await()
	assert(v3, "bad tracker")
	local v8 = nil
	SimpleZone:BindToUpdate(function()
		local root = v3:getRoot()

		if not root then
			return
		end

		local position = root.Position

		if not v8 then
			v8 = position
		end

		local magnitude = (position - v8).Magnitude
		v8 = position

		if magnitude >= 1000 then
			EnvironmentUtil.Teleported = true
		end

		local v9 = {}

		for k, environment in pairs(EnvironmentUtil.Environments) do
			local cf = environment.region.cf
			local radius = environment.region.radius
			local infinite = environment.region.infinite
			local _zone = environment._zone
			local v10 = _zone and _zone:DistanceFromOrigin(localPlayer)
			local v11 = createVector(1, 0, 1) * cf.Position
			local withY = v10 and v10.withY or v3:distanceFromPosition(cf)
			local withoutY = v10 and v10.withoutY or v3:distanceFromPosition(v11, createVector(1, 0, 1))
			local default = v10 and v10.default or v3:distanceFromPosition(
				cf.Position * environment.region.radiusType,
				environment.region.radiusType
			)
			local v12, v13

			if infinite then
				v12 = true
				v13 = true
			else
				v13 = _zone and _zone:FindPlayer(localPlayer) or default <= radius * 0.5
				v12 = v13 or default <= environment._maxRenderDistance
			end

			environment.distanceFromOrigin = {
				default = default,
				withY = withY,
				withoutY = withoutY
			}

			if EnvironmentUtil.Teleported then
				environment._lastLoadedFrames = 2
			end

			if v12 then
				if not environment._listening then
					if v13 or environment._lastLoadedFrames >= 2 then
						environment._lastLoadedFrames = 0
						environment:_Listen()
					else
						environment._lastLoadedFrames += 1
					end
				end
			elseif not v12 and environment._listening then
				if environment._lastLoadedFrames >= 2 then
					environment._lastLoadedFrames = 0
					environment:_Ignore()
				else
					environment._lastLoadedFrames += 1
				end
			end

			if v13 and environment._listening then
				table.insert(v9, k)
			end
		end

		local v10 = 1e999
		local v11 = {}
		local closestEnvironment = nil
		local v13 = false
		local v14 = false

		for _, v15 in pairs(v9) do
			local environment = EnvironmentUtil.Environments[v15]

			if not (environment and (v7 or environment.configuration.group == "Island")) then
				continue
			end

			local group = environment.configuration.group
			local withY = environment.distanceFromOrigin.withY

			if group ~= "Sea" and withY < v10 then
				v13 = false
				v14 = false

				if Flags.ENVIRONMENT_MUSIC_ENABLED and (environment.sound or environment.notification) then
					local v16 = environment.sound and environment.sound.radius * 0.5
					local v17 = environment.notification and environment.notification.radius * 0.5
					v14 = v17 and withY <= v17 and true or false
					v13 = v16 and withY <= v16 and true or false

					if v13 or v14 then
						closestEnvironment = environment
						v10 = withY
					end
				elseif withY <= environment.region.bounds.Max * 0.5 then
					closestEnvironment = environment
					v10 = withY
				end
			end

			if EnvironmentUtil.Teleported then
				continue
			end

			debug.profilebegin("EnvironmentController:CalculateOnScreenFX")

			for k, v16 in pairs(environment.weather) do
				if not WeatherData.cameraEffects[k] then
					continue
				end

				local intensityForWeather = environment:GetIntensityForWeather(v16.weatherSettings, v3)

				if not (WeatherUtil.components[k] and WeatherUtil.components[k]._enabled ~= false or intensityForWeather ~= 0) then
					continue
				end

				if not v11[k] then
					v11[k] = {
						environments = {},
						numOfType = 0,
						intensity = 0,
						cover = 0,
						density = 0,
						color = nil
					}
				end

				local color = v16.weatherSettings.Color or nil
				local intensity = v16.weatherSettings.Intensity or 0
				local cover = v16.weatherSettings.Cover or 0
				local density = v16.weatherSettings.Density or 0
				local intensityRatio = intensityForWeather * intensity
				local coverRatio = intensityForWeather * cover
				local densityRatio = intensityForWeather * density

				if v16.name == "Clouds" then
					intensity = (coverRatio + densityRatio) / 2
					intensityRatio = intensity
				end

				local v20 = assert(v11[k], (`bad blend at "{k}"`))
				v20.intensity += intensityRatio
				v20.cover += coverRatio
				v20.density += densityRatio
				v20.color = color
				v20.numOfType += 1
				v20.environments[v15] = {
					colorRaw = color,
					intensityRaw = intensity,
					coverRaw = cover,
					densityRaw = density,
					intensityRatio = intensityRatio,
					coverRatio = coverRatio,
					densityRatio = densityRatio
				}
			end

			debug.profileend()
		end

		local v15, name

		if closestEnvironment then
			v7 = true
			v15 = {
				uid = closestEnvironment.configuration.uid,
				group = closestEnvironment.configuration.group,
				name = closestEnvironment.configuration.name,
				radius = closestEnvironment.region.radius
			}

			if closestEnvironment.notification then
				name = closestEnvironment.notification.name or nil
			end
		else
			v13 = true
			v15 = {
				uid = "Sea",
				group = "Sea",
				name = "Sea",
				radius = 1e999
			}
			v14 = true
			name = "Sea"
		end

		if v13 and v15 then
			EnvironmentUtil.playClosestSound(v15)
		end

		if v14 and name then
			notify(name)
		end

		EnvironmentUtil.ClosestEnvironment = closestEnvironment
		updateCameraEnvironment(v11)
		return nil
	end)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	local tweenInfo2 = TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local v9 = false
	local RunService = game:GetService("RunService")
	RunService.Heartbeat:Connect(function(_)
		if not (v3 and v3.Humanoid) then
			EnvironmentUtil.Teleported = true
		elseif EnvironmentUtil.Teleported then
			EnvironmentUtil.Teleported = nil
			v9 = true

			if v3.Humanoid then
				SimpleZone:_Update()
			end
		else
			for k, component in pairs(WeatherUtil.components) do
				if not WeatherData.cameraEffects[k] then
					continue
				end

				local v10 = v4[k]

				if v10 then
					debug.profilebegin("EnvironmentController:Blend:" .. k)
					local numOfType = v10.numOfType
					local intensity = math.clamp(v10.intensity / numOfType, 0, 1)

					if intensity <= 0.09 then
						if component._enabled then
							component:Disable(v9 and TweenInfo.new(1.5) or tweenInfo2)
						end
					else
						if not component._enabled then
							component:Enable()
						end

						if component._enabled and os.clock() - component.lastUpdate > 1 then
							if component.subtype == "Precipitation" then
								component:SetIntensity({
									Intensity = intensity,
									Color = v10.color
								}, tweenInfo)
							elseif k == "Clouds" then
								component:SetIntensity({
									Intensity = intensity,
									Cover = math.clamp(v10.cover / numOfType, 0, 1),
									Density = math.clamp(v10.density / numOfType, 0, 1),
									Color = v10.color
								}, tweenInfo)
							end
						end
					end

					debug.profileend()
				elseif component._enabled then
					component:Disable(tweenInfo2)
				end
			end

			v9 = false
		end
	end)
end

return EnvironmentController