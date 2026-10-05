local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
game:GetService("Players")
local module = require("./PassiveHandler")
local _ = ReplicatedStorage.resources.replicated.fishing.customreels.cocorod
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local CocoRod = {
	Morph = function(_, data)
		task.delay(0.75, function()
			if not data then
				return
			end

			script.Leaves:Play()
			task.delay(0.5, function()
				for _, image in data.goob.leaves:GetChildren() do
					if not (image:IsA("ImageLabel") and string.find(image.Name, "Leaf", 1, true)) then
						continue
					end

					local v = string.find(image.Name, "R", 1, true) and true or false
					local rotation = tonumber((string.gsub(image.Name, "Leaf" .. (v and "R" or "L"), "")))

					if not v then
						rotation = -rotation
					end

					image.Rotation = rotation
					TweenService:Create(image, tweenInfo, {
						Rotation = 0
					}):Play()
				end

				task.wait(tweenInfo.Time * 0.8)

				if not data then
					return
				end

				data.goob.ArmL.Rotation = 10
				data.goob.ArmL.Position = UDim2.fromScale(0.5, 0.79)
				data.goob.ArmL.Visible = true
				TweenService:Create(data.goob.ArmL, tweenInfo2, {
					Position = UDim2.fromScale(0.5, 0.625),
					Rotation = 0
				}):Play()
				data.goob.ArmR.Rotation = -10
				data.goob.ArmR.Position = UDim2.fromScale(0.5, 0.79)
				data.goob.ArmR.Visible = true
				TweenService:Create(data.goob.ArmR, tweenInfo2, {
					Position = UDim2.fromScale(0.5, 0.625),
					Rotation = 0
				}):Play()
				task.wait(tweenInfo2.Time * 0.6)

				if not data then
					return
				end

				data.goob.Face.Position = UDim2.fromScale(0.5, 0.74)
				data.goob.Face.Visible = true
				TweenService:Create(data.goob.Face, tweenInfo2, {
					Position = UDim2.fromScale(0.5, 0.625)
				}):Play()
			end)
			TweenService:Create(data.GlowL, tweenInfo3, {
				ImageColor3 = Color3.fromRGB(0, 0, 255)
			}):Play()
			TweenService:Create(data.GlowR, tweenInfo3, {
				ImageColor3 = Color3.fromRGB(255, 0, 0)
			}):Play()
		end)
	end
}
setmetatable(CocoRod, module)
return CocoRod