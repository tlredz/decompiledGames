script.Parent.Activated:Connect(function()
	local studioGui = game.Players.LocalPlayer.PlayerGui:WaitForChild("StudioGui", 9)
	local publishedFrame = studioGui:WaitForChild("PublishedFrame")
	local growingUpFrame = studioGui:WaitForChild("GrowingUpFrame")
	local voteFrame = studioGui:WaitForChild("VoteFrame")
	growingUpFrame.Visible = false
	voteFrame.Visible = false
	publishedFrame.Visible = true
end)