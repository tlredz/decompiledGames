local createVector = vector.create
local Environment = {}
Environment.__index = Environment
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local Signal = require(game.ReplicatedStorage.Modules.Util.Signal)
local SimpleZone = require(game.ReplicatedStorage.Modules.SimpleZone)
local Part = require(game.ReplicatedStorage.Modules.Debug.Part)
local WeatherData = require(game.ReplicatedStorage.Modules.Weather.WeatherData)
require(game.ReplicatedStorage.Controllers.WeatherController.Types)
require(script.Parent.Types)
local EnvironmentUtil = require(script.Parent.EnvironmentUtil)
local EnvironmentUtilShared = require(game.ReplicatedStorage.Modules.Weather.EnvironmentUtilShared)
local MIN_RENDER_DISTANCE = EnvironmentUtilShared.MIN_RENDER_DISTANCE
local DEBUG_RENDER_DISTANCE = EnvironmentUtilShared.DEBUG_RENDER_DISTANCE
local DEBUG_WEATHER_REGION = EnvironmentUtilShared.DEBUG_WEATHER_REGION
local DEBUG_BOUNDS = EnvironmentUtilShared.DEBUG_BOUNDS

function Environment.new(instance)
	local attributes = instance:GetAttributes()
	local region = {
		cf = attributes.CFrame,
		radius = attributes.Radius,
		bounds = attributes.Bounds,
		infinite = attributes.Infinite == true,
		radiusType = attributes.RadiusType
	}
	local maxRenderDistance = region.infinite and 1e999 or region.radius * 0.5 + MIN_RENDER_DISTANCE

	if DEBUG_RENDER_DISTANCE and typeof(DEBUG_RENDER_DISTANCE) == "number" then
		maxRenderDistance = DEBUG_RENDER_DISTANCE
	end

	local configuration = {
		timeIn = instance:GetAttribute("TimeIn"),
		group = instance:GetAttribute("Group"),
		uid = instance:GetAttribute("UID"),
		name = instance:GetAttribute("Name"),
		component = instance:GetAttribute("Component")
	}
	local destroyedSignal = Signal.new()
	local v6 = {
		obj = instance,
		region = region,
		weather = {},
		configuration = configuration,
		distanceFromOrigin = {
			default = 1e999,
			withY = 1e999,
			withoutY = 1e999
		},
		_maid = Trove.new(),
		_listening = false,
		_destroyed = false,
		_maxRenderDistance = maxRenderDistance,
		_destroyedSignal = destroyedSignal,
		_lastLoadedFrames = 1e999,
		_debuggerUpdates = {}
	}
	local cFrameChangedConnection = instance:GetAttributeChangedSignal("CFrame"):Connect(function()
		local cFrame = instance:GetAttribute("CFrame")
		v6.region.cf = cFrame

		if v6._zone then
			v6._zone.region.cf = cFrame
		end

		for _, _debuggerUpdate in pairs(v6._debuggerUpdates) do
			_debuggerUpdate()
		end
	end)
	v6._maid:Add(function()
		if v6._destroyed then
			cFrameChangedConnection:Disconnect()
		end
	end)
	return (setmetatable(v6, Environment))
end

function Environment:_Ignore()
	if not self._listening then
		return
	end

	self._listening = false
	self._maid:Clean()

	if self._zone then
		self._zone:Destroy()
		self._zone = nil
	end

	for k, _ in pairs(self.weather) do
		local v = k
		local success, result = pcall(function()
			self.weather[v]:Destroy()
		end)
		self.weather[k] = nil

		if not success then
			warn(result)
		end
	end

	if self.sound and self.sound.sounds then
		table.clear(self.sound.sounds)
	end

	self.sound = nil
	return nil
end

