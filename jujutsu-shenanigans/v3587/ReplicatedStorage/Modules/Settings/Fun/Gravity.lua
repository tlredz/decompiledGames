local renderSteppedConnection = nil
local RunService = game:GetService("RunService")
return {
	Btn = 1,
	SortOrder = 2,
	Desc = "The world is upside down, scream.",
	Callback = function(p)
		if p == true and not renderSteppedConnection then
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				workspace.CurrentCamera.CFrame *= CFrame.Angles(0, 0, 3.141592653589793)
			end)
		elseif renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end
	end
}