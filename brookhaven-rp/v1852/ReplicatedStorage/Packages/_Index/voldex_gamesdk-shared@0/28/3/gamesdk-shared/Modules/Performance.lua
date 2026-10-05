local Stats = game:GetService("Stats")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local parentModule = require(script.Parent.Parent)
local Telemetry = require(parentModule.Modules.Telemetry)
local Places = require(parentModule.Modules.Places)
local PerformanceUtil = require(parentModule.Utils.PerformanceUtil)
local MathUtil = require(parentModule.Utils.MathUtil)
local Loader = require(script.Parent.Parent.Loader)
local v = {
	"InstanceCount",
	"MovingPrimitivesCount",
	"RenderCPUFrameTime",
	"RenderGPUFrameTime",
	"SceneDrawcallCount",
	"SceneTriangleCount",
	"ShadowsDrawcallCount",
	"ShadowsTriangleCount",
	"UI2DDrawcallCount",
	"UI2DTriangleCount",
	"UI3DDrawcallCount",
	"UI3DTriangleCount",
	"DataReceiveKbps",
	"DataSendKbps",
	"PhysicsReceiveKbps",
	"PhysicsSendKbps",
	"PhysicsStepTime",
	"PrimitivesCount",
	"ContactsCount"
}
local Performance = {
	DependsOn = { "Telemetry", "Places" },
	Events = {
		Stats = "ClientPerformanceStats",
		Connect = "clientPerformanceConnectStats"
	},
	_timingsRemote = nil,
	_profileRemote = nil,
	_profileTask = nil,
	_profileCallables = {},
	_framerate = nil,
	_avgFramerate = nil,
	_avgPing = nil,
	_avgDataSend = nil,
	_avgDataReceive = nil,
	_avgPhysicsStep = nil,
	_avgPhysicsSend = nil,
	_avgPhysicsReceive = nil,
	_avgPhysicsThrottle = nil,
	_avgPhysicsAwakeParts = nil,
	_sceneDrawcallCount = nil,
	_sceneTriangleCount = nil,
	_renderCPUFrameTime = nil,
	_renderGPUFrameTime = nil,
	_frameratePoints = {},
	_lastSubmit = tick(),
	_sdValue = 0,
	_sdFunc = nil,
	_isWindowFocused = false,
	_initialized = false
}

local function erroro(p)
	error("[GameSdk - Performance] " .. p)
end

local function append(p, p2: number)
	if p == nil then
		p = PerformanceUtil.NewBlankRecord()
	end

	PerformanceUtil.Append(p, p2)
	return p
end

