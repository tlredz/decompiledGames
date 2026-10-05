local CupidsEmbrace = {}
local Players = game:GetService("Players")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
require(ReplicatedStorage.packages.Net)
require(ReplicatedStorage.client.legacyControllers.StatusEffectsController)

function CupidsEmbrace.Morph(p, p2, object)
	task.spawn(function()
		object:WaitUntilReady()
		local _ = Players.LocalPlayer
		local modifier = object:CreateModifier("resilience", "add")
		local modifier2 = object:CreateModifier("progressefficiency", "add")
		local heart = script:FindFirstChild("Heart")
		local now = 0
		local onLogicStepConnection = nil
		onLogicStepConnection = object.OnLogicStep:Connect(function(p3: number)
			if not p2.Parent then
				onLogicStepConnection:Disconnect()
				return
			end

			if not object.active then
				return
			end

			modifier.Value += p.config.ResilienceGainRate * p3
			local v2 = math.max(0, 1 - (object.progressefficiency - modifier2.Value))

			if math.abs(modifier2.Value - v2) > 0.001 then
				if v2 < modifier2.Value then
					modifier2.Value = math.max(v2, modifier2.Value - p.config.ProgressSpeedDecayRate * p3)
				else
					modifier2.Value = math.min(v2, modifier2.Value + p.config.ProgressSpeedDecayRate * p3)
				end
			end

			if heart and object.onbar and tick() - now >= p.config.HeartInterval then
				now = tick()
				local clone = heart:Clone()
				clone.ImageTransparency = 0
				clone.Position = UDim2.fromScale(0.5, -0.4)
				clone.Parent = p2.fish.icon
				local v3 = object.renderTweens:Create(
					clone,
					TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Position = clone.Position + UDim2.fromScale(0, -1.4),
						ImageTransparency = 1
					}
				)
				v3:Play()
				v3.Completed:Once(function()
					clone:Destroy()
				end)
			end
		end)
		p.reelTrove:Add(function()
			onLogicStepConnection:Disconnect()
		end)
	end)
end

setmetatable(CupidsEmbrace, module)
return CupidsEmbrace