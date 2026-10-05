local LogService = game:GetService("LogService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TableUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.TableUtils)
local LoggerManager = {}
local v = {}

local function formatArguments(...)
	local v2 = select("#", ...)
	local v3 = table.create(v2, "")

	for i = 1, v2 do
		v3[i] = tostring((select(i, ...)))
	end

	return table.concat(v3, "\t")
end

local function applyPrefix(p: string?, p2: string)
	if p and p ~= "" then
		return (`[{p}] {p2}`)
	end

	return p2
end

local class = {}
class.__index = class

function class.new(prefix: string?, context)
	return (setmetatable({
		prefix = prefix,
		context = context
	}, class))
end

function class.log(p, p2, p3: string, items)
	local context = p.context

	if items then
		context = TableUtils.Copy(p.context, true)

		for k, item in items do
			context[k] = item
		end
	end

	local prefix = p.prefix

	if prefix and prefix ~= "" then
		p3 = `[{prefix}] {p3}`
	end

	LogService:Log(p2, p3, context)
end

function class.print(p, ...)
	p.log(p, Enum.MessageType.MessageOutput, formatArguments(...))
end

function class.output(p, ...)
	p.log(p, Enum.MessageType.MessageOutput, formatArguments(...))
end

function class.info(p, ...)
	p.log(p, Enum.MessageType.MessageInfo, formatArguments(...))
end

function class.warn(p, ...)
	p.log(p, Enum.MessageType.MessageWarning, formatArguments(...))
end

function class.error(p, ...)
	p.log(p, Enum.MessageType.MessageError, formatArguments(...))
end

function LoggerManager.createLogger(p: string?, p2)
	local v2 = class.new(p, p2)
	table.insert(v, v2)
	return v2
end

function LoggerManager.getAllLoggers()
	return v
end

return LoggerManager