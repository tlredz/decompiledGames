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
local BloodyZee = require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "DespairController"
})

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Charles.Despair.Startup, humanoidRootPart, game.SoundService.Effect)
		end,
		Spin = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Charles.Despair.Spin, humanoidRootPart, game.SoundService.Effect)
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Charles.Despair.Swing, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Choso.CounterSwing:Clone()
			clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(1, 0, -4) * CFrame.Angles(0, 0.2617993877991494, 0))
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.3)
			TweenService:Create(clone.Shock, TweenInfo.new(0.15), {
				Size = createVector(0, 25, 0),
				Transparency = 1
			}):Play()
			TweenService:Create(clone.Shock2, TweenInfo.new(0.1), {
				Size = createVector(8, 0, 8),
				Transparency = 1,
				Position = clone.Shock2.Position + humanoidRootPart.CFrame.LookVector * 3
			}):Play()
			TweenService:Create(clone.Shockwave, TweenInfo.new(0.3), {
				Size = createVector(0, 30, 0),
				Transparency = 1,
				CFrame = clone.Shockwave.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
			}):Play()
		end,
		Swing2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Charles.Despair.Swing, humanoidRootPart, game.SoundService.Effect)
			local model = Instance.new("Model")
			local clone = utils.Todo.Swing:Clone()
			clone.Weld.C0 = clone.Weld.C0 * CFrame.Angles(0, 0, 1.7453292519943295)
			clone.Weld.Part0 = humanoidRootPart
			clone.Parent = model
			model.Parent = workspace.Effects
			model:ScaleTo(1.4)
			clone.Parent = workspace.Effects
			model:Destroy()
			Debris:AddItem(clone, 0.6)
			clone.Core.Wind:Emit(12)
			TweenService:Create(clone.Weld, TweenInfo.new(0.4), {
				C1 = clone.Weld.C1 * CFrame.Angles(0, -3.141592653589793, 0)
			}):Play()
			TweenService:Create(clone.Beam, TweenInfo.new(0.4), {
				Width0 = 0
			}):Play()
		end,
		Barrage = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local shirt = instance:FindFirstChildWhichIsA("Shirt")
			local color = instance["Left Arm"].Color
			local _ = instance["Right Arm"].Color

			repeat
				local clone = utils.Charles.Barrage:Clone()

				if shirt then
					local clone_2 = shirt:Clone()
					clone_2.Parent = clone
				end

				clone["Left Arm"].Color = color

				for _, part in clone:GetChildren() do
					if not part:IsA("BasePart") then
						continue
					end

					part.CFrame = humanoidRootPart.CFrame * CFrame.new(
						math.random(-20, -10) / 10,
						math.random(-10, 10) / 10,
						math.random(30, 50) / 10
					) * CFrame.Angles(
						math.rad((math.random(70, 110))),
						math.rad((math.random(0, 40))),
						(math.rad((math.random(-20, 20))))
					)
					TweenService:Create(part, TweenInfo.new(0.1), {
						CFrame = part.CFrame + humanoidRootPart.CFrame.LookVector * 7
					}):Play()
					TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
						Transparency = 1
					}):Play()
					TweenService:Create(
						part.GWarstaff,
						TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							Transparency = 1
						}
					):Play()
					local clone2 = utils.Gojo.LapseBlue.Throw:Clone()
					clone2.CFrame = humanoidRootPart.CFrame - humanoidRootPart.Position + part.Position + humanoidRootPart.CFrame.LookVector * 11
					clone2.Size = createVector(0, 0, 1)
					clone2.Parent = clone
					TweenService:Create(clone2, TweenInfo.new(0.15), {
						Size = createVector(4, 4, 0),
						Transparency = 1
					}):Play()
					Debris:AddItem(clone2, 0.15)
				end

				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 0.6)
				task.wait(0.025)
			until not p.Parent
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(
				sounds.Charles.Despair:FindFirstChild("Hit" .. math.random(1, 3)),
				humanoidRootPart,
				game.SoundService.Effect
			)
		end,
		Hit2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Charles.Despair.Hit3, humanoidRootPart, game.SoundService.Effect)
		end,
		Die = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Hiromi.Verdict.Hit2, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Locust.Slam:Clone()
			clone.Position = instance.Torso.Position
			clone.Parent = workspace.Effects

			for _, child in clone.Attachment:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			Debris:AddItem(clone, 0.5)

			for _ = 1, 20 do
				BloodyZee:Blood(instance.Head.CFrame, math.random(5, 150), 45, 45)
			end

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 100 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
			end
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
	v = Knit.GetService("DespairService")
	v2 = Knit.GetController("FXController")
end

return controller