workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = game.ReplicatedStorage.Util
local sound = Util.Sound
local _ = Util.MasterClock
local FX = require(game.ReplicatedStorage.FX)
local _ = workspace._WorldOrigin
local _ = workspace.Map
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Lightning = require(game.ReplicatedStorage.Util.Lightning)
return function(data)
	if data.Mode == 1 then
		local root = data.Root
		local _ = data.Holding

		if (root.Position - workspace.CurrentCamera.CFrame.p).magnitude > 600 then
			return
		end

		local position = root.Position
		sound:Play("ElectricZap", position)
		local size = data.Size or 85
		local clone = FX:WaitForChild("Attachments").LightningVortex:Clone()
		clone.ParticleEmitter.Size = NumberSequence.new(size, 0)
		clone.ParticleEmitter.Transparency = NumberSequence.new(1, 0)
		clone.Parent = workspace.Terrain
		clone.CFrame = CFrame.new(position)
		clone.ParticleEmitter:Emit(1)

		for i = 1, 7 do
			local cframe = CFrame.new(0, 0, -size - math.random() * size)
			local cFrame = clone.CFrame * CFrame.Angles(
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2
			)
			local attachment = Instance.new("Attachment")
			attachment.CFrame = cFrame * cframe
			attachment.Parent = workspace.Terrain
			local clone2 = clone.Beam:Clone()
			clone2.Width0 = 0
			clone2.Attachment0 = clone
			clone2.Attachment1 = attachment
			clone2.Parent = workspace.Terrain
			local tweenInfo = TweenInfo.new(0.1 + math.random() * 0.2)
			TweenService:Create(attachment, tweenInfo, {
				CFrame = cFrame
			}):Play()
			local tween = TweenService:Create(clone2, tweenInfo, {
				Width0 = size * 0.33 * (1 + math.random())
			})
			tween.Completed:Connect(function()
				attachment:Destroy()
				clone2:Destroy()
			end)
			tween:Play()

			if i % 2 == 0 then
				Lightning.new({
					Lifetime = 0.1 + math.random() * 0.2,
					DrawType = "Singular",
					Colors = {
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(65, 225, 255))
					},
					Sizes = {
						{
							Size = 0.33749999999999997,
							Time = 0
						},
						{
							Size = 2.25,
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
							Position = position
						},
						End = {
							Position = position + Vector3.new(
								math.random() - 0.5,
								math.random() - 0.5,
								math.random() - 0.5
							).unit * math.random(15, 20)
						}
					},
					ArcSize = {
						Min = 10,
						Max = 30
					},
					ChangesSegmentOffset = true,
					OffsetChangePercent = {
						EqualOrBelow = 0.15,
						Bounds = { 0, 1 }
					}
				})
			end
		end

		wait(1)
		clone:Destroy()
	elseif data.Mode == 2 then
		local old = data.Old
		local position = data.Position
		local _ = data.Holding

		if (position - workspace.CurrentCamera.CFrame.p).magnitude > 600 then
			return
		end

		if data.Boom then
			Effect.new("Awakening.RumbleZExplosion"):replicate({
				Position = position,
				Size = data.Scale or 65,
				Nerf = true
			})
		end

		for _ = 1, 2 do
			Lightning.new({
				Lifetime = 0.1 + math.random() * 0.2,
				DrawType = "Singular",
				Colors = {
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(65, 225, 255))
				},
				Sizes = {
					{
						Size = 0.33749999999999997,
						Time = 0
					},
					{
						Size = 2.25,
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
						Position = old
					},
					End = {
						Position = position
					}
				},
				ArcSize = {
					Min = 10,
					Max = 20
				},
				ChangesSegmentOffset = true,
				OffsetChangePercent = {
					EqualOrBelow = 0.15,
					Bounds = { 0, 1 }
				}
			})
		end
	end
end