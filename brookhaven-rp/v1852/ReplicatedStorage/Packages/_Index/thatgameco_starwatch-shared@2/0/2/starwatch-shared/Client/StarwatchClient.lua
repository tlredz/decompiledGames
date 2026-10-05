local createVector = vector.create
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalizationService = game:GetService("LocalizationService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local shared = script.Parent.Parent:WaitForChild("Shared")
local SafeCall = require(shared:WaitForChild("SafeCall"))
local Platform = require(shared:WaitForChild("Enums").Platform)
local HashUtils = require(shared:WaitForChild("HashUtils"))
local starwatchClientEventIngestor = shared:WaitForChild("StarwatchClientEventIngestor")
local StarwatchDefaultInstrumentation = require(script.Parent.StarwatchDefaultInstrumentation)
require(shared:WaitForChild("Enums").DefaultEvents)
require(shared:WaitForChild("Enums").DefaultGauges)
local StarwatchClient = {}
local localPlayer = nil
local v = {}
local v2 = {}
local chatEvents = {}
local v3 = {}
local v4 = {}
local flag = false
local userId = ""
local starwatchSessionId = ""
local ANDROID = Platform.ANDROID
local countryCode = "US"
local robloxLocaleId = "en"
local heartbeatConnection = nil
local v8 = nil

local function defaultLevel()
	return game.PlaceId ~= 0 and tostring(game.PlaceId) or "prepublished_dev_placeid"
end

local function defaultPlatform()
	if UserInputService.GamepadEnabled then
		if not GuiService:IsTenFootInterface() then
			return Platform.CONSOLE_UNKNOWN
		end

		local stringForKeyCode = UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonA)

		if stringForKeyCode == "ButtonA" then
			return Platform.XBOX
		elseif stringForKeyCode == "ButtonCross" then
			return Platform.PS5
		end

		return Platform.CONSOLE_UNKNOWN
	else
		if not UserInputService.TouchEnabled or UserInputService.MouseEnabled then
			return Platform.WIN
		end

		if not (UserInputService.AccelerometerEnabled or UserInputService.GyroscopeEnabled) then
			return Platform.MOBILE_UNKNOWN
		end

		local deviceGravity = UserInputService:GetDeviceGravity()

		if deviceGravity.Position == createVector(0, 0, 0) then
			deviceGravity = UserInputService.DeviceGravityChanged:Wait()
		end

		if deviceGravity.Position.Magnitude == 0 then
			return Platform.MOBILE_UNKNOWN
		end

		if deviceGravity.Position.Unit.Magnitude > deviceGravity.Position.Magnitude or deviceGravity.Position.Magnitude <= 1.75 then
			return Platform.IPHONEOS
		end

		if deviceGravity.Position.Magnitude > 1.75 then
			return Platform.ANDROID
		end

		return Platform.MOBILE_UNKNOWN
	end
end

function StarwatchClient.init(data)
	localPlayer = Players.LocalPlayer
	starwatchSessionId = HttpService:GenerateGUID(false)
	userId = HashUtils.hashUserId((tostring(localPlayer.UserId)))
	local v9

	if data and data.getPlatform then
		v9 = data.getPlatform
	else
		v9 = defaultPlatform
	end

	local v10 = SafeCall(v9)()

	if typeof(v10) == "number" then
		ANDROID = v10
	else
		warn("[Starwatch] Failed to get platform from config — falling back to internal defaultPlatform()")
		ANDROID = Platform.ANDROID
	end

	local v11

	if data and data.getLevel then
		v11 = data.getLevel
	else
		v11 = defaultLevel
	end

	v8 = v11
	robloxLocaleId = LocalizationService.RobloxLocaleId or "en"
	task.spawn(function()
		local v12 = SafeCall(function()
			return LocalizationService:GetCountryRegionForPlayerAsync(localPlayer)
		end)()

		if typeof(v12) == "string" then
			countryCode = v12
		end
	end)

	if data then
		local automaticEventTracking = data.automaticEventTracking
		local automaticGaugeTracking = data.automaticGaugeTracking

		if automaticEventTracking or automaticGaugeTracking then
			StarwatchDefaultInstrumentation.init(StarwatchClient, automaticEventTracking, automaticGaugeTracking)
		end
	end

	StarwatchClient.startHeartbeat()
end

local function createEvent(label: string, position: Vector3, options)
	return {
		label = label,
		ts = os.date("!%Y-%m-%dT%H:%M:%SZ"),
		loc = {
			x = position.X,
			y = position.Y,
			z = position.Z
		},
		params = options or {}
	}
end

