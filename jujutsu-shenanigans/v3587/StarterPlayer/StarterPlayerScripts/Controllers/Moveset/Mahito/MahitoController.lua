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
local v3 = nil
local v4 = nil
local controller = Knit.CreateController({
	Name = "MahitoController"
})

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function controller.KnitStart(_)
	local v5 = {
		Hit = function(instance, p, p2, p3)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))

			if p2 == 1 and not p3 then
				v3:PlaySound(
					sounds.Mahito.Variants.M1:FindFirstChild("Hit" .. p),
					humanoidRootPart,
					game.SoundService.Effect
				)
			elseif p2 == 2 and p3 ~= "Up" then
				v3:PlaySound(
					sounds.Mahito.Variants.M2:FindFirstChild("Hit" .. p),
					humanoidRootPart,
					game.SoundService.Effect
				)
			elseif p2 == 4 then
				v3:PlaySound(
					sounds.Mahito.Variants.M3:FindFirstChild("Hit" .. p),
					humanoidRootPart,
					game.SoundService.Effect
				)
			else
				v3:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit" .. p), humanoidRootPart, game.SoundService.Effect)
			end
		end,
		BladeHit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Megumi.Mahoraga.M1.Hit1, humanoidRootPart, game.SoundService.Effect)
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
			v3:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit3"), humanoidRootPart2, game.SoundService.Effect)
			local clone = utils.ChaseHit:Clone()
			clone.CFrame = CFrame.new(
				humanoidRootPart2.Position,
				(Vector3.new(humanoidRootPart.Position.X, humanoidRootPart2.Position.Y, humanoidRootPart.Position.Z))
			) * CFrame.Angles(0, 3.141592653589793, 0)
			clone.Parent = workspace.Effects
			clone.Ring:Emit(7)
			clone.Sparks:Emit(12)
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
		ChaseStart = function(p, p2)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			if p2 == 1 then
				v3:PlaySound(sounds.Mahito.Variants.StrikeStart, humanoidRootPart, game.SoundService.Effect)
			else
				v3:PlaySound(sounds.Mahito.Variants.Spin, humanoidRootPart, game.SoundService.Effect)
			end
		end,
		Chase2 = function(p, p2, p3)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			if localPlayer.Character == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end

			if p2 == 1 then
				v3:PlaySound(sounds.Mahito.Variants.Strike, humanoidRootPart, game.SoundService.Effect)
				RunService.Stepped:Wait()
				local cframe = CFrame.new(p3, humanoidRootPart.Position)
				local magnitude = (p3 - humanoidRootPart.Position).Magnitude
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
			elseif p2 == 4 then
				local clone = utils.Itadori.Shock:Clone()
				clone.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
				clone.Parent = workspace.Effects
				TweenService:Create(clone, TweenInfo.new(0.3), {
					Size = createVector(10, 0, 10),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone, 0.3)
				task.delay(0.075, function()
					local clone2 = utils.Itadori.Shock:Clone()
					clone2.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0) + humanoidRootPart.CFrame.LookVector * 3
					clone2.Parent = workspace.Effects
					TweenService:Create(clone2, TweenInfo.new(0.2), {
						Size = createVector(8, 0, 8),
						Transparency = 1
					}):Play()
					Debris:AddItem(clone2, 0.2)
					task.wait(0.075)
					local clone3 = utils.Itadori.Shock:Clone()
					clone3.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
					clone3.Parent = workspace.Effects
					TweenService:Create(clone3, TweenInfo.new(0.2), {
						Size = createVector(8, 0, 8),
						Transparency = 1
					}):Play()
					Debris:AddItem(clone3, 0.2)
				end)
				local clone2 = utils.Mahito.Worms.WormLaunch.groundwaveing.groundwaveing1:Clone()
				clone2.EmissionDirection = Enum.NormalId.Front
				clone2.Parent = humanoidRootPart
				Debris:AddItem(clone2, 1)
				task.delay(0.5, function()
					clone2.Enabled = false
				end)
				local clone3 = utils.Mahito.Worms.WormLaunch.groundwaveing.groundwaveing3:Clone()
				clone3.EmissionDirection = Enum.NormalId.Front
				clone3.Parent = humanoidRootPart
				Debris:AddItem(clone3, 1)
				task.delay(0.5, function()
					clone3.Enabled = false
				end)
				local rootJoint = humanoidRootPart:FindFirstChild("RootJoint")

				if rootJoint then
					local cframe = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
					rootJoint.C0 = cframe * CFrame.new(7, 0, 0)
					TweenService:Create(rootJoint, TweenInfo.new(0.8, Enum.EasingStyle.Elastic), {
						C0 = cframe
					}):Play()
				end
			else
				local clone = utils.Megumi.Wep.Attachment.Ring:Clone()
				clone.Enabled = true
				clone.TimeScale = 1
				clone.Parent = humanoidRootPart
				task.delay(0.4, function()
					clone.Enabled = false
					Debris:AddItem(clone, 0.5)
				end)
			end
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
		end,
		Swing2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local rootJoint = humanoidRootPart:FindFirstChild("RootJoint")

			if rootJoint then
				local cframe = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
				rootJoint.C0 = cframe * CFrame.new(7, 0, 0)
				TweenService:Create(rootJoint, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {
					C0 = cframe
				}):Play()
			end

			if localPlayer.Character == instance then
				local shakeSustain = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit)
				task.delay(0.45, function()
					shakeSustain:StartFadeOut(1)
				end)
			end

			local clone = utils.Mahito.Worms.DashSlash.Attachment:Clone()
			clone.Parent = humanoidRootPart
			Debris:AddItem(clone, 2.5)
			task.wait(0.45)

			for _, child in clone:GetChildren() do
				child.Enabled = false
			end

			task.wait(0.1)
			clone.Wind2:Emit(10)
			clone.Sparks:Emit(10)
		end,
		Swing3 = function(data, p, p2, p3)
			local color = Color3.fromRGB(124, 80, 255)

			local function weaponFlash(part, value, duration)
				if not part then
					return
				end

				task.spawn(function()
					if duration then
						task.wait(duration)
					end

					local clone

					if part.Name == "ClubBase" then
						clone = utils.Mahito.ClubCombatTrail:Clone()
					else
						clone = utils.Mahito.SwordCombatTrail:Clone()
					end

					clone.Color = color
					clone.Weld.Part0 = part
					clone.Parent = workspace.Effects
					task.wait(0.35)
					clone.Trail.Enabled = false
					TweenService:Create(clone, TweenInfo.new(0.1), {
						Transparency = 1
					}):Play()
					Debris:AddItem(clone, value or 0.2)
				end)
			end

			if p3 == 1 then
				local blade = data.SetAssets:FindFirstChild("Weapon").MahitoWepR.Sword.Blade
				local blade2 = data.SetAssets:FindFirstChild("Weapon").MahitoWepL.Sword.Blade

				if p2 == "Down" or p2 == "Up" then
					v3:ArmFlash(data["Right Leg"], color, 0.4)
				elseif p == 1 or p == 3 then
					if not blade then
						return
					end

					local v6 = nil
					local v7 = 0.25
					task.spawn(function()
						if v6 then
							task.wait(v6)
						end

						local clone

						if blade.Name == "ClubBase" then
							clone = utils.Mahito.ClubCombatTrail:Clone()
						else
							clone = utils.Mahito.SwordCombatTrail:Clone()
						end

						clone.Color = color
						clone.Weld.Part0 = blade
						clone.Parent = workspace.Effects
						task.wait(0.35)
						clone.Trail.Enabled = false
						TweenService:Create(clone, TweenInfo.new(0.1), {
							Transparency = 1
						}):Play()
						Debris:AddItem(clone, v7 or 0.2)
					end)
				elseif p == 2 then
					if not blade2 then
						return
					end

					local v6 = nil
					local v7 = 0.25
					task.spawn(function()
						if v6 then
							task.wait(v6)
						end

						local clone

						if blade2.Name == "ClubBase" then
							clone = utils.Mahito.ClubCombatTrail:Clone()
						else
							clone = utils.Mahito.SwordCombatTrail:Clone()
						end

						clone.Color = color
						clone.Weld.Part0 = blade2
						clone.Parent = workspace.Effects
						task.wait(0.35)
						clone.Trail.Enabled = false
						TweenService:Create(clone, TweenInfo.new(0.1), {
							Transparency = 1
						}):Play()
						Debris:AddItem(clone, v7 or 0.2)
					end)
				elseif p == 4 then
					if blade then
						local v6 = nil
						local v7 = 0.35
						task.spawn(function()
							if v6 then
								task.wait(v6)
							end

							local clone

							if blade.Name == "ClubBase" then
								clone = utils.Mahito.ClubCombatTrail:Clone()
							else
								clone = utils.Mahito.SwordCombatTrail:Clone()
							end

							clone.Color = color
							clone.Weld.Part0 = blade
							clone.Parent = workspace.Effects
							task.wait(0.35)
							clone.Trail.Enabled = false
							TweenService:Create(clone, TweenInfo.new(0.1), {
								Transparency = 1
							}):Play()
							Debris:AddItem(clone, v7 or 0.2)
						end)
					end

					if not blade2 then
						return
					end

					local v6 = nil
					local v7 = 0.35
					task.spawn(function()
						if v6 then
							task.wait(v6)
						end

						local clone

						if blade2.Name == "ClubBase" then
							clone = utils.Mahito.ClubCombatTrail:Clone()
						else
							clone = utils.Mahito.SwordCombatTrail:Clone()
						end

						clone.Color = color
						clone.Weld.Part0 = blade2
						clone.Parent = workspace.Effects
						task.wait(0.35)
						clone.Trail.Enabled = false
						TweenService:Create(clone, TweenInfo.new(0.1), {
							Transparency = 1
						}):Play()
						Debris:AddItem(clone, v7 or 0.2)
					end)
				end
			elseif p3 == 2 then
				local clubBase = data.SetAssets:FindFirstChild("Weapon").MahitoWepR.Club.ClubBase
				local clubBase2 = data.SetAssets:FindFirstChild("Weapon").MahitoWepL.Club.ClubBase

				if p == 1 or p == 3 then
					if not clubBase then
						return
					end

					local v6 = 0.1
					local v7 = 0.5
					task.spawn(function()
						if v6 then
							task.wait(v6)
						end

						local clone

						if clubBase.Name == "ClubBase" then
							clone = utils.Mahito.ClubCombatTrail:Clone()
						else
							clone = utils.Mahito.SwordCombatTrail:Clone()
						end

						clone.Color = color
						clone.Weld.Part0 = clubBase
						clone.Parent = workspace.Effects
						task.wait(0.35)
						clone.Trail.Enabled = false
						TweenService:Create(clone, TweenInfo.new(0.1), {
							Transparency = 1
						}):Play()
						Debris:AddItem(clone, v7 or 0.2)
					end)
				elseif p == 2 then
					if not clubBase2 then
						return
					end

					local v6 = 0.1
					local v7 = 0.5
					task.spawn(function()
						if v6 then
							task.wait(v6)
						end

						local clone

						if clubBase2.Name == "ClubBase" then
							clone = utils.Mahito.ClubCombatTrail:Clone()
						else
							clone = utils.Mahito.SwordCombatTrail:Clone()
						end

						clone.Color = color
						clone.Weld.Part0 = clubBase2
						clone.Parent = workspace.Effects
						task.wait(0.35)
						clone.Trail.Enabled = false
						TweenService:Create(clone, TweenInfo.new(0.1), {
							Transparency = 1
						}):Play()
						Debris:AddItem(clone, v7 or 0.2)
					end)
				elseif p2 == "Up" then
					v3:ArmFlash(data["Right Leg"], color, 0.4)
				elseif p == 4 or p2 == "Down" then
					if clubBase then
						local v6 = 0.1
						local v7 = 0.75
						task.spawn(function()
							if v6 then
								task.wait(v6)
							end

							local clone

							if clubBase.Name == "ClubBase" then
								clone = utils.Mahito.ClubCombatTrail:Clone()
							else
								clone = utils.Mahito.SwordCombatTrail:Clone()
							end

							clone.Color = color
							clone.Weld.Part0 = clubBase
							clone.Parent = workspace.Effects
							task.wait(0.35)
							clone.Trail.Enabled = false
							TweenService:Create(clone, TweenInfo.new(0.1), {
								Transparency = 1
							}):Play()
							Debris:AddItem(clone, v7 or 0.2)
						end)
					end

					if not clubBase2 then
						return
					end

					local v6 = 0.1
					local v7 = 0.75
					task.spawn(function()
						if v6 then
							task.wait(v6)
						end

						local clone

						if clubBase2.Name == "ClubBase" then
							clone = utils.Mahito.ClubCombatTrail:Clone()
						else
							clone = utils.Mahito.SwordCombatTrail:Clone()
						end

						clone.Color = color
						clone.Weld.Part0 = clubBase2
						clone.Parent = workspace.Effects
						task.wait(0.35)
						clone.Trail.Enabled = false
						TweenService:Create(clone, TweenInfo.new(0.1), {
							Transparency = 1
						}):Play()
						Debris:AddItem(clone, v7 or 0.2)
					end)
				end
			elseif p3 == 3 then
				if p2 == "Down" then
					v3:ArmFlash(data["Right Leg"], color, 0.4)
				elseif p == 4 then
					v3:ArmFlash(data["Right Leg"], color, 0.4)
				elseif p == 3 then
					v3:ArmFlash(data["Left Arm"], color, 0.35)
				else
					v3:ArmFlash(data["Right Arm"], color, 0.3)
				end
			elseif p3 == 4 then
				if p2 == "Down" or p == 3 then
					v3:ArmFlash(data["Right Leg"], color, 0.4)
				elseif p == 1 or p == 2 then
					v3:ArmFlash(data["Left Arm"], color, 0.3)
				else
					v3:ArmFlash(data["Right Arm"], color, 0.3)
				end
			end
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
		M = function(instance, p, items)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart or (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 200 then
				return
			end

			if p == 1 then
				v3:PlaySound(sounds.Mahito.Variants.Transform1, humanoidRootPart, game.SoundService.Effect)
			elseif p == 2 then
				v3:PlaySound(sounds.Mahito.Variants.Transform2, humanoidRootPart, game.SoundService.Effect)
			else
				v3:PlaySound(sounds.Mahito.Variants.Transform3, humanoidRootPart, game.SoundService.Effect)
			end

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end

			for _, item in items do
				local v6 = item.Size.X / 0.02
				local v7 = item.Size.Y / 0.02
				local v8 = item.Size.Z / 0.02

				for _ = 1, 12 do
					local clone = utils.Mahito.Morph:Clone()
					clone.Weld.Part0 = item
					clone.Color = item.Color
					clone.Material = item.Material
					clone.Weld.C0 = CFrame.new(
						math.random(-v6, v6) / 100,
						math.random(-v7, v7) / 100,
						math.random(-v8, v8) / 100
					)
					clone.Parent = workspace.Effects
					local v9 = math.random(100, 200) / 100
					local v10 = math.random(10, 40) / 100
					clone.Size = createVector(1, 1, 1) * v9
					TweenService:Create(clone, TweenInfo.new(v10, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
						Size = createVector(0, 0, 0)
					}):Play()
					TweenService:Create(
						clone.Weld,
						TweenInfo.new(v10, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
						{
							C0 = CFrame.new(0, 3, 0)
						}
					):Play()
					Debris:AddItem(clone, v10)
				end
			end
		end,
		Chat2 = function(instance)
			local torso = instance:FindFirstChild("Torso")

			if not torso then
				return
			end

			local clone = utils.Mahito.Worms.Dialogue2:Clone()
			clone.Parent = torso
			local position = clone.Chat1.Position
			clone.Chat1.Position = position - UDim2.new(0, 0, 0.15, 0)
			TweenService:Create(clone.Chat1, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = position
			}):Play()
			TweenService:Create(clone.Chat1, TweenInfo.new(0.3), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(clone.Chat1.Sub, TweenInfo.new(0.3), {
				TextTransparency = 0
			}):Play()
			task.wait(0.5)
			local position2 = clone.Chat2.Position
			clone.Chat2.Position = position2 - UDim2.new(0, 0, 0.15, 0)
			TweenService:Create(clone.Chat2, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = position2
			}):Play()
			TweenService:Create(clone.Chat2, TweenInfo.new(0.3), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(clone.Chat2.Sub, TweenInfo.new(0.3), {
				TextTransparency = 0
			}):Play()
			task.wait(0.3)
			v3:PlaySound(sounds.Gojo.BlindsOff, torso, game.SoundService.Effect)
			task.wait(0.6)
			Debris:AddItem(clone, 0.6)

			for _, guiObject in clone:GetDescendants() do
				if guiObject:IsA("Frame") then
					TweenService:Create(guiObject, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Position = guiObject.Position - UDim2.new(0, 0, 0.2, 0),
						BackgroundTransparency = 1
					}):Play()
				elseif guiObject:IsA("TextLabel") then
					TweenService:Create(guiObject, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						TextTransparency = 1
					}):Play()
				end
			end
		end,
		Worms = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.Worms.WormLaunch:Clone()
			clone.CFrame = humanoidRootPart.CFrame + humanoidRootPart.CFrame.LookVector * 3 - createVector(0, 3, 0)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 3)
			local v6 = {
				Color3.fromRGB(170, 170, 127),
				Color3.fromRGB(255, 170, 255),
				Color3.fromRGB(85, 170, 127),
				Color3.fromRGB(85, 85, 127),
				Color3.fromRGB(85, 85, 0)
			}

			for i = 1, 15 do
				local v7 = i
				task.delay((i - 1) * 0.08, function()
					if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 300 then
						return
					end

					local clone2 = utils.Mahito.Worms.Worm:Clone()
					clone2:SetPrimaryPartCFrame(humanoidRootPart.CFrame * CFrame.Angles(
						math.rad((math.random(70, 110))),
						math.rad((math.random(-20, 20))),
						0
					) + createVector(0, -3, 0) + humanoidRootPart.CFrame.LookVector * 3)
					local velocity = clone2["1"].CFrame.LookVector * math.random(120, 200)
					clone2["1"].RotVelocity = Vector3.new(
						math.random(-200, 200),
						math.random(-200, 200),
						math.random(-200, 200)
					)
					local color = v6[math.random(1, #v6)]

					for i2, child in clone2:GetChildren() do
						child.Color = color
						child.Velocity = velocity
					end

					clone2.Parent = workspace.Effects
					Debris:AddItem(clone2, 3)

					for i2 = 2, 8 do
						local v10 = clone2[tostring(i2)]
						local v11 = clone2[tostring(i2 - 1)]
						local attachment = Instance.new("Attachment", v10)
						local attachment2 = Instance.new("Attachment", v11)
						attachment.Position = createVector(0, 0, -1.5)
						attachment2.Position = createVector(0, 0, 1.5)
						local ballSocketConstraint = Instance.new("BallSocketConstraint")
						ballSocketConstraint.Attachment0 = attachment
						ballSocketConstraint.Attachment1 = attachment2
						ballSocketConstraint.LimitsEnabled = true
						ballSocketConstraint.Parent = attachment
					end

					sounds.Mahito.Worms.Fire.PlaybackSpeed = math.random(140, 200) / 100
					v3:PlaySound(sounds.Mahito.Worms.Fire, clone2["1"], game.SoundService.Effect)

					if v7 == 15 then
						for i2, emitter in clone:GetDescendants() do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end

					task.wait(0.4)

					for i2 = 1, 8 do
						local v10 = clone2[tostring(i2)]
						v10.CanCollide = true
						v10.Anchored = false
					end

					task.wait(1.6)
					local tweenInfo = TweenInfo.new(0.1111111111111111)
					local v10 = {
						Size = createVector(0, 0, 0)
					}

					for i2 = 8, 1, -1 do
						TweenService:Create(clone2[tostring(i2)], tweenInfo, v10):Play()
						task.wait(0.1111111111111111)
					end
				end)
			end

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 150 then
				local shakeSustain = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap)
				task.delay(1, function()
					shakeSustain:StartFadeOut(1)
				end)
			end
		end,
		Spit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local attachment = Instance.new("Attachment", instance.Head)
			attachment.Position = createVector(0, -0.25, -0.6)
			Debris:AddItem(attachment, 1)
			local clone = utils.Mahito.Worms.Spit:Clone()
			clone.Parent = attachment
			clone:Emit(30)
			v3:PlaySound(sounds.Mahito.Worms.Spit, humanoidRootPart, game.SoundService.Effect)
			task.delay(0.4, function()
				v3:PlaySound(sounds.Gojo.GrabBlinds, humanoidRootPart, game.SoundService.Effect)
			end)
			local model = Instance.new("Model", instance)
			model.Name = "BodyRepelStart"
			Debris:AddItem(model, 1)

			for _, child in replicatedStorage.Utils.Mahito.BodyRepel.BodyRepelStart:GetChildren() do
				local clone2 = child:Clone()
				clone2[child.Name].Part0 = humanoidRootPart
				clone2.Parent = model
				task.wait(0.03)
			end
		end,
		Chat = function(instance)
			local torso = instance:FindFirstChild("Torso")

			if not torso then
				return
			end

			v3:PlaySound(sounds.Gojo.BlindsOff, torso, game.SoundService.Effect)
			local clone = utils.Mahito.Worms.Dialogue:Clone()
			clone.Parent = torso
			local position = clone.Chat1.Position
			clone.Chat1.Position = position - UDim2.new(0, 0, 0.15, 0)
			TweenService:Create(clone.Chat1, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = position
			}):Play()
			TweenService:Create(clone.Chat1, TweenInfo.new(0.3), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(clone.Chat1.Sub, TweenInfo.new(0.3), {
				TextTransparency = 0
			}):Play()
			task.wait(1)
			Debris:AddItem(clone, 0.6)

			for _, guiObject in clone:GetDescendants() do
				if guiObject:IsA("Frame") then
					TweenService:Create(guiObject, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Position = guiObject.Position - UDim2.new(0, 0, 0.2, 0),
						BackgroundTransparency = 1
					}):Play()
				elseif guiObject:IsA("TextLabel") then
					TweenService:Create(guiObject, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						TextTransparency = 1
					}):Play()
				end
			end
		end,
		Worms2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local colors = {}

			for _, part in instance:GetChildren() do
				if part:IsA("BasePart") and part ~= humanoidRootPart and part.Transparency ~= 1 then
					table.insert(colors, part.Color)
				end
			end

			local clone = utils.Mahito.Worms.FleshSpread:Clone()
			clone.Color = ColorSequence.new(colors[math.random(1, #colors)])
			clone.Parent = humanoidRootPart
			Debris:AddItem(clone, 2)
			task.delay(0.8, function()
				clone.Enabled = false
				task.wait(0.4)
				v3:PlaySound(sounds.Mahito.Worms.Whip, humanoidRootPart, game.SoundService.Effect)
			end)
			v3:PlaySound(sounds.Mahito.Worms.Morph, humanoidRootPart, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 150 then
				local shakeSustain = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit)
				task.delay(0.8, function()
					shakeSustain:StartFadeOut(1)
				end)
			end

			local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

			for i = 1, 15 do
				if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 300 then
					task.wait()
				else
					local v6 = math.random(90, 130) / 100
					local clone2 = utils.Mahito.Worms.Morph2:Clone()

					if i % 4 ~= 0 then
						clone2.Decal:Destroy()
					end

					clone2.Color = colors[math.random(1, #colors)]
					clone2.Weld.C0 *= CFrame.Angles(
						math.random(0, 3.141592653589793),
						math.random(0, 3.141592653589793),
						math.random(0, 3.141592653589793)
					)
					clone2.Weld.Part0 = humanoidRootPart
					clone2.Parent = workspace.Effects
					Debris:AddItem(clone2, 2)
					TweenService:Create(clone2.Weld, TweenInfo.new(v6 + 0.4, Enum.EasingStyle.Exponential), {
						C0 = clone2.Weld.C0 * CFrame.Angles(
							math.random(0, 3.141592653589793),
							math.random(0, 3.141592653589793),
							math.random(0, 3.141592653589793)
						)
					}):Play()
					task.spawn(function()
						local v9 = v6 / 5
						TweenService:Create(clone2, TweenInfo.new(v6 * 0.66, Enum.EasingStyle.Elastic), {
							Size = createVector(1, 1, 1) * math.random(80, 140) / 10
						}):Play()
						task.delay(v6 * 0.33, function()
							TweenService:Create(
								clone2,
								TweenInfo.new(v6 * 0.33, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
								{
									Size = createVector(0, 0, 10)
								}
							):Play()
						end)
						local tweenInfo2 = TweenInfo.new(v9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

						for i2 = 1, 5 do
							local lerped = CFrame.new(
								math.random(-40, 40) / 3,
								math.random(-10, 50) / 5,
								math.random(-20, 20) / 3
							):Lerp(
								CFrame.new(),
								i2 / 6
							)
							TweenService:Create(clone2.Weld, tweenInfo2, {
								C1 = lerped
							}):Play()
							task.wait(v9)
						end

						TweenService:Create(clone2, tweenInfo, {
							Size = createVector(0, 0, 0)
						}):Play()
					end)
					task.wait()
				end
			end
		end,
		Dash = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Itadori.Rush.Rush, humanoidRootPart, game.SoundService.Effect)
			local clone = replicatedStorage.Utils.Itadori.RushWind:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			clone.Dust:Emit(7)
			clone.Ring:Emit(7)
			clone.Dash1.Dash:Emit(1)
			clone.Dash2.Dash:Emit(1)
			Debris:AddItem(clone, 2)
			local clone2 = utils.Itadori.Shock:Clone()
			clone2.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.2), {
				Size = createVector(8, 0, 8),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone2, 0.2)
			task.delay(0.1, function()
				local clone3 = utils.Itadori.Shock:Clone()
				clone3.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
				clone3.Parent = workspace.Effects
				TweenService:Create(clone3, TweenInfo.new(0.2), {
					Size = createVector(8, 0, 8),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone3, 0.2)
			end)
			v3:PlaySound(sounds.Mahito.Transfig.Start, humanoidRootPart, game.SoundService.Effect)
			local clone3 = utils.Mahito.EyeGlow:Clone()
			clone3.Weld.Part0 = instance.Head
			clone3.Parent = workspace.Effects
			Debris:AddItem(clone3, 1)
			clone3.Eye1.Glow:Emit(1)
			clone3.Eye2.Glow:Emit(1)
			clone3.Glow:Emit(1)
			task.wait(0.8)
			clone3.Trail1.Trail.Enabled = false
			clone3.Trail2.Trail.Enabled = false
		end,
		BlackFlashImpact = function(instance, instance2)
			local WAIT_INTERVAL = 0.04

			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance2, Color3.new(1, 0, 0))
			v3:PlaySound(sounds.Itadori.DivergentFist.BlackFlashHit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)

				if _G.Settings.Flash ~= true then
					return
				end

				local clone = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone.Parent = game.Lighting
				task.wait(WAIT_INTERVAL)
				clone.TintColor = Color3.new(1, 1, 1)
				task.wait(WAIT_INTERVAL)
				clone.Brightness = 200
				clone.Contrast = -1000
				task.wait(WAIT_INTERVAL)
				clone:Destroy()
			end
		end,
		BlackFlashHit = function(instance, instance2)
			local WAIT_INTERVAL = 0.04
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local clone = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(2, 1, -5)
			clone.Parent = workspace.Effects
			clone.Wind:Emit(20)
			clone.Sparks:Emit(20)
			clone.Flare:Emit(20)
			clone.Lightning:Emit(25)
			clone.Back1.Back:Emit(1)
			clone.Back2.Back:Emit(1)
			TweenService:Create(clone.Back1, TweenInfo.new(2), {
				CFrame = clone.Back1.CFrame - clone.Back1.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.Back2, TweenInfo.new(2), {
				CFrame = clone.Back2.CFrame - clone.Back2.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()
			Debris:AddItem(clone, 3)
			v3:Flash(instance2, Color3.new(1, 0, 0), 2)
			v3:PlaySound(sounds.Mahito.BlackFlash, humanoidRootPart2, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)

				if _G.Settings.Flash ~= true then
					return
				end

				local clone2 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone2.Parent = game.Lighting
				task.wait(WAIT_INTERVAL)
				clone2.Brightness = 200
				clone2.Contrast = -1000
				task.wait(WAIT_INTERVAL)
				clone2.TintColor = Color3.new(1, 1, 1)
				task.wait(WAIT_INTERVAL)
				clone2.Brightness = -200
				clone2.Contrast = 1000
				task.wait(WAIT_INTERVAL)
				clone2:Destroy()
			end
		end,
		Eat = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(0.333333, 0.333333, 0.498039), 1)
			v3:PlaySound(sounds.Mahito.Eat, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end
	}
	v.Effects:Connect(function(p, ...)
		local v6 = v5[p]

		if not v6 then
			return
		end

		v6(...)
	end)
	v.Hitbox:Connect(function(instance, p, object, p2)
		local humanoidRootPart = p.HumanoidRootPart

		if not humanoidRootPart then
			return
		end

		if p2 then
			repeat
				local sphereHitbox = v2:SphereHitbox(p, CFrame.new(0, 0, 0), 12)

				if #sphereHitbox > 0 then
					object:FireServer(sphereHitbox, humanoidRootPart.CFrame)
				end

				task.wait(0.05)
			until not instance.Parent
		else
			local v6 = nil

			while true do
				local sphereHitbox = v2:SphereHitbox(p, CFrame.new(0, 0, -4), 8)

				for _, v8 in sphereHitbox do
					local info = v8:FindFirstChild("Info")

					if not info then
						continue
					end

					local knockback = info:FindFirstChild("Knockback")

					if not (not knockback or knockback.Value ~= false) then
						continue
					end

					v6 = sphereHitbox
					break
				end

				if v6 then
					local numberValue = instance:FindFirstChildWhichIsA("NumberValue")

					if numberValue then
						TweenService:Create(numberValue, TweenInfo.new(0.1), {
							Value = 0
						}):Play()
					end
				else
					task.wait(0.05)

					if instance.Parent then
						continue
					end
				end

				object:FireServer(v6, humanoidRootPart.CFrame)
				break
			end
		end
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("MahitoService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
	v4 = Knit.GetController("ToolController")
end

return controller