local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(script.Parent.Types)
local Metadata = {}
local v = {}

function Metadata.findModule(instance)
	if typeof(instance) == "Instance" then
		return instance
	end

	local child = nil

	for childName in string.gmatch(instance, "([^.]+)") do
		child = (child or ReplicatedStorage.EffectContainer):FindFirstChild(childName)
	end

	return child
end

function Metadata.getModule(p)
	local module = Metadata.findModule(p)
	assert(module, "Effect not found!: " .. tostring(p))
	return module
end

function Metadata.getName(parent)
	local effectContainer = ReplicatedStorage:WaitForChild("EffectContainer")

	if not (effectContainer and parent:IsDescendantOf(effectContainer)) then
		return parent.Name
	end

	local v2 = {}

	while parent and parent ~= effectContainer do
		table.insert(v2, 1, parent.Name)
		parent = parent.Parent
	end

	return table.concat(v2, ".")
end

local function asEffectModule(moduleScript)
	if typeof(moduleScript) ~= "Instance" or not moduleScript:IsA("ModuleScript") then
		return nil
	end

	local effectContainer = ReplicatedStorage:WaitForChild("EffectContainer")

	if effectContainer and moduleScript:IsDescendantOf(effectContainer) then
		return moduleScript
	end

	return nil
end

local function normalizeSource(value: string)
	if string.sub(value, 1, 1) == "@" then
		value = string.sub(value, 2)
	end

	local v2 = string.find(value, "/src/", 1, true)

	if v2 then
		value = string.sub(value, v2 + 5)
	end

	local v3 = string.gsub(value, "\\", "/")
	local v4 = string.gsub(v3, "^src/", "")
	local v5 = string.gsub(v4, "%.luau$", "")
	local v6 = string.gsub(v5, "%.lua$", "")
	local v7 = string.gsub(v6, "/init$", "")
	local v8 = string.gsub(v7, "/", ".")

	if string.sub(v8, -5) == ".init" then
		return (string.sub(v8, 1, #v8 - 5))
	end

	return v8
end

local function sourceMatchesModule(value: string, instance)
	local fullName = instance:GetFullName()

	if value == fullName or string.sub(value, -#fullName) == fullName then
		return true
	end

	local source = normalizeSource(value)
	return source == fullName or string.sub(source, -#fullName) == fullName
end

local function resolveModuleFromSource(value: string?)
	if type(value) ~= "string" or value == "" then
		return nil
	end

	local v2 = v[value]

	if v2 ~= nil then
		return v2 or nil
	end

	local effectContainer = ReplicatedStorage:WaitForChild("EffectContainer")

	if effectContainer then
		for _, descendant in effectContainer:GetDescendants() do
			local v3 = asEffectModule(descendant)

			if not (v3 and sourceMatchesModule(value, v3)) then
				continue
			end

			v[value] = v3
			return v3
		end
	end

	v[value] = false
	return nil
end

local function getFunctionSource(implementationFunction)
	local success, result = pcall(function()
		return debug.info(implementationFunction, "s")
	end)

	if success and type(result) == "string" then
		return result
	end

	return nil
end

local function getImplementationFunction(value)
	if type(value) == "function" then
		return value
	end

	if type(value) == "table" then
		local v2 = rawget(value, "new")

		if type(v2) == "function" then
			return v2
		end
	end

	return nil
end

function Metadata.fromImplementation(p)
	local implementationFunction = getImplementationFunction(p)

	if not implementationFunction then
		return nil
	end

	local success, result = pcall(getfenv, implementationFunction)
	local v2

	if success and type(result) == "table" then
		v2 = asEffectModule(result.script)
	end

	return v2 or resolveModuleFromSource(getFunctionSource(implementationFunction))
end

local function getImplementationSource(implementation)
	local implementationFunction = getImplementationFunction(implementation)

	if implementationFunction then
		return (getFunctionSource(implementationFunction))
	end

	return nil
end

function Metadata:resolve()
	local v2 = asEffectModule(self.Module)
	local name = self.Name
	local v3

	if name then
		v3 = asEffectModule(Metadata.findModule(name))
	end

	if not v2 and self.Implementation ~= nil then
		v2 = Metadata.fromImplementation(self.Implementation)
	end

	local module = v2 or v3

	if not module then
		return module, name
	end

	if not name or v3 ~= module then
		name = Metadata.getName(module)
	end

	self.Module = module
	self.Name = name
	return module, name
end

function Metadata.forRemote(data)
	local resolved, name = Metadata.resolve(data)

	if not resolved then
		local Global = require(game.ReplicatedStorage.Global)
		Global.TestGameWarn(
			"Effect missing module for replication",
			name,
			typeof(data.Implementation),
			getImplementationSource(data.Implementation),
			debug.traceback()
		)
	end

	assert(resolved, "Effect missing module for replication: " .. tostring(name))
	return {
		Name = name,
		Module = resolved,
		Id = data.Id,
		Async = data.Async,
		Sender = data.Sender
	}
end

return Metadata