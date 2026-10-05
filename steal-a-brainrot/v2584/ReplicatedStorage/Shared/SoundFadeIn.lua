local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local renderStepped = RunService:IsClient() and RunService.RenderStepped or RunService.Heartbeat

local function SoundFadeIn(object, p: number, volume: number, p2, p3)
	local v = p2 or Enum.EasingStyle.Linear
	local v2 = p3 or Enum.EasingDirection.In

	if object.Playing then
		return
	end

	object.Volume = 0
	object:Play()
	local total = 0
	local connection = nil
	connection = renderStepped:Connect(function(p4)
		total += p4

		if total < p then
			local value = TweenService:GetValue(total / p, v, v2)
			object.Volume = math.lerp(0, volume, (math.max(0, value)))
		else
			connection:Disconnect()
			object.Volume = volume
		end
	end)
end

return SoundFadeIn