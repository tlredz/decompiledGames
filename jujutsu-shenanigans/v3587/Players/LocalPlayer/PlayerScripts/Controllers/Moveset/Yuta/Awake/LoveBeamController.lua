local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local _ = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "LoveBeamController"
})
local currentCamera = workspace.CurrentCamera

local function drawBeam(clone, cFrame, data)
	local v3 = math.max(data.Z - 20 - data.X / 2, 0)
	local _ = clone.BlackStart.Size.X
	clone.BlackStart.CFrame = cFrame * CFrame.new(0, 0, -10) * CFrame.Angles(-1.5707963267948966, 0, 0)
	clone.BlackStart.Size = Vector3.new(data.X, 20, data.Y)
	clone.PinkStart.CFrame = clone.BlackStart.CFrame
	clone.PinkStart.Size = clone.BlackStart.Size * createVector(0.875, 1, 0.875)
	clone.BlackMiddle.CFrame = cFrame * CFrame.new(0, 0, -(v3 / 2 + 20)) * CFrame.Angles(-1.5707963267948966, 0, 0)
	clone.BlackMiddle.Size = Vector3.new(data.X, v3, data.Y)
	clone.PinkMiddle.CFrame = clone.BlackMiddle.CFrame
	clone.PinkMiddle.Size = clone.BlackMiddle.Size * createVector(0.875, 1, 0.875)
	clone.BlackEnd.CFrame = cFrame * CFrame.new(0, 0, -(v3 + 20 + data.X / 4)) * CFrame.Angles(1.5707963267948966, 0, 0)
	clone.BlackEnd.Size = Vector3.new(data.X, data.X / 2, data.X)
	clone.PinkEnd.CFrame = clone.BlackEnd.CFrame
	clone.PinkEnd.Size = clone.BlackEnd.Size * createVector(0.875, 1, 0.875)
end

function controller.KnitStart(_)
	local random = Random.new()
	local v3 = {
		StartSound = function(p, instance)
			if not (p and p.Parent) then
				return
			end

			v2:PlaySound(sounds.Yuta.LoveBeam.ChargeSFX, p, game.SoundService.Effect)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Yuta.LoveBeam.Voiceline, humanoidRootPart, game.SoundService.Voice)
		end,
		Track = function(p, cFrame, value)
			if not p.Parent then
				return
			end

			TweenService:Create(p, TweenInfo.new(value or 0.3), {
				CFrame = cFrame
			}):Play()
		end,
		Bubble = function(parent, p)
			if not parent.Parent then
				return
			end

			local size = utils.Yuta.LoveBeam.ChargeBall.Size
			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true)
			TweenService:Create(parent, TweenInfo.new(0.2), {
				Size = size
			}):Play()
			TweenService:Create(parent.Outline, TweenInfo.new(0.2), {
				Size = size + createVector(0.07, 0.07, 0.07)
			}):Play()
			task.wait(0.2)

			repeat
				task.wait(0.05)
				local clone = utils.Yuta.LoveBeam.ChargeBall:Clone()
				local size2 = clone.Size
				clone.Size = createVector(0, 0, 0)
				clone.Outline.Size = createVector(0, 0, 0)
				local unit = (Vector3.new(
					math.random(-10, 10) / 10,
					math.random(-10, 10) / 10,
					math.random(-10, 10) / 10
				) * 9000000000).Unit
				local attachment = Instance.new("Attachment")
				attachment.Position = unit * (size2.Magnitude / 4)
				attachment.Parent = parent
				local rigidConstraint = Instance.new("RigidConstraint")
				rigidConstraint.Attachment0 = attachment
				rigidConstraint.Attachment1 = clone.Attachment
				rigidConstraint.Parent = attachment
				clone.Anchored = false
				clone.Parent = parent
				TweenService:Create(clone.Outline, tweenInfo, {
					Size = size2 + createVector(0.2, 0.2, 0.2)
				}):Play()
				TweenService:Create(clone, tweenInfo, {
					Size = size2
				}):Play()
				Debris:AddItem(clone, 0.3)
				Debris:AddItem(attachment, 0.3)
			until not (parent.Parent and p.Parent)
		end,
		SmallBeam = function(cFrame, instance)
			local clone = utils.Yuta.LoveBeam.Beam:Clone()
			v2:PlaySound(sounds.Yuta.LoveBeam.SmallBeam, clone.BlackMiddle, game.SoundService.Effect)

			for _, effect in clone:GetDescendants() do
				if effect:IsA("Beam") then
					effect.Enabled = false
				elseif effect:IsA("ParticleEmitter") then
					v2:ResizeParticle(effect, 0.3)
				end
			end

			clone.BlackStart.Glow.Position = createVector(0, -10, 0)
			local clone2 = utils.Yuta.LoveBeam.ChargeBall2:Clone()
			clone2.CFrame = cFrame
			clone2.Transparency = 1
			clone2.Parent = workspace.Effects

			for _, emitter in clone2:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					v2:ResizeParticle(emitter, 0.5)
				end
			end

			v2:PlayParticles(clone2.Attachment1)
			local vector3Value = Instance.new("Vector3Value")
			vector3Value.Value = createVector(2, 2, 180)
			drawBeam(clone, cFrame, Vector3.new(2, 2, instance:GetAttribute("BeamLength")))
			clone.Parent = workspace.Effects
			local v4 = false
			task.spawn(function()
				local v5

				if (currentCamera.CFrame.Position - cFrame.Position).Magnitude < 180 then
					v5 = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit)
				end

				repeat
					local v6 = v4 and createVector(0, 0, 0) or createVector(1, 1, 0) * random:NextNumber(1, 5)
					drawBeam(
						clone,
						cFrame,
						vector3Value.Value * createVector(1, 1, 0) + v6 + Vector3.new(
							0,
							0,
							instance:GetAttribute("BeamLength")
						)
					)
					task.wait()
				until not instance.Parent

				if v5 then
					v5:StartFadeOut(0.2)
				end
			end)
			task.wait(0.3)
			TweenService:Create(vector3Value, TweenInfo.new(0.3), {
				Value = createVector(0, 0, 180)
			}):Play()
			v4 = true

			for _, descendant in clone:GetDescendants() do
				if not (descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") or descendant:IsA("SpotLight")) then
					continue
				end

				descendant.Enabled = false
			end

			task.wait(1)
			clone:Destroy()
			clone2:Destroy()
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.fromRGB(255, 85, 255))
			v2:PlaySound(sounds.Yuta.LoveBeam.SmallBeamHit, humanoidRootPart, game.SoundService.Effect)
			local clone = replicatedStorage.Utils.Yuta.LoveBeam.BeamHit:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			v2:PlayParticles(clone)
		end
	}
	LoveBeamService.Effects:Connect(function(p, ...)
		local v4 = v3[p]

		if not v4 then
			return
		end

		v4(...)
	end)
end

function controller.KnitInit(_)
	LoveBeamService = Knit.GetService("LoveBeamService")
	v = Knit.GetController("HitboxController")
	v2 = Knit.GetController("FXController")
end

return controller