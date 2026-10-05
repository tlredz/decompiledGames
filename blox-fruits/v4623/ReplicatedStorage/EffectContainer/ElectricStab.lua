workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
require(ReplicatedStorage:WaitForChild("Util").LightningBolt.LightningExplosion)
local LightningBolt = require(ReplicatedStorage:WaitForChild("Util").LightningBolt)
local LightningSparks = require(ReplicatedStorage:WaitForChild("Util").LightningBolt.LightningSparks)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local cFrame = p.CFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 400 then
		return
	end

	local color = Color3.fromRGB(128, 187, 219)

	for i = 1, p.Distance - 20, 20 do
		local cFrame2 = cFrame * CFrame.new(0, 0, -i)
		local cframe = CFrame.new(0, 0, -20)
		local attachment = Instance.new("Attachment")
		attachment.CFrame = cFrame2
		attachment.Parent = workspace.Terrain
		local attachment2 = Instance.new("Attachment")
		attachment2.CFrame = cFrame2
		attachment2.Parent = workspace.Terrain
		local v2 = LightningBolt.new(attachment, attachment2, 2, 2, 6, color)
		v2.PulseLength = 0.4
		v2.FadeLength = 0.1
		v2.PulseSpeed = 2.5
		v2.MinThicknessMultiplier = 0.5
		v2.MaxThicknessMultiplier = 1
		v2.AnimationSpeed = 3
		v2.Thickness = 1
		v2.AddTransparency = 0
		local v3 = LightningSparks.new(v2, 6)
		v3.MinDistance = 9
		v3.MaxDistance = 18
		v3.MinSpeed = 9
		v3.MaxSpeed = 18
		local tween = TweenService:Create(attachment, TweenInfo.new(0.04000000000000001), {
			CFrame = cFrame2
		})
		tween.Completed:Connect(function()
			wait(0.8)
			attachment:Destroy()
		end)
		tween:Play()
		local tween2 = TweenService:Create(attachment2, TweenInfo.new(0.04000000000000001), {
			CFrame = cFrame2 * cframe
		})
		tween2.Completed:Connect(function()
			wait(0.8)
			attachment2:Destroy()
		end)
		tween2:Play()
		Effect.new("Ope-Ope.Shockwave"):replicate({
			cFrame2 * CFrame.new(0, 0, -25) * CFrame.Angles(1.5707963267948966, 0, 0),
			24,
			0.4
		})
		task.wait()
		task.wait()
	end
end