function Environment:_Listen()
	if self._listening then
		return
	end

	self._listening = true
	local zone = SimpleZone.new(self.region, "Environment", self.configuration.timeIn)
	self._zone = zone
	zone:Enable()
	self._maid:Add(function()
		table.clear(self._debuggerUpdates)
	end)

	local function weatherAdded(instance)
		if self.weather[instance.Name] then
			return
		end

		local attributes = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateSettings()
			attributes = instance:GetAttributes()
			local uid = self.configuration.uid
			local name = attributes.Name
			attributes.UID = uid .. name
			return attributes
		end

		attributes = instance:GetAttributes()
		attributes.UID = self.configuration.uid .. attributes.Name
		local v2 = nil

		if WeatherData.cameraEffects[attributes.Name] then
			v2 = {
				name = attributes.Name,
				weatherSettings = attributes,
				_enabled = false,
				_destroyed = false,
				Destroy = function(self)
					self._enabled = false
					self._destroyed = true
					return nil
				end
			}
			local updateChangedConnection = instance:GetAttributeChangedSignal("Update"):Connect(function()
				v2.weatherSettings = updateSettings()
			end)
			self._maid:Add(updateChangedConnection)
		elseif attributes.Name == "Lightning" then
			local LightningComponent = require(game.ReplicatedStorage.Controllers.WeatherController.Weather.Components.LightningComponent)
			v2 = LightningComponent.new(attributes)
			self._maid:Add(instance.ChildAdded:Connect(function(child)
				task.wait()
				v2.new(child)
				task.defer(function()
					if child.Parent then
						child:Destroy()
					end
				end)
			end))
			v2:Enable()
		elseif attributes.Name == "Tornado" then
			local TornadoComponent = require(game.ReplicatedStorage.Controllers.WeatherController.Weather.Components.TornadoComponent)
			v2 = TornadoComponent.new(attributes)

			local function tornadoAdded(p)
				if not p.Parent then
					return
				end

				local v3 = v2.new(p)

				if not v3 then
					return
				end

				v3:Spawn(0.5, workspace.SeaEvents)
			end

			self._maid:Add(instance.ChildAdded:Connect(tornadoAdded))

			for _, child in pairs(instance:GetChildren()) do
				task.spawn(tornadoAdded, child)
			end

			v2:Enable()
		else
			warn((`physicalWeather not found: {attributes.Name}`))
		end

		if v2 then
			if DEBUG_WEATHER_REGION then
				for _, v3 in pairs({ "Min", "Max" }) do
					local v4 = v2.weatherSettings.Bounds[v3] * 2
					local part = Part("SimpleZone_WeatherBoundary")
					part.Transparency = 0.95
					part.BrickColor = BrickColor.Red()
					part.Name = self.configuration.uid .. instance.Name
					local specialMesh = Instance.new("SpecialMesh", part)
					specialMesh.MeshType = Enum.MeshType.Sphere
					specialMesh.Scale = Vector3.new(v4, v4, v4)

					-- equivalent calls inferred from this helper; original call sites unknown
					local function fn()
						part.CFrame = self.region.cf
					end

					table.insert(self._debuggerUpdates, fn)
					fn() -- equivalent call inferred; original call site unknown
					self._maid:Add(part)
				end
			end

			self.weather[instance.Name] = v2
		end
	end

	local function weatherRemoved(p)
		local v2 = self.weather[p.Name]

		if v2 then
			v2:Destroy()
		end

		self.weather[p.Name] = nil
	end

	local function initSound()
		local sound = nil
		local sounds = self.obj:FindFirstChild("Sounds")

		if sounds then
			local children = sounds:GetChildren()
			sound = #children > 0 and {
				reverb = sounds:GetAttribute("AmbientReverb"),
				radius = sounds:GetAttribute("Radius"),
				sounds = children
			} or sound
		end

		self.sound = sound
	end

	local function initNotif()
		local notification = self.obj:FindFirstChild("Notification")

		if notification then
			self.notification = {
				name = notification:GetAttribute("Name"),
				radius = notification:GetAttribute("Radius")
			}
		end
	end

	initSound()
	initNotif()
	local weather = self.obj:FindFirstChild("Weather")

	if weather then
		local _maid = self._maid
		_maid:Add(weather.ChildAdded:Connect(weatherAdded))
		_maid:Add(weather.ChildRemoved:Connect(weatherRemoved))

		for _, child in pairs(weather:GetChildren()) do
			task.spawn(weatherAdded, child)
		end
	end

	zone:Connect("localPlayerEntered", function()
		if self._destroyed then
			return
		else
			return EnvironmentUtil.localPlayerEnteredEnvironment(self)
		end
	end)
	zone:Connect("localPlayerExited", function()
		return EnvironmentUtil.localPlayerExitedEnvironment(self)
	end)

	if not DEBUG_BOUNDS then
		return nil
	end

	for i = 1, 2 do
		local min = i == 1 and self.region.bounds.Min or self.region.bounds.Max
		local uid = self.configuration.uid
		local part = Part("SimpleZone_RegionBounds")
		part.BrickColor = BrickColor.Blue()
		part.Transparency = 0.95
		part.Name = uid .. "Bounds_" .. (i == 1 and "MIN" or "MAX")
		local specialMesh = Instance.new("SpecialMesh", part)
		specialMesh.MeshType = Enum.MeshType.Sphere
		specialMesh.Scale = Vector3.new(min, min, min)
		table.insert(self._debuggerUpdates, function()
			part.CFrame = self.region.cf
		end)
		part.CFrame = self.region.cf
		self._maid:Add(part)
	end

	return nil
end

function Environment.GetIntensityForWeather(p, data, object)
	local min = data.Bounds.Min
	local max = data.Bounds.Max
	local inverse = data.Inverse
	local withoutY = p.distanceFromOrigin.withoutY

	if data.RadiusType and data.RadiusType ~= createVector(1, 0, 1) then
		if data.RadiusType == createVector(1, 1, 1) then
			withoutY = p.distanceFromOrigin.withY
		else
			withoutY = not object and 1e999 or object:distanceFromPosition(
				p.region.cf.Position * data.RadiusType,
				data.RadiusType
			)
		end
	end

	local v = (math.clamp(withoutY, min, max) - min) / (max - min)
	local v2 = inverse and v or 1 - v

	if inverse and withoutY < min then
		return -v2
	end

	return v2
end

function Environment:Destroyed(callback)
	return assert(self._destroyedSignal):Connect(callback)
end

function Environment:_Destroy()
	self._destroyed = true
	self:_Ignore()
	self._maid:Destroy()

	if self._destroyedSignal then
		self._destroyedSignal:Fire()
		self._destroyedSignal:Destroy()
	end

	self._destroyedSignal = nil
	self._maid = nil
end

return Environment