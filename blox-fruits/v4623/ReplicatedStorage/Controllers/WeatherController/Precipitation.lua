local createVector = vector.create
local WeatherData = require(game.ReplicatedStorage.Modules.Weather.WeatherData)
local Config = require(game.ReplicatedStorage.Modules.World.Config)
local Raycast = require(game.ReplicatedStorage.Modules.World.Raycast)
local WeatherUtil = require(game.ReplicatedStorage.Controllers.WeatherController.WeatherUtil)
require(game.ReplicatedStorage.Controllers.WeatherController.Types)
local Tracking = require(game.ReplicatedStorage.Modules.Tracking)
local random = Random.new()
local v = nil
task.spawn(function()
	local FPSTracker = require(game.ReplicatedStorage.Util.FPSTracker)
	v = FPSTracker
end)
local RunService = game:GetService("RunService")
local v2 = RunService and false
local TweenService = game:GetService("TweenService")
local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = {
	workspace:WaitForChild("Characters"),
	workspace:WaitForChild("Enemies"),
	workspace:WaitForChild("_WorldOrigin")
}
local Precipitation = {}
Precipitation.__index = Precipitation
local v3 = {}

for _, v4 in pairs(require(script._VolumeScanGrid)) do
	table.insert(v3, v4 * 100)
end

table.sort(v3, function(a: Vector3, b: Vector3)
	return a.Magnitude < b.Magnitude
end)
local v4 = nil
v4 = {
	lookVector = function()
		return workspace.CurrentCamera.CFrame.LookVector
	end,
	right = function(vector2: Vector3)
		local cross = v4.cross(vector2)
		return cross.Magnitude > 0.001 and cross.Unit or -vector2
	end,
	cross = function(vector2: Vector3)
		return v4.lookVector():Cross(-vector2)
	end,
	forward = function(vector2: Vector3, vector3: Vector3)
		return vector2:Cross(vector3).Unit
	end,
	dot = function(vector2: Vector3)
		return v4.lookVector():Dot(vector2)
	end,
	transform = function(vector2: Vector3)
		local position = workspace.CurrentCamera.CFrame.Position
		local right = v4.right(vector2)
		local forward = v4.forward(vector2, right)
		return (CFrame.new(
			position.X,
			position.Y,
			position.Z,
			right.X,
			-vector2.X,
			forward.X,
			right.Y,
			-vector2.Y,
			forward.Y,
			right.Z,
			-vector2.Z,
			forward.Z
		))
	end
}

local function makeProperty(state, p, onChanged)
	if p then
		state.Value = p
	end

	state.Changed:Connect(onChanged)
	state.Parent = script
	onChanged(state.Value)
	return state
end

function Precipitation:PrecipRayCast(position: Vector3, vector2: Vector3, filter)
	local raycastParams2 = RaycastParams.new()
	raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams2.FilterDescendantsInstances = self.ignoreEmitterList
	raycastParams2:AddToFilter(workspace.Characters)
	raycastParams2:AddToFilter(workspace._WorldOrigin)
	return Raycast({
		filter = filter,
		origin = CFrame.new(position),
		direction = vector2,
		raycastParams = raycastParams2,
		visualize = v2 and {}
	})
end

function Precipitation:SetColor(color, p2)
	if self.color == color then
		return
	end

	self.color = color

	if p2 then
		TweenService:Create(self._colorValue, p2, {
			Value = color
		}):Play()
	else
		self._colorValue.Value = color
	end
end

function Precipitation:SetDirection(vector2: Vector3, p2)
	local direction = not (vector2.Unit.Magnitude > 0) and createVector(0, -1, 0) or vector2
	self.direction = direction

	if p2 then
		TweenService:Create(self._directionValue, p2, {
			Value = direction
		}):Play()
	else
		self._directionValue.Value = direction
	end
end

function Precipitation.IsRunning(p)
	return p.running == true
end

