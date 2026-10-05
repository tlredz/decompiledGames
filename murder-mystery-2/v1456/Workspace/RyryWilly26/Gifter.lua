local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Events"):WaitForChild("Generic"):WaitForChild("GetGiftsLeft"):InvokeServer()
local gifter = game.Players.LocalPlayer.PlayerGui:WaitForChild("Gifter")
gifter.Enabled = false
local chat = game.Players.LocalPlayer.PlayerGui:WaitForChild("MainGUI"):FindFirstChild("Chat")

if chat then
	GiftTip = chat:FindFirstChild("Gift")

	if GiftTip then
		GiftTip.Visible = false
	end
end