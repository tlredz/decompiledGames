return function(object, _, _)
	local eulerAnglesYXZ, _, _ = workspace.CurrentCamera.CFrame:ToEulerAnglesYXZ()
	local v = math.clamp(eulerAnglesYXZ / 1.3962634015954636, -1, 1)
	object:CreateSound("rbxassetid://82715240396507", 1, 1, true, 10)
	object:CreateSound("rbxassetid://100943371677728", 1, v * 0.5 + 1, true, 10)
end