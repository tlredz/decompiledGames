local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local doRejoin = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DoRejoin")
localPlayer.Idled:Connect(function(p: number)
	if p >= 900 then
		doRejoin:FireServer()
	end
end)