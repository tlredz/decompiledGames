local createVector = vector.create
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
local RunService = game:GetService("RunService")
return function(data)
	local cFrame = CFrame.new(data.HRP.CFrame.p, data.MousePos.Value) * CFrame.new(0, 1, -8)

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 500 then
		return
	end

	local clone = game.ReplicatedStorage.Assets.Models.Crosshair:Clone()
	clone.Parent = workspace._WorldOrigin
	clone.Size = createVector(0.05, 0.05, 0.05)
	clone.CFrame = cFrame

	for _, decal in pairs(clone:GetChildren()) do
		if decal:IsA("Decal") then
			decal.Transparency = 1
		end
	end

	for _, decal in pairs(clone:GetChildren()) do
		if decal:IsA("Decal") then
			TweenService:Create(decal, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
				Transparency = 0
			}):Play()
		end
	end

	local flag = false
	local tween = TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
		Size = createVector(10, 10, 0)
	})
	tween.Completed:Connect(function()
		repeat
			wait()
		until flag

		local tween2 = TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
			Size = createVector(18, 18, 0),
			CFrame = cFrame
		})
		tween2.Completed:Connect(function()
			local tween3 = TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
				Size = createVector(0, 0, 0),
				CFrame = cFrame
			})
			tween3.Completed:Connect(function()
				clone:Destroy()
			end)
			tween3:Play()
		end)
		tween2:Play()
	end)
	tween:Play()
	local lastTime = tick()

	if not (data.Holding and data.HRP:IsDescendantOf(workspace)) then
		flag = true
		return
	end

	repeat
		cFrame = CFrame.new(data.HRP.CFrame.p, data.MousePos.Value) * CFrame.new(0, 1, -7) * CFrame.Angles(
			0,
			0,
			-(tick() - lastTime) * 0.5
		)
		clone.CFrame = clone.CFrame:Lerp(cFrame, 0.2)
		RunService.RenderStepped:Wait()
	until not data.HRP:IsDescendantOf(workspace) or data.Holding.Value == false

	if tick() - lastTime < 0.35 then
		wait(0.35 - (tick() - lastTime))
	end

	flag = true
	local color = Color3.fromRGB(128, 187, 219)
	Effect.new("Ope-Ope.Shockwave"):replicate({ cFrame * CFrame.Angles(1.5707963267948966, 0, 0), 30, 0.6 })

	if not _G.FastMode then
		for i = 1, 6 do
			local v2 = i / 6 * 3.141592653589793 * 2
			local cFrame2 = cFrame * CFrame.Angles(0, 0, v2) * CFrame.new(0, 0, 0)
			local cframe = CFrame.new(8, 0, 8)
			local attachment = Instance.new("Attachment")
			attachment.CFrame = cFrame2
			attachment.Parent = workspace.Terrain
			local attachment2 = Instance.new("Attachment")
			attachment2.CFrame = cFrame2 * cframe
			attachment2.Parent = workspace.Terrain
			local v5 = LightningBolt.new(attachment, attachment2, -4, -4, 7, color)
			v5.PulseLength = 0.2
			v5.FadeLength = 0.1
			v5.PulseSpeed = 5
			v5.MinThicknessMultiplier = 0.5
			v5.MaxThicknessMultiplier = 1
			v5.AnimationSpeed = 1
			v5.Thickness = 1
			v5.AddTransparency = 0
			local v6 = LightningSparks.new(v5, 7)
			v6.MinDistance = 4
			v6.MaxDistance = 8
			v6.MinSpeed = 4
			v6.MaxSpeed = 8
			local tween2 = TweenService:Create(attachment, TweenInfo.new(0.020000000000000004), {
				CFrame = cFrame2
			})
			tween2.Completed:Connect(function()
				wait(0.4)
				attachment:Destroy()
			end)
			tween2:Play()
			local tween3 = TweenService:Create(attachment2, TweenInfo.new(0.020000000000000004), {
				CFrame = cFrame2 * cframe * cframe
			})
			tween3.Completed:Connect(function()
				wait(0.4)
				attachment2:Destroy()
			end)
			tween3:Play()
		end
	end

	local clone2 = game.ReplicatedStorage.Assets.Models.InjectionShot:Clone()
	clone2.Color = color
	clone2.CFrame = cFrame * CFrame.new(0, 0, -10)
	clone2.Parent = workspace._WorldOrigin
	local lastTime2 = tick()
	local value = nil

	while tick() - lastTime2 <= 0.1 and data.Distance do
		if data.Distance.Value == 0 then
			task.wait(0.016666666666666666)
		else
			value = data.Distance.Value
			break
		end
	end

	local v2 = value or 200
	local tweenInfo = TweenInfo.new(0.5)
	local v5 = cFrame * CFrame.new(0, 0, -v2)
	local v6 = TweenService:Create(clone2, tweenInfo, {
		Size = createVector(0, 0, 50),
		CFrame = v5 * CFrame.Angles(0, 0, 3.141592653589793)
	})
	v6.Completed:Connect(function()
		clone2:Destroy()
	end)
	v6:Play()

	if _G.FastMode then
		return
	end

	for i = 0, 4 do
		local cFrame2 = cFrame * CFrame.new(0, 0, -v2 / 5 * i)
		local cframe = CFrame.new(0, 0, -60)
		local attachment = Instance.new("Attachment")
		attachment.CFrame = cFrame2
		attachment.Parent = workspace.Terrain
		local attachment2 = Instance.new("Attachment")
		attachment2.CFrame = cFrame2
		attachment2.Parent = workspace.Terrain
		local v8 = LightningBolt.new(attachment, attachment2, 1, 1, 6, color)
		v8.PulseLength = 0.3
		v8.FadeLength = 0.1
		v8.PulseSpeed = 3.3333333333333335
		v8.MinThicknessMultiplier = 0.5
		v8.MaxThicknessMultiplier = 1
		v8.AnimationSpeed = 3
		v8.Thickness = 1
		v8.AddTransparency = 0
		local v9 = LightningSparks.new(v8, 6)
		v9.MinDistance = 4
		v9.MaxDistance = 8
		v9.MinSpeed = 4
		v9.MaxSpeed = 8
		local tween2 = TweenService:Create(attachment, TweenInfo.new(0.03), {
			CFrame = cFrame2
		})
		tween2.Completed:Connect(function()
			wait(0.6)
			attachment:Destroy()
		end)
		tween2:Play()
		local tween3 = TweenService:Create(attachment2, TweenInfo.new(0.03), {
			CFrame = cFrame2 * cframe
		})
		tween3.Completed:Connect(function()
			wait(0.6)
			attachment2:Destroy()
		end)
		tween3:Play()
		Effect.new("Ope-Ope.Shockwave"):replicate({
			cFrame2 * CFrame.new(0, 0, -20) * CFrame.Angles(1.5707963267948966, 0, 0),
			20,
			0.4
		})
		wait()
	end
end