local RunService = game:GetService("RunService")
local now = 0
local v = 0.025

if RunService:IsServer() then
	RunService.Heartbeat:Connect(function()
		task.defer(function()
			now = os.clock()
		end)
	end)
else
	RunService.PreRender:Connect(function()
		task.defer(function()
			now = os.clock()
		end)
	end)
end

local Reliever = {}

function Reliever.relieve()
	if os.clock() - now > 0.016666666666666666 then
		task.wait()
	end
end

function Reliever.setMax(p: number)
	v = p
end

return Reliever