local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
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
	Name = "BloodRainController"
})

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Choso.BloodRain.Start, humanoidRootPart, game.SoundService.Effect)
			v2:DomainBurst(humanoidRootPart)
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Itadori.Dismantle.Slash, humanoidRootPart, game.SoundService.Effect)
		end,
		Rain = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Choso.BloodRain:Clone()
			local position = clone.End.Position
			clone.End.Position = clone.Start.Position
			clone.Parent = workspace.Effects
			clone.Start.Sparks:Emit(60)
			clone.Start.Flash:Emit(20)
			TweenService:Create(clone.Beam, TweenInfo.new(0.3), {
				Width1 = 100
			}):Play()
			TweenService:Create(clone.End, TweenInfo.new(0.3), {
				Position = position
			}):Play()
			local count = 0
			local tweenInfo = TweenInfo.new(0.1)
			local v4 = nil
			local v5 = v2:PlaySound(sounds.Choso.BloodRain.Loop, clone, game.SoundService.Effect, true)
			local colorCorrectionEffect

			if localPlayer.Character == instance then
				colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
			else
				colorCorrectionEffect = nil
			end

			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if p.Parent and instance.Parent then
					count += 1
					clone.CFrame = humanoidRootPart.CFrame - humanoidRootPart.Position + instance.Torso.Position
					local v6 = localPlayer:GetAttribute("Ultimate") / 100

					if colorCorrectionEffect then
						local v7 = colorCorrectionEffect
						local saturation = colorCorrectionEffect.Saturation
						v7.Saturation = saturation + (-(1 - v6) - saturation) * 0.1
					end

					clone.Start.Flow.Rate = 400 * v6
					local magnitude = (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude

					if magnitude < 120 and v4 == nil then
						v4 = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit)
					elseif magnitude >= 120 and v4 ~= nil then
						v4:StartFadeOut(0.5)
						v4 = nil
					end

					if magnitude < 300 and count % 2 == 0 then
						for _ = 1, 4 do
							local raycastResult = workspace:Raycast(
								clone.Rain.Position + Vector3.new(math.random(-35, 35), 0, math.random(-35, 35)),
								createVector(0, -100, 0),
								_G.MapParams
							)

							if not raycastResult then
								continue
							end

							local clone2 = utils.Choso.RainDrop:Clone()
							clone2.CFrame = CFrame.lookAlong(raycastResult.Position, raycastResult.Normal) * CFrame.Angles(
								1.5707963267948966,
								0,
								0
							) - Vector3.new(0, math.random(0, 25) / 10 - 50, 0)
							TweenService:Create(clone2, tweenInfo, {
								CFrame = clone2.CFrame - createVector(0, 50, 0)
							}):Play()
							clone2.Parent = workspace.Effects
							Debris:AddItem(clone2, 0.75)
						end
					end
				else
					steppedConnection:Disconnect()
					task.spawn(function()
						Debris:AddItem(clone, 1)
						clone.Rain.Rain.Enabled = false
						clone.Start.Flow.Enabled = false
						TweenService:Create(clone.Beam, TweenInfo.new(0.3), {
							Width0 = 0,
							Width1 = 0
						}):Play()

						if colorCorrectionEffect then
							Debris:AddItem(colorCorrectionEffect, 0.5)
							TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.5), {
								Saturation = 0
							}):Play()
						end

						if v4 ~= nil then
							v4:StartFadeOut(0.5)
						end

						v2:PlaySound(sounds.Choso.BloodRain.End, humanoidRootPart, game.SoundService.Effect)

						if v5 then
							TweenService:Create(v5, TweenInfo.new(0.4), {
								Volume = 0
							}):Play()
						end
					end)
				end
			end)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 120 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
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
	v = Knit.GetService("BloodRainService")
	v2 = Knit.GetController("FXController")
end

return controller