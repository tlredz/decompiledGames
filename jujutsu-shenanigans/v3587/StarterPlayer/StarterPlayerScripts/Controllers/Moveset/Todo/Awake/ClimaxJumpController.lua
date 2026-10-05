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
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "ClimaxJumpController"
})

function controller.KnitStart(_)
	local v4 = {
		Grab = function(instance, instance2)
			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 1))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)
			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hakari.EnergySurge.Hit1, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end

			if localPlayer.Character == instance and instance:GetAttribute("InUlt") then
				local clone2 = utils.Todo.Jump.Flash:Clone()
				local camera = Instance.new("Camera", clone2.Main)
				clone2.Main.CurrentCamera = camera
				clone2.Parent = localPlayer.PlayerGui
				TweenService:Create(clone2.Fade, TweenInfo.new(0.2), {
					BackgroundTransparency = 1
				}):Play()
				local cframe = CFrame.new(2000, 0, 0)
				local clone3 = utils.DomainWarn.Panel.Viewport.Display:Clone()
				clone3["Left Arm"].FingersL:Destroy()
				clone3["Right Arm"].FingersR:Destroy()
				clone3.HumanoidRootPart.CFrame = cframe
				clone3.Parent = clone2.Main
				pcall(function()
					v3:ApplyCopyOutfit(instance, clone3)
				end)
				clone3.Humanoid:LoadAnimation(clone2.User):Play(0)
				local clone4 = utils.Todo.Awakening.Takada:Clone()
				clone4.Parent = clone2.Main
				clone4.HumanoidRootPart.CFrame = clone3.HumanoidRootPart.CFrame
				clone4.Humanoid:LoadAnimation(clone2.Takada):Play(0)
				local clone5 = utils.DomainWarn.Panel.Viewport.Display:Clone()
				clone5["Left Arm"].FingersL:Destroy()
				clone5["Right Arm"].FingersR:Destroy()
				clone5.HumanoidRootPart.CFrame = clone3.HumanoidRootPart.CFrame * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(
					0,
					0,
					5
				)
				clone5.Parent = clone2.Main
				pcall(function()
					v3:ApplyCopyOutfit(instance2, clone5)
				end)
				clone5.Humanoid:LoadAnimation(clone2.Target):Play(0)
				local cFrame = workspace.CurrentCamera.CFrame
				local total = 0
				local renderSteppedConnection = nil
				local cameraData = utils.Todo.Jump.CameraData
				renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
					local v5 = dt * 60
					total += v5
					local child = cameraData.Frames:FindFirstChild((tonumber((math.ceil(total)))))
					local child2 = cameraData.FOV:FindFirstChild((tonumber((math.ceil(total)))))

					if child and child2 and clone3.Parent then
						camera.CFrame = clone3.HumanoidRootPart.CFrame * child.Value
						camera.FieldOfView = child2.Value

						if total < 79 then
							workspace.CurrentCamera.CFrame = camera.CFrame
							workspace.CurrentCamera.FieldOfView = camera.FieldOfView
						end
					else
						renderSteppedConnection:Disconnect()
						workspace.CurrentCamera.FieldOfView = 70
						workspace.CurrentCamera.CFrame = cFrame
					end
				end)
				clone2.Main.Ambient = Color3.new(0.211765, 0.0509804, 0.0862745)
				clone2.Main.LightColor = Color3.new(0.956863, 0.807843, 1)
				clone2.Main.LightDirection = createVector(0, 1, -0.5)
				local clone6 = utils.Todo.Jump.Stage:Clone()
				clone6:PivotTo(CFrame.new(2000, 0, 0))
				TweenService:Create(clone6.BG, TweenInfo.new(1.3, Enum.EasingStyle.Linear), {
					CFrame = clone6.BG.CFrame * CFrame.new(3.12413936106985, 0, 0)
				}):Play()
				local bloom = clone6.Bloom
				clone6.Parent = workspace.Effects
				bloom.Parent = game.Lighting
				Debris:AddItem(clone6, 1.4)
				Debris:AddItem(bloom, 1.4)
				task.delay(1.3, function()
					clone2.BG.Visible = true
					clone2.Main.Ambient = Color3.new(1, 1, 1)
					clone2.Main.LightColor = Color3.new(1, 1, 1)
					clone2.Main.LightDirection = createVector(-1, -1, -1)
					task.wait(0.9)
					clone2.BG.Hearts.Position = UDim2.new(-0.5, 0, 0, 0)
					task.wait(0.7)
					clone2.BG.Hearts.Visible = false
				end)

				if _G.Settings.Flash ~= true then
					clone6.BG.Flashes.Enabled = false
					clone6.BG.Flashes2.Enabled = false
				end

				v3:PlaySound(sounds.Hakari.EnergySurge.Hit1, workspace, game.SoundService.Effect)
				task.delay(0.4, function()
					local attachment = clone6.RootPart.Attachment
					attachment.WorldPosition = clone5.Torso.Position
					attachment.Wind2:Emit(10)
					attachment.Hearts:Emit(20)
					attachment.Ring:Emit(1)
					v3:PlaySound(sounds.Hakari.EnergySurge.Hit1, workspace, game.SoundService.Effect)
					task.wait(0.3)
					attachment.Wind2:Emit(10)
					attachment.Hearts:Emit(20)
					attachment.Ring:Emit(1)
					v3:PlaySound(sounds.Hakari.EnergySurge.Hit2, workspace, game.SoundService.Effect)
					task.wait(0.2)
					attachment.Wind2:Emit(10)
					attachment.Hearts:Emit(20)
					attachment.Ring:Emit(1)
					v3:PlaySound(sounds.Hakari.EnergySurge.Hit1, workspace, game.SoundService.Effect)
					task.wait(0.4)
					local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

					repeat
						v3:PlaySound(
							sounds.Gojo.M1:FindFirstChild("Hit" .. math.random(1, 4)),
							workspace,
							game.SoundService.Effect
						)
						local clone7 = clone2.BG.Heart:Clone()
						clone7.ImageColor3 = Color3.fromHSV(math.random(0, 100) / 100, 1, 1)
						clone7.Parent = clone2.BG.Hearts
						Debris:AddItem(clone7, 0.3)
						clone7.Visible = true
						TweenService:Create(clone7, tweenInfo, {
							Size = UDim2.new(5, 0, 5, 0)
						}):Play()
						task.wait(0.075)
					until total > 171

					v3:PlaySound(sounds.Hakari.EnergySurge.Hit2, workspace, game.SoundService.Effect)
				end)
				task.delay(1, function()
					local WAIT_INTERVAL = 0.03
					Debris:AddItem(clone2, 2.2)
					local clone7 = utils.Todo.Jump.EndSpotlight:Clone()
					clone7.CFrame = humanoidRootPart.CFrame
					clone7.Parent = instance.HumanoidRootPart
					Debris:AddItem(clone7, 3.5)
					task.wait(2)
					TweenService:Create(clone2.Fade, TweenInfo.new(0.2), {
						BackgroundTransparency = 0
					}):Play()
					task.wait(0.2)

					if _G.Settings.Flash == true then
						local clone8 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
						clone8.TintColor = Color3.fromRGB(255, 170, 0)
						clone8.Parent = game.Lighting
						task.wait(WAIT_INTERVAL)
						clone8.Brightness = 200
						clone8.Contrast = -1000
						task.wait(WAIT_INTERVAL)
						clone8.TintColor = Color3.new(1, 1, 1)
						clone8.Brightness = -200
						clone8.Contrast = 1000
						task.wait(WAIT_INTERVAL)
						clone8:Destroy()
					end

					game.Lighting.ExposureCompensation = -6
					TweenService:Create(game.Lighting, TweenInfo.new(1), {
						ExposureCompensation = 0
					}):Play()
					TweenService:Create(clone7.Attachment.SpotLight, TweenInfo.new(1), {
						Brightness = 0
					}):Play()
					clone7.CFrame = humanoidRootPart.CFrame
					clone7.Dust:Emit(40)
					v3:PlaySound(sounds.Todo.Jump.Bell, instance.HumanoidRootPart, game.SoundService.Effect)
					local followTakada = workspace.Effects:FindFirstChild("FollowTakada")

					if followTakada and localPlayer.Character == instance then
						followTakada:SetAttribute("A", CFrame.new(-6, 0, 0))
						followTakada.Humanoid:LoadAnimation(animations.Todo.TakadaJoint.JumpEnd):Play(0)
						task.wait(1)
						followTakada:SetAttribute("A", nil)
					end
				end)
			end
		end,
		Hit = function(p, instance)
			if localPlayer == p then
				return
			end

			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 1))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)
			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hakari.EnergySurge.Hit1, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Hit2 = function(p, instance)
			if localPlayer == p then
				return
			end

			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(
				sounds.Gojo.M1:FindFirstChild("Hit" .. math.random(1, 4)),
				humanoidRootPart,
				game.SoundService.Effect
			)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Hit3 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 0.498039))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)
			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hakari.EnergySurge.Hit1, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Burst = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1), 1)
			v3:PlaySound(sounds.Itadori.CursedStrikes.Startup, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				local followTakada = workspace.Effects:FindFirstChild("FollowTakada")

				if followTakada and localPlayer.Character == instance then
					followTakada:SetAttribute("A", CFrame.new(4, 0, 0))
					followTakada.Humanoid:LoadAnimation(animations.Todo.TakadaJoint.JumpStart):Play(0)
					task.wait(1)
					followTakada:SetAttribute("A", nil)
				end
			end
		end,
		Dash = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Itadori.Rush.RushLaunch, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(2, 1, -5)
			clone.Parent = workspace.Effects
			clone.Wind:Emit(20)
			clone.PointLight:Destroy()
			clone.Back1.Back:Emit(1)
			clone.Back2.Back:Emit(1)
			TweenService:Create(clone.Back1, TweenInfo.new(2), {
				CFrame = clone.Back1.CFrame - clone.Back1.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.Back2, TweenInfo.new(2), {
				CFrame = clone.Back2.CFrame - clone.Back2.CFrame.LookVector * 20
			}):Play()
			Debris:AddItem(clone, 3)

			for _ = 1, 10 do
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
				task.wait(0.03)
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
	v = Knit.GetService("ClimaxJumpService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller