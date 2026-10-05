local RunService = game:GetService("RunService")
local Keys = require(game.ReplicatedStorage.UserGenerated.Lang.Keys)
local Asserts = require(game.ReplicatedStorage.UserGenerated.Lang.Asserts)
local Stringify = require(game.ReplicatedStorage.UserGenerated.Strings.Stringify)
local v = {
	Pretty = true,
	IndentChar = " ",
	IndentSize = 2
}

local function GetPrefix(value: number?)
	local v2, v3, v4 = debug.info((value or 0) + 2, "sln")
	local formatted = `{v2}:{v3}`

	if v4 then
		formatted ..= ` {v4}`
	end

	return (`[{formatted}]`)
end

local function Format(value)
	if type(value) == "string" then
		return value
	end

	if typeof(value) == "Instance" then
		return (`{value.ClassName}[{value:GetFullName()}]`)
	end

	return Stringify.Serialize(value, v)
end

local function FormatArgs(...)
	local values = table.pack(...)

	for i = 1, values.n do
		local serialized = values[i]

		if type(serialized) ~= "string" then
			if typeof(serialized) == "Instance" then
				serialized = `{serialized.ClassName}[{serialized:GetFullName()}]`
			else
				serialized = Stringify.Serialize(serialized, v)
			end
		end

		values[i] = serialized
	end

	return table.unpack(values)
end

local print2, warn2

if RunService:IsStudio() then
	print2 = print
	warn2 = warn
else
	print2 = function(...)
		local function fn(p, ...)
			print(p, FormatArgs(...))
		end

		local v2, v3, v4 = debug.info(2, "sln")
		local formatted = `{v2}:{v3}`

		if v4 then
			formatted ..= ` {v4}`
		end

		task.spawn(fn, `[{formatted}]`, ...)
	end

	warn2 = function(...)
		local function fn(p, ...)
			warn(p, FormatArgs(...))
		end

		local v2, v3, v4 = debug.info(2, "sln")
		local formatted = `{v2}:{v3}`

		if v4 then
			formatted ..= ` {v4}`
		end

		task.spawn(fn, `[{formatted}]`, ...)
	end
end

local function fn() end

local levels = {
	Trace = 1,
	Debug = 2,
	Info = 3,
	Warn = 4,
	Error = 5,
	Critical = 6,
	Off = 7
}
table.freeze(levels)
local v3 = {
	Trace = print2,
	Debug = print2,
	Info = print2,
	Warn = warn2,
	Error = warn2,
	Critical = warn2,
	Off = fn
}
table.freeze(v3)
local callback = Asserts.Set(Keys(levels))
local clone = table.clone(v3)
local v4 = "Info"

local function SetLevel(p: string, flag: boolean?)
	assert(levels[p])
	assert(flag == nil or type(flag) == "boolean")

	if v4 == p and not flag then
		return
	end

	v4 = p
	local v5 = assert(levels[p])

	for k, v6 in pairs(levels) do
		if v5 <= v6 then
			clone[k] = v3[k]
		else
			clone[k] = fn
		end
	end
end

SetLevel(v4, true)
local v5 = {
	Levels = levels,
	AssertLevel = callback
}
setmetatable(v5, {
	__index = clone
})

function v5.GetLevel()
	return v4
end

function v5.SetLevel(p: string)
	SetLevel(p)
end

function v5.Sink(p: string)
	return assert(clone[p])
end

return table.freeze(v5)