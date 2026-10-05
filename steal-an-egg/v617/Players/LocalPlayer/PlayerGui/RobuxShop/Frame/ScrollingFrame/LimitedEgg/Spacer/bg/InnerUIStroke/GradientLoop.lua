local parent = script.Parent:IsA("UIGradient") and script.Parent or script.Parent:FindFirstChildOfClass("UIGradient")
assert(parent, "No UIGradient found on or under " .. script.Parent:GetFullName())
local v = {
	{ 0, (Color3.fromRGB(255, 247, 15)) },
	{ 0.151986, (Color3.fromRGB(255, 62, 23)) },
	{ 0.326425, (Color3.fromRGB(255, 30, 34)) },
	{ 0.587219, (Color3.fromRGB(255, 71, 34)) },
	{ 0.777202, (Color3.fromRGB(255, 234, 0)) },
	{ 1, (Color3.fromRGB(255, 238, 152)) }
}

local function getWrappedColor(p)
	local v2 = p % 1
	local v3 = nil

	for i = 1, #v - 1 do
		local v4 = v[i]
		local v5 = v[i + 1]

		if not (v2 <= v5[1]) then
			continue
		end

		local v6 = v5[1] - v4[1]
		local v7 = not (v6 > 0) and 0 or (v2 - v4[1]) / v6 or 0
		v3 = v4[2]:Lerp(v5[2], v7)
		break
	end

	return v3 or v[#v][2]
end

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local v2 = UserInputService.TouchEnabled and 32 or 64
local colorSequences = nil
local v3 = -1
local heartbeatConnection = nil

local function buildPhases()
	colorSequences = table.create(v2)
	local colorSequenceKeypoints = table.create(20)

	for i = 0, v2 - 1 do
		local v4 = i / v2

		for i2 = 0, 19 do
			local v5 = i2 / 19
			colorSequenceKeypoints[i2 + 1] = ColorSequenceKeypoint.new(v5, (getWrappedColor(v5 * 0.5 - v4)))
		end

		colorSequences[i + 1] = ColorSequence.new(colorSequenceKeypoints)
	end
end

local function render()
	local v4 = math.floor(tick() % 2 / 2 * v2) % v2 + 1

	if v4 == v3 then
		return
	end

	v3 = v4
	parent.Color = colorSequences[v4]
end

local parent2 = script.Parent
local v4 = {}
local ancestryChangedConnection = nil
local v5 = false

local function isVisible()
	local parent3 = parent2

	while parent3 do
		if parent3:IsA("GuiObject") then
			if not parent3.Visible then
				return false
			end
		elseif parent3:IsA("LayerCollector") then
			return parent3.Enabled
		end

		parent3 = parent3.Parent
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setActive(visible)
	if visible == v5 then
		return
	end

	v5 = visible

	if visible then
		if not colorSequences then
			buildPhases()
		end

		heartbeatConnection = RunService.Heartbeat:Connect(render)
	else
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function evaluate()
	setActive(isVisible()) -- equivalent call inferred; original call site unknown
end

local function watchAncestors()
	for i = #v4, 1, -1 do
		v4[i]:Disconnect()
		v4[i] = nil
	end

	local parent3 = parent2

	while parent3 do
		if parent3:IsA("GuiObject") then
			v4[#v4 + 1] = parent3:GetPropertyChangedSignal("Visible"):Connect(evaluate)
		elseif parent3:IsA("LayerCollector") then
			v4[#v4 + 1] = parent3:GetPropertyChangedSignal("Enabled"):Connect(evaluate)
			break
		end

		parent3 = parent3.Parent
	end

	evaluate() -- equivalent call inferred; original call site unknown
end

local function teardown()
	if v5 ~= false then
		v5 = false
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	for i = #v4, 1, -1 do
		v4[i]:Disconnect()
		v4[i] = nil
	end

	if ancestryChangedConnection then
		ancestryChangedConnection:Disconnect()
		ancestryChangedConnection = nil
	end

	colorSequences = nil
	v3 = -1
end

script.Destroying:Once(teardown)
ancestryChangedConnection = parent2.AncestryChanged:Connect(watchAncestors)
watchAncestors()