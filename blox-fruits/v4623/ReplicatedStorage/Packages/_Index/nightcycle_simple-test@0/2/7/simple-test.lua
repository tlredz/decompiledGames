local Parameter = require(script.Parameter)
local Test = require(script.Test)
local Debug = require(script.Debug)
local Summary = require(script.Summary)
local ENV = require(script.ENV)
local CONSTANTS = require(script.CONSTANTS)

function toPath(instance)
	return (instance:GetFullName():gsub("%.spec", ""):gsub("%.", "/"))
end

local SimpleTest = {
	CONSTANTS = CONSTANTS,
	Parameter = Parameter,
	Summary = Summary,
	Test = Test,
	Debug = Debug,
	ENV = ENV
}

function SimpleTest.searchFromEnv()
	local SEARCH_FILTER_PATH = ENV.SEARCH_FILTER_PATH

	if SEARCH_FILTER_PATH == "" then
		error("SEARCH_FILTER_PATH is not set")
		return
	end

	local game2 = game
	local v

	if SEARCH_FILTER_PATH:sub(-5) == ".luau" then
		v = SEARCH_FILTER_PATH:sub(1, -6)
	elseif SEARCH_FILTER_PATH:sub(-4) == ".lua" then
		v = SEARCH_FILTER_PATH:sub(1, -5)
	else
		v = SEARCH_FILTER_PATH
	end

	local v2 = string.split(v, "/")

	if v2[1] == "game" or v2[1] == "src" then
		table.remove(v2, 1)
	end

	while true do
		local v3 = v2[1]

		if not v3 then
			error((`Invalid SEARCH_FILTER_PATH: "{SEARCH_FILTER_PATH}"`))
		end

		game2 = game2:FindFirstChild(v3)

		if game2 == nil then
			error((`Invalid SEARCH_FILTER_PATH, could not find instance at segment "{v3}": "{SEARCH_FILTER_PATH}"`))
		end

		table.remove(v2, 1)

		if #v2 == 0 then
			return SimpleTest.search({ game2 })
		end
	end
end

function SimpleTest.search(items)
	local result = {}

	for _, moduleScript in items do
		if not (moduleScript:IsA("ModuleScript") and moduleScript.Name:sub(-5) == ".spec") then
			continue
		end

		local success, result2 = pcall(require, moduleScript)

		if not success then
			continue
		end

		local v, _ = Test.Type.Test(result2)

		if v then
			local v2 = toPath(moduleScript)
			assert(result[v2] == nil, "duplicate path at: \"path}\"")
			result[v2] = result2
		else
			local v2, _ = Test.Type.TestMap(result2)

			if v2 then
				local v3 = toPath(moduleScript)

				for k, v4 in result2 do
					local formatted = `{v3}/{k}`
					assert(result[formatted] == nil, (`duplicate path at: "{formatted}"`))
					result[formatted] = v4
				end
			else
				local v3, _ = Test.Type.TestTree(result2)

				if v3 then
					local v5 = {}
					local recurse
					local recurse2 = recurse

					recurse = function(result3, p: string)
						for k, item in result3 do
							local formatted = `{p}/{k}`
							assert(v5[formatted] == nil, (`duplicate path at: "{formatted}"`))

							if Test.Type.Test(item) then
								v5[formatted] = item
							elseif Test.Type.TestTree(item) then
								recurse2(item, formatted)
							else
								return false
							end
						end

						return true
					end

					recurse(result2, (toPath(moduleScript)))

					for k, v7 in v5 do
						assert(result[k] == nil, (`duplicate path at: "{k}"`))
						result[k] = v7
					end
				end
			end
		end
	end

	table.freeze(result)
	return result
end

function SimpleTest.run(items, p)
	Debug.log("Running tests...")
	local v = {}

	for k, item in items do
		Debug.log((`Running test: "{k}"`))
		v[k] = Test.run(item)
	end

	Debug.log("Completed running tests")

	if p == "FullJSON" then
		return Summary.newFullJSON(v)
	elseif p == "Overview" then
		return Summary.newOverview(v)
	end

	error((`Invalid summary type: "{p}"`))
end

return SimpleTest