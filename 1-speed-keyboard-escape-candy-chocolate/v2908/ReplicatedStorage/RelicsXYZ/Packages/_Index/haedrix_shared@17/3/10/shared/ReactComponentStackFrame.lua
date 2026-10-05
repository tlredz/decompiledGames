local parent = script.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
require(script.Parent.ReactElementType)
require(script.Parent["flowtypes.roblox"])
local ReactSymbols = require(script.Parent.ReactSymbols)
local REACT_SUSPENSE_TYPE = ReactSymbols.REACT_SUSPENSE_TYPE
local REACT_SUSPENSE_LIST_TYPE = ReactSymbols.REACT_SUSPENSE_LIST_TYPE
local REACT_FORWARD_REF_TYPE = ReactSymbols.REACT_FORWARD_REF_TYPE
local REACT_MEMO_TYPE = ReactSymbols.REACT_MEMO_TYPE
local REACT_BLOCK_TYPE = ReactSymbols.REACT_BLOCK_TYPE
local REACT_LAZY_TYPE = ReactSymbols.REACT_LAZY_TYPE
local ConsolePatchingDevroblox = require(script.Parent["ConsolePatchingDev.roblox"])
local disableLogs = ConsolePatchingDevroblox.disableLogs
local reenableLogs = ConsolePatchingDevroblox.reenableLogs
local ReactSharedInternals = require(script.Parent.ReactSharedInternals)
local reactCurrentDispatcher = ReactSharedInternals.ReactCurrentDispatcher
local describeComponentFrame

local function describeOwner(value)
	if type(value) == "function" then
		return debug.info(value, "n")
	end

	if type(value) == "table" then
		return (tostring(value))
	end

	return nil
end

local function describeBuiltInComponentFrame(p: string, p2, value)
	local v

	if ReactGlobals.__DEV__ and value then
		if type(value) == "function" then
			v = debug.info(value, "n")
		elseif type(value) == "table" then
			v = tostring(value)
		end
	end

	return describeComponentFrame(p, p2, v)
end

local v = false
local v2

if ReactGlobals.__DEV__ then
	v2 = setmetatable({}, {
		__mode = "k"
	})
else
	v2 = nil
end

local function describeNativeComponentFrame(callback, flag: boolean)
	if not callback or v then
		return ""
	end

	if ReactGlobals.__DEV__ then
		local v3 = v2[callback]

		if v3 ~= nil then
			return v3
		end
	end

	local v3 = nil
	v = true
	local current

	if ReactGlobals.__DEV__ then
		current = reactCurrentDispatcher.current
		reactCurrentDispatcher.current = nil
		disableLogs()
	end

	local traceback = nil
	local _, v4 = xpcall(function()
		if flag then
			return
		end

		local _, result = pcall(function()
			traceback = debug.traceback()
			error({
				stack = traceback
			})
		end)
		v3 = result
		callback()
	end, function(message)
		return {
			message = message,
			stack = traceback
		}
	end)
	local v5 = nil

	if v4 and v3 and type(v4.stack) == "string" then
		local v6 = string.split(v4.stack, "\n")
		local v7 = string.split(v3.stack, "\n")
		local v8 = #v6 - 1
		local v9 = #v7 - 1

		while v8 >= 2 and v9 >= 0 and v6[v8] ~= v7[v9] do
			v9 -= 1
		end

		while v8 >= 3 and v9 >= 1 do
			v8 -= 1
			v9 -= 1

			if v6[v8] == v7[v9] then
				continue
			end

			if v8 == 1 and v9 == 1 then
				break
			end

			repeat
				v8 -= 1
				v9 -= 1

				if v9 < 0 or v6[v8] ~= v7[v9] then
					v5 = "\n" .. "    in " .. v6[v8]

					if ReactGlobals.__DEV__ then
						v2[callback] = v5
					end
				end
			until not (v8 >= 3 and v9 >= 1)

			break
		end
	end

	v = false

	if ReactGlobals.__DEV__ then
		reactCurrentDispatcher.current = current
		reenableLogs()
	end

	if v5 ~= nil then
		return v5
	end

	local v6

	if type(callback) == "function" then
		v6 = debug.info(callback, "n")
	else
		v6 = type(callback) ~= "table" and "" or tostring(callback)
	end

	local v7

	if v6 == nil or v6 == "" then
		v7 = ""
	else
		local _ = ReactGlobals.__DEV__
		v7 = describeComponentFrame(v6, nil, nil)
	end

	if ReactGlobals.__DEV__ then
		v2[callback] = v7
	end

	return v7
