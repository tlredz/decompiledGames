local module = require("@game/ReplicatedStorage/Omni")
local ScriptContext = game:GetService("ScriptContext")
local analytics = module.Shared.Analytics
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = nil
local count = 0
local now = os.clock()
local screen = "None"
local v11 = nil
local total = 0
local lastTime = os.clock()
local now2 = 0
local v12 = false
local v13 = false
local flag = false
local count2 = 0
local thread = nil
local thread2 = nil
local thread3 = nil

local function GetScreen(p: string)
	local v14 = v2[p]

	if not v14 then
		v14 = {
			Opens = 0,
			Seconds = 0
		}
		v2[p] = v14
	end

	return v14
end

local function MarkInput()
	lastTime = os.clock()
end

local function GetSystem(instance)
	if typeof(instance) ~= "Instance" then
		return "Other"
	end

	local fullName = instance:GetFullName()
	local v14, v15 = string.match(fullName, "Omni%.Scripts%.([%w_]+)%.([%w_ ]+)")

	if v14 then
		return (`{v14}.{v15}`)
	end

	local v16 = string.match(fullName, "Omni%.Main%.([%w_ ]+)")

	if v16 then
		return (`Main.{v16}`)
	end

	return "Other"
end

local function TrackError(_: string, _: string, p)
	local system = GetSystem(p)
	v7[system] = math.min((v7[system] or 0) + 1, analytics.MaximumErrors)
end

local function SamplePerf()
	local now3 = os.clock()
	local v14 = math.max(now3 - now, 0.001)
	local v15 = count / v14
	local v16 = module.Instance:GetNetworkPing() * 1000
	count = 0
	now = now3
	local bucket = analytics.GetBucket("Fps", v15)
	local bucket2 = analytics.GetBucket("Ping", v16)

	if not (bucket and bucket2) then
		return
	end

	local formatted = `{bucket}|{bucket2}`
	local v17 = v8[formatted]

	if not v17 then
		v17 = {
			Kind = "Perf",
			Fps = bucket,
			Ping = bucket2,
			Count = 0
		}
		v8[formatted] = v17
	end

	v17.Count += 1
end

