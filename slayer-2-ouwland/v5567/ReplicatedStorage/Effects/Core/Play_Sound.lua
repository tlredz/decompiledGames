local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
return function(parent, instance)
	if parent ~= nil and instance ~= nil and (workspace.CurrentCamera.CFrame.Position - parent.Position).Magnitude <= 200 then
		local clone = instance:Clone()
		clone.Parent = parent
		clone:Play()
		DebrisModule:AddItem(clone, clone.TimeLength)
	end
end