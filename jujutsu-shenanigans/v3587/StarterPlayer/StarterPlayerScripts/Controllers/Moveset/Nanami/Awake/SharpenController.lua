local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local SraikoVFX = require(replicatedStorage.Modules.SraikoVFX)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "SharpenController"
})
local emit = SraikoVFX.Emit
local _ = SraikoVFX.Enabled
local emitMesh = SraikoVFX.EmitMesh

function controller.KnitStart(_)
	local v4 = {
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Todo.BruteForce.Hit, humanoidRootPart, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 80 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end

			if p then
				v2:PlaySound(sounds.Itadori.Dismantle.Explode, humanoidRootPart, game.SoundService.Effect)
				v2:Bleed(instance)

				if localPlayer.Character == instance then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)

					if _G.Settings.Flash ~= true then
						return
					end

					local clone2 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
					clone2.TintColor = Color3.new(1, 1, 1)
					clone2.Parent = game.Lighting
					task.wait(0.04)
					clone2.Brightness = 200
					clone2.Contrast = -1000
					task.wait(0.04)
					clone2:Destroy()
				end
			end
		end,
		Slash2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Nanami.Sharpen.JumpSlash, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Nanami.Sharpen.SharpenAir.SlashEmit:Clone()
			clone.CFrame = humanoidRootPart.CFrame - createVector(0, 5, 0)
			clone.Parent = workspace.Effects

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			Debris:AddItem(clone, 1.5)
			local clone2 = utils.Nanami.Sharpen.SharpenAir.SlashBeam:Clone()
			clone2.CFrame = humanoidRootPart.CFrame
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 1.5)

			for _, beam in pairs(clone2:GetDescendants()) do
				if beam:IsA("Beam") then
					beam.Enabled = true
				end
			end

			for _, beam in pairs(clone2:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				TweenService:Create(beam, TweenInfo.new(0.19), {
					Width0 = 0,
					Width1 = 0
				}):Play()
				local v5 = beam
				task.delay(0.29000000000000004, function()
					v5.Enabled = false
					v5.Width0 = 17
					v5.Width1 = 17
				end)
			end

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		CleaverSlam = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			emit(utils.Nanami.Sharpen.VFX.DustLand.Emit.VFX, humanoidRootPart.CFrame, false, 1.5)
			emitMesh(
				utils.Nanami.Sharpen.VFX.DustLand.Meshes.MeshDownSlam,
				humanoidRootPart.CFrame * utils.Nanami.Sharpen.VFX.DustLand.Meshes.MeshDownSlam.WorldPivot
			)
		end,
		CleaverTrail = function(parent)
			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Nanami.Sharpen.VFX.MovingTrail.Trail:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Parent = parent
			Debris:AddItem(clone, 2)
			task.wait(0.4)

			for _, effect in clone:GetDescendants() do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end,
		Slash = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Nanami.Sharpen.Slash, humanoidRootPart, game.SoundService.Effect)
			emit(utils.Nanami.Sharpen.VFX.SlashR.Emit.Slash, humanoidRootPart.CFrame, false, 3)
			local clone = utils.Nanami.Sharpen.VFX.Slash.Slash:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1.5)

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("Beam") or effect:IsA("ParticleEmitter") then
					effect.Enabled = true
				end
			end

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("Beam") then
					TweenService:Create(effect, TweenInfo.new(0.12), {
						Width0 = 0,
						Width1 = 0
					}):Play()
					local v5 = effect
					task.delay(0.22, function()
						v5.Enabled = false
						v5.Width0 = 25
						v5.Width1 = 25
					end)
				elseif effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				end
			end
		end,
		RatioBar = function(instance, p)
			local C1 = p.SharpenRatio.Weld.C1
			p.SharpenRatio.Weld.C1 = C1 * CFrame.Angles(0, 0, 1.5707963267948966)
			TweenService:Create(p.SharpenRatio.Weld, TweenInfo.new(0.03, Enum.EasingStyle.Linear), {
				C1 = C1 * CFrame.Angles(0, 0, 3.141592653589793)
			}):Play()
			task.wait(0.03)
			TweenService:Create(p.SharpenRatio.Weld, TweenInfo.new(0.06, Enum.EasingStyle.Linear), {
				C1 = C1 * CFrame.Angles(0, 0, 4.71238898038469)
			}):Play()
			task.wait(0.06)
			TweenService:Create(
				p.SharpenRatio.Weld,
				TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					C1 = C1
				}
			):Play()
			local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Nanami.Sharpen.JumpWindup, humanoidRootPart, game.SoundService.Effect)
		end,
		RatioBreak = function(p, p2)
			v2:PlaySound(sounds.Nanami.Sharpen.RatioHit, p2, game.SoundService.Effect)
			p2.Shock.Transparency = 0
			task.wait(0.03)
			p2.Shock.Transparency = 1
			local front = p2.SharpenRatio.Front
			local back = p2.SharpenRatio.Back
			front.Bar.Visible = false
			front.Cursor.Visible = false
			front.FakeBar1.Visible = true
			front.FakeBar2.Visible = true
			back.Bar.Visible = false
			back.Cursor.Visible = false
			back.FakeBar1.Visible = true
			back.FakeBar2.Visible = true
			local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			local tweenInfo2 = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
			TweenService:Create(front.FakeBar1, tweenInfo, {
				Rotation = 45
			}):Play()
			TweenService:Create(front.FakeBar2, tweenInfo, {
				Rotation = 45
			}):Play()
			TweenService:Create(back.FakeBar1, tweenInfo, {
				Rotation = -45
			}):Play()
			TweenService:Create(back.FakeBar2, tweenInfo, {
				Rotation = -45
			}):Play()
			TweenService:Create(front.FakeBar1, tweenInfo2, {
				ImageTransparency = 1
			}):Play()
			TweenService:Create(front.FakeBar2, tweenInfo2, {
				ImageTransparency = 1
			}):Play()
			TweenService:Create(back.FakeBar1, tweenInfo2, {
				ImageTransparency = 1
			}):Play()
			TweenService:Create(back.FakeBar2, tweenInfo2, {
				ImageTransparency = 1
			}):Play()

			if localPlayer == p then
				local clone = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone.TintColor = Color3.fromRGB(60, 60, 60)
				clone.Brightness = -0.8
				clone.Contrast = 0
				clone.Saturation = 0

				if _G.Settings.Flash ~= true then
					clone.Brightness = 0
					clone.TintColor = Color3.new(1, 1, 1)
				end

				clone.Parent = game.Lighting
				front.AlwaysOnTop = true
				back.AlwaysOnTop = true
				task.spawn(function()
					task.wait(0.04)
					task.wait(0.04)
					clone.Brightness = -0.6
					TweenService:Create(clone, TweenInfo.new(0.2), {
						Brightness = 0,
						TintColor = Color3.new(1, 1, 1)
					}):Play()
					Debris:AddItem(clone, 0.2)
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
					task.wait(0.2)
					front.AlwaysOnTop = false
					back.AlwaysOnTop = false
				end)
			end
		end
	}
	v.Effects:Connect(function(p, ...)
		local v5 = v4[p]

		if not v5 then
			return
		end

		v5(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("SharpenService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller