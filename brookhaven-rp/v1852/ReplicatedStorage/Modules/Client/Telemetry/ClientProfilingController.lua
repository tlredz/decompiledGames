local ClientProfilingController = {}
local Stats = game:GetService("Stats")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Math = require(ReplicatedStorage.Modules.Shared.Math)
local ClientProfilingConstants = require(ReplicatedStorage.Modules.Shared.Telemetry.ClientProfilingConstants)
local thread = nil
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function append(state, p: number)
	state.sum += p
	state.amount += 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getAverage(p)
	return p.sum / p.amount
end

local function getStability(list)
	table.sort(list)
	local total = 0
	local total2 = 0

	for _, v2 in list do
		total += v2
		total2 += v2 * v2
	end

	local v2 = total / #list
	local v3 = math.sqrt(total2 / #list - v2 * v2)
	local v4 = math.ceil(#list * 0.01)
	local v5 = math.ceil(#list * 0.001)
	return {
		mean = Math.round(v2, 4),
		stdDev = Math.round(v3, 4),
		min = Math.round(list[1], 4),
		max = Math.round(list[#list], 4),
		p1Low = Math.round(list[v4], 4),
		p01Low = Math.round(list[v5], 4)
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function newRecordData()
	return {
		sum = 0,
		amount = 0
	}
end

local function newProfilingData()
	return {
		startTime = tick(),
		frameTimePoints = {},
		memoryPoints = {},
		avgFrameTime = newRecordData(),
		avgCPURenderTime = newRecordData(),
		avgGPURenderTime = newRecordData(),
		avgTotalMemory = newRecordData()
	}
end

local function profilingLoop()
	while RunService:IsRunning() do
		local v2 = {}

		for k, v3 in v do
			if tick() - v3.startTime > 180 then
				table.insert(v2, k)
			else
				if #v3.frameTimePoints >= 180 then
					table.remove(v3.frameTimePoints, 1)
				end

				table.insert(v3.frameTimePoints, Stats.FrameTime)

				if #v3.memoryPoints >= 180 then
					table.remove(v3.memoryPoints, 1)
				end

				table.insert(v3.memoryPoints, Stats:GetTotalMemoryUsageMb())
				append(v3.avgFrameTime, Stats.FrameTime) -- equivalent call inferred; original call site unknown
				append(v3.avgCPURenderTime, Stats.RenderCPUFrameTime) -- equivalent call inferred; original call site unknown
				append(v3.avgGPURenderTime, Stats.RenderGPUFrameTime) -- equivalent call inferred; original call site unknown
				append(v3.avgTotalMemory, Stats:GetTotalMemoryUsageMb()) -- equivalent call inferred; original call site unknown
			end
		end

		for _, v3 in v2 do
			print("Profiling data for " .. v3 .. " has naturally expired")
			task.defer(ClientProfilingController.Stop, v3)
		end

		task.wait(1)
	end
end

function ClientProfilingController.Start(p: string)
	assert(v[p] == nil, "Profiling data for " .. p .. " already exists")
	v[p] = newProfilingData()

	if thread == nil then
		thread = task.spawn(profilingLoop)
	end
end

function ClientProfilingController.Stop(identifier: string)
	assert(v[identifier] ~= nil, "Profiling data for " .. identifier .. " does not exist")
	local v2 = v[identifier]
	v[identifier] = nil

	if thread ~= nil and TableUtil.IsEmpty(v) then
		task.cancel(thread)
		thread = nil
	end

	local v3 = ClientProfilingConstants.MinimumIdentifierDuration[identifier] or 0
	local rounded = Math.round(tick() - v2.startTime, 4)

	if rounded < v3 then
		return
	end

	task.spawn(function()
		Remotes.fireServer("ClientProfiling:SendData", {
			identifier = identifier,
			duration = rounded,
			frameTimeStability = getStability(v2.frameTimePoints),
			memoryStability = getStability(v2.memoryPoints),
			avgFrameTime = Math.round(getAverage(v2.avgFrameTime), 4),
			avgCPURenderTime = Math.round(getAverage(v2.avgCPURenderTime), 4),
			avgGPURenderTime = Math.round(getAverage(v2.avgGPURenderTime), 4),
			avgTotalMemory = Math.round(getAverage(v2.avgTotalMemory), 4)
		})
	end)
end

return ClientProfilingController