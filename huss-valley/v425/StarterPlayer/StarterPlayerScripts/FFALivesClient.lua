local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local session = game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Game"):WaitForChild("Session")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FFALives"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 63
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
local textLabel = Instance.new("TextLabel")
textLabel.Name = "Lives"
textLabel.AnchorPoint = Vector2.new(1, 0.5)
textLabel.Position = UDim2.fromScale(0.98, 0.44)
textLabel.Size = UDim2.fromScale(0.19, 0.09)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(255, 218, 138)
textLabel.TextStrokeTransparency = 0.25
textLabel.Font = Enum.Font.GothamBold
textLabel.TextScaled = true
textLabel.TextWrapped = true
textLabel.Parent = screenGui
local flag = true
local connections = {}
local thread = nil
local render

render = function()
	if thread then
		task.cancel(thread)
		thread = nil
	end

	local fFALives = localPlayer:GetAttribute("FFALives")
	textLabel.Visible = session:GetAttribute("AdminMatchMode") == "FFACatchers" and type(fFALives) == "number" and fFALives > 0

	if not textLabel.Visible then
		return
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	local fFADownUntil = localPlayer:GetAttribute("FFADownUntil") or 0
	local fFAImmuneUntil = localPlayer:GetAttribute("FFAImmuneUntil") or 0
	local v3 = serverTimeNow < fFADownUntil and "GET UP IN " .. math.ceil(fFADownUntil - serverTimeNow) or not (serverTimeNow < fFAImmuneUntil) and "LAST ONE STANDING" or "INVINCIBLE · " .. math.ceil(fFAImmuneUntil - serverTimeNow) or "LAST ONE STANDING"
	textLabel.Text = string.format("%d / 3 LIVES\n%s", fFALives, v3)
	textLabel.TextColor3 = serverTimeNow < fFAImmuneUntil and Color3.fromRGB(110, 220, 255) or Color3.fromRGB(
		255,
		218,
		138
	)
	local v4 = serverTimeNow < fFADownUntil and fFADownUntil or serverTimeNow < fFAImmuneUntil and fFAImmuneUntil or nil

	if v4 then
		local v5 = v4 - serverTimeNow
		local v6 = v5 - (math.ceil(v5) - 1) + 0.02
		thread = task.delay(math.clamp(v6, 0.05, 1.02), function()
			thread = nil

			if flag then
				render()
			end
		end)
	end
end

for _, v in { "FFALives", "FFADownUntil", "FFAImmuneUntil" } do
	table.insert(connections, localPlayer:GetAttributeChangedSignal(v):Connect(render))
end

table.insert(connections, session:GetAttributeChangedSignal("AdminMatchMode"):Connect(render))
script.Destroying:Connect(function()
	flag = false

	if thread then
		task.cancel(thread)
		thread = nil
	end

	for _, connection in connections do
		connection:Disconnect()
	end

	screenGui:Destroy()
end)
render()