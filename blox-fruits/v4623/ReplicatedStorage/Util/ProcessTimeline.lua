local LogService = game:GetService("LogService")
local Display = require(game.ReplicatedStorage.Packages.Display)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local v = {
	FATAL = 5,
	ERROR = 4,
	WARN = 3,
	INFO = 2,
	TRACE = 1
}
local v2 = {
	function(p: string)
		LogService:Output(p)
	end,
	function(p: string)
		LogService:Info(p)
	end,
	function(p: string)
		LogService:Warn(p)
	end,
	function(p: string)
		pcall(function()
			LogService:Error(p)
		end)
	end,
	function(p: string)
		pcall(function()
			LogService:Error(p)
		end)
	end
}
local v3 = Display.JSON.new():setSortKeys(true):setIndentWith("  "):build()
local class = {}
class.__index = class

function class:display(callback, p2, p3: number?)
	local v4 = p2 or v3
	assert(v4, "bad formatter")
	local _Logs = {}
	local copies = {}

	for _, _Log in self._Logs do
		local copy = TableUtil.deepCopy(_Log)
		local v5

		if #_Logs > 0 then
			v5 = _Logs[#_Logs].Tick
		else
			v5 = self._Start
		end

		copy.Delta.Prior = copy.Tick - v5

		if #_Logs == 0 then
			copy.Delta.Prior = 1e999
		end

		if callback then
			copy = callback(copy)
		end

		if copy == nil then
			continue
		end

		table.insert(copies, copy)
		table.insert(_Logs, _Log)
	end

	return v4:display(copies, p3)
end

function class:output(callback)
	local _Logs = {}

	for k, _Log in self._Logs do
		if k % 1000 == 0 then
			task.wait()
		end

		local copy = TableUtil.deepCopy(_Log)
		local v4

		if #_Logs > 0 then
			v4 = _Logs[#_Logs].Tick
		else
			v4 = self._Start
		end

		copy.Delta.Prior = copy.Tick - v4

		if #_Logs == 0 then
			copy.Delta.Prior = 1e999
		end

		local message

		if callback then
			message = callback(copy)
		else
			message = copy.Message
		end

		if message == nil then
			continue
		end

		local v5 = v2[copy.Level]
		assert(v5, (`unknown level "{copy.Level}"`))
		table.insert(_Logs, _Log)
		v5(message)
	end

	return #_Logs
end

function class:prepReport(callback)
	local v4 = {}
	local messages = {}

	for _, _Log in self._Logs do
		local copy = TableUtil.deepCopy(_Log)
		local v5

		if #v4 > 0 then
			v5 = v4[#v4].Tick
		else
			v5 = self._Start
		end

		copy.Delta.Prior = copy.Tick - v5

		if #v4 == 0 then
			copy.Delta.Prior = 1e999
		end

		local message

		if callback then
			message = callback(copy)
		else
			message = copy.Message
		end

		if message ~= nil then
			table.insert(messages, message)
		end
	end

	return messages
end

function class:log(message: string, p2: string?)
	local _Index = self._Index
	self._Index += 1
	local now = tick()
	local v4

	if #self._Logs > 0 then
		v4 = self._Logs[#self._Logs].Tick
	else
		v4 = self._Start
	end

	local v5 = {
		Id = _Index,
		Message = message,
		Tick = now,
		UTC = os.time(),
		Delta = {
			Start = now - self._Start,
			Prior = now - v4
		},
		Level = 0
	}
	local v6

	if p2 then
		v6 = v[p2]
	end

	v5.Level = v6 or 2
	TableUtil.deepFreeze(v5)
	table.insert(self._Logs, v5)
	return v5
end

function class:reset()
	self._Start = tick()
	table.clear(self._Logs)
end

local ProcessTimeline = {}
ProcessTimeline.LOG_LEVELS = v

function ProcessTimeline.log(p: string, p2: string)
	v2[v[p2]](p)
end

function ProcessTimeline.new()
	return (setmetatable({
		_Index = 0,
		_Start = tick(),
		_Logs = {}
	}, class))
end

return ProcessTimeline