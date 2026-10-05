local parent = script.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local LuauPolyfill = require(parent.LuauPolyfill)
local console = LuauPolyfill.console
local array = LuauPolyfill.Array
local ReactSharedInternals = require(script.Parent.ReactSharedInternals)
local printWarning
local ConsoleWithStackDev = {
	warn = function(p, ...)
		if ReactGlobals.__DEV__ then
			printWarning("warn", p, { ... })
		end
	end,
	error = function(p, ...)
		if ReactGlobals.__DEV__ then
			printWarning("error", p, { ... })
		end
	end
}

printWarning = function(p, p2, stackAddendums)
	if ReactGlobals.__DEV__ then
		local stackAddendum = ReactSharedInternals.ReactDebugCurrentFrame.getStackAddendum()

		if stackAddendum ~= "" then
			p2 ..= "%s"
			stackAddendums = array.slice(stackAddendums, 1)
			table.insert(stackAddendums, stackAddendum)
		end

		local mapped = array.map(stackAddendums, tostring)
		table.insert(mapped, 1, "Warning: " .. p2)
		console[p](unpack(mapped))
	end
end

return ConsoleWithStackDev