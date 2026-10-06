local luaVM = {}
local v2 = {}
local RunService = game:GetService("RunService")
require(script:WaitForChild("Types"))
local Rule = require(script:WaitForChild("Rule"))
local Enum2 = require(script:WaitForChild("Enum"))
local enumList = Enum2.EnumList
local utilities = Enum2.Utilities
local v3 = {
	DockWidgetPluginGuiInfo = DockWidgetPluginGuiInfo,
	warn = warn,
	CFrame = CFrame,
	gcinfo = gcinfo,
	os = os,
	tick = tick,
	task = task,
	UDim = UDim,
	pairs = pairs,
	NumberSequence = NumberSequence,
	assert = assert,
	rawlen = rawlen,
	tonumber = tonumber,
	Color3 = Color3,
	Enum = Enum,
	Delay = Delay,
	OverlapParams = OverlapParams,
	Stats = Stats,
	_G = _G,
	RotationCurveKey = RotationCurveKey,
	coroutine = coroutine,
	NumberRange = NumberRange,
	FloatCurveKey = FloatCurveKey,
	PhysicalProperties = PhysicalProperties,
	Region3int16 = Region3int16,
	ypcall = ypcall,
	Font = Font,
	Ray = Ray,
	NumberSequenceKeypoint = NumberSequenceKeypoint,
	Version = Version,
	Vector2 = Vector2,
	version = version,
	Game = Game,
	delay = delay,
	spawn = spawn,
	stats = stats,
	string = string,
	wait = wait,
	UserSettings = UserSettings,
	settings = settings,
	_VERSION = _VERSION,
	loadstring = loadstring,
	printidentity = printidentity,
	CatalogSearchParams = CatalogSearchParams,
	UDim2 = UDim2,
	unpack = unpack,
	TweenInfo = TweenInfo,
	Wait = Wait,
	require = require,
	Vector3 = Vector3,
	Instance = Instance,
	Vector3int16 = Vector3int16,
	setmetatable = setmetatable,
	next = next,
	elapsedTime = elapsedTime,
	time = time,
	shared = shared,
	SharedTable = SharedTable,
	ipairs = ipairs,
	Workspace = Workspace,
	Faces = Faces,
	rawequal = rawequal,
	Vector2int16 = Vector2int16,
	collectgarbage = collectgarbage,
	game = game,
	newproxy = newproxy,
	Spawn = Spawn,
	DateTime = DateTime,
	Region3 = Region3,
	utf8 = utf8,
	xpcall = xpcall,
	Random = Random,
	rawset = rawset,
	PathWaypoint = PathWaypoint,
	tostring = tostring,
	RaycastParams = RaycastParams,
	workspace = workspace,
	typeof = typeof,
	math = math,
	bit32 = bit32,
	pcall = pcall,
	ColorSequenceKeypoint = ColorSequenceKeypoint,
	getfenv = getfenv,
	type = type,
	ColorSequence = ColorSequence,
	ElapsedTime = ElapsedTime,
	select = select,
	getmetatable = getmetatable,
	rawget = rawget,
	table = table,
	Rect = Rect,
	BrickColor = BrickColor,
	setfenv = setfenv,
	debug = debug,
	Axes = Axes,
	error = error,
	print = print,
	buffer = buffer,
	Content = Content,
	vector = vector
}
local LuaVM = require(script.LuaVM)

