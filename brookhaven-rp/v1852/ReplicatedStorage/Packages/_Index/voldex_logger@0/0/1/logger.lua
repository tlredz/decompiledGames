local Logger = {}
local TableUtil = require(script.Parent.TableUtil)
local v = {
	{
		Name = "Debug",
		Emoji = "🐛"
	},
	{
		Name = "Trace",
		Emoji = "🔍"
	},
	{
		Name = "Info",
		Emoji = "ℹ️"
	},
	{
		Name = "Warn",
		Emoji = "⚠️"
	},
	{
		Name = "Error",
		Emoji = "❌"
	}
}
Logger.Levels = {
	Debug = 1,
	Trace = 2,
	Info = 3,
	Warn = 4,
	Error = 5
}
local v2 = {}

local function getSourceName(value: number?, flag: boolean?)
	local v3 = (value or 0) + 3
	local parts = debug.traceback():split("\n")
	local v4 = parts and v3 <= #parts and parts[v3]

	if not v4 then
		return "Unknown Source"
	end

	if not flag then
		local v5, v6 = v4:gsub(".*%.([_%w]+:%d+)%s*function%s*([_%w]+)", "%1 %2")

		if v6 > 0 then
			return v5
		end
	end

	for k in v4:gmatch("([_%w]+:%d+)") do
		if flag then
			k = k:gsub(":(%d+)", "") or k
		end

		return k
	end

	return "Unknown Source"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function assertLevel(p: number)
	local v3

	if p >= 1 then
		v3 = p <= 5
	else
		v3 = false
	end

	assert(v3, "Invalid level")
end

local function getLevel(value: number?)
	return v2[getSourceName((value or 0) + 1, true)] or 3
end

local function output(callback, p: number, ...)
	if p < (v2[getSourceName(2, true)] or 3) then
		return
	end

	if callback == error then
		local v3 = {}
		local emoji = v[p].Emoji
		local v5 = (1 or 0) + 3
		local parts = debug.traceback():split("\n")
		local v6 = parts and v5 <= #parts and parts[v5]
		local v7

		if v6 then
			local v8
			v7, v8 = v6:gsub(".*%.([_%w]+:%d+)%s*function%s*([_%w]+)", "%1 %2")

			if not (v8 > 0) then
				local flag = true

				for k in v6:gmatch("([_%w]+:%d+)") do
					v7 = k
					flag = false
					break
				end

				if flag then
					v7 = "Unknown Source"
				end
			end
		else
			v7 = "Unknown Source"
		end

		v3[1], v3[2], v3[3], v3[4], v3[5] = [[


]], emoji, v7, v[p].Emoji, "=>"
		table.insert(v3, TableUtil.ToString({ ... }))
		table.insert(v3, debug.traceback())
		error(table.concat(v3, " "))
	end

	local emoji = v[p].Emoji
	local v4 = (1 or 0) + 3
	local parts = debug.traceback():split("\n")
	local v5 = parts and v4 <= #parts and parts[v4]
	local v6

	if v5 then
		local v7
		v6, v7 = v5:gsub(".*%.([_%w]+:%d+)%s*function%s*([_%w]+)", "%1 %2")

		if not (v7 > 0) then
			local flag = true

			for k in v5:gmatch("([_%w]+:%d+)") do
				v6 = k
				flag = false
				break
			end

			if flag then
				v6 = "Unknown Source"
			end
		end
	else
		v6 = "Unknown Source"
	end

	callback(("%s %s %s =>"):format(emoji, v6, v[p].Emoji), ...)
end

function Logger.setLevel(p: number)
	assertLevel(p) -- equivalent call inferred; original call site unknown
	local v3 = v2
	local v4 = 0 + 3
	local parts = debug.traceback():split("\n")
	local v5 = parts and v4 <= #parts and parts[v4]
	local v6

	if v5 then
		local flag = true

		for k in v5:gmatch("([_%w]+:%d+)") do
			v6 = k:gsub(":(%d+)", "") or k
			flag = false
			break
		end

		if flag then
			v6 = "Unknown Source"
		end
	else
		v6 = "Unknown Source"
	end

	v3[v6] = p
end

function Logger.trace(...)
	output(print, Logger.Levels.Trace, ...)
end

function Logger.debug(...)
	output(print, Logger.Levels.Debug, ...)
end

function Logger.info(...)
	output(print, Logger.Levels.Info, ...)
end

function Logger.warn(...)
	output(warn, Logger.Levels.Warn, ...)
end

function Logger.error(...)
	output(error, Logger.Levels.Error, ..., "\n", debug.traceback())
end

return Logger