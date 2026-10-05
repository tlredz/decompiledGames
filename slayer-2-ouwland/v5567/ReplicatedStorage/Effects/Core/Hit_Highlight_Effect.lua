local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
return function(p, p2)
	if p ~= nil and p2 ~= nil and (workspace.CurrentCamera.CFrame.Position - p.Position).Magnitude <= 200 then
		Utility.Damagehighlight(p, p2)
	end
end