local function createChatEvent(options)
	return {
		label = "chat",
		ts = os.date("!%Y-%m-%dT%H:%M:%SZ"),
		id = HttpService:GenerateGUID(false),
		params = options or {}
	}
end

local function createSocialEvent(label: string, value2: string, position: Vector3, options)
	local hashUserId = HashUtils.hashUserId(value2)
	return {
		label = label,
		userId = userId,
		otherId = hashUserId,
		ts = os.date("!%Y-%m-%dT%H:%M:%SZ"),
		loc = {
			x = position.X,
			y = position.Y,
			z = position.Z
		},
		params = options or {}
	}
end

local function buildLevelEventTemplate(position: Vector3)
	local v9 = SafeCall(v8 or defaultLevel)()
	local levelName = typeof(v9) ~= "string" and "unknown_level" or v9
	local clone = next(v) and table.clone(v) or nil
	local clone2 = next(v4) and table.clone(v4) or nil
	local clone3 = next(v2) and table.clone(v2) or {}
	local clone4 = next(chatEvents) and table.clone(chatEvents) or {}
	local fps = math.floor(1 / math.max(RunService.RenderStepped:Wait(), 0.001))
	return {
		userId = userId,
		platform = ANDROID,
		gameserver = game.JobId == "" and "local-dev" or game.JobId or "local-dev",
		position = {
			x = position.X,
			y = position.Y,
			z = position.Z
		},
		fps = fps,
		countryCode = countryCode,
		eventCounts = clone,
		gaugeValues = clone2,
		starwatchSessionId = starwatchSessionId,
		levelName = levelName,
		deviceLang = robloxLocaleId,
		events = {
			chatEvents = clone4,
			socialEvents = {},
			otherEvents = clone3
		},
		otherParams = {}
	}
end

function StarwatchClient.submitEvent(label: string, items)
	if flag then
		return
	end

	if typeof(label) ~= "string" or label == "" then
		warn("[Starwatch] submitEvent: invalid label", label)
		return
	end

	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return
	end

	local position = humanoidRootPart.Position
	v[label] = (v[label] or 0) + 1

	if items and next(items) then
		table.insert(v2, (createEvent(label, position, items)))
	end
end

function StarwatchClient.submitChatEvent(options)
	local v9 = options or {}

	if flag then
		return
	end

	local chatEvent = createChatEvent({
		message = v9.message or "",
		flagged = v9.flagged or false,
		annotation = v9.annotation or "",
		tag = v9.tag or ""
	})
	table.insert(chatEvents, chatEvent)
end

function StarwatchClient.submitSocialEvent(label: string, value2: string, p)
	if flag then
		return
	end

	if typeof(label) ~= "string" or label == "" then
		warn("[Starwatch] submitSocialEvent: invalid label", label)
		return
	end

	if typeof(value2) ~= "string" or value2 == "" then
		warn("[Starwatch] submitSocialEvent: invalid otherId", value2)
		return
	end

	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		local position = humanoidRootPart.Position
		table.insert(v3, (createSocialEvent(label, value2, position, p)))
	end
end

function StarwatchClient.startHeartbeat()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end

	local total = 0
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt

		if total >= 2 then
			total = 0

			if flag then
				return
			end

			local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
			local position = humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoidRootPart.Position or createVector(
				0,
				0,
				0
			)
			starwatchClientEventIngestor:FireServer("LevelEvent", (buildLevelEventTemplate(position)))
			table.clear(v)
			table.clear(v2)
			table.clear(chatEvents)
			table.clear(v3)
		end
	end)
end

function StarwatchClient.pause()
	flag = true
end

function StarwatchClient.resume()
	flag = false
end

function StarwatchClient.isPaused()
	return flag
end

function StarwatchClient.setGauge(value: string, value2: number)
	if flag then
		return
	end

	if typeof(value) ~= "string" or value == "" then
		warn("[Starwatch] setGauge: invalid gaugeName", value)
	elseif typeof(value2) == "number" then
		v4[value] = value2
	else
		warn("[Starwatch] setGauge: invalid value, must be a number", value2)
	end
end

function StarwatchClient.getGauge(value: string)
	if typeof(value) == "string" and value ~= "" then
		return v4[value]
	end

	warn("[Starwatch] getGauge: invalid gaugeName", value)
	return nil
end

function StarwatchClient.removeGauge(value: string)
	if typeof(value) == "string" and value ~= "" then
		v4[value] = nil
	else
		warn("[Starwatch] removeGauge: invalid gaugeName", value)
	end
end

function StarwatchClient.clearAllGauges()
	table.clear(v4)
end

return StarwatchClient