function Precipitation:_RenderStepped(_: number)
	local cFrame = workspace.CurrentCamera.CFrame
	local config = self.config
	local straight = self.emitter:FindFirstChild("Straight")
	local inside = WeatherUtil.precipitationState:Get("Inside")

	if inside then
		if straight then
			straight.Enabled = false
		end

		local FADE_INSIDE_CHECK = config.FADE_INSIDE_CHECK or 0

		if self.cameraFocus then
			if FADE_INSIDE_CHECK <= tick() - WeatherUtil.precipitationState:Get("TimeWentInside") then
				for _, v5 in pairs(self.cameraFocus) do
					v5[1].CFrame = CFrame.new(0, -10000, 0)
				end
			elseif self.wasDisabled then
				for _, v5 in pairs(self.cameraFocus) do
					v5[1].CFrame = v5[2](cFrame)
				end
			else
				self.wasDisabled = true

				for _, v5 in pairs(self.cameraFocus) do
					for _, emitter in pairs(v5[1]:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter:SetAttribute("WasEnabled", emitter.Enabled)
						emitter.Enabled = false
					end
				end
			end
		end
	else
		if self.volumeTarget ~= self.currentIntensity and not self.disabled then
			self.volumeTarget = self.currentIntensity
			TweenService:Create(self.sound, TweenInfo.new(0.5), {
				Volume = self.currentIntensity * config.MAX_VOLUME
			}):Play()
		end

		if straight then
			local v5 = math.abs((v4.dot(self.direction)))
			self.emitter.Size = Vector3.new(
				config.EMITTER_DIM_DEFAULT,
				config.EMITTER_DIM_DEFAULT,
				config.EMITTER_DIM_DEFAULT + (1 - v5) * (config.EMITTER_DIM_MAXFORWARD - config.EMITTER_DIM_DEFAULT)
			)
			local transformed = v4.transform(self.direction)
			self.emitter.CFrame = transformed + (1 - v5) * cFrame.lookVector * self.emitter.Size.Z / 3 - v5 * self.direction * config.EMITTER_UP_MODIFIER

			if self.specialEffect and math.random() < self.currentIntensity * 0.2 then
				self.specialEffect(self.emitter.CFrame, self.emitter.Size, self.emitter.Straight.Speed)
			end

			self.emitter.Straight.Enabled = true
		end

		if self.cameraFocus then
			if self.wasDisabled then
				self.wasDisabled = false

				for _, v5 in pairs(self.cameraFocus) do
					for _, emitter in pairs(v5[1]:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = emitter:GetAttribute("WasEnabled")
						end
					end
				end
			end

			for _, v5 in pairs(self.cameraFocus) do
				v5[1].CFrame = v5[2](cFrame)
			end
		end
	end

	if self.walkEffect then
		local tracker = Tracking:GetTracker(game.Players.LocalPlayer)

		if not (tracker and tracker.Character) then
			return
		end

		local humanoid = tracker.Humanoid

		if not humanoid then
			return
		end

		local primaryPart = tracker.PrimaryPart

		if not primaryPart then
			return
		end

		local moveDirection = humanoid.MoveDirection

		if inside or moveDirection.Magnitude < 0.1 or humanoid.Sit then
			if self.__walkEffectOn then
				self.__walkEffectOn = nil

				for _, emitter in pairs(self.walkEffect:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end
		else
			local v5 = math.min(3.5, primaryPart.Size.Y * 0.5 + humanoid.HipHeight) + 0.5
			local raycastResult = workspace:Raycast(primaryPart.Position, createVector(0, 1, 0) * -v5, raycastParams)

			if raycastResult then
				self.walkEffect.Position = raycastResult.Position

				if not self.__walkEffectOn then
					self.__walkEffectOn = true

					for _, emitter in pairs(self.walkEffect:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end
				end
			elseif self.__walkEffectOn then
				self.__walkEffectOn = nil

				for _, emitter in pairs(self.walkEffect:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end
		end
	end
end

function Precipitation:_Stepped()
	self.frame += 1
	local config = self.config
	local inside = WeatherUtil.precipitationState:Get("Inside")
	local transformed = v4.transform(self.direction)

	if self.frame >= config.UPDATE_PERIOD then
		self.frame = 0

		if inside and not self.disabled then
			local ceiling = WeatherUtil.precipitationState:Get("Ceiling")
			local v5

			if ceiling and not (workspace.CurrentCamera.CFrame.p.y <= ceiling) then
				v5 = 0
			else
				local v6 = -self.direction * (self.SCAN_HEIGHT + transformed.Y + 1)
				local magnitude = 100

				for i = 1, #v3 do
					if self:PrecipRayCast(workspace.CurrentCamera.CFrame * v3[i], v6) then
						continue
					end

					magnitude = v3[i].Magnitude
					break
				end

				v5 = 1 - magnitude / 100
			end

			if math.abs(v5 - self.volumeTarget) > 0.01 then
				self.volumeTarget = math.min(math.clamp(v5, 0, config.MAX_VOLUME), self.currentIntensity)
				TweenService:Create(self.sound, TweenInfo.new(1), {
					Volume = self.volumeTarget * config.MAX_VOLUME
				}):Play()
			end
		end

		if v and self.numSplashes > 0 and v.FPS >= config.MIN_SPLASH_FPS and self.splashAttachments then
			local v5 = self.direction * (self.SCAN_HEIGHT + transformed.Y + 1)

			for i = 1, not inside and 1 or self.numSplashes or 1 do
				local splashAttachment = self.splashAttachments[i]

				if not splashAttachment then
					break
				end

				local occludedAttachment = self.occludedAttachments[i]
				local number = random:NextNumber(config.OCCLUDECHECK_OFFSET_XZ_MIN, config.OCCLUDECHECK_OFFSET_XZ_MAX)
				local number2 = random:NextNumber(config.OCCLUDECHECK_OFFSET_XZ_MIN, config.OCCLUDECHECK_OFFSET_XZ_MAX)
				local precipRayCast = self:PrecipRayCast(
					transformed * Vector3.new(number, self.SCAN_HEIGHT, number2),
					v5
				)
				local position = precipRayCast and precipRayCast.Position
				local normal = precipRayCast and precipRayCast.Normal
				local v6

				if position and normal then
					v6 = position - self.direction * config.SPLASH_OFFSET_Y
					splashAttachment.Position = Vector3.new(
						position.X,
						math.max(Config.SEA_ORIGIN.Y, position.Y),
						position.Z
					) + normal * 0.01
				else
					v6 = transformed * Vector3.new(number, 0, number2)
					splashAttachment.Position = Vector3.new(v6.X, Config.SEA_ORIGIN.Y + 0.01, v6.Z)
				end

				for _, child in pairs(splashAttachment:GetChildren()) do
					child:Emit(child:GetAttribute("EmitCount"))
				end

				if not (inside and occludedAttachment) then
					continue
				end

				occludedAttachment.CFrame = transformed - transformed.Position + v6
				occludedAttachment.Occluded:Emit(1)
			end
		end
	end
end

function Precipitation:_SetIntensity(value: number, p)
	local v5 = math.clamp(value, 0, 1)
	self.goalIntensity = v5
	self.timeDisabled = nil

	if p then
		local attempt

		attempt = function()
			if self.intensityTween and v5 ~= 0 and (self.lastIntensity ~= 0 or v5 == 0) then
				self.lastIntensity = v5
				return false
			end

			if self.currentIntensity == v5 then
				return false
			end

			if v5 == 0 then
				self.disabled = true
			else
				self.disabled = false
			end

			if self.intensityTween then
				self.intensityTween:Cancel()
				self.intensityTween = nil
			end

			local tween = TweenService:Create(self._intensityValue, p, {
				Value = v5
			})
			self.intensityTween = tween
			tween:Play()
			tween.Completed:Connect(function(p2)
				self.intensityTween = nil

				if p2 == Enum.PlaybackState.Completed and v5 ~= self.currentIntensity then
					attempt()
				end
			end)
			return true
		end

		return (attempt())
	end

	self._intensityValue.Value = v5
	self.currentIntensity = v5
	return true
end

function Precipitation:_Disable(p)
	local lastTime = os.time()
	self.timeDisabled = lastTime
	task.spawn(function()
		while lastTime == self.timeDisabled do
			if os.time() - lastTime >= 0.2 and lastTime == self.timeDisabled then
				self:_SetIntensity(0, p)
				break
			else
				task.wait()
			end
		end
	end)
end

function Precipitation:_Init()
	local emitter = self.emitter
	local config = self.config
	local numberValue = Instance.new("NumberValue")

	local function onChanged(currentIntensity: number)
		if self.__firstRun == false and currentIntensity <= 0 then
			return
		end

		if self.__firstRun == false then
			self.__firstRun = true

			for _, callback in pairs(self.prepareEffects) do
				task.spawn(callback)
			end
		end

		local straight = emitter:FindFirstChild("Straight")

		if not self.running then
			self.running = true

			if straight then
				straight.Enabled = true
			end

			if not self.sound.IsPlaying then
				self.sound:Play()
			end

			if self.colorCorrection then
				self.colorCorrection.Enabled = true
			end
		end

		if straight then
			straight.Rate = config.STRAIGHT_MAX_RATE * currentIntensity
			straight.Speed = NumberRange.new((math.max(
				currentIntensity * config.STRAIGHT_MIN_SPEED,
				currentIntensity * config.STRAIGHT_MAX_SPEED
			)))
		end

		if self.cameraFocus then
			for _, v5 in pairs(self.cameraFocus) do
				for _, child in pairs(v5[1]:GetChildren()) do
					child.Enabled = true
					child.Rate = child:GetAttribute("OriginalRate") * currentIntensity
					child.Speed = NumberRange.new(
						child:GetAttribute("OriginalSpeedMin") * currentIntensity,
						child:GetAttribute("OriginalSpeedMax") * currentIntensity
					)
				end
			end
		end

		if straight then
			for _, occludedAttachment in pairs(self.occludedAttachments) do
				occludedAttachment.Occluded.Speed = straight.Speed
				occludedAttachment.Occluded.SpreadAngle = straight.SpreadAngle
			end
		end

		self.numSplashes = math.ceil(config.OCCLUDED_SPLASH_NUM * currentIntensity)
		self.sound.Volume = config.MAX_VOLUME * currentIntensity
		self.currentIntensity = currentIntensity

		if self.colorCorrection then
			self.colorCorrection.TintColor = Color3.new(1, 1, 1):Lerp(
				self.colorCorrection:GetAttribute("ActiveColor"),
				currentIntensity
			)
		end

		if self.currentIntensity == 0 then
			if self.goalIntensity == 0 then
				self.running = false
				self.disabled = true

				if straight then
					straight.Enabled = false
					emitter.Size = createVector(0, 0, 0)
				end

				if self.__walkEffectOn then
					self.__walkEffectOn = nil

					if self.walkEffect then
						for _, emitter2 in pairs(self.walkEffect:GetDescendants()) do
							if emitter2:IsA("ParticleEmitter") then
								emitter2.Enabled = false
							end
						end
					end
				end
			end

			if self.cameraFocus then
				for _, v5 in pairs(self.cameraFocus) do
					v5[1].CFrame = CFrame.new(0, -10000, 0)

					for _, child in pairs(v5[1]:GetChildren()) do
						child.Enabled = false
					end
				end
			end

			if self.colorCorrection then
				self.colorCorrection.Enabled = false
			end
		end
	end

	numberValue.Value = 0
	numberValue.Changed:Connect(onChanged)
	numberValue.Parent = script
	onChanged(numberValue.Value)
	self._intensityValue = numberValue
	local color3Value = Instance.new("Color3Value")
	local color = self.color

	local function onChanged2(_) end

	if color then
		color3Value.Value = color
	end

	color3Value.Changed:Connect(onChanged2)
	color3Value.Parent = script
	local _ = color3Value.Value
	self._colorValue = color3Value
	local vector3Value = Instance.new("Vector3Value")
	local direction = self.direction

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onChanged3(value)
		if value.Magnitude > 0.001 then
			self.direction = value.Unit
		end
	end

	if direction then
		vector3Value.Value = direction
	end

	vector3Value.Changed:Connect(onChanged3)
	vector3Value.Parent = script
	onChanged3(vector3Value.Value) -- equivalent call inferred; original call site unknown
	self._directionValue = vector3Value
	return self
end

function Precipitation.new(name: string, config)
	if WeatherUtil.precipitationTypes[name] then
		print((`Return created singlerton: {name}`))
		return WeatherUtil.precipitationTypes[name]
	end

	local clone = script.Emitter:Clone()
	clone.Name = name .. "EmitterPart"
	clone.Parent = workspace._WorldOrigin
	return (setmetatable({
		SCAN_HEIGHT = WeatherUtil.SCAN_HEIGHT,
		name = name,
		emitter = clone,
		ignoreEmitterList = { clone },
		occludedAttachments = {},
		running = false,
		disabled = false,
		config = config,
		frame = 0,
		direction = createVector(0, -1, 0),
		color = WeatherData.properties[name].Color,
		numSplashes = 0,
		volumeTarget = 0,
		currentIntensity = 0,
		lastIntensity = 0,
		goalIntensity = 0,
		prepareEffects = {},
		__walkEffectOn = nil,
		__firstRun = false
	}, Precipitation))
end

return Precipitation