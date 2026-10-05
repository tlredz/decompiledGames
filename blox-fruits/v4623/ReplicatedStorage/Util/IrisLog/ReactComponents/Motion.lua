local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local React = require(game.ReplicatedStorage.Packages.React)
local Motion = {
	Hover = TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Press = TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Release = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Rotate = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Pop = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Collapse = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Fade = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	to = function(p, p2, p3)
		if not p then
			return nil
		end

		local tween = TweenService:Create(p, p2, p3)
		tween:Play()
		return tween
	end,
	set = function(p, items)
		if not p then
			return
		end

		for k, item in items do
			p[k] = item
		end
	end
}

function Motion.useNumberMotion(p: number)
	local v, v2 = React.useBinding(p)
	local ref = React.useRef(nil)

	if not ref.current then
		ref.current = {
			connection = nil
		}
	end

	local v3 = React.useCallback(function(p2: number, p3, callback)
		local current = ref.current

		if current.connection then
			current.connection:Disconnect()
			current.connection = nil
		end

		local v4 = p3 or Motion.Collapse
		local time = v4.Time
		local value = v:getValue()

		if time <= 0 or math.abs(value - p2) < 0.001 then
			v2(p2)

			if callback then
				callback()
			end
		else
			local easingStyle = v4.EasingStyle
			local easingDirection = v4.EasingDirection
			local total = 0
			current.connection = RunService.Heartbeat:Connect(function(dt: number)
				total += dt
				local v5 = math.clamp(total / time, 0, 1)
				v2(value + (p2 - value) * TweenService:GetValue(v5, easingStyle, easingDirection))

				if v5 >= 1 and current.connection then
					current.connection:Disconnect()
					current.connection = nil

					if callback then
						callback()
					end
				end
			end)
		end
	end, {})
	local v4 = React.useCallback(function(p2: number)
		local current = ref.current

		if current.connection then
			current.connection:Disconnect()
			current.connection = nil
		end

		v2(p2)
	end, {})
	React.useEffect(function()
		return function()
			local current = ref.current

			if current and current.connection then
				current.connection:Disconnect()
				current.connection = nil
			end
		end
	end, {})
	return v, v3, v4
end

function Motion.useMeasuredCollapse(flag: boolean, data)
	local v = data and data.UnmountWhenClosed == true
	local v2 = data == nil or data.KeepOpenHeightSynced ~= false
	local v3 = (not data or typeof(data.OpenAngle) ~= "number") and 0 or data.OpenAngle
	local v4 = (not data or typeof(data.ClosedAngle) ~= "number") and -90 or data.ClosedAngle
	local state, setState = React.useState(flag)
	local state2, setState2 = React.useState(flag and "auto" or v and "collapsed" or "fixed")
	local ref = React.useRef(nil)
	local ref2 = React.useRef(0)
	local ref3 = React.useRef(flag)
	local height, v6, v7 = Motion.useNumberMotion(0)
	local useNumberMotion = Motion.useNumberMotion
	local v8

	if flag then
		v8 = v3
	else
		v8 = v4
	end

	local chevronAngle, v10 = useNumberMotion(v8)
	ref3.current = state
	local bodyMounted = not v or state2 ~= "collapsed"
	local clipped = state2 == "fixed"
	React.useEffect(function()
		local current = ref.current

		if not current then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			ref2.current = math.ceil(current.AbsoluteSize.Y)

			if ref3.current and v2 then
				v7(ref2.current)
			end
		end

		update() -- equivalent call inferred; original call site unknown
		task.defer(update)
		local absoluteSizeChangedConnection = current:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
		return function()
			absoluteSizeChangedConnection:Disconnect()
		end
	end, {
		bodyMounted,
		state2 == "auto",
		state2 == "fixed",
		v2
	})

	local function setOpen(flag2: boolean)
		if flag2 == ref3.current then
			return
		end

		if flag2 then
			setState2("fixed")
			v7(0)
			setState(true)
			v10(v3, Motion.Rotate)
			v6(ref2.current, Motion.Collapse, function()
				if v then
					setState2("auto")
				end
			end)
		else
			v7(ref2.current)
			setState2("fixed")
			setState(false)
			v10(v4, Motion.Rotate)
			v6(0, Motion.Collapse, function()
				if v then
					setState2("collapsed")
				end
			end)
		end
	end

	local function toggle()
		setOpen(not ref3.current)
	end

	return {
		Open = state,
		SetOpen = setOpen,
		Toggle = toggle,
		MeasureRef = ref,
		Height = height,
		ChevronAngle = chevronAngle,
		BodyMounted = bodyMounted,
		Clipped = clipped,
		Mode = state2,
		FullHeightRef = ref2
	}
end

return Motion