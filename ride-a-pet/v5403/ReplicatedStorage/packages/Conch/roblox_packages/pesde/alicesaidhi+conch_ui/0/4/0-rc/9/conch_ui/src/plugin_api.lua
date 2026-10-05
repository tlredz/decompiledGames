local RunService = game:GetService("RunService")
local module = require("@self/folder")
require("@self/semver")

-- equivalent calls inferred from this helper; original call sites unknown
local function bind_function(parent, childName: string, onInvoke)
	local bindableFunction = parent:FindFirstChild(childName)

	if bindableFunction then
		assert(bindableFunction:IsA("BindableFunction"))
		bindableFunction.OnInvoke = onInvoke
	else
		local bindableFunction2 = Instance.new("BindableFunction")
		bindableFunction2.OnInvoke = onInvoke
		bindableFunction2.Name = childName
		bindableFunction2.Parent = parent
	end
end

local function bind_event(parent, childName: string)
	local bindableEvent = parent:FindFirstChild(childName)

	if bindableEvent then
		assert(bindableEvent:IsA("BindableEvent"))
		return bindableEvent.Event, function(...)
			return bindableEvent:Fire(...)
		end
	end

	local bindableEvent2 = Instance.new("BindableEvent")
	bindableEvent2.Name = childName
	bindableEvent2.Parent = parent
	return bindableEvent2.Event, function(...)
		bindableEvent2:Fire(...)
	end
end

local function index_folder(parent, name: string)
	local child = parent:FindFirstChild(name)

	if child then
		return child
	end

	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local class = {}
local PluginApi = {}

function PluginApi.get_signal()
	local v = {}

	local function fire(...)
		for _, v2 in v do
			v2(...)
		end
	end

	return setmetatable(v, class), fire
end

function PluginApi.expose(p, p2: string, p3)
	if RunService:IsStudio() == false then
		return
	end

	if typeof(p3) ~= "table" then
		error("can only serialize tables")
	end

	local obtain_plugins_api = module.obtain_plugins_api(p2, p)
	local v = {}
	local process

	process = function(parent, items)
		if v[items] then
			error("cannot serialize api recursively")
		end

		v[items] = true
		local v2 = parent:FindFirstChild("events")

		if not v2 then
			v2 = Instance.new("Folder")
			v2.Name = "events"
			v2.Parent = parent
		end

		local v3 = parent:FindFirstChild("functions")

		if not v3 then
			v3 = Instance.new("Folder")
			v3.Name = "functions"
			v3.Parent = parent
		end

		local parent2 = parent:FindFirstChild("tables")

		if not parent2 then
			parent2 = Instance.new("Folder")
			parent2.Name = "tables"
			parent2.Parent = parent
		end

		local function fn(p4)
			return items[p4]
		end

		bind_function(parent, "__index", fn) -- equivalent call inferred; original call site unknown

		for childName, item in items do
			if typeof(item) == "table" and getmetatable(item) ~= class then
				local v6 = parent2:FindFirstChild(childName)

				if not v6 then
					v6 = Instance.new("Folder")
					v6.Name = childName
					v6.Parent = parent2
				end

				process(v6, item)
			elseif typeof(item) == "function" then
				bind_function(v3, childName, item) -- equivalent call inferred; original call site unknown
			elseif typeof(item) == "table" and getmetatable(item) == class then
				local _, v5 = bind_event(v2, childName)
				table.insert(item, v5)
			end
		end
	end

	process(obtain_plugins_api, p3)
end

function PluginApi.load(_)
	if RunService:IsStudio() == false then
		error("cannot load outside of studio")
	end

	local process

	process = function(p, parent)
		local v = parent:FindFirstChild("events")

		if not v then
			v = Instance.new("Folder")
			v.Name = "events"
			v.Parent = parent
		end

		local v2 = parent:FindFirstChild("functions")

		if not v2 then
			v2 = Instance.new("Folder")
			v2.Name = "functions"
			v2.Parent = parent
		end

		local v3 = parent:FindFirstChild("tables")

		if not v3 then
			v3 = Instance.new("Folder")
			v3.Name = "tables"
			v3.Parent = parent
		end

		for _, bindableEvent in v:GetChildren() do
			assert(bindableEvent:IsA("BindableEvent"))
			p[bindableEvent.Name] = bindableEvent.Event
		end

		for _, bindableFunction in v2:GetChildren() do
			assert(bindableFunction:IsA("BindableFunction"))
			local v4 = bindableFunction

			p[bindableFunction.Name] = function(...)
				return v4:Invoke(...)
			end
		end

		for _, child in v3:GetChildren() do
			p[child.Name] = process({}, child)
		end

		return p
	end

	return (process({}, module))
end

PluginApi.find_plugins_api = module.find_plugins_api
PluginApi.wait_for_first_api = module.wait_for_first_api
return PluginApi