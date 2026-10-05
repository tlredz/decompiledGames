local parent = script.Parent
local reusable = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Reusable")
game.SoundService:WaitForChild("SFX")
parent.Activated:Connect(function()
	reusable.InviteRandomFriend:Fire()
end)