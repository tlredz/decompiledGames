local RunService = game:GetService("RunService")
local Util = require(script.Parent.Util)
local v = {
	TypeMethods = Util.MakeDictionary({
		"Transform",
		"Validate",
		"Autocomplete",
		"Parse",
		"DisplayName",
		"Listable",
		"ValidateOnce",
		"Prefixes",
		"Default",
		"ArgumentOperatorAliases"
	}),
	CommandMethods = Util.MakeDictionary({
		"Name",
		"Aliases",
		"AutoExec",
		"Description",
		"Args",
		"Run",
		"ClientRun",
		"Data",
		"Group"
	}),
	CommandArgProps = Util.MakeDictionary({
		"Name",
		"Type",
		"Description",
		"Optional",
		"Default"
	}),
	Types = {},
	TypeAliases = {},
	Commands = {},
	CommandsArray = {},
	Cmdr = nil,
	Hooks = {
		BeforeRun = {},
		AfterRun = {}
	},
	Stores = setmetatable({}, {
		__index = function(p, p2)
			p[p2] = {}
			return p[p2]
		end
	}),
	AutoExecBuffer = {},
	RegisterType = function(self, name, p)
		if not name or typeof(name) ~= "string" then
			error("Invalid type name provided: nil")
		end

		if not name:find("^[%d%l]%w*$") then
			error(("Invalid type name provided: \"%s\", type names must be alphanumeric and start with a lower-case letter or a digit."):format(name))
		end

		for k in pairs(p) do
			if self.TypeMethods[k] == nil then
				error("Unknown key/method in type \"" .. name .. "\": " .. k)
			end
		end

		if self.Types[name] ~= nil then
			error(("Type \"%s\" has already been registered."):format(name))
		end

		p.Name = name
		p.DisplayName = p.DisplayName or name
		self.Types[name] = p

		if p.Prefixes then
			self:RegisterTypePrefix(name, p.Prefixes)
		end
	end,
	RegisterTypePrefix = function(self, p2, p3)
		if not self.TypeAliases[p2] then
			self.TypeAliases[p2] = p2
		end

		self.TypeAliases[p2] = ("%s %s"):format(self.TypeAliases[p2], p3)
	end,
	RegisterTypeAlias = function(p, p2, p3)
		assert(p.TypeAliases[p2] == nil, ("Type alias %s already exists!"):format(p3))
		p.TypeAliases[p2] = p3
	end,
	RegisterTypesIn = function(self, instance)
		for _, moduleScript in pairs(instance:GetChildren()) do
			if moduleScript:IsA("ModuleScript") then
				moduleScript.Parent = self.Cmdr.ReplicatedRoot.Types
				local module = require(moduleScript)
				module(self)
			else
				self:RegisterTypesIn(moduleScript)
			end
		end
	end
}
v.RegisterHooksIn = v.RegisterTypesIn

function v:RegisterCommandObject(p, _)
	for k in pairs(p) do
		if self.CommandMethods[k] == nil then
			error("Unknown key/method in command " .. (p.Name or "unknown command") .. ": " .. k)
		end
	end

	if p.Args then
		for k, arg in pairs(p.Args) do
			if type(arg) ~= "table" then
				continue
			end

			for k2 in pairs(arg) do
				if self.CommandArgProps[k2] == nil then
					error(("Unknown property in command \"%s\" argument #%d: %s"):format(p.Name or "unknown", k, k2))
				end
			end
		end
	end

	if p.AutoExec and RunService:IsClient() then
		table.insert(self.AutoExecBuffer, p.AutoExec)
		self:FlushAutoExecBufferDeferred()
	end

	local command = self.Commands[p.Name:lower()]

	if command and command.Aliases then
		for _, alias in pairs(command.Aliases) do
			self.Commands[alias:lower()] = nil
		end
	elseif not command then
		table.insert(self.CommandsArray, p)
	end

	self.Commands[p.Name:lower()] = p

	if p.Aliases then
		for _, alias in pairs(p.Aliases) do
			self.Commands[alias:lower()] = p
		end
	end
end

function v:RegisterCommand(moduleScript, moduleScript2, callback)
	local module = require(moduleScript)
	assert(
		typeof(module) == "table",
		(`Invalid return value from command script "{moduleScript.Name}" (CommandDefinition expected, got {typeof(module)})`)
	)

	if moduleScript2 then
		assert(RunService:IsServer(), "The commandServerScript parameter is not valid for client usage.")
		module.Run = require(moduleScript2)
	end

	if callback and not callback(module) then
		return
	end

	self:RegisterCommandObject(module)
	moduleScript.Parent = self.Cmdr.ReplicatedRoot.Commands
end

function v:RegisterCommandsIn(instance, p)
	local v2 = {}
	local v3 = {}

	for _, moduleScript in pairs(instance:GetChildren()) do
		if moduleScript:IsA("ModuleScript") then
			if moduleScript.Name:find("Server") then
				v2[moduleScript] = true
			else
				local child = instance:FindFirstChild(moduleScript.Name .. "Server")

				if child then
					v3[child] = true
				end

				self:RegisterCommand(moduleScript, child, p)
			end
		else
			self:RegisterCommandsIn(moduleScript, p)
		end
	end

	for k in pairs(v2) do
		if not v3[k] then
			warn("Command script " .. k.Name .. " was skipped because it has 'Server' in its name, and has no equivalent shared script.")
		end
	end
end

function v:RegisterDefaultCommands(p)
	assert(RunService:IsServer(), "RegisterDefaultCommands cannot be called from the client.")
	local v2 = type(p) == "table"

	if v2 then
		p = Util.MakeDictionary(p)
	end

	self:RegisterCommandsIn(self.Cmdr.DefaultCommandsFolder, v2 and function(p2)
		return p[p2.Group] or false
	end or p)
end

function v.GetCommand(p, value)
	return p.Commands[(value or ""):lower()]
end

function v.GetCommands(p)
	return p.CommandsArray
end

function v.GetCommandNames(p)
	local names = {}

	for _, v2 in pairs(p.CommandsArray) do
		table.insert(names, v2.Name)
	end

	return names
end

v.GetCommandsAsStrings = v.GetCommandNames

function v.GetTypeNames(p)
	local result = {}

	for k in pairs(p.Types) do
		table.insert(result, k)
	end

	return result
end

function v.GetType(p, p2)
	return p.Types[p2]
end

function v.GetTypeName(p, p2)
	return p.TypeAliases[p2] or p2
end

function v.RegisterHook(p, p2, callback, value)
	if not p.Hooks[p2] then
		error(("Invalid hook name: %q"):format(p2), 2)
	end

	table.insert(p.Hooks[p2], {
		callback = callback,
		priority = value or 0
	})
	table.sort(p.Hooks[p2], function(a, b)
		return a.priority < b.priority
	end)
end

v.AddHook = v.RegisterHook

function v.GetStore(p, p2)
	return p.Stores[p2]
end

function v:FlushAutoExecBufferDeferred()
	if self.AutoExecFlushConnection then
		return
	end

	self.AutoExecFlushConnection = RunService.Heartbeat:Connect(function()
		self.AutoExecFlushConnection:Disconnect()
		self.AutoExecFlushConnection = nil
		self:FlushAutoExecBuffer()
	end)
end

function v:FlushAutoExecBuffer()
	for _, list in ipairs(self.AutoExecBuffer) do
		for _, v2 in ipairs(list) do
			self.Cmdr.Dispatcher:EvaluateAndRun(v2)
		end
	end

	self.AutoExecBuffer = {}
end

return function(cmdr)
	v.Cmdr = cmdr
	return v
end