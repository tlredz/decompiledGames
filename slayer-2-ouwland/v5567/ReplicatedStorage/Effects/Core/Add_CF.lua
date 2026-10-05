local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
return function(instance, p, p2, p3)
	if instance ~= nil and p ~= nil and p2 ~= nil and (instance.Position - workspace.CurrentCamera.CFrame.Position).Magnitude <= 200 and instance.Parent ~= nil and instance.Parent:FindFirstChild("HumanoidRootPart") then
		Utility.bg(instance, p, p2, p3)
	end
end