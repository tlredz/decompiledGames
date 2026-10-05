local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local assets = ReplicatedStorage:WaitForChild("Assets")
local numberRange = NumberRange.new(0.14, 0.21)
local numberRange2 = NumberRange.new(0.55, 0.85)
local numberRange3 = NumberRange.new(1.4, 2.1)
local numberRange4 = NumberRange.new(0.8, 2)
local back = Enum.EasingStyle.Back
local cubic = Enum.EasingStyle.Cubic
local uDim = UDim2.fromScale(0, 0)
local random = Random.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function glintTemplate()
	return assets.UI.Misc.Effects.Glint
end

-- equivalent calls inferred from this helper; original call sites unknown
local function draw(range: NumberRange, p: number)
	return random:NextNumber(range.Min, range.Max) * p
end

local function layerAbove(parent)
	local zIndex = parent.ZIndex

	for _, guiObject in parent:GetChildren() do
		if guiObject:IsA("GuiObject") then
			zIndex = math.max(zIndex, guiObject.ZIndex)
		end
	end

	return zIndex + 2
end

local function newLane(parent, zIndex: number)
	local clone = (glintTemplate()):Clone()
	clone.Visible = false
	clone.Size = uDim
	clone.ZIndex = zIndex
	clone.Parent = parent
	return {
		glint = clone,
		readyAt = 0,
		inFlight = nil,
		retired = false
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tweenSize(p, duration: number, p2, p3, udim: UDim2)
	return TweenService:Create(p, TweenInfo.new(duration, p2, p3), {
		Size = udim
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function finish(state)
	state.inFlight = nil

	if state.retired then
		state.glint:Destroy()
	else
		state.glint.Visible = false
	end
end

local function twinkle(p, size: number, pace: number)
	local glint = p.glint
	local v2 = draw(numberRange, size) -- equivalent call inferred; original call site unknown
	local v4 = draw(numberRange2, 1) / pace
	local v6 = draw(numberRange3, 1) / pace
	glint.Position = UDim2.fromScale(random:NextNumber(), random:NextNumber())
	glint.Size = uDim
	glint.Visible = true
	local inFlight = tweenSize(glint, v4, back, Enum.EasingDirection.Out, UDim2.fromScale(v2, v2)) -- equivalent call inferred; original call site unknown
	inFlight.Completed:Once(function(p2)
		if p2 == Enum.PlaybackState.Completed then
			local inFlight2 = tweenSize(glint, v6, cubic, Enum.EasingDirection.InOut, uDim) -- equivalent call inferred; original call site unknown
			inFlight2.Completed:Once(function()
				finish(p) -- equivalent call inferred; original call site unknown
			end)
			p.inFlight = inFlight2
			inFlight2:Play()
		else
			finish(p) -- equivalent call inferred; original call site unknown
		end
	end)
	p.inFlight = inFlight
	inFlight:Play()
	return v4 + v6
end

return function(parent, options)
	local layerCollector = parent:FindFirstAncestorWhichIsA("LayerCollector")

	if layerCollector == nil then
		return function() end
	end

	local v = options or {}
	local size = v.Size or 1
	local pace = v.Pace or 1
	local lanes = v.Lanes or 1
	local v2

	if type(lanes) == "number" then
		v2 = lanes >= 1
	else
		v2 = false
	end

	assert(v2, "a sparkle field needs at least one lane")
	local zIndex = layerAbove(parent)
	local v4 = {}

	for _ = 1, lanes do
		local clone = (glintTemplate()):Clone()
		clone.Visible = false
		clone.Size = uDim
		clone.ZIndex = zIndex
		clone.Parent = parent
		table.insert(v4, {
			glint = clone,
			readyAt = 0,
			inFlight = nil,
			retired = false
		})
	end

	local v5 = true

	local function retireLanes()
		for _, v6 in v4 do
			v6.retired = true

			if v6.inFlight == nil then
				v6.glint:Destroy()
			end
		end
	end

	task.spawn(function()
		while v5 and parent.Parent ~= nil do
			local now = os.clock()
			local v6 = 1e999

			for _, v7 in v4 do
				if not (now < v7.readyAt) then
					if layerCollector.Enabled then
						v7.readyAt = now + twinkle(v7, size, pace) + draw(numberRange4, 1)
					else
						v7.readyAt = now + 0.4
					end
				end

				v6 = math.min(v6, v7.readyAt)
			end

			task.wait((math.clamp(v6 - os.clock(), 0.05, 0.3)))
		end

		retireLanes()
	end)
	return function()
		v5 = false
	end
end