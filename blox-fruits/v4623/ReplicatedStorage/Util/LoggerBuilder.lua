local RunService = game:GetService("RunService")
local Display = require(game.ReplicatedStorage.Packages.Display)
local RunTimeline = require(game.ReplicatedStorage.RunTimeline)
local BuildInfo = require(game.ReplicatedStorage.BuildInfo)
local ProcessTimeline = require(game.ReplicatedStorage.Util.ProcessTimeline)
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()
local isStudio = RunService:IsStudio()
local v = isServer and "SRV" or "CLI"

if (BuildInfo.CORE_BRANCH ~= "live" or isStudio) and not GlobalUtil.FFlags.IsSandboxed and RunService:IsRunning() then
	while not RunTimeline.IsInitialized do
		task.wait()
	end
end

local count = 0

function newConfig(data)
	local tags

	if data and data.Tags then
		tags = table.clone(data.Tags)
	end

	return {
		Tags = tags,
		TracebackLevel = data and data.TracebackLevel,
		MinLevel = data and data.MinLevel,
		DisableCondition = data and data.DisableCondition,
		Display = data and data.Display,
		Prefix = data and data.Prefix
	}
end

function getTraceInfo(p: number)
	local source, lineNumber = debug.info(p, "sl")

	if source == nil then
		return nil
	end

	return {
		Source = source,
		LineNumber = lineNumber
	}
end

function _dumpTrace(p: number, p2: number)
	local v2 = p + 1
	local traceInfo = getTraceInfo(v2)
	local traceInfos = {}

	while traceInfo do
		traceInfos[v2 - p] = traceInfo
		v2 += 1

		if p2 < v2 then
			break
		else
			traceInfo = getTraceInfo(v2)
		end
	end

	return traceInfos
end

function freezeConfig(list)
	table.freeze(list)

	if list.Tags then
		table.freeze(list.Tags)
	end
end

local class = {}
class.__index = class

function newBuilder(config)
	if not config then
		config = newConfig()
		assert(config, "bad config")
		freezeConfig(config)
	end

	assert(config, "bad config")
	local self = setmetatable({
		_Config = config
	}, class)
	table.freeze(self)
	return self
end

function class:tag(p2: string)
	local v2 = newConfig(self._Config)
	local tags = v2.Tags or {}
	table.insert(tags, p2)
	v2.Tags = tags
	freezeConfig(v2)
	return newBuilder(v2)
end

function class:traceback(value: number?)
	local v2 = newConfig(self._Config)
	v2.TracebackLevel = value or 0
	freezeConfig(v2)
	return newBuilder(v2)
end

function class:minLevel(p2)
	local v2 = newConfig(self._Config)
	v2.MinLevel = ProcessTimeline.LOG_LEVELS[p2]
	freezeConfig(v2)
	return newBuilder(v2)
end

function class:display(p2)
	local v2 = newConfig(self._Config)
	v2.Display = p2 or Display.JSON.new():build()
	freezeConfig(v2)
	return newBuilder(v2)
end

function class:prefix(prefix: string, _: boolean?)
	local v2 = newConfig(self._Config)
	v2.Prefix = prefix
	freezeConfig(v2)
	return newBuilder(v2)
end

function class:disable(callback)
	local v2 = newConfig(self._Config)
	v2.DisableCondition = callback or function()
		return true
	end
	freezeConfig(v2)
	return newBuilder(v2)
end

