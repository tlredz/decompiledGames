local currentCamera = workspace.CurrentCamera
return function(_)
	local lastTime = tick()
	local v = 0

	while true do
		local RunService = game:GetService("RunService")

		if not RunService.RenderStepped:Wait() then
			break
		end

		currentCamera.CFrame *= CFrame.Angles(0, 0, (math.rad(v)))
		v = math.min(v + 17.5, 180)

		if tick() - lastTime >= 1.5 then
			break
		end
	end
end