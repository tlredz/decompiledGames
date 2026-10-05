local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Players")
local animatedgradient = require(ReplicatedStorage.shared.modules.fx.animatedgradient)
local _ = ReplicatedStorage.resources.replicated.fishing.customreels.prismaticrod
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
TweenInfo.new(1)
local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(tweenInfo2.Time * 0.4)
local tweenInfo4 = TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local module = require("./PassiveHandler")
local PrismaticRod = {
	Morph = function(p, instance)
		p.reelTrove:Add(RunService.Heartbeat:Connect(function()
			local rotation = workspace:GetServerTimeNow() * 360 / 2 % 360
			instance.EvilShine.UIGradient.Rotation = rotation
			instance.EvilShine.hello.UIStroke.UIGradient.Rotation = rotation
			instance.EvilShine.lightningL.Rotation = 90 + Random.new():NextNumber(-3, 3)
			instance.EvilShine.lightningR.Rotation = -90 + Random.new():NextNumber(-3, 3)
		end))
		local v = animatedgradient.new(animatedgradient._presets.Rainbow)
		v.Rotation = 90
		v.Parent = instance.EvilShine.hello
		local v2 = false
		task.delay(2, function()
			TweenService:Create(instance.HeartL, tweenInfo, {
				Position = UDim2.fromScale(-0.05, 0.5)
			}):Play()
			TweenService:Create(instance.HeartR, tweenInfo, {
				Position = UDim2.fromScale(1.05, 0.5)
			}):Play()
			script.Heart:Play()
			task.wait(tweenInfo.Time + 0.25)

			if not instance then
				return
			end

			if instance:FindFirstChild("HeartL") and instance:FindFirstChild("HeartR") then
				TweenService:Create(instance.HeartL, tweenInfo, {
					Position = UDim2.fromScale(-0.05, 0.5)
				}):Play()
				TweenService:Create(instance.HeartR, tweenInfo, {
					Position = UDim2.fromScale(1.05, 0.5)
				}):Play()
			end
		end)
		task.spawn(function()
			while true do
				task.wait(0.4)

				if not instance then
					break
				end

				v2 = not v2
				instance.UIScale.Scale = 1.1
				instance.Rotation = v2 and -4 or 4
				TweenService:Create(instance, tweenInfo4, {
					Rotation = 0
				}):Play()
				TweenService:Create(instance.UIScale, tweenInfo4, {
					Scale = 1
				}):Play()
				instance.EvilShine.UIScale.Scale = 1.15
				TweenService:Create(instance.EvilShine.UIScale, tweenInfo4, {
					Scale = 1
				}):Play()

				for i = 1, 2 do
					local clone = instance.progress.Ring:Clone()
					clone.Name = "NewRing"
					clone.Visible = true
					clone.Position = UDim2.fromScale(i == 1 and 0 or 1, 0.5)
					clone.Parent = instance.progress
					TweenService:Create(clone, tweenInfo2, {
						Position = UDim2.fromScale(i == 1 and -0.25 or 1.25, 0.5)
					}):Play()
					TweenService:Create(clone.UIScale, tweenInfo2, {
						Scale = 1.75
					}):Play()
					task.delay(tweenInfo2.Time * 0.5, function()
						if not clone then
							return
						end

						TweenService:Create(clone, tweenInfo3, {
							ImageTransparency = 1
						}):Play()
					end)
				end
			end
		end)
	end
}
setmetatable(PrismaticRod, module)
return PrismaticRod