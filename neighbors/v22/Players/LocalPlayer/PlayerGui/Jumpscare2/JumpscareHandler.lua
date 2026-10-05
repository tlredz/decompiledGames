local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local Network = require(game.ReplicatedStorage.Modules.Network)
local v = {
	12940390287,
	110900575822599,
	15848332855,
	12075892911,
	6418552310,
	12510899710,
	1308665109
}
local frame = script.Parent.Frame
local image = frame.Image
local children = script.Sounds:GetChildren()
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function getShakeOffset(p: number, p2: number)
	local v2 = os.clock() * p2
	return Vector2.new(math.noise(v2, 0), math.noise(0, v2)) * p
end

Network:listen("PromptScaryJumpscare", function()
	if flag then
		return
	end

	flag = true
	local v2 = children[math.random(1, #children)]
	image.Image = `rbxassetid://{v[math.random(1, #v)]}`
	image.Position = UDim2.fromScale(0.5, 0.5)
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		local shakeOffset = getShakeOffset(0.1, 20) -- equivalent call inferred; original call site unknown
		image.Position = UDim2.new(shakeOffset.X + 0.5, 0, shakeOffset.Y + 0.5, 0)
	end)
	v2:Play()
	frame.Visible = true
	task.wait(1)
	frame.Visible = false
	heartbeatConnection:Disconnect()
	flag = false
end)
task.delay(3, function()
	local v2 = {}

	for _, v3 in next, v, nil do
		local imageLabel = Instance.new("ImageLabel", script)
		imageLabel.Image = `rbxassetid://{v3}`
		table.insert(v2, imageLabel)
	end

	ContentProvider:PreloadAsync(v2)
end)