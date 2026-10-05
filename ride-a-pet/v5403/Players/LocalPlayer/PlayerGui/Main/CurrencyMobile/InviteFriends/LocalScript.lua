local parent = script.Parent
local SocialService = game:GetService("SocialService")
game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Reusable")
local SFX = game.SoundService:WaitForChild("SFX")
local localPlayer = game.Players.LocalPlayer
parent.Activated:Connect(function()
	SFX.Click:Play()
	SocialService:PromptGameInvite(localPlayer)
end)