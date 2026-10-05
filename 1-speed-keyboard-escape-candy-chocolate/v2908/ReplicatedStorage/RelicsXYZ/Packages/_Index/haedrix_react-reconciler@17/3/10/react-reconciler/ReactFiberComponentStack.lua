local parent = script.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
require(parent.LuauPolyfill)
require(script.Parent.ReactInternalTypes)
local ReactWorkTags = require(script.Parent.ReactWorkTags)
local hostComponent = ReactWorkTags.HostComponent
local lazyComponent = ReactWorkTags.LazyComponent
local suspenseComponent = ReactWorkTags.SuspenseComponent
local suspenseListComponent = ReactWorkTags.SuspenseListComponent
local functionComponent = ReactWorkTags.FunctionComponent
local indeterminateComponent = ReactWorkTags.IndeterminateComponent
local forwardRef = ReactWorkTags.ForwardRef
local simpleMemoComponent = ReactWorkTags.SimpleMemoComponent
local classComponent = ReactWorkTags.ClassComponent
local Shared = require(parent.Shared)
local reactComponentStackFrame = Shared.ReactComponentStackFrame
local describeBuiltInComponentFrame = reactComponentStackFrame.describeBuiltInComponentFrame
local describeFunctionComponentFrame = reactComponentStackFrame.describeFunctionComponentFrame
local describeClassComponentFrame = reactComponentStackFrame.describeClassComponentFrame

local function describeFiber(return_)
	local type = nil

	if ReactGlobals.__DEV__ then
		local _debugOwner = return_._debugOwner

		if _debugOwner then
			type = _debugOwner.type
		end
	end

	local _debugSource

	if ReactGlobals.__DEV__ then
		_debugSource = return_._debugSource
	end

	if return_.tag == hostComponent then
		return describeBuiltInComponentFrame(return_.type, _debugSource, type)
	end

	if return_.tag == lazyComponent then
		return describeBuiltInComponentFrame("Lazy", _debugSource, type)
	end

	if return_.tag == suspenseComponent then
		return describeBuiltInComponentFrame("Suspense", _debugSource, type)
	end

	if return_.tag == suspenseListComponent then
		return describeBuiltInComponentFrame("SuspenseList", _debugSource, type)
	end

	if return_.tag == functionComponent or return_.tag == indeterminateComponent or return_.tag == simpleMemoComponent then
		return describeFunctionComponentFrame(return_.type, _debugSource, type)
	end

	if return_.tag == forwardRef then
		return describeFunctionComponentFrame(return_.type.render, _debugSource, type)
	end

	if return_.tag == classComponent then
		return describeClassComponentFrame(return_.type, _debugSource, type)
	end

	return ""
end

return {
	getStackByFiberInDevAndProd = function(p)
		local success, result = pcall(function()
			local return_ = p
			local v = ""

			repeat
				v ..= describeFiber(return_)
				return_ = return_.return_
			until return_ == nil

			return v
		end)

		if success then
			return result
		end

		if typeof(result) == "table" and result.message and result.stack then
			return "\nError generating stack: " .. result.message .. "\n" .. tostring(result.stack)
		end

		return "\nError generating stack: " .. tostring(result)
	end
}