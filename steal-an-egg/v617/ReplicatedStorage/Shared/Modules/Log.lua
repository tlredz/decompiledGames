local RunService = game:GetService("RunService")
local v = {
	"fatal",
	"error",
	"warn",
	"info",
	"debug",
	"trace"
}
local v2 = {
	error = true,
	fatal = true
}
local Log = {}
local v3 = nil

local function discard() end

local function merged(p, options)
	local clone = table.clone(p)

	for k, v4 in options or {} do
		clone[k] = v4
	end

	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function describe(value)
	if typeof(value) == "Instance" then
		local parent = value.Parent
		return (`{parent and parent.Name or "?"}/{value.Name}`)
	end

	if typeof(value) == "string" then
		return value
	end

	return "UNKNOWN"
end

local function escalate(p, value: string?)
	local v4 = v2[p.level]

	if v4 then
		warn(debug.traceback(value or "a record was escalated without a headline"))
	end

	return v4
end

v3 = {
	__index = {
		log = function(data, level: string, message: string, options)
			if table.find(v, level) > table.find(v, data.threshold) then
				return
			end

			local bindings = data.bindings
			local clone = table.clone(bindings)
			local v4 = {
				level = level,
				message = message,
				context = 0
			}

			for k, v5 in options or {} do
				clone[k] = v5
			end

			v4.context = clone
			local success, result = pcall(data.emit, v4)

			if not success then
				warn((`the log sink raised while taking a record: {result}`))
			end
		end,
		extend = function(data, options)
			local v4 = {
				emit = data.emit,
				bindings = 0,
				threshold = 0
			}
			local bindings = data.bindings
			local clone = table.clone(bindings)

			for k, v5 in options or {} do
				clone[k] = v5
			end

			v4.bindings = clone
			v4.threshold = data.threshold
			return (setmetatable(v4, v3))
		end,
		setLevel = function(p, threshold: string)
			if table.find(v, threshold) == nil then
				error((`{threshold} is not a severity this logger knows`))
			end

			p.threshold = threshold
			return p
		end
	}
}

function Log.createLogger(emit, options)
	if typeof(emit) ~= "function" then
		emit = discard
	end

	return (setmetatable({
		emit = emit,
		bindings = options or {},
		threshold = "info"
	}, v3))
end

function Log.createDefaultCallback(value)
	local v4 = describe(value) -- equivalent call inferred; original call site unknown
	local isStudio = RunService:IsStudio()
	return function(data)
		local v5

		if isStudio then
			v5 = `[{v4}][{data.level}] {data.message}`
		else
			v5 = `[{v4}] {data.message}`
		end

		if isStudio and data.context then
			print(`[{v4}] bound context ->`, data.context)
		end

		local v6 = v2[data.level]

		if v6 then
			warn(debug.traceback(v5 or "a record was escalated without a headline"))
		end

		if v6 or not isStudio then
			return
		end

		local v7

		if data.level == "warn" then
			v7 = warn
		else
			v7 = print
		end

		v7(v5)
	end
end

return Log