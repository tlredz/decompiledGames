local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local TweenService = game:GetService("TweenService")
local Lightning = require(game.ReplicatedStorage.Util.Lightning)
game:GetService("RunService")
return function(p)
	local cFrame = p.CFrame
	local scale = p.Scale

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
		return
	end

	local v = _G.FastMode and 0.5 or 1
	local clone = script.PesadoBoom:Clone()
	clone.CFrame = cFrame * CFrame.new(0, 1, 0)
	clone.Mesh.Scale = Vector3.new()
	clone.Parent = _WorldOrigin
	clone.Pre.Slashes.Size = NumberSequence.new(scale * 0.2, 0, scale * 0.05)
	clone.Pre.Slashes:Emit(3 * v)
	clone.Pre.Spiral.Size = NumberSequence.new(scale * 0.15, 0, scale * 0.05)
	clone.Pre.Spiral:Emit(9 * v)
	clone.Pre.Sparks.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.25, scale * 0.2, scale * 0.05),
		NumberSequenceKeypoint.new(1, 0)
	})
	clone.Pre.Sparks:Emit(14 * v)
	Util.Sound:Play("SandCast2", cFrame)
	task.wait(0.15)
	clone.Pre.Star.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, scale * 0.11, scale * 0.04),
		NumberSequenceKeypoint.new(1, 0)
	})
	clone.Pre.Star:Emit(8 * v)
	task.wait(0.15)
	task.delay(3, function()
		clone:Destroy()
	end)
	Util.Sound:Play("SandVExplosion", cFrame)

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude < 200 then
		Util.CameraShaker:ShakeOnce(15, 30, 0.1, 2.5, createVector(1, 1, 1), createVector(1, 1, 2))
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		Util.Debris:AddItem(colorCorrectionEffect, 5)
		colorCorrectionEffect.Parent = game:GetService("Lighting")
		local blurEffect = Instance.new("BlurEffect")
		blurEffect.Size = 0
		Util.Debris:AddItem(blurEffect, 5)
		blurEffect.Parent = game:GetService("Lighting")
		local tween = TweenService:Create(
			colorCorrectionEffect,
			TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
			{
				Brightness = -0.25,
				Contrast = 0.5,
				Saturation = -1
			}
		)
		tween.Completed:Connect(function()
			colorCorrectionEffect:Destroy()
		end)
		tween:Play()
		local tween2 = TweenService:Create(
			blurEffect,
			TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
			{
				Size = 12
			}
		)
		tween2.Completed:Connect(function()
			blurEffect:Destroy()
		end)
		tween2:Play()
	end

	task.spawn(function()
		for i = 1, 13 do
			for _ = 1, 13 - i do
				Lightning.new({
					Lifetime = 0.1 + math.random() * 0.15,
					DrawType = "Singular",
					Colors = {
						ColorSequenceKeypoint.new(0, Color3.fromRGB(175, 80, 236)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 140, 255))
					},
					Sizes = {
						{
							Size = 1 + math.random() * 2 * 0.15,
							Time = 0
						},
						{
							Size = 1 + math.random() * 2,
							Time = 0.5
						},
						{
							Size = 0,
							Time = 1
						}
					},
					Transparencies = {
						{
							Transparency = 0,
							Time = 0
						},
						{
							Transparency = 0,
							Time = 1
						}
					},
					Points = {
						Start = {
							Position = cFrame.p
						},
						End = {
							Position = cFrame.p + Vector3.new(
								math.random() - 0.5,
								math.random() - 0.5,
								math.random() - 0.5
							).unit * (scale * (0.5 + math.random() * 0.5) * 0.75)
						}
					},
					ArcSize = {
						Min = scale * 0.333,
						Max = scale * 0.666
					},
					ChangesSegmentOffset = true,
					OffsetChangePercent = {
						EqualOrBelow = 0.15,
						Bounds = { 0, 1 }
					}
				})
			end

			task.wait(0.15)
		end
	end)
	local v2 = sound:Play("SandFlightLoop2", cFrame)

	for _ = 1, 7 do
		task.spawn(function()
			local clone2 = script.PesadoBoom:Clone()
			clone2.CFrame = cFrame * CFrame.new(0, 5, 0)
			clone2.Mesh.Scale = createVector(1, 1, 1) * scale
			clone2.Parent = _WorldOrigin
			clone2.Attachment.Background.Size = NumberSequence.new(scale * 0.075, scale * 0.75)
			clone2.Attachment.Background.Speed = NumberRange.new(scale * 0.5, scale * 2)
			clone2.Attachment.Background:Emit(5 * v)
			clone2.Attachment.BackgroundDark.Size = NumberSequence.new(scale * 0.075, scale * 0.75)
			clone2.Attachment.BackgroundDark.Speed = NumberRange.new(scale * 0.5, scale * 2)
			clone2.Attachment.BackgroundDark:Emit(5 * v)
			clone2.Attachment.Slashes.Size = NumberSequence.new(1, scale * 0.75, scale * 0.1)
			clone2.Attachment.Slashes:Emit(2 * v)
			clone2.Attachment.Spiral.Size = NumberSequence.new(scale * 0.1, scale, scale * 0.1)
			clone2.Attachment.Spiral:Emit(6 * v)
			clone2.Attachment.BoomFireflies.Size = NumberSequence.new(scale * 0.1, scale * 0.04, scale * 0.02)
			clone2.Attachment.BoomFireflies.Speed = NumberRange.new(scale * 0.1, scale * 2.5)
			clone2.Attachment.BoomFireflies:Emit(12 * v)
			clone2.Attachment.Sparks.Size = NumberSequence.new(scale * 0.2, 0)
			clone2.Attachment.Sparks.Speed = NumberRange.new(scale * 1.25, scale * 2.75)
			clone2.Attachment.Sparks:Emit(14 * v)
			clone2.Attachment.SparksDark.Size = NumberSequence.new(scale * 0.2, 0)
			clone2.Attachment.SparksDark.Speed = NumberRange.new(scale * 1.25, scale * 2.75)
			clone2.Attachment.SparksDark:Emit(14 * v)
			TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Size = createVector(1, 1, 1),
				Transparency = 1
			}):Play()
			wait(6)
			clone2:Destroy()
		end)
		task.wait(0.1)
	end

	task.wait(1)
	sound:FadeOut(v2, 1.5)
end