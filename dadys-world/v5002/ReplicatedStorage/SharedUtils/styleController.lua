local StyleController = {}
StyleController.__index = StyleController
local tweenHelpers = require(script.Parent.tweenHelpers)
local loadStylesheetsRecursive

loadStylesheetsRecursive = function(instance, p, modules)
	for _, child in pairs(instance:GetChildren()) do
		if child:IsA("ModuleScript") then
			local v = p .. "." .. child.Name
			local module = require(child)
			modules[v] = module
		elseif child:IsA("Folder") then
			loadStylesheetsRecursive(child, p .. "." .. child.Name, modules)
		end
	end
end

function StyleController.new(instance)
	local object = setmetatable({}, StyleController)
	object.stylesheets = {}
	object._threads = {}
	object._connections = {}
	object._applyConnections = {}
	local stylesheets = script.Parent:FindFirstChild("stylesheets")

	if stylesheets then
		loadStylesheetsRecursive(stylesheets, "Shared", object.stylesheets)
	end

	if instance then
		for _, moduleScript in pairs(instance:GetChildren()) do
			if moduleScript:IsA("ModuleScript") then
				object:AddStylesheet(moduleScript)
			end
		end
	end

	return object
end

function StyleController:AddStylesheet(moduleScript)
	local stylesheets = self.stylesheets
	local name = moduleScript.Name
	local module = require(moduleScript)
	stylesheets[name] = module
end

function StyleController:Apply(instance, p)
	if not instance then
		return
	end

	local stylesheet = self.stylesheets[p]

	if not stylesheet then
		warn("unknown stylesheet:", p)
		return
	end

	local v = self._applyConnections[instance] == nil

	if self._applyConnections[instance] then
		for _, v2 in ipairs(self._applyConnections[instance]) do
			local connection = v2
			pcall(function()
				connection:Disconnect()
			end)
		end
	end

	self._applyConnections[instance] = {}

	if v then
		instance.Destroying:Once(function()
			self._applyConnections[instance] = nil
			self._connections[instance] = nil
		end)
	end

	self:_applyToGui(instance, stylesheet)
	table.insert(self._applyConnections[instance], instance:GetAttributeChangedSignal("state"):Connect(function()
		local state = instance:GetAttribute("state")

		if stylesheet.states then
			for _, _thread in ipairs(self._threads) do
				task.cancel(_thread)
			end

			runFunction(stylesheet.states[state], instance, self)
		end
	end))
	table.insert(self._applyConnections[instance], instance.AttributeChanged:Connect(function(attributeName)
		local attribute = instance:GetAttribute(attributeName)

		if typeof(attribute) == "boolean" and stylesheet.flags and stylesheet.flags[attributeName] then
			runFunction(stylesheet.flags[attributeName], instance, attribute, self)
		end
	end))
end

function StyleController:Detach(p2)
	if self._applyConnections[p2] then
		for _, v in ipairs(self._applyConnections[p2]) do
			local connection = v
			pcall(function()
				connection:Disconnect()
			end)
		end

		self._applyConnections[p2] = nil
	end

	if self._connections[p2] then
		for k, list in pairs(self._connections[p2]) do
			for _, v in ipairs(list) do
				local connection = v
				pcall(function()
					connection:Disconnect()
				end)
			end

			self._connections[p2][k] = nil
		end

		self._connections[p2] = nil
	end
end

function StyleController.SetState(_, instance, state)
	instance:SetAttribute("state", state)
end

function StyleController.SetFlag(_, instance, p, p2)
	instance:SetAttribute(p, p2)
end

function StyleController.IsState(_, instance, p)
	return instance:GetAttribute("state") == p
end

function StyleController.GetState(_, instance, _)
	return instance:GetAttribute("state")
end

function StyleController:AddConnection(p2, p3, p4)
	if not self._connections[p2] then
		self._connections[p2] = {}
	end

	self._connections[p2][p3] = self._connections[p2][p3] or {}
	table.insert(self._connections[p2][p3], p4)
end

function StyleController:ClearConnections(p2, p3)
	if not self._connections[p2] then
		return
	end

	local v = self._connections[p2][p3]

	if v then
		for _, connection in ipairs(v) do
			connection:Disconnect()
		end

		self._connections[p2][p3] = nil
	end
end

function StyleController:_applyToGui(instance, object)
	object:Init({
		tweens = tweenHelpers,
		getState = function(instance2)
			return instance2:GetAttribute("state")
		end,
		isState = function(instance2, p2)
			return instance2:GetAttribute("state") == p2
		end,
		isShown = function(parent)
			while parent do
				if parent:IsA("GuiObject") then
					if not parent.Visible then
						return false
					end
				elseif parent:IsA("LayerCollector") then
					return parent.Enabled
				end

				parent = parent.Parent
			end

			return false
		end
	})
	runFunction(object.base, instance, self)
	local state = instance:GetAttribute("state")

	if state and object.states then
		runFunction(object.states[state], instance, self)
	end

	if object.flags then
		for attributeName, flag in pairs(object.flags) do
			local attribute = instance:GetAttribute(attributeName)

			if typeof(attribute) == "boolean" then
				runFunction(flag, instance, attribute, self)
			end
		end
	end
end

function runFunction(callback, ...)
	if typeof(callback) == "function" then
		callback(...)
	end
end

return StyleController