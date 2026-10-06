local ReplicatedStorage = game:GetService("ReplicatedStorage")
local studioLiteFolder = ReplicatedStorage:WaitForChild("StudioLiteFolder")
local parent = script.Parent
local flag = true
parent.MouseButton1Click:Connect(function()
	if flag then
		flag = false
		studioLiteFolder.PromptDonation:FireServer(parent.Name)
		task.wait(2)
		flag = true
	end
end)