local ConfigHandler = require(script.Parent.ConfigHandler)
local v = {
	Instance = function(instance)
		return instance:GetFullName()
	end,
	CFrame = function(cframe: CFrame)
		return (tostring(cframe.Position))
	end
}

local function log(p, ...)
	if not ConfigHandler.GetActiveConfig(p).Debugging.Enabled then
		return
	end

	local v2 = "[" .. debug.info(3, "s") .. "]: "

	for _, v3 in pairs({ ... }) do
		local v4 = "COULD NOT CONVERT VAL TYPE!"
		local v5 = v[typeof(v3)]
		local v6

		if v5 ~= nil then
			v6 = v5(v3)
		end

		local v7

		if v6 then
			v7 = v6 or v4
		else
			v7 = tostring(v3)
		end

		v2 ..= v7
	end

	print(v2)
end

local Debugging = {}

function Debugging.Log(p, ...)
	log(p, ...)
end

function Debugging.LogWithVerbosity(p, p2: number, ...)
	local activeConfig = ConfigHandler.GetActiveConfig(p)

	if not activeConfig.Debugging.Enabled or activeConfig.Debugging.Verbosity < p2 then
		return
	end

	log(p, ...)
end

function Debugging.TimeIt(p: string, callback)
	local lastTime = os.clock()
	local success, result = pcall(callback)
	local v2 = os.clock() - lastTime

	if success then
		print(string.format(p .. " | Elapsed time: %.6f seconds", v2))
	else
		warn(string.format(p .. " | Callback failed after %.6f seconds: %s", v2, result))
	end

	return v2, success, result
end

return Debugging