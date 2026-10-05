local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Net = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net"))
local remoteEvent = Net:RemoteEvent("GodbreakerPortal/Teleport")
return {
	Start = function(_)
		remoteEvent.OnClientEvent:Connect(function(_)
			script.Boom:Play()
			local renderSteppedConnection = nil
			local lastTime = os.clock()
			local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect.Brightness = 1
			colorCorrectionEffect.Parent = Lighting
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local v = (os.clock() - lastTime) / 3
				local value = TweenService:GetValue(
					math.clamp(v, 0, 1),
					Enum.EasingStyle.Exponential,
					Enum.EasingDirection.Out
				)
				workspace.CurrentCamera.CFrame *= CFrame.new(0, 0, 0, value, 0, 0, 0, value, 0, 0, 0, 1)
				colorCorrectionEffect.Brightness = 1 - value

				if v >= 1 then
					colorCorrectionEffect:Destroy()
					renderSteppedConnection:Disconnect()
					renderSteppedConnection = nil
				end
			end)
		end)
	end
}