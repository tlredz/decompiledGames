local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local RunService2 = game:GetService("RunService")
local isStudio = RunService2:IsStudio()
local AnalyticsService = game:GetService("AnalyticsService")
local HttpService = game:GetService("HttpService")
local analyticsLogLevel = Enum.AnalyticsLogLevel
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer

if isServer then
	localPlayer = nil
else
	localPlayer = Players.LocalPlayer or nil
end

local log = script:FindFirstAncestor("Packages").Configs:FindFirstChild("Log")
local module = log and require(log) or "Debug"
local Stringify = require(ReplicatedStorage.UserGenerated.Strings.Stringify)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage2:WaitForChild("Packages"):WaitForChild("t"))
local TryCall = require(ReplicatedStorage.Shared.Utils.TryCall)
local v = nil
local clock = os.clock
local level = {
	Trace = analyticsLogLevel.Trace.Value,
	Debug = analyticsLogLevel.Debug.Value,
	Info = analyticsLogLevel.Information.Value,
	Warning = analyticsLogLevel.Warning.Value,
	Error = analyticsLogLevel.Error.Value,
	Fatal = analyticsLogLevel.Fatal.Value
}

local function ToSeconds(p: number, p2: number)
	if p2 == 0 then
		return p / 1000
	elseif p2 == 1 then
		return p
	elseif p2 == 2 then
		return p * 60
	elseif p2 == 3 then
		return p * 3600
	elseif p2 == 4 then
		return p * 86400
	elseif p2 == 5 then
		return p * 604800
	elseif p2 == 6 then
		return p * 2592000
	elseif p2 == 7 then
		return p * 31536000
	end

	error("Unknown time unit", 2)
end

local function GetPlayerFromCustomData(p)
	local player = type(p) == "table" and (p.Player or p.PlayerId)

	if not player then
		return nil
	end

	local Players2 = game:GetService("Players")
	return Players2:GetPlayerByUserId(player)
end

local fn = isStudio and function(_: number, _: string, _: string, _) end or function(p: number, p2: string, stackTrace: string, p4)
	local success, result = pcall(function()
		local playerByUserId = localPlayer

		if not playerByUserId then
			local v3 = p4

			if type(v3) == "table" then
				local player = v3.Player or v3.PlayerId

				if player then
					local Players2 = game:GetService("Players")
					playerByUserId = Players2:GetPlayerByUserId(player)
				else
					playerByUserId = nil
				end
			else
				playerByUserId = nil
			end
		end

		AnalyticsService:FireLogEvent(playerByUserId, p, p2, {
			stackTrace = stackTrace
		}, p4)
	end)

	if not success then
		warn(result)
	end
end
local class = {}
class.__index = class

function class.new(log2, levelName: string, traceback: string, p4: string, muted: boolean?)
	return (setmetatable({
		_muted = muted,
		_log = log2,
		_traceback = traceback,
		_levelName = levelName,
		_modifiers = {
			Throw = false
		},
		_key = p4
	}, class))
end

function class:_shouldLog(object)
	if self._modifiers.Every and not object:_checkAndIncrementCount(self._modifiers.Every) then
		return false
	end

	if self._modifiers.AtMostEvery and not object:_checkLastTimestamp(clock(), self._modifiers.AtMostEvery) then
		return false
	end

	return true
end

function class:Every(every: number)
	self._modifiers.Every = every
	return self
end

function class:AtMostEvery(p2: number, p3: number)
	self._modifiers.AtMostEvery = ToSeconds(p2, p3)
	return self
end

function class:Throw()
	self._modifiers.Throw = true
	return self
end

