workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local util = game.ReplicatedStorage.Util
local LightningBolt = require(util.LightningBolt)
require(util.LightningBolt.LightningSparks)
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local color = Color3.fromRGB(175, 221, 255)
return function(data)
	local cFrame = data.CFrame
	local scale = data.Scale or 5
	local magnitude = (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude

	if 100 + 50 * scale < magnitude then
		return
	end

	local clone = game.ReplicatedStorage.Assets.Models.TremorCrack:Clone()
	clone.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
	clone.Size = Vector3.new(scale * 1.5, 0.05, scale * 1.5)
	clone.Parent = workspace._WorldOrigin
	local clone2 = game.ReplicatedStorage.Assets.Models.TremorCrack:Clone()
	clone2.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
	clone2.Transparency = 0.9
	clone2.Material = "SmoothPlastic"
	clone2.Size = Vector3.new(scale * 1.5, 0.05, scale * 1.5)
	clone2.Parent = workspace._WorldOrigin

	if data.Delay then
		wait(data.Delay)
	end

	local tween = TweenService:Create(clone2, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {
		Size = Vector3.new(scale * 1.5, scale * 3, scale * 1.5),
		Transparency = 1,
		CFrame = cFrame * CFrame.new(0, 0, scale * 1.5) * CFrame.Angles(1.5707963267948966, 0, 0)
	})
	tween.Completed:Connect(function()
		clone2:Destroy()
		local tween2 = TweenService:Create(clone, TweenInfo.new(0.3), {
			Transparency = 1
		})
		tween2.Completed:Connect(function()
			clone:Destroy()
		end)
		tween2:Play()
	end)
	tween:Play()

	if data.Player and game.Players.LocalPlayer == data.Player then
		local blurEffect = Instance.new("BlurEffect")
		blurEffect.Size = 12
		blurEffect.Parent = game.Lighting
		local tween2 = TweenService:Create(blurEffect, TweenInfo.new(0.2), {
			Size = 0
		})
		tween2.Completed:Connect(function()
			blurEffect:Destroy()
		end)
		tween2:Play()
	end

	local magnitude2 = (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude

	if 100 + 25 * scale < magnitude2 or _G.FastMode then
		return
	end

	for i = 1, 3 do
		local v = i / 3 * 3.141592653589793 * 2
		local cFrame2 = cFrame * CFrame.Angles(0, 0, v) * CFrame.new(0, 0, 0)
		local cframe = CFrame.new(scale * 2, 0, scale * 0.25)
		local attachment = Instance.new("Attachment")
		attachment.CFrame = cFrame2
		attachment.Parent = workspace.Terrain
		local attachment2 = Instance.new("Attachment")
		attachment2.CFrame = cFrame2 * cframe
		attachment2.Parent = workspace.Terrain
		local v3 = -scale / 2
		local v4 = -scale / 2
		local v5 = LightningBolt.new(attachment, attachment2, v3, v4, 6, color)
		v5.PulseLength = 0.5
		v5.FadeLength = 0.1
		v5.PulseSpeed = 2
		v5.MinThicknessMultiplier = 0.1
		v5.MaxThicknessMultiplier = 1
		v5.AnimationSpeed = 6
		v5.Thickness = 1
		v5.AddTransparency = 0
		local tween2 = TweenService:Create(attachment, TweenInfo.new(0.05), {
			CFrame = cFrame2
		})
		tween2.Completed:Connect(function()
			wait(1)
			attachment:Destroy()
		end)
		tween2:Play()
		local tween3 = TweenService:Create(attachment2, TweenInfo.new(0.05), {
			CFrame = cFrame2 * cframe * cframe
		})
		tween3.Completed:Connect(function()
			wait(1)
			attachment2:Destroy()
		end)
		tween3:Play()
	end

	for i = 1, 3 do
		local v = i / 3 * 3.141592653589793 * 2
		local cFrame2 = cFrame * CFrame.Angles(0, 0, v) * CFrame.new(scale * 0.75, 0, scale * 0.25)
		local cframe = CFrame.new(scale, 0, scale * 2)
		local attachment = Instance.new("Attachment")
		attachment.CFrame = cFrame2
		attachment.Parent = workspace.Terrain
		local attachment2 = Instance.new("Attachment")
		attachment2.CFrame = cFrame2 * cframe
		attachment2.Parent = workspace.Terrain
		local v3 = -scale / 2
		local v4 = -scale / 2
		local v5 = LightningBolt.new(attachment, attachment2, v3, v4, 7, color)
		v5.PulseLength = 0.6
		v5.FadeLength = 0.1
		v5.PulseSpeed = 1.6666666666666667
		v5.MinThicknessMultiplier = 0.1
		v5.MaxThicknessMultiplier = 1
		v5.AnimationSpeed = 6
		v5.Thickness = 1
		v5.AddTransparency = 0
		local tween2 = TweenService:Create(attachment, TweenInfo.new(0.06), {
			CFrame = cFrame2
		})
		tween2.Completed:Connect(function()
			wait(1.2)
			attachment:Destroy()
		end)
		tween2:Play()
		local tween3 = TweenService:Create(attachment2, TweenInfo.new(0.06), {
			CFrame = cFrame2 * cframe * cframe
		})
		tween3.Completed:Connect(function()
			wait(1.2)
			attachment2:Destroy()
		end)
		tween3:Play()
	end
end