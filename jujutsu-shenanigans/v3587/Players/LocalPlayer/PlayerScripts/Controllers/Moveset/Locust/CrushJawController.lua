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
	Name = "CrusshJawController"
})

function controller.KnitStart(_)
	local v3 = {
		Crush = function(p, position)
			local clone = utils.Itadori.CrushingBlow:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			TweenService:Create(clone.Air, TweenInfo.new(0.2), {
				Position = createVector(0, 0, 0)
			}):Play()
			TweenService:Create(clone.PointLight, TweenInfo.new(0.6), {
				Brightness = 0
			}):Play()
			clone.Flames:Emit(20)
			clone.Floor.Glow:Emit(1)
			clone.Floor.Ring:Emit(10)
			clone.Floor.Sparks:Emit(10)
			clone.Floor.Wind2:Emit(8)
			Debris:AddItem(clone, 1.5)
			v2:PlaySound(sounds.Itadori.CrushingBlow.GroundImpact, clone, game.SoundService.Effect)

			if localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Chomp = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Locust.Chomp["Bite" .. p], humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Bite = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.fromRGB(255, 255, 255))
			v2:PlaySound(sounds.Locust.Chomp.Hit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.CrushingBlow.Hit1, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Itadori.CrushingBlow.Hit2, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Dash = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Locust.MucusFire:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -5)
			clone.Parent = workspace.Effects
			clone.Wind:Emit(20)
			clone.Back1.Back:Emit(1)
			clone.Back2.Back:Emit(1)
			TweenService:Create(clone.Back1, TweenInfo.new(2), {
				CFrame = clone.Back1.CFrame - clone.Back1.CFrame.LookVector * 10
			}):Play()
			TweenService:Create(clone.Back2, TweenInfo.new(2), {
				CFrame = clone.Back2.CFrame - clone.Back2.CFrame.LookVector * 10
			}):Play()
			Debris:AddItem(clone, 2)
			v2:PlaySound(sounds.Locust.Chomp.Dash, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end

			for _ = 1, 5 do
				local clone2 = utils.Mahito.BodyRepel["Wind" .. math.random(1, 5)]:Clone()
				clone2.CFrame = humanoidRootPart.CFrame * CFrame.Angles(
					1.5707963267948966,
					math.rad((math.random(0, 360))),
					0
				)
				clone2.Transparency = 0.5
				clone2.Size = createVector(6, 6, 6)
				TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
					CFrame = clone2.CFrame + humanoidRootPart.CFrame.LookVector * 3,
					Size = createVector(7, 0, 7)
				}):Play()
				Debris:AddItem(clone2, 0.3)
				clone2.Parent = workspace.Effects
				TweenService:Create(clone2, TweenInfo.new(0.15), {
					Transparency = 0.5
				}):Play()
				task.delay(0.15, function()
					TweenService:Create(clone2, TweenInfo.new(0.15), {
						Transparency = 1
					}):Play()
				end)
				task.wait(0.06)
			end
		end,
		Leap = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Locust.Chomp.Throw, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Locust.Chomp.Slam, humanoidRootPart, game.SoundService.Effect)
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
	v = Knit.GetService("CrushJawService")
	v2 = Knit.GetController("FXController")
end

return controller