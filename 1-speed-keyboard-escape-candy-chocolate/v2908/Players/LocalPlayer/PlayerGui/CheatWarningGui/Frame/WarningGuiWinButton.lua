local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
game:GetService("TweenService")
local parent = script.Parent
local textLabel = parent:WaitForChild("TextLabel")
local cheatWarningEvent = ReplicatedStorage:WaitForChild("CheatWarningEvent")
local announcementSound = SoundService:WaitForChild("AnnouncementSound")
local flag = false
parent.Visible = false
textLabel.Text = "You must complete the entire obby!"
cheatWarningEvent.OnClientEvent:Connect(function()
	if flag then
		return
	end

	flag = true
	announcementSound:Play()
	parent.Visible = true
	textLabel.TextTransparency = 0
	parent.BackgroundTransparency = 0.3
	task.wait(3)

	for i = 0, 1, 0.1 do
		textLabel.TextTransparency = i
		parent.BackgroundTransparency = i * 0.7 + 0.3
		task.wait(0.05)
	end

	parent.Visible = false
	flag = false
end)