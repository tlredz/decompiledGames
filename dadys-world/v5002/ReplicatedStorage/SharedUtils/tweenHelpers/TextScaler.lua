local TextScaler = {}
local v = {}
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function _getCamera()
	return workspace.CurrentCamera
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _currentSizeX(p)
	if p ~= "screen" then
		return p.AbsoluteSize.X
	end

	local currentCamera = _getCamera() -- equivalent call inferred; original call site unknown
	return currentCamera and currentCamera.ViewportSize.X or 0
end

local function _runScale(state, p)
	state.pendingTask = nil
	local v3 = _currentSizeX(p) -- equivalent call inferred; original call site unknown

	if v3 == 0 then
		return
	end

	local v4 = v3 / state.referenceSizeX

	for i = #state.labels, 1, -1 do
		local label = state.labels[i]

		if label.Parent then
			label.TextSize = math.round(label:GetAttribute("OriginalFontSize") * v4)
		else
			table.remove(state.labels, i)
			v2[label] = nil
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _scheduleUpdate(state, p)
	if state.pendingTask then
		return
	end

	state.pendingTask = task.delay(state.throttle, function()
		_runScale(state, p)
	end)
end

local function _connectCamera(screen)
	local currentCamera = _getCamera() -- equivalent call inferred; original call site unknown

	if not currentCamera then
		return
	end

	if screen.connection then
		screen.connection:Disconnect()
	end

	screen.connection = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		local screen2 = v.screen

		if screen2.pendingTask then
			return
		end

		local v4 = "screen"
		screen2.pendingTask = task.delay(screen2.throttle, function()
			_runScale(screen2, v4)
		end)
	end)
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local screen = v.screen

	if screen then
		_connectCamera(screen)
	end
end)

function TextScaler.track(instance, instance2, options)
	local v3 = instance2 or "screen"
	local v4 = options or {}
	local v5 = v[v3]

	if not v5 then
		local referenceSizeX = v4.referenceSizeX

		if not referenceSizeX then
			if v3 == "screen" then
				local currentCamera = _getCamera() -- equivalent call inferred; original call site unknown
				referenceSizeX = currentCamera and currentCamera.ViewportSize.X or 0
			else
				referenceSizeX = v3.AbsoluteSize.X
			end
		end

		local throttle = v4.throttle or 0.15
		local connection

		if v3 == "screen" then
			connection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				local screen = v.screen

				if screen.pendingTask then
					return
				end

				local v7 = "screen"
				screen.pendingTask = task.delay(screen.throttle, function()
					_runScale(screen, v7)
				end)
			end)
		else
			connection = instance2:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				_scheduleUpdate(v[v3], v3) -- equivalent call inferred; original call site unknown
			end)
		end

		v5 = {
			connection = connection,
			pendingTask = nil,
			referenceSizeX = referenceSizeX,
			throttle = throttle,
			labels = {}
		}
		v[v3] = v5
		_scheduleUpdate(v5, v3) -- equivalent call inferred; original call site unknown
	end

	for _, label in ipairs(v5.labels) do
		if label == instance then
			return
		end
	end

	table.insert(v5.labels, instance)
	v2[instance] = v3

	if not instance:GetAttribute("OriginalFontSize") then
		instance:SetAttribute("OriginalFontSize", instance.TextSize)
	end

	instance.Destroying:Connect(function()
		TextScaler.untrack(instance)
	end)
end

function TextScaler.untrack(p)
	local v3 = v2[p]

	if not v3 then
		return
	end

	v2[p] = nil
	local v4 = v[v3]

	if not v4 then
		return
	end

	for i, label in ipairs(v4.labels) do
		if label ~= p then
			continue
		end

		table.remove(v4.labels, i)
		break
	end

	if #v4.labels == 0 then
		v4.connection:Disconnect()

		if v4.pendingTask then
			task.cancel(v4.pendingTask)
		end

		v[v3] = nil
	end
end

return TextScaler