function class:Log(value, ...)
	if self._muted then
		return
	end

	local v3 = select("#", ...)
	local v4 = nil
	local v5

	if v3 == 1 then
		v5 = select(1, ...)
	else
		v5 = v3 > 1 and { ... } or v4
	end

	local _getLogStats = self._log:_getLogStats(self._key)
	local v6 = false

	if not self:_shouldLog(_getLogStats) then
		return
	end

	if type(value) == "function" then
		value, v5 = value()

		if v5 == nil then
		end
	elseif type(value) == "table" then
		local v7, v8 = TryCall(HttpService.JSONEncode, HttpService, value)

		if v7 and v8 then
			value = v8
		end
	end

	if not isStudio and self._log._settings.EnableStringRead and type(value) == "string" and type(v5) == "table" then
		local v7, v8 = TryCall(Stringify.Pretty, v5)

		if v7 and v8 then
			value ..= " " .. v8
			v6 = true
		end
	end

	_getLogStats:_setTimestamp(clock())
	local formatted = ("%s: [%s] %s"):format(self._log._name, self._levelName, value)
	local v7 = level[self._levelName]
	fn(v7, ("%s: %s"):format(self._log._name, value), self._traceback, v5)

	if self._modifiers.Throw then
		error(formatted .. ((not v5 or v6) and "" or " " .. HttpService:JSONEncode(v5) or ""), 4)
	elseif v7 < level.Warning then
		print(formatted, v6 and "" or v5 or "")
	else
		warn(formatted, v6 and "" or v5 or "")
	end
end

function class:SepLog(value: number?, value2: string?)
	t.strict(t.optional(t.string))(value2)
	t.strict(t.optional(t.number))(value)
	self:Log(string.rep(value2 or "-", value or 100))
end

function class:Wrap()
	return function(...)
		self:Log(...)
	end
end

function class:Assert(flag: boolean, ...)
	if flag then
		self:Throw():Log(...)
	end
end

local class2 = {}
class2.__index = class2
setmetatable(class2, class)

function class2.new(...)
	return (setmetatable(class.new(...), class2))
end

function class2:Log() end

local class3 = {}
class3.__index = class3

function class3.new()
	local self = setmetatable({}, class3)
	self._invocationCount = 0
	self._lastTimestamp = 0
	return self
end

function class3:_checkAndIncrementCount(p2: number)
	local v3 = self._invocationCount % p2 == 0
	self._invocationCount += 1
	return v3
end

function class3:_checkLastTimestamp(p2: number, p3: number)
	return p3 <= p2 - self._lastTimestamp
end

function class3:_setTimestamp(lastTimestamp: number)
	self._lastTimestamp = lastTimestamp
end

local Log = {}
Log.__index = Log
Log.TimeUnit = {
	Milliseconds = 0,
	Seconds = 1,
	Minutes = 2,
	Hours = 3,
	Days = 4,
	Weeks = 5,
	Months = 6,
	Years = 7
}
Log.Level = level
Log.LevelNames = {}

for k, v3 in pairs(Log.Level) do
	Log.LevelNames[v3] = k
end

function Log.new(options)
	t.strict(t.optional(t.table))(options)
	local self = setmetatable({}, Log)
	self._name = debug.info(2, "s"):match("([^%.]-)$")
	self._muted = false
	self._stats = {}
	self._settings = options or {}
	return self
end

function Log.getLevelFromName(p: string)
	t.strict(t.string)(p)
	return assert(Log.Level[p], (`Invalid log level: "{p}"`))
end

function Log.isWithinLevel(p: string)
	local levelFromName = Log.getLevelFromName(p)
	return v <= levelFromName, v
end

function Log:_getLogStats(p2)
	local _stat = self._stats[p2]

	if not _stat then
		_stat = class3.new()
		self._stats[p2] = _stat
	end

	return _stat
end

function Log:_at(p2)
	local v3, v4 = debug.info(3, "lf")
	local traceback = debug.traceback("Log", 3)
	local v5 = tostring(v3) .. tostring(v4)

	if p2 < (self._limitUnder or v) then
		return (class2.new(self, Log.LevelNames[p2], traceback, v5))
	end

	return class.new(self, Log.LevelNames[p2], traceback, v5, self._muted)
end

function Log:Mute()
	self._muted = true
	return self
end

function Log:UnMute()
	self._muted = false
	return self
end

function Log:LimitUnderLevel(p2: string)
	self._limitUnder = Log.getLevelFromName(p2)
	return self
end

function Log:At(p)
	return self:_at(p)
end