function luaVM.new(chunkName: string?, p)
	assert(
		type(chunkName) == "string" or type(chunkName) == "nil",
		"Expected string or nil as argument #1 for 'SLVM.new'"
	)
	assert(type(p) == "table" or type(p) == "nil", "Expected table or nil as argument #2 for 'SLVM.new'")
	local object = setmetatable({
		LVMSettings = {
			ChunkName = chunkName,
			Env = p and setmetatable(p, {
				__index = v3
			}) or table.clone(v3)
		},
		ReplacedClosures = {},
		ReadHooks = {},
		WriteHooks = {},
		AdditionalSettings = {},
		Rules = {},
		MaxThreadCount = 100,
		CreatedInstances = {},
		CreatedThreads = {},
		ScriptGlobalType = enumList.ScriptGlobalType.AutoResolve
	}, {
		__index = v2
	})
	local v4 = nil
	v4 = object:ReplaceClosure(Instance.new, function(...)
		if type(...) == "string" and object:CheckCString("FloorWire", ...) then
			error("crash detection triggered - usage of deprecated instance 'FloorWire' which is not supported in SLVM")
		end

		local success, result = pcall(v4, ...)

		if not success then
			error(result, 2)
		end

		table.insert(object.CreatedInstances, result)
		return result
	end)
	local v5 = nil
	v5 = object:ReplaceClosure(SharedTable.new, function(...)
		local v6 = { ... }

		if type(v6[2]) == "table" and type(v6[3]) == "userdata" then
			error("crash detection triggered - please put the SharedTable's values in a different order", 2)
		end

		local success, result = pcall(v5, ...)

		if not success then
			error(result, 2)
		end

		return result
	end)
	local v6 = nil
	v6 = object:ReplaceClosure(SharedTable.clone, function(...)
		local v7 = ...

		if type(v7[2]) == "table" and type(v7[3]) == "userdata" then
			error("crash detection triggered - please put the SharedTable's values to clone in a different order", 2)
		end

		local success, result = pcall(v6, ...)

		if not success then
			error(result, 2)
		end

		return result
	end)
	local flag = false
	local spawn2 = task.spawn

	local function fn(...)
		if flag then
			return
		end

		if #object.CreatedThreads >= object.MaxThreadCount then
			flag = true
			object:CloseCreatedThreads()
			task.delay(1, function()
				flag = false
			end)
			error("too many threads - ending execution", 2)
		end

		local success, result = pcall(spawn2, ...)

		if not success then
			error(result, 2)
		end

		table.insert(object.CreatedThreads, result)
		task.wait()
		return result
	end

	local function fn2(...)
		local v7, v8 = ...

		if type(v7) == "number" and type(v8) == "function" then
			RunService.Heartbeat:Wait()
			task.wait(...)
			return fn(v8)
		else
			local success, result = pcall(fn, ...)

			if not success then
				error(result, 2)
			end

			return result
		end
	end

	object:ReplaceClosure(spawn2, fn)
	object:ReplaceClosure(spawn, fn)
	object:ReplaceClosure(Spawn, fn)
	object:ReplaceClosure(task.delay, fn2)
	object:ReplaceClosure(delay, fn2)
	object:ReplaceClosure(Delay, fn2)
	object:AddRule(Rule.new(enumList.RuleType.TableRestriction, shared))
	object:ReplaceClosure(coroutine.create, function(...)
		local v7 = ...
		return fn(function()
			coroutine.yield()
			return v7()
		end)
	end)
	object:ReplaceClosure(coroutine.wrap, function(...)
		local v7 = ...
		return function()
			local v8 = fn(function()
				coroutine.yield()
				return v7()
			end)

			if v8 then
				coroutine.resume(v8)
			end
		end
	end)
	local v7 = nil
	v7 = object:ReplaceClosure(coroutine.close, function(...)
		local v8 = ...
		local index = table.find(object.CreatedThreads, v8)

		if coroutine.status(...) ~= "dead" then
			local success, result = pcall(v7, ...)

			if success then
				table.remove(object.CreatedThreads, index)
			else
				error(result, 2)
			end
		end

		local success, result = pcall(v7, ...)

		if not success then
			error(result, 2)
		end

		return result
	end)

	if buffer then
		local v8 = nil
		v8 = object:ReplaceClosure(buffer.create, function(...)
			if type(...) == "number" and ... >= 10000 then
				error("crash detection triggered - buffer size is bigger than 10000", 2)
			end

			local success, result = pcall(v8, ...)

			if not success then
				error(result, 2)
			end

			return result
		end)
		local v9 = nil
		v9 = object:ReplaceClosure(buffer.fromstring, function(...)
			if type(...) == "number" and #... >= 10000 then
				error("crash detection triggered - string size is bigger than 10000", 2)
			end

			local success, result = pcall(v9, ...)

			if not success then
				error(result, 2)
			end

			return result
		end)
		local v10 = nil
		v10 = object:ReplaceClosure(buffer.fill, function(...)
			local v11, v12, v13, _ = ...

			if type(v11) == "buffer" and type(v13) == "number" and v12 >= 1000000 and v13 >= 4500000000 then
				error("crash detection triggered - buffer fill with these arguments is an unsafe operation", 2)
			end

			local success, result = pcall(v10, ...)

			if not success then
				error(result, 2)
			end

			return result
		end)
	end

	object:EnableAdditionalSetting(enumList.AdditionalSettings.SandboxCalls)
	return object
end

