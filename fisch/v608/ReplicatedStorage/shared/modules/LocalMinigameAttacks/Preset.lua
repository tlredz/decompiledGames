local Preset = {}
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("client"):WaitForChild("legacyControllers"):WaitForChild("ReelController"):WaitForChild("Types"))

function Preset.Start(p, p2)
	warn("started")
	task.spawn(ContentProvider.PreloadAsync, ContentProvider, { script })
	task.spawn(function()
		if not p2.ready then
			p2.OnReady:Wait()
		end

		local _ = p.playerbar
		tick()
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if p.Parent then
				return
			end

			heartbeatConnection:Disconnect()
		end)
	end)
end

return Preset