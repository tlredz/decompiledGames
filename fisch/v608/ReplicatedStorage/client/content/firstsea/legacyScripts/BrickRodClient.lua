local ReplicatedStorage = game:GetService("ReplicatedStorage")
local brickRodMessages = workspace:WaitForChild("BrickRodMessages")
ReplicatedStorage.events:WaitForChild("BrickRodEvents"):WaitForChild("ShowMessages").OnClientEvent:Connect(function(text, text2, text3)
	local textLabel = brickRodMessages:WaitForChild("m1"):WaitForChild("SurfaceGui"):WaitForChild("TextLabel")
	textLabel.Text = text
	local textLabel_2 = brickRodMessages:WaitForChild("m2"):WaitForChild("SurfaceGui"):WaitForChild("TextLabel")
	textLabel_2.Text = text2
	local textLabel_3 = brickRodMessages:WaitForChild("m3"):WaitForChild("SurfaceGui"):WaitForChild("TextLabel")
	textLabel_3.Text = text3
end)