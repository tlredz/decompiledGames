script.Parent.Activated:Connect(function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local studioLiteFolder = ReplicatedStorage:WaitForChild("StudioLiteFolder")
	local studioGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("StudioGui", 9)
	local growingUpFrame = studioGui:WaitForChild("GrowingUpFrame")
	local voteFrame = studioGui:WaitForChild("VoteFrame")
	growingUpFrame.Visible = false
	voteFrame.Visible = true
	studioLiteFolder.RefreshDonation:FireServer(50)
end)