local function RefreshFrames()
	local now3 = os.clock()
	local openedFrames = module.Frame:GetOpenedFrames()

	for k, v14 in v3 do
		if table.find(openedFrames, k) then
			continue
		end

		local v15 = v2[k]

		if not v15 then
			v15 = {
				Opens = 0,
				Seconds = 0
			}
			v2[k] = v15
		end

		v15.Seconds += now3 - v14
		v3[k] = nil
	end

	for _, openedFrame in openedFrames do
		if v3[openedFrame] then
			continue
		end

		v3[openedFrame] = now3
		local v14 = v2[openedFrame]

		if not v14 then
			v14 = {
				Opens = 0,
				Seconds = 0
			}
			v2[openedFrame] = v14
		end

		v14.Opens += 1
	end

	screen = openedFrames[#openedFrames] or "None"

	if screen ~= v11 then
		v12 = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsFlushDue()
	local v14 = os.clock() - now2
	return analytics.ClientFlushInterval <= v14 or v12 and analytics.ClientMinimumInterval <= v14
end

local function Flush()
	local now3 = os.clock()
	local v14 = analytics.ClientFlushInterval * 2
	local v15 = {}

	if not v13 then
		v13 = true
		table.insert(v15, {
			Kind = "Ready",
			Platform = module.Platform or "Computer"
		})
	end

	for k, v16 in v3 do
		local v17 = v2[k]

		if not v17 then
			v17 = {
				Opens = 0,
				Seconds = 0
			}
			v2[k] = v17
		end

		v17.Seconds += now3 - v16
		v3[k] = now3
	end

	for k, v16 in v2 do
		if #v15 >= analytics.ClientBatchSize - 2 then
			break
		end

		table.insert(v15, {
			Kind = "Screen",
			Screen = k,
			Opens = math.min(v16.Opens, analytics.MaximumScreenOpens),
			Seconds = math.min(math.floor(v16.Seconds), v14)
		})
		v2[k] = nil
	end

	if total > 0 then
		table.insert(v15, {
			Kind = "Idle",
			Seconds = math.min(total, v14)
		})
		total = 0
	end

	if screen ~= v11 then
		v11 = screen
		table.insert(v15, {
			Kind = "State",
			Screen = screen
		})
	end

	for k, v16 in v4 do
		if #v15 >= analytics.ClientBatchSize then
			break
		end

		table.insert(v15, {
			Kind = "Dialog",
			Npc = k,
			Count = math.min(v16, analytics.MaximumDialogs)
		})
		v4[k] = nil
	end

	local count3 = 0

	for k, count4 in v7 do
		if #v15 >= analytics.ClientBatchSize - 1 or analytics.MaximumErrorSystems <= count3 then
			break
		end

		count3 += 1
		table.insert(v15, {
			Kind = "Error",
			System = k,
			Count = count4
		})
		v7[k] = nil
	end

	for k, v16 in v8 do
		if #v15 >= analytics.ClientBatchSize - 1 then
			break
		end

		table.insert(v15, v16)
		v8[k] = nil
	end

	for k in v6 do
		if #v15 >= analytics.ClientBatchSize - 1 then
			break
		end

		table.insert(v15, {
			Kind = "Upsell",
			Resource = k
		})
		v6[k] = nil
	end

	for k, v16 in v5 do
		if k == v9 then
			continue
		end

		if #v15 >= analytics.ClientBatchSize - 1 then
			break
		end

		table.insert(v15, v16)
		v5[k] = nil
	end

	if v9 and v5[v9] and #v15 < analytics.ClientBatchSize then
		table.insert(v15, v5[v9])
		v5[v9] = nil
		v9 = nil
	end

	if #v15 == 0 then
		return
	end

	module.Signal:Fire("General", "Analytics", "Track", v15)
end

local Analytics = {}

function Analytics.TrackDialog(value: string)
	if not flag or typeof(value) ~= "string" then
		return
	end

	v4[value] = (v4[value] or 0) + 1
end

function Analytics.TrackShop(origin: string, value2: string)
	if not flag or typeof(origin) ~= "string" or typeof(value2) ~= "string" then
		return
	end

	local formatted = `{origin}|{value2}`
	local v14 = v5[formatted]

	if not v14 then
		v14 = {
			Kind = "Shop",
			Origin = origin,
			Section = value2,
			Count = 0
		}
		v5[formatted] = v14
	end

	v14.Count = math.min(v14.Count + 1, analytics.MaximumScreenOpens)
	v9 = formatted
	v12 = true
end

function Analytics.TrackUpsell(value: string)
	if not flag or typeof(value) ~= "string" then
		return
	end

	v6[value] = true
	v12 = true
end

function Analytics.Destroy()
	flag = false
	count2 += 1

	if thread then
		task.cancel(thread)
		thread = nil
	end

	if thread2 then
		task.cancel(thread2)
		thread2 = nil
	end

	if thread3 then
		task.cancel(thread3)
		thread3 = nil
	end

	for _, connection in v do
		connection:Disconnect()
	end

	table.clear(v)
	table.clear(v2)
	table.clear(v3)
	table.clear(v4)
	table.clear(v5)
	table.clear(v6)
	table.clear(v7)
	table.clear(v8)
	v9 = nil
	total = 0
	v12 = false
end

function Analytics.Init()
	if flag then
		return
	end

	flag = true
	count2 += 1
	local v14 = count2
	v.Frames = module.Frame.FramesChangedSignal:Connect(RefreshFrames)
	v.InputBegan = module.Services.UserInputService.InputBegan:Connect(MarkInput)
	v.InputChanged = module.Services.UserInputService.InputChanged:Connect(MarkInput)
	v.ScriptError = ScriptContext.Error:Connect(TrackError)
	v.Rendered = module.Services.RunService.RenderStepped:Connect(function()
		count += 1
	end)
	RefreshFrames()
	thread2 = task.defer(function()
		while flag and count2 == v14 do
			task.wait(analytics.IdleCheckInterval)

			if os.clock() - lastTime >= analytics.IdleThreshold then
				total += analytics.IdleCheckInterval
			end
		end
	end)
	thread3 = task.defer(function()
		while module.Instance:GetAttribute("Loaded") ~= true do
			module.Instance:GetAttributeChangedSignal("Loaded"):Wait()
		end

		count = 0
		now = os.clock()

		while flag and count2 == v14 do
			task.wait(analytics.ClientPerfInterval)
			local success, result = pcall(SamplePerf)

			if not success then
				warn((`[ANALYTICS]: Client performance sample failed: {result}`))
			end
		end
	end)
	thread = task.defer(function()
		while module.Instance:GetAttribute("Loaded") ~= true do
			module.Instance:GetAttributeChangedSignal("Loaded"):Wait()
		end

		while flag and count2 == v14 do
			local success, result = pcall(Flush)

			if not success then
				warn((`[ANALYTICS]: Client flush failed: {result}`))
			end

			now2 = os.clock()
			v12 = false

			while flag and count2 == v14 do
				if IsFlushDue() then
					break
				else
					task.wait(analytics.ClientPollInterval)
				end
			end
		end
	end)
end

return Analytics