local function format(p, value: number?)
	if p == nil then
		return nil
	end

	local v2 = value or 2
	return {
		Average = MathUtil.round(PerformanceUtil.GetAverage(p), v2),
		Min = MathUtil.round(p.min, v2),
		Max = MathUtil.round(p.max, v2)
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPercentile(_frameratePoints, p)
	local v2 = #_frameratePoints * p

	if v2 + 6755399441055744 - 6755399441055744 == v2 then
		return _frameratePoints[v2]
	end

	local v3 = math.floor(v2)
	local v4 = math.ceil(v2)

	if _frameratePoints[v3] and _frameratePoints[v4] then
		return (_frameratePoints[v3] + _frameratePoints[v4]) / 2
	end

	if _frameratePoints[v3] then
		return _frameratePoints[v3]
	end

	if _frameratePoints[v4] then
		return _frameratePoints[v4]
	end

	return -1
end

local function getStability(items, p, p2)
	local count = 0
	local count2 = 0

	for _, item in items do
		if p * (1 - p2) < item and item < p * (1 + p2) then
			count += 1
		end

		count2 += 1
	end

	return count / count2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getStandardDeviationFactory()
	local v2 = 0
	local v3 = 0
	local v4 = 0
	return function(p)
		local v5 = v2 + p
		local v6 = v3 + p ^ 2
		local v7 = v4 + 1
		v2 = v5
		v3 = v6
		v4 = v7
		Performance._sdValue = math.sqrt(v3 / v4 - (v2 / v4) ^ 2)
	end
end

local function fireAndResetRecords(p: string)
	local min = nil
	local max = nil

	for _, _frameratePoint in Performance._frameratePoints do
		min = math.min(min or _frameratePoint, _frameratePoint)
		max = math.max(max or _frameratePoint, _frameratePoint)
	end

	local rounded, values

	if Stats.MemoryTrackingEnabled then
		rounded = MathUtil.round(Stats:GetTotalMemoryUsageMb(), 4)
		values = {}

		for _, v4 in Enum.DeveloperMemoryTag:GetEnumItems() do
			values[v4.Name] = MathUtil.round(Stats:GetMemoryUsageMbForTag(v4), 4)
		end
	end

	local success, service = pcall(UserSettings().GetService, UserSettings(), "UserGameSettings")
	local savedQualityLevel

	if success and service ~= nil then
		savedQualityLevel = service.SavedQualityLevel
	end

	local framerate = Performance.GetFramerate()
	table.sort(Performance._frameratePoints)
	local percentile = getPercentile(Performance._frameratePoints, 0.5) -- equivalent call inferred; original call site unknown
	local configuration = parentModule:GetConfiguration()
	local v4 = (configuration == nil or configuration:GetPerformanceSamplePercent() == nil) and 100 or configuration:GetPerformanceSamplePercent()
	local fireSampledEvent = Telemetry.FireSampledEvent
	local v5 = {
		Ping = PerformanceUtil.GetAverage(Performance._avgPing),
		InstancesLoadedInMemory = Stats.InstanceCount,
		TotalMemoryUsed = rounded,
		MemorySummary = values,
		MemoryTrackingEnabled = Stats.MemoryTrackingEnabled,
		AverageDataTransferRates = {
			Send = PerformanceUtil.GetAverage(Performance._avgDataSend),
			Receive = PerformanceUtil.GetAverage(Performance._avgDataReceive)
		},
		AveragePhysics = {
			Step = PerformanceUtil.GetAverage(Performance._avgPhysicsStep),
			AwakeParts = PerformanceUtil.GetAverage(Performance._avgPhysicsAwakeParts),
			ThrottlePercent = PerformanceUtil.GetAverage(Performance._avgPhysicsThrottle),
			Send = PerformanceUtil.GetAverage(Performance._avgPhysicsSend),
			Receive = PerformanceUtil.GetAverage(Performance._avgPhysicsReceive)
		},
		FPSData = 0,
		SceneDrawcallCount = 0,
		SceneTriangleCount = 0,
		RenderCPUFrameTime = 0,
		RenderGPUFrameTime = 0,
		QualityLevel = 0,
		TimeframeTracked = 0
	}
	local fPSData = {
		IsFPSUnlocked = framerate > 65,
		Current = framerate,
		Average = PerformanceUtil.GetAverage(Performance._avgFramerate),
		Min = min,
		Max = max
	}
	local percentile2 = getPercentile(Performance._frameratePoints, 0.9) -- equivalent call inferred; original call site unknown
	fPSData["90Percentile"] = percentile2
	local percentile3 = getPercentile(Performance._frameratePoints, 0.75) -- equivalent call inferred; original call site unknown
	fPSData["75Percentile"] = percentile3
	fPSData["50Percentile"] = percentile
	local percentile4 = getPercentile(Performance._frameratePoints, 0.25) -- equivalent call inferred; original call site unknown
	fPSData["25Percentile"] = percentile4
	local percentile5 = getPercentile(Performance._frameratePoints, 0.1) -- equivalent call inferred; original call site unknown
	fPSData["10Percentile"] = percentile5
	local count = 0
	local count2 = 0

	for _, _frameratePoint in Performance._frameratePoints do
		if percentile * 0.8 < _frameratePoint and _frameratePoint < percentile * 1.2 then
			count += 1
		end

		count2 += 1
	end

	fPSData.Stability = count / count2
	fPSData.StandardDeviation = Performance._sdValue
	v5.FPSData = fPSData
	v5.SceneDrawcallCount = format(Performance._sceneDrawcallCount, 0)
	v5.SceneTriangleCount = format(Performance._sceneTriangleCount, 0)
	v5.RenderCPUFrameTime = format(Performance._renderCPUFrameTime, 4)
	local renderGPUFrameTime

	if not RunService:IsStudio() then
		renderGPUFrameTime = format(Performance._renderGPUFrameTime, 4)
	end

	v5.RenderGPUFrameTime = renderGPUFrameTime
	v5.QualityLevel = savedQualityLevel and savedQualityLevel.Name or nil
	v5.TimeframeTracked = MathUtil.round(tick() - Performance._lastSubmit, 0)
	fireSampledEvent(v4, p, v5)
	Performance._avgFramerate = PerformanceUtil.NewBlankRecord()
	Performance._avgPing = PerformanceUtil.NewBlankRecord()
	Performance._avgDataSend = PerformanceUtil.NewBlankRecord()
	Performance._avgDataReceive = PerformanceUtil.NewBlankRecord()
	Performance._avgPhysicsStep = PerformanceUtil.NewBlankRecord()
	Performance._avgPhysicsSend = PerformanceUtil.NewBlankRecord()
	Performance._avgPhysicsReceive = PerformanceUtil.NewBlankRecord()
	Performance._avgPhysicsThrottle = PerformanceUtil.NewBlankRecord()
	Performance._avgPhysicsAwakeParts = PerformanceUtil.NewBlankRecord()
	Performance._sceneDrawcallCount = PerformanceUtil.NewBlankRecord()
	Performance._sceneTriangleCount = PerformanceUtil.NewBlankRecord()
	Performance._renderCPUFrameTime = PerformanceUtil.NewBlankRecord()
	Performance._renderGPUFrameTime = PerformanceUtil.NewBlankRecord()
	Performance._frameratePoints = {}
	Performance._sdFunc = getStandardDeviationFactory()
	Performance._lastSubmit = tick()
end

local function framerateLoop()
	while RunService:IsRunning() do
		Performance._framerate = 1 / RunService.RenderStepped:Wait()
		task.wait(0.5)
	end
end

local function collectWorker()
	if Performance._sdFunc == nil then
		Performance._sdFunc = getStandardDeviationFactory()
	end

	while RunService:IsRunning() do
		task.wait(1)

		if not Performance._isWindowFocused then
			continue
		end

		local framerate = Performance.GetFramerate()

		if framerate ~= nil then
			local v2 = Performance
			local _avgFramerate = Performance._avgFramerate

			if _avgFramerate == nil then
				_avgFramerate = PerformanceUtil.NewBlankRecord()
			end

			PerformanceUtil.Append(_avgFramerate, framerate)
			v2._avgFramerate = _avgFramerate
			table.insert(Performance._frameratePoints, framerate)
			Performance._sdFunc(framerate)
		end

		local v2 = Performance
		local _sceneDrawcallCount = Performance._sceneDrawcallCount
		local sceneDrawcallCount = Stats.SceneDrawcallCount

		if _sceneDrawcallCount == nil then
			_sceneDrawcallCount = PerformanceUtil.NewBlankRecord()
		end

		PerformanceUtil.Append(_sceneDrawcallCount, sceneDrawcallCount)
		v2._sceneDrawcallCount = _sceneDrawcallCount
		local v3 = Performance
		local _sceneTriangleCount = Performance._sceneTriangleCount
		local sceneTriangleCount = Stats.SceneTriangleCount

		if _sceneTriangleCount == nil then
			_sceneTriangleCount = PerformanceUtil.NewBlankRecord()
		end

		PerformanceUtil.Append(_sceneTriangleCount, sceneTriangleCount)
		v3._sceneTriangleCount = _sceneTriangleCount
		local v4 = Performance
		local _renderCPUFrameTime = Performance._renderCPUFrameTime
		local renderCPUFrameTime = Stats.RenderCPUFrameTime

		if _renderCPUFrameTime == nil then
			_renderCPUFrameTime = PerformanceUtil.NewBlankRecord()
		end

		PerformanceUtil.Append(_renderCPUFrameTime, renderCPUFrameTime)
		v4._renderCPUFrameTime = _renderCPUFrameTime
		local v5 = Performance
		local _renderGPUFrameTime = Performance._renderGPUFrameTime
		local renderGPUFrameTime = Stats.RenderGPUFrameTime

		if _renderGPUFrameTime == nil then
			_renderGPUFrameTime = PerformanceUtil.NewBlankRecord()
		end

		PerformanceUtil.Append(_renderGPUFrameTime, renderGPUFrameTime)
		v5._renderGPUFrameTime = _renderGPUFrameTime
		local v6 = Performance
		local _avgPing = Performance._avgPing
		local ping = Performance.GetPing()

		if _avgPing == nil then
			_avgPing = PerformanceUtil.NewBlankRecord()
		end

		PerformanceUtil.Append(_avgPing, ping)
		v6._avgPing = _avgPing
		local v7 = Performance
		local _avgDataSend = Performance._avgDataSend
		local dataSendKbps = Stats.DataSendKbps

		if _avgDataSend == nil then
			_avgDataSend = PerformanceUtil.NewBlankRecord()
		end

		PerformanceUtil.Append(_avgDataSend, dataSendKbps)
		v7._avgDataSend = _avgDataSend
		local v8 = Performance
		local _avgDataReceive = Performance._avgDataReceive
		local dataReceiveKbps = Stats.DataReceiveKbps

		if _avgDataReceive == nil then
			_avgDataReceive = PerformanceUtil.NewBlankRecord()
		end

		PerformanceUtil.Append(_avgDataReceive, dataReceiveKbps)
		v8._avgDataReceive = _avgDataReceive
		local v9 = Performance
		local _avgPhysicsStep = Performance._avgPhysicsStep
		local physicsStepTimeMs = Stats.PhysicsStepTimeMs

		if _avgPhysicsStep == nil then
			_avgPhysicsStep = PerformanceUtil.NewBlankRecord()
		end

		PerformanceUtil.Append(_avgPhysicsStep, physicsStepTimeMs)
		v9._avgPhysicsStep = _avgPhysicsStep
		local v10 = Performance
		local _avgPhysicsSend = Performance._avgPhysicsSend
		local physicsSendKbps = Stats.PhysicsSendKbps

		if _avgPhysicsSend == nil then
			_avgPhysicsSend = PerformanceUtil.NewBlankRecord()
		end

		PerformanceUtil.Append(_avgPhysicsSend, physicsSendKbps)
		v10._avgPhysicsSend = _avgPhysicsSend
		local v11 = Performance
		local _avgPhysicsReceive = Performance._avgPhysicsReceive
		local physicsReceiveKbps = Stats.PhysicsReceiveKbps

		if _avgPhysicsReceive == nil then
			_avgPhysicsReceive = PerformanceUtil.NewBlankRecord()
		end

		PerformanceUtil.Append(_avgPhysicsReceive, physicsReceiveKbps)
		v11._avgPhysicsReceive = _avgPhysicsReceive
		local v12 = Performance
		local _avgPhysicsThrottle = Performance._avgPhysicsThrottle
		local physicsThrottling = workspace:GetPhysicsThrottling()

		if _avgPhysicsThrottle == nil then
			_avgPhysicsThrottle = PerformanceUtil.NewBlankRecord()
		end

		PerformanceUtil.Append(_avgPhysicsThrottle, physicsThrottling)
		v12._avgPhysicsThrottle = _avgPhysicsThrottle
		local v13 = Performance
		local _avgPhysicsAwakeParts = Performance._avgPhysicsAwakeParts
		local numAwakeParts = workspace:GetNumAwakeParts()

		if _avgPhysicsAwakeParts == nil then
			_avgPhysicsAwakeParts = PerformanceUtil.NewBlankRecord()
		end

		PerformanceUtil.Append(_avgPhysicsAwakeParts, numAwakeParts)
		v13._avgPhysicsAwakeParts = _avgPhysicsAwakeParts
	end
end

local function sendConnectWorker()
	local lastTime = tick()
	local configuration = parentModule:GetConfiguration()

	if ((configuration == nil or configuration:GetPerformanceConnectSamplePercent() == nil) and 0 or configuration:GetPerformanceConnectSamplePercent()) <= localPlayer.UserId % 100 then
		return
	end

	while tick() - lastTime < 240 do
		task.wait(30)

		if Performance._isWindowFocused then
			fireAndResetRecords(Performance.Events.Connect)
		end
	end
end

local function sendWorker()
	while RunService:IsRunning() do
		task.wait(300)

		if not Performance._isWindowFocused or #Performance._frameratePoints < 5 then
			continue
		end

		fireAndResetRecords(Performance.Events.Stats)
	end
end

local function createAsyncProfileTask(p: number, p2: number, callback)
	return task.spawn(function()
		local v2 = {}

		for k, _ in Performance._profileCallables do
			v2[k] = {}
		end

		local now = os.clock()

		for i = 1, math.max(1, (math.floor(p2 / p))) do
			for k, _profileCallable in Performance._profileCallables do
				local v3 = _profileCallable() or 0
				local v4 = v3 ~= v3 and 0 or v3
				table.insert(v2[k], v4)
			end

			local v3 = now + i * p - os.clock()

			if v3 > 0 then
				task.wait(v3)
			end
		end

		callback(v2)
	end)
end

local function handleDefaultProfileCallables()
	Performance.AddProfileDataPoint("FrameRate", function()
		return MathUtil.round(Performance.GetFramerate() or 0, 0)
	end)
	Performance.AddProfileDataPoint("FrameTime", function()
		return MathUtil.round((Stats.FrameTime or 0) * 1000, 0)
	end)
	local v2 = not Places.IsProduction() or Stats.MemoryTrackingEnabled
	Performance.AddProfileDataPoint("TotalMemoryUsageMb", function()
		if v2 then
			return MathUtil.round(Stats:GetTotalMemoryUsageMb() or 0, 4)
		end

		return 0
	end)
	Performance.AddProfileDataPoint("MemoryTagsSummed", function()
		if not v2 then
			return 0
		end

		local total = 0

		for _, v3 in Enum.DeveloperMemoryTag:GetEnumItems() do
			total += Stats:GetMemoryUsageMbForTag(v3) or 0
		end

		return MathUtil.round(total, 4)
	end)

	for _, v3 in v do
		local v4 = v3
		Performance.AddProfileDataPoint(v3, function()
			return MathUtil.round(Stats[v4] or 0, 4)
		end)
	end

	if v2 then
		for _, v3 in Enum.DeveloperMemoryTag:GetEnumItems() do
			local v4 = v3
			Performance.AddProfileDataPoint(v3.Name, function()
				return MathUtil.round(Stats:GetMemoryUsageMbForTag(v4) or 0, 4)
			end)
		end
	end

	Performance.AddProfileDataPoint("Ping", function()
		return MathUtil.round(localPlayer:GetNetworkPing() or 0, 0)
	end)
end

local function onClientProfileRemote(p: number, p2: number)
	if Performance._profileTask == nil then
		local function fn(intervalData)
			Performance._profileTask = nil
			Performance._profileRemote:FireServer({
				clientVersion = version(),
				intervalData = intervalData
			})
		end

		Performance._profileTask = task.spawn(function()
			local intervalData = {}

			for k, _ in Performance._profileCallables do
				intervalData[k] = {}
			end

			local now = os.clock()

			for i = 1, math.max(1, (math.floor(p2 / p))) do
				for k, _profileCallable in Performance._profileCallables do
					local v3 = _profileCallable() or 0
					local v4 = v3 ~= v3 and 0 or v3
					table.insert(intervalData[k], v4)
				end

				local v3 = now + i * p - os.clock()

				if v3 > 0 then
					task.wait(v3)
				end
			end

			fn(intervalData)
		end)
	else
		task.cancel(Performance._profileTask)
		Performance._profileTask = nil
	end
end

local function onGameClose()
	if tick() - Performance._lastSubmit < 30 then
		return
	end

	fireAndResetRecords(Performance.Events.Stats)
end

function Performance.Init()
	Performance._timingsRemote = ReplicatedStorage:WaitForChild("GameSdkPerformanceTimingsRemoteEvent", 20)

	if Performance._timingsRemote == nil then
		error("[GameSdk - Performance] Failed to find timings remote event")
	end

	Performance._profileRemote = ReplicatedStorage:WaitForChild("GameSdkPerformanceProfileRemoteEvent", 20)

	if Performance._profileRemote == nil then
		error("[GameSdk - Performance] Failed to find profile remote event")
	end

	Performance._profileRemote.OnClientEvent:Connect(onClientProfileRemote)
	handleDefaultProfileCallables()
	task.spawn(function()
		local v2 = false
		local inputChangedConnection = UserInputService.InputChanged:Connect(function()
			v2 = true
		end)
		local windowFocusedConnection = UserInputService.WindowFocused:Connect(function()
			v2 = true
		end)
		local lastTime = tick()

		while not v2 and tick() - lastTime < 30 do
			task.wait(0.1)
		end

		if inputChangedConnection ~= nil then
			inputChangedConnection:Disconnect()
		end

		if windowFocusedConnection ~= nil then
			windowFocusedConnection:Disconnect()
		end

		Performance._isWindowFocused = true
		UserInputService.WindowFocused:Connect(function()
			Performance._isWindowFocused = true
		end)
		UserInputService.WindowFocusReleased:Connect(function()
			Performance._isWindowFocused = false
		end)
	end)
	task.spawn(function()
		Performance._framerate = 1 / RunService.RenderStepped:Wait()
		Performance._framerateTask = task.spawn(framerateLoop)
		Performance._gatherTask = task.spawn(collectWorker)
		Performance._sendTask = task.spawn(sendWorker)
		Performance._sendConnectTask = task.spawn(sendConnectWorker)
	end)
	game.Close:Connect(onGameClose)
	Performance._initialized = true
end

function Performance.Start()
	local configuration = parentModule:GetConfiguration()

	if ((configuration == nil or configuration:GetTimingsSamplePercent() == nil) and 20 or configuration:GetTimingsSamplePercent()) > localPlayer.UserId % 100 then
		if Loader.GetState() == Loader.States.Done then
			Performance._timingsRemote:FireServer(Loader.Timings)
		else
			Loader.StateChanged:Connect(function(p)
				if p == Loader.States.Done then
					Performance._timingsRemote:FireServer(Loader.Timings)
				end
			end)
		end
	end
end

function Performance.GetFramerate()
	if Performance._framerate == nil then
		return nil
	end

	return math.floor(Performance._framerate * 100) / 100
end

function Performance.GetPing()
	return localPlayer:GetNetworkPing()
end

function Performance.GetMemoryUsage(p)
	if p == nil then
		return Stats:GetTotalMemoryUsageMb()
	end

	return Stats:GetMemoryUsageMbForTag(p)
end

function Performance.AddProfileDataPoint(p: string, callback)
	if callback == nil then
		error("[GameSdk - Performance] Callable must not be nil")
	end

	if Performance._profileCallables[p] ~= nil then
		error("[GameSdk - Performance] Callable with this name already exists")
	end

	if type(callback()) ~= "number" then
		error("[GameSdk - Performance] Callable must return a number")
	end

	Performance._profileCallables[p] = callback
end

return Performance