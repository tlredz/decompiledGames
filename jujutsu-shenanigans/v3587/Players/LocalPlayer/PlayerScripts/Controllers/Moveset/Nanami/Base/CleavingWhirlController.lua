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
local BloodyZee = require(replicatedStorage.Modules.BloodyZee)
require(replicatedStorage.Modules.SraikoVFX)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "CleavingWhirlController"
})

function controller.KnitStart(_)
	local v3 = {
		Hit = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local clone = utils.Nanami.CleavingWhirlwind.Hit:Clone()
			clone.Parent = humanoidRootPart2
			clone.WorldCFrame = CFrame.lookAt(
				humanoidRootPart2.Position,
				(Vector3.new(humanoidRootPart.Position.X, humanoidRootPart2.Position.Y, humanoidRootPart.Position.Z))
			)

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			Debris:AddItem(clone, 1)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.MediumHit)
			end

			if p then
				for _ = 1, 10 do
					BloodyZee:Blood(
						CFrame.lookAt(humanoidRootPart2.Position, humanoidRootPart.Position) * CFrame.Angles(
							0,
							3.141592653589793,
							0
						),
						math.random(20, 100),
						25,
						25
					)
				end
			end

			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(
				p and sounds.Nanami.CleavingWhirlwind.RatioHit or sounds.Nanami.CleavingWhirlwind.Hit,
				humanoidRootPart,
				game.SoundService.Effect
			)
		end,
		Start = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v4 = v2:PlaySound(sounds.Nanami.CleavingWhirlwind.Start, humanoidRootPart, game.SoundService.Effect)
			instance2.AncestryChanged:Once(function()
				v4:Destroy()
			end)
		end,
		CleaverEmit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Nanami.CleavingWhirlwind.VFX:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			Debris:AddItem(clone, 1.5)
			local nanamiCleaver = instance.SetAssets:FindFirstChild("NanamiCleaver")

			if nanamiCleaver then
				for _, emitter in pairs(nanamiCleaver:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				task.delay(0.65, function()
					if not (instance2 or instance2.Parent) then
						return
					end

					for _, emitter in pairs(nanamiCleaver:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)
			end

			if not instance2 then
				return
			end

			instance2.AncestryChanged:Once(function()
				for _, emitter in pairs(nanamiCleaver:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
		end,
		Slash = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Nanami.CleavingWhirlwind.SlashEmit:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			Debris:AddItem(clone, 1.5)
			local clone2 = utils.Nanami.CleavingWhirlwind.SlashBeam:Clone()
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
				local v4 = beam
				task.delay(0.29000000000000004, function()
					v4.Enabled = false
					v4.Width0 = 17
					v4.Width1 = 17
				end)
			end
		end,
		Swing = function(instance, value)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local nanamiCleaver = instance.SetAssets:FindFirstChild("NanamiCleaver")

			if not nanamiCleaver then
				return
			end

			local clone = utils.Nanami.CombatTrail:Clone()
			clone.Weld.Part0 = nanamiCleaver.Blade
			clone.Parent = workspace.Effects
			task.wait(value or 0.3)
			clone.Trail.Enabled = false
			TweenService:Create(clone, TweenInfo.new(0.1), {
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 0.2)
		end,
		Whoosh = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Todo.Swing:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(1.3)
			Debris:AddItem(model, 0.2)
			clone.Weld.C0 = clone.Weld.C0 * CFrame.new(0, -1, -0.5) * CFrame.Angles(0, 0, 0.17453292519943295) * CFrame.Angles(
				0,
				0,
				0.8726646259971648
			)
			clone.Weld.Part0 = humanoidRootPart
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.6)
			clone.Core.Wind:Emit(10)
			TweenService:Create(clone.Weld, TweenInfo.new(0.2), {
				C1 = clone.Weld.C1 * CFrame.Angles(0.08726646259971647, -3.141592653589793, 0)
			}):Play()
			TweenService:Create(clone.Beam, TweenInfo.new(0.2), {
				Width0 = 0
			}):Play()
		end,
		Dash = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local model = Instance.new("Model")
			local clone = replicatedStorage.Utils.Itadori.RushWind:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1, 0)
			clone.Parent = model
			model.Parent = workspace.Effects
			model:ScaleTo(0.6)
			clone.Ring:Emit(7)
			clone.Dash1.Dash:Emit(1)
			clone.Dash2.Dash:Emit(1)
			Debris:AddItem(model, 2)
			local clone2 = utils.Itadori.Shock:Clone()
			clone2.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.2), {
				Size = createVector(8, 0, 8),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone2, 0.2)
			task.delay(0.05, function()
				local clone3 = utils.Itadori.Shock:Clone()
				clone3.CFrame = (humanoidRootPart.CFrame - humanoidRootPart.CFrame.Position + humanoidRootPart.Position) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
				clone3.Parent = workspace.Effects
				TweenService:Create(clone3, TweenInfo.new(0.2), {
					Size = createVector(8, 0, 8),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone3, 0.2)
			end)
		end,
		Finisher = function(instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			v2:Bleed(instance)
		end
	}
	v.Effects:Connect(function(p, ...)
		local v4 = v3[p]

		if not v4 then
			return
		end

		v4(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("CleavingWhirlService")
	v2 = Knit.GetController("FXController")
end

return controller