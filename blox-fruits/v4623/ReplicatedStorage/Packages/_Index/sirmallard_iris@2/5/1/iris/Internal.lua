require(script.Parent.Types)
return function(state)
	local result = {
		_version = " 2.5.1 ",
		_started = false,
		_shutdown = false,
		_cycleTick = 0,
		_deltaTime = 0,
		_globalRefreshRequested = false,
		_refreshCounter = 0,
		_refreshLevel = 1,
		_refreshStack = table.create(16),
		_widgets = {},
		_stackIndex = 1,
		_rootInstance = nil
	}
	result._rootWidget = {
		ID = "R",
		type = "Root",
		Instance = result._rootInstance,
		ZIndex = 0,
		ZOffset = 0
	}
	result._lastWidget = result._rootWidget
	result._rootConfig = {}
	result._config = result._rootConfig
	result._IDStack = { "R" }
	result._usedIDs = {}
	result._pushedIds = {}
	result._newID = false
	result._nextWidgetId = nil
	result._states = {}
	result._postCycleCallbacks = {}
	result._connectedFunctions = {}
	result._connections = {}
	result._initFunctions = {}
	local RunService = game:GetService("RunService")
	result._fullErrorTracebacks = RunService:IsStudio()
	result._cycleCoroutine = coroutine.create(function()
		while result._started do
			for _, callback in result._connectedFunctions do
				debug.profilebegin("Iris/Connection")
				local success, result2 = pcall(callback)
				debug.profileend()

				if success then
					continue
				end

				result._stackIndex = 1
				coroutine.yield(false, result2)
			end

			coroutine.yield(true)
		end
	end)
	local class = {}
	class.__index = class

	function class.get(p)
		return p.value
	end

	function class:set(p, flag: boolean?)
		if p == self.value and flag ~= true then
			return self.value
		end

		self.value = p
		self.lastChangeTick = state.Internal._cycleTick

		for _, connectedWidget in self.ConnectedWidgets do
			if connectedWidget.lastCycleTick ~= -1 then
				result._widgets[connectedWidget.type].UpdateState(connectedWidget)
			end
		end

		for _, connectedFunction in self.ConnectedFunctions do
			connectedFunction(p)
		end

		return self.value
	end

	function class.onChange(p, callback)
		local v = #p.ConnectedFunctions + 1
		p.ConnectedFunctions[v] = callback
		return function()
			p.ConnectedFunctions[v] = nil
		end
	end

	function class.changed(p)
		return p.lastChangeTick + 1 == result._cycleTick
	end

	result.StateClass = class

	function result._cycle(deltaTime: number)
		if state.Disabled then
			return
		end

		result._rootWidget.lastCycleTick = result._cycleTick

		if result._rootInstance == nil or result._rootInstance.Parent == nil then
			state.ForceRefresh()
		end

		for _, v in result._lastVDOM do
			if v.lastCycleTick ~= result._cycleTick and v.lastCycleTick ~= -1 then
				result._DiscardWidget(v)
			end
		end

		setmetatable(result._lastVDOM, {
			__mode = "kv"
		})
		result._lastVDOM = result._VDOM
		result._VDOM = result._generateEmptyVDOM()
		task.spawn(function()
			for _, _postCycleCallback in result._postCycleCallbacks do
				_postCycleCallback()
			end
		end)

		if result._globalRefreshRequested then
			result._generateSelectionImageObject()
			result._globalRefreshRequested = false

			for _, v in result._lastVDOM do
				result._DiscardWidget(v)
			end

			result._generateRootInstance()
			result._lastVDOM = result._generateEmptyVDOM()
		end

		result._cycleTick += 1
		result._deltaTime = deltaTime
		table.clear(result._usedIDs)

		if (result.parentInstance:IsA("GuiBase2d") or result.parentInstance:IsA("BasePlayerGui")) == false then
			error("The Iris parent instance will not display any GUIs.")
		end

		if result._fullErrorTracebacks then
			for _, _connectedFunction in result._connectedFunctions do
				_connectedFunction()
			end
		else
			local v2 = coroutine.status(result._cycleCoroutine)

			if v2 == "suspended" then
				local _, v3, v4 = coroutine.resume(result._cycleCoroutine)

				if v3 == false then
					error(v4, 0)
				end
			elseif v2 == "running" then
				error("Iris cycleCoroutine took to long to yield. Connected functions should not yield.")
			else
				error("unrecoverable state")
			end
		end

		if result._stackIndex ~= 1 then
			result._stackIndex = 1
			error("Too few calls to Iris.End().", 0)
		end

		if #result._pushedIds ~= 0 then
			error("Too few calls to Iris.PopId().", 0)
		end
	end

	function result._NoOp() end

	function result.WidgetConstructor(p: string, p2)
		local v = {
			All = {
				Required = {
					"Generate",
					"Discard",
					"Update",
					"Args",
					"Events",
					"hasChildren",
					"hasState"
				},
				Optional = {}
			},
			IfState = {
				Required = { "GenerateState", "UpdateState" },
				Optional = {}
			},
			IfChildren = {
				Required = { "ChildAdded" },
				Optional = { "ChildDiscarded" }
			}
		}
		local v2 = {}

		for _, v3 in v.All.Required do
			assert(p2[v3] ~= nil, (`field {v3} is missing from widget {p}, it is required for all widgets`))
			v2[v3] = p2[v3]
		end

		for _, v3 in v.All.Optional do
			if p2[v3] == nil then
				v2[v3] = result._NoOp
			else
				v2[v3] = p2[v3]
			end
		end

		if p2.hasState then
			for _, v3 in v.IfState.Required do
				assert(
					p2[v3] ~= nil,
					(`field {v3} is missing from widget {p}, it is required for all widgets with state`)
				)
				v2[v3] = p2[v3]
			end

			for _, v3 in v.IfState.Optional do
				if p2[v3] == nil then
					v2[v3] = result._NoOp
				else
					v2[v3] = p2[v3]
				end
			end
		end

		if p2.hasChildren then
			for _, v3 in v.IfChildren.Required do
				assert(
					p2[v3] ~= nil,
					(`field {v3} is missing from widget {p}, it is required for all widgets with children`)
				)
				v2[v3] = p2[v3]
			end

			for _, v3 in v.IfChildren.Optional do
				if p2[v3] == nil then
					v2[v3] = result._NoOp
				else
					v2[v3] = p2[v3]
				end
			end
		end

		result._widgets[p] = v2
		state.Args[p] = v2.Args
		local argNames = {}

		for k, arg in v2.Args do
			argNames[arg] = k
		end

		v2.ArgNames = argNames

		for k, _ in v2.Events do
			if state.Events[k] ~= nil then
				continue
			end

			local v4 = k

			state.Events[k] = function()
				return result._EventCall(result._lastWidget, v4)
			end
		end
	end

	function result._Insert(p: string, p2, p3)
		local _getID = result._getID(3)
		local _widget = result._widgets[p]

		if result._VDOM[_getID] then
			return result._ContinueWidget(_getID, p)
		end

		local providedArguments = {}

		if p2 ~= nil then
			for k, v2 in type(p2) ~= "table" and { p2 } or p2 do
				assert(k > 0, (`Widget Arguments must be a positive number, not {k} of type {typeof(k)} for {v2}.`))
				providedArguments[_widget.ArgNames[k]] = v2
			end
		end

		table.freeze(providedArguments)
		local lastWidget = result._lastVDOM[_getID]

		if lastWidget and p == lastWidget.type and result._refreshCounter > 0 then
			result._DiscardWidget(lastWidget)
			lastWidget = nil
		end

		if lastWidget == nil then
			lastWidget = result._GenNewWidget(p, providedArguments, p3, _getID)
		end

		local parentWidget = lastWidget.parentWidget

		if lastWidget.type ~= "Window" and lastWidget.type ~= "Tooltip" then
			if lastWidget.ZIndex ~= parentWidget.ZOffset then
				parentWidget.ZUpdate = true
			end

			if parentWidget.ZUpdate then
				lastWidget.ZIndex = parentWidget.ZOffset

				if lastWidget.Instance then
					lastWidget.Instance.ZIndex = lastWidget.ZIndex
					lastWidget.Instance.LayoutOrder = lastWidget.ZIndex
				end
			end
		end

		if parentWidget.type == "Table" then
			parentWidget._rowCycles[parentWidget._rowIndex] = result._cycleTick
		end

		if result._deepCompare(lastWidget.providedArguments, providedArguments) == false then
			lastWidget.arguments = result._deepCopy(providedArguments)
			lastWidget.providedArguments = providedArguments
			_widget.Update(lastWidget)
		end

		lastWidget.lastCycleTick = result._cycleTick
		parentWidget.ZOffset += 1

		if _widget.hasChildren then
			lastWidget.ZOffset = 0
			lastWidget.ZUpdate = false
			result._stackIndex += 1
			result._IDStack[result._stackIndex] = lastWidget.ID
		end

		result._VDOM[_getID] = lastWidget
		result._lastWidget = lastWidget
		return lastWidget
	end

	function result._GenNewWidget(p: string, providedArguments, state2, ID)
		local v = result._IDStack[result._stackIndex]
		local parentWidget2 = result._VDOM[v]
		local _widget = result._widgets[p]
		local class2 = {}
		setmetatable(class2, class2)
		class2.ID = ID
		class2.type = p
		class2.parentWidget = parentWidget2
		class2.trackedEvents = {}
		class2.ZIndex = parentWidget2.ZOffset
		class2.Instance = _widget.Generate(class2)
		local parentWidget = class2.parentWidget

		if result._config.Parent then
			class2.Instance.Parent = result._config.Parent
		else
			class2.Instance.Parent = result._widgets[parentWidget.type].ChildAdded(parentWidget, class2)
		end

		class2.providedArguments = providedArguments
		class2.arguments = result._deepCopy(providedArguments)
		_widget.Update(class2)
		local stateMT

		if _widget.hasState then
			if state2 then
				for k, v3 in state2 do
					if type(v3) ~= "table" or getmetatable(v3) ~= result.StateClass then
						state2[k] = result._widgetState(class2, k, v3)
					end

					state2[k].lastChangeTick = result._cycleTick
				end

				class2.state = state2

				for _, v3 in state2 do
					v3.ConnectedWidgets[class2.ID] = class2
				end
			else
				class2.state = {}
			end

			_widget.GenerateState(class2)
			_widget.UpdateState(class2)
			class2.stateMT = {}
			setmetatable(class2.state, class2.stateMT)
			class2.__index = class2.state
			stateMT = class2.stateMT
		else
			stateMT = class2
		end

		function stateMT.__index(_, p2)
			return function()
				return result._EventCall(class2, p2)
			end
		end

		return class2
	end

	function result._ContinueWidget(p, p2: string)
		local _widget = result._widgets[p2]
		local lastWidget = result._VDOM[p]

		if _widget.hasChildren then
			result._stackIndex += 1
			result._IDStack[result._stackIndex] = lastWidget.ID
		end

		result._lastWidget = lastWidget
		return lastWidget
	end

	function result:_DiscardWidget()
		local parentWidget = self.parentWidget

		if parentWidget then
			result._widgets[parentWidget.type].ChildDiscarded(parentWidget, self)
		end

		result._widgets[self.type].Discard(self)
		self.lastCycleTick = -1
	end

	function result._widgetState(p, p2: string, p3)
		local ID = p.ID .. p2

		if result._states[ID] then
			result._states[ID].ConnectedWidgets[p.ID] = p
			result._states[ID].lastChangeTick = result._cycleTick
			return result._states[ID]
		else
			local v2 = {
				ID = ID,
				value = p3,
				lastChangeTick = result._cycleTick,
				ConnectedWidgets = {
					[p.ID] = p
				},
				ConnectedFunctions = {}
			}
			setmetatable(v2, result.StateClass)
			result._states[ID] = v2
			return v2
		end
	end

	function result._EventCall(p, p2: string)
		local event = result._widgets[p.type].Events[p2]
		assert(event ~= nil, (`widget {p.type} has no event of name {p2}`))

		if p.trackedEvents[p2] == nil then
			event.Init(p)
			p.trackedEvents[p2] = true
		end

		return event.Get(p)
	end

	function result._GetParentWidget()
		return result._VDOM[result._IDStack[result._stackIndex]]
	end

	function result._generateEmptyVDOM()
		return {
			R = result._rootWidget
		}
	end

	function result._generateRootInstance()
		result._rootInstance = result._widgets.Root.Generate(result._widgets.Root)
		result._rootInstance.Parent = result.parentInstance
		result._rootWidget.Instance = result._rootInstance
	end

	function result._generateSelectionImageObject()
		if result.SelectionImageObject then
			result.SelectionImageObject:Destroy()
		end

		local frame = Instance.new("Frame")
		frame.Position = UDim2.fromOffset(-1, -1)
		frame.Size = UDim2.new(1, 2, 1, 2)
		frame.BackgroundColor3 = result._config.SelectionImageObjectColor
		frame.BackgroundTransparency = result._config.SelectionImageObjectTransparency
		frame.BorderSizePixel = 0
		result._utility.UIStroke(
			frame,
			1,
			result._config.SelectionImageObjectBorderColor,
			result._config.SelectionImageObjectBorderTransparency
		)
		result._utility.UICorner(frame, 2)
		result.SelectionImageObject = frame
	end

	function result._getID(value: number)
		if result._nextWidgetId then
			local _nextWidgetId = result._nextWidgetId
			result._nextWidgetId = nil
			return _nextWidgetId
		else
			local v = 1 + (value or 1)
			local v2 = debug.info(v, "l")
			local v3 = ""

			while v2 ~= -1 and v2 ~= nil do
				v3 ..= "+" .. v2
				v += 1
				v2 = debug.info(v, "l")
			end

			local _usedID = result._usedIDs[v3]
			local v4

			if _usedID then
				result._usedIDs[v3] += 1
				v4 = _usedID + 1
			else
				result._usedIDs[v3] = 1
				v4 = 1
			end

			if #result._pushedIds == 0 then
				return v3 .. ":" .. v4
			end

			if not result._newID then
				return v3 .. ":" .. v4 .. ":" .. table.concat(result._pushedIds, "\\")
			end

			result._newID = false
			return v3 .. "::" .. table.concat(result._pushedIds, "\\")
		end
	end

	function result._deepCompare(items, p)
		for k, item in items do
			local v = p[k]

			if type(item) == "table" then
				if not v or type(v) ~= "table" or result._deepCompare(item, v) == false then
					return false
				end
			elseif type(item) ~= type(v) or item ~= v then
				return false
			end
		end

		return true
	end

	function result._deepCopy(items)
		local clone = table.clone(items)

		for k, item in items do
			if type(item) == "table" then
				clone[k] = result._deepCopy(item)
			end
		end

		return clone
	end

	result._lastVDOM = result._generateEmptyVDOM()
	result._VDOM = result._generateEmptyVDOM()
	state.Internal = result
	state._config = result._config
	return result
end