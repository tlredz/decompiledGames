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
require(replicatedStorage.Modules.CameraShaker)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "CleverController"
})

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Locust.FourArmed, humanoidRootPart, game.SoundService.Effect)
		end,
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
						part:Destroy()
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
		Hit2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit4"), humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart, game.SoundService.Effect)
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
	v = Knit.GetService("CleverService")
	v2 = Knit.GetController("FXController")
end

return controller