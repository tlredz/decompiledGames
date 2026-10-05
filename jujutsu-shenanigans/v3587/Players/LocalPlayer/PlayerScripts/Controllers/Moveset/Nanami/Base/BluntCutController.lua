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
local BloodyZee = require(replicatedStorage.Modules.BloodyZee)
local SraikoVFX = require(replicatedStorage.Modules.SraikoVFX)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "BluntCutController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Nanami.BluntCut.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit = function(instance, instance2, p, p2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end

			if p then
				for _ = 1, 10 do
					BloodyZee:Blood(
						CFrame.lookAt(humanoidRootPart.Position, p2) * CFrame.Angles(0, 3.141592653589793, 0),
						math.random(40, 125),
						25,
						25
					)
				end
			end

			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(
				p and sounds.Nanami.BluntCut.RatioHit or sounds.Nanami.BluntCut.Hit,
				humanoidRootPart,
				game.SoundService.Effect
			)
		end,
		Charge = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Nanami.BluntCut.Charge.Strike:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = humanoidRootPart.CFrame
			clone.Weld.Part0 = humanoidRootPart
			Debris:AddItem(clone, 3)
			local v5 = v2:PlaySound(sounds.Nanami.BluntCut.Charge, humanoidRootPart, game.SoundService.Effect)

			for _, beam in pairs(clone:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				local v6 = beam
				task.spawn(function()
					v6.Enabled = true
					local v7 = v6
					v6.Width0 = 0
					v7.Width1 = 0
					v6.CurveSize0 = 0
					v6.CurveSize1 = 0
					v6.Attachment0.Position *= 0.5
					v6.Attachment1.Position *= 0.5
					local curveSize = v6.Attachment0.Name == "A1" and -5 or 5
					local curveSize2 = v6.Attachment1.Name == "A2" and 5 or -5
					local v10 = v6.Attachment0.Name == "A1" and 4 or -4
					local tween = TweenService:Create(v6, TweenInfo.new(0.6), {
						Width0 = 4,
						Width1 = 4,
						CurveSize0 = curveSize,
						CurveSize1 = curveSize2
					})
					tween:Play()
					local tween2 = TweenService:Create(v6.Attachment0, TweenInfo.new(0.6), {
						Position = Vector3.new(v10, 0, 0)
					})
					tween2:Play()
					local tween3 = TweenService:Create(v6.Attachment1, TweenInfo.new(0.6), {
						Position = Vector3.new(-v10, 0, 0)
					})
					tween3:Play()

					repeat
						task.wait()
					until p.Parent == nil or p.Value == true

					tween:Cancel()
					tween2:Cancel()
					tween3:Cancel()

					if not p.Value then
						TweenService:Create(v6, TweenInfo.new(0.125), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end
				end)
			end

			local now = tick() - 0.19
			local total = 0

			while true do
				task.wait()

				if tick() - now >= 0.2 then
					now = tick()
					total += 0.35
					local raycastResult = workspace:Raycast(
						humanoidRootPart.Position,
						createVector(-0, -7.5, -0),
						raycastParams
					)

					if raycastResult then
						for _, model in pairs(utils.Nanami.BluntCut.Charge:GetChildren()) do
							if not model:IsA("Model") then
								continue
							end

							local clone2 = model:Clone()
							clone2:ScaleTo(total)
							local v6 = SraikoVFX.HandleMesh(
								clone2,
								CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
									-1.5707963267948966,
									0,
									0
								)
							)
							clone2.Parent = workspace.Effects
							Debris:AddItem(clone2, v6)
						end
					end
				end

				if not (p.Parent == nil or p.Value == true) then
					continue
				end

				v5:Stop()

				if p.Parent == nil then
					Debris:AddItem(clone, 0.125)
					break
				end

				v2:PlaySound(sounds.Nanami.BluntCut.ChargeFinish, humanoidRootPart, game.SoundService.Effect)

				for _, effect in pairs(clone:GetDescendants()) do
					if effect:IsA("ParticleEmitter") then
						effect:Emit(effect:GetAttribute("EmitCount"))
					elseif effect:IsA("Beam") then
						effect.Enabled = true
						TweenService:Create(effect, TweenInfo.new(0.4), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						local v6 = effect
						task.delay(0.5, function()
							v6.Enabled = false
							v6.Width0 = 15
							v6.Width1 = 15
						end)
					end
				end

				local raycastResult = workspace:Raycast(
					humanoidRootPart.Position,
					createVector(-0, -7.5, -0),
					raycastParams
				)

				if not raycastResult then
					break
				end

				for _, model in pairs(utils.Nanami.BluntCut.Charge:GetChildren()) do
					if not model:IsA("Model") then
						continue
					end

					local clone2 = model:Clone()
					local v6 = SraikoVFX.HandleMesh(
						clone2,
						CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
							-1.5707963267948966,
							0,
							0
						)
					)
					clone2.Parent = workspace.Effects
					Debris:AddItem(clone2, v6)
				end

				break
			end
		end,
		Dash = function(p, p2)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			RunService.Stepped:Wait()
			local cframe = CFrame.new(p2, humanoidRootPart.Position)
			local magnitude = (p2 - humanoidRootPart.Position).Magnitude
			local clone = utils.Mahito.Dash:Clone()
			clone.CFrame = cframe + cframe.LookVector * magnitude / 2
			clone.Size = Vector3.new(5, 5, magnitude)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Size = Vector3.new(0, 0, magnitude),
				CFrame = clone.CFrame * CFrame.Angles(0, 0, 3.141592653589793)
			}):Play()
			Debris:AddItem(clone, 0.2)
			local model = Instance.new("Model")
			local clone2 = replicatedStorage.Utils.Itadori.RushWind:Clone()
			clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1, 0)
			clone2.Parent = model
			model.Parent = workspace.Effects
			model:ScaleTo(0.6)
			clone2.Ring:Emit(7)
			clone2.Dash1.Dash:Emit(1)
			clone2.Dash2.Dash:Emit(1)
			Debris:AddItem(model, 2)
			local clone3 = utils.Itadori.Shock:Clone()
			clone3.CFrame = cframe * CFrame.Angles(1.5707963267948966, 0, 0)
			clone3.Parent = workspace.Effects
			TweenService:Create(clone3, TweenInfo.new(0.3), {
				Size = createVector(10, 0, 10),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone3, 0.3)
			task.delay(0.075, function()
				local clone4 = utils.Itadori.Shock:Clone()
				clone4.CFrame = cframe * CFrame.Angles(1.5707963267948966, 0, 0) + cframe.LookVector * 3
				clone4.Parent = workspace.Effects
				TweenService:Create(clone4, TweenInfo.new(0.2), {
					Size = createVector(8, 0, 8),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone4, 0.2)
				task.wait(0.075)
				local clone5 = utils.Itadori.Shock:Clone()
				clone5.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
				clone5.Parent = workspace.Effects
				TweenService:Create(clone5, TweenInfo.new(0.2), {
					Size = createVector(8, 0, 8),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone5, 0.2)
			end)
			v2:PlaySound(sounds.Nanami.BluntCut.Dash, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Hit2 = function(instance, instance2, p)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end

			v2:Flash(instance2, Color3.new(0.333333, 0.666667, 1))
			v2:PlaySound(
				p and sounds.Nanami.CrossCut.RatioHit or sounds.Nanami.CrossCut.Hit1,
				humanoidRootPart,
				game.SoundService.Effect
			)
		end,
		Hit3 = function(instance, instance2, p)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.MediumHit)
			end

			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)
			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(
				p and sounds.Nanami.CrossCut.RatioHit or sounds.Nanami.CrossCut.Hit2,
				humanoidRootPart,
				game.SoundService.Effect
			)
		end,
		Swing2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Nanami.CrossCut.Whoosh, humanoidRootPart, game.SoundService.Effect)
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
			clone.Weld.C0 = clone.Weld.C0 * CFrame.new(0.5, -1, -0.5) * CFrame.Angles(0, 0, 0.17453292519943295) * CFrame.Angles(
				0,
				0.08726646259971647,
				1.1344640137963142
			)
			clone.Weld.Part0 = humanoidRootPart
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.6)
			clone.Core.Wind:Emit(7)
			TweenService:Create(clone.Weld, TweenInfo.new(0.2), {
				C1 = clone.Weld.C1 * CFrame.Angles(0, -3.141592653589793, 0)
			}):Play()
			TweenService:Create(clone.Beam, TweenInfo.new(0.2), {
				Width0 = 0
			}):Play()
		end,
		Endlag = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Nanami.CrossCut.Endlag, humanoidRootPart, game.SoundService.Effect)
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
				v2:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, humanoidRootPart, game.SoundService.Effect)
				v2:DustBreak(humanoidRootPart.Position + createVector(0, 2, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)

				if localPlayer:DistanceFromCharacter(humanoidRootPart.Position) < 20 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				end
			end
		end,
		Leap = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Nanami.CrossCut.Start, humanoidRootPart, game.SoundService.Effect)

			if instance == localPlayer.Character then
				p.Position = humanoidRootPart.Position + createVector(0, 2, 0)
			end
		end,
		Slam = function(instance, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Nanami.CrossCut.Slam.Cone:Clone()
			local v5 = SraikoVFX.HandleMesh(clone, CFrame.new(p, p + p2) * CFrame.Angles(-1.5707963267948966, 0, 0))
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, v5)
			local clone2 = utils.Nanami.CrossCut.Slam.NewSlash:Clone()
			local v6 = SraikoVFX.HandleMesh(clone2, CFrame.new(p, p + p2) * CFrame.Angles(-1.5707963267948966, 0, 0))
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, v6)
			SraikoVFX.Emit(
				utils.Nanami.CrossCut.Slam.Strike,
				CFrame.new(p, p + p2) * CFrame.Angles(-1.5707963267948966, 0, 0)
			)
			v2:PlaySound(sounds.Nanami.CrossCut.Slam, humanoidRootPart, game.SoundService.Effect)
		end,
		LaunchDown = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Nanami.CrossCut.Dash.Strike:Clone()
			clone.Parent = workspace.Effects
			clone.Weld.Part0 = humanoidRootPart
			clone.Weld.C0 = CFrame.new(0, -2, 0)

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("Beam") then
					effect.Enabled = true
					TweenService:Create(effect, TweenInfo.new(0.2), {
						Width0 = 0,
						Width1 = 0
					}):Play()
					local v5 = effect
					task.delay(0.30000000000000004, function()
						v5.Enabled = false
						v5.Width0 = 12
						v5.Width1 = 12
					end)
				end

				if effect:IsA("ParticleEmitter") then
					effect:Emit(effect:GetAttribute("EmitCount"))
				end
			end

			Debris:AddItem(clone, 2)
		end,
		Finisher = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if localPlayer.Character ~= instance and localPlayer.Character ~= instance2 then
				task.delay(0.55, function()
					local v5 = v2:PlaySound(sounds.Nanami.BluntCut.Finisher, humanoidRootPart, game.SoundService.Effect)
					v5.TimePosition = 0.55
					v5.Volume = 4.5
				end)
			end

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				v2:PlaySound(sounds.Nanami.BluntCut.Finisher, workspace, game.SoundService.Effect)
				local screenGui = Instance.new("ScreenGui")
				screenGui.IgnoreGuiInset = true
				screenGui.Parent = localPlayer.PlayerGui
				local frame = Instance.new("Frame")
				frame.BackgroundTransparency = 1
				frame.BackgroundColor3 = Color3.new(0, 0, 0)
				frame.AnchorPoint = Vector2.new(0.5, 0.5)
				frame.Size = UDim2.fromScale(1, 1)
				frame.Position = UDim2.fromScale(0.5, 0.5)
				frame.Parent = screenGui
				TweenService:Create(frame, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					BackgroundTransparency = 0
				}):Play()
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.BackgroundTransparency = 1
				imageLabel.Image = "rbxassetid://93103077686592"
				imageLabel.ImageTransparency = 1
				imageLabel.ImageColor3 = Color3.fromRGB(150, 0, 0)
				imageLabel.Size = UDim2.fromScale(1, 1)
				imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				imageLabel.Position = UDim2.fromScale(0.5, 0.5)
				task.wait(0.15)
				local clone = game.ReplicatedStorage.Utils.Nanami.Ratio.Bar:Clone()
				clone.Parent = frame
				local _ = clone.Cursor
				clone.Rotation = -180
				clone.Size = UDim2.fromScale(0.16, 2.4)
				TweenService:Create(
					clone,
					TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Rotation = 80,
						Size = UDim2.fromScale(0.08, 1.2)
					}
				):Play()
				task.wait(0.25)

				if _G.Settings.Gore == false then
					imageLabel.ImageColor3 = Color3.fromRGB(255, 85, 255)
					clone.Hit2.ImageColor3 = Color3.fromRGB(255, 85, 255)
				end

				imageLabel.ImageTransparency = 0
				clone.Hit.Visible = true
				clone.Hit.ImageColor3 = Color3.new(0, 0, 0)
				frame.BackgroundColor3 = Color3.new(1, 1, 1)
				clone.Bar.ImageColor3 = Color3.new(0, 0, 0)
				task.wait(0.035)
				frame.BackgroundColor3 = Color3.new(0, 0, 0)
				clone.Bar.ImageColor3 = Color3.new(1, 1, 1)
				clone.Hit.Visible = false
				clone.Hit2.Visible = true
				clone.Hit2.Size = UDim2.fromScale(0.5, 0.1)
				TweenService:Create(
					clone.Hit2,
					TweenInfo.new(0.125, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						ImageTransparency = 0.15,
						Size = UDim2.fromScale(15, 3)
					}
				):Play()
				task.wait(0.05)
				imageLabel.Parent = frame
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				task.wait(0.1)
				screenGui:Destroy()
			end
		end,
		FinisherBleed = function(instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			v2:Bleed(instance)
		end,
		Finisher2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Yuta.ResoluteHit, humanoidRootPart, game.SoundService.Effect)
			v2:Bleed(instance)
		end
	}
	v.Effects:Connect(function(p, ...)
		local v5 = v4[p]

		if not v5 then
			return
		end

		v5(...)
	end)
	v.Hitbox:Connect(function(instance, p, object)
		local humanoidRootPart = p.HumanoidRootPart

		if not humanoidRootPart then
			return
		end

		repeat
			local raycastResult = workspace:Raycast(
				(humanoidRootPart.CFrame * CFrame.new(0, 0, -2.5)).Position,
				instance.Velocity.Unit * 8,
				raycastParams
			)
			local sphereHitbox = v3:SphereHitbox(p, CFrame.new(0, -5, -5), 12)

			if raycastResult then
				object:FireServer(
					sphereHitbox,
					raycastResult and raycastResult.Position,
					raycastResult and raycastResult.Normal
				)

				if raycastResult then
					instance:Destroy()
				end
			end

			task.wait(0.025)
		until not instance.Parent
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("BluntCutService")
	v3 = Knit.GetController("HitboxController")
	v2 = Knit.GetController("FXController")
end

return controller