local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local random = Random.new()
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }
local controller = Knit.CreateController({
	Name = "MeiMeiController"
})

function controller.KnitStart(_)
	local v5 = {
		Hit = function(instance, instance2, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			if p2 ~= nil then
				p = p2
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.MeiMei.M1:FindFirstChild("Hit" .. p), humanoidRootPart2, game.SoundService.Effect)
			local clone = utils.MeiMei.SlashHit:Clone()
			clone.CFrame = CFrame.lookAlong(humanoidRootPart2.Position, humanoidRootPart.CFrame.LookVector)
			local v6 = {
				CFrame.Angles(0, 0, -0.17453292519943295),
				CFrame.Angles(0, 0, 0.7853981633974483),
				CFrame.Angles(0, 0, -1.0471975511965976),
				(CFrame.Angles(0, 0, 0.7853981633974483))
			}

			if p2 then
				clone.CFrame *= CFrame.Angles(0, 0, 1.5707963267948966)
			elseif v6[p] then
				clone.CFrame *= v6[p]
			end

			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.5)
			v3:PlayParticles(clone)
		end,
		ChaseHit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			local playSound = v3:PlaySound(
				sounds.MeiMei.M1:FindFirstChild("Hit3"),
				humanoidRootPart2,
				game.SoundService.Effect
			)
			playSound.PlaybackSpeed = 0.9
			local clone = utils.Yuta.SlashHit:Clone()
			clone.CFrame = CFrame.lookAlong(humanoidRootPart2.Position, humanoidRootPart.CFrame.LookVector) * CFrame.Angles(
				0,
				0,
				-0.17453292519943295
			)
			clone.Slash.Size = NumberSequence.new(3, 0)
			clone.Slash.Lifetime = NumberRange.new(0.2)
			clone.Slash.Color = ColorSequence.new(Color3.fromRGB(34, 48, 56))
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.5)
			clone.Slash:Emit(5)
		end,
		AerialHit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart2, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			local cframe = CFrame.new(humanoidRootPart.Position, humanoidRootPart2.Position - createVector(0, 4, 0))
			local clone = utils.Gojo.HardHit:Clone()
			clone.CFrame = cframe + cframe.LookVector * 4
			clone.Parent = workspace.Effects
			clone.Dust:Emit(5)
			clone.Ring:Emit(5)
			clone.Sparks:Emit(10)
			Debris:AddItem(clone, 0.5)
		end,
		Chase = function(p)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 1, -4)
			clone.Size = createVector(0, 0, 2)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(9, 9, 0),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 0.3)
			v3:PlaySound(sounds.Misc.Chase, humanoidRootPart, game.SoundService.Effect)
			v3:DustTrail(p, 0.4, CFrame.Angles(0, -1.5707963267948966, 0))
		end,
		Swing = function(instance, value, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v6 = p ~= "Up" and p ~= "Down" and (value or 2) or p
			v3:PlaySound(sounds.MeiMei.M1:FindFirstChild("Swing" .. v6), humanoidRootPart, game.SoundService.Effect)
		end,
		Swing2 = function(p, p2, p3)
			local meiMeiAxe = p.SetAssets:FindFirstChild("MeiMeiAxe")

			if not meiMeiAxe then
				return
			end

			local clone = utils.MeiMei.CombatTrail:Clone()
			clone.Weld.Part0 = meiMeiAxe.Axe
			clone.Parent = workspace.Effects
			task.wait(p2 == 4 and p3 == nil and 0.75 or 0.35)
			clone.Trail.Enabled = false
			TweenService:Create(clone, TweenInfo.new(0.1), {
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 0.2)
		end,
		Launch = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone.Size = createVector(0, 0, 5)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(8, 8, 0),
				Transparency = 1,
				Position = clone.Position + Vector3.new(0, p, 0)
			}):Play()
			Debris:AddItem(clone, 0.3)

			if p < 0 then
				v3:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, humanoidRootPart, game.SoundService.Effect)
				v3:DustBreak(humanoidRootPart.Position + createVector(0, 2, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)

				if localPlayer:DistanceFromCharacter(humanoidRootPart.Position) < 20 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				end
			end
		end,
		Flock = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.MeiMei.Flock, humanoidRootPart, game.SoundService.Effect)
		end,
		FlockHit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and instance2:FindFirstChild("HumanoidRootPart")) then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hiromi.Grapple.Hit, humanoidRootPart, game.SoundService.Effect)
		end,
		Jump = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Gojo.InfiniteVoid.Hits.Hit3, humanoidRootPart, game.SoundService.Effect)
		end,
		Crowstep = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.MeiMei.Crow:Clone()
			clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -3.5 * instance:GetScale(), 0))
			clone.Parent = workspace.Effects
			clone.HumanoidRootPart.Anchored = false
			clone.HumanoidRootPart.AssemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
			local clone2 = utils.Damage.CrowExplode:Clone()
			clone2.Parent = workspace.Effects
			clone2.Position = clone.PrimaryPart.Position
			Debris:AddItem(clone2, 4)

			for _, emitter in clone2:GetDescendants() do
				if emitter:IsA("ParticleEmitter") and emitter.Name ~= "Sparks" then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end,
		UltimateStart = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.MeiMei.UltStart, humanoidRootPart, game.SoundService.Effect)
		end,
		CrowUltimate = function(instance, instance2, object)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			if instance == localPlayer.Character then
				workspace.CurrentCamera.CameraSubject = instance2.PrimaryPart
				localPlayer.CameraMinZoomDistance = 5

				while instance2 and instance2.Parent and instance2:GetAttribute("InControl") do
					task.wait()
					object:FireServer(workspace.CurrentCamera.CFrame.Position + workspace.CurrentCamera.CFrame.LookVector * 100)
				end

				if not instance2 and instance2:GetAttribute("InControl") then
					task.wait(1)
				end

				workspace.CurrentCamera.CameraSubject = localPlayer.Character:WaitForChild("Humanoid")
				localPlayer.CameraMinZoomDistance = game.StarterPlayer.CameraMinZoomDistance
			end
		end,
		CrowControl = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local clone = replicatedStorage.Utils.MeiMei.CrowControl:Clone()
			clone.Parent = instance2.PrimaryPart
			clone.Ring:Emit(5)
			clone.Star:Emit(1)
			Debris:AddItem(clone, 0.8)
		end,
		CrowStart = function(_, instance)
			local playSound = v3:PlaySound(sounds.Misc.CrowMad2, instance.PrimaryPart, game.SoundService.Effect)
			playSound.Volume = 0.9
			task.wait(0.1)

			for _ = 1, 2 do
				v3:PlaySound(sounds.MeiMei.WingFlap, instance.PrimaryPart, game.SoundService.Effect)
				task.wait(0.1)
			end
		end,
		CrowHit = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if p then
				v3:PlaySound(sounds.MeiMei.BirdoStrike, humanoidRootPart, game.SoundService.Voice)
				v3:PlaySound(sounds.MeiMei.CrowHit, instance2.PrimaryPart, game.SoundService.Effect)
				task.spawn(function()
					for _ = 1, 5 do
						local v6 = math.random(250, 400) / 10
						local clone = utils.Gojo.LapseBlue.Throw:Clone()
						clone.Transparency = 0.7
						clone.Position = typeof(p) == "CFrame" and p.Position or p.HumanoidRootPart.Position
						clone.Orientation = Vector3.new(
							math.random(-180, 180),
							math.random(-180, 180),
							math.random(-180, 180)
						)
						clone.Size = createVector(0, 0, 7)
						clone.Parent = workspace.Effects
						TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
							Size = Vector3.new(v6, v6, 0),
							Transparency = 1
						}):Play()
						Debris:AddItem(clone, 0.2)
						task.wait()
					end
				end)
				task.delay(0.3, function()
					local clone = utils.Gojo.LapseBlue.LapseBlue.Grab:Clone()
					clone.Weld:Destroy()
					clone.Anchored = true
					clone.Position = typeof(p) == "CFrame" and p.Position or p.HumanoidRootPart.Position
					clone.Size = createVector(50, 50, 50)
					clone.Parent = workspace.Effects
					local highlight = Instance.new("Highlight", clone)
					highlight.FillTransparency = 1
					highlight.OutlineTransparency = 1
					TweenService:Create(
						clone,
						TweenInfo.new(0.226, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
						{
							Size = createVector(0, 0, 0),
							Transparency = 50
						}
					):Play()
					Debris:AddItem(clone, 0.5)
				end)
				local clone = replicatedStorage.Utils.MeiMei.BirdStrikeHit1:Clone()
				clone.CFrame = instance2.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2) * CFrame.Angles(
					0,
					3.141592653589793,
					(math.rad((random:NextNumber(-180, 180))))
				)

				for _, beam in clone:GetDescendants() do
					if beam:IsA("Beam") then
						beam.TextureSpeed = 10
						beam.TextureLength = 1
						beam.Width1 = 25
						beam.Width0 = 2
						TweenService:Create(beam, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
							TextureSpeed = 0,
							TextureLength = 0.5,
							Width1 = 0,
							Width0 = 0
						}):Play()
						beam.Parent.CFrame *= CFrame.new(0, 0, 12)
						TweenService:Create(
							beam.Parent,
							TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								CFrame = beam.Parent.CFrame * CFrame.new(0, 0, -12)
							}
						):Play()
					elseif beam.Parent.Name == "Particles" then
						beam.Enabled = true
					end

					clone.Parent = workspace.Effects
					Debris:AddItem(clone, 0.5)
				end

				v3:PlayParticles(clone)
			end

			if localPlayer.Character == instance or localPlayer.Character == p or (workspace.CurrentCamera.CFrame.Position - (typeof(p) == "CFrame" and p.Position or p.HumanoidRootPart.Position)).Magnitude < 90 then
				CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit):StartFadeOut(0.5)
			end
		end,
		CrowSmash = function(instance, p, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			if instance2 then
				task.spawn(function()
					for _ = 1, 5 do
						local v6 = math.random(350, 500) / 10
						local clone = utils.Gojo.LapseBlue.Throw:Clone()
						clone.Transparency = 0.7
						clone.Position = typeof(instance2) == "CFrame" and instance2.Position or instance2.HumanoidRootPart.Position
						clone.Orientation = Vector3.new(
							math.random(-180, 180),
							math.random(-180, 180),
							math.random(-180, 180)
						)
						clone.Size = createVector(0, 0, 7)
						clone.Parent = workspace.Effects
						TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
							Size = Vector3.new(v6, v6, 0),
							Transparency = 1
						}):Play()
						Debris:AddItem(clone, 0.2)
						task.wait()
					end
				end)
				local clone = replicatedStorage.Utils.MeiMei.BirdStrikeHit2:Clone()
				clone.CFrame = p.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2) * CFrame.Angles(
					0,
					3.141592653589793,
					(math.rad((random:NextNumber(-180, 180))))
				)
				v3:PlayParticles(clone)
				clone.Parent = workspace.Effects
				TweenService:Create(
					clone.PointLight,
					TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Brightness = 0
					}
				):Play()
				Debris:AddItem(clone, 2)
				v3:PlaySound(sounds.MeiMei.CrowSmash, instance2.PrimaryPart, game.SoundService.Effect)
			end

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
			end
		end,
		CrowBoom = function(instance, _, position)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local clone = replicatedStorage.Utils.MeiMei.BirdStrikeAOE:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			v3:PlayParticles(clone)
			TweenService:Create(clone.PointLight, TweenInfo.new(0.75), {
				Brightness = 0
			}):Play()
			Debris:AddItem(clone, 3)
			v3:PlaySound(sounds.MeiMei.CrowExplode, clone, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 90 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		TeleportStart = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.MeiMei.Teleport, humanoidRootPart, game.SoundService.Effect)
		end,
		Teleport = function(instance, cFrame, cFrame2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local raycastResult = workspace:Raycast(cFrame.Position, createVector(-0, -7.5, -0), raycastParams)
			local raycastResult2 = workspace:Raycast(cFrame2.Position, createVector(-0, -7.5, -0), raycastParams)
			local clone = utils.Naoya.Teleport:Clone()
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			clone.Lines.Color = ColorSequence.new(Color3.new(1, 1, 1))
			clone.Lines:Emit(8)

			if raycastResult then
				clone.Floor.Dust:Emit(30)
			end

			Debris:AddItem(clone, 1)
			local clone2 = utils.Naoya.Teleport:Clone()
			clone2.CFrame = cFrame2
			clone2.Parent = workspace.Effects
			clone2.Lines.Color = ColorSequence.new(Color3.new(1, 1, 1))
			clone2.Lines:Emit(8)

			if raycastResult2 then
				clone2.Floor.Dust:Emit(30)
			end

			Debris:AddItem(clone2, 1)
		end
	}
	v.Effects:Connect(function(p, ...)
		local v6 = v5[p]

		if not v6 then
			return
		end

		v6(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("MeiMeiService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
	v4 = Knit.GetController("ToolController")
end

return controller