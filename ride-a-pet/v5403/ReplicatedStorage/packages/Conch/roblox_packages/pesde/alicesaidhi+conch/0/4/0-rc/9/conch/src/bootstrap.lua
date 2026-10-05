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

local function conch_print(...)
	output({
		kind = "normal",
		text = concat(...)
	}) -- equivalent call inferred; original call site unknown
end

local function conch_error(...)
	local v = concat(...)
	error(v, 0)
end

local function conch_warn(...)
	output({
		kind = "warn",
		text = concat(...)
	}) -- equivalent call inferred; original call site unknown
end

local function conch_info(...)
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
		conch_print((`CONCH INTERNAL INFORMATION - {RunService:IsClient() and "CLIENT" or RunService:IsServer() and "SERVER" or "?"}`))
		conch_print("")
		conch_print("REGISTERED ROLES:")

		for k, list in module3.roles do
			conch_print((`[{k}]: {table.concat(list, ", ")}`))
		end

		conch_print("")
		conch_print("REGISTERED COMMANDS")
	end

	local function set(p, p2, p3)
		p[p2] = p3
	end

	if isClient then
		module2.register_command("print", {
			permissions = {},
			description = "Converts the given arguments into a string and sends it to the output",
			arguments = function()
				return module.args.variadic(module.args.any("any", "Arguments to output"))
			end,
			callback = conch_print
		})
		module2.register_command("sleep", {
			permissions = {},
			description = "Waits for a given amount of time before continuing execution",
			arguments = function()
				return module.args.number("time", "The amount of time to sleep for")
			end,
			callback = task.wait
		})
		module2.register_quick("error", conch_error)
		module2.register_quick("warn", conch_warn)
		module2.register_quick("info", conch_info)
		module2.register_command("set", {
			permissions = {},
			description = "Attempts to set the given key and value onto the given object",
			arguments = function()
				return
					module.args.any("object", "the object to set"),
					module.args.any("key", "key of the object"),
					module.args.any("value", "the value to set it to")
			end,
			callback = set
		})
	end
end