local v = {
	ServicePromises = true,
	Middleware = nil,
	PerServiceMiddleware = {}
}
local v2 = nil
local Players = game:GetService("Players")
local KnitClient = {
	Player = Players.LocalPlayer,
	Util = script.Parent.Parent
}
local Promise = require(KnitClient.Util.Promise)
local Comm = require(KnitClient.Util.Comm)
local clientComm = Comm.ClientComm
local v3 = {}
local v4 = {}
local services = nil
local flag = false
local flag2 = false
local bindableEvent = Instance.new("BindableEvent")

local function DoesControllerExist(p: string)
	return v3[p] ~= nil
end

local function GetServicesFolder()
	if not services then
		services = script.Parent:WaitForChild("Services")
	end

	return services
end

local function GetMiddlewareForService(p: string)
	local v5 = v2.Middleware == nil and {} or v2.Middleware
	local v6 = v2.PerServiceMiddleware[p]

	if v6 == nil then
		return v5
	end

	return v6
end

local function BuildService(p: string)
	if not services then
		services = script.Parent:WaitForChild("Services")
	end

	local v5 = services
	local v6 = v2.Middleware == nil and {} or v2.Middleware
	local v7 = v2.PerServiceMiddleware[p]

	if v7 == nil then
		v7 = v6
	end

	local object = clientComm.new(v5, v2.ServicePromises, p):BuildObject(v7.Inbound, v7.Outbound)
	v4[p] = object
	return object
end

function KnitClient.CreateController(p)
	assert(type(p) == "table", (`Controller must be a table; got {type(p)}`))
	assert(type(p.Name) == "string", (`Controller.Name must be a string; got {type(p.Name)}`))
	assert(#p.Name > 0, "Controller.Name must be a non-empty string")
	local name = p.Name
	assert(v3[name] == nil, (`Controller {p.Name} already exists`))
	v3[p.Name] = p
	return p
end

function KnitClient.AddControllers(instance)
	local modules = {}

	for _, moduleScript in instance:GetChildren() do
		if moduleScript:IsA("ModuleScript") then
			table.insert(modules, require(moduleScript))
		end
	end

	return modules
end

function KnitClient.AddControllersDeep(folder)
	local modules = {}

	for _, moduleScript in folder:GetDescendants() do
		if moduleScript:IsA("ModuleScript") then
			table.insert(modules, require(moduleScript))
		end
	end

	return modules
end

function KnitClient:GetService()
	local v5 = v4[self]

	if v5 then
		return v5
	end

	assert(flag, "Cannot call GetService until Knit has been started")
	assert(type(self) == "string", (`ServiceName must be a string; got {type(self)}`))

	if not services then
		services = script.Parent:WaitForChild("Services")
	end

	local v6 = services
	local v7 = v2.Middleware == nil and {} or v2.Middleware
	local v8 = v2.PerServiceMiddleware[self]

	if v8 == nil then
		v8 = v7
	end

	local object = clientComm.new(v6, v2.ServicePromises, self):BuildObject(v8.Inbound, v8.Outbound)
	v4[self] = object
	return object
end

function KnitClient.GetController(value: string)
	local v5 = v3[value]

	if v5 then
		return v5
	end

	assert(flag, "Cannot call GetController until Knit has been started")
	assert(type(value) == "string", (`ControllerName must be a string; got {type(value)}`))
	error(`Could not find controller "{value}". Check to verify a controller with this name exists.`, 2)
end

function KnitClient.Start(p)
	if flag then
		return Promise.reject("Knit already started")
	end

	flag = true

	if p == nil then
		v2 = v
	else
		assert(typeof(p) == "table", (`KnitOptions should be a table or nil; got {typeof(p)}`))
		v2 = p

		for k, v5 in v do
			if v2[k] == nil then
				v2[k] = v5
			end
		end
	end

	if type(v2.PerServiceMiddleware) ~= "table" then
		v2.PerServiceMiddleware = {}
	end

	return Promise.new(function(callback)
		local v5 = {}

		for _, v6 in v3 do
			if type(v6.KnitInit) ~= "function" then
				continue
			end

			local v7 = v6
			table.insert(v5, Promise.new(function(callback2)
				debug.setmemorycategory(v7.Name)
				v7:KnitInit()
				callback2()
			end))
		end

		callback(Promise.all(v5))
	end):andThen(function()
		for _, v5 in v3 do
			if type(v5.KnitStart) ~= "function" then
				continue
			end

			local v6 = v5
			task.spawn(function()
				debug.setmemorycategory(v6.Name)
				v6:KnitStart()
			end)
		end

		flag2 = true
		bindableEvent:Fire()
		task.defer(function()
			bindableEvent:Destroy()
		end)
	end)
end

function KnitClient.OnStart()
	if flag2 then
		return Promise.resolve()
	end

	return Promise.fromEvent(bindableEvent.Event)
end

return KnitClient