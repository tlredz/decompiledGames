local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local renderStepped = RunService:IsClient() and RunService.RenderStepped or RunService.Heartbeat

local function SoundFadeOut(object, p: number, p2, p3)
	local v = p2 or Enum.EasingStyle.Linear
	local v2 = p3 or Enum.EasingDirection.Out

	if not object.Playing then
		return
	end

	local volume = object.Volume
	local total = 0
	local connection = nil
	connection = renderStepped:Connect(function(p4)
		total += p4

		if total < p then
			local value = TweenService:GetValue(total / p, v, v2)
			object.Volume = math.lerp(volume, 0, (math.min(1, value)))
		else
			connection:Disconnect()
			object.Volume = 0
			object:Stop()
		end
	end)
end

return SoundFadeOut