end

describeComponentFrame = function(value: string?, p, p2: string?)
	local v3 = ""

	if ReactGlobals.__DEV__ and p then
		local fileName = p.fileName
		local v4 = string.gsub(fileName, "^(.*)[\\/]", "")

		if string.match(v4, "^init%.") then
			local v5 = string.match(fileName, "^(.*)[\\/]")

			if v5 and #v5 ~= 0 then
				v4 = string.gsub(v5, "^(.*)[\\/]", "") .. "/" .. v4
			end
		end

		v3 = " (at " .. v4 .. ":" .. p.lineNumber .. ")"
	elseif p2 then
		v3 = " (created by " .. p2 .. ")"
	end

	return "\n    in " .. (value or "Unknown") .. v3
end

local function describeClassComponentFrame(value, p, value2)
	local v3 = tostring(value)
	local v4

	if ReactGlobals.__DEV__ and value2 then
		if type(value2) == "function" then
			v4 = debug.info(value2, "n")
		elseif type(value2) == "table" then
			v4 = tostring(value2)
		end
	end

	return describeComponentFrame(v3, p, v4)
end

local function describeFunctionComponentFrame(callback, p, value)
	if not callback then
		return ""
	end

	local v3

	if type(callback) == "function" then
		v3 = debug.info(callback, "n")
	else
		v3 = tostring(callback)
	end

	local v4

	if ReactGlobals.__DEV__ and value then
		if type(value) == "function" then
			v4 = debug.info(value, "n")
		elseif type(value) == "table" then
			v4 = tostring(value)
		end
	end

	return describeComponentFrame(v3, p, v4)
end

local describeUnknownElementTypeFrameInDEV

describeUnknownElementTypeFrameInDEV = function(value, p, p2)
	if not (ReactGlobals.__DEV__ and value ~= nil) then
		return ""
	end

	if type(value) == "table" and type(value.__ctor) == "function" then
		return describeClassComponentFrame(value, p, p2)
	end

	if type(value) == "function" then
		return describeFunctionComponentFrame(value, p, p2)
	end

	if type(value) == "string" then
		return describeBuiltInComponentFrame(value, p, p2)
	end

	if value == REACT_SUSPENSE_TYPE then
		return describeBuiltInComponentFrame("Suspense", p, p2)
	end

	if value == REACT_SUSPENSE_LIST_TYPE then
		return describeBuiltInComponentFrame("SuspenseList", p, p2)
	end

	if type(value) ~= "table" then
		return ""
	end

	local typeof = value["$$typeof"]

	if typeof == REACT_FORWARD_REF_TYPE then
		return describeFunctionComponentFrame(value.render, p, p2)
	end

	if typeof == REACT_MEMO_TYPE then
		return describeUnknownElementTypeFrameInDEV(value.type, p, p2)
	end

	if typeof == REACT_BLOCK_TYPE then
		return describeFunctionComponentFrame(value._render, p, p2)
	end

	if typeof ~= REACT_LAZY_TYPE then
		return ""
	end

	local _payload = value._payload
	local _init = value._init
	local success, result = pcall(function()
		describeUnknownElementTypeFrameInDEV(_init(_payload), p, p2)
	end)

	if success then
		return result
	end

	return ""
end

return {
	describeComponentFrame = describeComponentFrame,
	describeBuiltInComponentFrame = describeBuiltInComponentFrame,
	describeNativeComponentFrame = describeNativeComponentFrame,
	describeClassComponentFrame = describeClassComponentFrame,
	describeFunctionComponentFrame = describeFunctionComponentFrame,
	describeUnknownElementTypeFrameInDEV = describeUnknownElementTypeFrameInDEV
}