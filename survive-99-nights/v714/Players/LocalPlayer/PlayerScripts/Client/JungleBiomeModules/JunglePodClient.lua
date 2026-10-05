local JunglePodClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local RunService = game:GetService("RunService")

function SinkFoliage(instance, p, p2, position)
	task.delay(p / 2, function()
		if instance.Parent == nil then
			return
		end

		p2 = p2
		local pivot = instance:GetPivot()
		local _, v = instance:GetBoundingBox()
		local _ = v.Y + 1
		local total = 0

		while total < p2 do
			total += RunService.Heartbeat:Wait()

			if instance.Parent == nil then
				return
			end

			local v2 = (math.min(total / p2, 1) * 0.7 + 0.3) * 0.06981317007977318
			instance:PivotTo(pivot * CFrame.Angles(math.sin(total * 15) * v2, 0, math.cos(total * 11) * v2))
		end

		Client.Events.DestroyObject:Fire(instance, CFrame.new(position), nil, true)
	end)
end

Client.Events.SinkJungleFoliage:Connect(function(items, p, p2)
	for _, item in pairs(items) do
		if item.Model then
			SinkFoliage(item.Model, item.Delay, p, p2)
		end
	end
end)

function JunglePodClient.Init() end

return JunglePodClient