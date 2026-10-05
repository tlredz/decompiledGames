local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Constants = require(script.Parent.Constants)
local HotReloader = {}
HotReloader.__index = HotReloader

function HotReloader.new()
	return (setmetatable({
		_listeners = {},
		_clonedModules = {}
	}, HotReloader))
end

function HotReloader:destroy()
	for _, _listener in pairs(self._listeners) do
		_listener:Disconnect()
	end

	self._listeners = {}

	for _, _clonedModule in pairs(self._clonedModules) do
		_clonedModule:Destroy()
	end

	self._clonedModules = {}
end

function HotReloader:listen(instance, callback, callback2)
	if RunService:IsStudio() then
		local changedConnection = instance.Changed:Connect(function()
			local isAncestor = game:IsAncestorOf(instance)
			local v = {
				isReloading = isAncestor,
				originalModule = instance
			}

			if self._clonedModules[instance] then
				callback2(self._clonedModules[instance], v)
				self._clonedModules[instance]:Destroy()
			else
				callback2(instance, v)
			end

			if not isAncestor then
				return
			end

			local clone = instance:Clone()
			CollectionService:AddTag(clone, Constants.CollectionServiceTag)
			clone.Parent = instance.Parent
			self._clonedModules[instance] = clone
			callback(clone, {
				originalModule = instance,
				isReloading = true
			})
		end)
		table.insert(self._listeners, changedConnection)
	end

	callback(instance, {
		originalModule = instance,
		isReloading = false
	})
end

function HotReloader:scan(folder, callback, callback2)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function add(moduleScript)
		self:listen(moduleScript, callback, callback2)
	end

	for _, moduleScript in folder:GetDescendants() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		add(moduleScript) -- equivalent call inferred; original call site unknown
	end

	local descendantAddedConnection = folder.DescendantAdded:Connect(function(moduleScript)
		if moduleScript:IsA("ModuleScript") and not CollectionService:HasTag(
			moduleScript,
			Constants.CollectionServiceTag
		) then
			add(moduleScript) -- equivalent call inferred; original call site unknown
		end
	end)
	table.insert(self._listeners, descendantAddedConnection)
end

return HotReloader