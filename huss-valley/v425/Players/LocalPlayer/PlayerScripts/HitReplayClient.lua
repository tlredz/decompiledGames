local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local CombatPrediction = require(game.ReplicatedStorage:WaitForChild("ChickenOrHero").Game:WaitForChild("CombatPrediction"))
CombatPrediction.start()

if game.PlaceId ~= 130574217370467 then
	return
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HitReplayStatus"
screenGui:SetAttribute("TestOnlyUI", true)
screenGui.Enabled = localPlayer:GetAttribute("TestUIHidden") ~= true
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 119
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
local textLabel = Instance.new("TextLabel")
textLabel.AnchorPoint = Vector2.new(0.5, 0)
textLabel.Position = UDim2.fromScale(0.5, 0.085)
textLabel.Size = UDim2.fromScale(0.7, 0.045)
textLabel.BackgroundTransparency = 0.3
textLabel.BackgroundColor3 = Color3.fromRGB(12, 22, 29)
textLabel.TextColor3 = Color3.fromRGB(184, 231, 250)
textLabel.Font = Enum.Font.GothamMedium
textLabel.TextScaled = true
textLabel.TextWrapped = true
textLabel.Text = "HIT REPLAY · waiting for contacts"
textLabel.Parent = screenGui
local connection = CombatPrediction.subscribe(function(data)
	textLabel.Text = string.format(
		"%s: %s · %s%s",
		data.kind or "HIT",
		data.verdict or data.accepted == true and "HIT" or data.accepted == false and "MISS" or "RESULT",
		data.reason or "",
		type(data.latencyMs) ~= "number" and "" or string.format(" · %dms", data.latencyMs) or ""
	)
end)
local testUIHiddenChangedConnection = localPlayer:GetAttributeChangedSignal("TestUIHidden"):Connect(function()
	screenGui.Enabled = localPlayer:GetAttribute("TestUIHidden") ~= true
end)
script.Destroying:Connect(function()
	connection:Disconnect()
	testUIHiddenChangedConnection:Disconnect()
	screenGui:Destroy()
end)