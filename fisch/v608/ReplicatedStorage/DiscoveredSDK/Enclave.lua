local RunService = game:GetService("RunService")
local Enclave = {}
setmetatable(Enclave, Enclave)
Enclave.Assets = script.Parent:WaitForChild("Assets", 10)
local v = {
	CACHE_MISS = "Cache miss for %* during require.",
	CYCLIC_REQUIRE = "Cyclic dependency detected while requiring %*. Modules involved:",
	EXPANDING_LEVEL = "Expanding ancestry name index to level %*.",
	INDEXED_MODULES = "Indexed all modules in %*. Found %*.",
	JOB_INIT = "Initializing %* (priority %*)...",
	JOB_INIT_ERR = "Job %*:Init() errored: %*",
	JOB_INIT_SUCCESS = "Initialized %*.",
	JOB_RUN = "Running %* (priority %*)...",
	JOB_RUN_ERR = "Job %*:Run() errored: %*",
	JOB_RUN_SUCCESS = "Ran %*.",
	LOADING_JOB_FAILED = "Job %* errored on-load. Job data:",
	LOADING_JOBS = "Loading jobs in %*...",
	REQUIRE_ERR = "Module %* errored during require: %*",
	SLOW_JOB_INIT = `Job %*:Init() has been running for more than {1}. Move yielding operations to ::Run().`,
	STARTUP_TIME = "Successfully executed %* jobs in ~%.5f seconds!",
	UNKNOWN_MODULE = "%*: attempt to require unknown module %*."
}
local v2 = {}
local v3 = {}
local v4 = {}
local __calls = {}
local names = {}
local v5 = 0

local function vprint(...) end

local function vwarn(...)
	warn("[Enclave]", ...)
end

local function Load(moduleScript)
	local v6 = nil
	local success, result = pcall(function()
		local module = require(moduleScript)
		v6 = module
	end)

	if not success then
		vwarn(v.REQUIRE_ERR:format(moduleScript.Name, result))
	end

	if typeof(v6) == "table" and (v6.Init or v6.Run) then
		names[v6] = moduleScript.Name
	end

	return v6
end

local function GetAncestors(p)
	local parent = p.Parent
	local parents = {}

	while parent do
		table.insert(parents, parent)
		parent = parent.Parent
	end

	return parents
end

local function IndexNames(instance, p: number?)
	if typeof(instance) ~= "Instance" then
		return
	end

	local function indexName(name: string)
		if not v2[name] or v2[name] == instance then
			v2[name] = instance
			return
		end

		local instances = v2[name]

		if typeof(instances) == "table" and not table.find(instances, instance) then
			table.insert(instances, instance)
		else
			v2[name] = { instances, instance }
		end
	end

	indexName(instance.Name)
	local parent = instance.Parent
	local parents = {}

	while parent do
		table.insert(parents, parent)
		parent = parent.Parent
	end

	local name = instance.Name

	for k, v6 in pairs(parents) do
		if p and p < k then
			break
		end

		name = v6.Name .. "/" .. name
		indexName(name)

		if v6.Name == "Enclave" then
			break
		end
	end
end

local function ExpandNameIndex(p: number)
	if p <= v5 then
		return
	end

	vprint(v.EXPANDING_LEVEL:format(p))

	for _, moduleScript in pairs(v2) do
		if typeof(moduleScript) == "table" then
			for _, item in pairs(moduleScript) do
				IndexNames(item, p)
			end
		elseif typeof(moduleScript) == "Instance" and moduleScript:IsA("ModuleScript") then
			IndexNames(moduleScript, p)
		end
	end

	v5 = p
end

local function IndexModulesOf(folder, flag: boolean?)
	local children = flag and folder:GetChildren() or folder:GetDescendants()
	local count = 0

	for _, moduleScript in ipairs(children) do
		if not (moduleScript:IsA("ModuleScript") and moduleScript ~= script) then
			continue
		end

		count += 1
		IndexNames(moduleScript, 0)
	end

	vprint(v.INDEXED_MODULES:format(folder:GetFullName(), count))
end

local LoadJobs

LoadJobs = function(instance)
	vprint(v.LOADING_JOBS:format(instance:GetFullName()))

	for _, child in ipairs(instance:GetChildren()) do
		if child:IsA("ModuleScript") then
			local name = child.Name
			local parent = child.Parent

			while v2[name] and typeof(v2[name]) == "table" do
				name = parent.Name .. "/" .. name
				parent = parent.Parent
			end

			local __call = Enclave:__call(name)

			if __call then
				table.insert(__calls, __call)
			else
				vwarn(v.LOADING_JOB_FAILED:format(child.Name), child)
			end
		elseif child:IsA("Folder") then
			LoadJobs(child)
		end
	end
