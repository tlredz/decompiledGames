local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local OverlayRoot = require(script.Parent.OverlayRoot)
local v = {
	Attack = 0.5,
	Decay = 0.9,
	Tint = Color3.new(1, 1, 1),
	Opacity = 1
}
local v2 = {
	style = Enum.EasingStyle.Quint,
	direction = Enum.EasingDirection.Out
}
local v3 = {
	style = Enum.EasingStyle.Cubic,
	direction = Enum.EasingDirection.InOut
}
local v4 = {}
local v5 = nil
local heartbeatConnection = nil

local function attach(p)
	local parent = v5

	if parent and parent.Parent then
		p.Parent = parent
	else
		task.spawn(function()
			local parent2 = OverlayRoot()
			v5 = parent2
			p.Parent = parent2
		end)
	end
end

local function sheetFor(tint: Color3)
	local hex = tint:ToHex()
	local v6 = v4[hex]

	if v6 then
		return v6
	end

	local frame = Instance.new("Frame")
	frame.Name = `Wash_{hex}`
	frame.ZIndex = 500
	frame.BorderSizePixel = 0
	frame.BackgroundColor3 = tint
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromScale(1, 1)
	frame.Visible = false
	local v7 = {
		frame = frame,
		startedAt = 0,
		keys = nil
	}
	v4[hex] = v7
	frame.Destroying:Connect(function()
		if v4[hex] == v7 then
			v4[hex] = nil
		end
	end)
	local parent = v5

	if parent and parent.Parent then
		frame.Parent = parent
		return v7
	end

	task.spawn(function()
		local parent2 = OverlayRoot()
		v5 = parent2
		frame.Parent = parent2
	end)
	return v7
end

local function envelope(level: number, data)
	local attack = data.Attack or v.Attack
	local decay = data.Decay or v.Decay
	local level2 = math.clamp(data.Opacity or v.Opacity, 0, 1)
	return {
		{
			at = 0,
			level = level,
			style = v2.style,
			direction = v2.direction
		},
		{
			at = attack,
			level = level2,
			style = v2.style,
			direction = v2.direction
		},
		{
			at = attack + decay,
			level = 0,
			style = v3.style,
			direction = v3.direction
		}
	}
end

local function levelAt(keys, p: number)
	for i = 2, #keys do
		local v6 = keys[i]

		if not (p < v6.at) then
			continue
		end

		local v7 = keys[i - 1]
		local v8 = v6.at - v7.at
		local value = TweenService:GetValue(not (v8 > 0) and 1 or (p - v7.at) / v8, v6.style, v6.direction)
		return v7.level + (v6.level - v7.level) * value, false
	end

	return keys[#keys].level, true
end

local function step()
	local now = os.clock()
	local v6 = false

	for _, v7 in v4 do
		local keys = v7.keys

		if keys == nil then
			continue
		end

		local v8, v9 = levelAt(keys, now - v7.startedAt)
		v7.frame.BackgroundTransparency = 1 - v8

		if v9 then
			v7.keys = nil
			v7.frame.Visible = false
		else
			v6 = true
		end
	end

	if not v6 and heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

local v6 = {
	Play = function(p)
		local v7 = sheetFor(p.Tint or v.Tint)
		v7.keys = envelope(1 - v7.frame.BackgroundTransparency, p)
		v7.startedAt = os.clock()
		v7.frame.Visible = true

		if heartbeatConnection == nil then
			heartbeatConnection = RunService.Heartbeat:Connect(step)
		end

		step()
	end
}
return table.freeze(v6)