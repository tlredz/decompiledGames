local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LogService = game:GetService("LogService")
local Stats = game:GetService("Stats")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local DeviceForm = require(ReplicatedStorage.UserGenerated.Roblox.DeviceForm)
local MicroProfilerConfig = require(ReplicatedStorage.UserGenerated.Analytics.MicroProfilerConfig)
local DataModel = require(ReplicatedStorage.UserGenerated.DataModel)
local localPlayer = Players.LocalPlayer

local function diag(...) end

local function diagWarn(...) end

diag("script running; userId =", localPlayer.UserId)

local function WaitRemote(childName: string)
	local child = script.Parent:WaitForChild(childName, 10)

	if child then
		diag("resolved remote:", childName, (`({child.ClassName})`))
		return child
	end

	diagWarn("MISSING remote (WaitForChild timed out after 10s):", childName)
	return child
end

local fps = script.Parent:WaitForChild("Fps", 10)

if fps then
	diag("resolved remote:", "Fps", (`({fps.ClassName})`))
else
	diagWarn("MISSING remote (WaitForChild timed out after 10s):", "Fps")
end

local libMPDevice = script.Parent:WaitForChild("LibMPDevice", 10)

if libMPDevice then
	diag("resolved remote:", "LibMPDevice", (`({libMPDevice.ClassName})`))
else
	diagWarn("MISSING remote (WaitForChild timed out after 10s):", "LibMPDevice")
end

local libMPRequiring = script.Parent:WaitForChild("LibMPRequiring", 10)

if libMPRequiring then
	diag("resolved remote:", "LibMPRequiring", (`({libMPRequiring.ClassName})`))
else
	diagWarn("MISSING remote (WaitForChild timed out after 10s):", "LibMPRequiring")
end

local libMPRequired = script.Parent:WaitForChild("LibMPRequired", 10)

if libMPRequired then
	diag("resolved remote:", "LibMPRequired", (`({libMPRequired.ClassName})`))
else
	diagWarn("MISSING remote (WaitForChild timed out after 10s):", "LibMPRequired")
end

local libMPFrame = script.Parent:WaitForChild("LibMPFrame", 10)

if libMPFrame then
	diag("resolved remote:", "LibMPFrame", (`({libMPFrame.ClassName})`))
else
	diagWarn("MISSING remote (WaitForChild timed out after 10s):", "LibMPFrame")
end

local liveRequest = script.Parent:WaitForChild("LiveRequest", 10)

if liveRequest then
	diag("resolved remote:", "LiveRequest", (`({liveRequest.ClassName})`))
else
	diagWarn("MISSING remote (WaitForChild timed out after 10s):", "LiveRequest")
end

local liveResponse = script.Parent:WaitForChild("LiveResponse", 10)

if liveResponse then
	diag("resolved remote:", "LiveResponse", (`({liveResponse.ClassName})`))
else
	diagWarn("MISSING remote (WaitForChild timed out after 10s):", "LiveResponse")
end

local v = nil
local v2 = table.create(60, 0)
local v3 = table.create(60, 0)
local v4 = -1
RunService.RenderStepped:Connect(function(dt: number)
	local v5 = math.floor((os.clock())) % 60 + 1

	if v5 ~= v4 then
		v2[v5] = 0
		v3[v5] = 0
		v4 = v5
	end

	v2[v5] += 1
	v3[v5] += dt
end)

local function getRecentAvgFps()
	local total = 0
	local total2 = 0

	for i = 1, 60 do
		total += v2[i]
		total2 += v3[i]
	end

	if total2 <= 0 then
		return 0
	end

	return total / total2
end

local v5 = {}

local function GetBucket(p: number)
	local v6 = v5[p]

	if not v6 then
		v6 = {
			Frames = 0,
			Time = 0,
			Spikes = 0
		}
		v5[p] = v6
	end

	return v6
end

local total = 0
local v6 = 0
local total2 = 0
local flag = false
local dts = table.create(60, 0)
local count = 0
local v7 = 0
local v8 = table.create(60, 0)

local function GetMedian()
	if count < 60 then
		return 0
	end

	for i = 1, 60 do
		v8[i] = dts[i]
	end

	table.sort(v8)
	return (v8[30] + v8[31]) * 0.5
end

local function ReportBucket(p: number)
	local v9 = v5[p]

	if not v9 or v9.Time <= 0 then
		return
	end

	local v10 = v9.Frames / v9.Time
	fps:FireServer(p, v10, v9.Spikes)
	diag("fired Fps: minute", p, "avgFps", math.round(v10), "spikes", v9.Spikes)
end

