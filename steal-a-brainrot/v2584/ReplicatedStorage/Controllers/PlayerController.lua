local RunService = game:GetService("RunService")
local v = 0
local PlayerController = {}

function PlayerController.GetFps(_)
	return v
end

function PlayerController.Start(_)
	RunService.RenderStepped:Connect(function(dt)
		debug.profilebegin("PlayerController")
		v = math.floor(1 / dt)
		debug.profileend()
	end)
end

return PlayerController