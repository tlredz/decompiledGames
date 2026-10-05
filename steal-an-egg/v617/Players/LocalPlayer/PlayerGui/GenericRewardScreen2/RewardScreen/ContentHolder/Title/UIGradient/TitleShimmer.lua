local RunService = game:GetService("RunService")
local parent = script.Parent
local screenGui = parent:FindFirstAncestorWhichIsA("ScreenGui")
local v = {
	Color3.fromRGB(255, 225, 0),
	Color3.fromRGB(255, 225, 0),
	Color3.fromRGB(255, 248, 39),
	Color3.fromRGB(255, 191, 0),
	Color3.fromRGB(255, 225, 0),
	Color3.fromRGB(255, 250, 115),
	Color3.fromRGB(255, 225, 0),
	(Color3.fromRGB(255, 225, 0))
}
local v2 = #v - 1
local colorSequenceKeypoints = table.create(14)

local function wrappedColor(p)
	local v3 = p % 1 * v2
	local v4 = math.floor(v3) + 1
	local v5 = math.min(v4 + 1, #v)
	return v[v4]:Lerp(v[v5], v3 % 1)
end

local total = 0

local function step(p)
	total += p

	if total < 0.03333333333333333 then
		return
	end

	total = 0
	local v3 = os.clock() % 2 / 2

	for i = 0, 13 do
		local v4 = i / 13
		colorSequenceKeypoints[i + 1] = ColorSequenceKeypoint.new(v4, wrappedColor(v4 * 0.5 - v3))
	end

	parent.Color = ColorSequence.new(colorSequenceKeypoints)
end

local renderSteppedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function start()
	if not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(step)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stop()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

if screenGui then
	screenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
		if screenGui.Enabled then
			start() -- equivalent call inferred; original call site unknown
		else
			stop() -- equivalent call inferred; original call site unknown
		end
	end)

	if screenGui.Enabled and not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(step)
	end
else
	start() -- equivalent call inferred; original call site unknown
end

script.Destroying:Once(stop)