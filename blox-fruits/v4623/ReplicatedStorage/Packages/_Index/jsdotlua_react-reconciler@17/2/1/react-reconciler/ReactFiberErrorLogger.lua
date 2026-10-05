local luaupolyfill = require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local inspect = luaupolyfill.util.inspect
local setTimeout = luaupolyfill.setTimeout
local shared = require(script.Parent.Parent:WaitForChild("shared"))
local console = shared.console
local errorToString = shared.errorToString
require(script.Parent:WaitForChild("ReactInternalTypes"))
require(script.Parent:WaitForChild("ReactCapturedValue"))
local ReactFiberErrorDialog = require(script.Parent:WaitForChild("ReactFiberErrorDialog"))
local showErrorDialog = ReactFiberErrorDialog.showErrorDialog
local ReactWorkTags = require(script.Parent:WaitForChild("ReactWorkTags"))
local classComponent = ReactWorkTags.ClassComponent
local shared2 = require(script.Parent.Parent:WaitForChild("shared"))
local getComponentName = shared2.getComponentName
return {
	logCapturedError = function(p, data)
		local success, result = pcall(function()
			if showErrorDialog(p, data) == false then
				return nil
			end

			local value = data.value

			if _G.__DEV__ then
				local source = data.source
				local stack = data.stack or ""

				if value ~= nil and value._suppressLogging then
					if p.tag == classComponent then
						return
					else
						console.error(value)
					end
				end

				local v

				if source ~= nil then
					v = getComponentName(source.type)
				end

				local v2 = not v and "The above error occurred in one of your React components:" or "The above error occurred in the <" .. tostring(v) .. "> component:"
				local componentName = getComponentName(p.type)
				local v3 = v2 .. "\n" .. stack .. [[


]] .. (not componentName and [[
Consider adding an error boundary to your tree to customize error handling behavior.
Visit https://reactjs.org/link/error-boundaries to learn more about error boundaries.]] or "React will try to recreate this component tree from scratch " .. "using the error boundary you provided, " .. componentName .. ".")
				console.error(v3)
			else
				console.error(inspect(value))
			end

			return nil
		end)

		if not success then
			warn("failed to error with error: " .. inspect(result))
			setTimeout(function()
				error(errorToString(result))
			end)
		end
	end
}