function v2:Compile(value: string)
	assert(type(value) == "string", "Expected string as argument #1 for 'SLVM.Compile'")

	if not self:IsAdditionalSettingEnabled(enumList.AdditionalSettings.SandboxCalls) then
		warn("SLVM has detected that the additional setting `SandboxCalls` is disabled. It is HIGHLY recommended that you enable it. Only disable it for performance intensive tasks.")
	end

	local env = self.LVMSettings.Env

	if table.find(self.AdditionalSettings, enumList.AdditionalSettings) and self.ScriptGlobalType ~= enumList.ScriptGlobalType.None then
		env.script = Instance.new(self.ScriptGlobalType == enumList.ScriptGlobalType.Server and "Script" or self.ScriptGlobalType == enumList.ScriptGlobalType.Client and "LocalScript" or self.ScriptGlobalType == enumList.ScriptGlobalType.AutoResolve and RunService:IsServer() and "Script" or "LocalScript")
	end

	local v4 = {
		SLVMTypes = {},
		SLVMBlock = {},
		SLVMReplaced = {},
		SLVMReadHook = {},
		SLVMWriteHook = {},
		AdditionalSettings = {},
		AdvDebug = false
	}
	v4.AdditionalSettings.ThrottleLoopInstructions = table.find(
		self.AdditionalSettings,
		enumList.AdditionalSettings.ThrottleLoopInstructions
	) and true or false
	v4.AdditionalSettings.ThrottleRecursiveCalls = table.find(
		self.AdditionalSettings,
		enumList.AdditionalSettings.ThrottleRecursiveCalls
	) and true or false
	v4.AdditionalSettings.SandboxCalls = table.find(self.AdditionalSettings, enumList.AdditionalSettings.SandboxCalls) and true or false

	for _, rule in pairs(self.Rules) do
		if rule.Kind == enumList.RuleType.ClosureRestriction then
			v4.SLVMBlock[rule.Data] = rule.Message or `The closure '{debug.info(rule.Data, "n")}' has been blocked within this SLVM environment`
		elseif rule.Kind == enumList.RuleType.UserDataRestriction then
			v4.SLVMBlock[rule.Data] = rule.Message or "This userdata / instance has been blocked within this SLVM environment"
		elseif rule.Kind == enumList.RuleType.TableRestriction then
			v4.SLVMBlock[rule.Data] = rule.Message or "This table / library has been blocked within this SLVM environment"
		elseif rule.Kind == enumList.RuleType.TypeRestriction then
			v4.SLVMTypes[rule.Data] = rule.Message or `The variable type '{type(rule.Data)}' has been blocked withing this SLVM encrionment`
		end
	end

	for k, replacedClosure in pairs(self.ReplacedClosures) do
		v4.SLVMReplaced[k] = replacedClosure
	end

	for k, readHook in pairs(self.ReadHooks) do
		v4.SLVMReadHook[k] = readHook
	end

	for k, writeHook in pairs(self.WriteHooks) do
		v4.SLVMWriteHook[k] = writeHook
	end

	return LuaVM(value, self.LVMSettings.ChunkName, env, v4)
end

function v2:Run(value: string, ...)
	assert(type(value) == "string", "Expected string as argument #1 for 'SLVM.Run'")
	local compile, v4 = self:Compile(value)

	if not compile then
		error(v4, 2)
	end

	return compile(...)
end

function v2:AddRule(p2)
	local v4

	if type(p2) == "table" then
		v4 = p2.IsA
	else
		v4 = false
	end

	assert(v4, "Expected Rule as argument #1 for 'SLVM.AddRule'")
	table.insert(self.Rules, p2)
end

function v2.RemoveRule(p, value)
	assert(
		type(value) == "table" and value.IsA or type(value) == "number",
		"Expected Rule or number as argument #1 for 'SLVM.RemoveRule'"
	)

	if type(value) == "table" then
		local index = table.find(p.Rules, value)

		if not index then
			error("The rule isn't added to the SLVM rules", 2)
		end

		table.remove(p.Rules, index)
	else
		if not p.Rules[value] then
			error("The rule at the given Index wasn't found", 2)
		end

		table.remove(p.Rules, value)
	end
end

function v2:IsAdditionalSettingEnabled(value)
	local isA = utilities:IsA(value, "EnumItem")
	assert(
		type(value) == "table" and value.Name or type(value) == "string" or type(value) == "number",
		"Expected SLVMEnumItem or string or number as argument #1 for 'SLVM.IsAdditionalSettingEnabled'"
	)
	local v4

	if isA then
		v4 = value
	elseif type(value) == "number" then
		v4 = utilities:FindEnumItemByValue(enumList.RuleType, value)

		if not value then
			error("Provided EnumItem value does not exist for the expected SubEnum", 2)
		end
	elseif type(value) == "string" then
		v4 = utilities:FindEnumItemByName(enumList.RuleType, value)

		if not value then
			error("Provided EnumItem value does not exist for the expected SubEnum", 2)
		end
	else
		v4 = value
	end

	if table.find(self.AdditionalSettings, v4) then
		return true
	end

	return false
end

