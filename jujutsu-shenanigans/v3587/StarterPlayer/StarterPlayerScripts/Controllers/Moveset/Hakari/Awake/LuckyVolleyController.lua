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
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "LuckyVolleyController"
})

function controller.KnitStart(_)
	local v3 = {
		Barrage = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local shirt = instance:FindFirstChildWhichIsA("Shirt")
			local color = instance["Left Arm"].Color
			local color2 = instance["Right Arm"].Color
			local count = 0

			repeat
				local clone = utils.Hakari.Barrage:Clone()

				if shirt then
					local clone_2 = shirt:Clone()
					clone_2.Parent = clone
				end

				clone["Left Arm"].Color = color
				clone["Right Arm"].Color = color2

				for _, part in clone:GetChildren() do
					if not part:IsA("BasePart") then
						continue
					end

					if part.Name == "ColorArm" then
						part.CFrame = humanoidRootPart.CFrame * CFrame.new(
							math.random(-50, 50) / 10,
							math.random(-50, 50) / 10,
							math.random(-20, 20) / 10
						) * CFrame.Angles(1.5707963267948966, 0, 0)
						TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Transparency = 1,
							CFrame = part.CFrame + humanoidRootPart.CFrame.LookVector * 16
						}):Play()
						part.Attachment.Flames:Emit(7)
						part.Attachment.Wind:Emit(2)
					else
						part.CFrame = humanoidRootPart.CFrame * CFrame.new(
							math.random(-25, 25) / 10,
							math.random(-10, 10) / 10,
							math.random(-10, 10) / 10
						) * CFrame.Angles(
							math.rad((math.random(70, 110))),
							math.rad((math.random(-20, 20))),
							(math.rad((math.random(-20, 20))))
						)
						TweenService:Create(part, TweenInfo.new(0.1), {
							CFrame = part.CFrame + humanoidRootPart.CFrame.LookVector * 7
						}):Play()
						TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Transparency = 1
						}):Play()
						local clone2 = utils.Gojo.LapseBlue.Throw:Clone()
						clone2.CFrame = humanoidRootPart.CFrame - humanoidRootPart.Position + part.Position + humanoidRootPart.CFrame.LookVector * 8
						clone2.Size = createVector(0, 0, 1)
						clone2.Parent = clone
						TweenService:Create(clone2, TweenInfo.new(0.15), {
							Size = createVector(4, 4, 0),
							Transparency = 1
						}):Play()
						Debris:AddItem(clone2, 0.15)
					end
				end

				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 0.6)
				count += 1

				if count == 2 then
					v2:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
					count = 0
				end

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
				sounds.Gojo.M1:FindFirstChild("Hit" .. math.random(1, 3)),
				humanoidRootPart,
				game.SoundService.Effect
			)
		end,
		Hit2 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Hakari.EnergySurge.Hit2, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Hakari.RoughHit:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			TweenService:Create(clone.PointLight, TweenInfo.new(0.6), {
				Brightness = 0
			}):Play()
			clone.Glow:Emit(1)
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Hakari.RoughSwing:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1.1)
			TweenService:Create(
				clone.Weld,
				TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					C1 = clone.Weld.C1 * CFrame.Angles(0, 3.141592653589793, 0)
				}
			):Play()
			TweenService:Create(clone.Beam, TweenInfo.new(0.3), {
				Width0 = 0
			}):Play()
			v2:PlaySound(sounds.Hakari.Counter.Startup, humanoidRootPart, game.SoundService.Effect)
			task.wait(0.1)
			clone.Core.Flames.Enabled = false
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
	v = Knit.GetService("LuckyVolleyService")
	v2 = Knit.GetController("FXController")
end

return controller