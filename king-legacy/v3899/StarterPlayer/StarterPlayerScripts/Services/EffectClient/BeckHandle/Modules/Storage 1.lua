local createVector = vector.create
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local currentCamera = workspace.CurrentCamera
local RockModule = require(ReplicatedStorage.Chest.Assets.Modules.RockModule)
local Utility = require(ReplicatedStorage.Chest.Modules.Utility)
local FastRenderer = require(ReplicatedStorage.Chest.Modules.FastRenderer)
local HighlightModule = require(ReplicatedStorage.Chest.Modules.HighlightModule)
local Bezier = require(ReplicatedStorage.Chest.Modules.Bezier)
local Scheduler = require(ReplicatedStorage.Chest.Assets.Modules.Scheduler)

function bloomBlur()
	local blurEffect = Instance.new("BlurEffect", game.Lighting)
	blurEffect.Size = 0
	local bloomEffect = Instance.new("BloomEffect", game.Lighting)
	_G.PU:Dust(blurEffect, 0.2)
	_G.PU:Dust(bloomEffect, 0.2)
	TweenService:Create(blurEffect, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0), {
		Size = 4
	}):Play()
	TweenService:Create(bloomEffect, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0), {
		Intensity = 3,
		Size = 35,
		Threshold = 1
	}):Play()
end

function SetupPart(p)
	p.Anchored = true
	p.CanCollide = false
	p.Transparency = 1
	p.CastShadow = false
	p.Massless = true
end