local renderSteppedConnection = nil
renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
	local median = GetMedian()

	if median > 0 then
		if median * 3 < dt then
			if not flag then
				local v10 = v6
				local v11 = v5[v10]

				if not v11 then
					v11 = {
						Frames = 0,
						Time = 0,
						Spikes = 0
					}
					v5[v10] = v11
				end

				v11.Spikes += 1
				flag = true
			end
		else
			flag = false
		end
	end

	v7 = v7 % 60 + 1
	dts[v7] = dt

	if count < 60 then
		count += 1
	end

	local v10 = v6
	local v11 = v5[v10]

	if not v11 then
		v11 = {
			Frames = 0,
			Time = 0,
			Spikes = 0
		}
		v5[v10] = v11
	end

	v11.Frames += 1
	v11.Time += dt
	total += dt
	local v12 = math.floor(total / 60)

	if v12 ~= v6 then
		for i = v6, math.min(v12, 60) - 1 do
			local v13 = v5[i]

			if not v13 or v13.Time <= 0 then
				continue
			end

			local v14 = v13.Frames / v13.Time
			fps:FireServer(i, v14, v13.Spikes)
			diag("fired Fps: minute", i, "avgFps", math.round(v14), "spikes", v13.Spikes)
		end

		v6 = v12
		total2 = 0
	end

	if v6 >= 60 then
		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end
	else
		total2 += dt

		if total2 >= 15 then
			total2 = 0
			local v13 = v6
			local v14 = v5[v13]

			if v14 then
				if v14.Time <= 0 then
					return
				end

				local v15 = v14.Frames / v14.Time
				fps:FireServer(v13, v15, v14.Spikes)
				diag("fired Fps: minute", v13, "avgFps", math.round(v15), "spikes", v14.Spikes)
			end
		end
	end
end)
task.spawn(function()
	for i = 1, 5 do
		local v9 = DeviceForm.Get()
		diag("device report attempt", i, "->", not v9 and "nil" or v9.Name)

		if v9 then
			libMPDevice:FireServer(v9)
			diag("fired LibMPDevice:", v9.Name)
			return
		else
			task.wait(1)
		end
	end

	diagWarn("device never resolved after 5 attempts; LibMPDevice was NOT fired")
end)
local flag2 = false

local function StartCapture(moduleScript)
	if flag2 then
		return
	end

	flag2 = true
	diag("StartCapture: module delivered ->", moduleScript:GetFullName())
	libMPRequiring:FireServer()
	diag("fired LibMPRequiring")
	local success, result = pcall(require, moduleScript)

	if not success or type(result) ~= "table" then
		diagWarn("require(LibMP) failed:", result)
		return
	end

	diag("require(LibMP) ok")
	libMPRequired:FireServer()
	diag("fired LibMPRequired")
	local v9 = MicroProfilerConfig.FramesBefore:Get()
	local v10 = MicroProfilerConfig.FramesAfter:Get()
	local control = result.Control
	local lastTime = os.clock()

	while not control:IsBackendReady() do
		if os.clock() - lastTime > 30 then
			diagWarn("LibMP backend not ready after 30s; capture disabled")
			return
		else
			task.wait()
		end
	end

	local success2, result2 = pcall(function()
		control:SetFrameLimit(v9 + v10 + 1)
		control:EnableProfiler(true)
		control:EnableCapture(true)
	end)

	if not success2 then
		diagWarn("LibMP setup failed:", result2)
		return
	end

	v = control
	diag("LibMP capture armed; window =", v9, "+1+", v10)
	local count2 = 0
	local now = -1e999
	local v11 = 0
	local tickStartCpu = nil
	local v12 = nil
	task.spawn(function()
		task.wait(2)
		local v13 = result.Session.OpenFromLiveData()

		if v13 and v13:IsValid() then
			while count2 < MicroProfilerConfig.MaxFramesPerSession:Get() do
				task.wait(0.03)
				pcall(function()
					v13:SetSyncRequired()
					local globalDesc = v13:FetchGlobalDesc()
					local tickToMsCpu = globalDesc.TickToMsCpu
					local tickToMsGpu = globalDesc.TickToMsGpu
					local frameIdMin = v13:GetFrameIdMin()
					local frameIdMax = v13:GetFrameIdMax()

					if frameIdMax == 0 or type(tickToMsCpu) ~= "number" or tickToMsCpu <= 0 then
						return
					end

					local v14 = math.max(frameIdMin, v11 + 1)
					local v15 = 0
					local v16 = 0
					local v17 = 0
					local v18 = 0
					local v19 = 0
					local v20 = 0

					for i = v14, frameIdMax do
						local frameDesc = v13:FetchFrameDesc(i)

						if not frameDesc then
							continue
						end

						local frameAbsoluteId = frameDesc.FrameAbsoluteId

						if v12 then
							local _ = frameAbsoluteId - v12
						end

						if frameDesc.IsPaused then
							continue
						end

						local v21 = (frameDesc.TickEndCpu - frameDesc.TickStartCpu) * tickToMsCpu
						local v22 = (type(tickToMsGpu) ~= "number" or not (tickToMsGpu > 0)) and 0 or math.max(
							(frameDesc.TickEndGpu - frameDesc.TickStartGpu) * tickToMsGpu,
							0
						)
						local v24 = (tickStartCpu == nil or v12 == nil or frameAbsoluteId ~= v12 + 1 or not tickStartCpu) and 0 or (frameDesc.TickStartCpu - tickStartCpu) * tickToMsCpu
						tickStartCpu = frameDesc.TickStartCpu
						v12 = frameAbsoluteId
						local v25 = math.max(v21, v24)

						if not (v15 < v25) then
							continue
						end

						v20 = v24
						v19 = v22
						v18 = v21
						v17 = frameAbsoluteId
						v16 = i
						v15 = v25
					end

					if v14 <= frameIdMax then
						v11 = frameIdMax
					end

					if MicroProfilerConfig.LaggyFrameMs:Get() <= v15 then
						diag(
							"laggy frame",
							v16,
							"abs",
							v17,
							"peakMs",
							string.format("%.2f", v15),
							"[ cpu",
							string.format("%.2f", v18),
							"gpu",
							string.format("%.2f", v19),
							"interval",
							string.format("%.2f", v20),
							"]"
						)

						if os.clock() - now >= MicroProfilerConfig.MinFrameInterval:Get() then
							for _ = 1, v10 do
								RunService.RenderStepped:Wait()
							end

							local captureToBufferSync = control:CaptureToBufferSync()

							if typeof(captureToBufferSync) ~= "buffer" then
								diagWarn("CaptureToBufferSync produced no buffer; got", (typeof(captureToBufferSync)))
								return
							end

							if buffer.len(captureToBufferSync) > MicroProfilerConfig.MaxDumpBytes:Get() then
								diagWarn("dump over MaxDumpBytes; size =", buffer.len(captureToBufferSync))
								return
							end

							count2 += 1
							now = os.clock()
							libMPFrame:FireServer(captureToBufferSync, v15)
							diag(
								"fired LibMPFrame; size =",
								buffer.len(captureToBufferSync),
								"peakMs =",
								string.format("%.2f", v15),
								"windowsSent =",
								count2
							)
						end
					end
				end)
			end

			v13:Dispose()
		else
			diagWarn("OpenFromLiveData failed; client laggy-frame capture disabled")

			if v13 then
				v13:Dispose()
			end
		end
	end)