function v2:EnableAdditionalSetting(value)
	local isA = utilities:IsA(value, "EnumItem")
	assert(
		type(value) == "table" and value.Name or type(value) == "string" or type(value) == "number",
		"Expected SLVMEnumItem or string or number as argument #1 for 'SLVM.EnableAdditionalSetting'"
	)
	local v4

	if isA then
		v4 = value
	elseif type(value) == "number" then
		v4 = utilities:FindEnumItemByValue(enumList.RuleType, value)

		if not value then
			error("Provided EnumItem value does not exist for the expected SubEnum", 2)
		end
	elseif type(value) == "string" then
		v4 = utilities:FindEnumItemByName(enumList.RuleType, value)

		if not value then
			error("Provided EnumItem value does not exist for the expected SubEnum", 2)
		end
	else
		v4 = value
	end

	if table.find(self.AdditionalSettings, v4) then
		error("This additional setting is already enabled", 2)
	end

	table.insert(self.AdditionalSettings, v4)
end

function v2.DisableAdditionalSetting(p, value)
	local isA = utilities:IsA(value, "EnumItem")
	assert(
		type(value) == "table" and value.Name or type(value) == "string" or type(value) == "number",
		"Expected SLVMEnumItem or string or number as argument #1 for 'SLVM.DisableAdditionalSetting'"
	)
	local v4

	if isA then
		v4 = value
	elseif type(value) == "number" then
		v4 = utilities:FindEnumItemByValue(enumList.RuleType, value)

		if not value then
			error("Provided EnumItem value does not exist for the expected SubEnum", 2)
		end
	elseif type(value) == "string" then
		v4 = utilities:FindEnumItemByName(enumList.RuleType, value)

		if not value then
			error("Provided EnumItem value does not exist for the expected SubEnum", 2)
		end
	else
		v4 = value
	end

	local index = table.find(p.AdditionalSettings, v4)

	if not index then
		error("This additional setting is not enabled", 2)
	end

	table.remove(p.AdditionalSettings, index)
end

function v2:ReplaceClosure(callback, callback2)
	assert(type(callback) == "function", "Expected function as argument #1 for 'SLVM.ReplaceClosure'")
	assert(type(callback2) == "function", "Expected function as argument #2 for 'SLVM.ReplaceClosure'")
	local v4 = self.ReplacedClosures[callback] or callback
	self.ReplacedClosures[callback] = callback2
	return v4
end

function v2.AddReadHook(p, value, callback)
	assert(
		type(value) == "table" or typeof(value) == "Instance",
		"Expected table or Instance as argument #1 for 'SLVM.AddReadHook'"
	)
	assert(type(callback) == "function", "Expected function as argument #2 for 'SLVM.AddReadHook'")
	local v4 = typeof(value) == "Instance" and "InstanceHook" or value
	p.ReadHooks[v4] = callback
end

function v2.AddWriteHook(p, value, callback)
	assert(
		type(value) == "table" or typeof(value) == "Instance",
		"Expected table or Instance as argument #1 for 'SLVM.AddWriteHook'"
	)
	assert(type(callback) == "function", "Expected function as argument #2 for 'SLVM.AddWriteHook'")
	local v4 = typeof(value) == "Instance" and "InstanceHook" or value
	p.WriteHooks[v4] = callback
end

function v2:CheckCString(value: string, value2: string)
	assert(type(value) == "string", "Expected string as argument #1 for 'SLVM.CheckCString'")
	assert(type(value2) == "string", "Expected string as argument #2 for 'SLVM.CheckCString'")
	return value == string.gsub(value2, "%z.*", "")
end

function v2.ChangeChunkName(p, chunkName: string)
	assert(type(chunkName) == "string", "Expected string as argument #1 for 'SLVM.ChangeChunkName'")
	p.LVMSettings.ChunkName = chunkName
end

function v2.DeleteCreatedInstances(p, callback)
	assert(
		type(callback) == "function" or type(callback) == "nil",
		"Expected function or nil as argument #1 for 'SLVM.DeleteCreatedInstances'"
	)

	for k, createdInstance in pairs(p.CreatedInstances) do
		if not (not callback or callback(createdInstance)) then
			continue
		end

		createdInstance:Destroy()
		p.CreatedInstances[k] = nil
	end
end

function v2:CloseCreatedThreads(callback)
	assert(
		type(callback) == "function" or type(callback) == "nil",
		"Expected function or nil as argument #1 for 'SLVM.CloseCreatedThreads'"
	)

	for k, createdThread in pairs(self.CreatedThreads) do
		if not (not callback or callback(createdThread)) then
			continue
		end

		pcall(coroutine.close, createdThread)
		self.CreatedThreads[k] = nil
	end
end

return {
	LuaVM = luaVM,
	Enum = enumList,
	Rule = Rule
}