local RunService = game:GetService("RunService")
return {
	Bind = function(callback)
		local v = -1
		local v2 = nil
		local v3 = nil
		local count = 0
		local v4 = nil
		local v5 = nil
		return RunService.RenderStepped:Connect(function()
			local currentCamera = workspace.CurrentCamera

			if not currentCamera then
				return
			end

			local viewportSize = currentCamera.ViewportSize

			if viewportSize.X <= 1 or viewportSize.Y <= 1 then
				return
			end

			if currentCamera == v2 and viewportSize == v3 then
				count += 1
			else
				v2 = currentCamera
				v3 = viewportSize
				count = 0
			end

			local v6 = not game.Players.LocalPlayer and 0 or game.Players.LocalPlayer:GetAttribute("MobileLayoutRevision") or 0

			if count >= 2 and (v4 ~= viewportSize or v5 ~= currentCamera or v ~= v6) then
				v = v6
				v4 = viewportSize
				v5 = currentCamera
				callback()
			end
		end)
	end
}