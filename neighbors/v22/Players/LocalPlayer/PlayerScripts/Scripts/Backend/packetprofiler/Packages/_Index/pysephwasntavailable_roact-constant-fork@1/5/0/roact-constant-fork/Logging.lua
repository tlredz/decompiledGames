local v = true
local v2 = {}
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function indent(value, count)
	local v4 = ("\t"):rep(count)
	return v4 .. value:gsub("\n", "\n" .. v4)
end

local function indentLines(list, count)
	local v4 = {}

	for _, v5 in ipairs(list) do
		table.insert(v4, indent(v5, count))
	end

	return table.concat(v4, "\n")
end

local v4 = {
	__tostring = function(data)
		local v5 = { "LogInfo {" }
		local count = #data.errors
		local count2 = #data.warnings
		local count3 = #data.infos

		if count + count2 + count3 == 0 then
			table.insert(v5, "\t(no messages)")
		end

		if count > 0 then
			table.insert(v5, ("\tErrors (%d) {"):format(count))
			table.insert(v5, indentLines(data.errors, 2))
			table.insert(v5, "\t}")
		end

		if count2 > 0 then
			table.insert(v5, ("\tWarnings (%d) {"):format(count2))
			table.insert(v5, indentLines(data.warnings, 2))
			table.insert(v5, "\t}")
		end

		if count3 > 0 then
			table.insert(v5, ("\tInfos (%d) {"):format(count3))
			table.insert(v5, indentLines(data.infos, 2))
			table.insert(v5, "\t}")
		end

		table.insert(v5, "}")
		return table.concat(v5, "\n")
	end
}

local function createLogInfo()
	local v5 = {
		errors = {},
		warnings = {},
		infos = {}
	}
	setmetatable(v5, v4)
	return v5
end

local Logging = {
	capture = function(callback)
		local logInfo = createLogInfo()
		local v5 = v
		v = false
		v2[logInfo] = true
		local success, result = pcall(callback)
		v2[logInfo] = nil
		v = v5
		assert(success, result)
		return logInfo
	end,
	warn = function(value, ...)
		local formatted = value:format(...)

		for k in pairs(v2) do
			table.insert(k.warnings, formatted)
		end

		local formatted2 = ("%s\n%s"):format(formatted, indent(debug.traceback("", 2):sub(2), 1))

		if v then
			warn(formatted2)
		end
	end
}

function Logging.warnOnce(p, ...)
	local traceback = debug.traceback()

	if v3[traceback] then
		return
	end

	v3[traceback] = true
	Logging.warn(p, ...)
end

return Logging