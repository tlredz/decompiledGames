return function(object, _, _)
	local eulerAnglesYXZ, _, _ = workspace.CurrentCamera.CFrame:ToEulerAnglesYXZ()
	object:CreateSound(
		"rbxassetid://120936003285451",
		0.875,
		math.clamp(eulerAnglesYXZ / 1.3962634015954636, -1, 1) * 0.25 + 1,
		true,
		5
	)
end