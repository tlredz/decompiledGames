local parent = script.Parent.Parent
local LuauPolyfill = require(parent.LuauPolyfill)
local error = LuauPolyfill.Error
local inspect = LuauPolyfill.util.inspect
local ReactFeatureFlags = require(script.Parent.ReactFeatureFlags)
local filterInternalStackFrames = ReactFeatureFlags.filterInternalStackFrames
local v = {
	"React",
	"ReactDevtoolsShared",
	"ReactNoopRenderer",
	"ReactReconciler",
	"ReactRefresh",
	"ReactRoblox",
	"RoactCompat",
	"Scheduler",
	"Shared"
}
local v2 = nil

local function getReactPackagePrefixes()
	if v2 then
		return v2
	end

	local result = {}

	for _, childName in v do
		local child = parent.Parent:FindFirstChild(childName)

		if child then
			table.insert(result, (child:GetFullName():gsub("^game%.", "")))
		end
	end

	v2 = result
	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isInternalFrame(value: string)
	local reactPackagePrefixes = getReactPackagePrefixes()

	for _, reactPackagePrefix in reactPackagePrefixes do
		if string.sub(value, 1, #reactPackagePrefix) == reactPackagePrefix then
			return true
		end
	end

	return false
end

local function buildStackString(p: number)
	local v3 = false
	local v4 = false
	local v5 = ""

	for i = p + 1, 1e999 do
		local v6, v7, v8 = debug.info(i, "sln")

		if not v6 then
			break
		end

		if v6 == "[C]" then
			continue
		end

		if not v3 then
			local internalFrame = isInternalFrame(v6) -- equivalent call inferred; original call site unknown
			v4 = not internalFrame
			v3 = true
		end

		if v4 then
			-- equivalent call inferred; original call site unknown
			if isInternalFrame(v6) then
				continue
			end
		end

		v5 ..= `{v6}:{v7} function {v8 or "?"}\n`
	end

	return (string.gsub(v5, "\n$", ""))
end

local Roblox = {}

function Roblox.describeError(value)
	if typeof(value) ~= "string" then
		return value
	end

	local _, v3 = string.find(value, ":[%d]+: ")

	if v3 then
		value = string.sub(value, v3 + 1)
	end

	local error2 = LuauPolyfill.Error.new(value)

	if filterInternalStackFrames then
		error2.stack = buildStackString(2)
		return error2
	end

	error2.stack = debug.traceback(nil, 2)
	return error2
end

function Roblox.errorToString(p)
	if typeof(p) ~= "table" then
		return (inspect(p))
	end

	if p.message and p.stack then
		return [[

------ Error caught by React ------
]] .. p.message .. [[

------ Error caught by React ------
]] .. tostring(p.stack)
	end

	return (inspect(p))
end

function Roblox.parseReactError(value: string)
	local v3 = string.split(value, [[

------ Error caught by React ------
]])

	if #v3 == 3 then
		local v4, v5, stack = table.unpack(v3)
		local v7 = error.new(v5)
		v7.stack = stack
		return v7, v4
	else
		local v4 = error.new(value)
		v4.stack = nil
		return v4, ""
	end
end

Roblox.__ERROR_DIVIDER = [[

------ Error caught by React ------
]]
return Roblox