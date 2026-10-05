local Signal = require(script.Parent.Signal)
local MenuManager = {}
MenuManager._registry = {}
MenuManager._instances = {}
MenuManager._history = {}
MenuManager._overlays = {}
MenuManager._backGuards = {}
MenuManager._connections = {}
MenuManager._signals = {
	Opened = Signal.new(),
	Closed = Signal.new()
}

function MenuManager:_setVisible(p2, p3, p4)
	local v = self._registry[p2]

	if not v then
		return
	end

	if p3 then
		v.controller:Open()
	else
		v.controller:Close(p4)
	end
end

function MenuManager:_resolve(p2)
	if self._registry[p2] then
		return p2
	end

	for k, v in pairs(self._registry) do
		local menu = v.controller and v.controller.menu
		local gui = menu and menu.gui

		if gui and gui.Name == p2 then
			return k
		end
	end

	return nil
end

function MenuManager:Setup(parent, options)
	local exclude = (options or {}).exclude or {}
	local names = {}
	local names2 = {}
	local notMigrated = parent:FindFirstChild("NotMigrated")

	if notMigrated then
		for _, child in pairs(notMigrated:GetChildren()) do
			child.Parent = parent
		end
	end

	for _, moduleScript in ipairs(parent:GetChildren()) do
		if not moduleScript:IsA("ModuleScript") or table.find(exclude, moduleScript.Name) then
			continue
		end

		local success, result = pcall(require, moduleScript)

		if success then
			if type(result) == "table" and result.init then
				local instance = result.init()

				if instance then
					self._instances[moduleScript.Name] = instance
				end

				if instance then
					self:Register(moduleScript.Name, instance, {
						isOverlay = result.isOverlay or false,
						instance = instance
					})
					table.insert(names2, moduleScript.Name)
				else
					table.insert(names, moduleScript.Name)
				end
			end
		else
			warn("[MenuManager] failed to load module:", moduleScript.Name, "-", result)
		end
	end

	if #names > 0 then
		table.sort(names2)
		local v = { "[MenuManager] modules migrated to UIController:" }

		for _, v2 in ipairs(names2) do
			table.insert(v, "  [✅] " .. v2)
		end

		warn(table.concat(v, "\n"))
		table.sort(names)
		local v2 = { "[MenuManager] modules not yet using UIController:" }

		for _, v3 in ipairs(names) do
			table.insert(v2, "  [❌] " .. v3)
		end

		warn(table.concat(v2, "\n"))
	end
end

function MenuManager:Register(p, controller, options)
	local v = options or {}
	self._registry[p] = {
		controller = controller,
		isOverlay = v.isOverlay or false,
		instance = v.instance or nil
	}
	self:_setVisible(p, false)
end

function MenuManager:GetInstance(p)
	local v = self:_resolve(p) or p
	local v2 = self._registry[v]

	if not v2 then
		return self._instances[v]
	end

	if v2.instance then
		return v2.instance
	end

	if v2.controller then
		return v2.controller
	end

	return self._instances[v]
end

function MenuManager:Open(p)
	local _resolve = self:_resolve(p)

	if not _resolve then
		warn("MenuManager:Open failed: menu not registered:", p)
		return
	end

	if self._registry[_resolve].isOverlay then
		if not table.find(self._overlays, _resolve) then
			table.insert(self._overlays, _resolve)
		end
	else
		local active = self:GetActive()

		if active == _resolve then
			self._signals.Opened:Fire(_resolve)
			return
		end

		if active then
			self:_setVisible(active, false)
		end

		local index = table.find(self._history, _resolve)

		if index then
			table.remove(self._history, index)
		end

		table.insert(self._history, _resolve)
	end

	self:_setVisible(_resolve, true)
	self._signals.Opened:Fire(_resolve)
end