end

local function ExecuteJobs()
	local lastTime = os.clock()
	vprint("Initializing jobs...")
	table.sort(__calls, function(a, b)
		return (a.Priority or 0) > (b.Priority or 0)
	end)

	local function initialize(p)
		if not p.Init then
			return
		end

		local lastTime2 = os.clock()
		local v6 = false
		local v7 = names[p] or "Unknown Job"
		task.spawn(function()
			while not v6 do
				if os.clock() - lastTime2 > 1 then
					vwarn(v.SLOW_JOB_INIT:format(v7))
					break
				else
					task.wait()
				end
			end
		end)
		vprint(v.JOB_INIT:format(v7, p.Priority or 0))
		local success, result = pcall(p.Init, p)
		v6 = true

		if success then
			vprint(v.JOB_INIT_SUCCESS:format(v7))
		else
			vwarn(v.JOB_INIT_ERR:format(v7, result))
		end
	end

	local function run(p)
		if not p.Run then
			return
		end

		local v6 = names[p] or "Unknown Job"
		vprint(v.JOB_RUN:format(v6, p.Priority or 0))
		local success, result = pcall(p.Run, p)

		if success then
			vprint(v.JOB_RUN_SUCCESS:format(v6))
		else
			vwarn(v.JOB_RUN_ERR:format(v6, result))
		end
	end

	local count = 0

	for _, v6 in pairs(__calls) do
		count += 1

		if v6.Init then
			initialize(v6)
		end
	end

	vprint("Finished initializing jobs.")
	vprint("Running jobs...")
	local v6 = 0

	for _, v7 in pairs(__calls) do
		if not v7.Run then
			continue
		end

		v6 += 1
		local v8 = v7
		task.spawn(function()
			run(v8)
			v6 -= 1
		end)
	end

	vprint("Finished running jobs.")
	vprint(v.STARTUP_TIME:format(count, os.clock() - lastTime))
	table.clear(__calls)
end

function Enclave:__call(instance)
	if typeof(instance) == "Instance" then
		return require(instance)
	end

	local v6 = v2[instance]

	if v6 and v3[v6] then
		return v3[v6]
	end

	if v6 then
		if v4[v6] then
			vwarn(v.CYCLIC_REQUIRE:format(instance))

			for k in pairs(v4) do
				warn("\t-", k:GetFullName())
			end
		elseif typeof(v2[instance]) == "table" then
			local v7 = v2[instance]
			local traceback = debug.traceback()
			local v8 = string.sub(traceback, (string.find(traceback, "__call") or 0) + 7, string.len(traceback) - 1) .. ": Multiple modules found for '" .. instance .. "' - please be more specific:\n"
			local v9 = #v7

			for i, v10 in ipairs(v7) do
				if typeof(v10) ~= "table" then
					v8 ..= "\t\t\t\t\t\t\t- " .. string.gsub(v10:GetFullName(), "[.]", "/") .. (i == v9 and "" or "\n")
				end
			end

			warn(v8)
			return
		else
			v4[v6] = true
			v3[v6] = Load(v6)
			v4[v6] = nil
		end

		return v3[v6]
	else
		vprint(v.CACHE_MISS:format(instance))
		local _, v7 = string.gsub(instance, "/", "")

		if v5 < v7 then
			ExpandNameIndex(v7)
			return Enclave:__call(instance)
		end

		local traceback = debug.traceback()
		local v8 = string.sub(traceback, (string.find(traceback, "__call") or 0) + 7, string.len(traceback) - 1)
		vwarn(v.UNKNOWN_MODULE:format(v8, instance))
	end
end

function Enclave:Init()
	local child = script:WaitForChild(RunService:IsClient() and "Client" or "Server")
	local shared2 = script:WaitForChild("Shared")
	IndexModulesOf(child)
	IndexModulesOf(shared2)

	if RunService:IsRunning() then
		LoadJobs(child:WaitForChild("Jobs"))
		LoadJobs(shared2:WaitForChild("Jobs"))
		ExecuteJobs()
	end
end

if not getmetatable(shared) then
	setmetatable(shared, {
		__call = function(self, p)
			local v6, v7 = debug.info(2, "sl")
			local v8 = string.split(v6, ".")
			local v9 = v8[#v8]
			error(`{v9}:{v7} - Attempt to require shared module "{p}", did you forget to switch shared to Enclave?`, 0)
		end
	})
end

if not RunService:IsRunning() then
	Enclave:Init()
end

return Enclave