return function(list)
	local character, cFrame2, v2, _ = unpack(list)
	local success, result = pcall(function()
		if type(v2) == "table" and v2.LoopDistance then
			return false
		end

		if cFrame2 then
			return (localPlayer.Character.HumanoidRootPart.Position - cFrame2.p).Magnitude > 1000
		end

		return false
	end)

	if success then
		if result then
			return
		end

		local mode = v2.Mode

		if mode == "Smoke Transform" then
			local rootPart = v2.RootPart
			local baseSize = v2.BaseSize or 1
			local v3 = {
				RollOffMaxDistance = 300,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://9914772806",
				Volume = 1.25
			}
			local sound = PeoUtils.CreateSound(v3)
			_G.PU:Dust(sound, 2)
			sound.Parent = rootPart
			sound:Play()
			local clone = ReplicatedStorage.Chest.FruitEffect.Allo.At.Attachment:Clone()
			_G.PU:Dust(clone, 1)
			clone.Parent = rootPart

			for _, emitter in pairs(clone:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				_G.ParticleSize(emitter, baseSize)
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		elseif mode == "Leopard Transform" then
			local rootPart = v2.RootPart

			if (rootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 100 then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
				local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
				clone.Enabled = true
				clone.Parent = workspace.CurrentCamera
				clone.Size = 0
				_G.PU:Dust(clone, 0.5)
				TweenService:Create(
					clone,
					TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 5, true, 0),
					{
						Size = 10
					}
				):Play()
			end

			local v3 = {
				RollOffMaxDistance = 300,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://15071462772",
				Volume = 0.2
			}
			local sound = PeoUtils.CreateSound(v3)
			_G.PU:Dust(sound, 1.3)
			sound.Parent = rootPart
			sound:Play()
			local clone = ReplicatedStorage.Chest.FruitEffect.Leopard.TransformationEffect.Attachment:Clone()
			clone.Parent = rootPart
			_G.PU:Dust(clone, 1)

			for _, emitter in pairs(clone:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local clone2 = ReplicatedStorage.Chest.FruitEffect.Leopard.TransformationEffect.strike:Clone()
			clone2.Parent = rootPart
			_G.PU:Dust(clone2, 1)

			for _, emitter in pairs(clone2:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		elseif mode == "Dark Beard Servant 1" then
			local rootPart = v2.RootPart
			local localPlayer2 = Players.LocalPlayer
			PeodizService.ForLoop({
				Step = 15,
				WaitTime = 0.03
			}, function(_)
				if (rootPart.Position - localPlayer2.Character.HumanoidRootPart.Position).Magnitude <= 100 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
					local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
					clone.Enabled = true
					clone.Parent = workspace.CurrentCamera
					clone.Size = 0
					_G.PU:Dust(clone, 0.5)
					TweenService:Create(
						clone,
						TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 5, true, 0),
						{
							Size = 10
						}
					):Play()
				end

				local v3 = math.random(50, 75) / 2
				local clone = ReplicatedStorage.Chest.SwordEffect.HellSword.Slash:Clone()
				clone.Mesh.Scale = Vector3.new(v3, 1, v3)
				clone.Decal.Transparency = -4
				clone.Decal.Color3 = Color3.fromRGB(0, 0, 0)
				clone.CFrame = rootPart.CFrame * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				) * CFrame.new(0, 0, math.random(1, 20))
				clone.Parent = workspace.Effects
				local v4 = {
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://6344307698",
					Volume = 0.5
				}
				local sound = PeoUtils.CreateSound(v4)
				_G.PU:Dust(sound, 0.5)
				sound.Parent = clone
				sound:Play()
				_G.PU:Dust(clone, 0.5)
				TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
				}):Play()
				TweenService:Create(clone.Decal, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
			end)
		elseif mode == "Vice Admiral 1" then
			local rootPart = v2.RootPart
			local localPlayer2 = Players.LocalPlayer
			PeodizService.ForLoop({
				Step = 20,
				WaitTime = 0.03
			}, function(p)
				math.floor(p * 20)

				if (rootPart.Position - localPlayer2.Character.HumanoidRootPart.Position).Magnitude <= 100 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
					local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
					clone.Enabled = true
					clone.Parent = workspace.CurrentCamera
					clone.Size = 0
					_G.PU:Dust(clone, 0.5)
					TweenService:Create(
						clone,
						TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 5, true, 0),
						{
							Size = 10
						}
					):Play()
				end

				local v3 = math.random(50, 75) / 2
				local clone = ReplicatedStorage.Chest.SwordEffect.HellSword.Slash:Clone()
				clone.Mesh.Scale = Vector3.new(v3, 1, v3)
				clone.Decal.Transparency = -4
				clone.Decal.Color3 = Color3.fromRGB(1000, 1000, 1000)
				clone.CFrame = rootPart.CFrame * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				) * CFrame.new(0, 0, math.random(1, 20))
				clone.Parent = workspace.Effects
				local v4 = {
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://6344307698",
					Volume = 0.25
				}
				local sound = PeoUtils.CreateSound(v4)
				_G.PU:Dust(sound, 0.5)
				sound.Parent = clone
				sound:Play()
				_G.PU:Dust(clone, 0.5)
				TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
				}):Play()
				TweenService:Create(clone.Decal, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
			end)
		elseif mode == "Vice Admiral 2" then
			local localPlayer2 = Players.LocalPlayer
			local _ = v2.RootPart
			PeodizService.ForLoop({
				Step = 25
			}, function(p)
				local v3 = math.floor(p * 25)
				local clone = ReplicatedStorage.Chest.SwordEffect.HellSword.Slash:Clone()
				clone.Mesh.Scale = createVector(25, 0.125, 25)
				clone.Decal.Transparency = -4
				clone.Decal.Color3 = Color3.fromRGB(1000, 1000, 1000)
				clone.CFrame = cFrame2 * CFrame.new(0, 0, -v3 * 10) * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				) * CFrame.new(0, 0, math.random(1, 20))
				clone.Parent = workspace.Effects
				local v4 = {
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://6344307698",
					Volume = 0.25
				}
				local sound = PeoUtils.CreateSound(v4)
				_G.PU:Dust(sound, 0.5)
				sound.Parent = clone
				sound:Play()
				_G.PU:Dust(clone, 0.5)
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
				}):Play()
				TweenService:Create(clone.Decal, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
					Transparency = 1
				}):Play()

				if (clone.Position - localPlayer2.Character.HumanoidRootPart.Position).Magnitude <= 100 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.SmallBump)
					local clone2 = ReplicatedStorage.Chest.Etc.Blur:Clone()
					clone2.Enabled = true
					clone2.Parent = workspace.CurrentCamera
					clone2.Size = 0
					_G.PU:Dust(clone2, 0.5)
					TweenService:Create(
						clone2,
						TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 5, true, 0),
						{
							Size = 10
						}
					):Play()
				end
			end)
		elseif mode == "Armament Acception" then
			local rootPart = v2.RootPart
			local baseSize = v2.BaseSize
			local clone = v2.Object:Clone()
			clone.Bot.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
			clone.Top.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
			clone.Bot.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.144, 0.252 * baseSize),
				NumberSequenceKeypoint.new(0.352, 1.76 * baseSize, 0.535 * baseSize),
				NumberSequenceKeypoint.new(0.836, 0.126 * baseSize),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone.Top.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.144, 0.252 * baseSize),
				NumberSequenceKeypoint.new(0.361, 4.47 * baseSize, 0.535 * baseSize),
				NumberSequenceKeypoint.new(0.836, 0.126 * baseSize),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone.Bot.Speed = NumberRange.new(20 * baseSize, 50 * baseSize)
			clone.Top.Speed = NumberRange.new(5 * baseSize, 20 * baseSize)
			clone.Bot.Acceleration = Vector3.new(0, 475 * baseSize, 0)
			clone.Top.Acceleration = Vector3.new(0, 375 * baseSize, 0)
			clone.Bot.Rate = 200
			clone.Top.Rate = 50
			clone.Position = createVector(0, -3, 0)
			clone.Parent = rootPart
			clone.Bot.Enabled = true
			clone.Top.Enabled = true
			spawn(function()
				wait(2)
				clone.Bot.Enabled = false
				clone.Top.Enabled = false
			end)
			_G.PU:Dust(clone, 4)
		elseif mode == "End Test1" then
			_G.SpecMeEnd = true
			task.spawn(function()
				PeodizService.new({
					Time = 60
				}, function()
					if _G.SpecMeEnd == false then
						return true
					end

					v2.Target.HumanoidRootPart.CFrame = v2.Bone.Position
				end)
			end)
		elseif mode == "End Test2" then
			_G.SpecMeEnd = false
		elseif mode == "watch" then
			local function watchPlayer(targetName2)
				local child = Players:FindFirstChild(targetName2)

				if not child then
					return
				end

				local function follow()
					if not (child.Character and child.Character:FindFirstChild("HumanoidRootPart")) then
						warn("ผู้เล่นยังไม่มีตัวละคร")
						return
					end

					currentCamera.CameraSubject = child.Character:FindFirstChild("Humanoid")
					currentCamera.CameraType = Enum.CameraType.Custom
					print("กำลังดูผู้เล่น: " .. targetName2)
				end

				if not child.Character then
					child.CharacterAdded:Wait()
				end

				follow()
			end

			watchPlayer(v2.TargetName)
		elseif mode == "unwatch" then
			workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			workspace.CurrentCamera.CameraSubject = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid")
			print("เลิกดูผู้เล่นแล้ว")
		elseif mode == "Lee Pung Tool" then
			local toolMode = v2.ToolMode
			local character2 = v2.Character

			if toolMode == "Diamond" then
				local leftHand = character2:FindFirstChild("LeftHand")

				if leftHand then
					local clone = ReplicatedStorage.Chest.Etc.LeePung.Diamond2:Clone()
					clone.Parent = character2
					_G.PU:Dust(clone, 2)
					local weld = Instance.new("Weld")
					weld.Part0 = leftHand
					weld.Part1 = clone.LeftHand
					weld.Parent = clone.LeftHand
					_G.PU:Dust(weld, 2)
				end

				local rightHand = character2:FindFirstChild("RightHand")

				if rightHand then
					local clone = ReplicatedStorage.Chest.Etc.LeePung.Diamond2:Clone()
					clone.Parent = character2
					_G.PU:Dust(clone, 2)
					local weld = Instance.new("Weld")
					weld.Part0 = rightHand
					weld.Part1 = clone.LeftHand
					weld.Parent = clone.LeftHand
					_G.PU:Dust(weld, 2)
				end
			elseif toolMode == "Diamond Sword" then
				local rightHand = character2:FindFirstChild("RightHand")

				if rightHand then
					local clone = ReplicatedStorage.Chest.Etc.LeePung["Diamond Sword2"]:Clone()
					clone.Parent = character2
					_G.PU:Dust(clone, 2)
					local weld = Instance.new("Weld")
					weld.Part0 = rightHand
					weld.Part1 = clone.RightHand
					weld.Parent = clone.RightHand
					_G.PU:Dust(weld, 2)
				end
			else
				local rightHand = toolMode == "Diamond Pickaxe" and character2:FindFirstChild("RightHand")

				if rightHand then
					local clone = ReplicatedStorage.Chest.Etc.LeePung["Diamond Pickaxe2"]:Clone()
					clone.Parent = character2
					_G.PU:Dust(clone, 2)
					local weld = Instance.new("Weld")
					weld.Part0 = rightHand
					weld.Part1 = clone.RightHand
					weld.Parent = clone.RightHand
					_G.PU:Dust(weld, 2)
				end
			end
		elseif mode == "Lee Pung Diamond Explosion" then
			local localPlayer2 = Players.LocalPlayer
			task.spawn(function()
				if (localPlayer2.Character.HumanoidRootPart.Position - cFrame2.p).Magnitude < 200 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
					local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
					clone.Enabled = true
					clone.Parent = workspace.CurrentCamera
					clone.Size = 0
					_G.PU:Dust(clone, 1.5)
					TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Exponential), {
						Size = 10
					}):Play()
					wait(0.5)
					TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Quad), {
						Size = 0
					}):Play()
				end
			end)
			local clone = ReplicatedStorage.Chest.Etc.Explosion5:Clone()
			clone.CFrame = cFrame2
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 2)
			local v3 = {
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://10590408959",
				Volume = 1.5
			}
			local sound = PeoUtils.CreateSound(v3)
			_G.PU:Dust(sound, 0.5)
			sound.Parent = clone
			sound:Play()

			for _, child in pairs(clone.Attachment:GetChildren()) do
				if child:isA("ParticleEmitter") then
					child:Emit(child:GetAttribute("EmitCount"))
				end
			end
		elseif mode == "Diamond Sword Explosion" then
			local localPlayer2 = Players.LocalPlayer
			task.spawn(function()
				if (localPlayer2.Character.HumanoidRootPart.Position - cFrame2.p).Magnitude < 200 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
					local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
					clone.Enabled = true
					clone.Parent = workspace.CurrentCamera
					clone.Size = 0
					_G.PU:Dust(clone, 1.5)
					TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Exponential), {
						Size = 10
					}):Play()
					wait(0.5)
					TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Quad), {
						Size = 0
					}):Play()
				end
			end)
			local clone = ReplicatedStorage.Chest.Etc.Explosion4:Clone()
			clone.CFrame = cFrame2
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 2)
			local v3 = {
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://10590408959",
				Volume = 1.5
			}
			local sound = PeoUtils.CreateSound(v3)
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()

			for _, child in pairs(clone.Attachment:GetChildren()) do
				if child:isA("ParticleEmitter") then
					child:Emit(child:GetAttribute("EmitCount"))
				end
			end

			task.spawn(function()
				local clone2 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
				clone2.Color = Color3.fromRGB(255, 85, 0)
				clone2.CFrame = CFrame.new(cFrame2.p) * CFrame.Angles(3.141592653589793, 0, 0)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 1)
				TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(250, 10, 250),
					Transparency = 1
				}):Play()
			end)
			task.spawn(function()
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Gravity.Fire:Clone()
				clone2.CFrame = CFrame.new(cFrame2.p)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 2)
				delay(1, function()
					clone2.par.Enabled = false
				end)
			end)
		elseif mode == "Diamond Pickaxe" then
			local localPlayer2 = Players.LocalPlayer
			local rootPart = v2.RootPart
			PeodizService.ForLoop({
				Step = 15,
				WaitTime = 0.03
			}, function(_)
				local v3 = math.random(50, 75) / 2
				local clone = ReplicatedStorage.Chest.Etc.LeePung.SlashAni:Clone()
				_G.PU:Dust(clone, 1)
				clone.Mesh.Scale = Vector3.new(v3, 1, v3)
				clone.CFrame = rootPart.CFrame * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				) * CFrame.new(0, 0, math.random(1, 20))
				clone.Parent = workspace.Effects
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://8364577736",
					Volume = 1.5
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://10592367662",
					Volume = 1
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = clone
				sound2:Play()
				clone.swirldot:Emit(clone.swirldot:GetAttribute("EmitCount"))
				clone.swirldot2:Emit(clone.swirldot2:GetAttribute("EmitCount"))
				local Animate = require(clone.Animate)
				Animate()

				if (clone.Position - localPlayer2.Character.HumanoidRootPart.Position).Magnitude <= 100 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.SmallBump)
					local clone2 = ReplicatedStorage.Chest.Etc.Blur:Clone()
					clone2.Enabled = true
					clone2.Parent = workspace.CurrentCamera
					clone2.Size = 0
					_G.PU:Dust(clone2, 0.5)
					TweenService:Create(
						clone2,
						TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 5, true, 0),
						{
							Size = 10
						}
					):Play()
				end
			end)
		elseif mode == "Smoke Transform Chest" then
			local rootPart = v2.RootPart
			local baseSize = v2.BaseSize or 1
			local v3 = {
				RollOffMaxDistance = 300,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://9914772806",
				Volume = 3
			}
			local sound = PeoUtils.CreateSound(v3)
			_G.PU:Dust(sound, 1.3)
			sound.Parent = rootPart
			sound:Play()
			local clone = ReplicatedStorage.Chest.FruitEffect.Allo.At.Attachment:Clone()
			clone.Parent = rootPart
			_G.PU:Dust(clone, 1)

			for _, emitter in pairs(clone:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				_G.ParticleSize(emitter, baseSize)
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		elseif mode == "ATK M4" then
			task.spawn(function()
				local rootPart = v2.RootPart
				PeodizService.ForLoop({
					Step = 10,
					WaitTime = 0.05
				}, function(p)
					local v3 = math.floor(p * 10)
					local cframe = CFrame.new(rootPart.Position)
					local C0 = CFrame.new(0, math.random(-2, 2), 0) * CFrame.Angles(
						math.rad((math.random(-10, 10))),
						6.283185307179586 * math.random(),
						0
					)
					local clone = ReplicatedStorage.Chest.SwordEffect["Authentic Triple Katana"].SlashAni:Clone()
					clone.Anchored = false
					clone.Massless = true
					clone.Top.Color3 = Color3.fromRGB(170, 0, 2000)
					clone.Mesh.Scale = createVector(7, 0.5, 7) * (math.random(5, 10) / 5)
					clone.CFrame = CFrame.new(cframe.p) * C0
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 1)
					local weld = Instance.new("Weld")
					weld.Part0 = rootPart
					weld.Part1 = clone
					weld.C0 = C0
					weld.Parent = clone
					_G.PU:Dust(weld, 1)
					task.spawn(function()
						for _, emitter in pairs(clone.Attachment2:GetChildren()) do
							if emitter:IsA("ParticleEmitter") then
								emitter:Emit(emitter:GetAttribute("EmitCount"))
							end
						end
					end)

					if v3 % 2 == 0 then
						local sound = PeoUtils.CreateSound({
							RollOffMaxDistance = 500,
							RollOffMinDistance = 10,
							RollOffMode = Enum.RollOffMode.InverseTapered,
							SoundId = "rbxassetid://8364577736",
							PlaybackSpeed = 1.35,
							Volume = 0.25
						})
						_G.PU:Dust(sound, 3)
						sound.Parent = clone
						sound:Play()
					end

					local Animate = require(clone.Animate)
					Animate()
				end)
			end)
		elseif mode == "ATK Awake Charge" then
			local chargeFolder = v2.ChargeFolder
			local character2 = v2.Character
			local rootPart = v2.RootPart
			tick()
			task.spawn(function()
				if chargeFolder and chargeFolder.Parent then
					local clone = v2.Attachment:Clone()

					for _, emitter in pairs(clone:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						_G.ParticleSize(emitter, 3)
						emitter.Enabled = true
					end

					clone.Parent = rootPart
					_G.PU:Dust(clone, 10)
					local clone2 = ReplicatedStorage.Chest.SwordEffect["Authentic Triple Katana"].PartWinddd:Clone()
					clone2.CFrame = CFrame.new(rootPart.Position) * CFrame.new(0, 10, 0)
					clone2.Parent = workspace.Effects
					_G.PU:Dust(clone2, 10)

					for _, emitter in pairs(clone2:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end

					local clone3 = ReplicatedStorage.Chest.SwordEffect["Authentic Triple Katana"].Part1203.Attachment2:Clone()

					for _, emitter in pairs(clone3:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						_G.ParticleSize(emitter, 2)
						emitter.Enabled = true
					end

					clone3.Parent = rootPart
					_G.PU:Dust(clone3, 10)
					PeodizService.new({
						Time = 10
					}, function()
						if not chargeFolder:IsDescendantOf(character2) or character2.Humanoid.Health <= 0 then
							return true
						end

						clone2.CFrame = CFrame.new(rootPart.Position) * CFrame.new(0, 10, 0)
					end)

					if clone then
						for _, emitter in pairs(clone:GetChildren()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						_G.PU:Dust(clone, 1)
					end

					if clone2 then
						for _, emitter in pairs(clone2:GetChildren()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						_G.PU:Dust(clone2, 1)
					end

					if clone3 then
						for _, emitter in pairs(clone3:GetChildren()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						_G.PU:Dust(clone3, 1)
					end
				end
			end)
			task.spawn(function()
				if chargeFolder and chargeFolder.Parent then
					PeodizService.HeartbeatWait({
						Time = 10,
						WaitTime = 0.15
					}, function()
						if not chargeFolder:IsDescendantOf(character2) or character2.Humanoid.Health <= 0 then
							return true
						end

						local cframe = CFrame.new(rootPart.Position)
						local clone = ReplicatedStorage.Chest.Etc.BlackLeg.Shockowave:Clone()
						clone.CastShadow = false
						clone.Transparency = 0.1
						clone.CFrame = cframe * CFrame.new(0, -1.5, 0)
						clone.Parent = workspace.Effects
						TweenService:Create(
							clone,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Size = createVector(75, 7.5, 75),
								Transparency = 1
							}
						):Play()
						_G.PU:Dust(clone, 0.5)
					end)
				end
			end)
		elseif mode == "Magnet Hand" then
			local character2 = v2.Character
			local chargeFolder = v2.ChargeFolder
			local rootPart = v2.RootPart
			local clone = ReplicatedStorage.Chest.FruitEffect.Magnet.ChargeParticle:Clone()
			clone.Enabled = true
			clone.Parent = character2.RightHand
			_G.PU:Dust(clone, 15)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://12016538518",
				Volume = 3
			})
			_G.PU:Dust(sound, 15)
			sound.Parent = rootPart
			sound:Play()
			PeodizService.HeartbeatWait({
				Time = 10
			}, function()
				if chargeFolder:IsDescendantOf(character2) then
					return
				else
					return true
				end
			end)

			if clone then
				clone.Enabled = false
				_G.PU:Dust(clone, 0.5)
			end

			if sound and sound.Parent then
				TweenService:Create(sound, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()
				_G.PU:Dust(sound, 1)
			end
		elseif mode == "Magnet Z" then
			local effects = workspace.Effects
			local skillZ = ReplicatedStorage.Chest.FruitEffect.Magnet.SkillZ
			local character2 = v2.Character
			local chargeFolder = v2.ChargeFolder
			local rootPart = v2.RootPart
			local skillFolder = v2.SkillFolder
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://12016477422",
				Volume = 5
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = rootPart
			sound:Play()
			local rightLowerArm = character2:FindFirstChild("RightLowerArm")
			local rightHand = character2:FindFirstChild("RightHand")
			local clone, v3

			if rightLowerArm and rightHand then
				clone = skillZ.JikiPistol:Clone()
				clone:PivotTo(rightLowerArm.CFrame)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 15)
				clone.BarrelLow.Particle.Enabled = true
				local motor6D = Instance.new("Motor6D")
				motor6D.Part0 = rightLowerArm
				motor6D.Part1 = clone.MainMotor6D
				motor6D.Parent = clone.MainMotor6D
				_G.PU:Dust(motor6D, 15)
				v3 = _G.PU.PlayOneShotAnim({
					Animator = clone:FindFirstChild("AnimationController"),
					Animation = ReplicatedStorage.Chest.Animation.MagnetMagnet.MagnetZFiring,
					Speed = 1.5
				})
				rightLowerArm.Transparency = 1
				rightHand.Transparency = 1
			end

			local clone2 = skillZ.Step1:Clone()
			clone2.Anchored = true
			clone2.CanCollide = false
			clone2.Transparency = 1
			clone2.CFrame = rootPart.CFrame
			clone2.Parent = effects
			_G.PU:Dust(clone2, 4)
			Utility.EmitParticles(clone2)

			local function MagnetZShoot(child)
				local mouseHit = child:GetAttribute("MouseHit")
				local v4 = (rootPart.Position - mouseHit).Magnitude / 250 * 0.25
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://111847634223825",
					Volume = 1
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = rootPart
				sound2:Play()
				local clone3 = skillZ.Mesh1:Clone()
				clone3.Anchored = true
				clone3.CanCollide = false
				clone3.Transparency = 1
				clone3.CFrame = rootPart.CFrame * CFrame.new(0, 0, -2) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone3.Parent = effects
				TweenService:Create(
					clone3.Mesh,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Scale = createVector(1.5, 1, 1.5)
					}
				):Play()
				TweenService:Create(
					clone3,
					TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone3.CFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
					}
				):Play()
				local decal = clone3.Decal
				decal.Transparency = 0.8
				TweenService:Create(decal, TweenInfo.new(0.8), {
					Transparency = 1
				}):Play()
				local clone4 = skillZ.Mesh1:Clone()
				clone4.Anchored = true
				clone4.CanCollide = false
				clone4.Transparency = 1
				clone4.CFrame = rootPart.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone4.Parent = effects
				TweenService:Create(
					clone4.Mesh,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Scale = createVector(0.5, 0.5, 0.5)
					}
				):Play()
				TweenService:Create(
					clone4,
					TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone4.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
					}
				):Play()
				local decal2 = clone4.Decal
				decal2.Transparency = 0.5
				TweenService:Create(decal2, TweenInfo.new(0.8), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone3, 1.5)
				_G.PU:Dust(clone4, 2)
				local clone5 = skillZ.Step2:Clone()
				clone5.Anchored = true
				clone5.CanCollide = false
				clone5.Transparency = 1
				clone5.CFrame = rootPart.CFrame * CFrame.new(0, 0, -3.8)
				clone5.Parent = effects
				Utility.EmitParticles(clone2)
				local clone6 = skillZ.Step3:Clone()
				clone6.Anchored = true
				clone6.CanCollide = false
				clone6.Transparency = 1
				clone6.CFrame = rootPart.CFrame * CFrame.new(math.random(-3, 3), math.random(-2, 2), -3.5)
				clone6.Parent = effects
				_G.PU:Dust(clone6, 2)
				local cframe = CFrame.new(mouseHit)
				TweenService:Create(clone6, TweenInfo.new(v4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					CFrame = cframe
				}):Play()
				task.delay(v4, function()
					for _, emitter in pairs(clone6:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					local clone7 = skillZ.Exp:Clone()
					clone7.Anchored = true
					clone7.CanCollide = false
					clone7.Transparency = 1
					clone7.CFrame = cframe
					clone7.Parent = effects
					_G.PU:Dust(clone7, 2)
					Utility.EmitParticles(clone7)
					local sound3 = PeoUtils.CreateSound({
						RollOffMaxDistance = 500,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://122815410523410",
						Volume = 3
					})
					_G.PU:Dust(sound3, 3)
					sound3.Parent = clone7
					sound3:Play()
				end)
				_G.PU:Dust(clone5, 2)
			end

			skillFolder.ChildAdded:Connect(function(child)
				MagnetZShoot(child)
			end)
			local v4 = Scheduler.new(3)
			v4:OnStep(function()
				if chargeFolder:IsDescendantOf(character2) then
					clone2.CFrame = rootPart.CFrame
				else
					v4:Destroy()
				end
			end)
			v4:Execute()

			if clone and clone.Parent then
				clone.BarrelLow.Particle.Enabled = false
				_G.PU:Dust(clone, 0.5)

				if rightLowerArm and rightLowerArm.Parent then
					character2.RightLowerArm.Transparency = 0
				end

				if rightHand and rightHand.Parent then
					character2.RightHand.Transparency = 0
				end

				if v3 then
					v3:Stop()
				end
			end

			if clone2 and clone2.Parent then
				Utility.ParticleHandler(clone2, false)
			end
		elseif mode == "Magnet X" then
			local chargeFolder = v2.ChargeFolder
			local character2 = v2.Character
			local rootPart = v2.RootPart
			local skillFolder = v2.SkillFolder
			local effects = workspace.Effects
			local skillX = ReplicatedStorage.Chest.FruitEffect.Magnet.SkillX
			local clone = skillX["Magnet Railgun"]:Clone()
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 25)

			if character2:FindFirstChild("RightUpperArm") and character2:FindFirstChild("RightLowerArm") and character2:FindFirstChild("RightHand") then
				character2.RightUpperArm.Transparency = 1
				character2.RightLowerArm.Transparency = 1
				character2.RightHand.Transparency = 1
			end

			local weld = Instance.new("Weld")
			weld.Part0 = character2.RightUpperArm
			weld.Part1 = clone.MainMotor6D
			weld.Parent = clone.MainMotor6D
			local clone2 = skillX.Step1:Clone()
			clone2.Anchored = true
			clone2.CanCollide = false
			clone2.Transparency = 1
			clone2.CFrame = rootPart.CFrame
			clone2.Parent = effects
			_G.PU:Dust(clone2, 2)
			Utility.EmitParticles(clone2)
			local cframe = CFrame.new(0.7, 0.4, -8)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://124839216596232",
				Volume = 2
			})
			_G.PU:Dust(sound, 4)
			sound.Parent = rootPart
			sound:Play()
			local clone3 = skillX.Mesh1:Clone()
			clone3.Anchored = true
			clone3.CanCollide = false
			clone3.Transparency = 1
			clone3.CFrame = rootPart.CFrame
			clone3.Parent = effects
			_G.PU:Dust(clone3, 2)
			local decal = clone3.Decal
			decal.Transparency = 0
			TweenService:Create(
				clone3.Mesh,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Scale = createVector(3, 2, 3)
				}
			):Play()
			TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone3.CFrame * CFrame.Angles(0, -3.141592653589793, 0)
			}):Play()
			TweenService:Create(decal, TweenInfo.new(0.45), {
				Transparency = 1
			}):Play()
			task.wait(0.1)
			local clone4 = skillX.Step2:Clone()
			_G.PU:Dust(clone4, 15)
			clone4:PivotTo(rootPart.CFrame * cframe)
			clone4.Parent = effects
			task.spawn(function()
				PeodizService.new({
					Time = 0.3,
					WaitTime = 0.01
				}, function(p)
					clone4:ScaleTo(1 + -0.55 * p)
				end)
			end)
			local lastTime = tick()

			local function MagnetXCast(instance)
				if not instance then
					warn("Error Magnet X Cast")
					return
				end

				local mouseHit = instance:GetAttribute("MouseHit")
				local v3 = (rootPart.Position - mouseHit).Magnitude / 1000
				local cframe2 = CFrame.new(rootPart.Position, mouseHit)
				local cframe3 = CFrame.new(mouseHit)
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://117172685105061",
					Volume = 0.5
				})
				_G.PU:Dust(sound2, 4)
				sound2.Parent = rootPart
				sound2:Play()
				local clone5 = skillX.Step3:Clone()
				clone5.Anchored = true
				clone5.CanCollide = false
				clone5.Transparency = 1
				clone5.CFrame = cframe2 * cframe
				clone5.Parent = effects
				_G.PU:Dust(clone5, 2)
				Utility.EmitParticles(clone5)
				task.delay(0.05, function()
					local clone6 = skillX.Step4:Clone()
					local start = clone6.Start.Start
					local v4 = clone6.End.End
					clone6:PivotTo(cframe2 * cframe)
					v4.CFrame = start.CFrame
					clone6.LongPart.Size = createVector(15, 15, 0)
					clone6.LongPart.CFrame = start.CFrame
					clone6.Parent = effects
					task.spawn(function()
						PeodizService.new({
							Time = 0.15
						}, function(p)
							local v5 = 1 + p * 0.5
							clone6.Start:ScaleTo(v5)
							clone6.End:ScaleTo(v5)
						end)
						task.wait(0.8)
						PeodizService.new({
							Time = 0.15
						}, function(p)
							local v5 = math.max(1.5 - p * 1.5, 0.001)
							clone6.Start:ScaleTo(v5)
							clone6.End:ScaleTo(v5)
						end)
					end)
					task.spawn(function()
						PeodizService.ForLoop({
							Step = 12,
							WaitTime = 0.1
						}, function(_)
							if (localPlayer.Character.HumanoidRootPart.Position - cframe2.Position).Magnitude < 250 then
								_G.CameraShake:ShakeOnce(0.5, 10, 0, 0.5)
							end

							local clone7 = skillX.Mesh1:Clone()
							clone7.Anchored = true
							clone7.CanCollide = false
							clone7.Transparency = 1
							clone7.CFrame = cframe2 * CFrame.new(0, 1, -8) * CFrame.Angles(1.5707963267948966, 0, 0)
							clone7.Parent = effects
							TweenService:Create(
								clone7.Mesh,
								TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Scale = createVector(5, 3, 5)
								}
							):Play()
							TweenService:Create(
								clone7,
								TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									CFrame = clone7.CFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
								}
							):Play()
							local decal2 = clone7.Decal
							decal2.Transparency = 0.8
							TweenService:Create(decal2, TweenInfo.new(0.7), {
								Transparency = 1
							}):Play()
							local clone8 = skillX.Mesh1:Clone()
							clone8.Anchored = true
							clone8.CanCollide = false
							clone8.Transparency = 1
							clone8.CFrame = cframe2 * CFrame.new(0, 1, -8) * CFrame.Angles(1.5707963267948966, 0, 0)
							clone8.Parent = effects
							TweenService:Create(
								clone8.Mesh,
								TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Scale = createVector(3, 2, 3)
								}
							):Play()
							TweenService:Create(
								clone8,
								TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									CFrame = clone8.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
								}
							):Play()
							local decal3 = clone8.Decal
							decal3.Transparency = 0.5
							TweenService:Create(decal3, TweenInfo.new(0.7), {
								Transparency = 1
							}):Play()
							_G.PU:Dust(clone7, 1.5)
							_G.PU:Dust(clone8, 2)
						end)
					end)
					local magnitude = (cframe2.Position - cframe3.Position).Magnitude
					TweenService:Create(clone6.LongPart, TweenInfo.new(v3, Enum.EasingStyle.Linear), {
						Size = Vector3.new(clone6.LongPart.Size.X, clone6.LongPart.Size.Y, magnitude),
						CFrame = cframe2 * CFrame.new(0, 0, -magnitude / 2)
					}):Play()
					TweenService:Create(v4, TweenInfo.new(v3, Enum.EasingStyle.Linear), {
						CFrame = cframe3
					}):Play()
					_G.PU:Dust(clone6, 2.2)
					task.delay(v3 + 0.7, function()
						if clone and clone.Parent then
							if character2:FindFirstChild("RightUpperArm") and character2:FindFirstChild("RightLowerArm") and character2:FindFirstChild("RightHand") then
								character2.RightUpperArm.Transparency = 0
								character2.RightLowerArm.Transparency = 0
								character2.RightHand.Transparency = 0
							end

							for _, part in pairs(clone:GetChildren()) do
								if part:IsA("BasePart") then
									TweenService:Create(part, TweenInfo.new(0.5), {
										Transparency = 1
									}):Play()
								end
							end

							_G.PU:Dust(clone, 1)
						end

						Utility.ParticleHandler(clone6.LongPart, false)
						Utility.ParticleHandler(v4, false)

						for _, beam in pairs(clone6:GetDescendants()) do
							if beam:IsA("Beam") then
								TweenService:Create(
									beam,
									TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
									{
										Width0 = 0,
										Width1 = 0
									}
								):Play()
							end
						end

						local clone7 = skillX.Step5:Clone()
						clone7.Anchored = true
						clone7.CanCollide = false
						clone7.Transparency = 1
						clone7.CFrame = cframe3
						clone7.Parent = effects
						Utility.EmitParticles(clone7)
						local clone8 = skillX.ExpMesh:Clone()
						clone8.Anchored = true
						clone8.CanCollide = false
						clone8.Transparency = 1
						clone8.CFrame = cframe3
						clone8.Parent = effects
						TweenService:Create(
							clone8.Mesh,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Scale = createVector(13, 13, 13)
							}
						):Play()
						TweenService:Create(
							clone8,
							TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								CFrame = clone8.CFrame * CFrame.Angles(0, math.rad((math.random(-180, 180))), 0)
							}
						):Play()
						local decal2 = clone8.Decal
						decal2.Transparency = 0.5
						TweenService:Create(decal2, TweenInfo.new(1), {
							Transparency = 1
						}):Play()
						local clone9 = skillX.Glass:Clone()
						clone9.Anchored = true
						clone9.CanCollide = false
						clone9.CFrame = cframe3
						clone9.Parent = effects
						TweenService:Create(
							clone9,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Size = createVector(110, 110, 110)
							}
						):Play()
						local highlight = Instance.new("Highlight")
						highlight.FillTransparency = 1
						highlight.OutlineTransparency = 1
						highlight.Parent = clone9
						_G.PU:Dust({ clone9, highlight }, 0.2)
						_G.PU:Dust(clone8, 2)
						_G.PU:Dust(clone7, 2)
						local sound3 = PeoUtils.CreateSound({
							RollOffMaxDistance = 500,
							RollOffMinDistance = 10,
							RollOffMode = Enum.RollOffMode.InverseTapered,
							SoundId = "rbxassetid://111942411221116",
							Volume = 2
						})
						_G.PU:Dust(sound3, 4)
						sound3.Parent = rootPart
						sound3:Play()
						task.delay(0.2, function()
							local clone10 = skillX.Step6:Clone()
							clone10.Anchored = true
							clone10.CanCollide = false
							clone10.Transparency = 1
							clone10.CFrame = cframe2 * CFrame.new(0, 1, -8)
							clone10.Parent = effects
							_G.PU:Dust(clone10, 2)
							Utility.EmitParticles(clone10)
						end)
					end)
				end)
			end

			PeodizService.HeartbeatWait({
				Time = 10
			}, function()
				if not chargeFolder:IsDescendantOf(character2) then
					return true
				end

				clone4:PivotTo(rootPart.CFrame * cframe)

				if tick() - lastTime > 0.3 then
					lastTime = tick()
					local cFrame = rootPart.CFrame * cframe
					local clone5 = skillX.Glass:Clone()
					clone5.Size = createVector(20, 20, 20)
					clone5.Anchored = true
					clone5.CanCollide = false
					clone5.CFrame = cFrame
					clone5.Parent = effects
					TweenService:Create(
						clone5,
						TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(1, 1, 1)
						}
					):Play()
					local highlight = Instance.new("Highlight")
					highlight.FillTransparency = 1
					highlight.OutlineTransparency = 1
					highlight.Parent = clone5
					local clone6 = skillX.PartTrail:Clone()
					clone6.Anchored = true
					clone6.CanCollide = false
					clone6.Transparency = 1
					clone6.CFrame = cFrame
					clone6.Parent = effects
					local v4 = clone4.Step2Main.CFrame * CFrame.new(0, math.random(-10, 10), 0)
					local v5 = v4 * CFrame.new(math.random(-25, 25), math.random(-20, 20), math.random(-25, 25))
					local v6 = clone4.Step2Main.CFrame * CFrame.new(0, 0, 0)
					local v7 = Bezier.new(v4.Position, v5.Position, v6.Position)
					task.spawn(function()
						PeodizService.ForLoop({
							Step = 20,
							WaitTime = 0.01
						}, function(p)
							local v8 = math.floor(p * 20)
							local v9 = v7:Get(v8 / 20)
							local v10 = v7:Get((v8 + 1) / 20)
							clone6.CFrame = CFrame.new(v9, v10)
						end)
					end)
					local clone7 = skillX.PartTrail2:Clone()
					clone7.Anchored = true
					clone7.CanCollide = false
					clone7.Transparency = 1
					clone7.CFrame = cFrame
					clone7.Parent = effects
					local v8 = clone4.Step2Main.CFrame * CFrame.new(0, math.random(-10, 10), 0)
					local v9 = v8 * CFrame.new(math.random(-25, 25), math.random(-20, 20), math.random(-25, 25))
					local v10 = clone4.Step2Main.CFrame * CFrame.new(0, 0, 0)
					local v11 = Bezier.new(v8.Position, v9.Position, v10.Position)
					task.spawn(function()
						PeodizService.ForLoop({
							Step = 30
						}, function(p)
							local v12 = math.floor(p * 30)
							local v13 = v11:Get(v12 / 30)
							local v14 = v11:Get((v12 + 1) / 30)
							clone7.CFrame = CFrame.new(v13, v14)
						end)
					end)
					_G.PU:Dust(clone7, 0.8)
					_G.PU:Dust(clone6, 0.8)
					_G.PU:Dust({ clone5, highlight }, 0.5)
					_G.PU:Dust(clone4, 1.7)
				end
			end)

			if sound and sound.Parent then
				sound:Destroy()
			end

			if clone4 and clone4.Parent then
				clone4:Destroy()
			end

			MagnetXCast(skillFolder:GetChildren()[1])
		elseif mode == "Magnet C" then
			local effects = workspace.Effects
			local skillC = ReplicatedStorage.Chest.FruitEffect.Magnet.SkillC
			local character2 = v2.Character
			local chargeFolder = v2.ChargeFolder
			local rootPart = v2.RootPart
			local skillFolder = v2.SkillFolder
			local childAddedConnection = nil
			local clone = skillC.Step1:Clone()
			clone.Anchored = true
			clone.CanCollide = false
			clone.Transparency = 1
			clone.CFrame = rootPart.CFrame * CFrame.new(0, -0.5, 0)
			clone.Parent = effects
			_G.PU:Dust(clone, 2)
			Utility.EmitParticles(clone)
			local clone2 = skillC.Glass:Clone()
			clone2.Anchored = true
			clone2.CanCollide = false
			clone2.CFrame = rootPart.CFrame
			clone2.Parent = effects
			TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(1, 1, 1)
			}):Play()
			local highlight = Instance.new("Highlight")
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			highlight.Parent = clone2
			_G.PU:Dust({ clone2, highlight }, 0.15)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://12016535679",
				Volume = 0.5
			})
			_G.PU:Dust(sound, 15)
			sound.Parent = rootPart
			sound:Play()
			local leftUpperArm = character2:FindFirstChild("LeftUpperArm")
			local rightUpperArm = character2:FindFirstChild("RightUpperArm")
			local clone3 = nil
			local motor6D = nil
			local clone4, motor6D2

			if leftUpperArm then
				clone4 = skillC.MagnetLeftArm:Clone()
				clone4.Mesh.Particle.Enabled = true
				clone4:SetPrimaryPartCFrame(character2.LeftUpperArm.CFrame)
				clone4.Parent = effects
				_G.PU:Dust(clone4, 15)
				motor6D2 = Instance.new("Motor6D")
				motor6D2.Part0 = character2.LeftUpperArm
				motor6D2.Part1 = clone4.MainMotor6D
				motor6D2.Parent = clone4.MainMotor6D
				_G.PU:Dust(motor6D2, 15)
			end

			if rightUpperArm then
				clone3 = skillC.MagnetRightArm:Clone()
				clone3.Mesh.Particle.Enabled = true
				clone3:SetPrimaryPartCFrame(character2.RightUpperArm.CFrame)
				clone3.Parent = effects
				_G.PU:Dust(clone3, 15)
				motor6D = Instance.new("Motor6D")
				motor6D.Part0 = character2.RightUpperArm
				motor6D.Part1 = clone3.MainMotor6D
				motor6D.Parent = clone3.MainMotor6D
				_G.PU:Dust(motor6D, 15)
			end

			local function MagnetCCast(child)
				local mouseHit = child:GetAttribute("MouseHit")

				if not mouseHit then
					warn("No MouseHit Attribute Magnet C")
				end

				local v3 = (rootPart.Position - mouseHit).Magnitude / 225
				local cframe = CFrame.new(rootPart.Position, mouseHit)
				local cframe2 = CFrame.new(mouseHit)
				local clone5 = skillC.Step2:Clone()
				clone5.Anchored = true
				clone5.CanCollide = false
				clone5.Transparency = 1
				clone5.CFrame = cframe * CFrame.new(0, 1, -2)
				clone5.Parent = effects
				Utility.EmitParticles(clone5)

				for _, beam in pairs(clone5:GetDescendants()) do
					if beam:IsA("Beam") then
						TweenService:Create(beam, TweenInfo.new(0.5), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end
				end

				_G.PU:Dust(clone5, 2)
				local clone6 = skillC.Glass2:Clone()
				clone6.Anchored = true
				clone6.CanCollide = false
				clone6.CFrame = cframe * CFrame.new(0, 2, 0)
				clone6.Parent = effects
				TweenService:Create(
					clone6,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(30, 30, 30)
					}
				):Play()
				_G.PU:Dust(clone6, 0.15)
				task.spawn(function()
					local clone7 = skillC.Mesh1:Clone()
					clone7.Anchored = true
					clone7.CanCollide = false
					clone7.Transparency = 1
					clone7.CFrame = cframe * CFrame.new(0, 0, -5) * CFrame.Angles(1.5707963267948966, 0, 0)
					clone7.Parent = effects
					TweenService:Create(
						clone7.Mesh,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Scale = createVector(2, 1, 2)
						}
					):Play()
					TweenService:Create(
						clone7,
						TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							CFrame = clone7.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
						}
					):Play()
					local decal = clone7.Decal
					decal.Transparency = 0.5
					TweenService:Create(decal, TweenInfo.new(0.8), {
						Transparency = 1
					}):Play()
					local clone8 = skillC.Mesh2:Clone()
					clone8.Anchored = true
					clone8.CanCollide = false
					clone8.Transparency = 1
					clone8.CFrame = cframe * CFrame.new(0, 0, -2) * CFrame.Angles(1.5707963267948966, 0, 0)
					clone8.Parent = effects
					local decal2 = clone8.Decal
					decal2.Transparency = 0.5
					TweenService:Create(
						clone8.Mesh,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Scale = createVector(3, 1, 3)
						}
					):Play()
					TweenService:Create(
						clone8,
						TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							CFrame = clone8.CFrame * CFrame.Angles(0, -3.141592653589793, 0)
						}
					):Play()
					TweenService:Create(decal2, TweenInfo.new(0.8), {
						Transparency = 1
					}):Play()
					_G.PU:Dust(clone8, 2)
					_G.PU:Dust(clone7, 2)
				end)
				task.delay(0.05, function()
					local clone7 = skillC.Step3:Clone()
					clone7.Anchored = true
					clone7.CanCollide = false
					clone7.Transparency = 1
					clone7.CFrame = cframe
					clone7.Parent = effects
					TweenService:Create(clone7, TweenInfo.new(v3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						CFrame = cframe2
					}):Play()
					task.wait(v3)
					local clone8 = skillC.Step4:Clone()

					for _, emitter in pairs(clone7:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					clone8:PivotTo(clone7.CFrame * CFrame.new(0, 3, 0))
					clone8.Parent = effects
					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 500,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://127134464963698",
						Volume = 3
					})
					_G.PU:Dust(sound2, 3)
					sound2.Parent = rootPart
					sound2:Play()
					local modelCFrame = clone8:GetModelCFrame()
					task.spawn(function()
						PeodizService.new({
							Time = 1,
							WaitTime = 0.01
						}, function(p)
							local v4 = 1 - p

							if v4 <= 0 then
								return true
							end

							clone8:ScaleTo(v4)
						end)
					end)
					PeodizService.ForLoop({
						Step = 8,
						WaitTime = 0.1
					}, function(p)
						if (localPlayer.Character.HumanoidRootPart.Position - modelCFrame.Position).Magnitude < 200 then
							_G.CameraShake:ShakeOnce(0.5, 6, 0, 0.5)
						end

						if math.floor(p * 8) % 2 == 1 then
							local clone9 = skillC.Glass:Clone()
							clone2.Size = createVector(100, 100, 100)
							clone9.Anchored = true
							clone9.CanCollide = false
							clone9.CFrame = modelCFrame
							clone9.Parent = effects
							TweenService:Create(
								clone9,
								TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Size = createVector(1, 1, 1)
								}
							):Play()
							local highlight2 = Instance.new("Highlight")
							highlight2.FillTransparency = 1
							highlight2.OutlineTransparency = 1
							highlight2.Parent = clone9
							_G.PU:Dust({ clone9, highlight2 }, 0.5)
						end

						local clone9 = skillC.PartTrail:Clone()
						clone9.Anchored = true
						clone9.CanCollide = false
						clone9.Transparency = 1
						clone9.CFrame = modelCFrame
						clone9.Parent = effects
						local v4 = clone8.Step4Main.CFrame * CFrame.new(0, 0, 0)
						local v5 = v4 * CFrame.new(math.random(-90, 90), math.random(-45, 60), math.random(-80, 80))
						local v6 = clone8.Step4Main.CFrame * CFrame.new(0, 0, 0)
						local v7 = Bezier.new(v4.Position, v5.Position, v6.Position)
						task.spawn(function()
							PeodizService.ForLoop({
								Step = 35,
								WaitTime = 0.01
							}, function(p2)
								local v8 = math.floor(p2 * 35)
								local v9 = v7:Get(v8 / 35)
								local v10 = v7:Get((v8 + 1) / 35)
								clone9.CFrame = CFrame.new(v9, v10)
							end)
						end)
						_G.PU:Dust(clone9, 0.8)
						_G.PU:Dust(clone8, 2)
					end)
					_G.PU:Dust(clone7, 2)
					task.delay(0.5, function()
						if (localPlayer.Character.HumanoidRootPart.Position - modelCFrame.Position).Magnitude < 200 then
							_G.CameraShake:ShakeOnce(2, 10, 0, 1)
						end

						local clone9 = skillC.Exp:Clone()
						clone9.Anchored = true
						clone9.CanCollide = false
						clone9.Transparency = 1
						clone9.CFrame = modelCFrame
						clone9.Parent = effects
						_G.PU:Dust(clone9, 2)
						Utility.EmitParticles(clone9)
						local sound3 = PeoUtils.CreateSound({
							RollOffMaxDistance = 500,
							RollOffMinDistance = 50,
							RollOffMode = Enum.RollOffMode.InverseTapered,
							SoundId = "rbxassetid://94138291252305",
							Volume = 3
						})
						_G.PU:Dust(sound3, 3)
						sound3.Parent = clone9
						sound3:Play()
						local parts = {}

						for _, part in pairs(ReplicatedStorage.Chest.FruitEffect.Magnet.PartLibrary:GetChildren()) do
							if part:IsA("BasePart") then
								table.insert(parts, part)
							end
						end

						PeodizService.ForLoop({
							Step = 5
						}, function(_)
							local clone10 = parts[math.random(1, #parts)]:Clone()

							for _, child2 in pairs(skillC.PartDrop:GetChildren()) do
								local clone = child2:Clone()
								clone.Parent = clone10
							end

							local attachmentT0 = clone10:FindFirstChild("AttachmentT0")
							local attachmentT1 = clone10:FindFirstChild("AttachmentT1")

							if attachmentT0 and attachmentT1 then
								if attachmentT0:FindFirstChild("Trail1") then
									attachmentT0.Trail1.Attachment1 = attachmentT1
								end

								if attachmentT0:FindFirstChild("Trail2") then
									attachmentT0.Trail2.Attachment1 = attachmentT1
								end
							end

							clone10.Anchored = false
							clone10.CanCollide = true
							clone10.CollisionGroup = "Effect"
							clone10.Transparency = 0
							clone10.Size *= math.random(20, 30) / 10
							clone10.CFrame = modelCFrame
							clone10.Parent = effects
							task.spawn(function()
								task.wait(2.5)

								for _, effect in pairs(clone10:GetDescendants()) do
									if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
										effect.Enabled = false
									end
								end

								TweenService:Create(clone10, TweenInfo.new(0.3), {
									Transparency = 1
								}):Play()
							end)
							local bodyVelocity = Instance.new("BodyVelocity")
							bodyVelocity.Velocity = Vector3.new(
								math.random(-50, 50),
								math.random(10, 70),
								math.random(-50, 50)
							)
							bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
							bodyVelocity.Parent = clone10
							_G.PU:Dust(clone10, 4)
							_G.PU:Dust(bodyVelocity, 0.3)
						end)
					end)
				end)

				if childAddedConnection and childAddedConnection.Connected then
					childAddedConnection:Disconnect()
				end
			end

			childAddedConnection = skillFolder.ChildAdded:Connect(function(child)
				MagnetCCast(child)
			end)
			PeodizService.HeartbeatWait({
				Time = 10
			}, function(_)
				if chargeFolder:IsDescendantOf(character2) then
					return
				else
					return true
				end
			end)

			if clone4 and clone4.Parent then
				clone4:Destroy()
			end

			if clone3 and clone3.Parent then
				clone3:Destroy()
			end

			if motor6D and motor6D.Parent then
				motor6D:Destroy()
			end

			if motor6D2 and motor6D2.Parent then
				motor6D2:Destroy()
			end

			if sound and sound.Parent then
				TweenService:Create(sound, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()
				_G.PU:Dust(sound, 1)
			end
		elseif mode == "Magnet V" then
			local effects = workspace.Effects
			local skillV = ReplicatedStorage.Chest.FruitEffect.Magnet.SkillV
			local character2 = v2.Character
			local chargeFolder = v2.ChargeFolder
			local rootPart = v2.RootPart
			local rightUpperArm = character2:FindFirstChild("RightUpperArm")
			local clone = skillV.Step1:Clone()
			clone.Anchored = true
			clone.CanCollide = false
			clone.Transparency = 1
			clone.CFrame = rootPart.CFrame
			clone.Parent = effects
			_G.PU:Dust(clone, 2)
			Utility.EmitParticles(clone)
			local clone2, motor6D

			if rightUpperArm then
				clone2 = ReplicatedStorage.Chest.FruitEffect.Magnet.SkillC.MagnetRightArm:Clone()
				clone2:ScaleTo(3.5)
				clone2.Mesh.Particle.Enabled = true
				clone2:PivotTo(rightUpperArm.CFrame)
				clone2.Parent = effects
				_G.PU:Dust(clone2, 15)
				motor6D = Instance.new("Motor6D")
				motor6D.Part0 = rightUpperArm
				motor6D.Part1 = clone2.MainMotor6D
				motor6D.Parent = clone2.MainMotor6D
				_G.PU:Dust(motor6D, 15)
			else
				clone2 = nil
				motor6D = nil
			end

			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://12016535679",
				Volume = 0.5,
				Looped = true
			})
			_G.PU:Dust(sound, 15)
			sound.Parent = rootPart
			sound:Play()
			PeodizService.HeartbeatWait({
				Time = 10
			}, function(_)
				if chargeFolder:IsDescendantOf(character2) then
					return
				else
					return true
				end
			end)

			if sound and sound.Parent then
				TweenService:Create(sound, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()
				_G.PU:Dust(sound, 1)
			end

			if clone2 and clone2.Parent and clone2:FindFirstChild("Mesh") and clone2.Mesh:FindFirstChild("Particle") then
				clone2.Mesh.Particle.Enabled = nil
			end

			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://100660874680113",
				Volume = 1.25
			})
			_G.PU:Dust(sound2, 6)
			sound2.Parent = rootPart
			sound2:Play()
			local sound3 = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://94138291252305",
				Volume = 1.25
			})
			_G.PU:Dust(sound3, 3)
			sound3.Parent = rootPart
			sound3:Play()
			task.delay(0.3, function()
				if clone2 and clone2.Parent then
					clone2:Destroy()
					clone2 = nil
				end

				if motor6D and motor6D.Parent then
					motor6D:Destroy()
					motor6D = nil
				end
			end)
			task.wait(0.25)
			local v3 = rootPart.CFrame * CFrame.new(0, 0, -5)
			local cframe = CFrame.new(v3.Position)
			local clone3 = skillV.Exp:Clone()
			clone3.Anchored = true
			clone3.CanCollide = false
			clone3.Transparency = 1
			clone3.CFrame = cframe
			clone3.Parent = effects
			_G.PU:Dust(clone3, 2)
			Utility.EmitParticles(clone3)

			if (localPlayer.Character.HumanoidRootPart.Position - cframe.Position).Magnitude < 200 then
				_G.CameraShake:ShakeOnce(4, 10, 0, 1)
			end

			local ray = Ray.new(clone3.CFrame * CFrame.new(0, 0, -0.5).Position, clone3.CFrame.UpVector * -5)
			local part, v4 = workspace:FindPartOnRayWithWhitelist(ray, { workspace.Island })

			if part and part:IsDescendantOf(workspace.Island) and v4 then
				local clone4 = skillV.Ground_Ray:Clone()
				clone4.Anchored = true
				clone4.CanCollide = false
				clone4.Transparency = 1
				clone4.CFrame = CFrame.new(v4 + Vector3.new(0, clone4.Size.Y / 2, 0)) * CFrame.Angles(
					0,
					math.rad(clone3.Orientation.Y),
					0
				)
				clone4.Parent = effects
				Utility.EmitParticles(clone4)
				task.spawn(function()
					for _, emitter in pairs(clone4:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end

					task.wait(1)

					for _, emitter in pairs(clone4:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)
				_G.PU:Dust(clone4, 2)
			end

			local clone4 = skillV.Mesh1:Clone()
			clone4.Anchored = true
			clone4.CanCollide = false
			clone4.Transparency = 1
			clone4.CFrame = cframe * CFrame.new(0, -1, 0)
			clone4.Parent = effects
			_G.PU:Dust(clone4, 0.8)
			TweenService:Create(
				clone4.Mesh,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Scale = createVector(2, 2, 2)
				}
			):Play()
			TweenService:Create(clone4, TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone4.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			local decal = clone4.Decal
			decal.Transparency = 0.5
			TweenService:Create(decal, TweenInfo.new(0.6), {
				Transparency = 1
			}):Play()
			local clone5 = skillV.Glass:Clone()
			clone5.Anchored = true
			clone5.CanCollide = false
			clone5.CFrame = cframe
			clone5.Parent = effects
			TweenService:Create(clone5, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(45, 45, 45),
				Transparency = 1
			}):Play()
			local highlight = Instance.new("Highlight")
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			highlight.Parent = clone5
			_G.PU:Dust({ clone5, highlight }, 0.2)
			task.spawn(function()
				local parts = {}

				for _, part2 in pairs(ReplicatedStorage.Chest.FruitEffect.Magnet.PartLibrary:GetChildren()) do
					if part2:IsA("BasePart") then
						table.insert(parts, part2)
					end
				end

				PeodizService.ForLoop({
					Step = 5
				}, function(_)
					local clone6 = parts[math.random(1, #parts)]:Clone()

					for _, child in pairs(skillV.PartDrop:GetChildren()) do
						local clone = child:Clone()
						clone.Parent = clone6
					end

					local attachmentT0 = clone6:FindFirstChild("AttachmentT0")
					local attachmentT1 = clone6:FindFirstChild("AttachmentT1")

					if attachmentT0 and attachmentT1 then
						if attachmentT0:FindFirstChild("Trail1") then
							attachmentT0.Trail1.Attachment1 = attachmentT1
						end

						if attachmentT0:FindFirstChild("Trail2") then
							attachmentT0.Trail2.Attachment1 = attachmentT1
						end
					end

					clone6.Anchored = false
					clone6.CanCollide = true
					clone6.CollisionGroup = "Effect"
					clone6.Transparency = 0
					clone6.Size *= math.random(50, 60) / 10
					clone6.CFrame = cframe
					clone6.Parent = effects
					_G.PU:Dust(clone6, 4)
					task.spawn(function()
						task.wait(2.5)

						for _, effect in pairs(clone6:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end

						TweenService:Create(clone6, TweenInfo.new(0.3), {
							Transparency = 1
						}):Play()
					end)
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Velocity = Vector3.new(math.random(-50, 50), math.random(10, 70), math.random(-50, 50))
					bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
					bodyVelocity.Parent = clone6
					_G.PU:Dust(bodyVelocity, 0.3)
				end)
			end)
		elseif mode == "Magnet B" then
			local effects = workspace.Effects
			local skillB = ReplicatedStorage.Chest.FruitEffect.Magnet.SkillB
			local rootPart = v2.RootPart
			local endCF = v2.EndCF
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://107045707082283",
				Volume = 2
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = rootPart
			sound:Play()
			local clone = ReplicatedStorage.Chest.Etc.PartSound:Clone()
			clone.CFrame = endCF
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 6)
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://112917969881416",
				Volume = 2
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone
			sound2:Play()
			local sound3 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://12016669141",
				Volume = 2.5
			})
			_G.PU:Dust(sound3, 5)
			sound3.Parent = clone
			sound3:Play()
			local clone2 = skillB.Step1:Clone()
			clone2.Anchored = true
			clone2.CanCollide = false
			clone2.Transparency = 1
			clone2.CFrame = CFrame.new(rootPart.Position)
			clone2.Parent = effects
			Utility.EmitParticles(clone2)
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.Angles(0, -2.9670597283903604, 0)
			}):Play()

			for _, beam in pairs(clone2:GetDescendants()) do
				if beam:IsA("Beam") then
					TweenService:Create(beam, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end
			end

			local clone3 = skillB.Mesh1:Clone()
			clone3.Anchored = true
			clone3.CanCollide = false
			clone3.Transparency = 1
			clone3.CFrame = CFrame.new(rootPart.Position)
			clone3.Parent = effects
			local decal = clone3.Decal
			decal.Transparency = 0
			TweenService:Create(
				clone3.Mesh,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Scale = createVector(3, 2, 3)
				}
			):Play()
			TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone3.CFrame * CFrame.Angles(0, -3.141592653589793, 0)
			}):Play()
			TweenService:Create(decal, TweenInfo.new(0.45), {
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone3, 2)
			_G.PU:Dust(clone2, 2)
			task.delay(0.15, function()
				local position = rootPart.Position
				local parts = {}

				for _, part in pairs(ReplicatedStorage.Chest.FruitEffect.Magnet.PartLibrary:GetChildren()) do
					if part:IsA("BasePart") then
						table.insert(parts, part)
					end
				end

				local clones = {}
				PeodizService.ForceForLoop({
					Step = 10,
					WaitTime = 0.1
				}, function(_)
					local v3 = CFrame.new(endCF.p) * CFrame.Angles(
						math.rad((math.random(-45, 45))),
						0,
						(math.rad((math.random(-45, 45))))
					)
					local cframe = CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					local v4 = math.random(10, 20) / 10
					local clone4 = parts[math.random(1, #parts)]:Clone()
					clone4.Size = Vector3.new(math.random(10, 15), math.random(10, 15), math.random(10, 15))
					clone4.Anchored = true
					clone4.CanCollide = false
					clone4.Size *= v4
					clone4.CollisionGroup = "Effect"
					clone4.Massless = true
					clone4.Transparency = 0
					clone4.CFrame = CFrame.new(position + Vector3.new(math.random(-40, 40), 0, math.random(-40, 40))) * CFrame.Angles(
						math.rad((math.random(-180, 180))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-180, 180))))
					)
					clone4.Parent = effects
					TweenService:Create(clone4, TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
						CFrame = v3 * CFrame.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10)) * cframe
					}):Play()
					_G.PU:Dust(clone4, 4)
					local clone5 = ReplicatedStorage.Chest.FruitEffect.Magnet.ParticleEmitter1:Clone()
					clone5.Name = "Particle"
					clone5.Rate = 4
					clone5.Parent = clone4
					clone5.Enabled = true
					_G.PU:Dust(clone5, 5)
					table.insert(clones, clone4)
				end)
				task.spawn(function()
					task.wait(0.4)
					local cFrames = {}

					for i = 1, #clones do
						local v3 = clones[i]
						TweenService:Create(v3, TweenInfo.new(1.25, Enum.EasingStyle.Linear), {
							Size = v3.Size / 2
						}):Play()
						table.insert(cFrames, v3.CFrame)
					end

					PeodizService.HeartbeatWait({
						Time = 1.25
					}, function(_)
						for i = 1, #clones do
							local v3 = clones[i]
							local v4 = (math.random() - 0.5) * 5
							local v5 = (math.random() - 0.5) * 5
							local v6 = (math.random() - 0.5) * 5
							v3.CFrame = cFrames[i] * CFrame.new(v4, v5, v6)
						end
					end)
				end)
				task.delay(0.25, function()
					local clone4 = skillB.Step3:Clone()
					clone4:PivotTo(endCF)
					clone4.Parent = effects
					local modelCFrame = clone4:GetModelCFrame()
					task.spawn(function()
						PeodizService.new({
							Time = 1.33,
							WaitTime = 0.03
						}, function(p)
							clone4:ScaleTo(4 + -3.99 * p)
						end)
					end)
					PeodizService.ForLoop({
						Step = 10,
						WaitTime = 0.08
					}, function(_)
						local clone5 = skillB.Glass:Clone()
						clone5.Size = createVector(110, 110, 110)
						clone5.Anchored = true
						clone5.CanCollide = false
						clone5.CFrame = modelCFrame
						clone5.Parent = effects
						TweenService:Create(
							clone5,
							TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Size = createVector(1, 1, 1)
							}
						):Play()
						local highlight = Instance.new("Highlight")
						highlight.FillTransparency = 1
						highlight.OutlineTransparency = 1
						highlight.Parent = clone5
						_G.PU:Dust({ clone5, highlight }, 0.5)
						local clone6 = skillB.PartTrail:Clone()
						clone6.Anchored = true
						clone6.CanCollide = false
						clone6.Transparency = 1
						clone6.CFrame = modelCFrame
						clone6.Parent = effects
						local v3 = clone4.Step3Main.CFrame * CFrame.new(0, 0, 0)
						local v4 = v3 * CFrame.new(
							math.random(-120, 120),
							math.random(-100, 100),
							math.random(-120, 120)
						)
						local v5 = clone4.Step3Main.CFrame * CFrame.new(0, 0, 0)
						local v6 = Bezier.new(v3.Position, v4.Position, v5.Position)
						task.spawn(function()
							PeodizService.ForLoop({
								Step = 25,
								WaitTime = 0.01
							}, function(p)
								local v7 = math.floor(p * 25)
								local v8 = v6:Get(v7 / 25)
								local v9 = v6:Get((v7 + 1) / 25)
								clone6.CFrame = CFrame.new(v8, v9)
							end)
						end)
						task.spawn(function()
							local clone7 = skillB.PartTrail2:Clone()
							clone7.Anchored = true
							clone7.CanCollide = false
							clone7.Transparency = 1
							clone7.CFrame = modelCFrame
							clone7.Parent = effects
							local v7 = clone4.Step3Main.CFrame * CFrame.new(0, 0, 0)
							local v8 = v7 * CFrame.new(
								math.random(-100, 100),
								math.random(-80, 80),
								math.random(-100, 100)
							)
							local v9 = clone4.Step3Main.CFrame * CFrame.new(0, 0, 0)
							local v10 = Bezier.new(v7.Position, v8.Position, v9.Position)
							task.spawn(function()
								PeodizService.ForLoop({
									Step = 25,
									WaitTime = 0.01
								}, function(p)
									local v11 = math.floor(p * 25)
									local v12 = v10:Get(v11 / 25)
									local v13 = v10:Get((v11 + 1) / 25)
									clone7.CFrame = CFrame.new(v12, v13)
								end)
								_G.PU:Dust(clone7, 0.6)
							end)
						end)
						_G.PU:Dust(clone6, 0.6)
						_G.PU:Dust(clone4, 2)
					end)
					task.delay(0.8, function()
						if (endCF.Position - currentCamera.CFrame.Position).Magnitude < 300 then
							_G.BeckCameraShake(_G.CameraShakerModule.Presets.Gura1)
							local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
							colorCorrectionEffect.TintColor = Color3.fromRGB(255, 0, 0)
							colorCorrectionEffect.Brightness = -3
							colorCorrectionEffect.Contrast = 1
							colorCorrectionEffect.Saturation = 5
							colorCorrectionEffect.Enabled = true
							colorCorrectionEffect.Parent = game.Lighting
							_G.PU:Dust(colorCorrectionEffect, 0.1)
						end

						local clone5 = ReplicatedStorage.Chest.Etc.PartSound:Clone()
						clone5.CFrame = endCF
						clone5.Parent = workspace.Effects
						_G.PU:Dust(clone5, 6)
						local sound4 = PeoUtils.CreateSound({
							RollOffMaxDistance = 1000,
							RollOffMinDistance = 50,
							RollOffMode = Enum.RollOffMode.InverseTapered,
							SoundId = "rbxassetid://112100938186314",
							Volume = 3
						})
						_G.PU:Dust(sound4, 3)
						sound4.Parent = clone5
						sound4:Play()
						local sound5 = PeoUtils.CreateSound({
							RollOffMaxDistance = 1000,
							RollOffMinDistance = 50,
							RollOffMode = Enum.RollOffMode.InverseTapered,
							SoundId = "rbxassetid://12016540546",
							Volume = 2
						})
						_G.PU:Dust(sound5, 5)
						sound5.Parent = clone5
						sound5:Play()
						local clone6 = skillB.Exp:Clone()
						clone6.Anchored = true
						clone6.CanCollide = false
						clone6.Transparency = 1
						clone6.CFrame = modelCFrame
						clone6.Parent = effects
						Utility.EmitParticles(clone6)
						_G.PU:Dust(clone6, 2)

						for i = 1, #clones do
							local v3 = clones[i]
							local v4 = math.random(1, 5)
							v3.CastShadow = false
							v3.Velocity = Vector3.new(math.random(-75, 75), math.random(100, 125), math.random(-75, 75))
							v3.Anchored = false
							v3.CanCollide = true
							v3.CollisionGroup = "Effect"
							v3.Massless = true
							v3.CFrame = v3.CFrame
							v3.Parent = workspace.Effects
							v3.RotVelocity = Vector3.new(
								math.random(-v4, v4),
								math.random(-v4, v4),
								math.random(-v4, v4)
							)
							_G.PU:Dust(v3, 4)
							task.delay(3.5, function()
								TweenService:Create(v3, TweenInfo.new(0.3), {
									Transparency = 1
								}):Play()
							end)
						end
					end)
				end)
			end)
		elseif mode == "Fiore Gladiator" then
			if (localPlayer.Character.HumanoidRootPart.Position - cFrame2.p).Magnitude < 150 then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
			end

			local rootPart = v2.RootPart
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://9597812848",
				Volume = 2
			})
			_G.PU:Dust(sound, 1)
			sound.Parent = rootPart
			sound:Play()
			local clone = ReplicatedStorage.Chest.Etc.BallMan.slash3:Clone()
			clone.CFrame = cFrame2 * CFrame.Angles(0, 0, 1.5707963267948966)
			clone.Parent = workspace.Effects
			clone.Mesh.Scale = createVector(30, 0.001, 20.391)
			clone.Mesh.Offset = createVector(0, 0, 18.5)
			clone.Attachment.rock.Enabled = true
			clone.Bottom.Transparency = -7
			clone.PointLight.Range = 0
			clone.PointLight.Brightness = 0
			TweenService:Create(
				clone.PointLight,
				TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Range = 20,
					Brightness = 1
				}
			):Play()
			_G.PU:Dust(clone, 3)
			TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone.CFrame * CFrame.new(0, 0, -150)
			}):Play()
			local v3 = {}
			task.spawn(function()
				PeodizService.HeartbeatWait({
					Time = 1,
					Tween = {
						EasingStyle = Enum.EasingStyle.Exponential,
						EasingDirection = Enum.EasingDirection.Out
					}
				}, function(p)
					local v4 = math.floor(p * 10)

					if v3[math.floor(v4)] or math.floor(v4) == 10 then
						return
					end

					v3[math.floor(v4)] = true
					clone.Attachment.Specs:Emit(math.random(3, 5))
					clone.Attachment.shard:Emit(2)
				end)
				task.delay(10, function()
					table.clear(v3)
				end)
			end)
			spawn(function()
				wait(0.25)
				spawn(function()
					wait(0.065)
					clone.Attachment.rock.Enabled = false
				end)
				spawn(function()
					wait(0.1)
					local Animate = require(clone.Animate)
					Animate()
				end)
				TweenService:Create(
					clone.Bottom,
					TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
				wait(0.125)
				TweenService:Create(
					clone.PointLight,
					TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Brightness = 0,
						Range = 20
					}
				):Play()
				wait(0.2)
				task.spawn(function()
					PeodizService.HeartbeatWait({
						Time = 0.5,
						Tween = {
							EasingStyle = Enum.EasingStyle.Exponential,
							EasingDirection = Enum.EasingDirection.Out
						}
					}, function(p)
						local v4 = math.floor(p * 1)
						clone.Trail.Transparency = NumberSequence.new(v4)
					end)
				end)
			end)
		elseif mode == "Magnet Hold" then
			task.spawn(function()
				local magnetLeftArm = v2.MagnetLeftArm
				local magnetRightArm = v2.MagnetRightArm

				if magnetLeftArm then
					for _, part in pairs(magnetLeftArm:GetChildren()) do
						if not (part:IsA("BasePart") and part.Name ~= "MainMotor6D" and part.Name ~= "RootPart") then
							continue
						end

						part.Transparency = 1
						TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
							Transparency = 0
						}):Play()
					end
				end

				if magnetRightArm then
					for _, part in pairs(magnetRightArm:GetChildren()) do
						if not (part:IsA("BasePart") and part.Name ~= "MainMotor6D" and part.Name ~= "RootPart") then
							continue
						end

						part.Transparency = 1
						TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
							Transparency = 0
						}):Play()
					end
				end
			end)
			local rootPart = v2.RootPart
			tick()
			local devide = v2.Devide or 1
			task.spawn(function()
				local chargeFolder = v2.ChargeFolder
				local character2 = v2.Character

				if chargeFolder and character2 then
					local clone = ReplicatedStorage.Chest.SwordEffect["Authentic Triple Katana"].Part1203.Attachment2:Clone()

					for _, emitter in pairs(clone:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						_G.ParticleSize(emitter, 2)
						emitter.Enabled = true
					end

					clone.Parent = rootPart
					_G.PU:Dust(clone, 10)
					PeodizService.HeartbeatWait({
						Time = 10,
						WaitTime = 0.05
					}, function()
						if chargeFolder:IsDescendantOf(character2) then
							return
						else
							return true
						end
					end)

					if clone then
						for _, emitter in pairs(clone:GetChildren()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						_G.PU:Dust(clone, 1)
					end
				end
			end)
			task.spawn(function()
				PeodizService.HeartbeatWait({
					Time = 0.25
				}, function()
					local cFrame = rootPart.CFrame
					local clone = v2.Slash:Clone()
					clone.Mesh.Scale = createVector(150, 4, 150) / devide
					clone.Decal.Color3 = Color3.fromRGB(555, 0, 0)
					clone.Decal.Transparency = -1
					clone.CFrame = cFrame * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					clone.Parent = workspace.Effects
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
					}):Play()
					TweenService:Create(clone.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Scale = createVector(0, 0.125, 0)
					}):Play()
					_G.PU:Dust(clone, 0.5)
				end)
			end)
		elseif mode == "Race Evolved V2" then
			local rootPart = v2.RootPart
			local cFrame = rootPart.CFrame
			local raceType = v2.RaceType
			local color = Color3.fromRGB(255, 255, 255)

			if raceType == "Fish" or raceType == "Sea Beast" then
				color = Color3.fromRGB(98, 145, 255)
			elseif raceType == "Sky" then
				color = Color3.fromRGB(255, 170, 0)
			elseif raceType == "Human" then
				color = Color3.fromRGB(255, 0, 0)
			elseif raceType == "Mink" then
				color = Color3.fromRGB(0, 255, 255)
			end

			PeodizService.ForLoop({
				Step = 3,
				WaitTime = 0.5
			}, function(p)
				local v3 = math.floor(p * 3)
				local clone = ReplicatedStorage.Chest.Etc.Part25:Clone()
				clone.Anchored = false
				clone.CFrame = cFrame
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 2)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://9115798750",
					Volume = 1
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()
				local weld = Instance.new("Weld")
				weld.Part0 = rootPart
				weld.Part1 = clone
				weld.C0 = CFrame.new(0, -2, 0)
				weld.Parent = clone
				_G.PU:Dust(weld, 3)

				for _, emitter in pairs(clone:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					_G.ParticleSize(emitter, v3)
					emitter.Color = ColorSequence.new(color)
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end)
		elseif mode == "Passive Evolved" then
			local rootPart = v2.RootPart
			local cFrame = rootPart.CFrame
			local color = Color3.fromRGB(0, 170, 255)
			PeodizService.ForLoop({
				Step = 3,
				WaitTime = 0.5
			}, function(p)
				local v3 = math.floor(p * 3)
				local clone = ReplicatedStorage.Chest.Etc.Part25:Clone()
				clone.Anchored = false
				clone.CFrame = cFrame
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 2)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://9115798750",
					Volume = 1
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()
				local weld = Instance.new("Weld")
				weld.Part0 = rootPart
				weld.Part1 = clone
				weld.C0 = CFrame.new(0, -2, 0)
				weld.Parent = clone
				_G.PU:Dust(weld, 3)

				for _, emitter in pairs(clone:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					_G.ParticleSize(emitter, v3)
					emitter.Color = ColorSequence.new(color)
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end)
		elseif mode == "Flame Z Cast" then
			local startCF = v2.StartCF
			local clone = ReplicatedStorage.Chest.FruitEffect.FlameNew.FlameCastZ:Clone()
			clone.CFrame = startCF * CFrame.new(0, 0, -2)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 2)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://12276928842",
				Volume = 2
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()

			for _, emitter in pairs(clone.Attachment:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		elseif mode == "Flame Z Ex" then
			local startCF = v2.StartCF
			task.spawn(function()
				if (startCF.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 150 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
				end
			end)
			local clone = ReplicatedStorage.Chest.FruitEffect.FlameNew["Flame Fist Explosion"]:Clone()
			clone.CFrame = startCF
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 1.5)
			task.spawn(function()
				local v3 = {
					RollOffMaxDistance = 500,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://12276907916",
					Volume = 1.5
				}
				local sound = PeoUtils.CreateSound(v3)
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()
			end)

			for _, emitter in pairs(clone:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		elseif mode == "Flame X" then
			local startCF = v2.StartCF
			task.spawn(function()
				if (startCF.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 150 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
				end
			end)
			spawn(function()
				local clone = ReplicatedStorage.Chest.FruitEffect.FlameNew.FlamePillar:Clone()
				clone.CFrame = startCF
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 3)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://13175699313",
					Volume = 3
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()

				for _, descendant in pairs(clone:GetDescendants()) do
					if descendant:IsA("Beam") then
						descendant.Enabled = true
						TweenService:Create(descendant, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
							Width0 = 30,
							Width1 = 25
						}):Play()
					elseif descendant:IsA("ParticleEmitter") then
						descendant.Enabled = true
					elseif descendant:IsA("Attachment") and descendant.Name == "Sky" then
						TweenService:Create(descendant, TweenInfo.new(0.5), {
							Position = createVector(0, 100, 0)
						}):Play()
					end
				end

				spawn(function()
					wait(1)

					for _, effect in pairs(clone:GetDescendants()) do
						if effect:IsA("Beam") then
							effect.Enabled = true
							TweenService:Create(effect, TweenInfo.new(0.5), {
								Width0 = 0,
								Width1 = 0
							}):Play()
						elseif effect:IsA("ParticleEmitter") then
							effect.Enabled = false
						end
					end
				end)
				local clone2 = ReplicatedStorage.Chest.FruitEffect.FlameNew.Shockwave:Clone()
				clone2.Color = Color3.fromRGB(255, 85, 0)
				clone2.CFrame = startCF * CFrame.new(0, 5, 0) * CFrame.Angles(-1.5707963267948966, 0, 0)
				clone2.Parent = workspace.Effects
				TweenService:Create(clone2, TweenInfo.new(0.5), {
					Position = clone2.Position + createVector(0, 90, 0),
					Size = createVector(110, 110, 20)
				}):Play()
				_G.PU:Dust(clone2, 2)
				spawn(function()
					wait(1)
					TweenService:Create(clone2, TweenInfo.new(0.25), {
						Transparency = 1
					}):Play()
				end)
				spawn(function()
					PeodizService.HeartbeatWait({
						Time = 10,
						WaitTime = 0.05
					}, function()
						if not clone2:IsDescendantOf(workspace.Effects) then
							return true
						end

						TweenService:Create(clone2, TweenInfo.new(0.1), {
							CFrame = clone2.CFrame * CFrame.Angles(0, 0, 3.141592653589793)
						}):Play()
					end)
				end)
				spawn(function()
					PeodizService.ForLoop({
						Step = 10,
						WaitTime = 0.1
					}, function(_)
						local clone3 = ReplicatedStorage.Chest.FruitEffect.FlameNew.Shockwave:Clone()
						clone3.Color = Color3.fromRGB(255, 85, 0)
						clone3.CFrame = startCF * CFrame.new(0, 10, 0) * CFrame.Angles(
							1.5707963267948966,
							0,
							6.283185307179586 * math.random()
						)
						clone3.Parent = workspace.Effects
						TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
							Size = createVector(165, 165, 30),
							Transparency = 1
						}):Play()
						_G.PU:Dust(clone3, 0.5)
					end)
				end)
			end)
		elseif mode == "Flame C" then
			local start = v2.Start
			local _ = v2.End
			local mag = v2.Mag
			local lookAt = v2.LookAt
			local howLong = v2.HowLong or 75
			local _ = v2.RootPart
			local clone = ReplicatedStorage.Chest.FruitEffect.Dragon.BallBullet:Clone()
			clone.Anchored = true
			clone.Trail.Enabled = false
			clone.Color = Color3.fromRGB(0, 255, 0)
			clone.Attachment0.Position = createVector(0, -0.5, 0)
			clone.Attachment1.Position = createVector(0, 0.5, 0)
			clone.Size = createVector(1, 1, 1)
			clone.CFrame = start.CFrame * CFrame.new(0, 0, -3)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 2)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://12289550774",
				Volume = 0.7
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()
			TweenService:Create(clone, TweenInfo.new(1.2, Enum.EasingStyle.Linear), {
				Color = Color3.fromRGB(255, 85, 0)
			}):Play()
			spawn(function()
				local step = howLong
				PeodizService.ForLoop({
					Step = step
				}, function(p)
					local cframe = CFrame.new(0, math.sin(3.141592653589793 * p) * step, -(p * step) * mag)
					clone.CFrame = CFrame.new((lookAt * cframe).p, clone.Position) * CFrame.Angles(
						0,
						3.141592653589793,
						0
					)
				end)
				clone.Transparency = 1
				local cFrame = clone.CFrame
				local clone2 = ReplicatedStorage.Chest.FruitEffect.FlameNew["Flame Bullet Explosion"]:Clone()
				clone2.CFrame = cFrame
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 1.5)
				local v4 = {
					RollOffMaxDistance = 500,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://12289551570",
					Volume = 1.5
				}
				local sound2 = PeoUtils.CreateSound(v4)
				_G.PU:Dust(sound2, 1.5)
				sound2.Parent = clone2
				sound2:Play()

				for _, emitter in pairs(clone2:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					_G.ParticleSize(emitter, 0.25)
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end)
		elseif mode == "Flame V" then
			local clone = ReplicatedStorage.Chest.FruitEffect.FlameNew.FlameBall:Clone()
			_G.PU:Dust(clone, 10)
			clone.Size = createVector(75, 75, 75)
			clone.CFrame = cFrame2
			clone.Parent = workspace.Effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://12325216969",
				Volume = 6
			})
			_G.PU:Dust(sound, 10)
			sound.Parent = clone
			sound:Play()
			TweenService:Create(clone, TweenInfo.new(1.5), {
				Size = createVector(125, 125, 125)
			}):Play()
			clone.Attachment0.Par1.Enabled = true
			clone.Attachment0.Par2.Enabled = true
			local clone2 = ReplicatedStorage.Chest.FruitEffect.FlameNew.FlameBall2:Clone()
			clone2.Size = createVector(76, 76, 76)
			clone2.CFrame = cFrame2
			clone2.Color = Color3.fromRGB(255, 0, 0)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(3), {
				Orientation = createVector(0, 1800, 0)
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(1.35), {
				Size = createVector(126.6, 126.6, 126.6)
			}):Play()
			_G.PU:Dust(clone2, 10)
			local clone3 = ReplicatedStorage.Chest.FruitEffect.FlameNew.Fire:Clone()
			clone3.Par1.Enabled = true
			clone3.Par2.Enabled = true
			clone3.CFrame = CFrame.new(cFrame2.p)
			clone3.Parent = workspace.Effects
			_G.PU:Dust(clone3, 3)
			delay(2, function()
				clone3.Par1.Enabled = false
				clone3.Par2.Enabled = false
			end)
			spawn(function()
				PeodizService.ForLoop({
					Step = 22
				}, function(_)
					local cFrame = clone.CFrame * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					local v4 = math.random(75, 125)
					local v5 = math.random(100, 150)
					local clone4 = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
					clone4.CastShadow = false
					clone4.Transparency = -1
					clone4.Size = Vector3.new(25, 25, v4)
					clone4.Color = Color3.fromRGB(213, 115, 61)
					clone4.CFrame = cFrame
					clone4.Parent = workspace.Effects
					TweenService:Create(clone4, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Size = Vector3.new(0, 0, v4),
						CFrame = cFrame * CFrame.new(0, 0, v5)
					}):Play()
					spawn(function()
						wait(0.15)
						TweenService:Create(
							clone4,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end)
					_G.PU:Dust(clone4, 1)
				end)
			end)
			spawn(function()
				wait(0.1)
				local v3 = CFrame.new(cFrame2.p) + createVector(0, 25, 0)

				for i = 1, 15 do
					local cframe = v3 * CFrame.Angles(0, 6.283185307179586 * i / 15, 0) * CFrame.new(0, 0, -62.5)
					local _, v4, _ = cframe:ToOrientation()
					local ray = Ray.new(cframe.Position, createVector(0, -100, 0))
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = {
						workspace.Effects,
						workspace.PlayerCharacters,
						workspace.CharacterWorkshop
					}
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
					local instance

					if raycastResult then
						instance = raycastResult.Instance or nil
					end

					local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

					if not instance then
						continue
					end

					local part = Instance.new("Part")
					part.CanCollide = false
					part.CastShadow = false
					part.Anchored = true
					part.Size = createVector(1, 1, 1)
					part.Material = instance.Material
					part.MaterialVariant = instance.MaterialVariant
					part.Color = instance.Color
					part.CFrame = CFrame.new(v3.X, position.Y, v3.Z)
					part.Parent = workspace.Effects
					_G.PU:Dust(part, 3)
					local v5 = math.random(85, 115) / 10
					TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v4, 0) * CFrame.Angles(
							0.7853981633974483,
							0,
							0
						),
						Size = Vector3.new(v5 * 3, v5, v5)
					}):Play()
					spawn(function()
						wait(2)
						TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
							Position = part.Position + createVector(0, -5, 0),
							Transparency = 1
						}):Play()
					end)
				end
			end)
			PeodizService.ForLoop({
				Step = 15
			}, function(_)
				local attachment = Instance.new("Attachment", clone)
				attachment.Position = createVector(0, 0, 0)
				local clone4 = ReplicatedStorage.Chest.FruitEffect.FlameNew.FlameBeam:Clone()
				clone4.Parent = clone
				clone4.Attachment0 = attachment
				clone4.Width0 = math.random(60, 100)
				clone4.Attachment1 = clone.Attachment0
				local cframe = CFrame.new(0, 0, -math.random(50, 90))
				TweenService:Create(attachment, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					WorldPosition = clone.CFrame * CFrame.Angles(
						math.rad((math.random(1, 360))),
						math.rad((math.random(1, 360))),
						(math.rad((math.random(1, 360))))
					) * CFrame.new(0, 0, -150) * cframe.p
				}):Play()
				TweenService:Create(clone4, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Width0 = 0
				}):Play()
				_G.PU:Dust(attachment, 1)
				_G.PU:Dust(clone4, 1)
			end)
			delay(1, function()
				clone.Attachment0.Par1.Enabled = false
				clone.Attachment0.Par2.Enabled = false
				TweenService:Create(clone, TweenInfo.new(1), {
					Size = Vector3.new()
				}):Play()
				TweenService:Create(clone2, TweenInfo.new(1), {
					Size = Vector3.new()
				}):Play()
				_G.PU:Dust(clone2, 1)
				_G.PU:Dust(clone, 1)
			end)
		elseif mode == "Flame V Hold" then
			local chargeFolder = v2.ChargeFolder
			local ball = v2.Ball
			local ball2 = v2.Ball2
			local rootPart = v2.RootPart

			if character:IsDescendantOf(Players) then
				character = character.Character
			end

			spawn(function()
				PeodizService.new({
					Time = 10
				}, function()
					if not ball2:IsDescendantOf(workspace.Effects) then
						return true
					end

					ball2.CFrame *= CFrame.Angles(0, 0.1, 0)
				end)
			end)
			spawn(function()
				local clone = ReplicatedStorage.Chest.FruitEffect.FlameNew.ChargeVFX2:Clone()
				clone.CFrame = CFrame.new(rootPart.Position) * CFrame.new(0, -2.5, 0)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 25)
				spawn(function()
					for _, emitter in pairs(clone.Attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end
				end)
				PeodizService.HeartbeatWait({
					Time = 15,
					WaitTime = 0.05
				}, function()
					if not chargeFolder:IsDescendantOf(character) then
						return true
					end

					clone.CFrame = CFrame.new(rootPart.Position) * CFrame.new(0, -2.5, 0)
					local cFrame = CFrame.new(ball.Position) * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					local v4 = math.random(60, 80)
					local v5 = math.random(100, 150)
					local clone2 = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
					clone2.CastShadow = false
					clone2.Transparency = -1
					clone2.Size = Vector3.new(10, 10, math.random(60, 80))
					clone2.Color = Color3.fromRGB(213, 115, 61)
					clone2.CFrame = cFrame * CFrame.new(0, 0, v5)
					clone2.Parent = workspace.Effects
					TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Size = Vector3.new(0, 0, v4),
						CFrame = cFrame
					}):Play()
					spawn(function()
						wait(0.15)
						TweenService:Create(
							clone2,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end)
					_G.PU:Dust(clone2, 1)
				end)
				spawn(function()
					for _, emitter in pairs(clone.Attachment:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					_G.PU:Dust(clone, 1.5)
				end)
			end)
		elseif mode == "Snow Z Explosion" then
			local startCF = v2.StartCF
			task.spawn(function()
				if (startCF.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 150 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
				end
			end)
			spawn(function()
				local clone = ReplicatedStorage.Chest.FruitEffect.Snow.SnowEx:Clone()
				clone.CFrame = CFrame.new(startCF.p)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 2)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://12464407705",
					Volume = 1
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()

				for _, emitter in pairs(clone.Attachment:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)
			spawn(function()
				local v3 = CFrame.new(startCF.p) * CFrame.new(0, 25, 0)
				local ray = Ray.new(v3.p, createVector(0, -50, 0))
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
				local instance

				if raycastResult then
					instance = raycastResult.Instance or nil
				end

				local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
				local normal

				if raycastResult then
					normal = raycastResult.Normal or nil
				end

				local _ = raycastResult and raycastResult.Material

				if instance then
					local clone = ReplicatedStorage.Chest.SwordEffect.MiniMace.Crack:Clone()
					clone.Decal.Transparency = 0
					clone.Decal.ZIndex = 1
					clone.Decal.Texture = "rbxassetid://12270872092"
					clone.Decal.Color3 = Color3.fromRGB(255, 255, 255)
					clone.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
						0,
						6.283185307179586 * math.random(),
						0
					)
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 1)
					TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
						Size = createVector(40, 0, 40)
					}):Play()
					task.spawn(function()
						wait(0.1)
						TweenService:Create(clone.Decal, TweenInfo.new(0.25), {
							Transparency = 1
						}):Play()
					end)
				end
			end)
		elseif mode == "Snow X" then
			local startCF = v2.StartCF
			local particleSize = v2.ParticleSize
			spawn(function()
				local clone = ReplicatedStorage.Chest.FruitEffect.Snow.SnowEx2:Clone()
				clone.CFrame = CFrame.new(startCF.p)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 2)

				for _, emitter in pairs(clone.Attachment:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					_G.ParticleSize(emitter, particleSize)
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end)
		elseif mode == "Snow X Ex" then
			local startCF = v2.StartCF
			local particleSize = v2.ParticleSize
			spawn(function()
				local clone = ReplicatedStorage.Chest.FruitEffect.Snow.SnowEx2:Clone()
				clone.CFrame = CFrame.new(startCF.p)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 0.85)

				for _, emitter in pairs(clone.Attachment:GetChildren()) do
					if not (emitter:IsA("ParticleEmitter") and emitter.Name ~= "Spec") then
						continue
					end

					_G.ParticleSize(emitter, particleSize)
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end)
		elseif mode == "Snow C" then
			local startCF = v2.StartCF
			task.spawn(function()
				if (startCF.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 150 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
				end
			end)
			spawn(function()
				local clone = ReplicatedStorage.Chest.FruitEffect.Snow.TornadoNew:Clone()
				_G.PU:Dust(clone, 2)
				clone.CFrame = CFrame.new(startCF.p) * CFrame.new(0, 30, 0)
				clone.Parent = workspace.Effects
				TweenService:Create(clone, TweenInfo.new(3), {
					Orientation = createVector(0, -2880, 0)
				}):Play()

				for _, beam in pairs(clone:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					local v3 = beam
					spawn(function()
						local v4 = 1

						for i = 1, 10 do
							v4 -= 0.1
							v3.Transparency = NumberSequence.new(v4)
							wait()
						end
					end)
				end

				delay(1, function()
					for _, beam in pairs(clone:GetDescendants()) do
						if not beam:IsA("Beam") then
							continue
						end

						local v3 = beam
						spawn(function()
							for i = 1, 10 do
								v3.Transparency = NumberSequence.new(i / 10)
								wait()
							end
						end)
					end
				end)
			end)
			spawn(function()
				local clone = ReplicatedStorage.Chest.FruitEffect.Snow.TornadoFloor:Clone()
				clone.CFrame = startCF
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 3.5)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://12464412736",
					Volume = 2
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()

				for _, effect in pairs(clone:GetDescendants()) do
					if effect:IsA("Beam") then
						local v3 = effect
						spawn(function()
							local v4 = 1
							PeodizService.ForLoop({
								Step = 10,
								WaitTime = 0.03
							}, function(p)
								v4 -= 0.1
								v3.Transparency = NumberSequence.new(v4)
							end)
						end)
					elseif effect:IsA("ParticleEmitter") then
						effect.Enabled = true
					end
				end

				delay(1, function()
					for _, effect in pairs(clone:GetDescendants()) do
						if effect:IsA("Beam") then
							local v3 = effect
							spawn(function()
								PeodizService.ForLoop({
									Step = 10,
									WaitTime = 0.03
								}, function(p)
									local v4 = math.floor(p * 10)
									v3.Transparency = NumberSequence.new(v4 / 10)
								end)
							end)
						elseif effect:IsA("ParticleEmitter") then
							effect.Enabled = false
						end
					end
				end)
			end)
		elseif mode == "Snow V" then
			local startCF = v2.StartCF
			local clone = ReplicatedStorage.Chest.FruitEffect.Snow.SnowRain:Clone()
			clone.Size = createVector(300, 0.1, 300)
			clone.Attachment.rings.Rate = 25
			spawn(function()
				for _, emitter in pairs(clone:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Rate = 500
					end
				end
			end)
			clone.CFrame = startCF * CFrame.new(0, 150, 0)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 6)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://13261881377",
				Volume = 4
			})
			_G.PU:Dust(sound, 10)
			sound.Parent = clone
			sound:Play()
			spawn(function()
				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				delay(4, function()
					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)
			end)
			spawn(function()
				PeodizService.ForLoop({
					Step = 10
				}, function(_)
					local v3 = math.random(200, 300)
					local clone2 = ReplicatedStorage.Chest.FruitEffect.Snow.SnowCloud:Clone()
					clone2.CFrame = startCF * CFrame.new(
						math.random(-125, 125),
						math.random(140, 170),
						math.random(-125, 125)
					) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
					clone2.Parent = workspace.Effects
					_G.PU:Dust(clone2, 6)
					TweenService:Create(clone2, TweenInfo.new(1), {
						Size = Vector3.new(v3, math.random(20, 100), v3)
					}):Play()
					delay(4, function()
						TweenService:Create(clone2, TweenInfo.new(0.5), {
							Transparency = 1,
							Size = clone2.Size / 2
						}):Play()
					end)
				end)
			end)
			spawn(function()
				wait(0.5)
				PeodizService.ForLoop({
					Step = 15,
					WaitTime = 0.1
				}, function(_)
					for _ = 1, 3 do
						local ray = Ray.new(
							(startCF * CFrame.new(math.random(-160, 160), 0, math.random(-160, 160))).p,
							createVector(0, -300, 0)
						)
						local raycastParams = RaycastParams.new()
						raycastParams.FilterDescendantsInstances = { workspace.Island }
						raycastParams.FilterType = Enum.RaycastFilterType.Include
						local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
						local instance

						if raycastResult then
							instance = raycastResult.Instance or nil
						end

						local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

						if not instance then
							continue
						end

						local part = Instance.new("Part")
						part.Material = "SmoothPlastic"
						part.Color = Color3.fromRGB(231, 231, 236)
						part.CanCollide = false
						part.Anchored = true
						part.CastShadow = false
						part.Massless = true
						part.CFrame = CFrame.new(position)
						part.Size = Vector3.new(math.rad(15, 40), 1, (math.rad(25, 40)))
						part.Orientation = Vector3.new(0, math.random(-360, 360), 0)
						part.Parent = workspace.Effects
						_G.PU:Dust(part, 5)
						TweenService:Create(part, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
							Size = Vector3.new(75, math.random(10, 100) / 100, 75)
						}):Play()
						delay(4, function()
							TweenService:Create(part, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
								Transparency = 1,
								Size = part.Size / 2
							}):Play()
						end)
					end
				end)
			end)
		elseif mode == "Snow E" then
			local startCF = v2.StartCF
			local endCF = v2.EndCF
			local p = startCF.p
			local p2 = endCF.p
			spawn(function()
				local clone = ReplicatedStorage.Chest.FruitEffect.Snow.SnowEx2:Clone()
				clone.CFrame = CFrame.new(startCF.p)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 2)
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Snow.SnowEx2:Clone()
				clone2.CFrame = CFrame.new(endCF.p)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 2)

				for _, emitter in pairs(clone.Attachment:GetChildren()) do
					if not (emitter:IsA("ParticleEmitter") and emitter.Name ~= "squashshard") then
						continue
					end

					_G.ParticleSize(emitter, 0.1)
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end

				for _, emitter in pairs(clone2.Attachment:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					_G.ParticleSize(emitter, 0.3)
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end)
			spawn(function()
				local v3 = {}

				for i = 1, 10 do
					local vector2 = Vector3.new(math.random(-7, 7), math.random(1, 7), math.random(-7, 7))
					local v4 = p + (p2 - p).Unit * i * (p2 - p).Magnitude / 10
					local v5 = (i == 0 or i == 10) and createVector(0, 0, 0) or vector2
					v3[#v3 + 1] = v4 + v5
				end

				PeodizService.ForceForLoop({
					Step = #v3
				}, function(p3)
					local v4 = math.floor(p3 * #v3)

					if v3[v4 + 1] ~= nil then
						local part = Instance.new("Part")
						part.Parent = workspace.Effects
						part.Material = "Neon"
						part.Color = Color3.fromRGB(255, 255, 255)
						part.Size = Vector3.new(1, 1, (v3[v4] - v3[v4 + 1]).Magnitude)
						part.Anchored = true
						part.CanCollide = false
						part.CFrame = CFrame.new((v3[v4] + v3[v4 + 1]) / 2, v3[v4 + 1])
						_G.PU:Dust(part, 0.35)
						TweenService:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
							Size = Vector3.new(0, 0, (v3[v4] - v3[v4 + 1]).Magnitude)
						}):Play()
					end
				end)
				task.delay(10, function()
					table.clear(v3)
				end)
			end)
		elseif mode == "Sand Z Ex" then
			local startCF = v2.StartCF
			local clone = ReplicatedStorage.Chest.FruitEffect.Sand["Sand Projectile Explode"]:Clone()
			_G.PU:Dust(clone, 2)
			clone.CFrame = startCF
			clone.Parent = workspace.Effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://13261756719",
				Volume = 0.5
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()

			for _, emitter in pairs(clone.Attachment:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		elseif mode == "Sand V" then
			local startCF = v2.StartCF
			task.spawn(function()
				if (startCF.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 150 then
					_G.BeckCameraShake(_G.CameraShakerModule.Presets.SmallExplosion)
				end
			end)
			local clone = ReplicatedStorage.Chest.FruitEffect.Sand["Tornado P"]:Clone()
			clone.CFrame = startCF
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 3)

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			spawn(function()
				wait(1.25)

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
		elseif mode == "Fix Gas X" then
			local startCF = v2.StartCF
			local character2 = v2.Character
			local magnitude = v2.Magnitude
			local endCF = v2.EndCF
			local mouseValue = v2.MouseValue
			local effects = workspace.Effects
			local clone = ReplicatedStorage.Chest.FruitEffect.Gas.gas_beam:Clone()
			_G.PU:Dust(clone, 3)
			clone.Size = Vector3.new(magnitude, 0, 0)
			clone.CFrame = startCF * CFrame.new(0, 0, -magnitude / 2) * CFrame.Angles(0, 1.5707963267948966, 0)
			clone.Parent = effects
			local lastTime = tick()
			PeodizService.HeartbeatWait({
				Time = 1
			}, function()
				if not clone:IsDescendantOf(effects) then
					return true
				end

				for _, texture in pairs(clone:GetChildren()) do
					if not texture:IsA("Texture") then
						continue
					end

					if texture.Name == "Texture1" then
						texture.OffsetStudsU -= 5
					else
						texture.OffsetStudsU += 5
					end
				end

				startCF = CFrame.new(character2.Head.Position, mouseValue.Value)
				magnitude = math.clamp((character2.Head.Position - mouseValue.Value).Magnitude, 0, 150)
				endCF = CFrame.new(character2.Head.Position, mouseValue.Value) * CFrame.new(0, 0, -magnitude)
				clone.Size = Vector3.new(magnitude, 1.5, 1.5)
				clone.CFrame = startCF * CFrame.new(0, 0, -magnitude / 2) * CFrame.Angles(0, 1.5707963267948966, 0)

				if tick() - lastTime > 0.1 then
					lastTime = tick()
					local position = endCF.Position
					local clone2 = ReplicatedStorage.Chest.FruitEffect.Gas.explode_fx:Clone()
					_G.PU:Dust(clone2, 1.5)
					clone2.CFrame = CFrame.new(position)
					clone2.Parent = workspace.Effects

					for _, sound in pairs(clone2:GetChildren()) do
						if sound:IsA("Sound") then
							sound:Play()
						end
					end

					TweenService:Create(clone2.PointLight, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
						Range = 10,
						Brightness = 0
					}):Play()
					PeodizService.ForLoop({
						Step = 1
					}, function(p)
						math.floor(p * 1)
						local v4 = math.random(50, 75)
						local cframe = CFrame.new(endCF.Position)
						local part = Instance.new("Part")
						_G.PU:Dust(part, 1.5)
						part.Shape = "Ball"
						part.Color = Color3.fromRGB(55, 95, 167)
						part.Material = Enum.Material.Neon
						part.Size = createVector(10, 10, 10)
						part.CFrame = cframe
						part.Parent = workspace.Effects
						TweenService:Create(
							part,
							TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Size = Vector3.new(v4, v4, v4)
							}
						):Play()
						task.delay(0.05, function()
							TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
								Color = Color3.fromRGB(),
								Size = createVector(0, 0, 0),
								CFrame = part.CFrame * CFrame.Angles(
									6.283185307179586 * math.random(),
									6.283185307179586 * math.random(),
									6.283185307179586 * math.random()
								) * CFrame.new(0, 0, math.random(20, 25))
							}):Play()
						end)
						local clone3 = ReplicatedStorage.Chest.FruitEffect.Gas.Shockowave:Clone()
						_G.PU:Dust(clone3, 1)
						clone3.Anchored = true
						clone3.CanCollide = false
						clone3.Transparency = 0.35
						clone3.Size = Vector3.new()
						clone3.CFrame = CFrame.new(endCF.Position) * CFrame.Angles(
							math.random() * 2 * 3.141592653589793,
							math.random() * 2 * 3.141592653589793,
							math.random() * 2 * 3.141592653589793
						)
						clone3.Parent = workspace.Effects
						TweenService:Create(
							clone3,
							TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Size = createVector(66.149994, 7.34, 66.149994)
							}
						):Play()
						TweenService:Create(
							clone3,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end)
				end
			end)
			clone.blueflame.Enabled = false
			clone.blueflame:Emit(10)
			TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Transparency = 1,
				Size = Vector3.new(magnitude, 0, 0)
			}):Play()

			for _, texture in pairs(clone:GetChildren()) do
				if texture:IsA("Texture") then
					TweenService:Create(texture, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end
			end

			_G.PU:Dust(clone, 1)
		elseif mode == "Rumble Z V2 Hold" then
			local effects = workspace.Effects
			local Z = ReplicatedStorage.Chest.FruitEffect.Rumble.Z
			local rootPart = v2.RootPart
			local character2 = v2.Character
			local chargeFolder = v2.ChargeFolder
			local rightHand = character2:FindFirstChild("RightHand")

			if not rightHand then
				return
			end

			local clone = Z["Rumble Trident"]:Clone()
			clone:PivotTo(rightHand.CFrame)
			clone.Parent = effects
			Utility.EmitParticles(clone)
			local v3 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://74130014792163",
				Volume = 1.5
			}
			local sound = PeoUtils.CreateSound(v3)
			_G.PU:Dust(sound, 5)
			sound.Parent = rootPart
			sound:Play()
			local motor6D = Instance.new("Motor6D")
			motor6D.Part0 = rightHand
			motor6D.Part1 = clone.MainMotor6D
			motor6D.Parent = clone.MainMotor6D
			local v4 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://95606012580671",
				Volume = 1.25,
				Looped = true
			}
			local sound2 = PeoUtils.CreateSound(v4)
			sound2.Parent = rootPart
			sound2:Play()
			_G.PU:Dust({ clone, motor6D, sound2 }, 15)
			PeodizService.HeartbeatWait({
				Time = 15
			}, function()
				if chargeFolder:IsDescendantOf(character2) then
					return
				else
					return true
				end
			end)
			_G.PU:Dust({ clone, motor6D }, 0.1)

			if sound2 and sound2.Parent then
				TweenService:Create(sound2, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()
				_G.PU:Dust(sound2, 1)
			end
		elseif mode == "Rumble Z V2" then
			local effects = workspace.Effects
			local Z = ReplicatedStorage.Chest.FruitEffect.Rumble.Z
			local startCF = v2.StartCF
			local rootPart = v2.RootPart
			local v3 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://108008853675694",
				Volume = 1
			}
			local sound = PeoUtils.CreateSound(v3)
			_G.PU:Dust(sound, 3)
			sound.Parent = rootPart
			sound:Play()
			local part = Instance.new("Part")
			_G.PU:Dust(part, 1)
			part.Shape = Enum.PartType.Ball
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(255, 130, 47)
			part.Size = Vector3.new()
			part.CFrame = startCF
			part.CanCollide = false
			part.Parent = effects
			TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				CFrame = startCF * CFrame.new(0, 0, -270)
			}):Play()
			task.spawn(function()
				RockModule.SideRock({
					PartTemplate = Z.Rock,
					Track = part,
					Step = task.wait(),
					Radius = 9,
					RadiusWidth = { 0.9, 1.7 },
					List = {
						Enum.RaycastFilterType.Exclude,
						{
							workspace.Effects,
							part,
							workspace.PlayerCharacters,
							workspace.MOB
						}
					},
					Lifetime = 0.5,
					FadeTime = 0.75,
					Width = 1.11
				})
			end)
			wait()

			if (startCF.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 250 then
				_G.CameraShake:ShakeOnce(12, 19, 0, 0.5)
			end

			PeodizService.ForceForLoop({
				Step = 6
			}, function(p)
				local v4 = math.floor(p * 6)
				local clone = Z.Part:Clone()
				_G.PU:Dust(clone, 5)
				clone.CFrame = startCF * CFrame.new(0, 0, v4 * -45)
				clone.Part.CFrame = startCF * CFrame.new(0, 0, v4 * -45)
				clone.Parent = effects
				Utility.EmitParticles(clone)
				local pointLight = Instance.new("PointLight")
				pointLight.Parent = clone
				pointLight.Color = Color3.fromRGB(69, 128, 255)
				pointLight.Brightness = 3
				pointLight.Range = 60
				task.spawn(function()
					wait()
					TweenService:Create(
						pointLight,
						TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Brightness = 0
						}
					):Play()
				end)
				local clone2 = Z.WindMesh:Clone()
				_G.PU:Dust(clone2, 2)
				clone2.CFrame = startCF * CFrame.new(0, 0, v4 * -45) * CFrame.new(0, 0, -22.5) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
				clone2.Size = Vector3.new(clone2.Size.X * 0.6, clone2.Size.Y, clone2.Size.Z * 0.6)
				clone2.Decal.Transparency = 0.7
				clone2.Decal2.Transparency = 0.7
				clone2.Parent = effects
				TweenService:Create(
					clone2.Decal,
					TweenInfo.new(0.6363636363636362, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false),
					{
						Transparency = 1
					}
				):Play()
				TweenService:Create(
					clone2.Decal2,
					TweenInfo.new(0.6363636363636362, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false),
					{
						Transparency = 1
					}
				):Play()
				TweenService:Create(
					clone2,
					TweenInfo.new(0.7272727272727273, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false),
					{
						Size = createVector(72, 103, 72)
					}
				):Play()
				TweenService:Create(
					clone2,
					TweenInfo.new(0.9090909090909091, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false),
					{
						CFrame = clone2.CFrame * CFrame.new(0, 38.85, 0) * CFrame.Angles(0, 3.490658503988659, 0)
					}
				):Play()
				wait()
				task.spawn(function()
					wait(math.random(5, 20) / 10)
					clone.PLightning:Emit(math.random(0, 2))
					clone.PLightning2:Emit(math.random(0, 2))
					clone.PLightning3:Emit(math.random(0, 2))
				end)
			end)
		elseif mode == "Rumble X V2 Hold" then
			local X = ReplicatedStorage.Chest.FruitEffect.Rumble.X
			local effects = workspace.Effects
			local rootPart = v2.RootPart
			local chargeFolder = v2.ChargeFolder
			local character2 = v2.Character
			local clone = nil
			local clone2 = X.Charge:Clone()
			_G.PU:Dust(clone2, 15)
			clone2.Parent = effects
			clone2.CFrame = rootPart.CFrame * CFrame.new(0, 0, -8)
			Utility.ParticleHandler(clone2.Before, true)
			Utility.EmitParticles(clone2.AT0)
			local v3 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://80369909581253",
				Volume = 0.4
			}
			local sound = PeoUtils.CreateSound(v3)
			_G.PU:Dust(sound, 3)
			sound.Parent = rootPart
			sound:Play()
			local v4 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://95606012580671",
				Volume = 1.25,
				Looped = true
			}
			local sound2 = PeoUtils.CreateSound(v4)
			_G.PU:Dust(sound2, 15)
			sound2.Parent = rootPart
			sound2:Play()
			local lastTime = tick()
			local v5 = true
			PeodizService.HeartbeatWait({
				Time = 10
			}, function(_)
				if not chargeFolder:IsDescendantOf(character2) then
					return true
				end

				local v6 = tick() - lastTime
				clone2.CFrame = rootPart.CFrame * CFrame.new(0, 0, -8)

				if clone then
					clone.CFrame = rootPart.CFrame * CFrame.new(0, 0, -8)
					clone.Size = (createVector(3.25, 3.25, 3.25)):Lerp(
						createVector(7.25, 7.25, 7.25),
						(math.abs((math.sin(tick() * 30))))
					)

					if clone:FindFirstChild("ChargeBallIn") then
						clone.ChargeBallIn.Size = (createVector(3.25, 3.25, 3.25)):Lerp(
							createVector(6.5, 6.5, 6.5),
							(math.abs((math.sin(tick() * 30))))
						)
					end
				end

				if v6 > 0.7 and v5 then
					v5 = nil
					local v7 = {
						RollOffMaxDistance = 500,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.Inverse,
						SoundId = "rbxassetid://104746672148229",
						Volume = 1.25
					}
					local sound3 = PeoUtils.CreateSound(v7)
					_G.PU:Dust(sound3, 5)
					sound3.Parent = rootPart
					sound3:Play()
					clone = X.ChargeBall:Clone()
					clone.Parent = effects
					local size = clone.Size
					clone.Size = Vector3.new()
					TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = size
					}):Play()
					clone2.ImpJumpFlip.Enabled = true
					clone2.ImpJumpFlip2.Enabled = true
					Utility.ParticleHandler(clone2.After, true)
					Utility.EmitParticles(clone2.Impact)

					if (rootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 250 then
						_G.CameraShake:ShakeOnce(6, 10, 0, 0.35)
						local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
						colorCorrectionEffect.Parent = game.Lighting
						colorCorrectionEffect.Brightness = 0.1
						colorCorrectionEffect.Contrast = 0.1
						_G.PU:Dust(colorCorrectionEffect, 2)
						task.spawn(function()
							wait()
							TweenService:Create(
								colorCorrectionEffect,
								TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Brightness = 0,
									Contrast = 0
								}
							):Play()
						end)
					end
				end
			end)
			Utility.ParticleHandler(clone2, false)
			_G.PU:Dust(clone2, 1)

			if sound2 and sound2.Parent then
				TweenService:Create(sound2, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()
				_G.PU:Dust(sound2, 1)
			end

			if clone then
				if clone:FindFirstChild("ChargeBallIn") then
					TweenService:Create(
						clone.ChargeBallIn,
						TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
						{
							Size = Vector3.new()
						}
					):Play()
				end

				_G.PU:Dust(clone, 1)
				TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
					Size = Vector3.new()
				}):Play()

				for _, beam in pairs(clone:GetChildren()) do
					if beam:IsA("Beam") then
						TweenService:Create(beam, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
							Width0 = 0,
							Width1 = 0,
							CurveSize0 = 0,
							CurveSize1 = 0
						}):Play()
					end
				end
			end
		elseif mode == "Rumble X V2" then
			local X = ReplicatedStorage.Chest.FruitEffect.Rumble.X
			local effects = workspace.Effects
			local rootPart = v2.RootPart
			local mouseValue = v2.MouseValue
			local startCF = v2.StartCF
			local charge = v2.Charge
			local magnitude = math.clamp((startCF.p - mouseValue.Value).Magnitude, 0, 300 * charge)
			local v3 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://118965797679860",
				Volume = 1
			}
			local sound = PeoUtils.CreateSound(v3)
			_G.PU:Dust(sound, 5)
			sound.Parent = rootPart
			sound:Play()

			local function UpdateBeam(folder)
				for _, attachment in pairs(folder:GetDescendants()) do
					if not attachment:IsA("Attachment") then
						continue
					end

					if attachment.Parent.Name == "Beam" then
						if attachment.Name == "End" then
							attachment.Position = Vector3.new(0, 0, attachment.Parent.Size.Z / 2)
						elseif attachment.Name == "Start" then
							attachment.Position = Vector3.new(0, 0, -attachment.Parent.Size.Z / 2)
						end
					elseif attachment.Parent.Name == "Start" then
						if attachment.Name == "BlackBeamEnd" then
							attachment.Position = Vector3.new(0, 0, attachment.Parent.Size.Z / 2)
						elseif attachment.Name == "BlackBeamStart" then
							attachment.Position = Vector3.new(0, 0, -attachment.Parent.Size.Z / 2)
						elseif attachment.Name == "Start" then
							attachment.Position = createVector(0, 0, 0)
						elseif attachment.Name == "End" then
							attachment.Position = Vector3.new(0, 0, folder.Beam.Size.Z)
						end
					elseif attachment.Parent.Name == "End" then
						if attachment.Name == "BlackBeamEnd" then
							attachment.Position = Vector3.new(0, 0, attachment.Parent.Size.Z / 2)
						elseif attachment.Name == "BlackBeamStart" then
							attachment.Position = Vector3.new(0, 0, -attachment.Parent.Size.Z / 2)
						end
					end
				end
			end

			local clone = X.ThunderBeam:Clone()
			_G.PU:Dust(clone, 2)
			clone:SetPrimaryPartCFrame(startCF * CFrame.new(0, 0, -30) * CFrame.Angles(0, 3.141592653589793, 0))
			clone.Parent = effects
			UpdateBeam(clone)
			local v4 = {}
			local positionsByDescendant = {}
			task.delay(50, function()
				table.clear(v4)
				table.clear(positionsByDescendant)
			end)
			local numberValue = Instance.new("NumberValue")
			_G.PU:Dust(numberValue, 10)

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("BasePart") then
					descendant.Size *= charge
					v4[#v4 + 1] = { descendant, descendant.Size, descendant.Transparency }
					descendant.Transparency = 1

					if descendant.Name == "Beam" then
						descendant.Size = Vector3.new(0, 0, descendant.Size.Z)
					else
						descendant.Size = createVector(0, 0, 0)
					end
				elseif descendant:IsA("Beam") then
					v4[#v4 + 1] = {
						descendant,
						descendant.Width0 * charge,
						descendant.Width1 * charge,
						descendant.CurveSize0 * charge,
						descendant.CurveSize1 * charge
					}
					descendant.Enabled = false
					descendant.Width0 = 0
					descendant.Width1 = 0
					descendant.CurveSize0 = 0
					descendant.CurveSize1 = 0
				elseif descendant:IsA("Attachment") and not descendant:FindFirstChildOfClass("ParticleEmitter") and descendant.Name ~= "BlackBeamStart" and descendant.Name ~= "BlackBeamEnd" then
					descendant.Position *= charge
					positionsByDescendant[descendant] = descendant.Position
				end
			end

			TweenService:Create(numberValue, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Value = 25 * charge
			}):Play()

			for _, v5 in pairs(v4) do
				if v5[1]:IsA("BasePart") then
					v5[1].Transparency = v5[3]

					if v5[1].Name == "Start" or v5[1].Name == "End" then
						TweenService:Create(
							v5[1],
							TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								Size = v5[2]
							}
						):Play()
					end

					local v6 = v5
					task.delay(1, function()
						if v6[1].Name == "Beam" then
							TweenService:Create(
								v6[1],
								TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
								{
									Size = Vector3.new(0, 0, v6[1].Size.Z / 2)
								}
							):Play()
						else
							TweenService:Create(
								v6[1],
								TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
								{
									Size = createVector(0, 0, 0)
								}
							):Play()
						end

						task.delay(0.4, function()
							v6[1].Transparency = 1
						end)
					end)
				elseif v5[1]:IsA("Beam") then
					v5[1].Enabled = true
					TweenService:Create(v5[1], TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Width0 = v5[2],
						Width1 = v5[3],
						CurveSize0 = v5[4],
						CurveSize1 = v5[5]
					}):Play()
					local v6 = v5
					task.delay(1, function()
						TweenService:Create(
							v6[1],
							TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
							{
								Width0 = 0,
								Width1 = 0,
								CurveSize0 = 0,
								CurveSize1 = 0
							}
						):Play()
					end)
				end
			end

			Utility.ParticleHandler(clone, true)

			if (rootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 250 then
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				_G.PU:Dust(colorCorrectionEffect, 2)
				colorCorrectionEffect.Parent = game.Lighting
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						TintColor = Color3.fromRGB(167, 205, 255),
						Contrast = 0.25
					}
				):Play()
				task.spawn(function()
					wait(1.2)
					Utility.ParticleHandler(clone, false)
					wait(0.3)
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Color3.fromRGB(255, 255, 255),
							Contrast = 0
						}
					):Play()
				end)
			end

			local lastTime = tick()

			local function explode(cframe)
				local v5 = {
					Smaller = {
						Size = createVector(6.65, 9.975, 9.975),
						Duration = 1.5,
						Amount = 12,
						Radius = 25,
						Chance = 85
					},
					Bigger = {
						Size = createVector(9.975, 14.962501, 14.962501),
						Duration = 1.5,
						Amount = 10.56,
						Radius = 42.5,
						Chance = 85
					}
				}
				task.delay(30, function()
					table.clear(v5)
				end)
				task.spawn(function()
					RockModule.Rocks(cframe, {
						RockSize = v5.Smaller.Size,
						Duration = v5.Smaller.Duration,
						Amount = v5.Smaller.Amount,
						Radius = v5.Smaller.Radius,
						Chance = v5.Smaller.Chance
					})
				end)
				task.spawn(function()
					RockModule.Debris(cframe, {
						PartTemplate = X.Rock2,
						Count = 8,
						Force = 180,
						Radius = 12.5,
						Lifetime = 1.5,
						Direction = Vector3.new(math.random(0, 50) / 100, 1, math.random(0, 50) / 100),
						BVLifetime = 0.1,
						SpreadAngle = 0.35,
						SpreadForce = 0.5
					})
				end)
				local clone2 = X.Impact:Clone()
				_G.PU:Dust(clone2, 4)
				clone2.CFrame = cframe
				clone2.Parent = effects
				Utility.EmitParticles(clone2)
				local v6 = {
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://131920116112437",
					Volume = 1.25
				}
				local sound2 = PeoUtils.CreateSound(v6)
				_G.PU:Dust(sound2, 5)
				sound2.Parent = clone2
				sound2:Play()

				if (rootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 250 then
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
					_G.PU:Dust(colorCorrectionEffect, 2)
					colorCorrectionEffect.Brightness = 0.1
					colorCorrectionEffect.Contrast = 0.1
					colorCorrectionEffect.Parent = game.Lighting
					task.spawn(function()
						wait()
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Brightness = 0,
								Contrast = 0
							}
						):Play()
					end)
				end

				local pointLight = Instance.new("PointLight")
				_G.PU:Dust(pointLight, 4)
				pointLight.Color = Color3.fromRGB(69, 128, 255)
				pointLight.Brightness = 3
				pointLight.Range = 60
				pointLight.Parent = clone2
				task.spawn(function()
					wait()
					TweenService:Create(
						pointLight,
						TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Brightness = 0
						}
					):Play()
				end)
			end

			PeodizService.HeartbeatWait({
				Time = 1.5
			}, function(_)
				local v5 = CFrame.new(rootPart.Position, mouseValue.Value) * CFrame.new(0, 0, -numberValue.Value / 1.5)
				local cframe = CFrame.new(mouseValue.Value)
				magnitude = (v5.Position - cframe.Position).Magnitude
				local v6 = magnitude / 300

				if clone and clone.Parent then
					clone:SetPrimaryPartCFrame(v5 * CFrame.Angles(0, 3.141592653589793, 0))
				end

				local cFrame = v5 * CFrame.new(0, 0, -magnitude / 2) * CFrame.Angles(0, 3.141592653589793, 0)
				clone.Beam.CFrame = cFrame
				clone.BeamPart.CFrame = cFrame
				clone.BeamPart2.CFrame = cFrame
				clone.Beam.Size = Vector3.new(numberValue.Value, numberValue.Value, 300 * v6)
				clone.BeamPart.Size = Vector3.new(numberValue.Value, numberValue.Value, 300 * v6)
				clone.BeamPart2.Size = Vector3.new(numberValue.Value * 2.5, numberValue.Value / 2, 300 * v6)
				clone.End.CFrame = v5 * CFrame.new(0, 0, -magnitude) * CFrame.Angles(0, 3.141592653589793, 0)
				UpdateBeam(clone)

				if tick() - lastTime > 0.2 then
					lastTime = tick()
					explode(cframe)
				end
			end)
		elseif mode == "Rumble C V2" then
			local C = ReplicatedStorage.Chest.FruitEffect.Rumble.C
			local effects = workspace.Effects
			local chargeFolder = v2.ChargeFolder
			local character2 = v2.Character
			local rootPart = v2.RootPart
			local lightningDragon = v2.LightningDragon

			if lightningDragon and lightningDragon.Parent then
				for _, part in pairs(lightningDragon:GetChildren()) do
					if not (part:IsA("BasePart") and part.Name ~= "RootPart") then
						continue
					end

					part.Transparency = 1
					TweenService:Create(part, TweenInfo.new(0.5), {
						Transparency = 0
					}):Play()
				end
			end

			local v3 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://71068002171606",
				Volume = 2.2
			}
			local sound = PeoUtils.CreateSound(v3)
			_G.PU:Dust(sound, 5)
			sound.Parent = rootPart
			sound:Play()
			local v4 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://81579998364711",
				Volume = 2
			}
			local sound2 = PeoUtils.CreateSound(v4)
			_G.PU:Dust(sound2, 5)
			sound2.Parent = rootPart
			sound2:Play()
			local clone = C.Mount:Clone()
			_G.PU:Dust(clone, 6)
			clone.Parent = effects
			clone.Anchored = false
			local weld = Instance.new("Weld")
			weld.Part0 = clone
			weld.Part1 = rootPart
			weld.Parent = clone
			weld.C0 = CFrame.Angles(0, 3.141592653589793, 0)
			Utility.EmitParticles(clone)
			Utility.ParticleHandler(clone, true)

			local function ImpactTransform(p)
				if p then
					local v5 = {
						RollOffMaxDistance = 500,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.Inverse,
						SoundId = "rbxassetid://74130014792163",
						Volume = 2
					}
					local sound3 = PeoUtils.CreateSound(v5)
					_G.PU:Dust(sound3, 5)
					sound3.Parent = rootPart
					sound3:Play()
				end

				local clone2 = C.ImpactT:Clone()
				_G.PU:Dust(clone2, 3)
				clone2.CFrame = rootPart.CFrame
				clone2.Parent = effects
				Utility.EmitParticles(clone2)
				PeodizService.HeartbeatWait({
					Time = 2
				}, function(_)
					clone2.CFrame = rootPart.CFrame
				end)
			end

			task.spawn(function()
				ImpactTransform()
			end)
			task.spawn(function()
				task.wait()
				TweenService:Create(weld, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					C0 = CFrame.new(0, 5, 0) * CFrame.Angles(0, 3.141592653589793, 0)
				}):Play()
			end)
			local v5 = {}
			task.delay(50, function()
				table.clear(v5)
			end)
			local lastTime = tick()

			if localPlayer == character then
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				_G.PU:Dust(colorCorrectionEffect, 6)
				colorCorrectionEffect.Parent = game.Lighting
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						TintColor = Color3.fromRGB(167, 205, 255),
						Contrast = 0.25
					}
				):Play()
				TweenService:Create(
					currentCamera,
					TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						FieldOfView = 100
					}
				):Play()
				task.spawn(function()
					wait(1)
					TweenService:Create(
						currentCamera,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							FieldOfView = 70
						}
					):Play()
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Color3.fromRGB(255, 255, 255),
							Contrast = 0
						}
					):Play()
				end)
			end

			local pointLight = Instance.new("PointLight")
			pointLight.Parent = clone
			pointLight.Color = Color3.fromRGB(69, 128, 255)
			pointLight.Brightness = 3
			pointLight.Range = 60
			task.spawn(function()
				wait(5)
				TweenService:Create(pointLight, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Brightness = 0
				}):Play()
			end)
			PeodizService.HeartbeatWait({
				Time = 5
			}, function(_)
				if not chargeFolder:IsDescendantOf(character2) then
					return true
				end

				if tick() - lastTime > 0.25 then
					lastTime = tick()
					local clone2 = C.Spiral:Clone()
					_G.PU:Dust(clone2, 2)
					clone2.CFrame = rootPart.CFrame * CFrame.new(0, 0, 10)
					clone2.Parent = effects
					Utility.EmitParticles(clone2)
					local clone3 = C.WindMesh:Clone()
					_G.PU:Dust(clone3, 2)
					clone3.CFrame = rootPart.CFrame * CFrame.new(0, 0, -50) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
						0,
						6.283185307179586 * math.random(),
						0
					)
					clone3.Size = Vector3.new(clone3.Size.X * 0.6, clone3.Size.Y, clone3.Size.Z * 0.6)
					clone3.Decal.Transparency = 0.8
					clone3.Decal2.Transparency = 0.8
					clone3.Parent = effects
					TweenService:Create(
						clone3.Decal,
						TweenInfo.new(0.6363636363636362, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false),
						{
							Transparency = 1
						}
					):Play()
					TweenService:Create(
						clone3.Decal2,
						TweenInfo.new(0.6363636363636362, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false),
						{
							Transparency = 1
						}
					):Play()
					TweenService:Create(
						clone3,
						TweenInfo.new(
							0.7272727272727273,
							Enum.EasingStyle.Exponential,
							Enum.EasingDirection.Out,
							0,
							false
						),
						{
							Size = createVector(119, 110, 119)
						}
					):Play()
					TweenService:Create(
						clone3,
						TweenInfo.new(
							0.9090909090909091,
							Enum.EasingStyle.Exponential,
							Enum.EasingDirection.Out,
							0,
							false
						),
						{
							CFrame = clone3.CFrame * CFrame.new(0, 49.95, 0) * CFrame.Angles(0, 3.490658503988659, 0)
						}
					):Play()

					if (rootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 150 then
						local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
						_G.PU:Dust(colorCorrectionEffect, 2)
						colorCorrectionEffect.Brightness = 0.1
						colorCorrectionEffect.Contrast = 0.1
						colorCorrectionEffect.Parent = game.Lighting
						task.spawn(function()
							wait()
							TweenService:Create(
								colorCorrectionEffect,
								TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Brightness = 0,
									Contrast = 0
								}
							):Play()
						end)
					end

					local function get_all_enemys()
						local children = {}

						for _, child in pairs(workspace.Monster:GetChildren()) do
							if child:FindFirstChild("HumanoidRootPart") then
								children[#children + 1] = child
							end
						end

						return children
					end

					local function get_nearest_enemys(cFrame, p, p2)
						local v6 = get_all_enemys()
						local v7 = {}

						for _, enemy in pairs(v6) do
							local magnitude = (cFrame.Position - enemy.HumanoidRootPart.Position).Magnitude

							if magnitude < p then
								table.insert(v7, {
									enemy = enemy,
									distance = magnitude
								})
							end
						end

						table.sort(v7, function(a, b)
							return a.distance < b.distance
						end)
						local enemies = {}

						for i = 1, math.min(p2, #v7) do
							table.insert(enemies, v7[i].enemy)
						end

						return enemies
					end

					local v6 = get_nearest_enemys(rootPart.CFrame, 125, 3)

					for _, v7 in pairs(v6) do
						local clone4 = C.Impact:Clone()
						_G.PU:Dust(clone4, 3)
						clone4.CFrame = CFrame.new(v7.HumanoidRootPart.CFrame.p)
						clone4.Parent = effects
						Utility.EmitParticles(clone4)
					end
				end
			end)

			if lightningDragon and lightningDragon.Parent then
				for _, part in pairs(lightningDragon:GetChildren()) do
					if not (part:IsA("BasePart") and part.Name ~= "RootPart") then
						continue
					end

					part.Transparency = 1
					TweenService:Create(part, TweenInfo.new(0.5), {
						Transparency = 1
					}):Play()
				end
			end

			task.spawn(function()
				ImpactTransform(true)
			end)
			weld:Destroy()
			clone.Anchored = true
			Utility.ParticleHandler(clone, false)
		elseif mode == "Rumble V V2 Cast" then
			local effects = workspace.Effects
			local E = ReplicatedStorage.Chest.FruitEffect.Rumble.E
			local startCF = v2.StartCF
			local cFMouse = v2.CFMouse
			local rootPart = v2.RootPart
			local position = startCF.Position
			local position2 = cFMouse.Position
			local midpoint = (position + position2) / 2
			local magnitude = (position2 - position).Magnitude
			local clone = E.Pierce:Clone()
			_G.PU:Dust(clone, 3)
			clone.Part:Destroy()
			clone.Size = Vector3.new(10, 10, magnitude)
			clone.CFrame = CFrame.lookAt(midpoint, position2)
			clone.Parent = effects
			Utility.EmitParticles(clone)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 250,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://303967360",
				Volume = 0.5,
				PlaybackSpeed = 2
			})
			_G.PU:Dust(sound, 1)
			sound.Parent = rootPart
			sound:Play()
			local clone2 = E.exp2:Clone()
			_G.PU:Dust(clone2, 5)
			clone2.CFrame = cFMouse
			clone2.Parent = effects
			Utility.ParticleHandler(clone2, true)
			task.wait(0.5)
			Utility.ParticleHandler(clone2, false)
			local clone3 = E.ImpactV:Clone()
			_G.PU:Dust(clone3, 5)
			clone3.CFrame = cFMouse
			clone3.Parent = effects
			Utility.EmitParticles(clone3)
			local v4 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://112770019501644",
				Volume = 1.25
			}
			local sound2 = PeoUtils.CreateSound(v4)
			_G.PU:Dust(sound2, 5)
			sound2.Parent = clone3
			sound2:Play()
		elseif mode == "Rumble V V2" then
			local effects = workspace.Effects
			local V = ReplicatedStorage.Chest.FruitEffect.Rumble.V
			local humanoid = v2.Humanoid
			local rootPart = v2.RootPart
			local character2 = v2.Character
			local _ = v2.StartCF
			local cFMouse = v2.CFMouse
			local v3 = cFMouse * CFrame.new(
				-2.07985878,
				184.939514,
				172.638046,
				0,
				0,
				-1,
				-0.728734314,
				0.684796512,
				0,
				0.684796512,
				0.728734314,
				0
			)
			local v4 = cFMouse * CFrame.new(
				1.64713097,
				168.233963,
				173.770264,
				0,
				0,
				-1,
				0.578445911,
				-0.815720618,
				0,
				-0.815720618,
				-0.578445911,
				0
			)
			local v5 = cFMouse * CFrame.new(
				1.64713097,
				175.087341,
				178.630127,
				0,
				0,
				-1,
				0.578445971,
				-0.815720677,
				0,
				-0.815720677,
				-0.578445971,
				0
			)
			local v6 = cFMouse * CFrame.new(
				1.64713097,
				260.738098,
				239.367035,
				0,
				0,
				-1,
				0.578445971,
				-0.815720677,
				0,
				-0.815720677,
				-0.578445971,
				0
			)
			local cFrame = cFMouse * CFrame.new(18.2123489, -4.7816925, 43.1802521, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			local cFrame3 = cFMouse * CFrame.new(24.5346375, 141.275513, 43.0697784, 0, 0, -1, 0, 1, 0, 1, 0, 0)
			local cFrame4 = cFMouse * CFrame.new(18.2123489, -4.7816925, 43.1802521, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			local cFrame5 = cFMouse * CFrame.new(
				18.2119751,
				-4.78200006,
				43.1799774,
				-1,
				0,
				-8.74227766e-8,
				0,
				1,
				0,
				8.74227766e-8,
				0,
				-1
			)
			local cFrame6 = cFMouse * CFrame.new(18.2119751, -553.204224, 43.1799774, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			local cFrame7 = cFMouse * CFrame.new(
				1.05051994,
				-0.0415053368,
				-2.46869659,
				0.943304121,
				-0.19763273,
				0.266681433,
				-0.0625162274,
				-0.894829273,
				-0.442009479,
				0.325989991,
				0.400277436,
				-0.856451213
			)
			local cFrame8 = cFMouse * CFrame.new(
				18.2119751,
				-4.78200006,
				43.1799736,
				0.547231257,
				0,
				-0.836981416,
				0,
				1,
				0,
				0.836981416,
				0,
				0.547231257
			)
			local cFrame9 = cFMouse * CFrame.new(
				18.2121315,
				-0.0486793518,
				43.1803551,
				0.713245928,
				0.0000326859881,
				0.700913846,
				0.0000326859481,
				1,
				-0.0000798944238,
				-0.700913846,
				0.0000798944093,
				0.713245928
			)
			local v15 = cFMouse * CFrame.new(
				18.2121315,
				-272.832611,
				43.1803551,
				0.713245928,
				0.0000326859918,
				0.700913846,
				0.0000326859481,
				1,
				-0.0000798944238,
				-0.700913846,
				0.0000798944093,
				0.713245928
			)
			local cFrame10 = cFMouse * CFrame.new(
				0.803005219,
				316.347168,
				306.154236,
				1,
				0,
				0,
				0,
				0.712352037,
				-0.70182234,
				0,
				0.70182234,
				0.712352037
			)
			local cFrame11 = cFMouse * CFrame.new(
				-0.241725922,
				-2.26992702,
				-2.97497368,
				0.987006247,
				-0.160684824,
				0,
				0.0781981796,
				0.480332226,
				-0.873593986,
				0.14037326,
				0.862242579,
				0.486655802
			)
			local v18 = cFMouse * CFrame.new(
				-0.0200004578,
				-2.98999977,
				-0.0200004578,
				-1,
				0,
				-8.74227766e-8,
				0,
				1,
				0,
				8.74227766e-8,
				0,
				-1
			)
			local clone = V.CamRigWithLetterBox:Clone()
			_G.PU:Dust(clone, 15)
			clone:SetPrimaryPartCFrame(v18)
			clone.Parent = effects
			local clone2 = V.Cloud:Clone()
			clone2:PivotTo(v3)
			clone2.Parent = effects
			local cloud = clone2.Cloud
			cloud:PivotTo(v4)
			local cloud2 = clone2.Cloud
			cloud2:PivotTo(v4)
			local cloud3 = clone2.Cloud
			cloud3:PivotTo(v4)
			local clone3 = V.RumbleExplo:Clone()
			clone3.CFrame = cFrame
			clone3.Parent = effects
			local clone4 = V.Mesh.Shock:Clone()
			clone4.CFrame = cFrame3
			clone4.Parent = effects
			local clone5 = V.Mesh.RotateStar:Clone()
			clone5.CFrame = cFrame4
			clone5.Parent = effects
			local clone6 = V.Mesh.Explosion:Clone()
			clone6.CFrame = cFrame5
			clone6.Parent = effects
			local clone7 = V.Mesh.ImpactMesh:Clone()
			clone7.CFrame = cFrame6
			clone7.Parent = effects
			local clone8 = V.Fly:Clone()
			clone8.CFrame = cFrame7
			clone8.Parent = effects
			local clone9 = V.Mesh.MeshSpin:Clone()
			clone9.CFrame = cFrame8
			clone9.Parent = effects
			local clone10 = V.Mesh.Cloud9:Clone()
			clone10.CFrame = cFrame9
			clone10.Parent = effects
			local clone11 = V.Mesh.Cloud8:Clone()
			clone11:PivotTo(v15)
			clone11.Parent = effects
			local clone12 = V.RumbleBall:Clone()
			clone12.CFrame = cFrame10
			clone12.Parent = effects
			local clone13 = V.Jump:Clone()
			clone13.CFrame = cFrame11
			clone13.Parent = effects
			local cFrame12 = cFMouse * CFrame.new(-1.78520775, 9.78499603, 7.87395859, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			local clone14 = V.Kabam:Clone()
			clone14.CFrame = cFrame12
			clone14.Parent = effects
			local cFrame13 = cFMouse * CFrame.new(-0.794643402, 7.54321861, 5.65533447, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			local clone15 = V.Kabam2:Clone()
			clone15.CFrame = cFrame13
			clone15.Parent = effects
			local cFrame14 = cFMouse * CFrame.new(-2.6185112, -2.5, 7.95550728, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			local clone16 = V.AuraRepeat:Clone()
			clone16.CFrame = cFrame14
			clone16.Parent = effects
			local v22 = cFMouse * CFrame.new(4.34021568, 12.9666977, 3.45867538, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			local clone17 = V.RandomTrailFirst:Clone()
			clone17:PivotTo(v22)
			clone17.Parent = effects
			local cFrame15 = cFMouse * CFrame.new(-0.659784317, 7.96669769, 5.45867538, 1, 0, 0, 0, 1, 0, 0, 0, 1)
			local clone18 = V.HandUp:Clone()
			clone18.CFrame = cFrame15
			clone18.Parent = effects
			local v24 = cFMouse * CFrame.new(
				164.803009,
				-222.367325,
				-35.7605019,
				1,
				0,
				0,
				0,
				0.712352037,
				-0.70182234,
				0,
				0.70182234,
				0.712352037
			)
			local clone19 = V.RandomTrail:Clone()
			clone19:PivotTo(v24)
			clone19.Parent = effects
			local cFrame16 = cFMouse * CFrame.new(
				0.803005219,
				257.4422,
				248.119949,
				1,
				0,
				0,
				0,
				0.712352037,
				-0.7018224,
				0,
				0.7018224,
				0.712352037
			)
			local clone20 = V.EmitSpawnBall:Clone()
			clone20.CFrame = cFrame16
			clone20.Parent = effects
			local clone21 = game.Lighting.Blur:Clone()
			clone21.Parent = game.Lighting
			local clone22 = game.Lighting.ColorCorrection:Clone()
			clone22.Parent = game.Lighting
			local windBeam = clone.WindBeam
			local highlight = Instance.new("Highlight")
			_G.PU:Dust(highlight, 15)
			highlight.FillColor = Color3.fromRGB(79, 146, 255)
			highlight.FillTransparency = 1
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			highlight.OutlineTransparency = 1
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.Enabled = true
			highlight.Parent = character2
			_G.PU:Dust({
				clone2,
				cloud,
				cloud2,
				cloud3,
				clone3,
				clone4,
				clone5,
				clone6,
				clone7,
				clone8,
				clone9,
				clone10,
				clone11,
				clone12,
				clone13,
				clone14,
				clone15,
				clone16,
				clone17,
				clone18,
				clone19,
				clone20,
				clone21,
				clone22,
				highlight
			}, 15)
			local charParticle = V.CharParticle
			local v26 = {}
			local v27 = nil

			for childName in pairs({
				Head = true,
				UpperTorso = true,
				RightUpperLeg = true,
				RightUpperArm = true,
				LeftUpperLeg = true,
				LeftUpperArm = true
			}) do
				local child = character2:FindFirstChild(childName)

				if not child then
					continue
				end

				v26[childName] = {}

				for _, emitter in ipairs(charParticle:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local clone23 = emitter:Clone()
					_G.PU:Dust(clone23, 15)
					clone23.Parent = child
					table.insert(v26[childName], clone23)
				end
			end

			task.delay(0.3, function()
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://76502022034421",
					Volume = 1.1
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = rootPart
				sound:Play()
			end)
			task.delay(1.3, function()
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://132505473562863",
					Volume = 0.7
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = rootPart
				sound:Play()
			end)
			task.delay(2, function()
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://73642161703180",
					Volume = 1.25
				})
				_G.PU:Dust(sound, 4)
				sound.Parent = rootPart
				sound:Play()
			end)
			task.delay(3, function()
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://126358762222759",
					Volume = 0.9
				})
				_G.PU:Dust(sound, 4)
				sound.Parent = rootPart
				sound:Play()
			end)
			task.delay(3.4, function()
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 250,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://125385540843958",
					Volume = 0.55
				})
				_G.PU:Dust(sound, 7)
				sound.Parent = SoundService
				sound:Play()
				TweenService:Create(sound, TweenInfo.new(2, Enum.EasingStyle.Linear), {
					Volume = 0.7
				}):Play()
			end)
			task.delay(6.4, function()
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 250,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://91233391114077",
					Volume = 0.55
				})
				_G.PU:Dust(sound, 7)
				sound.Parent = SoundService
				sound:Play()
			end)
			local v28 = _G.PU.PlayOneShotAnim({
				Animator = humanoid,
				Animation = ReplicatedStorage.Chest.Animation.RumbleRumble.Awake.V2
			})
			task.delay(0.5, function()
				if localPlayer == character then
					PeoUtils.LerpCF(rootPart, TweenInfo.new(0.9), cFMouse * CFrame.new(-1.5, 7, 8.5))
				end
			end)

			local function StartCutScene(p)
				task.spawn(function()
					v28.Stopped:Wait()
					v27 = true
					rootPart.Anchored = nil
					humanoid.AutoRotate = true
				end)

				if p then
					local function RumbleCutscene()
						_G.VisibleGui(nil)
						humanoid.AutoRotate = false
						rootPart.Anchored = true
						tick()
						local track = clone.AnimationController:LoadAnimation(ReplicatedStorage.Chest.Animation.RumbleRumble.Awake.V2Cam)
						track.Priority = Enum.AnimationPriority.Action4
						track:AdjustSpeed(1)
						track:Play()
						currentCamera.CameraType = Enum.CameraType.Scriptable
						task.spawn(function()
							PeodizService.new({
								Time = 10
							}, function(_)
								if not track.IsPlaying or v27 or not clone:FindFirstChild("camera") then
									return true
								end

								currentCamera.CFrame = clone.camera.CFrame
								HighlightModule:Update()
							end)
							currentCamera.CameraType = Enum.CameraType.Custom

							if clone and clone.Parent then
								clone:Destroy()
							end

							_G.VisibleGui(true)
						end)
					end

					local targets = v2.Targets

					if targets and table.find(targets, localPlayer.Name) then
						RumbleCutscene()
					end

					if localPlayer.Character and localPlayer.Character == character2 then
						RumbleCutscene()
					end
				end
			end

			task.spawn(function()
				StartCutScene(true)
			end)

			local function CountProperties(items)
				local result2 = {}
				local v29 = 1

				for k, item in pairs(items) do
					local count = 0

					for k2, v30 in pairs(item) do
						if not result2[k2] then
							result2[k2] = {}
						end

						result2[k2][k] = v30
						count += 1
					end

					if v29 < count then
						v29 = count
					end
				end

				for _, list2 in pairs(result2) do
					table.sort(list2)
				end

				return v29, result2
			end

			task.spawn(function()
				local v29 = {
					[cloud2] = {
						[0] = {
							CFrame = v5 * CFrame.new(
								0,
								0,
								0,
								0.9999999403953552,
								0,
								0,
								0,
								0.9999999403953552,
								-0,
								0,
								-0,
								1
							)
						},
						[205] = {
							CFrame = v5 * CFrame.new(
								0,
								0,
								0,
								0.9999999403953552,
								0,
								0,
								0,
								0.9999999403953552,
								-0,
								0,
								-0,
								1
							)
						},
						[250] = {
							CFrame = v5 * CFrame.new(
								0,
								0,
								0,
								-0.03935729339718819,
								-1.4901161193847656e-7,
								0.9992252588272095,
								-9.12696123123169e-8,
								1.000000238418579,
								5.960464477539063e-8,
								-0.9992252588272095,
								-5.960464477539063e-8,
								-0.03935731202363968
							)
						},
						[312] = {
							CFrame = v5 * CFrame.new(
								0,
								0,
								0,
								-0.9970029592514038,
								-9.238719940185547e-7,
								0.0773642286658287,
								-9.238719940185547e-7,
								1.0000001192092896,
								-4.991888999938965e-7,
								-0.0773642435669899,
								-4.470348358154297e-7,
								-0.9970029592514038
							)
						},
						[396] = {
							CFrame = v5 * CFrame.new(
								0,
								0,
								0,
								-0.01365969330072403,
								-1.430511474609375e-6,
								-0.9999066591262817,
								2.621673047542572e-7,
								1,
								-1.5497207641601562e-6,
								0.9999066591262817,
								-2.086162567138672e-7,
								-0.013659629970788956
							)
						}
					},
					[cloud] = {
						[0] = {
							CFrame = v4 * CFrame.new(
								0,
								0,
								0,
								0.9999998211860657,
								0,
								0,
								0,
								0.9999998211860657,
								-0,
								0,
								-0,
								1
							)
						},
						[205] = {
							CFrame = v4 * CFrame.new(
								0,
								0,
								0,
								0.9999998211860657,
								0,
								0,
								0,
								0.9999998211860657,
								-0,
								0,
								-0,
								1
							)
						},
						[250] = {
							CFrame = v4 * CFrame.new(
								0,
								0,
								0,
								-0.07725714147090912,
								-2.9802322387695312e-8,
								-0.9970111846923828,
								0,
								1,
								0,
								0.9970111846923828,
								-0,
								-0.07725714892148972
							)
						},
						[312] = {
							CFrame = v4 * CFrame.new(
								0,
								0,
								0,
								-0.9991050958633423,
								-1.7881393432617188e-7,
								0.04229636862874031,
								-1.7881393432617188e-7,
								1.0000001192092896,
								1.5832483768463135e-7,
								-0.042296402156353,
								1.1920928955078125e-7,
								-0.9991052150726318
							)
						},
						[396] = {
							CFrame = v4 * CFrame.new(
								0,
								0,
								0,
								0.057421691715717316,
								-1.1920928955078125e-7,
								0.9983501434326172,
								1.1362135410308838e-7,
								1.000000238418579,
								2.384185791015625e-7,
								-0.9983500838279724,
								8.940696716308594e-8,
								0.057421665638685226
							)
						}
					},
					[clone3] = {
						[0] = {
							Size = createVector(0.001, 0.001, 0.001),
							Transparency = 1
						},
						[395] = {
							Size = createVector(0.001, 0.001, 0.001),
							Transparency = 0
						},
						[397] = {
							Size = createVector(1028.645, 1028.645, 1028.645),
							Transparency = 0
						},
						[401] = {
							Size = createVector(0.001, 0.001, 0.001)
						},
						[409] = {
							Size = createVector(1000, 1000, 1000)
						},
						[546] = {
							Size = createVector(1028.645, 1028.645, 1028.645)
						},
						[547] = {
							Transparency = 0
						},
						[563] = {
							Transparency = 1
						},
						[564] = {
							Size = createVector(1062.1804, 1062.1804, 1062.1804)
						}
					},
					[clone4] = {
						[0] = {
							CFrame = cFrame3 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 1
						},
						[248] = {
							CFrame = cFrame3 * CFrame.new(
								0,
								0,
								0,
								1.0000001192092896,
								0,
								-1.1920928955078125e-7,
								0,
								1,
								-0,
								1.1920928955078125e-7,
								0,
								1.0000001192092896
							)
						},
						[395] = {
							CFrame = cFrame3 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 1
						},
						[409] = {
							CFrame = cFrame3 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0
						},
						[419] = {
							CFrame = cFrame3 * CFrame.new(
								0,
								0,
								0,
								-0.07899288088083267,
								0,
								-0.9968751668930054,
								0,
								0.9999999403953552,
								0,
								0.9968751668930054,
								0,
								-0.07899288088083267
							)
						},
						[429] = {
							CFrame = cFrame3 * CFrame.new(
								0,
								0.0000152587890625,
								0,
								-0.9968751668930054,
								0,
								0.07899288088083267,
								0,
								0.9999998211860657,
								0,
								-0.07899288088083267,
								0,
								-0.9968751668930054
							)
						},
						[437] = {
							CFrame = cFrame3 * CFrame.new(
								0,
								0.000030517578125,
								0,
								0.07899288088083267,
								0,
								0.9968751668930054,
								0,
								0.999999463558197,
								0,
								-0.9968751668930054,
								0,
								0.07899288088083267
							)
						},
						[444] = {
							CFrame = cFrame3 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[454] = {
							CFrame = cFrame3 * CFrame.new(
								0,
								0,
								0,
								-0.07899288088083267,
								0,
								-0.9968751668930054,
								0,
								0.9999999403953552,
								0,
								0.9968751668930054,
								0,
								-0.07899288088083267
							)
						},
						[464] = {
							CFrame = cFrame3 * CFrame.new(
								0,
								0.0000152587890625,
								0,
								-0.9968751668930054,
								0,
								0.07899288088083267,
								0,
								0.9999998211860657,
								0,
								-0.07899288088083267,
								0,
								-0.9968751668930054
							)
						},
						[472] = {
							CFrame = cFrame3 * CFrame.new(
								0,
								0.000030517578125,
								0,
								0.07899288088083267,
								0,
								0.9968751668930054,
								0,
								0.999999463558197,
								0,
								-0.9968751668930054,
								0,
								0.07899288088083267
							)
						},
						[484] = {
							CFrame = cFrame3 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[494] = {
							CFrame = cFrame3 * CFrame.new(
								0,
								0,
								0,
								-0.07899288088083267,
								0,
								-0.9968751668930054,
								0,
								0.9999999403953552,
								0,
								0.9968751668930054,
								0,
								-0.07899288088083267
							)
						},
						[504] = {
							CFrame = cFrame3 * CFrame.new(
								0,
								0.0000152587890625,
								0,
								-0.9968751668930054,
								0,
								0.07899288088083267,
								0,
								0.9999998211860657,
								0,
								-0.07899288088083267,
								0,
								-0.9968751668930054
							)
						},
						[512] = {
							CFrame = cFrame3 * CFrame.new(
								0,
								0.000030517578125,
								0,
								0.07899288088083267,
								0,
								0.9968751668930054,
								0,
								0.999999463558197,
								0,
								-0.9968751668930054,
								0,
								0.07899288088083267
							)
						},
						[520] = {
							CFrame = cFrame3 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[530] = {
							CFrame = cFrame3 * CFrame.new(
								0,
								0,
								0,
								-0.07899288088083267,
								0,
								-0.9968751668930054,
								0,
								0.9999999403953552,
								0,
								0.9968751668930054,
								0,
								-0.07899288088083267
							)
						},
						[540] = {
							CFrame = cFrame3 * CFrame.new(
								0,
								0.0000152587890625,
								0,
								-0.9968751668930054,
								0,
								0.07899288088083267,
								0,
								0.9999998211860657,
								0,
								-0.07899288088083267,
								0,
								-0.9968751668930054
							)
						},
						[548] = {
							CFrame = cFrame3 * CFrame.new(
								0,
								0.000030517578125,
								0,
								0.07899288088083267,
								0,
								0.9968751668930054,
								0,
								0.999999463558197,
								0,
								-0.9968751668930054,
								0,
								0.07899288088083267
							),
							Transparency = 0
						},
						[557] = {
							CFrame = cFrame3 * CFrame.new(
								0,
								0.000030517578125,
								0,
								0.9968751668930054,
								0,
								-0.07899288088083267,
								0,
								0.9999983906745911,
								0,
								0.07899288088083267,
								0,
								0.9968751668930054
							),
							Transparency = 1
						},
						[590] = {
							CFrame = cFrame3 * CFrame.new(
								0,
								0.000030517578125,
								0,
								0.9968751668930054,
								0,
								-0.07899288088083267,
								0,
								0.9999983906745911,
								0,
								0.07899288088083267,
								0,
								0.9968751668930054
							)
						}
					},
					[clone5] = {
						[0] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[395] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[406] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, 0, 1, 0, -1, 0, 0, 0, 0, 1)
						},
						[412] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1)
						},
						[420] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, 0, -1, 0, 1, 0, 0, 0, 0, 1)
						},
						[426] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, 0, 1, 0, -1, 0, 0, 0, 0, 1)
						},
						[432] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1)
						},
						[440] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, 0, -1, 0, 1, 0, 0, 0, 0, 1)
						},
						[445] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, 0, 1, 0, -1, 0, 0, 0, 0, 1)
						},
						[451] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1)
						},
						[459] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, 0, -1, 0, 1, 0, 0, 0, 0, 1)
						},
						[464] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, 0, 1, 0, -1, 0, 0, 0, 0, 1)
						},
						[470] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1)
						},
						[478] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, 0, -1, 0, 1, 0, 0, 0, 0, 1)
						},
						[484] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, 0, 1, 0, -1, 0, 0, 0, 0, 1)
						},
						[490] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1)
						},
						[498] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, 0, -1, 0, 1, 0, 0, 0, 0, 1)
						},
						[505] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, 0, 1, 0, -1, 0, 0, 0, 0, 1)
						},
						[511] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1)
						},
						[519] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, 0, -1, 0, 1, 0, 0, 0, 0, 1)
						},
						[523] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, 0, 1, 0, -1, 0, 0, 0, 0, 1)
						},
						[529] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1)
						},
						[537] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, 0, -1, 0, 1, 0, 0, 0, 0, 1)
						},
						[543] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, 0, 1, 0, -1, 0, 0, 0, 0, 1)
						}
					},
					[clone6] = {
						[0] = {
							CFrame = cFrame5 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 1
						},
						[395] = {
							CFrame = cFrame5 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 1
						},
						[398] = {
							CFrame = cFrame5 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0
						},
						[410] = {
							CFrame = cFrame5 * CFrame.new(
								0,
								0,
								0,
								0.04017995297908783,
								-4.046803716674295e-18,
								-0.999192476272583,
								-4.046803716674295e-18,
								1,
								-4.2128064579045e-18,
								0.999192476272583,
								4.2128064579045e-18,
								0.04017995297908783
							)
						},
						[424] = {
							CFrame = cFrame5 * CFrame.new(
								0,
								0,
								0,
								-0.999192476272583,
								0,
								-0.04017995297908783,
								0,
								1,
								0,
								0.04017995297908783,
								0,
								-0.999192476272583
							)
						},
						[434] = {
							CFrame = cFrame5 * CFrame.new(
								0,
								0,
								0,
								-0.04017995297908783,
								0,
								0.999192476272583,
								0,
								1,
								0,
								-0.999192476272583,
								0,
								-0.04017995297908783
							)
						},
						[449] = {
							CFrame = cFrame5 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[461] = {
							CFrame = cFrame5 * CFrame.new(
								0,
								0,
								0,
								0.04017995297908783,
								-4.046803716674295e-18,
								-0.999192476272583,
								-4.046803716674295e-18,
								1,
								-4.2128064579045e-18,
								0.999192476272583,
								4.2128064579045e-18,
								0.04017995297908783
							)
						},
						[475] = {
							CFrame = cFrame5 * CFrame.new(
								0,
								0,
								0,
								-0.999192476272583,
								0,
								-0.04017995297908783,
								0,
								1,
								0,
								0.04017995297908783,
								0,
								-0.999192476272583
							)
						},
						[485] = {
							CFrame = cFrame5 * CFrame.new(
								0,
								0,
								0,
								-0.04017995297908783,
								0,
								0.999192476272583,
								0,
								1,
								0,
								-0.999192476272583,
								0,
								-0.04017995297908783
							)
						},
						[493] = {
							CFrame = cFrame5 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[505] = {
							CFrame = cFrame5 * CFrame.new(
								0,
								0,
								0,
								0.04017995297908783,
								-4.046803716674295e-18,
								-0.999192476272583,
								-4.046803716674295e-18,
								1,
								-4.2128064579045e-18,
								0.999192476272583,
								4.2128064579045e-18,
								0.04017995297908783
							)
						},
						[519] = {
							CFrame = cFrame5 * CFrame.new(
								0,
								0,
								0,
								-0.999192476272583,
								0,
								-0.04017995297908783,
								0,
								1,
								0,
								0.04017995297908783,
								0,
								-0.999192476272583
							)
						},
						[529] = {
							CFrame = cFrame5 * CFrame.new(
								0,
								0,
								0,
								-0.04017995297908783,
								0,
								0.999192476272583,
								0,
								1,
								0,
								-0.999192476272583,
								0,
								-0.04017995297908783
							)
						},
						[538] = {
							CFrame = cFrame5 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0
						},
						[543] = {
							CFrame = cFrame5 * CFrame.new(
								0,
								0,
								0,
								0.04017995297908783,
								-4.046803716674295e-18,
								-0.999192476272583,
								-4.046803716674295e-18,
								1,
								-4.2128064579045e-18,
								0.999192476272583,
								4.2128064579045e-18,
								0.04017995297908783
							),
							Transparency = 1
						}
					},
					[clone7] = {
						[0] = {
							CFrame = cFrame6 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 1,
							Size = createVector(0.015014648, 0.001, 0.015014648)
						},
						[394] = {
							CFrame = cFrame6 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 1,
							Size = createVector(0.015014648, 0.001, 0.015014648)
						},
						[395] = {
							Transparency = 0
						},
						[398] = {
							CFrame = cFrame6 * CFrame.new(0, 613, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(1536.3729, 98.50474, 1536.3729)
						},
						[404] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(606.6896, 38.828136, 606.6896)
						},
						[406] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015625, 0.001, 0.015625)
						},
						[407] = {
							CFrame = cFrame6 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015014648, 0.001, 0.015014648)
						},
						[411] = {
							CFrame = cFrame6 * CFrame.new(0, 613, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(1536.3729, 98.50474, 1536.3729)
						},
						[417] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(606.6896, 38.828136, 606.6896)
						},
						[419] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015625, 0.001, 0.015625)
						},
						[420] = {
							CFrame = cFrame6 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015014648, 0.001, 0.015014648)
						},
						[424] = {
							CFrame = cFrame6 * CFrame.new(0, 613, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(1536.3729, 98.50474, 1536.3729)
						},
						[430] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(606.6896, 38.828136, 606.6896)
						},
						[432] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015625, 0.001, 0.015625)
						},
						[433] = {
							CFrame = cFrame6 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015014648, 0.001, 0.015014648)
						},
						[437] = {
							CFrame = cFrame6 * CFrame.new(0, 613, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(1536.3729, 98.50474, 1536.3729)
						},
						[443] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(606.6896, 38.828136, 606.6896)
						},
						[445] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015625, 0.001, 0.015625)
						},
						[446] = {
							CFrame = cFrame6 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015014648, 0.001, 0.015014648)
						},
						[450] = {
							CFrame = cFrame6 * CFrame.new(0, 613, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(1536.3729, 98.50474, 1536.3729)
						},
						[456] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(606.6896, 38.828136, 606.6896)
						},
						[458] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015625, 0.001, 0.015625)
						},
						[459] = {
							CFrame = cFrame6 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015014648, 0.001, 0.015014648)
						},
						[463] = {
							CFrame = cFrame6 * CFrame.new(0, 613, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(1536.3729, 98.50474, 1536.3729)
						},
						[469] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(606.6896, 38.828136, 606.6896)
						},
						[471] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015625, 0.001, 0.015625)
						},
						[472] = {
							CFrame = cFrame6 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015014648, 0.001, 0.015014648)
						},
						[476] = {
							CFrame = cFrame6 * CFrame.new(0, 613, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(1536.3729, 98.50474, 1536.3729)
						},
						[482] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(606.6896, 38.828136, 606.6896)
						},
						[484] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015625, 0.001, 0.015625)
						},
						[485] = {
							CFrame = cFrame6 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015014648, 0.001, 0.015014648)
						},
						[489] = {
							CFrame = cFrame6 * CFrame.new(0, 613, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(1536.3729, 98.50474, 1536.3729)
						},
						[495] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(606.6896, 38.828136, 606.6896)
						},
						[497] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015625, 0.001, 0.015625)
						},
						[498] = {
							CFrame = cFrame6 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015014648, 0.001, 0.015014648)
						},
						[502] = {
							CFrame = cFrame6 * CFrame.new(0, 613, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(1536.3729, 98.50474, 1536.3729)
						},
						[508] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(606.6896, 38.828136, 606.6896)
						},
						[510] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015625, 0.001, 0.015625)
						},
						[511] = {
							CFrame = cFrame6 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015014648, 0.001, 0.015014648)
						},
						[515] = {
							CFrame = cFrame6 * CFrame.new(0, 613, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(1536.3729, 98.50474, 1536.3729)
						},
						[521] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(606.6896, 38.828136, 606.6896)
						},
						[523] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015625, 0.001, 0.015625)
						},
						[524] = {
							CFrame = cFrame6 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015014648, 0.001, 0.015014648)
						},
						[528] = {
							CFrame = cFrame6 * CFrame.new(0, 613, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(1536.3729, 98.50474, 1536.3729)
						},
						[534] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(606.6896, 38.828136, 606.6896)
						},
						[536] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015625, 0.001, 0.015625)
						},
						[537] = {
							CFrame = cFrame6 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015014648, 0.001, 0.015014648)
						},
						[541] = {
							CFrame = cFrame6 * CFrame.new(0, 613, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(1536.3729, 98.50474, 1536.3729)
						},
						[547] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(606.6896, 38.828136, 606.6896)
						},
						[549] = {
							CFrame = cFrame6 * CFrame.new(0, 1092.23388671875, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 0,
							Size = createVector(0.015625, 0.001, 0.015625)
						}
					},
					[clone8] = {
						[0] = {
							CFrame = cFrame7 * CFrame.new(
								-0.733551025390625,
								0.9926724433898926,
								-1.2054100036621094,
								0.9962489604949951,
								-2.9802322387695312e-8,
								-0.08653663098812103,
								5.21540641784668e-8,
								1,
								2.9802322387695312e-8,
								0.08653655648231506,
								-8.940696716308594e-8,
								0.9962486624717712
							)
						},
						[27] = {
							CFrame = cFrame7 * CFrame.new(
								-0.733551025390625,
								0.9926724433898926,
								-1.2054100036621094,
								0.9962489604949951,
								-2.9802322387695312e-8,
								-0.08653663098812103,
								5.21540641784668e-8,
								1,
								2.9802322387695312e-8,
								0.08653655648231506,
								-8.940696716308594e-8,
								0.9962486624717712
							)
						},
						[51] = {
							CFrame = cFrame7 * CFrame.new(
								0.07341766357421875,
								-0.5364651679992676,
								-10.49560260772705,
								0.9962489604949951,
								-2.9802322387695312e-8,
								-0.08653663098812103,
								5.21540641784668e-8,
								1,
								2.9802322387695312e-8,
								0.08653655648231506,
								-8.940696716308594e-8,
								0.9962486624717712
							)
						}
					},
					[clone9.Decal] = {
						[0] = {
							Transparency = 1
						},
						[394] = {
							Transparency = 1
						},
						[402] = {
							Transparency = 0
						},
						[533] = {
							Transparency = 0
						},
						[549] = {
							Transparency = 1
						}
					},
					[clone9] = {
						[0] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[394] = {
							CFrame = cFrame8 * CFrame.new(
								0,
								0,
								0,
								1,
								0,
								5.960464477539063e-8,
								0,
								1,
								0,
								-5.960464477539063e-8,
								0,
								1
							)
						},
						[402] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[407] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0.000011444091796875, 0, 0, -1, 0, 1, 0, 1, 0, 0)
						},
						[412] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0.0000209808349609375, -1, 0, 0, 0, 1, 0, 0, 0, -1)
						},
						[417] = {
							CFrame = cFrame8 * CFrame.new(
								7.62939453125e-6,
								0,
								0.000026702880859375,
								0,
								0,
								1,
								0,
								1,
								0,
								-1,
								0,
								0
							)
						},
						[422] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[427] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0.000011444091796875, 0, 0, -1, 0, 1, 0, 1, 0, 0)
						},
						[432] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0.0000209808349609375, -1, 0, 0, 0, 1, 0, 0, 0, -1)
						},
						[437] = {
							CFrame = cFrame8 * CFrame.new(
								7.62939453125e-6,
								0,
								0.000026702880859375,
								0,
								0,
								1,
								0,
								1,
								0,
								-1,
								0,
								0
							)
						},
						[441] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[446] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0.000011444091796875, 0, 0, -1, 0, 1, 0, 1, 0, 0)
						},
						[451] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0.0000209808349609375, -1, 0, 0, 0, 1, 0, 0, 0, -1)
						},
						[456] = {
							CFrame = cFrame8 * CFrame.new(
								7.62939453125e-6,
								0,
								0.000026702880859375,
								0,
								0,
								1,
								0,
								1,
								0,
								-1,
								0,
								0
							)
						},
						[461] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[466] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0.000011444091796875, 0, 0, -1, 0, 1, 0, 1, 0, 0)
						},
						[471] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0.0000209808349609375, -1, 0, 0, 0, 1, 0, 0, 0, -1)
						},
						[476] = {
							CFrame = cFrame8 * CFrame.new(
								7.62939453125e-6,
								0,
								0.000026702880859375,
								0,
								0,
								1,
								0,
								1,
								0,
								-1,
								0,
								0
							)
						},
						[480] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[485] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0.000011444091796875, 0, 0, -1, 0, 1, 0, 1, 0, 0)
						},
						[490] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0.0000209808349609375, -1, 0, 0, 0, 1, 0, 0, 0, -1)
						},
						[495] = {
							CFrame = cFrame8 * CFrame.new(
								7.62939453125e-6,
								0,
								0.000026702880859375,
								0,
								0,
								1,
								0,
								1,
								0,
								-1,
								0,
								0
							)
						},
						[500] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[505] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0.000011444091796875, 0, 0, -1, 0, 1, 0, 1, 0, 0)
						},
						[510] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0.0000209808349609375, -1, 0, 0, 0, 1, 0, 0, 0, -1)
						},
						[515] = {
							CFrame = cFrame8 * CFrame.new(
								7.62939453125e-6,
								0,
								0.000026702880859375,
								0,
								0,
								1,
								0,
								1,
								0,
								-1,
								0,
								0
							)
						},
						[519] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[524] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0.000011444091796875, 0, 0, -1, 0, 1, 0, 1, 0, 0)
						},
						[529] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0.0000209808349609375, -1, 0, 0, 0, 1, 0, 0, 0, -1)
						},
						[534] = {
							CFrame = cFrame8 * CFrame.new(
								7.62939453125e-6,
								0,
								0.000026702880859375,
								0,
								0,
								1,
								0,
								1,
								0,
								-1,
								0,
								0
							)
						},
						[539] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[544] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0.000011444091796875, 0, 0, -1, 0, 1, 0, 1, 0, 0)
						},
						[549] = {
							CFrame = cFrame8 * CFrame.new(0, 0, 0.0000209808349609375, -1, 0, 0, 0, 1, 0, 0, 0, -1)
						}
					},
					[clone10] = {
						[0] = {
							CFrame = cFrame9 * CFrame.new(
								0,
								0,
								0,
								1,
								-3.637978807091713e-12,
								0,
								-3.637978807091713e-12,
								1,
								0,
								0,
								0,
								1
							)
						},
						[395] = {
							CFrame = cFrame9 * CFrame.new(
								0,
								0,
								0,
								1,
								-3.637978807091713e-12,
								0,
								-3.637978807091713e-12,
								1,
								0,
								0,
								0,
								1
							)
						},
						[409] = {
							CFrame = cFrame9 * CFrame.new(
								0,
								0,
								0,
								1,
								-3.637978807091713e-12,
								0,
								-3.637978807091713e-12,
								1,
								0,
								0,
								0,
								1
							)
						},
						[421] = {
							CFrame = cFrame9 * CFrame.new(
								0,
								0,
								0,
								0,
								0.00011258037557126954,
								1,
								-0.00004720847573480569,
								1,
								-0.00011258036829531193,
								-1,
								-0.00004720847209682688,
								0
							)
						},
						[434] = {
							CFrame = cFrame9 * CFrame.new(
								0,
								0,
								0,
								-1,
								0.00006537189619848505,
								0,
								0.00006537189619848505,
								1,
								-0.00015978884766809642,
								0,
								-0.00015978884766809642,
								-1
							)
						},
						[447] = {
							CFrame = cFrame9 * CFrame.new(
								0,
								0,
								0,
								0,
								-0.00004720847573480569,
								-1,
								0.00011258036829531193,
								1,
								-0.00004720847573480569,
								1,
								-0.00011258037557126954,
								0
							)
						},
						[454] = {
							CFrame = cFrame9 * CFrame.new(
								0,
								0,
								0,
								1,
								-3.637978807091713e-12,
								0,
								-3.637978807091713e-12,
								1,
								0,
								0,
								0,
								1
							)
						},
						[466] = {
							CFrame = cFrame9 * CFrame.new(
								0,
								0,
								0,
								0,
								0.00011258037557126954,
								1,
								-0.00004720847573480569,
								1,
								-0.00011258036829531193,
								-1,
								-0.00004720847209682688,
								0
							)
						},
						[479] = {
							CFrame = cFrame9 * CFrame.new(
								0,
								0,
								0,
								-1,
								0.00006537189619848505,
								0,
								0.00006537189619848505,
								1,
								-0.00015978884766809642,
								0,
								-0.00015978884766809642,
								-1
							)
						},
						[492] = {
							CFrame = cFrame9 * CFrame.new(
								0,
								0,
								0,
								0,
								-0.00004720847573480569,
								-1,
								0.00011258036829531193,
								1,
								-0.00004720847573480569,
								1,
								-0.00011258037557126954,
								0
							)
						},
						[500] = {
							CFrame = cFrame9 * CFrame.new(
								0,
								0,
								0,
								1,
								-3.637978807091713e-12,
								0,
								-3.637978807091713e-12,
								1,
								0,
								0,
								0,
								1
							)
						},
						[512] = {
							CFrame = cFrame9 * CFrame.new(
								0,
								0,
								0,
								0,
								0.00011258037557126954,
								1,
								-0.00004720847573480569,
								1,
								-0.00011258036829531193,
								-1,
								-0.00004720847209682688,
								0
							)
						},
						[525] = {
							CFrame = cFrame9 * CFrame.new(
								0,
								0,
								0,
								-1,
								0.00006537189619848505,
								0,
								0.00006537189619848505,
								1,
								-0.00015978884766809642,
								0,
								-0.00015978884766809642,
								-1
							)
						},
						[538] = {
							CFrame = cFrame9 * CFrame.new(
								0,
								0,
								0,
								0,
								-0.00004720847573480569,
								-1,
								0.00011258036829531193,
								1,
								-0.00004720847573480569,
								1,
								-0.00011258037557126954,
								0
							)
						}
					},
					[clone11] = {
						[0] = {
							CFrame = v15 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[395] = {
							CFrame = v15 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[409] = {
							CFrame = v15 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[421] = {
							CFrame = v15 * CFrame.new(
								0,
								0,
								0,
								0,
								-0.000047208479372784495,
								-1,
								0.00011258037557126954,
								1,
								-0.00004720847573480569,
								1,
								-0.00011258037557126954,
								0
							)
						},
						[434] = {
							CFrame = v15 * CFrame.new(
								0,
								0,
								0,
								-1,
								0.00006537189619848505,
								0,
								0.00006537189619848505,
								1,
								-0.00015978884766809642,
								0,
								-0.00015978884766809642,
								-1
							)
						},
						[447] = {
							CFrame = v15 * CFrame.new(
								0,
								0,
								0,
								0,
								0.00011258037557126954,
								1,
								-0.000047208479372784495,
								1,
								-0.00011258036829531193,
								-1,
								-0.00004720847573480569,
								0
							)
						},
						[454] = {
							CFrame = v15 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[466] = {
							CFrame = v15 * CFrame.new(
								0,
								0,
								0,
								0,
								-0.000047208479372784495,
								-1,
								0.00011258037557126954,
								1,
								-0.00004720847573480569,
								1,
								-0.00011258037557126954,
								0
							)
						},
						[479] = {
							CFrame = v15 * CFrame.new(
								0,
								0,
								0,
								-1,
								0.00006537189619848505,
								0,
								0.00006537189619848505,
								1,
								-0.00015978884766809642,
								0,
								-0.00015978884766809642,
								-1
							)
						},
						[492] = {
							CFrame = v15 * CFrame.new(
								0,
								0,
								0,
								0,
								0.00011258037557126954,
								1,
								-0.000047208479372784495,
								1,
								-0.00011258036829531193,
								-1,
								-0.00004720847573480569,
								0
							)
						},
						[500] = {
							CFrame = v15 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[512] = {
							CFrame = v15 * CFrame.new(
								0,
								0,
								0,
								0,
								-0.000047208479372784495,
								-1,
								0.00011258037557126954,
								1,
								-0.00004720847573480569,
								1,
								-0.00011258037557126954,
								0
							)
						},
						[525] = {
							CFrame = v15 * CFrame.new(
								0,
								0,
								0,
								-1,
								0.00006537189619848505,
								0,
								0.00006537189619848505,
								1,
								-0.00015978884766809642,
								0,
								-0.00015978884766809642,
								-1
							)
						},
						[538] = {
							CFrame = v15 * CFrame.new(
								0,
								0,
								0,
								0,
								0.00011258037557126954,
								1,
								-0.000047208479372784495,
								1,
								-0.00011258036829531193,
								-1,
								-0.00004720847573480569,
								0
							)
						}
					},
					[currentCamera] = {
						[0] = {
							FieldOfView = 60
						},
						[203] = {
							FieldOfView = 60
						},
						[204] = {
							FieldOfView = 80
						},
						[391] = {},
						[392] = {
							FieldOfView = 100
						},
						[409] = {
							FieldOfView = 70
						}
					},
					[clone12] = {
						[0] = {
							CFrame = cFrame10 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Transparency = 1
						},
						[204] = {
							CFrame = cFrame10 * CFrame.new(
								0,
								-82.69082641601562,
								-0.0000152587890625,
								1,
								0,
								0,
								0,
								1.0000001192092896,
								-5.960464477539063e-8,
								0,
								5.960464477539063e-8,
								1.0000001192092896
							),
							Transparency = 1
						},
						[214] = {
							CFrame = cFrame10 * CFrame.new(
								0,
								-82.69082641601562,
								-0.0000152587890625,
								1,
								0,
								0,
								0,
								1.0000001192092896,
								-5.960464477539063e-8,
								0,
								5.960464477539063e-8,
								1.0000001192092896
							),
							Transparency = 0
						},
						[229] = {
							CFrame = cFrame10 * CFrame.new(
								0,
								-82.69082641601562,
								-0.0000152587890625,
								1,
								0,
								0,
								0,
								1.0000001192092896,
								-5.960464477539063e-8,
								0,
								5.960464477539063e-8,
								1.0000001192092896
							),
							Transparency = 0
						},
						[257] = {
							CFrame = cFrame10 * CFrame.new(
								0,
								-82.69082641601562,
								-0.0000152587890625,
								1,
								0,
								0,
								0,
								1.0000001192092896,
								-5.960464477539063e-8,
								0,
								5.960464477539063e-8,
								1.0000001192092896
							)
						},
						[392] = {
							CFrame = cFrame10 * CFrame.new(
								0,
								-490.04345703125,
								-0.0000362396240234375,
								1,
								0,
								0,
								0,
								1,
								0,
								0,
								0,
								1
							),
							Transparency = 0
						},
						[395] = {
							CFrame = cFrame10 * CFrame.new(
								0,
								-490.04345703125,
								-0.0000362396240234375,
								1,
								0,
								0,
								0,
								1,
								0,
								0,
								0,
								1
							),
							Transparency = 1
						}
					},
					Clouds = {
						[0] = {
							Density = 1,
							Cover = 0
						},
						[162] = {
							Cover = 0
						},
						[190] = {
							Cover = 1
						},
						[545] = {
							Cover = 1
						},
						[573] = {
							Cover = 0
						}
					},
					[clone21] = {
						[0] = {
							Size = 1
						},
						[84] = {
							Size = 1
						},
						[87] = {
							Size = 8
						},
						[122] = {
							Size = 1
						},
						[125] = {
							Size = 5
						},
						[150] = {
							Size = 1
						},
						[181] = {
							Size = 1
						},
						[184] = {
							Size = 8
						},
						[198] = {
							Size = 1
						},
						[204] = {
							Size = 3
						}
					},
					[highlight] = {
						[0] = {
							FillTransparency = 1
						},
						[26] = {
							FillTransparency = 1
						},
						[33] = {
							FillTransparency = 0.5
						},
						[53] = {
							FillTransparency = 1
						},
						[79] = {
							FillTransparency = 1
						},
						[81] = {
							FillTransparency = 0.15
						},
						[100] = {
							FillTransparency = 1
						},
						[180] = {
							FillTransparency = 1
						},
						[181] = {
							FillTransparency = 0
						},
						[201] = {
							FillTransparency = 1
						}
					},
					[clone22] = {
						[0] = {
							Brightness = 0,
							Saturation = 0.15000000596046448,
							Contrast = 0
						},
						[84] = {
							Brightness = 0,
							Saturation = 0.15000000596046448,
							Contrast = 0
						},
						[87] = {
							Brightness = 0.39999999999999997,
							Saturation = 0,
							Contrast = 0
						},
						[112] = {
							Brightness = 0,
							Saturation = 0.15000000596046448,
							Contrast = 0
						},
						[181] = {
							Brightness = 0,
							Saturation = 0.15000000596046448,
							Contrast = 0
						},
						[184] = {
							Brightness = 0,
							Saturation = -2,
							Contrast = 1
						},
						[200] = {
							Brightness = 0,
							Saturation = 0.15000000596046448,
							Contrast = 0
						},
						[203] = {
							Brightness = 0
						},
						[206] = {
							Brightness = 0.7999999999999999
						},
						[225] = {
							Brightness = 0
						},
						[343] = {
							Brightness = 0
						},
						[364] = {
							Brightness = 0.7999999999999999
						},
						[396] = {
							Brightness = 1
						},
						[430] = {
							Brightness = 0
						},
						[509] = {
							Brightness = 0
						},
						[538] = {
							Brightness = 0
						},
						[543] = {
							Brightness = 1
						},
						[590] = {
							Brightness = 0
						}
					},
					[cloud3] = {
						[0] = {
							CFrame = v6 * CFrame.new(
								0,
								0,
								0,
								0.9999999403953552,
								0,
								0,
								0,
								0.9999999403953552,
								-0,
								0,
								-0,
								1
							)
						},
						[205] = {
							CFrame = v6 * CFrame.new(
								0,
								0,
								0,
								0.9999999403953552,
								0,
								0,
								0,
								0.9999999403953552,
								-0,
								0,
								-0,
								1
							)
						},
						[250] = {
							CFrame = v6 * CFrame.new(
								0,
								0,
								0,
								0.11206373572349548,
								3.8743019104003906e-7,
								-0.9937009811401367,
								-3.3527612686157227e-7,
								0.9999999403953552,
								3.2782554626464844e-7,
								0.9937011003494263,
								2.980232238769531e-7,
								0.1120636835694313
							)
						},
						[312] = {
							CFrame = v6 * CFrame.new(
								0,
								0,
								0,
								-0.999956488609314,
								4.470348358154297e-7,
								0.009348304942250252,
								4.470348358154297e-7,
								1,
								2.6402994990348816e-7,
								-0.00934823602437973,
								3.2782554626464844e-7,
								-0.9999563097953796
							)
						},
						[396] = {
							CFrame = v6 * CFrame.new(
								0,
								0,
								0,
								-0.09413884580135345,
								1.7583370208740234e-6,
								0.9955589771270752,
								8.009374141693115e-7,
								1,
								-1.7881393432617188e-6,
								-0.9955592155456543,
								6.258487701416016e-7,
								-0.09413876384496689
							)
						}
					},
					["function"] = {
						[26] = function()
							for _, emitter in pairs(clone13:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v30 = emitter
								task.spawn(function()
									v30:Emit(v30:GetAttribute("EmitCount"))
								end)
							end

							for _, effect in pairs(clone8:GetDescendants()) do
								if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
									continue
								end

								local v30 = effect
								task.spawn(function()
									v30.Enabled = true
								end)
							end
						end,
						[58] = function()
							for _, effect in pairs(clone8:GetDescendants()) do
								if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
									continue
								end

								local v30 = effect
								task.spawn(function()
									v30.Enabled = false
								end)
							end
						end,
						[81] = function()
							for _, emitter in pairs(clone14:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v30 = emitter
								task.spawn(function()
									v30:Emit(v30:GetAttribute("EmitCount"))
								end)
							end

							for _, emitter in pairs(clone16:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v30 = emitter
								task.spawn(function()
									v30:Emit(v30:GetAttribute("EmitCount"))
								end)
							end

							PeodizService.HeartbeatWait({
								Time = 0.2,
								WaitTime = 0.16
							}, function(_)
								for _, part in ipairs(clone17:GetChildren()) do
									if not part:IsA("Part") then
										continue
									end

									local cFrame17 = clone14.CFrame * CFrame.new(0, -2, 0)
									part.CFrame = cFrame17
									local position = cFrame17.Position
									local v31 = part
									delay(0.1, function()
										if v31 and v31.Parent then
											v31.Position = position + Vector3.new(
												math.random(-15, 15),
												math.random(-25, 25),
												math.random(-15, 15)
											)
										end
									end)
									local v33 = part
									local position2 = position
									delay(0.15, function()
										if v33 and v33.Parent then
											v33.Position = position2 + Vector3.new(
												math.random(-30, 30),
												math.random(-15, 15),
												math.random(-25, 25)
											)
										end
									end)
								end
							end)
						end,
						[129] = function()
							for _, emitter in pairs(clone15:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v30 = emitter
								task.spawn(function()
									v30:Emit(v30:GetAttribute("EmitCount"))
								end)
							end

							for _, emitter in pairs(clone16:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v30 = emitter
								task.spawn(function()
									v30:Emit(v30:GetAttribute("EmitCount"))
								end)
							end

							PeodizService.HeartbeatWait({
								Time = 0.2,
								WaitTime = 0.16
							}, function(_)
								for _, part in ipairs(clone17:GetChildren()) do
									if not part:IsA("Part") then
										continue
									end

									local cFrame17 = clone15.CFrame * CFrame.new(0, 0, 0)
									part.CFrame = cFrame17
									local position = cFrame17.Position
									local v31 = part
									delay(0.1, function()
										if v31 and v31.Parent then
											v31.Position = position + Vector3.new(
												math.random(-5, 5),
												math.random(-5, 5),
												math.random(-5, 5)
											)
										end
									end)
									local v33 = part
									local position2 = position
									delay(0.15, function()
										if v33 and v33.Parent then
											v33.Position = position2 + Vector3.new(
												math.random(-5, 5),
												math.random(-5, 5),
												math.random(-5, 5)
											)
										end
									end)
								end
							end)
						end,
						[181] = function()
							for _, emitter in pairs(clone:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v30 = emitter
								task.spawn(function()
									v30.Enabled = true
								end)
							end

							for _, emitter in pairs(clone16:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v30 = emitter
								task.spawn(function()
									v30:Emit(v30:GetAttribute("EmitCount"))
								end)
							end

							for _, emitter in pairs(clone18:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v30 = emitter
								task.spawn(function()
									v30:Emit(v30:GetAttribute("EmitCount"))
								end)
							end

							for _, beam in pairs(windBeam:GetDescendants()) do
								if not beam:IsA("Beam") then
									continue
								end

								local v30 = beam
								task.spawn(function()
									v30.Enabled = true
								end)
							end

							PeodizService.HeartbeatWait({
								Time = 0.1,
								WaitTime = 0.16
							}, function(_)
								for _, part in ipairs(clone17:GetChildren()) do
									if not part:IsA("Part") then
										continue
									end

									local cFrame17 = clone18.CFrame * CFrame.new(0, 0, 0)
									part.CFrame = cFrame17
									local position = cFrame17.Position
									local v31 = part
									delay(0.1, function()
										if v31 and v31.Parent then
											v31.Position = position + Vector3.new(
												math.random(-5, 5),
												math.random(-5, 5),
												math.random(-5, 5)
											)
										end
									end)
									local v33 = part
									local position2 = position
									delay(0.15, function()
										if v33 and v33.Parent then
											v33.Position = position2 + Vector3.new(
												math.random(-5, 5),
												math.random(-5, 5),
												math.random(-5, 5)
											)
										end
									end)
								end
							end)
						end,
						[205] = function()
							for _, effect in pairs(clone12:GetDescendants()) do
								if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
									continue
								end

								local v30 = effect
								task.spawn(function()
									v30.Enabled = true
								end)
							end

							for _, descendant in pairs(clone2:GetDescendants()) do
								if descendant:IsA("Decal") and descendant.Name ~= "DecalX" then
									if descendant.Name == "DecalX" then
										local v30 = descendant
										task.spawn(function()
											v30.Transparency = 0.8
										end)
									else
										local v30 = descendant
										task.spawn(function()
											v30.Transparency = 0.3
										end)
									end
								elseif descendant:IsA("ParticleEmitter") then
									local v30 = descendant
									task.spawn(function()
										v30.Enabled = true
									end)
								end
							end

							PeodizService.HeartbeatWait({
								Time = 3,
								WaitTime = 0.16
							}, function(_)
								for _, part in ipairs(clone19:GetChildren()) do
									if not part:IsA("Part") then
										continue
									end

									local cFrame17 = clone12.CFrame * CFrame.new(0, -2, 0)
									part.CFrame = cFrame17
									local position = cFrame17.Position
									local v31 = part
									delay(0.1, function()
										if v31 and v31.Parent then
											v31.Position = position + Vector3.new(
												math.random(-205, 205),
												math.random(-225, 225),
												math.random(-205, 105)
											)
										end
									end)
									local v33 = part
									local position2 = position
									delay(0.15, function()
										if v33 and v33.Parent then
											v33.Position = position2 + Vector3.new(
												math.random(-205, 205),
												math.random(-225, 225),
												math.random(-205, 105)
											)
										end
									end)
								end
							end)
						end,
						[213] = function()
							for _, emitter in pairs(clone20:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v30 = emitter
								task.spawn(function()
									v30:Emit(v30:GetAttribute("EmitCount"))
								end)
							end
						end,
						[395] = function()
							for _, effect in pairs(clone12:GetDescendants()) do
								if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
									continue
								end

								local v30 = effect
								task.spawn(function()
									v30.Enabled = false
								end)
							end

							for _, descendant in pairs(clone2:GetDescendants()) do
								if descendant:IsA("Decal") then
									local v30 = descendant
									task.spawn(function()
										v30.Transparency = 1
									end)
								elseif descendant:IsA("ParticleEmitter") then
									local v30 = descendant
									task.spawn(function()
										v30.Enabled = false
									end)
								end
							end

							for _, decal in pairs(clone11:GetDescendants()) do
								if not (decal:IsA("Decal") and decal.Name == "CloudDecal") then
									continue
								end

								local v30 = decal
								task.spawn(function()
									v30.Transparency = 0.75
								end)
							end

							if clone10:FindFirstChild("CloudDecal") then
								clone10.CloudDecal.Transparency = 0.75
							end

							for _, beam in pairs(windBeam:GetDescendants()) do
								if not beam:IsA("Beam") then
									continue
								end

								local v30 = beam
								task.spawn(function()
									v30.Enabled = false
								end)
							end

							for _, effect in pairs(clone3:GetDescendants()) do
								if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
									continue
								end

								local v30 = effect
								task.spawn(function()
									v30.Enabled = true
								end)
							end

							for _, decal in pairs(clone5:GetDescendants()) do
								if not decal:IsA("Decal") then
									continue
								end

								local v30 = decal
								task.spawn(function()
									v30.Transparency = 0
								end)
							end

							for _, decal in pairs(clone11:GetDescendants()) do
								if not (decal:IsA("Decal") and decal.Name == "CloudDecal") then
									continue
								end

								local v30 = decal
								task.spawn(function()
									v30.Transparency = 1
								end)
							end
						end,
						[469] = function()
							for _, emitter in pairs(clone:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v30 = emitter
								task.spawn(function()
									v30.Enabled = false
								end)
							end
						end,
						[542] = function()
							for _, effect in pairs(clone3:GetDescendants()) do
								if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
									continue
								end

								local v30 = effect
								task.spawn(function()
									v30.Enabled = false
								end)
							end

							for _, decal in pairs(clone5:GetDescendants()) do
								if not decal:IsA("Decal") then
									continue
								end

								local v30 = decal
								task.spawn(function()
									v30.Transparency = 1
								end)
							end

							for _, list2 in pairs(v26) do
								for _, v30 in ipairs(list2) do
									v30.Enabled = false
								end
							end

							if clone10:FindFirstChild("CloudDecal") then
								clone10.CloudDecal.Transparency = 1
							end
						end
					}
				}
				task.delay(15, function()
					table.clear(v29)
				end)
				local v30 = {}
				task.delay(15, function()
					table.clear(v30)
				end)

				for k, _ in pairs(v29) do
					if typeof(k) == "Instance" then
						table.insert(v30, k)
					end
				end

				local function getDepth(parent)
					local count = 0

					while parent.Parent do
						count += 1
						parent = parent.Parent
					end

					return count
				end

				table.sort(v30, function(parent, parent2)
					local count = 0

					while parent.Parent do
						count += 1
						parent = parent.Parent
					end

					local count2 = 0

					while parent2.Parent do
						count2 += 1
						parent2 = parent2.Parent
					end

					return count < count2
				end)
				local v31 = {}
				task.delay(15, function()
					table.clear(v31)
				end)

				for _, v32 in ipairs(v30) do
					local v33 = v29[v32]

					if type(v33) ~= "table" then
						continue
					end

					local v34, v35 = CountProperties(v33)

					if not (v34 and v35) then
						continue
					end

					for k, v36 in pairs(v35) do
						local v37 = v32
						local v38 = v36
						local v39 = k
						task.spawn(function()
							local instance = v37

							if v38[0] and typeof(v38[0]) == "table" then
								for k2, v40 in pairs(v38[0]) do
									instance[k2] = v40
								end
							end

							task.spawn(function()
								local v40 = {}

								for k2, v41 in pairs(v38) do
									table.insert(v40, k2)
								end

								table.sort(v40)

								for i = 1, #v40 - 1 do
									local v41 = v40[i]
									local v42 = v40[i + 1]
									local v43 = {
										[v39] = v38[v42]
									}
									local v44 = (v42 - v41) / 60
									local tweenInfo = TweenInfo.new(
										v44,
										Enum.EasingStyle.Linear,
										Enum.EasingDirection.InOut
									)

									if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude > 200 and (instance:IsA("BlurEffect") or instance:IsA("ColorCorrectionEffect")) then
										task.wait(v44)
									elseif instance:IsA("Model") then
										if instance.PrimaryPart and instance.PrimaryPart:IsDescendantOf(instance) then
											local tween = TweenService:Create(instance.PrimaryPart, tweenInfo, v43)
											tween:Play()
											tween.Completed:Wait()
										end
									else
										local tween = TweenService:Create(instance, tweenInfo, v43)
										tween:Play()
										tween.Completed:Wait()
									end

									local v45 = i == #v40 - 1
								end
							end)
						end)
					end
				end

				local v32 = v29["function"]

				if type(v32) == "table" then
					task.spawn(function()
						local v33 = {}
						task.delay(15, function()
							table.clear(v33)
						end)

						for k, v34 in pairs(v32) do
							if type(v34) == "function" then
								table.insert(v33, k)
							end
						end

						table.sort(v33)

						for _, v34 in ipairs(v33) do
							local v35 = v32[v34]
							local v36 = v34 / 60
							task.delay(v36, v35)
						end
					end)
				end
			end)
		elseif mode == "Rumble V V2 Hold" then
			local E = ReplicatedStorage.Chest.FruitEffect.Rumble.E
			local effects = workspace.Effects
			local rootPart = v2.RootPart
			local chargeFolder = v2.ChargeFolder
			local character2 = v2.Character
			local v3 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://95606012580671",
				Volume = 1.25,
				Looped = true
			}
			local sound = PeoUtils.CreateSound(v3)
			_G.PU:Dust(sound, 15)
			sound.Parent = rootPart
			sound:Play()
			local v4 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://77522936155471",
				Volume = 1.25
			}
			local sound2 = PeoUtils.CreateSound(v4)
			_G.PU:Dust(sound2, 5)
			sound2.Parent = rootPart
			sound2:Play()

			if (rootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 250 then
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				_G.PU:Dust(colorCorrectionEffect, 2)
				colorCorrectionEffect.Brightness = 0.1
				colorCorrectionEffect.Contrast = 0.1
				colorCorrectionEffect.Parent = game.Lighting
				task.spawn(function()
					wait()
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Brightness = 0,
							Contrast = 0
						}
					):Play()
				end)
				_G.CameraShake:ShakeOnce(6, 10, 0, 0.35)
			end

			local clone = E.Charge:Clone()
			_G.PU:Dust(clone, 15)
			clone.CFrame = CFrame.new(rootPart.Position)
			clone.Parent = effects
			Utility.EmitParticles(clone)
			TweenService:Create(clone.PointLight, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Range = 16
			}):Play()

			for _, emitter in pairs(clone:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			PeodizService.HeartbeatWait({
				Time = 10
			}, function(_)
				if not chargeFolder:IsDescendantOf(character2) then
					return true
				end

				task.spawn(function()
					if clone and clone.Parent then
						clone.CFrame = CFrame.new(rootPart.Position)
					end

					local v5 = CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
						0,
						0,
						math.random(5, 10)
					)
					local v6 = CFrame.new(rootPart.CFrame.p) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * v5
					local _ = v6 * CFrame.new(0, 10, 0)
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					raycastParams.FilterDescendantsInstances = { effects }
					local raycastResult = workspace:Raycast(v6.Position, createVector(0, -10, 0), raycastParams)

					if raycastResult and raycastResult.Instance and raycastResult.Position then
						local part = Instance.new("Part")
						_G.PU:Dust(part, 2)
						part.Name = "Rock"
						part.Anchored = true
						part.CanCollide = false
						part.Massless = true
						local v7 = math.random(2, 12)
						part.Size = Vector3.new(v7, v7 / (math.random(15, 20) / 10), v7 / (math.random(15, 20) / 10)) * 0.2
						part.CFrame = CFrame.new(raycastResult.Position) * CFrame.Angles(
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random()
						)
						part.Material = raycastResult.Material
						part.Color = raycastResult.Instance.Color
						part.CollisionGroup = "Effect"
						part.Parent = effects
						TweenService:Create(
							part,
							TweenInfo.new(
								math.random(40, 50) / 100,
								Enum.EasingStyle.Exponential,
								Enum.EasingDirection.Out
							),
							{
								CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, math.random(5, 15), 0)) * CFrame.Angles(
									6.283185307179586 * math.random(),
									6.283185307179586 * math.random(),
									6.283185307179586 * math.random()
								)
							}
						):Play()
						task.spawn(function()
							wait(0.15)
							TweenService:Create(
								part,
								TweenInfo.new(
									math.random(35, 45) / 100,
									Enum.EasingStyle.Cubic,
									Enum.EasingDirection.Out
								),
								{
									Size = Vector3.new()
								}
							):Play()
						end)
					end
				end)
			end)
			task.delay(1, function()
				if sound and sound.Parent then
					TweenService:Create(sound, TweenInfo.new(0.5), {
						Volume = 0
					}):Play()
					_G.PU:Dust(sound, 1)
				end
			end)

			if clone and clone.Parent then
				Utility.ParticleHandler(clone, false)
				_G.PU:Dust(clone, 1)
			end
		elseif mode == "Rumble E V2 Hold" then
			local E = ReplicatedStorage.Chest.FruitEffect.Rumble.E
			local effects = workspace.Effects
			local rootPart = v2.RootPart
			local chargeFolder = v2.ChargeFolder
			local character2 = v2.Character
			local clone = nil
			local lastTime = tick()
			local flag = nil
			local v3 = nil
			PeodizService.HeartbeatWait({
				Time = 10
			}, function(_)
				if not chargeFolder:IsDescendantOf(character2) then
					return true
				end

				if tick() - lastTime > 1 and not flag then
					local v4 = {
						RollOffMaxDistance = 500,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.Inverse,
						SoundId = "rbxassetid://95606012580671",
						Volume = 1.25,
						Looped = true
					}
					v3 = PeoUtils.CreateSound(v4)
					_G.PU:Dust(v3, 15)
					v3.Parent = rootPart
					v3:Play()
					local v5 = {
						RollOffMaxDistance = 500,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.Inverse,
						SoundId = "rbxassetid://77522936155471",
						Volume = 1.25
					}
					local sound = PeoUtils.CreateSound(v5)
					_G.PU:Dust(sound, 5)
					sound.Parent = rootPart
					sound:Play()
					flag = true

					if (rootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 250 then
						local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
						_G.PU:Dust(colorCorrectionEffect, 2)
						colorCorrectionEffect.Brightness = 0.1
						colorCorrectionEffect.Contrast = 0.1
						colorCorrectionEffect.Parent = game.Lighting
						task.spawn(function()
							wait()
							TweenService:Create(
								colorCorrectionEffect,
								TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Brightness = 0,
									Contrast = 0
								}
							):Play()
						end)
						_G.CameraShake:ShakeOnce(6, 10, 0, 0.35)
					end

					clone = E.Charge:Clone()
					_G.PU:Dust(clone, 15)
					clone.CFrame = CFrame.new(rootPart.Position)
					clone.Parent = effects
					Utility.EmitParticles(clone)
					TweenService:Create(
						clone.PointLight,
						TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Range = 16
						}
					):Play()

					for _, emitter in pairs(clone:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end
				end

				if flag then
					task.spawn(function()
						if clone and clone.Parent then
							clone.CFrame = CFrame.new(rootPart.Position)
						end

						local v4 = CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
							0,
							0,
							math.random(5, 10)
						)
						local v5 = CFrame.new(rootPart.CFrame.p) * CFrame.Angles(
							0,
							6.283185307179586 * math.random(),
							0
						) * v4
						local _ = v5 * CFrame.new(0, 10, 0)
						local raycastParams = RaycastParams.new()
						raycastParams.FilterType = Enum.RaycastFilterType.Exclude
						raycastParams.FilterDescendantsInstances = { effects }
						local raycastResult = workspace:Raycast(v5.Position, createVector(0, -10, 0), raycastParams)

						if raycastResult and raycastResult.Instance and raycastResult.Position then
							local part = Instance.new("Part")
							_G.PU:Dust(part, 2)
							part.Name = "Rock"
							part.Anchored = true
							part.CanCollide = false
							part.Massless = true
							local v6 = math.random(2, 12)
							part.Size = Vector3.new(
								v6,
								v6 / (math.random(15, 20) / 10),
								v6 / (math.random(15, 20) / 10)
							) * 0.2
							part.CFrame = CFrame.new(raycastResult.Position) * CFrame.Angles(
								6.283185307179586 * math.random(),
								6.283185307179586 * math.random(),
								6.283185307179586 * math.random()
							)
							part.Material = raycastResult.Material
							part.Color = raycastResult.Instance.Color
							part.CollisionGroup = "Effect"
							part.Parent = effects
							TweenService:Create(
								part,
								TweenInfo.new(
									math.random(40, 50) / 100,
									Enum.EasingStyle.Exponential,
									Enum.EasingDirection.Out
								),
								{
									CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, math.random(5, 15), 0)) * CFrame.Angles(
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random()
									)
								}
							):Play()
							task.spawn(function()
								wait(0.15)
								TweenService:Create(
									part,
									TweenInfo.new(
										math.random(35, 45) / 100,
										Enum.EasingStyle.Cubic,
										Enum.EasingDirection.Out
									),
									{
										Size = Vector3.new()
									}
								):Play()
							end)
						end
					end)
				end
			end)

			if v3 and v3.Parent then
				TweenService:Create(v3, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()
				_G.PU:Dust(v3, 1)
			end

			if clone and clone.Parent then
				Utility.ParticleHandler(clone, false)
				_G.PU:Dust(clone, 1)
			end
		elseif mode == "Rumble E V2" then
			local E = ReplicatedStorage.Chest.FruitEffect.Rumble.E
			local effects = workspace.Effects
			local character2 = v2.Character
			local rootPart = v2.RootPart
			local startCF = v2.StartCF
			local cFMouse = v2.CFMouse
			local _ = v2.MaxMouse
			local fullStack = v2.FullStack
			local calc = v2.Calc
			local FOV = v2.FOV

			if localPlayer == character then
				rootPart.CFrame = CFrame.new(startCF.p, cFMouse.p)
				PeoUtils.LerpCF(rootPart, TweenInfo.new(calc, Enum.EasingStyle.Linear), cFMouse)
			end

			local v3 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://83881029445463",
				Volume = 2
			}
			local sound = PeoUtils.CreateSound(v3)
			_G.PU:Dust(sound, 5)
			sound.Parent = rootPart
			sound:Play()
			local clone = E.Mount:Clone()
			_G.PU:Dust(clone, calc + 1)
			clone.Anchored = false
			clone.Parent = character2
			local weld = Instance.new("Weld")
			weld.Part0 = clone
			weld.Part1 = rootPart
			weld.C0 = CFrame.Angles(0, 3.141592653589793, 0)
			weld.Parent = clone
			Utility.ParticleHandler(clone, true)
			task.spawn(function()
				if localPlayer == character then
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
					_G.PU:Dust(colorCorrectionEffect, 5)
					colorCorrectionEffect.Parent = game.Lighting
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							TintColor = Color3.fromRGB(167, 205, 255),
							Contrast = 0.25
						}
					):Play()
					TweenService:Create(
						currentCamera,
						TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							FieldOfView = FOV
						}
					):Play()
					wait(calc + 1)

					if fullStack then
						wait(1)
					end

					TweenService:Create(
						currentCamera,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							FieldOfView = 70
						}
					):Play()
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							TintColor = Color3.fromRGB(255, 255, 255),
							Contrast = 0
						}
					):Play()
					_G.PU:Dust(colorCorrectionEffect, 1)
				end
			end)
			tick()
			Utility.EmitParticles(clone)
			local clone2 = E.Spiral:Clone()
			_G.PU:Dust(clone2, 2)
			clone2.CFrame = CFrame.new(startCF.p, cFMouse.p) * CFrame.new(0, 0, 10)
			clone2.Parent = effects
			Utility.EmitParticles(clone2)
			PeodizService.HeartbeatWait({
				Time = calc * 0.8
			}, function(_) end)
			Utility.ParticleHandler(clone, false)
			local cframe = CFrame.new(cFMouse.p)

			if fullStack then
				local v4 = {
					{ cframe * CFrame.new(0, 0, 100), cframe * CFrame.new(0, 0, -100) },
					{
						cframe * CFrame.Angles(0, 3.9269908169872414, 0) * CFrame.new(0, 0, 100),
						cframe * CFrame.Angles(0, 3.9269908169872414, 0) * CFrame.new(0, 0, -100)
					},
					{
						cframe * CFrame.Angles(0, 4.71238898038469, 0) * CFrame.new(0, 0, 100),
						cframe * CFrame.Angles(0, 4.71238898038469, 0) * CFrame.new(0, 0, -100)
					},
					{
						cframe * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(0, 0, 100),
						cframe * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(0, 0, -100)
					},
					{
						cframe * CFrame.Angles(0, 0.7853981633974483, 0) * CFrame.new(0, 0, 100),
						cframe * CFrame.Angles(0, 0.7853981633974483, 0) * CFrame.new(0, 0, -100)
					},
					{
						cframe * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(0, 0, 100),
						cframe * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(0, 0, -100)
					},
					{
						cframe * CFrame.new(0, 100, 0) * CFrame.Angles(1.5707963267948966, 0, 0),
						cframe * CFrame.new(0, -100, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
					}
				}
				local clone3 = E.Pierce:Clone()
				_G.PU:Dust(clone3, 3)
				clone3.CFrame = v4[1][1]
				clone3.Parent = effects
				Utility.ParticleHandler(clone3, true)
				local v5 = {
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://74253494720354",
					Volume = 1.25
				}
				local sound2 = PeoUtils.CreateSound(v5)
				_G.PU:Dust(sound2, 5)
				sound2.Parent = rootPart
				sound2:Play()
				PeodizService.ForceForLoop({
					Step = #v4,
					WaitTime = 0.13333333333333333
				}, function(p)
					local v7 = v4[math.floor(p * #v4)]
					TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
						CFrame = v7[2]
					}):Play()
					TweenService:Create(
						clone3.Part,
						TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							CFrame = v7[2]
						}
					):Play()
					local clone4 = E.Spiral2:Clone()
					_G.PU:Dust(clone4, 1)
					clone4.CFrame = v7[1] * CFrame.new(0, 0, 10)
					clone4.Parent = effects
					Utility.EmitParticles(clone4)

					if (rootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 250 then
						_G.CameraShake:ShakeOnce(5, 12, 0, 0.25)
					end
				end)
				Utility.ParticleHandler(clone3, false)
			end

			local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			_G.PU:Dust(colorCorrectionEffect, 2)
			colorCorrectionEffect.Brightness = 0.15
			colorCorrectionEffect.Contrast = 0.15
			colorCorrectionEffect.Parent = game.Lighting

			if (rootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 250 then
				_G.CameraShake:ShakeOnce(6, 10, 0, 0.35)
			end

			task.spawn(function()
				wait()
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(0.75, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Brightness = 0,
						Contrast = 0
					}
				):Play()
			end)
			local clone3 = E.Impact:Clone()
			_G.PU:Dust(clone3, 3)
			clone3.CFrame = CFrame.new(cFMouse.p)
			clone3.Above.CFrame = clone3.CFrame * CFrame.new(0, 40, 0)
			clone3.Above2.CFrame = clone3.CFrame * CFrame.new(0, 70, 0)
			clone3.Parent = effects
			Utility.EmitParticles(clone3)
			Utility.ParticleHandler(clone3, true)
			local v4 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://115121417589295",
				Volume = 1.25
			}
			local sound2 = PeoUtils.CreateSound(v4)
			_G.PU:Dust(sound2, 5)
			sound2.Parent = clone3
			sound2:Play()

			if (rootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 250 then
				_G.CameraShake:ShakeOnce(8, 16, 0, 0.35)
			end

			tick()
			PeodizService.HeartbeatWait({
				Time = 1,
				WaitTime = 0.05
			}, function()
				if (rootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 250 then
					_G.CameraShake:ShakeOnce(4, 5, 0, 0.1)
				end

				task.spawn(function()
					PeodizService.ForceForLoop({
						Step = 2
					}, function(_)
						local v5 = CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
							0,
							0,
							math.random(20, 120)
						)
						local v6 = CFrame.new(rootPart.CFrame.p) * CFrame.Angles(
							0,
							6.283185307179586 * math.random(),
							0
						) * v5
						local _ = v6 * CFrame.new(0, 100, 0)
						local raycastParams = RaycastParams.new()
						raycastParams.FilterType = Enum.RaycastFilterType.Exclude
						raycastParams.FilterDescendantsInstances = { effects }
						local raycastResult = workspace:Raycast(v6.Position, createVector(0, -45, 0), raycastParams)

						if raycastResult and raycastResult.Instance and raycastResult.Position then
							local part = Instance.new("Part")
							_G.PU:Dust(part, 2)
							part.Name = "Rock"
							part.Anchored = true
							part.CanCollide = false
							part.Massless = true
							local v7 = math.random(2, 12)
							part.Size = Vector3.new(
								v7,
								v7 / (math.random(15, 20) / 10),
								v7 / (math.random(15, 20) / 10)
							) * 1.25
							part.CFrame = CFrame.new(raycastResult.Position) * CFrame.Angles(
								6.283185307179586 * math.random(),
								6.283185307179586 * math.random(),
								6.283185307179586 * math.random()
							)
							part.Material = raycastResult.Material
							part.Color = raycastResult.Instance.Color
							part.CollisionGroup = "Effect"
							part.Parent = effects
							TweenService:Create(
								part,
								TweenInfo.new(
									math.random(40, 50) / 100,
									Enum.EasingStyle.Exponential,
									Enum.EasingDirection.Out
								),
								{
									CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, math.random(80, 120), 0)) * CFrame.Angles(
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random()
									)
								}
							):Play()
							task.spawn(function()
								wait(0.15)
								TweenService:Create(
									part,
									TweenInfo.new(
										math.random(35, 45) / 100,
										Enum.EasingStyle.Cubic,
										Enum.EasingDirection.Out
									),
									{
										Size = Vector3.new()
									}
								):Play()
							end)
						end
					end)
				end)
			end)
			Utility.ParticleHandler(clone3, false)

			if fullStack then
				wait()

				if (rootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 250 then
					_G.CameraShake:ShakeOnce(12, 19, 0, 0.5)
				end

				local clone4 = E.exp:Clone()
				_G.PU:Dust(clone4, 3)
				clone4.CFrame = CFrame.new(cFMouse.p)
				clone4.Parent = effects
				Utility.EmitParticles(clone4)
				local v5 = {
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://73770886257886",
					Volume = 1.25
				}
				local sound3 = PeoUtils.CreateSound(v5)
				_G.PU:Dust(sound3, 5)
				sound3.Parent = clone4
				sound3:Play()
				local colorCorrectionEffect2 = Instance.new("ColorCorrectionEffect")
				_G.PU:Dust(colorCorrectionEffect2, 2)
				colorCorrectionEffect2.Brightness = 0.15
				colorCorrectionEffect2.Contrast = 0.15
				colorCorrectionEffect2.Parent = game.Lighting
				local v6 = {
					Smaller = {
						Size = createVector(16.25, 24.375, 24.375),
						Duration = 1,
						Amount = 24,
						Radius = 80,
						Chance = 85
					},
					Bigger = {
						Size = createVector(18.75, 28.125, 28.125),
						Duration = 1,
						Amount = 21.12,
						Radius = 100,
						Chance = 85
					}
				}
				task.delay(30, function()
					table.clear(v6)
				end)
				RockModule.Rocks(CFrame.new(cFMouse.p), {
					RockSize = v6.Smaller.Size,
					Duration = v6.Smaller.Duration,
					Amount = v6.Smaller.Amount,
					Radius = v6.Smaller.Radius,
					Chance = v6.Smaller.Chance
				})
				RockModule.Rocks(CFrame.new(cFMouse.p), {
					RockSize = v6.Bigger.Size,
					Duration = v6.Bigger.Duration,
					Amount = v6.Bigger.Amount,
					Radius = v6.Bigger.Radius,
					Chance = v6.Bigger.Chance
				})
				task.spawn(function()
					wait()
					TweenService:Create(
						colorCorrectionEffect2,
						TweenInfo.new(0.75, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							Brightness = 0,
							Contrast = 0
						}
					):Play()
				end)
				PeodizService.ForLoop({
					Step = 16
				}, function(_)
					local v7 = CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
						0,
						0,
						math.random(20, 120)
					)
					local v8 = CFrame.new(rootPart.CFrame.p) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * v7
					local v9 = v8 * CFrame.new(0, 100, 0)
					local v10 = math.random(80, 150) / 100
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					raycastParams.FilterDescendantsInstances = { effects }
					local raycastResult = workspace:Raycast(v8.Position, createVector(0, -45, 0), raycastParams)

					if raycastResult and raycastResult.Instance and raycastResult.Position then
						local part = Instance.new("Part")
						_G.PU:Dust(part, 5)
						part.Name = "Rock"
						part.Anchored = false
						part.CanCollide = true
						part.Massless = true
						local v11 = math.random(2, 12)
						part.Size = Vector3.new(v11, v11 / (math.random(15, 20) / 10), v11 / (math.random(15, 20) / 10)) * 1.25
						part.CFrame = CFrame.new(raycastResult.Position) * CFrame.Angles(
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random()
						)
						part.Material = raycastResult.Material
						part.Color = raycastResult.Instance.Color
						part.CollisionGroup = "Effect"
						part.Parent = effects
						local _ = v8.UpVector * 200 + v8.RightVector * 90
						local attachment = Instance.new("Attachment")
						attachment.Parent = part
						local alignPosition = Instance.new("AlignPosition")
						_G.PU:Dust(alignPosition, 0.3)
						alignPosition.ApplyAtCenterOfMass = true
						alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
						alignPosition.Attachment0 = attachment
						alignPosition.ForceLimitMode = Enum.ForceLimitMode.PerAxis
						alignPosition.MaxAxesForce = createVector(750000, 750000, 750000)
						alignPosition.Responsiveness = 25
						alignPosition.Position = v9.p
						alignPosition.Parent = rootPart
						task.delay(0.2, function()
							task.wait(v10)
							TweenService:Create(
								part,
								TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.In),
								{
									Size = Vector3.new()
								}
							):Play()
							task.wait(1)
							part:Destroy()
						end)
					end
				end)
			end
		elseif mode == "Striker M1" then
			local effects = workspace.Effects
			local striker = ReplicatedStorage.Chest.MeleeEffect.Striker
			local rootPart = v2.RootPart
			local v3 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 25,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://138283878366574",
				Volume = 0.45
			}
			local sound = PeoUtils.CreateSound(v3)
			_G.PU:Dust(sound, 3)
			sound.Parent = rootPart
			sound:Play()
			local v4 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 25,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://106234829193650",
				Volume = 0.45
			}
			local sound2 = PeoUtils.CreateSound(v4)
			_G.PU:Dust(sound2, 3)
			sound2.Parent = rootPart
			sound2:Play()
			local clone = striker.M1:Clone()
			_G.PU:Dust(clone, 5)
			clone.CFrame = rootPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(-1.5707963267948966, 0, 0)
			clone.Parent = effects
			Utility.EmitParticles(clone)
			PeodizService.new({
				Time = 2
			}, function(_)
				if clone and not clone.Parent then
					return true
				end

				clone.CFrame = rootPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(-1.5707963267948966, 0, 0)
			end)
		elseif mode == "Striker Z" then
			local effects = workspace.Effects
			local skillZ = ReplicatedStorage.Chest.MeleeEffect.Striker.SkillZ
			local rootPart = v2.RootPart
			local football = v2.Football
			local _ = v2.Character
			local startCF = v2.StartCF
			local v3 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://125354453807051",
				Volume = 0.75
			}
			local sound = PeoUtils.CreateSound(v3)
			sound.Parent = rootPart
			sound:Play()
			local cFrame3 = startCF * CFrame.new(
				0.000213623047,
				-0.000459194183,
				-5.37986755,
				1.00000143,
				-8.94070524e-8,
				-2.23517631e-8,
				-2.23517542e-8,
				-1.40569185e-7,
				1.00000143,
				8.9407024e-8,
				-1,
				-1.85272413e-7
			)
			local cFrame4 = startCF * CFrame.new(
				-0.353546143,
				3.50436378,
				-13.0686836,
				1,
				5.68434189e-14,
				-1.332311e-14,
				1.332311e-14,
				0,
				-1,
				5.68434189e-14,
				1,
				0
			)
			local clone = skillZ.FakeBall:Clone()
			clone.CFrame = cFrame3
			clone.Parent = effects
			local clone2 = skillZ.Stook:Clone()
			clone2.CFrame = startCF * CFrame.new(
				1.40957642,
				0.943711519,
				-1.36172104,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			clone2.Parent = effects
			local clone3 = skillZ.Impact:Clone()
			clone3.CFrame = startCF * CFrame.new(
				0.0483093262,
				0.0378956795,
				-5.57014084,
				1,
				-5.36439984e-7,
				-1.34110778e-7,
				1.34110863e-7,
				1.34110095e-7,
				1,
				-5.36439927e-7,
				-1,
				1.34110167e-7
			)
			clone3.Parent = effects
			local clone4 = skillZ.Ground:Clone()
			clone4.CFrame = startCF * CFrame.new(0, 0, -81.408)
			clone4.Parent = effects
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			local cFrame = clone4.CFrame
			local position = cFrame.Position
			local raycastResult = workspace:Raycast(
				position + createVector(0, 10, 0),
				createVector(0, -50, 0),
				raycastParams
			)

			if raycastResult then
				local Y = raycastResult.Position.Y
				local vector2 = Vector3.new(position.X, Y, position.Z)
				local v6 = vector2 + Vector3.new(cFrame.LookVector.X, 0, cFrame.LookVector.Z)
				clone4.CFrame = CFrame.lookAt(vector2, v6, createVector(0, 1, 0))
			else
				clone4:Destroy()
			end

			local fakeBallWeld = clone.FakeBallWeld
			local clone5 = skillZ.Mesh1:Clone()
			clone5.CFrame = cFrame4
			clone5.Parent = effects
			local clone6 = game.Lighting.Blur:Clone()
			clone6.Parent = game.Lighting
			local clone7 = game.Lighting.ColorCorrection:Clone()
			clone7.Parent = game.Lighting
			_G.PU:Dust({
				sound,
				clone,
				clone2,
				clone3,
				clone4,
				clone5,
				clone6,
				clone7
			}, 5)

			local function CountProperties(items)
				local result2 = {}
				local v6 = 1

				for k, item in pairs(items) do
					local count = 0

					for k2, v7 in pairs(item) do
						if not result2[k2] then
							result2[k2] = {}
						end

						result2[k2][k] = v7
						count += 1
					end

					if v6 < count then
						v6 = count
					end
				end

				for _, list2 in pairs(result2) do
					table.sort(list2)
				end

				return v6, result2
			end

			task.spawn(function()
				local v6 = {
					[clone] = {
						[0] = {
							CFrame = cFrame3 * CFrame.new(
								0,
								0,
								0,
								1.0000028610229492,
								-1.7881410485642846e-7,
								-4.4703611479235406e-8,
								-1.7881410485642846e-7,
								1,
								4.470302883419208e-8,
								-4.4703611479235406e-8,
								4.470302883419208e-8,
								1.0000028610229492
							),
							Transparency = 1
						},
						[36.666666666666664] = {
							CFrame = cFrame3 * CFrame.new(
								0,
								0,
								0,
								1.0000028610229492,
								-1.7881410485642846e-7,
								-4.4703611479235406e-8,
								-1.7881410485642846e-7,
								1,
								4.470302883419208e-8,
								-4.4703611479235406e-8,
								4.470302883419208e-8,
								1.0000028610229492
							),
							Transparency = 1
						},
						[37.333333333333336] = {
							Transparency = 0
						},
						[44] = {
							CFrame = cFrame3 * CFrame.new(
								0,
								162.10386657714844,
								0.000016689300537109375,
								1.0000028610229492,
								-1.7881410485642846e-7,
								-4.4703611479235406e-8,
								-1.7881410485642846e-7,
								1,
								4.470302883419208e-8,
								-4.4703611479235406e-8,
								4.470302883419208e-8,
								1.0000028610229492
							),
							Transparency = 0
						},
						[44.666666666666664] = {
							Transparency = 1
						}
					},
					[clone6] = {
						[0] = {
							Size = 1
						},
						[33.333333333333336] = {
							Size = 1
						},
						[36] = {
							Size = 14
						},
						[56.666666666666664] = {
							Size = 1
						}
					},
					[clone7] = {
						[0] = {
							Brightness = 0
						},
						[36] = {
							Brightness = 0
						},
						[37.333333333333336] = {
							Brightness = 0.3
						},
						[40.666666666666664] = {
							Brightness = 0
						}
					},
					[clone5] = {
						[0] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[37.333333333333336] = {
							CFrame = cFrame4 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[40] = {
							CFrame = cFrame4 * CFrame.new(
								0,
								-41.18185043334961,
								0,
								0.002035930287092924,
								0,
								0.9999979138374329,
								0,
								1,
								0,
								-0.9999979138374329,
								0,
								0.002035930287092924
							)
						},
						[42.666666666666664] = {
							CFrame = cFrame4 * CFrame.new(
								0,
								-71.53778076171875,
								0,
								-0.999967634677887,
								0,
								0.008044425398111343,
								0,
								1,
								0,
								-0.008044425398111343,
								0,
								-0.999967634677887
							)
						},
						[47.333333333333336] = {
							CFrame = cFrame4 * CFrame.new(
								0,
								-99.92255401611328,
								0,
								-0.12602925300598145,
								0,
								-0.9920265078544617,
								0,
								1,
								0,
								0.9920265078544617,
								0,
								-0.12602925300598145
							)
						},
						[51.333333333333336] = {
							CFrame = cFrame4 * CFrame.new(
								0,
								-132.4966583251953,
								0,
								0.9988826513290405,
								0,
								-0.047259196639060974,
								0,
								1,
								0,
								0.047259196639060974,
								0,
								0.9988826513290405
							)
						}
					},
					[clone5.HazeDecal] = {
						[0] = {
							Transparency = 1
						},
						[37.333333333333336] = {
							Transparency = 1
						},
						[38] = {
							Transparency = 0.85
						},
						[51.333333333333336] = {
							Transparency = 1
						}
					},
					["function"] = {
						[0] = function()
							if football and football.Parent then
								for _, emitter in pairs(football:GetDescendants()) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									local v7 = emitter
									task.spawn(function()
										v7:Emit(v7:GetAttribute("EmitCount"))
										v7.Enabled = true
									end)
								end
							end
						end,
						[20] = function()
							for _, emitter in pairs(clone2:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v7 = emitter
								task.spawn(function()
									v7:Emit(v7:GetAttribute("EmitCount"))
								end)
							end
						end,
						[37.333333333333336] = function()
							if football and football.Parent and football:FindFirstChild("BallMesh") then
								football.BallMesh.Transparency = 1
							end

							task.delay(0.5, function()
								if football and football.Parent and football:FindFirstChild("BallMesh") then
									football.BallMesh.Transparency = 0
								end
							end)
							local v7 = {
								RollOffMaxDistance = 500,
								RollOffMinDistance = 50,
								RollOffMode = Enum.RollOffMode.Inverse,
								SoundId = "rbxassetid://102178512045292",
								Volume = 0.75
							}
							local sound2 = PeoUtils.CreateSound(v7)
							_G.PU:Dust(sound2, 5)
							sound2.Parent = rootPart
							sound2:Play()

							for _, emitter in pairs(clone3:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v8 = emitter
								task.spawn(function()
									v8:Emit(v8:GetAttribute("EmitCount"))
								end)
							end

							if football and football.Parent then
								for _, emitter in pairs(football:GetDescendants()) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									local v8 = emitter
									task.spawn(function()
										v8.Enabled = false
									end)
								end
							end

							if clone4 and clone4.Parent then
								for _, emitter in pairs(clone4:GetDescendants()) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									local v8 = emitter
									task.spawn(function()
										v8:Emit(v8:GetAttribute("EmitCount"))
									end)
								end
							end

							for _, effect in pairs(fakeBallWeld:GetDescendants()) do
								if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
									continue
								end

								effect.Enabled = true
							end
						end,
						[44] = function()
							for _, effect in pairs(fakeBallWeld:GetDescendants()) do
								if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
									continue
								end

								effect.Enabled = false
							end
						end
					}
				}
				task.delay(15, function()
					table.clear(v6)
				end)
				local v7 = {}
				task.delay(15, function()
					table.clear(v7)
				end)

				for k, _ in pairs(v6) do
					if typeof(k) == "Instance" then
						table.insert(v7, k)
					end
				end

				local function getDepth(parent)
					local count = 0

					while parent.Parent do
						count += 1
						parent = parent.Parent
					end

					return count
				end

				table.sort(v7, function(parent, parent2)
					local count = 0

					while parent.Parent do
						count += 1
						parent = parent.Parent
					end

					local count2 = 0

					while parent2.Parent do
						count2 += 1
						parent2 = parent2.Parent
					end

					return count < count2
				end)
				local instances = {}
				task.delay(15, function()
					table.clear(instances)
				end)

				for _, v8 in ipairs(v7) do
					local v9 = v6[v8]

					if type(v9) ~= "table" then
						continue
					end

					local v10, v11 = CountProperties(v9)

					if not (v10 and v11) then
						continue
					end

					for k, v12 in pairs(v11) do
						local v13 = v8
						local v14 = v12
						local v15 = k
						task.spawn(function()
							local instance = v13
							instance.Name = v13.Name .. "_Clone"
							instance.Parent = instances[v13.Parent] or v13.Parent
							instances[v13] = instance

							if instance:IsA("BasePart") then
								instance.Parent = workspace.Effects
							end

							if v14[0] and typeof(v14[0]) == "table" then
								for k2, v16 in pairs(v14[0]) do
									instance[k2] = v16
								end
							end

							task.spawn(function()
								local v16 = {}

								for k2, v17 in pairs(v14) do
									table.insert(v16, k2)
								end

								table.sort(v16)

								for i = 1, #v16 - 1 do
									local v17 = v16[i]
									local v18 = v16[i + 1]
									local v19 = {
										[v15] = v14[v18]
									}
									local v20 = (v18 - v17) / 60
									local tweenInfo = TweenInfo.new(
										v20,
										Enum.EasingStyle.Linear,
										Enum.EasingDirection.InOut
									)

									if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude > 200 and (instance:IsA("BlurEffect") or instance:IsA("ColorCorrectionEffect")) then
										task.wait(v20)
									else
										local tween = TweenService:Create(instance, tweenInfo, v19)
										tween:Play()
										tween.Completed:Wait()
									end

									if i == #v16 - 1 then
										_G.PU:Dust(instance, v20 + 0.5)
									end
								end
							end)
						end)
					end
				end

				local v8 = v6["function"]

				if type(v8) == "table" then
					task.spawn(function()
						local v9 = {}
						task.delay(15, function()
							table.clear(v9)
						end)

						for k, v10 in pairs(v8) do
							if type(v10) == "function" then
								table.insert(v9, k)
							end
						end

						table.sort(v9)

						for _, v10 in ipairs(v9) do
							local v11 = v8[v10]
							local v12 = v10 / 60
							task.delay(v12, v11)
						end
					end)
				end
			end)
		elseif mode == "Striker X Explode" then
			local effects = workspace.Effects
			local skillX = ReplicatedStorage.Chest.MeleeEffect.Striker.SkillX
			local speed = v2.Speed
			local endCF = v2.EndCF
			local clone = skillX.Target:Clone()
			clone.CFrame = endCF
			clone.Parent = effects
			local clone2 = skillX.RandomTrail:Clone()
			clone2:PivotTo(endCF)
			clone2.Parent = effects
			_G.PU:Dust({ clone, clone2 }, 5)
			local v3 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 150,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://131243728796686",
				Volume = 0.75
			}
			local sound = PeoUtils.CreateSound(v3)
			_G.PU:Dust(sound, 5)
			sound.Parent = clone
			sound:Play()

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v4 = emitter
				task.spawn(function()
					v4:Emit(v4:GetAttribute("EmitCount"))
				end)
			end

			local time = speed + 0.1
			PeodizService.HeartbeatWait({
				Time = time,
				WaitTime = 0.1
			}, function(_)
				for _, part in ipairs(clone2:GetChildren()) do
					if not part:IsA("Part") then
						continue
					end

					part.CFrame = clone.CFrame * CFrame.new(0, -2, 0)
					local v5 = part
					delay(0.1, function()
						v5.Position += Vector3.new(math.random(-40, 40), math.random(-15, 15), math.random(-25, 25))
					end)
					local v6 = part
					delay(0.2, function()
						v6.Position += Vector3.new(math.random(-40, 40), math.random(-25, 25), math.random(-30, 30))
					end)
				end
			end)
		elseif mode == "Striker X" then
			local effects = workspace.Effects
			local skillX = ReplicatedStorage.Chest.MeleeEffect.Striker.SkillX
			local rootPart = v2.RootPart
			local football = v2.Football
			local _ = v2.Character
			local startCF = v2.StartCF
			local endCF = v2.EndCF
			local _ = v2.Speed
			local target = v2.Target
			local v3 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://136920957647901",
				Volume = 0.75
			}
			local sound = PeoUtils.CreateSound(v3)
			sound.Parent = rootPart
			sound:Play()
			local v4 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://106234829193650",
				Volume = 0.75
			}
			local sound2 = PeoUtils.CreateSound(v4)
			sound2.Parent = rootPart
			sound2:Play()
			local cFrame = startCF * CFrame.new(
				0.878448486,
				-2.43938684,
				-0.792133331,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local cFrame3 = startCF * CFrame.new(
				1.88632202,
				-1.58403909,
				-0.414581299,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local cFrame4 = startCF * CFrame.new(
				0.0482788086,
				0.0378913879,
				-5.57010651,
				0.891965985,
				-0.447243422,
				0.0661111325,
				0.0224007573,
				0.189770535,
				0.981573105,
				-0.451548249,
				-0.874048769,
				0.179287434
			)
			local cFrame5 = startCF * CFrame.new(
				0.000579833984,
				-0.000386238098,
				-4.16978455,
				1,
				-5.36439984e-7,
				-1.34110806e-7,
				1.34110863e-7,
				9.03987072e-8,
				1,
				-5.36439927e-7,
				-1,
				9.03987782e-8
			)
			local v9 = startCF * CFrame.new(
				-20.6888733,
				10.0719728,
				-91.9680405,
				1,
				-5.36439984e-7,
				-1.34110806e-7,
				1.34110863e-7,
				9.03987072e-8,
				1,
				-5.36439927e-7,
				-1,
				9.03987782e-8
			)
			local _ = startCF * CFrame.new(
				15.6855164,
				20.2611732,
				-147.301758,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local clone = skillX.GetUp:Clone()
			clone.CFrame = cFrame
			clone.Parent = effects
			local clone2 = skillX.Charging:Clone()
			clone2.CFrame = cFrame3
			clone2.Parent = effects
			local clone3 = skillX.Impact:Clone()
			clone3.CFrame = cFrame4
			clone3.Parent = effects
			local clone4 = skillX.FakeBallX:Clone()
			clone4.CFrame = cFrame5
			clone4.Parent = effects
			local clone5 = skillX.RandomTrail2:Clone()
			clone5:PivotTo(v9)
			clone5.Parent = effects
			local clone6 = game.Lighting.Blur:Clone()
			clone6.Parent = game.Lighting
			local clone7 = game.Lighting.ColorCorrection:Clone()
			clone7.Parent = game.Lighting
			_G.PU:Dust({
				sound,
				sound2,
				clone,
				clone2,
				clone3,
				clone4,
				clone5,
				clone6,
				clone7
			}, 5)

			local function CountProperties(items)
				local result2 = {}
				local v10 = 1

				for k, item in pairs(items) do
					local count = 0

					for k2, v11 in pairs(item) do
						if not result2[k2] then
							result2[k2] = {}
						end

						result2[k2][k] = v11
						count += 1
					end

					if v10 < count then
						v10 = count
					end
				end

				for _, list2 in pairs(result2) do
					table.sort(list2)
				end

				return v10, result2
			end

			task.spawn(function()
				local DELAY_DURATION = 15
				local v10 = {
					[clone6] = {
						[0] = {
							Size = 1
						},
						[43] = {
							Size = 1
						},
						[46] = {
							Size = 10
						},
						[59] = {
							Size = 1
						},
						[67] = {
							Size = 1
						},
						[70] = {
							Size = 12
						},
						[91] = {
							Size = 1
						}
					},
					[clone7] = {
						[0] = {
							Brightness = 0
						},
						[67] = {
							Brightness = 0
						},
						[70] = {
							Brightness = 0.2
						},
						[80] = {
							Brightness = 0
						}
					},
					["function"] = {
						[0] = function()
							if football and football.Parent and football:FindFirstChild("BallMesh") then
								football.BallMesh.Transparency = 0
							end

							if clone4 and clone4.Parent then
								clone4.Transparency = 1
							end
						end,
						[3] = function()
							for _, emitter in pairs(clone:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v11 = emitter
								task.spawn(function()
									v11:Emit(v11:GetAttribute("EmitCount"))
								end)
							end
						end,
						[46] = function()
							for _, emitter in pairs(clone2:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v11 = emitter
								task.spawn(function()
									v11:Emit(v11:GetAttribute("EmitCount"))
									v11.Enabled = true
								end)
							end

							for _, emitter in pairs(football:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v11 = emitter
								task.spawn(function()
									v11:Emit(v11:GetAttribute("EmitCount"))
									v11.Enabled = true
								end)
							end
						end,
						[61] = function()
							for _, emitter in pairs(football:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v11 = emitter
								task.spawn(function()
									v11.Enabled = false
								end)
							end
						end,
						[70] = function()
							local v11 = {
								RollOffMaxDistance = 500,
								RollOffMinDistance = 50,
								RollOffMode = Enum.RollOffMode.Inverse,
								SoundId = "rbxassetid://140088051092091",
								Volume = 0.5
							}
							local sound3 = PeoUtils.CreateSound(v11)
							_G.PU:Dust(sound3, 5)
							sound3.Parent = rootPart
							sound3:Play()
							local v12 = {
								RollOffMaxDistance = 500,
								RollOffMinDistance = 50,
								RollOffMode = Enum.RollOffMode.Inverse,
								SoundId = "rbxassetid://99253400828781",
								Volume = 0.75
							}
							local sound4 = PeoUtils.CreateSound(v12)
							_G.PU:Dust(sound4, 5)
							sound4.Parent = rootPart
							sound4:Play()

							for _, emitter in pairs(clone2:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v13 = emitter
								task.spawn(function()
									v13.Enabled = false
								end)
							end

							for _, emitter in pairs(clone3:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v13 = emitter
								task.spawn(function()
									v13:Emit(v13:GetAttribute("EmitCount"))
								end)
							end

							for _, effect in pairs(clone4:GetDescendants()) do
								if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
									continue
								end

								local v13 = effect
								task.spawn(function()
									v13.Enabled = true
								end)
							end

							PeodizService.HeartbeatWait({
								Time = 0.65,
								WaitTime = 0.16
							}, function(_)
								for _, part in ipairs(clone5:GetChildren()) do
									if not part:IsA("Part") then
										continue
									end

									local cFrame6 = clone4.CFrame * CFrame.new(0, -2, 0)
									part.CFrame = cFrame6
									local position = cFrame6.Position
									local v14 = part
									delay(0.1, function()
										if v14 and v14.Parent then
											v14.Position = position + Vector3.new(
												math.random(-15, 15),
												math.random(-25, 25),
												math.random(-15, 15)
											)
										end
									end)
									local v16 = part
									local position2 = position
									delay(0.15, function()
										if v16 and v16.Parent then
											v16.Position = position2 + Vector3.new(
												math.random(-30, 30),
												math.random(-15, 15),
												math.random(-25, 25)
											)
										end
									end)
								end
							end)
						end,
						[72] = function()
							if football and football.Parent and football:FindFirstChild("BallMesh") then
								football.BallMesh.Transparency = 0
							end

							if clone4 and clone4.Parent then
								clone4.Transparency = 1
							end
						end,
						[73] = function()
							if clone4 and clone4.Parent then
								clone4.Transparency = 0
							end

							if football and football.Parent and football:FindFirstChild("BallMesh") then
								football.BallMesh.Transparency = 1
							end

							task.delay(0.5, function()
								if football and football.Parent and football:FindFirstChild("BallMesh") then
									football.BallMesh.Transparency = 0
								end
							end)
							local position = clone4.Position
							local position2 = target and target.Position or endCF.Position

							-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
							local function quadBezier(p, p2, p3, p4)
								return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
							end

							PeodizService.new({
								Time = 0.5
							}, function(p)
								position2 = target and target.Position or endCF.Position
								local unit = (position2 - position).Unit:Cross(createVector(0, 1, 0)).Unit
								local position3 = quadBezier(
									p,
									position,
									position:Lerp(position2, 0.5) + createVector(0, 25, 0) + unit * -45,
									position2
								)
								clone4.Position = position3
							end)

							for _, effect in pairs(clone4:GetDescendants()) do
								if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
									continue
								end

								local v11 = effect
								task.spawn(function()
									v11.Enabled = false
								end)
							end

							task.delay(0.1, function()
								clone4.Transparency = 1
							end)
						end
					}
				}
				task.delay(DELAY_DURATION, function()
					table.clear(v10)
				end)
				local v11 = {}
				task.delay(DELAY_DURATION, function()
					table.clear(v11)
				end)

				for k, _ in pairs(v10) do
					if typeof(k) == "Instance" then
						table.insert(v11, k)
					end
				end

				local function getDepth(parent)
					local count = 0

					while parent.Parent do
						count += 1
						parent = parent.Parent
					end

					return count
				end

				table.sort(v11, function(parent, parent2)
					local count = 0

					while parent.Parent do
						count += 1
						parent = parent.Parent
					end

					local count2 = 0

					while parent2.Parent do
						count2 += 1
						parent2 = parent2.Parent
					end

					return count < count2
				end)
				local instances = {}
				task.delay(DELAY_DURATION, function()
					table.clear(instances)
				end)

				for _, v12 in ipairs(v11) do
					local v13 = v10[v12]

					if type(v13) ~= "table" then
						continue
					end

					local v14, v15 = CountProperties(v13)

					if not (v14 and v15) then
						continue
					end

					for k, v16 in pairs(v15) do
						local v17 = v12
						local v18 = v16
						local v19 = k
						task.spawn(function()
							local instance = v17
							instance.Name = v17.Name .. "_Clone"
							instance.Parent = instances[v17.Parent] or v17.Parent
							instances[v17] = instance

							if instance:IsA("BasePart") then
								instance.Parent = workspace.Effects
							end

							if v18[0] and typeof(v18[0]) == "table" then
								for k2, v20 in pairs(v18[0]) do
									instance[k2] = v20
								end
							end

							task.spawn(function()
								local v20 = {}

								for k2, v21 in pairs(v18) do
									table.insert(v20, k2)
								end

								table.sort(v20)

								for i = 1, #v20 - 1 do
									local v21 = v20[i]
									local v22 = v20[i + 1]
									local v23 = {
										[v19] = v18[v22]
									}
									local v24 = (v22 - v21) / 60
									local tweenInfo = TweenInfo.new(
										v24,
										Enum.EasingStyle.Linear,
										Enum.EasingDirection.InOut
									)

									if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude > 200 and (instance:IsA("BlurEffect") or instance:IsA("ColorCorrectionEffect")) then
										task.wait(v24)
									else
										local tween = TweenService:Create(instance, tweenInfo, v23)
										tween:Play()
										tween.Completed:Wait()
									end

									if i == #v20 - 1 then
										_G.PU:Dust(instance, v24 + 0.5)
									end
								end
							end)
						end)
					end
				end

				local v12 = v10["function"]

				if type(v12) == "table" then
					task.spawn(function()
						local v13 = {}
						task.delay(15, function()
							table.clear(v13)
						end)

						for k, v14 in pairs(v12) do
							if type(v14) == "function" then
								table.insert(v13, k)
							end
						end

						table.sort(v13)

						for _, v14 in ipairs(v13) do
							local v15 = v12[v14]
							local v16 = v14 / 60
							task.delay(v16, v15)
						end
					end)
				end
			end)
		elseif mode == "Striker C" then
			local effects = workspace.Effects
			local skillC = ReplicatedStorage.Chest.MeleeEffect.Striker.SkillC
			local rootPart = v2.RootPart
			local football = v2.Football
			local _ = v2.Character
			local startCF = v2.StartCF
			local cFMouse = v2.CFMouse
			local _ = v2.Speed
			local mouseData = v2.MouseData
			local _ = startCF * CFrame.new(
				15.6855164,
				-26.7388306,
				-113.005173,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local _ = startCF * CFrame.new(
				-6.31448364,
				-3.738832,
				-134.005157,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local cFrame3 = startCF * CFrame.new(
				0.000579833984,
				-0.0903856754,
				-6.68978119,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local cFrame4 = startCF * CFrame.new(
				0.0482788086,
				0.0378913879,
				-5.57010651,
				0.891965985,
				-0.447243422,
				0.0661111325,
				0.0224007573,
				0.189770535,
				0.981573105,
				-0.451548249,
				-0.874048769,
				0.179287434
			)
			local cFrame5 = startCF * CFrame.new(
				0.0482788086,
				0.0378913879,
				-5.57010651,
				0.916804492,
				0.396858305,
				0.0444177017,
				-0.125063881,
				0.179709285,
				0.975737512,
				0.379247338,
				-0.900115669,
				0.214390934
			)
			local cFrame6 = startCF * CFrame.new(
				2.29925537,
				-1.27637124,
				-0.38142395,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local clone = skillC.TargetCrash:Clone()
			clone.CFrame = cFMouse
			clone.Parent = effects
			local clone2 = skillC.AirBubble:Clone()
			clone2.CFrame = cFMouse
			clone2.Parent = effects
			local clone3 = skillC.FakeBallC1:Clone()
			clone3.CFrame = cFrame3
			clone3.Parent = effects
			local clone4 = skillC.Impact:Clone()
			clone4.CFrame = cFrame4
			clone4.Parent = effects
			local clone5 = skillC.Impact2:Clone()
			clone5.CFrame = cFrame5
			clone5.Parent = effects
			local clone6 = skillC.Target:Clone()
			clone6.CFrame = cFMouse
			clone6.Parent = effects
			local clone7 = skillC.Charging:Clone()
			clone7.CFrame = cFrame6
			clone7.Parent = effects
			local clone8 = game.Lighting.Blur:Clone()
			clone8.Parent = game.Lighting
			_G.PU:Dust({
				clone,
				clone2,
				clone3,
				clone4,
				clone5,
				clone6,
				clone7,
				clone8
			}, 10)

			local function CountProperties(items)
				local result2 = {}
				local v7 = 1

				for k, item in pairs(items) do
					local count = 0

					for k2, v8 in pairs(item) do
						if not result2[k2] then
							result2[k2] = {}
						end

						result2[k2][k] = v8
						count += 1
					end

					if v7 < count then
						v7 = count
					end
				end

				for _, list2 in pairs(result2) do
					table.sort(list2)
				end

				return v7, result2
			end

			task.spawn(function()
				local DELAY_DURATION = 15
				local v7 = {
					[clone8] = {
						[0] = {
							Size = 1
						}
					},
					["function"] = {
						[0] = function()
							if clone3 and clone3.Parent then
								clone3.Transparency = 1
							end

							if football and football.Parent and football:FindFirstChild("BallMesh") then
								football.BallMesh.Transparency = 0
							end
						end,
						[5] = function()
							if clone3 and clone3.Parent then
								clone3.Transparency = 1
							end

							if football and football.Parent and football:FindFirstChild("BallMesh") then
								football.BallMesh.Transparency = 0
							end

							local clone9 = skillC.RandomTrail2:Clone()
							_G.PU:Dust(clone9, 3)
							clone9:PivotTo(clone3.CFrame)
							clone9.Parent = effects
							local lastTime = tick()
							local flag = true
							PeodizService.HeartbeatWait({
								Time = 0.65
							}, function()
								if clone3 and clone3.Parent and clone3:GetAttribute("Shot1") then
									return true
								end

								if tick() - lastTime > 0.1 or flag then
									if flag then
										flag = nil
									end

									lastTime = tick()

									for _, part in ipairs(clone9:GetChildren()) do
										if not part:IsA("Part") then
											continue
										end

										local cFrame = clone3.CFrame * CFrame.new(0, -2, 0)
										part.CFrame = cFrame
										local position = cFrame.Position
										local v9 = part
										delay(0.1, function()
											if v9 and v9.Parent then
												v9.Position = position + Vector3.new(
													math.random(-15, 15),
													math.random(-25, 25),
													math.random(-15, 15)
												)
											end
										end)
										local v11 = part
										local position2 = position
										delay(0.15, function()
											if v11 and v11.Parent then
												v11.Position = position2 + Vector3.new(
													math.random(-30, 30),
													math.random(-15, 15),
													math.random(-25, 25)
												)
											end
										end)
									end
								end
							end)
						end,
						[12] = function()
							local mouse12 = mouseData:GetAttribute("Mouse12")
							local lastTime = tick()

							while not mouse12 do
								mouse12 = mouseData:GetAttribute("Mouse12")

								if tick() - lastTime > 1 then
									break
								else
									task.wait()
								end
							end

							if not mouse12 then
								return
							end

							if clone3 and clone3.Parent then
								clone3.Transparency = 0
							end

							if football and football.Parent and football:FindFirstChild("BallMesh") then
								football.BallMesh.Transparency = 1
							end

							local v8 = {
								RollOffMaxDistance = 500,
								RollOffMinDistance = 50,
								RollOffMode = Enum.RollOffMode.Inverse,
								SoundId = "rbxassetid://140088051092091",
								Volume = 0.75
							}
							local sound = PeoUtils.CreateSound(v8)
							_G.PU:Dust(sound, 5)
							sound.Parent = rootPart
							sound:Play()

							for _, effect in pairs(clone3:GetDescendants()) do
								if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
									continue
								end

								local v9 = effect
								task.spawn(function()
									v9.Enabled = true
								end)
							end

							for _, emitter in pairs(clone4:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v9 = emitter
								task.spawn(function()
									v9:Emit(v9:GetAttribute("EmitCount"))
								end)
							end

							local RunService = game:GetService("RunService")
							local v9 = clone3
							local folder = clone6
							local position = cFrame3.Position
							clone6.Position = mouse12
							local unit = (mouse12 - position).Unit
							local vector2 = Vector3.new(-unit.Z, 0, unit.X)
							local v10 = (position + mouse12) / 2 + createVector(0, 25, 0) + vector2 * -55
							local total = 0

							-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
							local function quadBezier(p, p2, p3, p4)
								return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
							end

							local heartbeatConnection = nil
							heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
								total += dt
								local v11 = math.clamp(total / 0.3, 0, 1)
								local position2 = quadBezier(v11, position, v10, mouse12)
								v9.Position = position2

								if v11 >= 1 then
									heartbeatConnection:Disconnect()
									clone3:SetAttribute("Shot1", true)
									local v16 = {
										RollOffMaxDistance = 500,
										RollOffMinDistance = 150,
										RollOffMode = Enum.RollOffMode.Inverse,
										SoundId = "rbxassetid://131243728796686",
										Volume = 0.75
									}
									local sound2 = PeoUtils.CreateSound(v16)
									_G.PU:Dust(sound2, 5)
									sound2.Parent = folder
									sound2:Play()

									for _, emitter in pairs(folder:GetDescendants()) do
										if not emitter:IsA("ParticleEmitter") then
											continue
										end

										local v17 = emitter
										task.spawn(function()
											v17:Emit(v17:GetAttribute("EmitCount"))
										end)
									end

									for _, effect in pairs(clone3:GetDescendants()) do
										if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
											continue
										end

										local v17 = effect
										task.spawn(function()
											v17.Enabled = false
										end)
									end

									task.delay(0.1, function()
										clone3:SetAttribute("Start2", true)
										v9.Position = position
										v9.Transparency = 1
									end)
									local cFrame = clone6.CFrame
									local clone9 = skillC.RandomTrail:Clone()
									_G.PU:Dust(clone9, 3)
									clone9:PivotTo(cFrame)
									clone9.Parent = effects
									PeodizService.HeartbeatWait({
										Time = 0.35,
										WaitTime = 0.15
									}, function()
										for _, part in ipairs(clone9:GetChildren()) do
											if not part:IsA("Part") then
												continue
											end

											part.CFrame = cFrame * CFrame.new(0, -2, 0)
											local v17 = part
											delay(0.1, function()
												v17.Position += Vector3.new(
													math.random(-40, 40),
													math.random(-15, 15),
													math.random(-25, 25)
												)
											end)
											local v18 = part
											delay(0.2, function()
												v18.Position += Vector3.new(
													math.random(-40, 40),
													math.random(-25, 25),
													math.random(-30, 30)
												)
											end)
										end
									end)
								end
							end)
						end,
						[25] = function()
							if clone3 and clone3.Parent then
								clone3.Transparency = 0.76
							end
						end,
						[29] = function()
							if clone3 and clone3.Parent then
								clone3.Transparency = 0
							end

							if football and football.Parent and football:FindFirstChild("BallMesh") then
								football.BallMesh.Transparency = 1
							end
						end,
						[32] = function()
							if clone3 and clone3.Parent then
								clone3.Transparency = 1
							end

							if football and football.Parent and football:FindFirstChild("BallMesh") then
								football.BallMesh.Transparency = 0
							end
						end,
						[33] = function()
							PeodizService.HeartbeatWait({
								Time = 1
							}, function(_)
								if clone3 and clone3.Parent and clone3:GetAttribute("Start2") then
									return true
								end
							end)
							local clone9 = skillC.RandomTrail2:Clone()
							_G.PU:Dust(clone9, 3)
							clone9:PivotTo(clone3.CFrame)
							clone9.Parent = effects
							local lastTime = tick()
							local flag = true
							PeodizService.HeartbeatWait({
								Time = 0.65
							}, function()
								if clone3 and clone3.Parent and clone3:GetAttribute("Shot2") then
									return true
								end

								if tick() - lastTime > 0.1 or flag then
									if flag then
										flag = nil
									end

									lastTime = tick()

									for _, part in ipairs(clone9:GetChildren()) do
										if not part:IsA("Part") then
											continue
										end

										local cFrame = clone3.CFrame * CFrame.new(0, -2, 0)
										part.CFrame = cFrame
										local position = cFrame.Position
										local v9 = part
										delay(0.1, function()
											if v9 and v9.Parent then
												v9.Position = position + Vector3.new(
													math.random(-15, 15),
													math.random(-25, 25),
													math.random(-15, 15)
												)
											end
										end)
										local v11 = part
										local position2 = position
										delay(0.15, function()
											if v11 and v11.Parent then
												v11.Position = position2 + Vector3.new(
													math.random(-30, 30),
													math.random(-15, 15),
													math.random(-25, 25)
												)
											end
										end)
									end
								end
							end)
						end,
						[39] = function()
							local mouse39 = mouseData:GetAttribute("Mouse39")
							local lastTime = tick()

							while not mouse39 do
								mouse39 = mouseData:GetAttribute("Mouse39")

								if tick() - lastTime > 1 then
									break
								else
									task.wait()
								end
							end

							if not mouse39 then
								return
							end

							local v8 = {
								RollOffMaxDistance = 500,
								RollOffMinDistance = 50,
								RollOffMode = Enum.RollOffMode.Inverse,
								SoundId = "rbxassetid://140088051092091",
								Volume = 0.75
							}
							local sound = PeoUtils.CreateSound(v8)
							_G.PU:Dust(sound, 5)
							sound.Parent = rootPart
							sound:Play()

							for _, effect in pairs(clone3:GetDescendants()) do
								if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
									continue
								end

								local v9 = effect
								task.spawn(function()
									v9.Enabled = true
								end)
							end

							for _, emitter in pairs(clone5:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v9 = emitter
								task.spawn(function()
									v9:Emit(v9:GetAttribute("EmitCount"))
								end)
							end

							local RunService = game:GetService("RunService")
							local v9 = clone3
							local folder = clone6
							local position = cFrame3.Position
							folder.Position = mouse39
							local unit = (mouse39 - position).Unit
							local vector2 = Vector3.new(-unit.Z, 0, unit.X)
							local v10 = (position + mouse39) / 2 + createVector(0, 25, 0) + vector2 * 55
							local total = 0

							-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
							local function quadBezier(p, p2, p3, p4)
								return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
							end

							local heartbeatConnection = nil
							heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
								total += dt
								local v11 = math.clamp(total / 0.3, 0, 1)
								local position2 = quadBezier(v11, position, v10, mouse39)
								v9.Position = position2

								if v11 >= 1 then
									heartbeatConnection:Disconnect()
									clone3:SetAttribute("Shot2", true)
									local v16 = {
										RollOffMaxDistance = 500,
										RollOffMinDistance = 150,
										RollOffMode = Enum.RollOffMode.Inverse,
										SoundId = "rbxassetid://131243728796686",
										Volume = 0.75
									}
									local sound2 = PeoUtils.CreateSound(v16)
									_G.PU:Dust(sound2, 5)
									sound2.Parent = folder
									sound2:Play()

									for _, emitter in pairs(folder:GetDescendants()) do
										if not emitter:IsA("ParticleEmitter") then
											continue
										end

										local v17 = emitter
										task.spawn(function()
											v17:Emit(v17:GetAttribute("EmitCount"))
										end)
									end

									for _, effect in pairs(clone3:GetDescendants()) do
										if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
											continue
										end

										local v17 = effect
										task.spawn(function()
											v17.Enabled = false
										end)
									end

									task.delay(0.1, function()
										clone3:SetAttribute("Start3", true)
										v9.Position = position
										v9.Transparency = 1
									end)
									local cFrame = clone6.CFrame
									local clone9 = skillC.RandomTrail:Clone()
									_G.PU:Dust(clone9, 3)
									clone9:PivotTo(cFrame)
									clone9.Parent = effects
									PeodizService.HeartbeatWait({
										Time = 0.35,
										WaitTime = 0.15
									}, function(_)
										for _, part in ipairs(clone9:GetChildren()) do
											if not part:IsA("Part") then
												continue
											end

											part.CFrame = cFrame * CFrame.new(0, -2, 0)
											local v17 = part
											delay(0.1, function()
												v17.Position += Vector3.new(
													math.random(-40, 40),
													math.random(-15, 15),
													math.random(-25, 25)
												)
											end)
											local v18 = part
											delay(0.2, function()
												v18.Position += Vector3.new(
													math.random(-40, 40),
													math.random(-25, 25),
													math.random(-30, 30)
												)
											end)
										end
									end)
								end
							end)
						end,
						[42] = function()
							if football and football.Parent and football:FindFirstChild("BallMesh") then
								football.BallMesh.Transparency = 0
							end
						end,
						[43] = function()
							if football and football.Parent and football:FindFirstChild("BallMesh") then
								football.BallMesh.Transparency = 0
							end
						end,
						[69] = function()
							local v8 = {
								RollOffMaxDistance = 500,
								RollOffMinDistance = 50,
								RollOffMode = Enum.RollOffMode.Inverse,
								SoundId = "rbxassetid://71556810523324",
								Volume = 0.75
							}
							local sound = PeoUtils.CreateSound(v8)
							_G.PU:Dust(sound, 5)
							sound.Parent = rootPart
							sound:Play()

							for _, emitter in pairs(clone7:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v9 = emitter
								task.spawn(function()
									v9:Emit(v9:GetAttribute("EmitCount"))
									v9.Enabled = true
								end)
							end

							local cFrame = clone7.CFrame
							local clone9 = skillC.RandomTrail2:Clone()
							_G.PU:Dust(clone9, 3)
							clone9:PivotTo(cFrame)
							clone9.Parent = effects
							PeodizService.HeartbeatWait({
								Time = 0.65,
								WaitTime = 0.1
							}, function(_)
								for _, part in ipairs(clone9:GetChildren()) do
									if not part:IsA("Part") then
										continue
									end

									local cFrame7 = cFrame * CFrame.new(0, -2, 0)
									part.CFrame = cFrame7
									local position = cFrame7.Position
									local v10 = part
									delay(0.1, function()
										if v10 and v10.Parent then
											v10.Position = position + Vector3.new(
												math.random(-15, 15),
												math.random(-25, 25),
												math.random(-15, 15)
											)
										end
									end)
									local v12 = part
									local position2 = position
									delay(0.15, function()
										if v12 and v12.Parent then
											v12.Position = position2 + Vector3.new(
												math.random(-30, 30),
												math.random(-15, 15),
												math.random(-25, 25)
											)
										end
									end)
								end
							end)
						end,
						[92] = function()
							PeodizService.HeartbeatWait({
								Time = 1
							}, function(_)
								if clone3 and clone3.Parent and clone3:GetAttribute("Start3") then
									return true
								end
							end)
							local clone9 = skillC.RandomTrail2:Clone()
							_G.PU:Dust(clone9, 3)
							clone9:PivotTo(clone3.CFrame)
							clone9.Parent = effects
							local lastTime = tick()
							local flag = true
							PeodizService.HeartbeatWait({
								Time = 0.65
							}, function()
								if clone3 and clone3.Parent and clone3:GetAttribute("Shot3") then
									return true
								end

								if tick() - lastTime > 0.1 or flag then
									if flag then
										flag = nil
									end

									lastTime = tick()

									for _, part in ipairs(clone9:GetChildren()) do
										if not part:IsA("Part") then
											continue
										end

										local cFrame = clone3.CFrame * CFrame.new(0, -2, 0)
										part.CFrame = cFrame
										local position = cFrame.Position
										local v9 = part
										delay(0.1, function()
											if v9 and v9.Parent then
												v9.Position = position + Vector3.new(
													math.random(-15, 15),
													math.random(-25, 25),
													math.random(-15, 15)
												)
											end
										end)
										local v11 = part
										local position2 = position
										delay(0.15, function()
											if v11 and v11.Parent then
												v11.Position = position2 + Vector3.new(
													math.random(-30, 30),
													math.random(-15, 15),
													math.random(-25, 25)
												)
											end
										end)
									end
								end
							end)
						end,
						[98] = function()
							local mouse98 = mouseData:GetAttribute("Mouse98")
							local lastTime = tick()

							while not mouse98 do
								mouse98 = mouseData:GetAttribute("Mouse98")

								if tick() - lastTime > 1 then
									break
								else
									task.wait()
								end
							end

							if not mouse98 then
								return
							end

							local v8 = {
								RollOffMaxDistance = 500,
								RollOffMinDistance = 50,
								RollOffMode = Enum.RollOffMode.Inverse,
								SoundId = "rbxassetid://99062599698831",
								Volume = 0.8
							}
							local sound = PeoUtils.CreateSound(v8)
							_G.PU:Dust(sound, 5)
							sound.Parent = rootPart
							sound:Play()

							for _, effect in pairs(clone3:GetDescendants()) do
								if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
									continue
								end

								local v9 = effect
								task.spawn(function()
									v9.Enabled = true
								end)
							end

							for _, emitter in pairs(clone7:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v9 = emitter
								task.spawn(function()
									v9.Enabled = false
								end)
							end

							for _, emitter in pairs(clone4:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v9 = emitter
								task.spawn(function()
									v9:Emit(v9:GetAttribute("EmitCount"))
								end)
							end

							local RunService = game:GetService("RunService")
							local v9 = clone3
							local folder = clone6
							local position = cFrame3.Position
							folder.CFrame = CFrame.new(mouse98)
							clone.CFrame = CFrame.new(mouse98)
							local v10 = clone2
							v10.CFrame = CFrame.new(mouse98)
							local unit = (mouse98 - position).Unit
							local vector2 = Vector3.new(-unit.Z, 0, unit.X)
							local v11 = (position + mouse98) / 2 + createVector(0, 45, 0) + vector2 * -85
							local total = 0

							-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
							local function quadBezier(p, p2, p3, p4)
								return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
							end

							local heartbeatConnection = nil
							heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
								total += dt
								local v12 = math.clamp(total / 0.3, 0, 1)
								local position2 = quadBezier(v12, position, v11, mouse98)
								v9.Position = position2

								if v12 >= 1 then
									heartbeatConnection:Disconnect()
									clone3:SetAttribute("Shot3", true)
									local v17 = {
										RollOffMaxDistance = 500,
										RollOffMinDistance = 150,
										RollOffMode = Enum.RollOffMode.Inverse,
										SoundId = "rbxassetid://117686262292569",
										Volume = 0.75
									}
									local sound2 = PeoUtils.CreateSound(v17)
									_G.PU:Dust(sound2, 5)
									sound2.Parent = folder
									sound2:Play()

									for _, emitter in pairs(folder:GetDescendants()) do
										if not emitter:IsA("ParticleEmitter") then
											continue
										end

										local v18 = emitter
										task.spawn(function()
											v18:Emit(v18:GetAttribute("EmitCount"))
										end)
									end

									for _, effect in pairs(clone3:GetDescendants()) do
										if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
											continue
										end

										local v18 = effect
										task.spawn(function()
											v18.Enabled = false
										end)
									end

									local tweenInfo = TweenInfo.new(
										0.1,
										Enum.EasingStyle.Sine,
										Enum.EasingDirection.Out
									)
									local tweenInfo2 = TweenInfo.new(
										0.2,
										Enum.EasingStyle.Sine,
										Enum.EasingDirection.Out
									)
									local tween = TweenService:Create(v10, tweenInfo, {
										Size = createVector(110, 110, 110)
									})
									local tween2 = TweenService:Create(v10, tweenInfo2, {
										Size = createVector(0.001, 0.001, 0.001)
									})
									tween:Play()
									task.delay(0.1, function()
										tween2:Play()
									end)
									task.delay(0.2, function()
										v9.Position = position
										v9.Transparency = 1
									end)
									local cFrame = clone.CFrame
									local clone9 = skillC.RandomTrail:Clone()
									_G.PU:Dust(clone9, 3)
									clone9:PivotTo(cFrame)
									clone9.Parent = effects
									PeodizService.HeartbeatWait({
										Time = 0.35,
										WaitTime = 0.15
									}, function(_)
										for _, part in ipairs(clone9:GetChildren()) do
											if not part:IsA("Part") then
												continue
											end

											part.CFrame = cFrame * CFrame.new(0, -2, 0)
											local v18 = part
											delay(0.1, function()
												v18.Position += Vector3.new(
													math.random(-40, 40),
													math.random(-15, 15),
													math.random(-25, 25)
												)
											end)
											local v19 = part
											delay(0.2, function()
												v19.Position += Vector3.new(
													math.random(-40, 40),
													math.random(-25, 25),
													math.random(-30, 30)
												)
											end)
										end
									end)
								end
							end)
						end,
						[100] = function()
							if football and football.Parent and football:FindFirstChild("BallMesh") then
								football.BallMesh.Transparency = 0
							end
						end,
						[101] = function()
							if football and football.Parent and football:FindFirstChild("BallMesh") then
								football.BallMesh.Transparency = 1
							end

							task.delay(0.5, function()
								if football and football.Parent and football:FindFirstChild("BallMesh") then
									football.BallMesh.Transparency = 0
								end
							end)
						end
					}
				}
				task.delay(DELAY_DURATION, function()
					table.clear(v7)
				end)
				local v8 = {}
				task.delay(DELAY_DURATION, function()
					table.clear(v8)
				end)

				for k, _ in pairs(v7) do
					if typeof(k) == "Instance" then
						table.insert(v8, k)
					end
				end

				local function getDepth(parent)
					local count = 0

					while parent.Parent do
						count += 1
						parent = parent.Parent
					end

					return count
				end

				table.sort(v8, function(parent, parent2)
					local count = 0

					while parent.Parent do
						count += 1
						parent = parent.Parent
					end

					local count2 = 0

					while parent2.Parent do
						count2 += 1
						parent2 = parent2.Parent
					end

					return count < count2
				end)
				local instances = {}
				task.delay(DELAY_DURATION, function()
					table.clear(instances)
				end)

				for _, v9 in ipairs(v8) do
					local v10 = v7[v9]

					if type(v10) ~= "table" then
						continue
					end

					local v11, v12 = CountProperties(v10)

					if not (v11 and v12) then
						continue
					end

					for k, v13 in pairs(v12) do
						local v14 = v9
						local v15 = v13
						local v16 = k
						task.spawn(function()
							local instance = v14
							instance.Name = v14.Name .. "_Clone"
							instance.Parent = instances[v14.Parent] or v14.Parent
							instances[v14] = instance

							if instance:IsA("BasePart") then
								instance.Parent = workspace.Effects
							end

							if v15[0] and typeof(v15[0]) == "table" then
								for k2, v17 in pairs(v15[0]) do
									instance[k2] = v17
								end
							end

							task.spawn(function()
								local v17 = {}

								for k2, v18 in pairs(v15) do
									table.insert(v17, k2)
								end

								table.sort(v17)

								for i = 1, #v17 - 1 do
									local v18 = v17[i]
									local v19 = v17[i + 1]
									local v20 = {
										[v16] = v15[v19]
									}
									local v21 = (v19 - v18) / 60
									local tweenInfo = TweenInfo.new(
										v21,
										Enum.EasingStyle.Linear,
										Enum.EasingDirection.InOut
									)

									if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude > 200 and (instance:IsA("BlurEffect") or instance:IsA("ColorCorrectionEffect")) then
										task.wait(v21)
									else
										local tween = TweenService:Create(instance, tweenInfo, v20)
										tween:Play()
										tween.Completed:Wait()
									end

									if i == #v17 - 1 then
										_G.PU:Dust(instance, v21 + 0.5)
									end
								end
							end)
						end)
					end
				end

				local v9 = v7["function"]

				if type(v9) == "table" then
					task.spawn(function()
						local v10 = {}
						task.delay(15, function()
							table.clear(v10)
						end)

						for k, v11 in pairs(v9) do
							if type(v11) == "function" then
								table.insert(v10, k)
							end
						end

						table.sort(v10)

						for _, v11 in ipairs(v10) do
							local v12 = v9[v11]
							local v13 = v11 / 60
							task.delay(v13, v12)
						end
					end)
				end
			end)
		elseif mode == "Striker E" then
			local effects = workspace.Effects
			local skillE = ReplicatedStorage.Chest.MeleeEffect.Striker.SkillE
			local rootPart = v2.RootPart
			local _ = v2.Football
			local character2 = v2.Character
			local startCF = v2.StartCF
			local cFMouse = v2.CFMouse
			local v3 = startCF * CFrame.new(
				3.46429443,
				-5.14818478,
				-88.5228882,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local cFrame = startCF * CFrame.new(
				10.4642944,
				3.53446031,
				-64.2564392,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local cFrame3 = startCF * CFrame.new(
				0.464294434,
				4.85181427,
				-89.5228882,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local cFrame4 = startCF * CFrame.new(
				0,
				0.199982882,
				0,
				1,
				1.332311e-14,
				5.68434189e-14,
				1.332311e-14,
				1,
				0,
				5.68434189e-14,
				0,
				1
			)
			local clone = skillE.Soru:Clone()
			clone:PivotTo(rootPart.CFrame)
			clone.Parent = effects
			local clone2 = skillE.RandomTrail:Clone()
			clone2:PivotTo(v3)
			clone2.Parent = effects
			local clone3 = skillE.Soru1:Clone()
			clone3.CFrame = cFrame
			clone3.Parent = effects
			local clone4 = skillE.Soru2:Clone()
			clone4.CFrame = cFrame3
			clone4.Parent = effects
			local clone5

			if character2:FindFirstChild("UpperTorso") then
				clone5 = skillE.TorsoTrail:Clone()
				_G.PU:Dust(clone5, 5)
				clone5.CFrame = cFrame4
				clone5.Parent = effects
				local weld = Instance.new("Weld")
				_G.PU:Dust(weld, 5)
				weld.Part0 = character2.UpperTorso
				weld.Part1 = clone5
				weld.Parent = clone5
			else
				clone5 = nil
			end

			local highlight = Instance.new("Highlight")
			highlight.Name = "FootHighlight"
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			highlight.FillColor = Color3.fromRGB(255, 255, 255)
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			highlight.Enabled = true
			highlight.Parent = character2
			_G.PU:Dust({
				clone,
				clone2,
				clone3,
				clone4,
				highlight
			}, 5)
			local position = rootPart.Position
			local position2 = cFMouse.Position
			local unit = (position2 - position).Unit
			local magnitude = (position2 - position).Magnitude
			local sideOffset = v2.SideOffset
			local v7 = position + unit * (magnitude / 3) + unit:Cross(createVector(0, 1, 0)).Unit * sideOffset
			local v8 = position + unit * (magnitude * 2 / 3) - unit:Cross(createVector(0, 1, 0)).Unit * sideOffset
			local lookVector = cFMouse.LookVector
			local cframe = CFrame.new(v7, v7 + lookVector)
			local cframe2 = CFrame.new(v8, v8 + lookVector)

			local function CountProperties(items)
				local result2 = {}
				local v9 = 1

				for k, item in pairs(items) do
					local count = 0

					for k2, v10 in pairs(item) do
						if not result2[k2] then
							result2[k2] = {}
						end

						result2[k2][k] = v10
						count += 1
					end

					if v9 < count then
						v9 = count
					end
				end

				for _, list2 in pairs(result2) do
					table.sort(list2)
				end

				return v9, result2
			end

			task.spawn(function()
				local DELAY_DURATION = 15
				local v9 = {
					[highlight] = {
						[0] = {
							FillTransparency = 1,
							OutlineTransparency = 1
						},
						[9] = {
							FillTransparency = 1,
							OutlineTransparency = 1
						},
						[11] = {
							FillTransparency = 0.2,
							OutlineTransparency = 0
						},
						[23] = {
							FillTransparency = 1,
							OutlineTransparency = 1
						},
						[24] = {
							FillTransparency = 1,
							OutlineTransparency = 1
						},
						[26] = {
							FillTransparency = 0.2,
							OutlineTransparency = 0
						},
						[37] = {
							FillTransparency = 1,
							OutlineTransparency = 1
						},
						[39] = {
							FillTransparency = 1,
							OutlineTransparency = 1
						},
						[41] = {
							FillTransparency = 0.2,
							OutlineTransparency = 0
						},
						[95] = {
							FillTransparency = 1,
							OutlineTransparency = 1
						}
					},
					["function"] = {
						[0] = function()
							if clone5 and clone5.Parent then
								for _, trail in pairs(clone5:GetDescendants()) do
									if not trail:IsA("Trail") then
										continue
									end

									local v10 = trail
									task.spawn(function()
										v10.Enabled = true
									end)
								end
							end
						end,
						[11] = function()
							if localPlayer == character and rootPart and rootPart.Parent then
								rootPart.CFrame = cframe
							end

							clone.Soru01.CFrame = cframe
							local v10 = {
								RollOffMaxDistance = 500,
								RollOffMinDistance = 50,
								RollOffMode = Enum.RollOffMode.Inverse,
								SoundId = "rbxassetid://138482293360323",
								Volume = 0.5
							}
							local sound = PeoUtils.CreateSound(v10)
							_G.PU:Dust(sound, 5)
							sound.Parent = rootPart
							sound:Play()

							for _, emitter in pairs(clone:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v11 = emitter
								task.spawn(function()
									v11:Emit(v11:GetAttribute("EmitCount"))
								end)
							end

							PeodizService.HeartbeatWait({
								Time = 0.25,
								WaitTime = 0.16
							}, function()
								for _, part in ipairs(clone2:GetChildren()) do
									if not part:IsA("Part") then
										continue
									end

									local cFrame5 = clone.Soru01.CFrame * CFrame.new(0, -2, 0)
									part.CFrame = cFrame5
									local position3 = cFrame5.Position
									local v12 = part
									delay(0.1, function()
										if v12 and v12.Parent then
											v12.Position = position3 + Vector3.new(
												math.random(-5, 5),
												math.random(-15, 15),
												math.random(-5, 5)
											)
										end
									end)
									local v14 = part
									local position4 = position3
									delay(0.15, function()
										if v14 and v14.Parent then
											v14.Position = position4 + Vector3.new(
												math.random(-10, 10),
												math.random(-15, 15),
												math.random(-25, 25)
											)
										end
									end)
								end
							end)
						end,
						[26] = function()
							if localPlayer == character and rootPart and rootPart.Parent then
								rootPart.CFrame = cframe2
							end

							clone3.CFrame = cframe2
							local v10 = {
								RollOffMaxDistance = 500,
								RollOffMinDistance = 50,
								RollOffMode = Enum.RollOffMode.Inverse,
								SoundId = "rbxassetid://138482293360323",
								Volume = 0.5
							}
							local sound = PeoUtils.CreateSound(v10)
							_G.PU:Dust(sound, 5)
							sound.Parent = rootPart
							sound:Play()

							for _, emitter in pairs(clone3:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v11 = emitter
								task.spawn(function()
									v11:Emit(v11:GetAttribute("EmitCount"))
								end)
							end

							PeodizService.HeartbeatWait({
								Time = 0.25,
								WaitTime = 0.16
							}, function()
								for _, part in ipairs(clone2:GetChildren()) do
									if not part:IsA("Part") then
										continue
									end

									local cFrame5 = clone3.CFrame * CFrame.new(0, -2, 0)
									part.CFrame = cFrame5
									local position3 = cFrame5.Position
									local v12 = part
									delay(0.1, function()
										if v12 and v12.Parent then
											v12.Position = position3 + Vector3.new(
												math.random(-5, 5),
												math.random(-15, 15),
												math.random(-5, 5)
											)
										end
									end)
									local v14 = part
									local position4 = position3
									delay(0.15, function()
										if v14 and v14.Parent then
											v14.Position = position4 + Vector3.new(
												math.random(-10, 10),
												math.random(-15, 15),
												math.random(-25, 25)
											)
										end
									end)
								end
							end)
						end,
						[41] = function()
							if localPlayer == character and rootPart and rootPart.Parent then
								rootPart.CFrame = cFMouse
							end

							clone4.CFrame = cFMouse
							local v10 = {
								RollOffMaxDistance = 500,
								RollOffMinDistance = 50,
								RollOffMode = Enum.RollOffMode.Inverse,
								SoundId = "rbxassetid://138482293360323",
								Volume = 0.5
							}
							local sound = PeoUtils.CreateSound(v10)
							_G.PU:Dust(sound, 5)
							sound.Parent = rootPart
							sound:Play()

							for _, emitter in pairs(clone4:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v11 = emitter
								task.spawn(function()
									v11:Emit(v11:GetAttribute("EmitCount"))
								end)
							end

							PeodizService.HeartbeatWait({
								Time = 0.25,
								WaitTime = 0.16
							}, function()
								for _, part in ipairs(clone2:GetChildren()) do
									if not part:IsA("Part") then
										continue
									end

									local cFrame5 = clone4.CFrame * CFrame.new(0, -2, 0)
									part.CFrame = cFrame5
									local position3 = cFrame5.Position
									local v12 = part
									delay(0.1, function()
										if v12 and v12.Parent then
											v12.Position = position3 + Vector3.new(
												math.random(-5, 5),
												math.random(-15, 15),
												math.random(-5, 5)
											)
										end
									end)
									local v14 = part
									local position4 = position3
									delay(0.15, function()
										if v14 and v14.Parent then
											v14.Position = position4 + Vector3.new(
												math.random(-10, 10),
												math.random(-15, 15),
												math.random(-25, 25)
											)
										end
									end)
								end
							end)
						end,
						[59] = function()
							if clone5 and clone5.Parent then
								for _, trail in pairs(clone5:GetDescendants()) do
									if not trail:IsA("Trail") then
										continue
									end

									local v10 = trail
									task.spawn(function()
										v10.Enabled = false
									end)
								end
							end
						end
					}
				}
				task.delay(DELAY_DURATION, function()
					table.clear(v9)
				end)
				local v10 = {}
				task.delay(DELAY_DURATION, function()
					table.clear(v10)
				end)

				for k, _ in pairs(v9) do
					if typeof(k) == "Instance" then
						table.insert(v10, k)
					end
				end

				local function getDepth(parent)
					local count = 0

					while parent.Parent do
						count += 1
						parent = parent.Parent
					end

					return count
				end

				table.sort(v10, function(parent, parent2)
					local count = 0

					while parent.Parent do
						count += 1
						parent = parent.Parent
					end

					local count2 = 0

					while parent2.Parent do
						count2 += 1
						parent2 = parent2.Parent
					end

					return count < count2
				end)
				local instances = {}
				task.delay(DELAY_DURATION, function()
					table.clear(instances)
				end)

				for _, v11 in ipairs(v10) do
					local v12 = v9[v11]

					if type(v12) ~= "table" then
						continue
					end

					local v13, v14 = CountProperties(v12)

					if not (v13 and v14) then
						continue
					end

					for k, v15 in pairs(v14) do
						local v16 = v11
						local v17 = v15
						local v18 = k
						task.spawn(function()
							local instance = v16
							instance.Name = v16.Name .. "_Clone"
							instance.Parent = instances[v16.Parent] or v16.Parent
							instances[v16] = instance

							if instance:IsA("BasePart") then
								instance.Parent = workspace.Effects
							end

							if v17[0] and typeof(v17[0]) == "table" then
								for k2, v19 in pairs(v17[0]) do
									instance[k2] = v19
								end
							end

							task.spawn(function()
								local v19 = {}

								for k2, v20 in pairs(v17) do
									table.insert(v19, k2)
								end

								table.sort(v19)

								for i = 1, #v19 - 1 do
									local v20 = v19[i]
									local v21 = v19[i + 1]
									local v22 = {
										[v18] = v17[v21]
									}
									local v23 = (v21 - v20) / 60
									local tweenInfo = TweenInfo.new(
										v23,
										Enum.EasingStyle.Linear,
										Enum.EasingDirection.InOut
									)

									if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude > 200 and (instance:IsA("BlurEffect") or instance:IsA("ColorCorrectionEffect")) then
										task.wait(v23)
									else
										local tween = TweenService:Create(instance, tweenInfo, v22)
										tween:Play()
										tween.Completed:Wait()
									end

									if i == #v19 - 1 then
										_G.PU:Dust(instance, v23 + 0.5)
									end
								end
							end)
						end)
					end
				end

				local v11 = v9["function"]

				if type(v11) == "table" then
					task.spawn(function()
						local v12 = {}
						task.delay(15, function()
							table.clear(v12)
						end)

						for k, v13 in pairs(v11) do
							if type(v13) == "function" then
								table.insert(v12, k)
							end
						end

						table.sort(v12)

						for _, v13 in ipairs(v12) do
							local v14 = v11[v13]
							local v15 = v13 / 60
							task.delay(v15, v14)
						end
					end)
				end
			end)
		elseif mode == "Striker V Cast" then
			local effects = workspace.Effects
			local skillV = ReplicatedStorage.Chest.MeleeEffect.Striker.SkillV
			local startCF = v2.StartCF
			local questFX = v2.QuestFX
			local rootPart = v2.RootPart
			local clone = skillV.Target:Clone()
			clone.CFrame = startCF
			clone.Parent = effects
			Utility.EmitParticles(clone)
			local v3 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 100,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://128406367181924",
				Volume = 0.5
			}
			local sound = PeoUtils.CreateSound(v3)
			sound.Parent = clone
			sound:Play()
			_G.PU:Dust({ clone, sound }, 5)
			task.wait(0.5)

			if questFX and rootPart then
				PeodizService.ForLoop({
					Step = 2,
					WaitTime = 0.5
				}, function(_)
					if not clone or clone and not clone.Parent then
						return true
					end

					clone.CFrame = rootPart.CFrame
					Utility.EmitParticles(clone)
					local v4 = {
						RollOffMaxDistance = 500,
						RollOffMinDistance = 100,
						RollOffMode = Enum.RollOffMode.Inverse,
						SoundId = "rbxassetid://128406367181924",
						Volume = 0.5
					}
					local sound2 = PeoUtils.CreateSound(v4)
					sound2.Parent = clone
					sound2:Play()
					_G.PU:Dust({ clone, sound2 }, 5)
				end)
			end
		elseif mode == "Striker V" then
			local effects = workspace.Effects
			local skillV = ReplicatedStorage.Chest.MeleeEffect.Striker.SkillV
			local humanoid = v2.Humanoid
			local rootPart = v2.RootPart
			local football = v2.Football
			local character2 = v2.Character
			local startCF = v2.StartCF
			local v3 = startCF * CFrame.new(
				-3.21389771,
				-5.1869874,
				15.1400681,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local v4 = startCF * CFrame.new(
				68.0406799,
				-52.1259499,
				19.588623,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local cFrame = startCF * CFrame.new(
				0.0405883789,
				-2.28838611,
				-5.41178131,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local cFrame3 = startCF * CFrame.new(
				0.0406799316,
				47.978878,
				-5.41131973,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local cFrame4 = startCF * CFrame.new(
				0.0406799316,
				-2.28808594,
				-5.41132736,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local cFrame5 = startCF * CFrame.new(
				0.0406799316,
				-0.125952482,
				-5.41133499,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local cFrame6 = startCF * CFrame.new(
				0.786102295,
				-2.18698454,
				-0.85993576,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local cFrame7 = startCF * CFrame.new(
				1.65158081,
				52.3841019,
				-1.16225815,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local cFrame8 = startCF * CFrame.new(
				0.381896973,
				-2.03639293,
				-0.825531006,
				1,
				5.36439984e-7,
				1.34110778e-7,
				1.34110863e-7,
				-1.34110095e-7,
				-1,
				-5.36439927e-7,
				1,
				-1.34110167e-7
			)
			local cFrame9 = startCF * CFrame.new(
				0.0483093262,
				44.0399818,
				-1.13969803,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local cFrame10 = startCF * CFrame.new(
				-2.53396606,
				38.3885994,
				-3.80278015,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local cFrame11 = startCF * CFrame.new(
				0.283874512,
				1.08379865,
				-0.816112518,
				1,
				-5.36439984e-7,
				-1.34110778e-7,
				1.34110863e-7,
				1.34110095e-7,
				1,
				-5.36439927e-7,
				-1,
				1.34110167e-7
			)
			local cFrame12 = startCF * CFrame.new(
				1.65112305,
				52.4950943,
				-1.36171341,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local cFrame13 = startCF * CFrame.new(
				0.381622314,
				-2.03638673,
				-0.825782776,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local v17 = startCF * CFrame.new(
				66.6027222,
				0.609391689,
				275.535858,
				1,
				-1.34110778e-7,
				5.36439984e-7,
				1.34110863e-7,
				1,
				-1.34110095e-7,
				-5.36439927e-7,
				1.34110167e-7,
				1
			)
			local clone = skillV.RandomTrail:Clone()
			clone:PivotTo(v3)
			clone.Parent = effects
			local clone2 = skillV.RandomTrail2:Clone()
			clone2:PivotTo(v4)
			clone2.Parent = effects
			local clone3 = skillV.AirBubble:Clone()
			clone3.CFrame = cFrame
			clone3.Parent = effects
			local clone4 = skillV.ImpactMesh:Clone()
			clone4.CFrame = cFrame3
			clone4.Parent = effects
			local clone5 = skillV.BeamImpactBall:Clone()
			clone5.CFrame = cFrame4
			clone5.Parent = effects
			local clone6 = skillV.Boom:Clone()
			clone6.CFrame = cFrame5
			clone6.Parent = effects
			local clone7 = skillV.Charging:Clone()
			clone7.CFrame = cFrame6
			clone7.Parent = effects
			local clone8 = skillV.Charging2:Clone()
			clone8.CFrame = cFrame7
			clone8.Parent = effects
			local clone9 = skillV.Dash:Clone()
			clone9.CFrame = cFrame8
			clone9.Parent = effects
			local clone10 = skillV.ImpactDown:Clone()
			clone10.CFrame = cFrame9
			clone10.Parent = effects
			local clone11 = skillV.Mesh1:Clone()
			_G.PU:Dust(clone11, 10)
			clone11.CFrame = cFrame10
			clone11.Parent = effects
			local clone12 = skillV.SpinUp:Clone()
			clone12.CFrame = cFrame11
			clone12.Parent = effects
			local clone13 = skillV.Stook:Clone()
			clone13.CFrame = cFrame12
			clone13.Parent = effects
			local clone14 = skillV.Trail:Clone()
			clone14.CFrame = cFrame13
			clone14.Parent = effects
			local clone15 = game.Lighting.Blur:Clone()
			clone15.Parent = game.Lighting
			local clone16 = game.Lighting.ColorCorrection:Clone()
			clone16.Parent = game.Lighting
			local clone17 = nil
			local clone18

			if character2:FindFirstChild("RightHand") then
				clone18 = skillV.At.A0:Clone()
				_G.PU:Dust(clone18, 10)
				clone18.Parent = character2.RightHand
			else
				clone18 = nil
			end

			if character2:FindFirstChild("LeftHand") then
				clone17 = skillV.At.A0:Clone()
				_G.PU:Dust(clone17, 10)
				clone17.Parent = character2.LeftHand
			end

			local v18 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 100,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://126271143831571",
				Volume = 0.75
			}
			local sound = PeoUtils.CreateSound(v18)
			_G.PU:Dust(sound, 5)
			sound.Parent = rootPart
			sound:Play()
			local clone19 = skillV.CameraRig:Clone()
			clone19:PivotTo(v17)
			clone19.Parent = effects
			_G.PU:Dust({
				clone,
				clone2,
				clone3,
				clone4,
				clone5,
				clone6,
				clone7,
				clone8,
				clone9,
				clone10,
				clone11,
				clone12,
				clone13,
				clone14,
				clone15,
				clone16,
				clone19
			}, 10)

			local function StartCutScene(p)
				if p then
					local flag = nil
					_G.VisibleGui(nil)
					_G.PU.PlayOneShotAnim({
						Animator = humanoid,
						Animation = ReplicatedStorage.Chest.Animation.Striker.V2
					})
					humanoid.AutoRotate = false
					local track = clone19.AnimationController:LoadAnimation(ReplicatedStorage.Chest.Animation.Striker.V2Cam)
					track:Play(0.1, 1, 1.1)
					track.Priority = Enum.AnimationPriority.Action4
					currentCamera.CameraType = Enum.CameraType.Scriptable
					task.spawn(function()
						local lastTime = tick()
						FastRenderer.new({
							Time = 10
						}, function(_)
							if flag then
								return true
							end

							if football and football.Parent and football:FindFirstChild("BallMesh") then
								clone8.CFrame = football.BallMesh.CFrame
							end

							if tick() - lastTime > 0.15 then
								clone19:PivotTo(rootPart.CFrame * CFrame.new(
									66.6027222,
									0.609391689,
									275.535858,
									1,
									-1.34110778e-7,
									5.36439984e-7,
									1.34110863e-7,
									1,
									-1.34110095e-7,
									-5.36439927e-7,
									1.34110167e-7,
									1
								))
								currentCamera.CFrame = clone19.camera.CFrame
							end
						end)
						currentCamera.CameraType = Enum.CameraType.Custom

						if clone19 and clone19.Parent then
							clone19:Destroy()
						end

						_G.VisibleGui(true)
					end)
					track.Stopped:Wait()
					flag = true
					humanoid.AutoRotate = true
				end
			end

			task.spawn(function()
				if localPlayer == character then
					StartCutScene(true)
				end

				local targets = v2.Targets

				if targets and table.find(targets, localPlayer.Name) and localPlayer ~= character then
					StartCutScene(true)
				end
			end)

			local function CountProperties(items)
				local result2 = {}
				local v19 = 1

				for k, item in pairs(items) do
					local count = 0

					for k2, v20 in pairs(item) do
						if not result2[k2] then
							result2[k2] = {}
						end

						result2[k2][k] = v20
						count += 1
					end

					if v19 < count then
						v19 = count
					end
				end

				for _, list2 in pairs(result2) do
					table.sort(list2)
				end

				return v19, result2
			end

			task.spawn(function()
				tick()
				local v19 = {
					[rootPart] = {
						[0] = {
							CFrame = startCF
						},
						[37] = {
							CFrame = startCF
						},
						[109] = {
							CFrame = startCF * CFrame.new(0, 50, 0)
						},
						[222] = {
							CFrame = startCF * CFrame.new(0, 50, 0)
						}
					},
					[clone4] = {
						[0] = {
							Transparency = 1,
							CFrame = cFrame3 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Size = createVector(171.9633, 11.4936905, 171.9633)
						},
						[168] = {
							Transparency = 1,
							CFrame = cFrame3 * CFrame.new(0, -41.013450622558594, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Size = createVector(0.015, 0.001, 0.015)
						},
						[173] = {
							Size = createVector(171.963, 11.494, 171.963),
							Transparency = 0
						},
						[178] = {
							Transparency = 0,
							CFrame = cFrame3 * CFrame.new(0, -1.1215171813964844, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Size = createVector(52.71538, 3.5234942, 52.71538)
						},
						[181] = {
							Transparency = 0,
							CFrame = cFrame3 * CFrame.new(0, -41.013450622558594, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Size = createVector(171.963, 11.494, 171.963)
						},
						[186] = {
							Size = createVector(52.71538, 3.5234942, 52.71538),
							Transparency = 0
						},
						[190] = {
							Size = createVector(171.963, 11.494, 171.963),
							Transparency = 0
						},
						[191] = {
							CFrame = cFrame3 * CFrame.new(0, -1.1215171813964844, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[195] = {
							Transparency = 0,
							CFrame = cFrame3 * CFrame.new(0, -41.013450622558594, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Size = createVector(52.71538, 3.5234942, 52.71538)
						},
						[199] = {
							Size = createVector(171.963, 11.494, 171.963),
							Transparency = 0
						},
						[204] = {
							Transparency = 0,
							CFrame = cFrame3 * CFrame.new(0, -1.1215171813964844, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Size = createVector(52.71538, 3.5234942, 52.71538)
						},
						[209] = {
							Transparency = 0,
							CFrame = cFrame3 * CFrame.new(0, -41.013450622558594, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
							Size = createVector(171.963, 11.494, 171.963)
						},
						[214] = {
							Size = createVector(52.71538, 3.5234942, 52.71538),
							Transparency = 0
						},
						[218] = {
							CFrame = cFrame3 * CFrame.new(0, -1.1215171813964844, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[220] = {
							Transparency = 1
						}
					},
					[clone5] = {
						[0] = {
							Transparency = 1,
							Size = createVector(102.86448, 102.86448, 102.86448)
						},
						[168] = {
							Transparency = 1,
							Size = createVector(0.001, 0.001, 0.001)
						},
						[173] = {
							Transparency = 0,
							Size = createVector(102.86448, 102.86448, 102.86448)
						},
						[178] = {
							Transparency = 0,
							Size = createVector(0.001, 0.001, 0.001)
						},
						[181] = {
							Transparency = 0,
							Size = createVector(102.86448, 102.86448, 102.86448)
						},
						[186] = {
							Transparency = 0,
							Size = createVector(0.001, 0.001, 0.001)
						},
						[190] = {
							Transparency = 0,
							Size = createVector(102.86448, 102.86448, 102.86448)
						},
						[195] = {
							Transparency = 0,
							Size = createVector(0.001, 0.001, 0.001)
						},
						[199] = {
							Transparency = 0,
							Size = createVector(102.86448, 102.86448, 102.86448)
						},
						[204] = {
							Transparency = 0,
							Size = createVector(0.001, 0.001, 0.001)
						},
						[209] = {
							Transparency = 0,
							Size = createVector(102.86448, 102.86448, 102.86448)
						},
						[214] = {
							Transparency = 0,
							Size = createVector(0.001, 0.001, 0.001)
						}
					},
					[clone3] = {
						[0] = {
							Size = createVector(0.001, 0.001, 0.001)
						},
						[168] = {
							Size = createVector(0.001, 0.001, 0.001)
						},
						[169] = {
							Size = createVector(85.169075, 85.169075, 85.169075)
						},
						[173] = {
							Size = createVector(0.001, 0.001, 0.001)
						},
						[178] = {
							Size = createVector(85.169075, 85.169075, 85.169075)
						},
						[181] = {
							Size = createVector(0.001, 0.001, 0.001)
						},
						[186] = {
							Size = createVector(85.169075, 85.169075, 85.169075)
						},
						[190] = {
							Size = createVector(0.001, 0.001, 0.001)
						},
						[195] = {
							Size = createVector(85.169075, 85.169075, 85.169075)
						},
						[199] = {
							Size = createVector(0.001, 0.001, 0.001)
						},
						[204] = {
							Size = createVector(85.169075, 85.169075, 85.169075)
						},
						[209] = {
							Size = createVector(0.001, 0.001, 0.001)
						},
						[214] = {
							Size = createVector(85.169075, 85.169075, 85.169075)
						},
						[219] = {
							Size = createVector(0.001, 0.001, 0.001)
						}
					},
					[clone15] = {
						[0] = {
							Size = 1
						},
						[2] = {
							Size = 1
						},
						[6] = {
							Size = 6
						},
						[19] = {
							Size = 1
						},
						[27] = {
							Size = 1
						},
						[31] = {
							Size = 8
						},
						[68] = {
							Size = 1
						},
						[107] = {
							Size = 1
						},
						[111] = {
							Size = 12
						},
						[135] = {
							Size = 1
						},
						[149] = {
							Size = 1
						},
						[153] = {
							Size = 12
						},
						[177] = {
							Size = 1
						}
					},
					[clone16] = {
						[0] = {
							Brightness = 0
						},
						[85] = {
							Brightness = 0
						},
						[93] = {
							Brightness = 0.2
						},
						[96] = {},
						[109] = {
							Brightness = 0.146
						},
						[110] = {
							Brightness = 0.9
						},
						[123] = {
							Brightness = 0
						}
					},
					[clone12] = {
						[0] = {
							CFrame = cFrame11 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[23] = {
							CFrame = cFrame11 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[72] = {
							CFrame = cFrame11 * CFrame.new(0, 0, 56.58331298828125, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						}
					},
					[clone14] = {
						[0] = {
							CFrame = startCF * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[27] = {
							CFrame = startCF * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[44] = {
							CFrame = cFrame13 * CFrame.new(
								0,
								23.8131046295166,
								0,
								-0.010298232547938824,
								0,
								0.9999469518661499,
								0,
								1,
								0,
								-0.9999469518661499,
								0,
								-0.010298232547938824
							)
						},
						[45] = {
							CFrame = cFrame13 * CFrame.new(
								0,
								25.024940490722656,
								0,
								-0.14041292667388916,
								0,
								0.9900930523872375,
								0,
								1,
								0,
								-0.9900930523872375,
								0,
								-0.14041292667388916
							)
						},
						[59] = {
							CFrame = cFrame13 * CFrame.new(
								0,
								41.990638732910156,
								0,
								-0.9217591285705566,
								0,
								-0.38776299357414246,
								0,
								0.9999999403953552,
								0,
								0.38776299357414246,
								0,
								-0.9217591285705566
							)
						},
						[83] = {
							CFrame = cFrame13 * CFrame.new(
								0,
								60.5465087890625,
								0,
								0.8751466274261475,
								0,
								-0.4838578999042511,
								0,
								0.9999999403953552,
								0,
								0.4838578999042511,
								0,
								0.8751466274261475
							)
						}
					},
					[clone11.HazeDecal] = {
						[0] = {
							Transparency = 1
						},
						[146] = {
							Transparency = 1
						},
						[153] = {
							Transparency = 0.8
						},
						[223] = {
							Transparency = 1
						}
					},
					[clone11] = {
						[0] = {
							CFrame = cFrame10 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[146] = {
							CFrame = cFrame10 * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
						},
						[165] = {
							CFrame = cFrame10 * CFrame.new(
								0,
								-25.707622528076172,
								0,
								0.00414082407951355,
								0,
								0.9999914169311523,
								0,
								1,
								0,
								-0.9999914169311523,
								0,
								0.00414082407951355
							)
						},
						[184] = {
							CFrame = cFrame10 * CFrame.new(
								0,
								-30.298376083374023,
								0,
								-0.6413440704345703,
								0,
								0.7672533988952637,
								0,
								1,
								0,
								-0.7672533988952637,
								0,
								-0.6413440704345703
							)
						},
						[207] = {
							CFrame = cFrame10 * CFrame.new(
								0,
								-39.200599670410156,
								0,
								0.06057879701256752,
								0,
								-0.9981634020805359,
								0,
								1,
								0,
								0.9981634020805359,
								0,
								0.06057879701256752
							)
						},
						[222] = {
							CFrame = cFrame10 * CFrame.new(
								0,
								-39.200599670410156,
								0,
								0.9984278082847595,
								0,
								0.05605243518948555,
								0,
								1,
								0,
								-0.05605243518948555,
								0,
								0.9984278082847595
							)
						}
					},
					["function"] = {
						[0] = function()
							if football and football.Parent and football:FindFirstChild("BallMesh") then
								football.BallMesh.Transparency = 0
							end

							for _, emitter in pairs(clone7:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v20 = emitter
								task.spawn(function()
									v20:Emit(v20:GetAttribute("EmitCount"))
									v20.Enabled = true
								end)
							end

							if football and football.Parent then
								for _, emitter in pairs(football:GetDescendants()) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									local v20 = emitter
									task.spawn(function()
										v20.Enabled = true
									end)
								end
							end

							if clone18 and clone18.Parent then
								for _, trail in pairs(clone18:GetChildren()) do
									if not trail:IsA("Trail") then
										continue
									end

									local v20 = trail
									task.spawn(function()
										v20.Enabled = true
									end)
								end
							end

							if clone17 and clone17.Parent then
								for _, trail in pairs(clone17:GetChildren()) do
									if not trail:IsA("Trail") then
										continue
									end

									local v20 = trail
									task.spawn(function()
										v20.Enabled = true
									end)
								end
							end

							if clone19 and clone19.Parent then
								for _, emitter in pairs(clone19:GetDescendants()) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									local v20 = emitter
									task.spawn(function()
										v20.Enabled = true
									end)
								end
							end

							PeodizService.HeartbeatWait({
								Time = 0.4,
								WaitTime = 0.16
							}, function(_)
								for _, part in ipairs(clone:GetChildren()) do
									if not part:IsA("Part") then
										continue
									end

									local cFrame14 = clone7.CFrame * CFrame.new(0, -2, 0)
									part.CFrame = cFrame14
									local position = cFrame14.Position
									local v21 = part
									delay(0.1, function()
										if v21 and v21.Parent then
											v21.Position = position + Vector3.new(
												math.random(-15, 15),
												math.random(-25, 25),
												math.random(-15, 15)
											)
										end
									end)
									local v23 = part
									local position2 = position
									delay(0.15, function()
										if v23 and v23.Parent then
											v23.Position = position2 + Vector3.new(
												math.random(-30, 30),
												math.random(-15, 15),
												math.random(-25, 25)
											)
										end
									end)
								end
							end)
						end,
						[27] = function()
							for _, emitter in pairs(clone7:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v20 = emitter
								task.spawn(function()
									v20.Enabled = false
								end)
							end

							for _, emitter in pairs(clone9:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v20 = emitter
								task.spawn(function()
									v20:Emit(v20:GetAttribute("EmitCount"))
								end)
							end

							for _, emitter in pairs(clone12:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v20 = emitter
								task.spawn(function()
									v20:Emit(v20:GetAttribute("EmitCount"))
									v20.Enabled = true
								end)
							end

							for _, trail in pairs(clone14:GetDescendants()) do
								if not trail:IsA("Trail") then
									continue
								end

								local v20 = trail
								task.spawn(function()
									v20.Enabled = true
								end)
							end

							if clone19 and clone19.Parent then
								for _, emitter in pairs(clone19:GetDescendants()) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									local v20 = emitter
									task.spawn(function()
										v20.Enabled = false
									end)
								end
							end
						end,
						[83] = function()
							for _, emitter in pairs(clone12:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v20 = emitter
								task.spawn(function()
									v20.Enabled = false
								end)
							end

							for _, trail in pairs(clone14:GetDescendants()) do
								if not trail:IsA("Trail") then
									continue
								end

								local v20 = trail
								task.spawn(function()
									v20.Enabled = false
								end)
							end

							if clone19 and clone19.Parent then
								for _, emitter in pairs(clone19:GetDescendants()) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									local v20 = emitter
									task.spawn(function()
										v20.Enabled = true
									end)
								end
							end
						end,
						[111] = function()
							for _, emitter in pairs(clone13:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v20 = emitter
								task.spawn(function()
									v20:Emit(v20:GetAttribute("EmitCount"))
								end)
							end

							if football and football.Parent and football:FindFirstChild("BallMesh") then
								clone8.CFrame = football.BallMesh.CFrame
							end

							for _, emitter in pairs(clone8:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v20 = emitter
								task.spawn(function()
									v20:Emit(v20:GetAttribute("EmitCount"))
									v20.Enabled = true
								end)
							end

							if clone19 and clone19.Parent then
								for _, emitter in pairs(clone19:GetDescendants()) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									local v20 = emitter
									task.spawn(function()
										v20.Enabled = false
									end)
								end
							end
						end,
						[153] = function()
							for _, emitter in pairs(clone8:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v20 = emitter
								task.spawn(function()
									v20.Enabled = false
								end)
							end

							for _, emitter in pairs(clone10:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v20 = emitter
								task.spawn(function()
									v20:Emit(v20:GetAttribute("EmitCount"))
								end)
							end
						end,
						[170] = function()
							local v20 = {
								RollOffMaxDistance = 500,
								RollOffMinDistance = 100,
								RollOffMode = Enum.RollOffMode.Inverse,
								SoundId = "rbxassetid://85175307402040",
								Volume = 0.75
							}
							local sound2 = PeoUtils.CreateSound(v20)
							_G.PU:Dust(sound2, 5)
							sound2.Parent = rootPart
							sound2:Play()

							if football and football.Parent and football:FindFirstChild("BallMesh") then
								football.BallMesh.Transparency = 1
							end

							if clone18 and clone18.Parent then
								for _, trail in pairs(clone18:GetChildren()) do
									if not trail:IsA("Trail") then
										continue
									end

									local v21 = trail
									task.spawn(function()
										v21.Enabled = false
									end)
								end
							end

							if clone17 and clone17.Parent then
								for _, trail in pairs(clone17:GetChildren()) do
									if not trail:IsA("Trail") then
										continue
									end

									local v21 = trail
									task.spawn(function()
										v21.Enabled = false
									end)
								end
							end

							for _, emitter in pairs(clone6:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v21 = emitter
								task.spawn(function()
									v21:Emit(v21:GetAttribute("EmitCount"))
									v21.Enabled = true
								end)
							end

							if clone19 and clone19.Parent then
								for _, emitter in pairs(clone19:GetDescendants()) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									local v21 = emitter
									task.spawn(function()
										v21.Enabled = true
									end)
								end
							end

							for _, beam in pairs(clone5:GetDescendants()) do
								if not beam:IsA("Beam") then
									continue
								end

								local v21 = beam
								task.spawn(function()
									v21.Enabled = true
								end)
							end

							PeodizService.HeartbeatWait({
								Time = 1.2,
								WaitTime = 0.16
							}, function(_)
								for _, part in ipairs(clone2:GetChildren()) do
									if not part:IsA("Part") then
										continue
									end

									local cFrame14 = clone6.CFrame * CFrame.new(0, -2, 0)
									part.CFrame = cFrame14
									local position = cFrame14.Position
									local v22 = part
									delay(0.1, function()
										if v22 and v22.Parent then
											v22.Position = position + Vector3.new(
												math.random(-35, 35),
												math.random(-45, 45),
												math.random(-35, 35)
											)
										end
									end)
									local v24 = part
									local position2 = position
									delay(0.15, function()
										if v24 and v24.Parent then
											v24.Position = position2 + Vector3.new(
												math.random(-70, 70),
												math.random(-75, 75),
												math.random(-85, 85)
											)
										end
									end)
								end
							end)
						end,
						[223] = function()
							task.delay(0.5, function()
								if football and football.Parent and football:FindFirstChild("BallMesh") then
									football.BallMesh.Transparency = 0
								end
							end)

							if football and football.Parent then
								for _, emitter in pairs(football:GetDescendants()) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									local v20 = emitter
									task.spawn(function()
										v20.Enabled = false
									end)
								end
							end

							for _, emitter in pairs(clone6:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local v20 = emitter
								task.spawn(function()
									v20.Enabled = false
								end)
							end

							for _, beam in pairs(clone5:GetDescendants()) do
								if not beam:IsA("Beam") then
									continue
								end

								local v20 = beam
								task.spawn(function()
									v20.Enabled = false
								end)
							end

							if clone19 and clone19.Parent then
								for _, emitter in pairs(clone19:GetDescendants()) do
									if not emitter:IsA("ParticleEmitter") then
										continue
									end

									local v20 = emitter
									task.spawn(function()
										v20.Enabled = false
									end)
								end
							end
						end
					}
				}
				task.delay(15, function()
					table.clear(v19)
				end)
				local v20 = {}
				task.delay(15, function()
					table.clear(v20)
				end)

				for k, _ in pairs(v19) do
					if typeof(k) == "Instance" then
						table.insert(v20, k)
					end
				end

				local function getDepth(parent)
					local count = 0

					while parent.Parent do
						count += 1
						parent = parent.Parent
					end

					return count
				end

				table.sort(v20, function(parent, parent2)
					local count = 0

					while parent.Parent do
						count += 1
						parent = parent.Parent
					end

					local count2 = 0

					while parent2.Parent do
						count2 += 1
						parent2 = parent2.Parent
					end

					return count < count2
				end)
				local v21 = {}
				task.delay(15, function()
					table.clear(v21)
				end)

				for _, v22 in ipairs(v20) do
					local v23 = v19[v22]

					if type(v23) ~= "table" then
						continue
					end

					local v24, v25 = CountProperties(v23)

					if not (v24 and v25) then
						continue
					end

					for k, v26 in pairs(v25) do
						local v27 = v22
						local v28 = v26
						local v29 = k
						task.spawn(function()
							local instance = v27

							if v28[0] and typeof(v28[0]) == "table" then
								for k2, v30 in pairs(v28[0]) do
									instance[k2] = v30
								end
							end

							task.spawn(function()
								local v30 = {}

								for k2, v31 in pairs(v28) do
									table.insert(v30, k2)
								end

								table.sort(v30)

								for i = 1, #v30 - 1 do
									local v31 = v30[i]
									local v32 = v30[i + 1]
									local v33 = {
										[v29] = v28[v32]
									}
									local v34 = (v32 - v31) / 60
									local tweenInfo = TweenInfo.new(
										v34,
										Enum.EasingStyle.Linear,
										Enum.EasingDirection.InOut
									)

									if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude > 200 and (instance:IsA("BlurEffect") or instance:IsA("ColorCorrectionEffect")) then
										task.wait(v34)
									elseif instance == rootPart then
										PeoUtils.LerpCF(rootPart, tweenInfo, v33.CFrame)
										task.wait(v34)
									else
										local tween = TweenService:Create(instance, tweenInfo, v33)
										tween:Play()
										tween.Completed:Wait()
									end

									local v35 = i == #v30 - 1
								end
							end)
						end)
					end
				end

				local v22 = v19["function"]

				if type(v22) == "table" then
					task.spawn(function()
						local v23 = {}
						task.delay(15, function()
							table.clear(v23)
						end)

						for k, v24 in pairs(v22) do
							if type(v24) == "function" then
								table.insert(v23, k)
							end
						end

						table.sort(v23)

						for _, v24 in ipairs(v23) do
							local v25 = v22[v24]
							local v26 = v24 / 60
							task.delay(v26, v25)
						end
					end)
				end
			end)
		elseif mode == "Sunken Blade Z" then
			local skillZ = ReplicatedStorage.Chest.SwordEffect.SunkenBlade.SkillZ
			local effects = workspace.Effects
			local startCF = v2.StartCF
			local clone = skillZ.Step1:Clone()
			clone:PivotTo(startCF)
			clone.Parent = effects
			local boundingBox = clone:GetBoundingBox()
			local clone2 = skillZ.Step2:Clone()
			SetupPart(clone2)
			clone2.CFrame = boundingBox
			clone2.Parent = effects
			local sound = _G.PU.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://7431359766",
				Volume = 2
			})
			_G.PU:Dust(sound, 2)
			sound.Parent = clone2
			sound:Play()
			task.delay(0.3, function()
				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				task.spawn(function()
					task.wait(0.1)

					if (localPlayer.Character.HumanoidRootPart.Position - startCF.Position).Magnitude < 250 then
						_G.CameraShake:ShakeOnce(5, 10, 0, 1)
					end

					local clone3 = skillZ.Step3:Clone()
					SetupPart(clone3)
					clone3.CFrame = boundingBox
					clone3.Parent = effects
					_G.PU:Dust(clone3, 2)
					Utility.EmitParticles(clone3)
					local sound2 = _G.PU.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.Inverse,
						SoundId = "rbxassetid://7431360041",
						Volume = 2.5
					})
					_G.PU:Dust(sound2, 2)
					sound2.Parent = clone3
					sound2:Play()
				end)
				task.spawn(function()
					PeodizService.new({
						Time = 0.1
					}, function(p)
						clone:ScaleTo((math.max(1 - p * 1, 0.001)))
					end)
				end)
			end)
			_G.PU:Dust(clone, 2)
			_G.PU:Dust(clone2, 2)
		elseif mode == "Sunken Blade X" then
			local skillX = ReplicatedStorage.Chest.SwordEffect.SunkenBlade.SkillX
			local effects = workspace.Effects
			local startCF = v2.StartCF
			local rootPart = v2.RootPart

			if (localPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude < 200 then
				_G.CameraShake:ShakeOnce(7, 12, 0, 0.5)
				bloomBlur()
			end

			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 800,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://15427697233",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = rootPart
			sound:Play()
			PeodizService.ForceForLoop({
				Step = 8,
				WaitTime = 0.15
			}, function(p)
				local v3 = math.floor(p * 8)
				local cFrame = startCF * CFrame.new(0, -3, 0 - v3 * 30)

				if (localPlayer.Character.HumanoidRootPart.Position - startCF.Position).Magnitude < 250 then
					_G.CameraShake:ShakeOnce(0.5, 10, 0, 0.5)
				end

				local clone = skillX.Step1:Clone()
				SetupPart(clone)
				clone.CFrame = cFrame
				clone.Parent = effects
				_G.PU:Dust(clone, 2)
				Utility.EmitParticles(clone)
			end)
		end
	end
end