function class:build()
	local v2 = {}
	local display = self._Config.Display
	local prefix = self._Config.Prefix
	local clone

	if self._Config.Tags then
		clone = table.clone(self._Config.Tags)
	else
		clone = nil
	end

	if clone then
		if isServer then
			table.insert(clone, "Server")
		end

		if isClient then
			table.insert(clone, "Client")
		end
	end

	local tracebackLevel

	if self._Config.TracebackLevel then
		tracebackLevel = self._Config.TracebackLevel
	else
		tracebackLevel = nil
	end

	local disableCondition = self._Config.DisableCondition
	local minLevel = self._Config.MinLevel or 0

	local function toStr(value)
		if type(value) == "string" then
			return value
		end

		if display then
			return (display:display(value))
		end

		return (`{value}`)
	end

	local toStrTuple

	toStrTuple = function(...)
		local v3 = table.pack(...)

		if v3.n == 1 then
			local v4 = v3[1]

			if type(v4) == "function" then
				return toStrTuple(v4())
			end

			if type(v4) ~= "string" then
				if display then
					return (display:display(v4))
				else
					return (`{v4}`)
				end
			end

			return v4
		else
			local v4 = table.create(v3.n)

			for i = 1, v3.n do
				local v5 = v3[i]

				if type(v5) ~= "string" then
					if display then
						v5 = display:display(v5)
					else
						v5 = `{v5}`
					end
				end

				table.insert(v4, v5)
			end

			return table.concat(v4, ", ")
		end
	end

	local function trace(p2: string)
		if not tracebackLevel then
			return (`{prefix or ""}|{p2}`)
		end

		local traceInfo = getTraceInfo(4 + tracebackLevel)

		if traceInfo then
			return (`{traceInfo.Source:gsub("ServerScriptService%.", "SerScr."):gsub("ReplicatedStorage%.", "RepSto.")}:{traceInfo.LineNumber}|{prefix or ""}|{p2}`)
		end

		return (`{prefix or ""}|{p2}`)
	end

	function v2.info(...)
		if RunTimeline.IsInitialized == true and RunTimeline.IsEnabled and (disableCondition == nil or disableCondition() == false) and math.max(
			RunTimeline.LevelFilter,
			minLevel
		) <= ProcessTimeline.LOG_LEVELS.INFO then
			local formatted = `{v}|INFO|{trace(toStrTuple(...))}`

			if GlobalUtil.FFlags.IsUnitTest then
				print(formatted)
			end

			RunTimeline:Log(formatted, clone, "INFO")
		end
	end

	function v2.warn(...)
		if RunTimeline.IsInitialized == true and RunTimeline.IsEnabled and (disableCondition == nil or disableCondition() == false) and math.max(
			RunTimeline.LevelFilter,
			minLevel
		) <= ProcessTimeline.LOG_LEVELS.WARN then
			local formatted = `{v}|WARN|{trace(toStrTuple(...))}`

			if GlobalUtil.FFlags.IsUnitTest then
				print(formatted)
			end

			if isStudio then
				ProcessTimeline.log(formatted, "WARN")
			end

			RunTimeline:Log(formatted, clone, "WARN")
		end
	end

	function v2.error(...)
		if RunTimeline.IsInitialized == true and RunTimeline.IsEnabled and (disableCondition == nil or disableCondition() == false) and math.max(
			RunTimeline.LevelFilter,
			minLevel
		) <= ProcessTimeline.LOG_LEVELS.ERROR then
			local formatted = `{v}|ERROR|{trace(toStrTuple(...))}`

			if GlobalUtil.FFlags.IsUnitTest then
				print(formatted)
			end

			ProcessTimeline.log(formatted, "ERROR")
			RunTimeline:Log(formatted, clone, "ERROR")
		end
	end

	function v2.fatal(...)
		if RunTimeline.IsInitialized == true and RunTimeline.IsEnabled and (disableCondition == nil or disableCondition() == false) and math.max(
			RunTimeline.LevelFilter,
			minLevel
		) <= ProcessTimeline.LOG_LEVELS.ERROR then
			local formatted = `{v}|FATAL|{trace(toStrTuple(...))}`

			if GlobalUtil.FFlags.IsUnitTest then
				print(formatted)
			end

			ProcessTimeline.log(formatted, "FATAL")
			RunTimeline:Log(formatted, clone, "FATAL")
		end
	end

	function v2.trace(...)
		if RunTimeline.IsInitialized == true and RunTimeline.IsEnabled and (disableCondition == nil or disableCondition() == false) and math.max(
			RunTimeline.LevelFilter,
			minLevel
		) <= ProcessTimeline.LOG_LEVELS.TRACE then
			local formatted = `{v}|TRACE|{trace(toStrTuple(...))}`

			if GlobalUtil.FFlags.IsUnitTest then
				print(formatted)
			end

			RunTimeline:Log(formatted, clone, "TRACE")
		end
	end

	function v2.extend(p2: string?, flag: boolean?, p3, items)
		if flag ~= false then
			count += 1
			local v3 = count

			if self._Config.Prefix then
				if p2 then
					p2 ..= ` #{v3}`
				else
					p2 = `#{v3}`
				end
			elseif self._Config.Prefix == nil then
				if p2 then
					p2 ..= ` #{v3}`
				else
					p2 = `#{v3}`
				end
			end
		end

		local v3 = newConfig(self._Config)
		local v4 = math.max(p3 and ProcessTimeline.LOG_LEVELS[p3] or ProcessTimeline.LOG_LEVELS.TRACE, minLevel)
		local v5 = nil

		for k, v7 in ProcessTimeline.LOG_LEVELS do
			if v7 ~= v4 then
				continue
			end

			v5 = k
			break
		end

		assert(v5, (`no matching log level found for {v4}`))

		if items then
			v3.Tags = v3.Tags or {}
			assert(v3.Tags, "bad tags")

			for _, item in items do
				table.insert(v3.Tags, item)
			end
		end

		if not p2 then
			return (newBuilder(v3):minLevel(v5):build())
		end

		local v7 = newBuilder(v3)

		if self._Config.Prefix then
			p2 = self._Config.Prefix .. ">" .. p2
		end

		return (v7:prefix(p2):minLevel(v5):build())
	end

	return v2
