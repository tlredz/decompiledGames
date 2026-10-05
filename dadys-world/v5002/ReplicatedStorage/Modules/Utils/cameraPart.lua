local RunService = game:GetService("RunService")
local renderSteppedConnection = nil
local v = nil
local CameraPart = {}

function CameraPart.Attach(p, p2)
	local currentCamera = workspace.CurrentCamera
	v = p
	local v2 = p2 or CFrame.new()

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		if v and currentCamera then
			v.CFrame = currentCamera.CFrame * v2
		end
	end)
end

function CameraPart.Detach()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	if v then
		v:Destroy()
		v = nil
	end
end

return CameraPart