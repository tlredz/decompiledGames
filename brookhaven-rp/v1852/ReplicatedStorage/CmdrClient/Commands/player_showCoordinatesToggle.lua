local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local v = nil
local renderSteppedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function formatAxis(p: number)
	return string.format("%.2f", p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stop()
	if renderSteppedConnection ~= nil then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	if v ~= nil then
		v:Destroy()
		v = nil
	end
end

local function start()
	local localPlayer = Players.LocalPlayer
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CoordinatesDebugGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 1000
	local textLabel = Instance.new("TextLabel")
	textLabel.AnchorPoint = Vector2.new(0.5, 0)
	textLabel.Position = UDim2.new(0.5, 0, 0, 60)
	textLabel.Size = UDim2.fromOffset(420, 56)
	textLabel.BackgroundColor3 = Color3.new(0, 0, 0)
	textLabel.BackgroundTransparency = 0.4
	textLabel.Font = Enum.Font.Code
	textLabel.TextSize = 18
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextStrokeTransparency = 0.5
	textLabel.Text = ""
	textLabel.Parent = screenGui
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 6)
	uICorner.Parent = textLabel
	screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
	v = screenGui
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local character = localPlayer.Character
		local humanoidRootPart

		if character ~= nil then
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		end

		if humanoidRootPart == nil then
			textLabel.Text = "No character"
			return
		end

		local position = humanoidRootPart.Position
		local _, v2, _ = humanoidRootPart.CFrame:ToOrientation()
		local parent = textLabel
		local v4 = formatAxis(position.X) -- equivalent call inferred; original call site unknown
		local v5 = formatAxis(position.Y) -- equivalent call inferred; original call site unknown
		local Z = position.Z
		parent.Text = `X: {v4}  Y: {v5}  Z: {string.format("%.2f", Z)}\nHeading: {string.format("%.1f", (math.deg(v2)))}°`
	end)
end

return {
	Name = "player_showCoordinatesToggle",
	Aliases = { "coords" },
	Description = "Toggles an on-screen debug view of your current XYZ coordinates (client only).",
	Group = "Player",
	Args = {},
	ClientRun = function()
		if v == nil then
			start()
			return "Coordinates view enabled. Run again to disable."
		end

		stop() -- equivalent call inferred; original call site unknown
		return "Coordinates view disabled"
	end
}