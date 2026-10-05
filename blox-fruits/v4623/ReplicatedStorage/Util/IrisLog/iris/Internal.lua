local HttpService = game:GetService("HttpService")
require(script.Parent.Types)
return function(state)
	local result = {
		_version = " 2.4.1 ",
		_started = false,
		_shutdown = false,
		_cycleTick = 0,
		_deltaTime = 0,
		_globalRefreshRequested = false,
		_localRefreshActive = false
	}
	local widgets = {}
	result._widgets = widgets
	result._stackIndex = 1
	result._rootInstance = nil
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
	local iDStack = { "R" }
	result._IDStack = iDStack
	local usedIDs = {}
	result._usedIDs = usedIDs
	result._pushedId = nil
	result._nextWidgetId = nil
	result._states = {}
	result._postCycleCallbacks = {}
	result._connectedFunctions = {}
	result._connections = {}
	result._initFunctions = {}
	local lastVDOM = nil
	local v5 = nil
	local _deepCopy
	local RunService = game:GetService("RunService")
	result._fullErrorTracebacks = RunService:IsStudio()
	result._cycleCoroutine = coroutine.create(function()
		while result._started do
			for _, callback in result._connectedFunctions do
				local success, result2 = pcall(callback)

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
			widgets[connectedWidget.type].UpdateState(connectedWidget)
		end

		for _, connectedFunction in self.ConnectedFunctions do
			connectedFunction(p)
		end

		return self.value
	end

	function class.onChange(p, callback)
		local v6 = #p.ConnectedFunctions + 1
		p.ConnectedFunctions[v6] = callback
		return function()
			p.ConnectedFunctions[v6] = nil
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

		for _, v6 in lastVDOM do
			if v6.lastCycleTick ~= result._cycleTick and v6.lastCycleTick ~= -1 then
				result._DiscardWidget(v6)
			end
		end

		setmetatable(lastVDOM, {
			__mode = "kv"
		})
		lastVDOM = v5
		v5 = result._generateEmptyVDOM()
		task.spawn(function()
			for _, _postCycleCallback in result._postCycleCallbacks do
				_postCycleCallback()
			end
		end)

		if result._globalRefreshRequested then
			result._generateSelectionImageObject()
			result._globalRefreshRequested = false

			for _, v6 in lastVDOM do
				result._DiscardWidget(v6)
			end

			result._generateRootInstance()
			lastVDOM = result._generateEmptyVDOM()
		end

		result._cycleTick += 1
		result._deltaTime = deltaTime
		table.clear(usedIDs)

		if (result.parentInstance:IsA("GuiBase2d") or result.parentInstance:IsA("CoreGui") or result.parentInstance:IsA("PluginGui") or result.parentInstance:IsA("PlayerGui")) == false then
			error("The Iris parent instance will not display any GUIs.")
		end

		for _, _connectedFunction in result._connectedFunctions do
			_connectedFunction()
		end

		if result._stackIndex ~= 1 then
			result._stackIndex = 1
			error("Too few calls to Iris.End().", 0)
		end
	end

	function result._NoOp() end

	function result.WidgetConstructor(p: string, p2)
		local v6 = {
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
		local v7 = {}

		for _, v8 in v6.All.Required do
			assert(p2[v8] ~= nil, (`field {v8} is missing from widget {p}, it is required for all widgets`))
			v7[v8] = p2[v8]
		end

		for _, v8 in v6.All.Optional do
			if p2[v8] == nil then
				v7[v8] = result._NoOp
			else
				v7[v8] = p2[v8]
			end
		end

		if p2.hasState then
			for _, v8 in v6.IfState.Required do
				assert(
					p2[v8] ~= nil,
					(`field {v8} is missing from widget {p}, it is required for all widgets with state`)
				)
				v7[v8] = p2[v8]
			end

			for _, v8 in v6.IfState.Optional do
				if p2[v8] == nil then
					v7[v8] = result._NoOp
				else
					v7[v8] = p2[v8]
				end
			end
		end

		if p2.hasChildren then
			for _, v8 in v6.IfChildren.Required do
				assert(
					p2[v8] ~= nil,
					(`field {v8} is missing from widget {p}, it is required for all widgets with children`)
				)
				v7[v8] = p2[v8]
			end

			for _, v8 in v6.IfChildren.Optional do
				if p2[v8] == nil then
					v7[v8] = result._NoOp
				else
					v7[v8] = p2[v8]
				end
			end
		end

		widgets[p] = v7
		state.Args[p] = v7.Args
		local argNames = {}

		for k, arg in v7.Args do
			argNames[arg] = k
		end

		v7.ArgNames = argNames

		for k, _ in v7.Events do
			if state.Events[k] ~= nil then
				continue
			end

			local v9 = k

			state.Events[k] = function()
				return result._EventCall(result._lastWidget, v9)
			end
		end
	end

	local cachedInserts = {}

	local function getCachedInsert(p: string)
		local v6 = cachedInserts[p]

		if v6 then
			return v6
		end

		local _ContinueWidget = result._ContinueWidget
		local _deepCompare = result._deepCompare
		local v7 = widgets[p]
		local argNames = v7.ArgNames
		local _getID = result._getID
		local _DiscardWidget = result._DiscardWidget
		local _GenNewWidget = result._GenNewWidget
		local update = v7.Update
		local hasChildren = v7.hasChildren
		local v8

		if p == "Window" then
			v8 = false
		else
			v8 = p ~= "Tooltip"
		end

		local function cachedInsert(items, p2)
			local v9 = _getID(4)

			if v5[v9] then
				return _ContinueWidget(v9, p)
			end

			local providedArguments = {}

			if items ~= nil then
				for k, item in items do
					providedArguments[argNames[k]] = item
				end
			end

			local v11 = lastVDOM[v9]

			if v11 and p == rawget(v11, "type") and result._localRefreshActive then
				_DiscardWidget(v11)
				v11 = nil
			end

			local lastWidget = v11 or _GenNewWidget(p, providedArguments, p2, v9)
			local v13 = rawget(lastWidget, "parentWidget")
			rawget(lastWidget, "type")

			if v8 then
				local v14 = rawget(v13, "ZOffset")

				if rawget(lastWidget, "ZIndex") ~= v14 then
					v13.ZUpdate = true
				end

				if rawget(v13, "ZUpdate") then
					lastWidget.ZIndex = v14
					local v15 = rawget(lastWidget, "Instance")

					if v15 then
						v15.ZIndex = v14
						v15.LayoutOrder = v14
					end
				end
			end

			if _deepCompare(lastWidget.providedArguments, providedArguments) == false then
				lastWidget.arguments = _deepCopy(providedArguments)
				lastWidget.providedArguments = providedArguments
				update(lastWidget)
			end

			lastWidget.lastCycleTick = result._cycleTick
			v13.ZOffset += 1

			if hasChildren then
				lastWidget.ZOffset = 0
				lastWidget.ZUpdate = false
				result._stackIndex += 1
				iDStack[result._stackIndex] = v9
			end

			v5[v9] = lastWidget
			result._lastWidget = lastWidget
			return lastWidget
		end

		cachedInserts[p] = cachedInsert
		return cachedInsert
	end

	function result._Insert(p: string, p2, p3)
		local cachedInsert = cachedInserts[p]

		if cachedInsert then
			return cachedInsert(p2, p3)
		end

		local _ContinueWidget = result._ContinueWidget
		local _deepCompare = result._deepCompare
		local v6 = widgets[p]
		local argNames = v6.ArgNames
		local _getID = result._getID
		local _DiscardWidget = result._DiscardWidget
		local _GenNewWidget = result._GenNewWidget
		local update = v6.Update
		local hasChildren = v6.hasChildren
		local v7

		if p == "Window" then
			v7 = false
		else
			v7 = p ~= "Tooltip"
		end

		cachedInsert = function(items, p4)
			local v8 = _getID(4)

			if v5[v8] then
				return _ContinueWidget(v8, p)
			end

			local providedArguments = {}

			if items ~= nil then
				for k, item in items do
					providedArguments[argNames[k]] = item
				end
			end

			local v10 = lastVDOM[v8]

			if v10 and p == rawget(v10, "type") and result._localRefreshActive then
				_DiscardWidget(v10)
				v10 = nil
			end

			local lastWidget = v10 or _GenNewWidget(p, providedArguments, p4, v8)
			local v12 = rawget(lastWidget, "parentWidget")
			rawget(lastWidget, "type")

			if v7 then
				local v13 = rawget(v12, "ZOffset")

				if rawget(lastWidget, "ZIndex") ~= v13 then
					v12.ZUpdate = true
				end

				if rawget(v12, "ZUpdate") then
					lastWidget.ZIndex = v13
					local v14 = rawget(lastWidget, "Instance")

					if v14 then
						v14.ZIndex = v13
						v14.LayoutOrder = v13
					end
				end
			end

			if _deepCompare(lastWidget.providedArguments, providedArguments) == false then
				lastWidget.arguments = _deepCopy(providedArguments)
				lastWidget.providedArguments = providedArguments
				update(lastWidget)
			end

			lastWidget.lastCycleTick = result._cycleTick
			v12.ZOffset += 1

			if hasChildren then
				lastWidget.ZOffset = 0
				lastWidget.ZUpdate = false
				result._stackIndex += 1
				iDStack[result._stackIndex] = v8
			end

			v5[v8] = lastWidget
			result._lastWidget = lastWidget
			return lastWidget
		end

		cachedInserts[p] = cachedInsert
		return cachedInsert(p2, p3)
	end

	function result._GenNewWidget(p: string, providedArguments, state2, ID)
		local v6 = iDStack[result._stackIndex]
		local parentWidget2 = v5[v6]
		local v8 = widgets[p]
		local class2 = {}
		setmetatable(class2, class2)
		class2.ID = ID
		class2.type = p
		class2.parentWidget = parentWidget2
		class2.trackedEvents = {}
		class2.UID = HttpService:GenerateGUID(false):sub(0, 8)
		class2.ZIndex = parentWidget2.ZOffset
		class2.Instance = v8.Generate(class2)
		local parentWidget = class2.parentWidget

		if result._config.Parent then
			class2.Instance.Parent = result._config.Parent
		else
			class2.Instance.Parent = widgets[parentWidget.type].ChildAdded(parentWidget, class2)
		end

		class2.providedArguments = providedArguments
		class2.arguments = _deepCopy(providedArguments)
		v8.Update(class2)
		local stateMT

		if v8.hasState then
			if state2 then
				for k, v9 in state2 do
					if type(v9) ~= "table" or getmetatable(v9) ~= result.StateClass then
						state2[k] = result._widgetState(class2, k, v9)
					end

					state2[k].lastChangeTick = result._cycleTick
				end

				class2.state = state2

				for _, v9 in state2 do
					v9.ConnectedWidgets[class2.ID] = class2
				end
			else
				class2.state = {}
			end

			v8.GenerateState(class2)
			v8.UpdateState(class2)
			class2.stateMT = {}
			setmetatable(class2.state, class2.stateMT)
			class2.__index = class2.state
			stateMT = class2.stateMT
		else
			stateMT = class2
		end

		function stateMT.__index(_, p2: string)
			return function()
				return result._EventCall(class2, p2)
			end
		end

		return class2
	end

	function result._ContinueWidget(p, p2: string)
		local v6 = widgets[p2]
		local lastWidget = v5[p]

		if v6.hasChildren then
			result._stackIndex += 1
			iDStack[result._stackIndex] = lastWidget.ID
		end

		result._lastWidget = lastWidget
		return lastWidget
	end

	function result:_DiscardWidget()
		local parentWidget = self.parentWidget

		if parentWidget then
			widgets[parentWidget.type].ChildDiscarded(parentWidget, self)
		end

		widgets[self.type].Discard(self)
		self.lastCycleTick = -1
	end

	function result._widgetState(p, p2: string, p3)
		local ID = p.ID
		local ID2 = ID .. p2
		local _states = result._states
		local _state = _states[ID2]

		if _state then
			_state.ConnectedWidgets[ID] = p
			_state.lastChangeTick = result._cycleTick
			return _state
		else
			_states[ID2] = {
				ID = ID2,
				value = p3,
				lastChangeTick = result._cycleTick,
				ConnectedWidgets = {
					[ID] = p
				},
				ConnectedFunctions = {}
			}
			setmetatable(_states[ID2], result.StateClass)
			return _states[ID2]
		end
	end

	function result._EventCall(p, p2: string)
		local type2 = p.type
		local event = widgets[type2].Events[p2]
		assert(event ~= nil, (`widget {type2} has no event of name {p2}`))

		if p.trackedEvents[p2] == nil then
			event.Init(p)
			p.trackedEvents[p2] = true
		end

		return event.Get(p)
	end

	function result._GetParentWidget()
		return v5[iDStack[result._stackIndex]]
	end

	function result._generateEmptyVDOM()
		return {
			R = result._rootWidget
		}
	end

	function result._generateRootInstance()
		result._rootInstance = widgets.Root.Generate(widgets.Root)
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
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Thickness = 1
		uIStroke.Color = result._config.SelectionImageObjectBorderColor
		uIStroke.Transparency = result._config.SelectionImageObjectBorderTransparency
		uIStroke.LineJoinMode = Enum.LineJoinMode.Bevel
		uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uIStroke.Parent = frame
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(0, 2)
		uICorner.Parent = frame
		result.SelectionImageObject = frame
	end

	local info = debug.info

	function result._getID(value: number)
		local _nextWidgetId = result._nextWidgetId

		if _nextWidgetId then
			result._nextWidgetId = nil
			return _nextWidgetId
		end

		local _pushedId = result._pushedId
		local v6 = 1 + (value or 1)
		local v7 = info(v6, "l")
		local v8 = ""

		while v7 ~= -1 and v7 ~= nil do
			v8 ..= "+" .. v7
			v6 += 1
			v7 = info(v6, "l")
		end

		local v9 = usedIDs[v8]

		if v9 then
			usedIDs[v8] += 1
		else
			usedIDs[v8] = 1
		end

		return v8 .. ":" .. (_pushedId or (v9 or 0) + 1)
	end

	local _deepCompare = nil

	function result._deepCompare(items, p)
		for k, item in items do
			local v6 = p[k]
			local typeName = type(item)

			if typeName == "table" then
				if not v6 or type(v6) ~= "table" or _deepCompare(item, v6) == false then
					return false
				end
			elseif typeName ~= type(v6) or item ~= v6 then
				return false
			end
		end

		return true
	end

	_deepCompare = result._deepCompare

	_deepCopy = function(items)
		local clone = table.clone(items)

		for k, item in pairs(items) do
			if type(item) == "table" then
				clone[k] = result._deepCopy(item)
			end
		end

		return clone
	end

	result._deepCopy = _deepCopy
	lastVDOM = result._generateEmptyVDOM()
	v5 = result._generateEmptyVDOM()
	result._lastVDOM = lastVDOM
	result._VDOM = v5
	state.Internal = result
	state._config = result._config
	return result
end