local AreaLocator = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Areas"):WaitForChild("AreaLocator"))

while true do
	if game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		AreaLocator:Update(game.Players.LocalPlayer.Character.HumanoidRootPart)
	end

	task.wait(0.35)
end