end

task.spawn(function()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	diag("waiting for LibMP module:", MicroProfilerConfig.ModuleName)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function waitForLibMP(childName: string)
		local moduleScript = playerGui:WaitForChild(childName, 1e999):WaitForChild(
			MicroProfilerConfig.ModuleName,
			1e999
		)

		if moduleScript:IsA("ModuleScript") then
			diag("found LibMP module via", childName)
			StartCapture(moduleScript)
		end
	end

	task.spawn(waitForLibMP, MicroProfilerConfig.ContainerName)
	waitForLibMP("__UG_LiveLibMPGui") -- equivalent call inferred; original call site unknown
end)

local function ensureArmed(p: number)
	if v then
		return v
	end

	local lastTime = os.clock()

	while not v and os.clock() - lastTime < p do
		task.wait(0.1)
	end

	return v
end

local function collectClientLogs()
	local logHistory = LogService:GetLogHistory()
	local result = {}

	for i = math.max(1, #logHistory - 400 + 1), #logHistory do
		local v9 = logHistory[i]
		local message = tostring(v9.message)

		if #message > 1000 then
			message = string.sub(message, 1, 1000) .. "…"
		end

		local messageType

		if typeof(v9.messageType) == "EnumItem" then
			messageType = v9.messageType.Name
		else
			messageType = tostring(v9.messageType)
		end

		local v10 = {
			message = message,
			messageType = messageType,
			timestamp = v9.timestamp
		}
		table.insert(result, v10)
	end

	return result
end

local function captureClientMicroprofiler(p: number)
	local armed = ensureArmed(8)

	if not armed then
		diagWarn("captureClientMicroprofiler: ensureArmed(8) returned nil (LibMP not armed)")
		return nil
	end

	diag("captureClientMicroprofiler: armed; capturing", p, "frames")
	local v9 = MicroProfilerConfig.FramesBefore:Get() + MicroProfilerConfig.FramesAfter:Get() + 1
	local success, result = pcall(function()
		armed:SetFrameLimit(p)
		armed:EnableProfiler(true)
		armed:EnableCapture(true)
	end)

	if not success then
		diagWarn("captureClientMicroprofiler: enable/setFrameLimit failed:", result)
		return nil
	end

	for _ = 1, p + 12 do
		RunService.RenderStepped:Wait()
	end

	local captureToBufferSync = armed:CaptureToBufferSync()
	pcall(function()
		armed:SetFrameLimit(v9)
	end)

	if typeof(captureToBufferSync) == "buffer" then
		diag("captureClientMicroprofiler: dump buffer size =", buffer.len(captureToBufferSync))
		return captureToBufferSync
	end

	diagWarn("captureClientMicroprofiler: CaptureToBufferSync gave", (typeof(captureToBufferSync)))
	return nil
end

local name = nil

local function getDeviceName()
	if name then
		return name
	end

	local v9 = DeviceForm.Get()

	if v9 then
		name = v9.Name
	end

	return name
end

local function getClientMemoryMb()
	local success, result = pcall(function()
		return Stats:GetTotalMemoryUsageMb()
	end)

	if success and type(result) == "number" then
		return result
	end

	return nil
end

local function getClientMeta()
	local v9 = {
		avgFps = getRecentAvgFps(),
		device = 0,
		engineVersion = 0
	}

	if not name then
		local v10 = DeviceForm.Get()

		if v10 then
			name = v10.Name
		end
	end

	v9.device = name
	v9.engineVersion = version()
	pcall(function()
		local currentCamera = Workspace.CurrentCamera

		if currentCamera then
			local viewportSize = currentCamera.ViewportSize
			v9.renderResolution = {
				x = math.round(viewportSize.X),
				y = math.round(viewportSize.Y)
			}
		end
	end)
	pcall(function()
		local viewportDisplaySize = GuiService.ViewportDisplaySize
		v9.displaySize = {
			x = math.round(viewportDisplaySize.X),
			y = math.round(viewportDisplaySize.Y)
		}
	end)
	pcall(function()
		v9.savedQualityLevel = UserSettings().GameSettings.SavedQualityLevel.Value
	end)
	return v9
end

local flag3 = false

local function captureDataModelSnapshot(dataModel)
	if type(dataModel) ~= "table" then
		return nil, nil
	end

	local recentAvgFps = getRecentAvgFps()
	local capture = DataModel.capture
	local v9

	if recentAvgFps > 0 then
		v9 = 1 / recentAvgFps
	end

	local success, result = pcall(capture, dataModel, v9)

	if not success or type(result) ~= "table" then
		return nil, nil
	end

	if result.TimedOut then
		return {
			TimedOut = true
		}, nil
	end

	if typeof(result.Buffer) == "buffer" and not (buffer.len(result.Buffer) > 67108864) then
		return {
			Classes = result.Classes,
			Props = result.Props,
			Truncated = result.Truncated
		}, result.Buffer
	end

	return {
		Truncated = true
	}, nil
end

liveRequest.OnClientEvent:Connect(function(value, value2, p)
	if type(value) ~= "string" or type(value2) ~= "string" then
		return
	end

	task.spawn(function()
		if value2 == "fps" then
			local v11 = {
				fps = getRecentAvgFps(),
				device = 0,
				memory = 0
			}

			if not name then
				local v12 = DeviceForm.Get()

				if v12 then
					name = v12.Name
				end
			end

			v11.device = name
			local success, result = pcall(function()
				return Stats:GetTotalMemoryUsageMb()
			end)

			if not success or type(result) ~= "number" then
				result = nil
			end

			v11.memory = result
			liveResponse:FireServer(value, v11)
		elseif value2 == "output" then
			liveResponse:FireServer(value, {
				logs = collectClientLogs()
			})
		elseif value2 == "microprofiler" then
			if flag3 then
				liveResponse:FireServer(value, {
					error = "busy"
				})
				return
			end

			flag3 = true
			local v9 = math.clamp(
				math.floor((type(p) ~= "table" or type(p.frames) ~= "number") and 128 or p.frames),
				8,
				256
			)
			local dataModel

			if type(p) == "table" then
				dataModel = p.dataModel
			end

			local buf = captureClientMicroprofiler(v9)
			local buf2 = nil
			local buf3 = nil
			local v10

			if buf then
				if buffer.len(buf) > 67108864 then
					v10 = {
						error = "Dump size over 64mb. Cannot be retrieved."
					}
				else
					v10 = {
						ok = true,
						meta = getClientMeta()
					}

					if dataModel then
						local snapshot, v12 = captureDataModelSnapshot(dataModel)

						if snapshot then
							v10.snapshot = snapshot
							buf3 = v12
						end
					end

					buf2 = buf
				end
			else
				v10 = {
					error = "libmp_unavailable"
				}
			end

			flag3 = false
			liveResponse:FireServer(value, v10, buf2, buf3)
		end
	end)
end)