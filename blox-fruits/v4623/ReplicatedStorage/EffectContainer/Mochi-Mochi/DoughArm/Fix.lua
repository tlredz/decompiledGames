local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
return function(instance)
	local v = _WorldOrigin:WaitForChild(instance.Name .. "DoughForearm", 1) or instance:WaitForChild(
		instance.Name .. "DoughForearm",
		1
	)

	if v then
		v.Weld.C0 = CFrame.Angles(-1.5707963267948966, 0, 0)
	end
end