local TestPlanner = require(script.Parent.TestPlanner)
local TestRunner = require(script.Parent.TestRunner)
local TextReporter = require(script.Parent.Reporters.TextReporter)

local function stripSpecSuffix(value)
	return (value:gsub("%.spec$", ""))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isSpecScript(moduleScript)
	return moduleScript:IsA("ModuleScript") and moduleScript.Name:match("%.spec$")
end

local function getPath(parent, p)
	local v = p or game
	local result = {}

	if parent.Name == "init.spec" then
		parent = parent.Parent
	end

	while parent ~= nil and parent ~= v do
		table.insert(result, (parent.Name:gsub("%.spec$", "")))
		parent = parent.Parent
	end

	table.insert(result, (v.Name:gsub("%.spec$", "")))
	return result
end

local function toStringPath(list)
	local flag = true
	local v = ""

	for _, v2 in ipairs(list) do
		if flag then
			v = v2
			flag = false
		else
			v = v2 .. " " .. v
		end
	end

	return v
end

local TestBootstrap = {}

function TestBootstrap:getModulesImpl(p, options, p2)
	local v = options or {}
	local moduleScript = p2 or p

	if isSpecScript(moduleScript) then
		local module = require(moduleScript)
		local path = getPath(moduleScript, p)
		local flag = true
		local v2 = ""

		for _, v3 in ipairs(path) do
			if flag then
				v2 = v3
				flag = false
			else
				v2 = v3 .. " " .. v2
			end
		end

		table.insert(v, {
			method = module,
			path = path,
			pathStringForSorting = v2:lower()
		})
	end
end

function TestBootstrap:getModules(folder)
	local v = {}
	self:getModulesImpl(folder, v)

	for _, descendant in ipairs(folder:GetDescendants()) do
		self:getModulesImpl(folder, v, descendant)
	end

	return v
end

function TestBootstrap:run(list, p, options)
	local v2 = options or {}
	local showTimingInfo = v2.showTimingInfo or false
	local testNamePattern = v2.testNamePattern
	local extraEnvironment = v2.extraEnvironment or {}

	if type(list) ~= "table" then
		error(("Bad argument #1 to TestBootstrap:run. Expected table, got %s"):format((typeof(list))), 2)
	end

	local now = tick()
	local modules = {}

	for _, v3 in ipairs(list) do
		local modules2 = self:getModules(v3)

		for _, module in ipairs(modules2) do
			table.insert(modules, module)
		end
	end

	local now2 = tick()
	local plan = TestPlanner.createPlan(modules, testNamePattern, extraEnvironment)
	local now3 = tick()
	local v3 = TestRunner.runPlan(plan)
	local now4 = tick()
	;(p or TextReporter).report(v3)
	local now5 = tick()

	if showTimingInfo then
		local v4 = {
			("Took %f seconds to locate test modules"):format(now2 - now),
			("Took %f seconds to create test plan"):format(now3 - now2),
			("Took %f seconds to run tests"):format(now4 - now3),
			("Took %f seconds to report tests"):format(now5 - now4)
		}
		print(table.concat(v4, "\n"))
	end

	return v3
end

return TestBootstrap