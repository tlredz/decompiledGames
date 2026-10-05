local spr = require(script.Parent:WaitForChild("spr"))
local Store = require(script.Parent:WaitForChild("Store"))
local Spring = {
	spr = spr,
	Presets = {
		Open = { 0.58, 4.2 },
		OpenFade = { 1, 7 },
		Close = { 1, 8 },
		CloseFade = { 1, 8 },
		Row = { 0.52, 4 },
		RowFade = { 1, 6 },
		Card = { 0.55, 4.6 },
		Hover = { 0.75, 8 },
		Press = { 0.65, 9 },
		Rotate = { 0.45, 4.5 },
		Punch = { 0.38, 5 },
		Pop = { 0.42, 5 },
		PopOut = { 1, 10 },
		Pulse = { 1, 1.6 },
		Select = { 0.4, 6 },
		Bar = { 1, 6 },
		BarSnap = { 1, 12 },
		Trail = { 1, 3 },
		Out = { 1, 9 },
		Soft = { 1, 3 },
		Snappy = { 0.85, 6 },
		Bouncy = { 0.55, 4.5 },
		Wobble = { 0.3, 5 },
		Instant = { 1, 9 },
		Slide = { 0.8, 4.2 },
		Text = { 0.85, 4.6 },
		Number = { 1, 4 }
	}
}

function Spring.tuning(value)
	if type(value) ~= "string" then
		return value[1], value[2]
	end

	local preset = Spring.Presets[value]

	if not preset then
		error("Spring: unknown preset " .. value, 2)
	end

	return preset[1], preset[2]
end

function Spring.to(p, p2, p3)
	local tuning, v = Spring.tuning(p2)
	spr.target(p, tuning, v, p3)
end

function Spring.stop(p, p2)
	spr.stop(p, p2)
end

function Spring.completed(p, p2)
	spr.completed(p, p2)
end

function Spring:snap(items)
	for k, item in pairs(items) do
		spr.stop(self, k)
		self[k] = item
	end
end

local v = Store.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function apply(state)
	local ext = state.ext
	local layers = state.layers

	for i = 1, #layers do
		ext *= layers[i].Scale
	end

	if math.abs(state.real.Scale - ext) > 0.0001 then
		state.written = ext
		state.real.Scale = ext
	end
end

local function track(p, instance)
	if instance == p.real or table.find(p.layers, instance) then
		return
	end

	table.insert(p.layers, instance)
	instance:GetPropertyChangedSignal("Scale"):Connect(function()
		apply(p) -- equivalent call inferred; original call site unknown
	end)
end

local function compositeOf(parent)
	local v2 = v[parent]

	if v2 and v2.real.Parent == parent then
		return v2
	end

	local uIScale = Instance.new("UIScale")
	uIScale.Name = "BitohiScale"
	local v3 = {
		real = uIScale,
		ext = 1,
		written = 1,
		layers = {}
	}
	v[parent] = v3
	local uIScales = {}

	for _, uIScale2 in ipairs(parent:GetChildren()) do
		if uIScale2:IsA("UIScale") then
			table.insert(uIScales, uIScale2)
		end
	end

	uIScale.Parent = parent

	for _, v4 in ipairs(uIScales) do
		v4.Parent = nil
		v4.Parent = parent
		track(v3, v4)
	end

	uIScale:GetPropertyChangedSignal("Scale"):Connect(function()
		if math.abs(uIScale.Scale - v3.written) > 0.0001 then
			v3.ext = uIScale.Scale
			v3.written = uIScale.Scale
			apply(v3) -- equivalent call inferred; original call site unknown
		end
	end)
	parent.ChildAdded:Connect(function(uIScale2)
		if uIScale2:IsA("UIScale") and v3.real.Parent == parent then
			track(v3, uIScale2)
			apply(v3) -- equivalent call inferred; original call site unknown
		end
	end)
	parent.ChildRemoved:Connect(function(child)
		local index = table.find(v3.layers, child)

		if index and child.Parent ~= parent then
			table.remove(v3.layers, index)
			apply(v3) -- equivalent call inferred; original call site unknown
		end
	end)
	apply(v3) -- equivalent call inferred; original call site unknown
	return v3
end

local function scaleCount(parent)
	local count = 0

	for _, uIScale in ipairs(parent:GetChildren()) do
		if uIScale:IsA("UIScale") then
			count += 1
		end
	end

	return count
end

function Spring.findScale(instance, value)
	local v2 = value or "AnimScale"

	if v2 == "BitohiScale" then
		return nil
	end

	local uIScale = instance:FindFirstChild(v2)

	if uIScale and uIScale:IsA("UIScale") then
		return uIScale
	end

	return nil
end

function Spring.scale(parent, value)
	local name = value or "AnimScale"
	local scale = Spring.findScale(parent, name)

	if scale then
		if not v[parent] and scaleCount(parent) > 1 then
			compositeOf(parent)
		end

		return scale
	else
		local uIScale = Instance.new("UIScale")
		uIScale.Name = name

		if parent:FindFirstChildOfClass("UIScale") then
			local v3 = compositeOf(parent)
			uIScale.Parent = parent
			track(v3, uIScale)
			local ext = v3.ext
			local layers = v3.layers

			for i = 1, #layers do
				ext *= layers[i].Scale
			end

			if math.abs(v3.real.Scale - ext) > 0.0001 then
				v3.written = ext
				v3.real.Scale = ext
				return uIScale
			end
		else
			uIScale.Parent = parent
		end

		return uIScale
	end
end

function Spring.scaleFrom(p, scale, value, p2, value2)
	local scaled = Spring.scale(p, p2)
	spr.stop(scaled)
	scaled.Scale = scale
	Spring.to(scaled, value or "Pop", {
		Scale = value2 or 1
	})
	return scaled
end

function Spring.extend(items)
	for k, item in pairs(items) do
		Spring.Presets[k] = item
	end
end

return Spring