function Log:AtTrace()
	return self:_at(Log.Level.Trace)
end

function Log:AtDebug()
	return self:_at(Log.Level.Debug)
end

function Log:AtInfo()
	return self:_at(Log.Level.Info)
end

function Log:AtWarning()
	return self:_at(Log.Level.Warning)
end

function Log:AtError()
	return self:_at(Log.Level.Error)
end

function Log:AtFatal()
	return self:_at(Log.Level.Fatal)
end

function Log:Assert(p, ...)
	if not p then
		self:_at(Log.Level.Error):Throw():Log(...)
	end
end

function Log.Destroy(_) end

function Log:__tostring()
	return ("Log<%s>"):format(self._name)
end

local function SetLogLevel(value: string)
	local lower = value:lower()

	for k, v3 in pairs(Log.Level) do
		if k:lower() ~= lower then
			continue
		end

		if isStudio then
			local v4 = isServer and "LogLevel" or "LogLevelClient"
			local v5 = lower:sub(1, 1):upper() .. lower:sub(2)

			if tostring(workspace:GetAttribute(v4) or "") ~= v5 then
				workspace:SetAttribute(v4, v5)
			end
		end

		v = v3
		return
	end

	error("Unknown log level: " .. tostring(value))
end

local typeName = type(module)
assert(typeName == "table" or typeName == "string", "LogConfig must return a table or a string; got " .. typeName)

if typeName == "string" then
	SetLogLevel(module)
elseif isStudio and module.Studio then
	local typeName2 = type(module.Studio)
	assert(
		typeName2 == "table" or typeName2 == "string",
		"LogConfig.Studio must be a table or a string; got " .. typeName2
	)

	if typeName2 == "string" then
		SetLogLevel(module.Studio)
	elseif isServer then
		local server = module.Studio.Server
		assert(type(server) == "string", "LogConfig.Studio.Server must be a string; got " .. type(server))
		SetLogLevel(server)
	else
		local client = module.Studio.Client
		assert(type(client) == "string", "LogConfig.Studio.Client must be a string; got " .. type(client))
		SetLogLevel(client)
	end
else
	local v3 = false
	local v4 = nil
	local count = 0
	local v5 = nil

	for k, v6 in pairs(module) do
		if k == "Studio" then
			continue
		end

		if type(v6) == "string" then
			count += 1
			v5 = v6
		elseif type(v6) == "table" then
			local v7 = false
			local v8

			if type(v6.PlaceId) == "number" then
				v8 = v6.PlaceId == game.PlaceId
			elseif type(v6.PlaceIds) == "table" then
				v8 = table.find(v6.PlaceIds, game.PlaceId) ~= nil
			elseif type(v6.GameId) == "number" then
				v8 = v6.GameId == game.GameId
			elseif type(v6.GameIds) == "table" then
				v8 = table.find(v6.GameIds, game.GameId) ~= nil
			else
				v7 = true
				v8 = true
			end

			if not v7 then
				assert(not v3, ("More than one LogConfig mapping matched (%s and %s)"):format(v4 or "", k or ""))
			end

			if v8 then
				if isServer then
					local server = v6.Server
					assert(
						type(server) == "string",
						("LogConfig.%s.Server must be a string; got %s"):format(k, (type(server)))
					)
					SetLogLevel(server)
				else
					local client = v6.Client
					assert(
						type(client) == "string",
						("LogConfig.%s.Client must be a string; got %s"):format(k, (type(client)))
					)
					SetLogLevel(client)
				end

				v4 = k
				v3 = true
			end
		else
			warn(("LogConfig.%s must be a table or a string; got %s"):format(k, (typeof(v6))))
		end
	end

	if count > 1 then
		warn("Ambiguous default logging level")
	end

	if v5 and not v3 then
		SetLogLevel(v5)
	end
end

assert(type(v) == "number", "LogLevel failed to be determined")

if isStudio then
	local v3 = isServer and "LogLevel" or "LogLevelClient"
	workspace:GetAttributeChangedSignal(v3):Connect(function()
		SetLogLevel(workspace:GetAttribute(v3))
	end)
end

return Log