function MenuManager:Transition(p)
	local _resolve = self:_resolve(p)

	if not _resolve then
		warn("MenuManager:Transition failed: menu not registered:", p)
		return
	end

	if self._registry[_resolve].isOverlay then
		if not table.find(self._overlays, _resolve) then
			table.insert(self._overlays, _resolve)
		end
	else
		local active = self:GetActive()

		if active == _resolve then
			self._signals.Opened:Fire(_resolve)
			return
		end

		if active then
			self:_setVisible(active, false, true)
		end

		local index = table.find(self._history, _resolve)

		if index then
			table.remove(self._history, index)
		end

		table.insert(self._history, _resolve)
	end

	self:_setVisible(_resolve, true)
	self._signals.Opened:Fire(_resolve)
end

function MenuManager:OpenPage(p, p2)
	local _resolve = self:_resolve(p)

	if not _resolve then
		warn("MenuManager:OpenPage failed: menu not registered:", p)
		return
	end

	self:Open(_resolve)
	local v = self._registry[_resolve]

	if v and v.controller.ShowPage then
		v.controller:ShowPage(p2)
	end
end

function MenuManager:Close(p)
	local _resolve = self:_resolve(p)

	if not _resolve then
		warn("MenuManager:Close failed: menu not registered:", p)
		return
	end

	self:_setVisible(_resolve, false)
	local index = table.find(self._history, _resolve)

	if index then
		table.remove(self._history, index)
	end

	local index2 = table.find(self._overlays, _resolve)

	if index2 then
		table.remove(self._overlays, index2)
	end

	self._signals.Closed:Fire(_resolve)
end

function MenuManager:SetBackGuard(p, p2)
	local v = self:_resolve(p) or p
	self._backGuards[v] = p2
end

function MenuManager:RunBackGuard(p, p2)
	local _backGuard = self._backGuards[self:_resolve(p) or p]

	if not _backGuard then
		return false
	end

	local success, result = pcall(_backGuard, p2)

	if success then
		return result == true
	end

	warn("[MenuManager] Back guard for", p, "errored; closing anyway:", result)
	return false
end

function MenuManager:Back()
	local active = self:GetActive()

	if not active then
		return
	end

	if self:RunBackGuard(active, function()
		self:_closeCurrent(active)
	end) then
		return
	end

	self:_closeCurrent(active)
end

function MenuManager:_closeCurrent(p)
	self:_setVisible(p, false)
	local index = table.find(self._history, p)

	if index then
		table.remove(self._history, index)
	end

	self._signals.Closed:Fire(p)
	local active = self:GetActive()

	if active then
		self:_setVisible(active, true)
		self._signals.Opened:Fire(active)
	end
end

function MenuManager:CloseAll()
	for _, v in ipairs(self._history) do
		self:_setVisible(v, false)
		self._signals.Closed:Fire(v)
	end

	for _, _overlay in ipairs(self._overlays) do
		self:_setVisible(_overlay, false)
		self._signals.Closed:Fire(_overlay)
	end

	self._history = {}
	self._overlays = {}
end

function MenuManager:IsOpen(p)
	local v = self:_resolve(p) or p
	return table.find(self._history, v) ~= nil or table.find(self._overlays, v) ~= nil
end

function MenuManager:GetActive()
	return self._history[#self._history]
end

function MenuManager:IsAnyOpen()
	return #self._history > 0 or #self._overlays > 0
end

function MenuManager:OnOpened(onOpened)
	local openedConnection = self._signals.Opened:Connect(onOpened)
	table.insert(self._connections, openedConnection)
	return openedConnection
end

function MenuManager:OnClosed(onClosed)
	local closedConnection = self._signals.Closed:Connect(onClosed)
	table.insert(self._connections, closedConnection)
	return closedConnection
end

function MenuManager:Destroy()
	for _, _connection in ipairs(self._connections) do
		_connection:Disconnect()
	end

	for _, _signal in pairs(self._signals) do
		_signal:Destroy()
	end

	table.clear(self)
end

return MenuManager