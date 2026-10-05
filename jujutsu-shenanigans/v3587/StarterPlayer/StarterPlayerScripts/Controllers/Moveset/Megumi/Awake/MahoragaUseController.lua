local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local animations = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "MahoragaUseController"
})

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function controller.KnitStart(_)
	local v3 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			v2:PlaySound(sounds.Megumi.Rabbit.Start, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Megumi.Mahoraga.RitualStart:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(75, 75, 75),
				Transparency = 1
			}):Play()
			clone.Attachment.Ring:Emit(20)
			clone.Attachment.Dust:Emit(20)
			Debris:AddItem(clone, 2)
		end,
		Timer = function(instance, p, p2)
			v2:Flash(instance, Color3.fromRGB(255, 255, 255), 1.5)

			if localPlayer.Character ~= instance and localPlayer.Character ~= p then
				return
			end

			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:DomainMapFade(Color3.new(0, 0, 0), 0.1, 0.1)
			CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			v2:PlaySound(sounds.Megumi.Mahoraga.Ritual.Timer, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Heian.Chant.Chant:Clone()
			clone.Parent = instance.Head
			Debris:AddItem(clone, 1)
			TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				StudsOffset = createVector(2, 2, 2)
			}):Play()
			task.delay(0.5, function()
				TweenService:Create(clone.Chat, TweenInfo.new(0.5), {
					ImageTransparency = 1
				}):Play()
				TweenService:Create(clone.Chat.Sub, TweenInfo.new(0.5), {
					TextTransparency = 1
				}):Play()
			end)

			if p2 then
				clone.Chat.Sub.Text = "WITH THIS TREASURE"
			else
				clone.Chat.Sub.Text = "I SUMMON"
			end
		end,
		Goodbye = function(instance, instance2, cFrame)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			task.spawn(function()
				local clone = utils.Megumi.Mahoraga.Mahoraga:Clone()
				clone.Outfit.Head.Beard:Destroy()
				clone.Outfit.Head.Hat:Destroy()
				clone.Outfit.Head.Mouth.Decal.Transparency = 0
				clone.Outfit.Head.Mouth.Pumpkin:Destroy()
				clone.HumanoidRootPart.CFrame = CFrame.new(0, 1000000, 0)
				clone.Parent = workspace.Effects
				local track = clone.Humanoid:LoadAnimation(animations.Megumi.MahoragaSummon)
				track:Play(0, nil, 0)
				task.wait(3)
				clone.HumanoidRootPart.CFrame = cFrame - createVector(0, 8, 0)
				TweenService:Create(clone.HumanoidRootPart, TweenInfo.new(2, Enum.EasingStyle.Exponential), {
					CFrame = cFrame
				}):Play()
				track:AdjustSpeed(1)

				if localPlayer.Character == instance or localPlayer.Character == instance2 then
					task.delay(1.75, function()
						local v4 = v2:PlaySound(
							sounds.Itadori.MalevolantShrine.Music,
							humanoidRootPart,
							game.SoundService.Music
						)
						task.delay(8, function()
							if not v4.Parent then
								return
							end

							TweenService:Create(v4, TweenInfo.new(4), {
								Volume = 0
							}):Play()
							Debris:AddItem(v4, 4)
						end)
					end)
				else
					v2:PlaySound(sounds.Megumi.Mahoraga.Ritual.Spawn, clone.HumanoidRootPart, game.SoundService.Effect)
					task.delay(1, function()
						v2:PlaySound(
							sounds.Megumi.Mahoraga.Ritual.Moving,
							clone.HumanoidRootPart,
							game.SoundService.Effect
						)
					end)

					if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 70 then
						CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
					end
				end

				task.wait(4.8)
				clone:Destroy()
			end)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				v2:PlaySound(sounds.Megumi.Mahoraga.Ritual.Timer, humanoidRootPart, game.SoundService.Effect)
				v2:PlaySound(sounds.Megumi.Mahoraga.Ritual.Summon, workspace, game.SoundService.Effect)
				local clone = utils.Megumi.Mahoraga.Ritual:Clone()
				clone.Viewport.CurrentCamera = workspace.CurrentCamera
				clone.Parent = localPlayer.PlayerGui
				local v4 = {}
				v2:WorldModelChar(instance, clone.Viewport)
				v2:WorldModelChar(instance2, clone.Viewport)
				local steppedConnection = nil
				steppedConnection = RunService.Stepped:Connect(function()
					if instance.Parent and instance2.Parent then
						for k, v5 in v4 do
							k.CFrame = CFrame.new(v5[2].Position + v5[1], v5[2].Position)
						end
					else
						steppedConnection:Disconnect()
						TweenService:Create(clone.Viewport, TweenInfo.new(1), {
							BackgroundTransparency = 1,
							ImageTransparency = 1
						}):Play()
						Debris:AddItem(clone, 1)
					end
				end)
				local cframe = CFrame.new(
					humanoidRootPart.Position,
					(Vector3.new(
						humanoidRootPart2.Position.X,
						humanoidRootPart.Position.Y,
						humanoidRootPart2.Position.Z
					))
				)
				local tweenInfo = TweenInfo.new(0.25)
				local clone2 = utils.Megumi.Mahoraga.Mahoraga:Clone()
				clone2.Outfit.Head.Beard:Destroy()
				clone2.Outfit.Head.Hat:Destroy()
				clone2.Outfit.Head.Mouth.Decal.Transparency = 0
				clone2.Outfit.Head.Mouth.Pumpkin:Destroy()
				clone2.HumanoidRootPart.CFrame = CFrame.new(0, 1000000, 0)
				clone2.Humanoid.DisplayName = instance.Humanoid.DisplayName or instance.Name
				clone2.Parent = clone.Viewport.Mahoraga
				local track = clone2.Humanoid:LoadAnimation(animations.Megumi.MahoragaSummon)
				track:Play(0, nil, 0)
				local total = 10

				for i = 1, 6 do
					for i2 = 1, 2 do
						local clone3 = clone.Toad:Clone()
						clone3.Parent = clone.Viewport
						clone3.CFrame = cframe * CFrame.Angles(0, math.rad(i2 == 1 and 45 or -45), 0) + cframe.LookVector * ((i - 1) * 10) + cframe.RightVector * (i2 == 1 and total or -total)
						local clone4 = clone.Wolf:Clone()
						clone4.Parent = clone.Viewport
						local v5 = total + (50 - total) * 0.15 + 2
						clone4.CFrame = cframe * CFrame.Angles(0, math.rad(i2 == 1 and -135 or 135), 0) + cframe.LookVector * ((i - 1) * 10 + 5) + cframe.RightVector * (i2 == 1 and v5 or -v5) + cframe.UpVector
						task.delay(i * 0.25 + 0.35, function()
							if not clone3.Parent then
								return
							end

							TweenService:Create(clone3, tweenInfo, {
								Transparency = 0
							}):Play()

							for i3, child in clone3:GetChildren() do
								TweenService:Create(child, tweenInfo, {
									Transparency = 0
								}):Play()
							end

							task.wait(0.125)

							if not clone4.Parent then
								return
							end

							TweenService:Create(clone4, tweenInfo, {
								Transparency = 0
							}):Play()

							for i3, child in clone4:GetChildren() do
								TweenService:Create(child, tweenInfo, {
									Transparency = 0
								}):Play()
							end
						end)
					end

					total += (50 - total) * 0.3
				end

				TweenService:Create(clone.Viewport, TweenInfo.new(0.6), {
					BackgroundTransparency = 0,
					ImageTransparency = 0
				}):Play()
				task.delay(3, function()
					for _, child in clone.Viewport:GetChildren() do
						if child.Name == "Toad" or child.Name == "Wolf" then
							child:Destroy()
						end
					end

					clone2.HumanoidRootPart.CFrame = cFrame
					track:AdjustSpeed(1)
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
					v2:PlaySound(sounds.Megumi.Mahoraga.Ritual.Spawn, workspace, game.SoundService.Effect)
					task.delay(1, function()
						v2:PlaySound(sounds.Megumi.Mahoraga.Ritual.Moving, workspace, game.SoundService.Effect)
					end)
					clone.Viewport.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					clone.Viewport.Ambient = Color3.fromRGB(0, 0, 0)
					clone.Viewport.LightColor = Color3.fromRGB(255, 255, 255)
					TweenService:Create(clone.Viewport, TweenInfo.new(0.3), {
						BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					}):Play()
					local v5 = {
						clone2.Torso,
						clone2.Head,
						clone2["Left Arm"],
						clone2["Right Arm"]
					}
					local random = Random.new()

					for i = 1, 20 do
						local v6 = v5[math.random(1, #v5)]
						local v7 = random:NextUnitVector() * 60
						local clone3 = utils.Megumi.Mahoraga.String:Clone()
						clone3.CFrame = CFrame.new(v6.Position + v7, v6.Position)
						clone3.Parent = clone.Viewport.Mahoraga
						v4[clone3] = { v7, v6 }
						task.delay(i < 5 and 2 or i < 10 and 3 or 3.55, function()
							v4[clone3] = nil
							TweenService:Create(
								clone3,
								TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									CFrame = CFrame.new(
										v6.Position + v7,
										v6.Position + Vector3.new(
											math.random(-40, 40),
											math.random(-40, 40),
											math.random(-40, 40)
										)
									),
									Transparency = 1
								}
							):Play()
							Debris:AddItem(clone3, 1)
						end)
					end

					task.wait(3.8)
					TweenService:Create(clone.Viewport, TweenInfo.new(1), {
						BackgroundTransparency = 1,
						ImageTransparency = 1
					}):Play()
					Debris:AddItem(clone, 1)
					steppedConnection:Disconnect()
				end)
			end
		end,
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Megumi.Mahoraga.Ritual.Hit, workspace, game.SoundService.Effect)

			if localPlayer.Character == instance then
				if _G.Settings.Flash == true then
					local clone = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
					clone.Parent = game.Lighting
					clone.TintColor = Color3.new(1, 1, 1)
					task.wait(0.04)
					clone.Brightness = 200
					clone.Contrast = -1000
					task.wait(0.04)
					clone:Destroy()
				end

				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			elseif (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 70 or localPlayer.Character == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
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
	v = Knit.GetService("MahoragaUseService")
	v2 = Knit.GetController("FXController")
end

return controller