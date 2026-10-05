local renderSteppedConnection = nil
local localPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
return {
	Btn = 1,
	SortOrder = 1,
	Val = "FPS",
	Desc = "See your current framerate",
	Callback = function(visible)
		local FPS = localPlayer.PlayerGui:WaitForChild("Main"):WaitForChild("FPS")
		FPS.Visible = visible

		if visible == true and not renderSteppedConnection then
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
				FPS.Text = tostring((math.ceil(1 / dt))) .. " FPS"
			end)
		elseif renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end
	end
}