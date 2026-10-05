local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local util = game.ReplicatedStorage.Util
local LightningBolt = require(util.LightningBolt)
local LightningSparks = require(util.LightningBolt.LightningSparks)
local FX = require(game.ReplicatedStorage.FX)
local sound = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local _ = workspace.Map
local glowingCrack = game.ReplicatedStorage.Assets.Models.GlowingCrack
local burntArea = game.ReplicatedStorage.Assets.Models.BurntArea
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(data)
	local position = data.Position

	if (position - workspace.CurrentCamera.CFrame.p).magnitude > 600 then
		return
	end

	if not data.NoExplode then
		sound:Play("ShortExplosion3", position)
	end

	if not data.Nerf then
		sound:Play("ElectricImpactShort", position)
	end

	local size = data.Size or 85
	local clone = FX:WaitForChild("Attachments").LightningVortex:Clone()
	Util.Debris:AddItem(clone, 2)
	clone.ParticleEmitter.Size = NumberSequence.new(0, size * 1.25)

	if data.Color then
		clone.ParticleEmitter.Color = ColorSequence.new(data.Color)
	end

	clone.Parent = workspace.Terrain
	clone.CFrame = CFrame.new(position)
	clone.ParticleEmitter:Emit(1)

	for _ = 1, data.Nerf and 8 or 12 do
		local cframe = CFrame.new(0, 0, -size - math.random() * size * 0.75)
		local cFrame = clone.CFrame * CFrame.Angles(
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2,
			math.random() * 3.141592653589793 * 2
		)
		local attachment = Instance.new("Attachment")
		attachment.CFrame = cFrame
		attachment.Parent = workspace.Terrain
		local clone2 = clone.Beam:Clone()

		if data.Color then
			clone2.Color = ColorSequence.new(data.Color, Color3.new(1, 1, 1))
		end

		clone2.Width0 = size * (2.25 + math.random() * 1.5)
		clone2.Attachment0 = clone
		clone2.Attachment1 = attachment
		clone2.Parent = _WorldOrigin
		local tweenInfo = TweenInfo.new(0.1 + math.random() * 0.2)
		TweenService:Create(attachment, tweenInfo, {
			CFrame = cFrame * cframe
		}):Play()
		local tween = TweenService:Create(clone2, tweenInfo, {
			Width0 = 0
		})
		tween.Completed:Connect(function()
			attachment:Destroy()
			clone2:Destroy()
		end)
		tween:Play()
	end

	if not data.Nerf then
		if _G.FastMode then
			return
		end

		local cframe = CFrame.new(position)

		for _ = 1, 4 do
			local cFrame = cframe * CFrame.Angles(
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2
			)
			local cframe2 = CFrame.new(0, 0, size * 0.5)
			local attachment = Instance.new("Attachment")
			attachment.CFrame = cFrame
			attachment.Parent = workspace.Terrain
			local attachment2 = Instance.new("Attachment")
			attachment2.CFrame = cFrame * cframe2
			attachment2.Parent = workspace.Terrain
			local v2 = -size / 2
			local v3 = -size / 2
			local v4 = LightningBolt.new(
				attachment,
				attachment2,
				v2,
				v3,
				3,
				data.Color or Color3.new(math.random() > 0.5 and 0.2 or 1, 0.95, 1)
			)
			v4.PulseLength = 0.25
			v4.FadeLength = 0.1
			v4.PulseSpeed = 4
			v4.MinThicknessMultiplier = 0.5
			v4.MaxThicknessMultiplier = 1
			v4.AnimationSpeed = 6
			v4.Thickness = 5 + math.random() * 7.5
			v4.AddTransparency = 0
			local v5 = LightningSparks.new(v4, 3)
			v5.Color = Color3.new(1, 1, 1)
			v5.MinDistance = size / 4
			v5.MaxDistance = size / 2
			v5.MinSpeed = size / 4
			v5.MaxSpeed = size / 2
			local tween = TweenService:Create(attachment, TweenInfo.new(0.025), {
				CFrame = cFrame
			})
			tween.Completed:Connect(function()
				wait(0.5)
				attachment:Destroy()
			end)
			tween:Play()
			local tween2 = TweenService:Create(attachment2, TweenInfo.new(0.025), {
				CFrame = cFrame * cframe2 * cframe2
			})
			tween2.Completed:Connect(function()
				wait(0.5)
				attachment2:Destroy()
			end)
			tween2:Play()
		end
	end

	if data.NoBurn then
		return
	end

	local ray, v, v2 = Util.Ray(
		position + createVector(0, 1, 0),
		Vector3.new(0, data.Nerf and -5 or -20, 0),
		{ workspace.Enemies, workspace.Characters }
	)

	if ray then
		local cFrame = CFrame.new(v, v + v2) * CFrame.Angles(-1.5707963267948966, 0, 0)
		local attachment = Instance.new("Attachment")
		attachment.CFrame = cFrame
		attachment.Parent = workspace.Terrain
		local clone2 = FX:WaitForChild("ThorDust"):Clone()
		clone2.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, size * 0.2),
			NumberSequenceKeypoint.new(1, size * 0.3)
		})
		clone2.Rate *= 1.25
		clone2.Lifetime = NumberRange.new(0.25, 0.5)
		clone2.Drag += 4
		clone2.Speed = NumberRange.new(clone2.Speed.Min * size * 0.01, clone2.Speed.Max * size * 0.01 * 1.5)
		clone2.Color = ColorSequence.new(ray.Color)
		clone2.Parent = attachment
		local width = size * (0.7 + math.random() * 0.15) * (data.Nerf and 0.85 or 1)
		local clones = {}

		for i = 1, 2 do
			local clone3 = glowingCrack:Clone()
			clone3.Size = createVector(0.05, 0.05, 0.05)
			clone3.Beam.Transparency = NumberSequence.new(1)
			clone3.Attachment0.CFrame = CFrame.new(0, 0, width * 0.5)
			clone3.Attachment1.CFrame = CFrame.new(0, 0, -width * 0.5)
			clone3.Beam.Color = ColorSequence.new(Color3.fromRGB((i - 1) * 16 + 4, 180, 255))
			clone3.Beam.Width0 = width
			clone3.Beam.Width1 = width
			clone3.CFrame = (cFrame + createVector(0, 0.2, 0)) * CFrame.Angles(
				0,
				math.random() * 3.141592653589793 * 2,
				1.5707963267948966
			)
			clone3.Parent = workspace._WorldOrigin
			table.insert(clones, clone3)
		end

		local clone3 = burntArea:Clone()
		clone3.Decal.Transparency = 1
		clone3.Size = Vector3.new(width, 0, width) * 1.7
		clone3.Decal.Color3 = ray.Color
		clone3.CFrame = cFrame * CFrame.Angles(0, 3.141592653589793 * math.random() * 2, 0) + createVector(0, 0.1, 0)
		clone3.Parent = workspace._WorldOrigin
		TweenService:Create(clone3.Decal, TweenInfo.new(0.1), {
			Transparency = 0.4
		}):Play()
		coroutine.resume(coroutine.create(function()
			local lastTime = tick()

			while clone3 and clone3.Parent and tick() - lastTime < 0.1 do
				local v5 = math.min(tick() - lastTime, 0.1)

				for _, v6 in pairs(clones) do
					v6.Beam.Transparency = NumberSequence.new(1 - v5 * 6)
				end

				task.wait()
			end

			for _, v5 in pairs(clones) do
				v5.Beam.Transparency = NumberSequence.new(0.4)
			end
		end))
		task.delay(0.15, function()
			attachment.ThorDust.Enabled = false
			wait(0.6)
			attachment:Destroy()
			local tween = TweenService:Create(clone3.Decal, TweenInfo.new(1.5), {
				Transparency = 1
			})
			tween.Completed:Connect(function()
				clone3:Destroy()
			end)
			tween:Play()
			local numberValue = Instance.new("NumberValue")
			numberValue.Value = 0.4
			TweenService:Create(numberValue, TweenInfo.new(2), {
				Value = 1
			}):Play()
			coroutine.resume(coroutine.create(function()
				while clone3 and clone3.Parent do
					for _, v5 in pairs(clones) do
						v5.Beam.Transparency = NumberSequence.new(numberValue.Value)
					end

					task.wait()
				end

				for _, v5 in pairs(clones) do
					v5:Destroy()
				end

				numberValue:Destroy()
			end))
		end)
	end
end