end

local LoggerBuilder = {
	new = function()
		return newBuilder()
	end,
	output = function(p, p2, callback)
		assert(RunTimeline.IsInitialized, "bad RunTimeline")
		return RunTimeline:Output(p, p2, callback)
	end,
	prepReport = function(p, p2, callback)
		assert(RunTimeline.IsInitialized, "bad RunTimeline")
		return RunTimeline:PrepReport(p, p2, callback)
	end,
	GET_CLIENT_LOGS_KEY = "GetClientLogs",
	GET_TAG_COUNT_KEY = "GetTagCount"
}

function LoggerBuilder.runCommand(data, callback, value: number?)
	local after = data.after
	local before = data.before
	local levelValue = data.levelValue
	local timestamp = data.timestamp
	local elapsed = data.elapsed
	local reportMsg = data.reportMsg
	local includedTags = data.includedTags
	local excludedTags = data.excludedTags
	local count2 = 0

	local function transformer(data2)
		if after and data2.UTC <= after.UnixTimestamp or before and data2.UTC >= before.UnixTimestamp or levelValue and data2.Level < levelValue then
			return nil
		end

		count2 += 1
		local v2 = { data2.Message }

		if timestamp then
			table.insert(v2, 1, DateTime.fromUnixTimestampMillis(data2.UTC * 1000):ToIsoDate())
		end

		if elapsed then
			table.insert(v2, 1, (`+{math.round(data2.Delta.Prior * 100000) / 100}ms`))
		end

		return table.concat(v2, "|")
	end

	if reportMsg then
		local prepReport = LoggerBuilder.prepReport

		if #includedTags == 0 then
			includedTags = nil
		end

		if #excludedTags == 0 then
			excludedTags = nil
		end

		local v2 = prepReport(includedTags, excludedTags, transformer)

		if callback then
			callback((`successfully dumped #{count2 + (value or 0)} logs`))
		end

		return v2, #v2
	else
		local output = LoggerBuilder.output

		if #includedTags == 0 then
			includedTags = nil
		end

		if #excludedTags == 0 then
			excludedTags = nil
		end

		local v2 = output(includedTags, excludedTags, transformer)

		if callback then
			callback((`successfully dumped #{count2 + (value or 0)} logs`))
		end

		return nil, v2
	end
end

return LoggerBuilder