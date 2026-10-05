local RunService = game:GetService("RunService")
local module = require("./arguments")
local module2 = require("./console")
local module3 = require("./state")
require("./types")
local isClient = RunService:IsClient()

-- equivalent calls inferred from this helper; original call sites unknown
local function output(p)
	module2.console.output(p)
end

local function concat(...)
	local v = { ... }

	for k, v2 in v do
		v[k] = tostring(v2)
	end

	return table.concat(v, " ")
end

local function print(...)
	output({
		kind = "normal",
		text = concat(...)
	}) -- equivalent call inferred; original call site unknown
end

local error

error = function(...)
	local text = concat(...)
	module2.console.output({
		kind = "error",
		text = text
	})
	error(text, 0)
end

local function warn(...)
	output({
		kind = "warn",
		text = concat(...)
	}) -- equivalent call inferred; original call site unknown
end

local function info(...)
	output({
		kind = "info",
		text = concat(...)
	}) -- equivalent call inferred; original call site unknown
end

if isClient then
	module2.register_command("license", {
		description = "Outputs the license to the console.",
		permissions = {},
		arguments = function() end,
		callback = function()
			for _, text in string.split([[
MIT License

Copyright (c) 2025 alicesays_hallo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.]], "\n") do
				module2.console.output({
					kind = "normal",
					text = text
				})
			end
		end
	})
end

return function()
	local function internal()
		print((`CONCH INTERNAL INFORMATION - {RunService:IsClient() and "CLIENT" or RunService:IsServer() and "SERVER" or "?"}`))
		print("")
		print("REGISTERED ROLES:")

		for k, list in module3.roles do
			print((`[{k}]: {table.concat(list, ", ")}`))
		end

		print("")
		print("REGISTERED COMMANDS")
	end

	local function set(p, p2, p3)
		p[p2] = p3
	end

	if isClient then
		module2.register_command("print", {
			permissions = {},
			description = "Converts the given arguments into a string and sends it to the output",
			arguments = function()
				return module.variadic(module.any("any", "Arguments to output"))
			end,
			callback = print
		})
		module2.register_command("sleep", {
			description = "Waits for a given amount of time before continuing execution",
			arguments = function()
				return module.number("time", "The amount of time to sleep for")
			end,
			callback = task.wait
		})
		module2.register_command("pairs", {
			description = "Iterates over a table",
			arguments = function()
				return module.table("t", "Table to iterate over")
			end,
			callback = function(p)
				local v = pairs(p)
				local v2 = nil
				return function()
					local v3, v4 = v(p, v2)
					v2 = v3
					return v3, v4
				end
			end
		})
		module2.register_command("ipairs", {
			description = "Iterates over an array",
			arguments = function()
				return module.table("t", "Table to iterate over")
			end,
			callback = function(list)
				local v = ipairs(list)
				local v2 = 0
				return function()
					local v3, v4 = v(list, v2)
					v2 = v3
					return v3, v4
				end
			end
		})
		module2.register_quick("error", error)
		module2.register_quick("warn", warn)
		module2.register_quick("info", info)
		module2.register_quick("vector", vector.create)
		module2.register_quick("set", set)
		module2.register_command("set", {
			permissions = {},
			description = "Attempts to set the given key and value onto the given object",
			arguments = function()
				return
					module.any("object", "the object to set"),
					module.any("key", "key of the object"),
					module.any("value", "the value to set it to")
			end,
			callback = set
		})
	end
end