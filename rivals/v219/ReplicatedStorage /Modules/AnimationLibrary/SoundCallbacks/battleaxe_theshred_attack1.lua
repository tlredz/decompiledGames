return function(object, _, _)
	local eulerAnglesYXZ, _, _ = workspace.CurrentCamera.CFrame:ToEulerAnglesYXZ()
	local v = math.clamp(eulerAnglesYXZ / 1.3962634015954636, -1, 1)
	object:CreateSound("rbxassetid://77594993345414", 0.875, v * 0.4 + 0.8, true, 5)
	object:CreateSound("rbxassetid://132970131270232", 0.875, v * 0.2 + 0.9, true, 5)
end