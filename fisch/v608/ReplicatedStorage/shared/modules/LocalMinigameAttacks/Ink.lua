local Ink = {}
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("client"):WaitForChild("legacyControllers"):WaitForChild("ReelController"):WaitForChild("Types"))
local v = { "rbxassetid://106002851975931", "rbxassetid://82758784930036", "rbxassetid://71764342826069" }

local function Ink2(parent)
	for _ = 1, math.random(1, 3) do
		local clone = script:WaitForChild("InkSplatter"):Clone()
		clone.Image = v[math.random(1, #v)]
		clone.Size = UDim2.new(math.random(20, 40) / 100, 0, math.random(5, 8))
		clone.Rotation = math.random(-360, 360)
		clone.Position = UDim2.new(math.random(1, 100) / 100, 0, 0.5, 0)
		clone.Parent = parent
		TweenService:Create(clone, TweenInfo.new(math.random(4, 9), Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			ImageTransparency = 1,
			Rotation = clone.Rotation + math.random(-23, 23)
		}):Play()
		clone.SplatterSound:Play()
		clone.SplatterSound2:Play()
	end
end

function Ink.Start(p, p2)
	task.spawn(ContentProvider.PreloadAsync, ContentProvider, { script })
	task.spawn(function()
		if not p2.ready then
			p2.OnReady:Wait()
		end

		local _ = p.playerbar
		local now = 0
		local v2 = math.random(1, 2)
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if not p.Parent then
				heartbeatConnection:Disconnect()
				return
			end

			local v3 = os.clock() - now

			if v2 < v3 then
				now = os.clock()
				v2 = math.random(7, 8)
				Ink2(p)
			end
		end)
	end)
end

return Ink