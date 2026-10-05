local parent = script.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local LuauPolyfill = require(parent.LuauPolyfill)
local error2 = LuauPolyfill.Error
local console = require(script.Parent.console)
local v = {}
local ReactComponentStackFrame = require(script.Parent.ReactComponentStackFrame)
local describeUnknownElementTypeFrameInDEV = ReactComponentStackFrame.describeUnknownElementTypeFrameInDEV
local ReactSharedInternals = require(script.Parent.ReactSharedInternals)
local ErrorHandlingroblox = require(script.Parent["ErrorHandling.roblox"])
local describeError = ErrorHandlingroblox.describeError
local reactDebugCurrentFrame = ReactSharedInternals.ReactDebugCurrentFrame

-- equivalent calls inferred from this helper; original call sites unknown
local function setCurrentlyValidatingElement(data)
	if ReactGlobals.__DEV__ then
		if data then
			local _owner = data._owner
			local type = data.type
			local _source = data._source
			local v3

			if _owner ~= nil then
				v3 = _owner.type
			end

			local v4 = describeUnknownElementTypeFrameInDEV(type, _source, v3)
			reactDebugCurrentFrame.setExtraStackFrame(v4)
		else
			reactDebugCurrentFrame.setExtraStackFrame(nil)
		end
	end
end

local function checkPropTypes(items, callback, p, p2: string, value: string?, data)
	if ReactGlobals.__DEV__ or ReactGlobals.__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ then
		if items and callback then
			console.warn("You've defined both propTypes and validateProps on " .. (value or "a component"))
		end

		if callback then
			if typeof(callback) == "function" then
				local v2, v3 = callback(p)

				if not v2 then
					local v4 = string.format(
						"validateProps failed on a %s type in %s: %s",
						p2,
						value or "<UNKNOWN Component>",
						(tostring(v3 or "<Validator function did not supply a message>"))
					)
					error(v4)
				end
			else
				console.error(([[
validateProps must be a function, but it is a %s.
Check the definition of the component %q.]]):format(typeof(callback), value or ""))
			end
		end

		if items then
			assert(typeof(items) == "table", "propTypes needs to be a table")

			for k, _ in items do
				local v2 = k
				local _, v3 = xpcall(function()
					if typeof(items[v2]) ~= "function" then
						local v4 = error2.new((value or "React class") .. ": " .. p2 .. " type `" .. v2 .. "` is invalid; " .. "it must be a function, usually from the `prop-types` package, but received `" .. typeof(items[v2]) .. "`.This often happens because of typos such as `PropTypes.function` instead of `PropTypes.func`.")
						v4.name = "Invariant Violation"
						error(v4)
					end

					return items[v2](p, v2, value, p2, nil, "SECRET_DO_NOT_PASS_THIS_OR_YOU_WILL_BE_FIRED")
				end, describeError)
				local v4 = typeof(v3) == "table"

				if v3 ~= nil and not v4 then
					setCurrentlyValidatingElement(data) -- equivalent call inferred; original call site unknown
					console.error(string.format(
						"%s: type specification of %s `%s` is invalid; the type checker function must return `nil` or an `Error` but returned a %s. You may have forgotten to pass an argument to the type checker creator (arrayOf, instanceOf, objectOf, oneOf, oneOfType, and shape all require an argument).",
						value or "React class",
						p2,
						k,
						(typeof(v3))
					))
					setCurrentlyValidatingElement() -- equivalent call inferred; original call site unknown
				end

				if not (v4 and v[v3.message] == nil) then
					continue
				end

				v[tostring(v3.message)] = true
				setCurrentlyValidatingElement(data) -- equivalent call inferred; original call site unknown
				console.warn(string.format("Failed %s type: %s", p2, (tostring(v3.message))))
				setCurrentlyValidatingElement() -- equivalent call inferred; original call site unknown
			end
		end
	end
end

return checkPropTypes