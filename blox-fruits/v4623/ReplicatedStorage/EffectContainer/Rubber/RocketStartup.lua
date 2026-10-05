local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
return function(p)
	local root = p.Root or p.HRP

	if (workspace.CurrentCamera.CFrame.Position - root.Position).magnitude > 500 then
		return
	end

	Util.Sound:Play("RubberRocketChargup", root, nil, 0.8333333333333333)
end