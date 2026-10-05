script.Parent.Visible = false

while not workspace:GetAttribute("ServerPerformanceTracker") do
	workspace:GetAttributeChangedSignal("ServerPerformanceTracker"):Wait()
end

script.Parent.Visible = true
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")

local function getColorSequence(color, p: number)
	if p <= 0 then
		return color.Keypoints[1].Value
	end

	if p >= 1 then
		return color.Keypoints[#color.Keypoints].Value
	end

	for i = 1, #color.Keypoints - 1 do
		local keypoint = color.Keypoints[i]
		local keypoint2 = color.Keypoints[i + 1]

		if not (keypoint.Time <= p and p <= keypoint2.Time) then
			continue
		end

		local v = (p - keypoint.Time) / (keypoint2.Time - keypoint.Time)
		return keypoint.Value:Lerp(keypoint2.Value, v)
	end

	return Color3.new()
end

script.Parent.Bars.UIListLayout.Bar.Size = UDim2.fromScale(0.02, 1)
local v = {}
local layoutOrder = 50

for i = 1, 50 do
	if script.Parent.Bars:FindFirstChild("Bar" .. i) then
		continue
	end

	local clone = script.Parent.Bars.UIListLayout.Bar:Clone()
	clone.LayoutOrder = i
	clone.Parent = script.Parent.Bars
	v[i] = clone
end

local v3 = {}

local function pushFrame(p: number)
	layoutOrder += 1
	local v4 = table.remove(v, 1)
	table.insert(v, v4)
	v4.LayoutOrder = layoutOrder
	local v5 = math.map(p, 0, 0.05, 0, 1)
	v4.Size = UDim2.fromScale(0.02, v5)
	local v6 = math.clamp(math.map(p, 0.01, 0.1, 0, 1), 0, 1)
	v4.BackgroundColor3 = getColorSequence(script.UIGradient.Color, v6)
	script.Parent.MSLabel.Text = `{math.round(p * 100000) / 100}ms`

	if #v3 >= 10 then
		table.remove(v3, 1)
	end

	table.insert(v3, p)
	local total = 0

	for _, v7 in v3 do
		total += v7
	end

	local v7 = 1 / (total / #v3)
	script.Parent.FPSLabel.Text = `{math.round(v7 * 100) / 100}FPS`
end

ReplicatedStorage.ServerMonitor.OnClientEvent:Connect(function(p)
	pushFrame(p)
end)
script.Parent.Parent.Boosts.Position = UDim2.new(0.025, 12, 0.85, 0)