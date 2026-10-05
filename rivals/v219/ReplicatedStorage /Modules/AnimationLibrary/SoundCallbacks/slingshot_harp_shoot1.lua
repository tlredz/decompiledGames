return function(object, _, _)
	local eulerAnglesYXZ, _, _ = workspace.CurrentCamera.CFrame:ToEulerAnglesYXZ()
	local v = math.clamp(eulerAnglesYXZ / 1.3962634015954636, -1, 1)
	object:CreateSound("rbxassetid://117069125273832", 0.75, v * 0.5 + 1.75, true, 5)
	object:CreateSound("rbxassetid://127039236309973", 1, v * 0.25 + 1, true, 5)
end