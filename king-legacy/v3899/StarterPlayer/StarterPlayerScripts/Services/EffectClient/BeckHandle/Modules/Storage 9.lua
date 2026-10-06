local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local localPlayer = game.Players.LocalPlayer
require(ReplicatedStorage.Chest.Modules.BoatTween)
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
require(ReplicatedStorage.Chest.Modules.HighlightModule)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
require(ReplicatedStorage.Chest.Modules.CameraParticle)
local currentCamera = workspace.CurrentCamera
local FastRenderer = require(ReplicatedStorage.Chest.Modules.FastRenderer)
local Utility = require(ReplicatedStorage.Chest.Modules.Utility)
require(ReplicatedStorage.Chest.Modules.System)
local Motion = require(ReplicatedStorage.Chest.Assets.Modules.Motion)
local Scheduler = require(ReplicatedStorage.Chest.Assets.Modules.Scheduler)
local effects = workspace.Effects
local PolyLib = require(ReplicatedStorage.Chest.Modules.PolyLib)
local Bezier = require(ReplicatedStorage.Chest.Modules.Bezier)

function Emit(p)
	Utility.EmitParticles(p)
end

function evaluateColorSequence(sequence, p)
	local keypoints = sequence.Keypoints

	for i = 1, #keypoints - 1 do
		local keypoint = keypoints[i]
		local keypoint2 = keypoints[i + 1]

		if not (keypoint.Time <= p and p <= keypoint2.Time) then
			continue
		end

		local v = (p - keypoint.Time) / (keypoint2.Time - keypoint.Time)
		return keypoint.Value:Lerp(keypoint2.Value, v)
	end

	return keypoints[#keypoints].Value
end

function SetupPart(p)
	p.Anchored = true
	p.CanCollide = false
	p.Transparency = 1
	p.CastShadow = false
	p.Massless = true
end

return function(list)
	local v, v2, v3, _ = unpack(list)
	local success, result = pcall(function()
		if type(v3) == "table" and v3.LoopDistance then
			return false
		end

		if v2 then
			return (localPlayer.Character.HumanoidRootPart.Position - v2.p).Magnitude > 1000
		end

		return false
	end)

	if success then
		if result then
			return
		end

		local mode = v3.Mode

		if mode == "Wolf Z" then
			local skillZ = ReplicatedStorage.Chest.FruitEffect.Wolf.SkillZ
			local rootPart = v3.RootPart

			if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 150 then
				Motion:Shake("Rise")
			end

			local v4 = {
				RollOffMaxDistance = 300,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://15071462772",
				Volume = 0.2
			}
			local sound = PeoUtils.CreateSound(v4)
			_G.PU:Dust(sound, 1.3)
			sound.Parent = rootPart
			sound:Play()
			local clone = skillZ.Step1:Clone()
			SetupPart(clone)
			clone.CFrame = rootPart.CFrame * CFrame.new(0, 2, 0)
			clone.Parent = effects
			Utility.EmitParticles(clone)
			_G.PU:Dust(clone, 2)
		elseif mode == "Wolf X" then
			local rootPart = v3.RootPart
			local cFMouse = v3.CFMouse
			local skillX = ReplicatedStorage.Chest.FruitEffect.Wolf.SkillX
			task.spawn(function()
				local v4 = Scheduler.Repeat(1, 3)
				v4:Wait(0.15)
				v4:OnStep(function(_)
					if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 150 then
						Motion:Shake("Rise")
					end

					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://8595975878",
						Volume = 1
					})
					_G.PU:Dust(sound, 3)
					sound.Parent = rootPart
					sound:Play()
					local clone = skillX.Step1:Clone()
					SetupPart(clone)
					clone.CFrame = cFMouse
					clone.Parent = effects
					Utility.EmitParticles(clone)
					_G.PU:Dust(clone, 2)
					task.spawn(function()
						PeodizService.new({
							Time = 0.15
						}, function(_, p)
							clone.CFrame *= CFrame.Angles(0, 0, 0.4487989505128276 * p * 60)
						end)

						for _, effect in pairs(clone:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
								effect.Enabled = false
							end
						end
					end)
				end)
				v4:Execute()
			end)
		elseif mode == "Wolf C" then
			local skillC = ReplicatedStorage.Chest.FruitEffect.Wolf.SkillC
			local startCF = v3.StartCF
			local cFMouse = v3.CFMouse
			local speed = v3.Speed
			local rootPart = v3.RootPart
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://8595976174",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = rootPart
			sound:Play()
			local clone = skillC.Step1:Clone()
			SetupPart(clone)
			clone.CFrame = startCF
			clone.Parent = effects
			_G.PU:Dust(clone, 2)
			TweenService:Create(clone, TweenInfo.new(speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				CFrame = cFMouse
			}):Play()
			task.delay(speed, function()
				if (localPlayer.Character.HumanoidRootPart.Position - cFMouse.Position).Magnitude < 150 then
					Motion:Shake("Rise")
				end

				for _, effect in pairs(clone:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = false
					end
				end

				local clone2 = skillC.Step2:Clone()
				SetupPart(clone2)
				clone2.CFrame = clone.CFrame
				clone2.Parent = effects
				Utility.EmitParticles(clone2)
				_G.PU:Dust(clone2, 2)
			end)
		elseif mode == "Wolf V" then
			local skillV = ReplicatedStorage.Chest.FruitEffect.Wolf.SkillV
			local rootPart = v3.RootPart
			local chargeFolder = v3.ChargeFolder
			local character = v3.Character
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://15071284418",
				Volume = 0.5
			})
			_G.PU:Dust(sound, 5)
			sound.Parent = rootPart
			sound:Play()

			local function PlayStep(instance, p)
				local clone = instance:Clone()
				SetupPart(clone)
				clone.CFrame = rootPart.CFrame * CFrame.new(0, 2, 0) * CFrame.Angles(0, 0, (math.rad(p)))
				clone.Parent = effects
				task.spawn(function()
					PeodizService.new({
						Time = 0.2
					}, function(_, p2)
						clone.CFrame *= CFrame.Angles(-0.41887902047863906 * p2 * 40, 0, 0)
					end)

					for _, beam in pairs(clone:GetDescendants()) do
						if beam:IsA("Beam") then
							TweenService:Create(beam, TweenInfo.new(0.1), {
								Width0 = 0,
								Width1 = 0
							}):Play()
						end
					end
				end)
				_G.PU:Dust(clone, 2)
				return clone
			end

			local function PlayHit(instance, p)
				local clone = instance:Clone()
				SetupPart(clone)
				clone.CFrame = rootPart.CFrame * CFrame.new(0, 0, -18) * CFrame.Angles(0, 0, (math.rad(p)))
				clone.Parent = effects
				Utility.EmitParticles(clone)
				_G.PU:Dust(clone, 2)
			end

			local v4 = Scheduler.new(5)
			v4:Wait(0.4)
			v4:OnStep(function()
				if not chargeFolder:IsDescendantOf(character) then
					v4:Destroy()
					return
				end

				PlayStep(skillV.Step1, -50)
				PlayHit(skillV.Hit1, -50)

				if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 150 then
					Motion:Shake("Rise")
				end

				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://15057161282",
					Volume = 0.1
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = rootPart
				sound2:Play()
				local sound3 = PeoUtils.CreateSound({
					RollOffMaxDistance = 400,
					RollOffMinDistance = 25,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://15057237595",
					Volume = 0.3,
					PlaybackSpeed = 1.2
				})
				_G.PU:Dust(sound3, 3)
				sound3.Parent = rootPart
				sound3:Play()
				task.wait(0.2)
				local sound4 = PeoUtils.CreateSound({
					RollOffMaxDistance = 400,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://15057161282",
					Volume = 0.1
				})
				_G.PU:Dust(sound4, 3)
				sound4.Parent = rootPart
				sound4:Play()
				local sound5 = PeoUtils.CreateSound({
					RollOffMaxDistance = 400,
					RollOffMinDistance = 25,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://15057237595",
					Volume = 0.3,
					PlaybackSpeed = 1.2
				})
				_G.PU:Dust(sound5, 3)
				sound5.Parent = rootPart
				sound5:Play()
				PlayStep(skillV.Step2, 50)
				PlayHit(skillV.Hit2, 50)

				if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 150 then
					Motion:Shake("Rise")
				end
			end)
			v4:Execute()
		elseif mode == "Basic Rod Z" then
			local _ = v3.RootPart
			local startCF = v3.StartCF
			local skillZ = ReplicatedStorage.Chest.SwordEffect["Basic Rod"].SkillZ
			local clone = skillZ.Step1:Clone()
			SetupPart(clone)
			clone.CFrame = startCF * CFrame.new(0, 2, 0)
			clone.Parent = effects
			_G.PU:Dust(clone, 3)
			Utility.EmitParticles(clone)
			task.delay(0.05, function()
				if (localPlayer.Character.HumanoidRootPart.Position - startCF.Position).Magnitude < 150 then
					Motion:Shake("Rise")
				end

				local clone2 = skillZ.Hit1:Clone()
				SetupPart(clone2)
				clone2.CFrame = startCF * CFrame.new(0, 2.5, 0) * CFrame.Angles(0, 0, -1.5707963267948966)
				clone2.Parent = effects
				Utility.EmitParticles(clone2)
				_G.PU:Dust(clone2, 3)
			end)
		elseif mode == "Basic Rod X" then
			local _ = v3.RootPart
			local startCF = v3.StartCF
			local cFMouse = v3.CFMouse
			local skillX = ReplicatedStorage.Chest.SwordEffect["Basic Rod"].SkillX
			local clone = skillX.PJT:Clone()
			clone.Anchored = true
			clone.CanCollide = false
			clone.Transparency = 1
			clone.CFrame = startCF
			clone.Parent = effects
			_G.PU:Dust(clone, 2)
			local midpoint = (startCF.Position + cFMouse.Position) / 2
			local cframe = CFrame.new(midpoint, cFMouse.Position)
			local v5 = cframe.Position + cframe.UpVector * 25
			local v6 = Bezier.new(startCF.Position, v5, cFMouse.Position)
			PeodizService.ForLoop({
				Step = 30,
				WaitTime = 0.01
			}, function(p)
				local v7 = math.floor(p * 30)
				local v8 = v6:Get(v7 / 30)
				local v9 = v6:Get((v7 + 1) / 30)
				clone.CFrame = CFrame.new(v8, v9)
			end)

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			local clone2 = skillX.Step1:Clone()
			SetupPart(clone2)
			clone2.CFrame = CFrame.new(cFMouse.Position)
			clone2.Parent = effects
			Utility.EmitParticles(clone2)
			_G.PU:Dust(clone2, 3)
			local sound = _G.PU.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://98150756929513",
				Volume = 0.5
			})
			_G.PU:Dust(sound, 4)
			sound.Parent = clone2
			sound:Play()
			local v7 = clone2.Position + createVector(0, 3, 0)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			local raycastResult = workspace:Raycast(v7, createVector(0, -15, 0), raycastParams)

			if raycastResult then
				local position = raycastResult.Position
				local clone3 = skillX.Ground_Ray:Clone()
				clone3.Anchored = true
				clone3.CanCollide = false
				clone3.Transparency = 1
				clone3.CFrame = CFrame.new(position + Vector3.new(0, clone3.Size.Y / 2, 0)) * CFrame.Angles(
					0,
					math.rad(clone2.Orientation.Y),
					0
				)
				clone3.Parent = effects
				Utility.EmitParticles(clone3)
				_G.PU:Dust(clone3, 4)
			end
		elseif mode == "Serpent Tornado" then
			local element = v3.Element
			local rootPart = v3.RootPart
			local scale = v3.Scale

			if element == "Fire" then
				task.spawn(function()
					local v4 = Scheduler.Repeat(1, 21)
					v4:Wait(0.1)
					v4:OnStep(function()
						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 500 then
							Motion:Shake("Roar")
						end
					end)
					v4:Execute()
				end)
				local clone = ReplicatedStorage.Chest.Etc.Serpent.SkFire.Spin.Step1:Clone()
				SetupPart(clone.PrimaryPart)
				clone:ScaleTo(scale)
				clone:PivotTo(CFrame.new(rootPart.Position))
				clone.Parent = effects
				_G.PU:Dust(clone, 10)
				local v4 = Scheduler.new(2.19)
				v4:OnStep(function()
					local v5 = task.wait(0.016666666666666666)
					clone:PivotTo(clone:GetPivot() * CFrame.Angles(0, -0.4487989505128276 * v5 * 30, 0))
				end)
				v4:Execute()

				for _, effect in pairs(clone:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = false
					end
				end
			elseif element == "Gale" then
				task.spawn(function()
					local v4 = Scheduler.Repeat(1, 21)
					v4:Wait(0.1)
					v4:OnStep(function()
						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 500 then
							Motion:Shake("Roar")
						end
					end)
					v4:Execute()
				end)
				local clone = ReplicatedStorage.Chest.Etc.Serpent.SkWind.Spin.Step1:Clone()
				SetupPart(clone.PrimaryPart)
				clone:ScaleTo(scale)
				clone:PivotTo(CFrame.new(rootPart.Position))
				clone.Parent = effects
				_G.PU:Dust(clone, 10)
				local v4 = Scheduler.new(2.19)
				v4:OnStep(function()
					local v5 = task.wait(0.016666666666666666)
					clone:PivotTo(clone:GetPivot() * CFrame.Angles(0, -0.4487989505128276 * v5 * 30, 0))
				end)
				v4:Execute()

				for _, effect in pairs(clone:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = false
					end
				end
			else
				if element ~= "Lightning" then
					return
				end

				task.spawn(function()
					local v4 = Scheduler.Repeat(1, 21)
					v4:Wait(0.1)
					v4:OnStep(function()
						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 500 then
							Motion:Shake("Roar")
						end
					end)
					v4:Execute()
				end)
				local clone = ReplicatedStorage.Chest.Etc.Serpent.SkLightning.Spin.Step1:Clone()
				SetupPart(clone.PrimaryPart)
				clone:ScaleTo(scale)
				clone:PivotTo(CFrame.new(rootPart.Position))
				clone.Parent = effects
				_G.PU:Dust(clone, 10)
				local v4 = Scheduler.new(2.19)
				v4:OnStep(function()
					local v5 = task.wait(0.016666666666666666)
					clone:PivotTo(clone:GetPivot() * CFrame.Angles(0, -0.4487989505128276 * v5 * 30, 0))
				end)
				v4:Execute()

				for _, effect in pairs(clone:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = false
					end
				end
			end
		elseif mode == "Serpent Roar" then
			local element = v3.Element
			local rootPart = v3.RootPart
			local scale = v3.Scale

			if element == "Fire" then
				task.spawn(function()
					local v4 = Scheduler.Repeat(1, 11)
					v4:Wait(0.1)
					v4:OnStep(function()
						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 500 then
							Motion:Shake("Roar")
						end
					end)
					v4:Execute()
				end)
				local bone003 = rootPart:FindFirstChild("Bone.003", true)
				local clone = ReplicatedStorage.Chest.Etc.Serpent.SkFire.Roar.Step1:Clone()
				SetupPart(clone.PrimaryPart)
				clone:ScaleTo(scale)
				clone:PivotTo(bone003.TransformedWorldCFrame * CFrame.new(0, 8, -25))
				clone.Parent = effects
				_G.PU:Dust(clone, 5)
				PeodizService.new({
					Time = 1.1
				}, function()
					if not bone003 or bone003 and not bone003.Parent then
						return true
					end

					clone:PivotTo(bone003.TransformedWorldCFrame * CFrame.new(0, 8, -25))
				end)

				for _, effect in pairs(clone:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = false
					end
				end
			elseif element == "Gale" then
				task.spawn(function()
					local v4 = Scheduler.Repeat(1, 11)
					v4:Wait(0.1)
					v4:OnStep(function()
						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 500 then
							Motion:Shake("Roar")
						end
					end)
					v4:Execute()
				end)
				local bone003 = rootPart:FindFirstChild("Bone.003", true)
				local clone = ReplicatedStorage.Chest.Etc.Serpent.SkWind.Roar.Step1:Clone()
				SetupPart(clone.PrimaryPart)
				clone:ScaleTo(scale)
				clone:PivotTo(bone003.TransformedWorldCFrame * CFrame.new(0, 8, -25))
				clone.Parent = effects
				_G.PU:Dust(clone, 5)
				PeodizService.new({
					Time = 1.1
				}, function()
					if not bone003 or bone003 and not bone003.Parent then
						return true
					end

					clone:PivotTo(bone003.TransformedWorldCFrame * CFrame.new(0, 8, -25))
				end)

				for _, effect in pairs(clone:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = false
					end
				end
			else
				if element ~= "Lightning" then
					return
				end

				task.spawn(function()
					local v4 = Scheduler.Repeat(1, 11)
					v4:Wait(0.1)
					v4:OnStep(function()
						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 500 then
							Motion:Shake("Roar")
						end
					end)
					v4:Execute()
				end)
				local bone003 = rootPart:FindFirstChild("Bone.003", true)
				local clone = ReplicatedStorage.Chest.Etc.Serpent.SkLightning.Roar.Step1:Clone()
				SetupPart(clone.PrimaryPart)
				clone:ScaleTo(scale)
				clone:PivotTo(bone003.TransformedWorldCFrame * CFrame.new(0, 8, -25))
				clone.Parent = effects
				_G.PU:Dust(clone, 5)
				PeodizService.new({
					Time = 1.1
				}, function()
					if not bone003 or bone003 and not bone003.Parent then
						return true
					end

					clone:PivotTo(bone003.TransformedWorldCFrame * CFrame.new(0, 8, -25))
				end)

				for _, effect in pairs(clone:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = false
					end
				end
			end
		elseif mode == "Serpent Bullet" then
			local element = v3.Element
			local rootPart = v3.RootPart
			local skillFolder = v3.SkillFolder
			local scale = v3.Scale or 1

			if element == "Fire" then
				local childAddedConnection = nil
				local count = 0

				local function ShootFireBullet(child)
					count += 1

					if count == 10 and childAddedConnection and childAddedConnection.Connected then
						childAddedConnection:Disconnect()
					end

					local startCF = child:GetAttribute("StartCF")
					local endCF = child:GetAttribute("EndCF")
					local sound = _G.PU.CreateSound({
						RollOffMaxDistance = 3000,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://109587362658542",
						Volume = 1
					})
					_G.PU:Dust(sound, 5)
					sound.Parent = rootPart
					sound:Play()
					local fireBall = ReplicatedStorage.Chest.Etc.Serpent.SkFire.FireBall
					local clone = fireBall.Step1:Clone()
					SetupPart(clone.PrimaryPart)
					clone:ScaleTo(scale)
					clone:PivotTo(startCF)
					clone.Parent = effects
					_G.PU:Dust(clone, 10)
					Utility.EmitParticles(clone)
					local clone2 = fireBall.Step2:Clone()
					SetupPart(clone2.PrimaryPart)
					clone2:ScaleTo(scale)
					clone2:PivotTo(startCF)
					clone2.Parent = effects
					_G.PU:Dust(clone2, 5)
					task.spawn(function()
						local v4 = startCF
						local v5 = v4 * CFrame.new(math.random(-60, 60), math.random(-60, 60), 0)
						local v7 = Bezier.new(v4.Position, v5.Position, endCF.Position)
						local v8 = Scheduler.Repeat(1, 40)
						v8:Wait()
						v8:OnStep(function(p)
							local v9 = v7:Get(p / 40)
							local v10 = v7:Get((p + 1) / 40)
							clone2:PivotTo(CFrame.new(v9, v10))
						end)
						v8:Execute()

						for _, emitter in pairs(clone2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 300 then
							Motion:Shake("Roar")
						end

						local clone3 = fireBall.Step3:Clone()
						SetupPart(clone3.PrimaryPart)
						clone3:PivotTo(endCF)
						clone3.Parent = effects
						Utility.EmitParticles(clone3)
						_G.PU:Dust(clone3, 5)
						local sound2 = _G.PU.CreateSound({
							RollOffMaxDistance = 3000,
							RollOffMinDistance = 50,
							RollOffMode = Enum.RollOffMode.InverseTapered,
							SoundId = "rbxassetid://111118499725060",
							Volume = 0.1
						})
						_G.PU:Dust(sound2, 5)
						sound2.Parent = clone3
						sound2:Play()
					end)
				end

				childAddedConnection = skillFolder.ChildAdded:Connect(function(child)
					ShootFireBullet(child)
				end)
			elseif element == "Gale" then
				local childAddedConnection = nil
				local count = 0

				local function ShootGaleBullet(child)
					count += 1

					if count == 10 and childAddedConnection and childAddedConnection.Connected then
						childAddedConnection:Disconnect()
					end

					local startCF = child:GetAttribute("StartCF")
					local endCF = child:GetAttribute("EndCF")
					local sound = _G.PU.CreateSound({
						RollOffMaxDistance = 3000,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://111773660949203",
						Volume = 1
					})
					_G.PU:Dust(sound, 5)
					sound.Parent = rootPart
					sound:Play()
					local windBall = ReplicatedStorage.Chest.Etc.Serpent.SkWind.WindBall
					local clone = windBall.Step1:Clone()
					SetupPart(clone.PrimaryPart)
					clone:ScaleTo(scale)
					clone:PivotTo(startCF)
					clone.Parent = effects
					_G.PU:Dust(clone, 10)
					Utility.EmitParticles(clone)
					local clone2 = windBall.Step2:Clone()
					SetupPart(clone2.PrimaryPart)
					clone2:ScaleTo(scale)
					clone2:PivotTo(startCF)
					clone2.Parent = effects
					_G.PU:Dust(clone2, 5)
					task.spawn(function()
						local v4 = startCF
						local v5 = v4 * CFrame.new(math.random(-60, 60), math.random(-60, 60), 0)
						local v7 = Bezier.new(v4.Position, v5.Position, endCF.Position)
						local v8 = Scheduler.Repeat(1, 40)
						v8:Wait()
						v8:OnStep(function(p)
							local v9 = v7:Get(p / 40)
							local v10 = v7:Get((p + 1) / 40)
							clone2:PivotTo(CFrame.new(v9, v10))
						end)
						v8:Execute()

						for _, emitter in pairs(clone2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 300 then
							Motion:Shake("Roar")
						end

						local clone3 = windBall.Step3:Clone()
						SetupPart(clone3.PrimaryPart)
						clone3:ScaleTo(scale)
						clone3:PivotTo(endCF)
						clone3.Parent = effects
						Utility.EmitParticles(clone3)
						_G.PU:Dust(clone3, 5)
						local sound2 = _G.PU.CreateSound({
							RollOffMaxDistance = 3000,
							RollOffMinDistance = 50,
							RollOffMode = Enum.RollOffMode.InverseTapered,
							SoundId = "rbxassetid://115879001567442",
							Volume = 0.1
						})
						_G.PU:Dust(sound2, 5)
						sound2.Parent = clone3
						sound2:Play()
					end)
				end

				childAddedConnection = skillFolder.ChildAdded:Connect(function(child)
					ShootGaleBullet(child)
				end)
			else
				if element ~= "Lightning" then
					return
				end

				local childAddedConnection = nil
				local count = 0

				local function ShootLightningBullet(child)
					count += 1

					if count == 10 and childAddedConnection and childAddedConnection.Connected then
						childAddedConnection:Disconnect()
					end

					local startCF = child:GetAttribute("StartCF")
					local endCF = child:GetAttribute("EndCF")
					local sound = _G.PU.CreateSound({
						RollOffMaxDistance = 3000,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://133584098531354",
						Volume = 1
					})
					_G.PU:Dust(sound, 5)
					sound.Parent = rootPart
					sound:Play()
					local lightningBall = ReplicatedStorage.Chest.Etc.Serpent.SkLightning.LightningBall
					local clone = lightningBall.Step1:Clone()
					SetupPart(clone.PrimaryPart)
					clone:ScaleTo(scale)
					clone:PivotTo(startCF)
					clone.Parent = effects
					_G.PU:Dust(clone, 10)
					Utility.EmitParticles(clone)
					local clone2 = lightningBall.Step2:Clone()
					SetupPart(clone2.PrimaryPart)
					clone2:ScaleTo(scale)
					clone2:PivotTo(startCF)
					clone2.Parent = effects
					_G.PU:Dust(clone2, 5)
					task.spawn(function()
						local v4 = startCF
						local v5 = v4 * CFrame.new(math.random(-60, 60), math.random(-60, 60), 0)
						local v7 = Bezier.new(v4.Position, v5.Position, endCF.Position)
						local v8 = Scheduler.Repeat(1, 40)
						v8:Wait()
						v8:OnStep(function(p)
							local v9 = v7:Get(p / 40)
							local v10 = v7:Get((p + 1) / 40)
							clone2:PivotTo(CFrame.new(v9, v10))
						end)
						v8:Execute()

						for _, emitter in pairs(clone2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 300 then
							Motion:Shake("Roar")
						end

						local clone3 = lightningBall.Step3:Clone()
						SetupPart(clone3.PrimaryPart)
						clone3:ScaleTo(scale)
						clone3:PivotTo(endCF)
						clone3.Parent = effects
						Utility.EmitParticles(clone3)
						_G.PU:Dust(clone3, 5)
						local sound2 = _G.PU.CreateSound({
							RollOffMaxDistance = 3000,
							RollOffMinDistance = 50,
							RollOffMode = Enum.RollOffMode.InverseTapered,
							SoundId = "rbxassetid://117608377305588",
							Volume = 0.1
						})
						_G.PU:Dust(sound2, 5)
						sound2.Parent = clone3
						sound2:Play()
					end)
				end

				childAddedConnection = skillFolder.ChildAdded:Connect(function(child)
					ShootLightningBullet(child)
				end)
			end
		elseif mode == "Serpent Spawn" then
			local rootPart = v3.RootPart
			local scale = v3.Scale
			local bone = v3.Bone
			task.delay(0.18, function()
				local spawn = ReplicatedStorage.Chest.Etc.Serpent.Spawn
				local clone = spawn.Step1:Clone()
				SetupPart(clone.PrimaryPart)
				clone:ScaleTo(scale)
				clone:PivotTo(CFrame.new((rootPart.CFrame * CFrame.new(0, 0, 30)).Position))
				clone.Parent = effects
				Utility.EmitParticles(clone)
				_G.PU:Dust(clone, 5)
				task.delay(1.14, function()
					local clone2 = spawn.Step2:Clone()
					SetupPart(clone2.PrimaryPart)
					clone2:ScaleTo(scale)
					clone2:PivotTo(bone.TransformedWorldCFrame * CFrame.new(0, 8, -25))
					clone2.Parent = effects
					Utility.EmitParticles(clone2)
					_G.PU:Dust(clone2, 5)
				end)
			end)
		elseif mode == "Serpent Death" then
			local rootPart = v3.RootPart
			local _ = v3.Humanoid
			local character = v3.Character
			local scale = v3.Scale
			local isDespawn = v3.IsDespawn

			if not isDespawn then
				for _, descendant in pairs(character:GetDescendants()) do
					if descendant:IsA("BasePart") then
						TweenService:Create(
							descendant,
							TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 1.3),
							{
								Transparency = 1
							}
						):Play()
					elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
						descendant.Enabled = false
					end
				end
			end

			task.delay(1.3, function()
				local clone = ReplicatedStorage.Chest.Etc.Serpent.Death.Step1:Clone()
				SetupPart(clone.PrimaryPart)
				clone:ScaleTo(scale)
				clone:PivotTo(CFrame.new((rootPart.CFrame * CFrame.new(0, 0, 29)).Position))
				clone.Parent = effects
				Utility.EmitParticles(clone)
				_G.PU:Dust(clone, 5)

				if isDespawn then
					local sound = _G.PU.CreateSound({
						RollOffMaxDistance = 3000,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://136702780883099",
						Volume = 0.75
					})
					_G.PU:Dust(sound, 5)
					sound.Parent = clone.PrimaryPart
					sound:Play()
				end
			end)
		elseif mode == "Tree Z" then
			local tree = ReplicatedStorage.Chest.FruitEffect.Tree
			local character = v3.Character
			local startCF = v3.StartCF
			local chargeFolder = v3.ChargeFolder
			local skillFolder = v3.SkillFolder
			local rootPart = v3.RootPart
			local tree_KL = character:FindFirstChild("Tree_KL")

			if tree_KL then
				local function GetGround(position, value)
					local v4 = value or 1000
					local raycastParams = RaycastParams.new()
					raycastParams.IgnoreWater = true
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					local raycastResult = workspace:Raycast(
						position + createVector(0, 5, 0),
						createVector(0, -1, 0) * (v4 + 2),
						raycastParams
					)

					if raycastResult then
						return {
							Position = raycastResult.Position,
							Object = raycastResult.Instance,
							Normal = raycastResult.Normal,
							IsWall = false
						}
					end

					for _, v5 in ipairs({
						createVector(1, 0, 0),
						createVector(-1, 0, 0),
						createVector(0, 0, 1),
						createVector(0, 0, -1)
					}) do
						local raycastResult2 = workspace:Raycast(position, v5 * v4, raycastParams)

						if raycastResult2 then
							return {
								Position = raycastResult2.Position,
								Object = raycastResult2.Instance,
								Normal = raycastResult2.Normal,
								IsWall = true
							}
						end
					end

					return nil
				end

				local bone005R = tree_KL:FindFirstChild("RootPart"):FindFirstChild("Bone.005.R", true)
				local clone

				if bone005R and bone005R.Parent then
					clone = tree.ZMode.Rod:Clone()
					clone.CFrame = bone005R.WorldCFrame * CFrame.new(-2, 5, 0) * CFrame.Angles(
						-0.08726646259971647,
						0,
						0.4363323129985824
					)
					clone.Parent = effects
					_G.PU:Dust(clone, 15)
					PolyLib:Active(clone, true)
				else
					clone = nil
				end

				local function TreeZCast(child)
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://78583301117449",
						Volume = 0.5,
						TimePosition = 0.25
					})
					_G.PU:Dust(sound, 3)
					sound.Parent = rootPart
					sound:Play()
					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://110937130066170",
						Volume = 0.5
					})
					_G.PU:Dust(sound2, 5)
					sound2.Parent = rootPart
					sound2:Play()
					local startCF2 = child:GetAttribute("StartCF")

					if (localPlayer.Character.HumanoidRootPart.Position - startCF2.Position).Magnitude < 300 then
						_G.CameraShake:ShakeOnce(7, 14, 0, 0.5, createVector(0, 0, -1))
					end

					local v4 = startCF2 * CFrame.new(0, -15, -30) * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.Angles(
						0,
						0,
						-0.7853981633974483
					)
					local cFrame = v4 * CFrame.new(0, 0, 350)
					local clone2 = tree.ZMode.Slash:Clone()
					clone2:PivotTo(v4)
					clone2.Parent = effects
					_G.PU:Dust(clone2, 2)
					PolyLib:Active(clone2, true)
					PolyLib:ParticleHandler(clone2)
					TweenService:Create(
						clone2.PrimaryPart,
						TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							CFrame = cFrame
						}
					):Play()
					local v6 = {}

					for _, beam in pairs(clone2:GetDescendants()) do
						if not beam:IsA("Beam") then
							continue
						end

						local width0 = beam.Width0
						local width1 = beam.Width1
						beam.Width0 = 0
						beam.Width1 = 0
						v6[beam] = { width0, width1 }
						TweenService:Create(
							beam,
							TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								Width0 = width0,
								Width1 = width1
							}
						):Play()
					end

					task.spawn(function()
						task.wait(0.5)
						PolyLib:Active(clone2, false)
					end)
					local clone3 = tree.ZMode.Petals:Clone()
					clone3:PivotTo(startCF2 * CFrame.Angles(0, 0, 0.7853981633974483))
					clone3.Parent = effects
					_G.PU:Dust(clone3, 2)
					PolyLib:ParticleHandler(clone3)
					TweenService:Create(
						clone3.PrimaryPart,
						TweenInfo.new(0.9, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							CFrame = clone3.PrimaryPart.CFrame * CFrame.Angles(0, 2.0734511513692633, 0)
						}
					):Play()
					tick()
					PeodizService.HeartbeatWait({
						Time = 0.5
					}, function(_)
						for k, v7 in pairs(v6) do
							k.Width0 = v7[1] * math.random(25, 160) / 100
							k.Width1 = v7[2] * math.random(25, 160) / 100
						end

						if math.random(1, 2) == 1 then
							local v7 = -math.random(10, 15)
							local v8 = math.random(25, 40) * (math.random() > 0.5 and 1 or -1)
							local _, v9, _ = clone2.PrimaryPart.CFrame:ToOrientation()
							local ground = GetGround(
								(CFrame.new(clone2.PrimaryPart.CFrame.p) * CFrame.fromOrientation(0, v9, 0) * CFrame.new(
									v8,
									-3,
									-v7
								)).Position,
								60
							)

							if ground and ground.Position then
								local part = Instance.new("Part")
								part.Size = Vector3.new(
									math.random(15, 40) / 10,
									math.random(15, 40) / 10,
									math.random(15, 40) / 10
								) * math.random(15, 25) / 8
								part.Color = ground.Object.Color
								part.Material = ground.Object.Material
								part.Anchored = true
								part.CanCollide = false
								part.CFrame = CFrame.new(ground.Position) * CFrame.Angles(
									6.283185307179586 * math.random(),
									6.283185307179586 * math.random(),
									6.283185307179586 * math.random()
								)
								part.Parent = effects
								_G.PU:Dust(part, 1.25)
								TweenService:Create(
									part,
									TweenInfo.new(
										math.random(40, 60) / 100,
										Enum.EasingStyle.Exponential,
										Enum.EasingDirection.Out
									),
									{
										CFrame = CFrame.new(ground.Position) * CFrame.Angles(
											0,
											6.283185307179586 * math.random(),
											0
										) * CFrame.new(0, math.random(25, 55), math.random(0, 10)) * CFrame.Angles(
											6.283185307179586 * math.random(),
											6.283185307179586 * math.random(),
											6.283185307179586 * math.random()
										)
									}
								):Play()
								task.delay(math.random(15, 25) / 100, function()
									TweenService:Create(
										part,
										TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Size = Vector3.new()
										}
									):Play()
								end)
							end
						end
					end)
				end

				local childAddedConnection = nil
				childAddedConnection = skillFolder.ChildAdded:Connect(function(child)
					TreeZCast(child)
					childAddedConnection:Disconnect()
				end)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://128663844625558",
					Volume = 1
				})
				_G.PU:Dust(sound, 5)
				sound.Parent = rootPart
				sound:Play()
				local v4 = Scheduler.new(10)
				v4:Wait()
				v4:OnStep(function()
					if not chargeFolder:IsDescendantOf(character) then
						v4:Destroy()
					elseif bone005R and bone005R.Parent and clone and clone.Parent then
						clone.CFrame = bone005R.WorldCFrame * CFrame.new(-2, 5, 0) * CFrame.Angles(
							-0.08726646259971647,
							0,
							0.4363323129985824
						)
					end
				end)
				v4:Execute()

				if clone and clone.Parent then
					PolyLib:Active(clone, false)
					_G.PU:Dust(clone, 1)
				end
			elseif not tree_KL then
				if (localPlayer.Character.HumanoidRootPart.Position - startCF.Position).Magnitude < 300 then
					_G.CameraShake:ShakeOnce(8, 12, 0, 0.4, createVector(0, 0, -1))
				end

				local clone = tree.ZBase.WoodPunch:Clone()
				clone:PivotTo(startCF)
				clone.Parent = effects
				_G.PU:Dust(clone, 2.5)
				PolyLib:ParticleHandler(clone)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://75456364736703",
					Volume = 0.4
				})
				_G.PU:Dust(sound, 2.5)
				sound.Parent = clone.PrimaryPart
				sound:Play()
				local clone2 = tree.ZBase.Mesh1:Clone()
				clone2.CFrame = startCF * CFrame.new(0, 0, -60) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone2.Parent = effects
				_G.PU:Dust(clone2, 1)
				task.spawn(function()
					clone2.HazeDecal.Transparency = 0
					clone2.HazeDecal.Color3 = Color3.fromRGB(406, 510, 268)
					TweenService:Create(
						clone2.HazeDecal,
						TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
						{
							Color3 = Color3.fromRGB(255, 255, 255),
							Transparency = 0.75
						}
					):Play()
					wait(0.2)
					TweenService:Create(
						clone2.HazeDecal,
						TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
						{
							Transparency = 1
						}
					):Play()
				end)
				task.spawn(function()
					-- equivalent calls inferred from this helper; original call sites unknown
					local function SpikeFunction(clone3)
						task.spawn(function()
							local cFrame = clone3.Base.CFrame
							local v4 = math.rad((math.random(5, 15)))
							local v5 = math.random() * 3.141592653589793 * 2
							local v6 = math.cos(v5)
							local v7 = math.sin(v5)
							local v8 = {
								Part1 = createVector(11.215, 2.876, 11.215),
								Part2 = createVector(7.869, 8.142, 7.996),
								Part3 = createVector(4.779, 6.751, 6.925),
								Part4 = createVector(3.124, 11.12, 4.266)
							}
							local total = 0
							local cframe = CFrame.new()
							local v9 = {}
							local v10 = Scheduler.Repeat(1, 4)
							v10:Instant()
							v10:OnStep(function(p)
								clone3["Part" .. p].Size = Vector3.new()
							end)
							v10:Execute()
							wait()
							local v11 = Scheduler.Repeat(1, 4)
							v11:Instant()
							v11:Wait(0.075)
							v11:OnStep(function(p)
								local part = clone3["Part" .. p]
								local size = v8["Part" .. p]
								local Y = size.Y
								local vector2 = Vector3.new(size.X, 0, size.Z)
								CFrame.new()
								local v14 = v4 / 4 * p
								local cframe2 = CFrame.Angles(v6 * v14, 0, v7 * v14)
								local v15 = cFrame * cframe * CFrame.new(0, total, 0)
								local v16 = cFrame * cframe * CFrame.new(0, total + Y / 2, 0) * cframe2
								part.Size = vector2
								part.CFrame = v15
								local cFrame2 = v16 * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
								v9[p] = {
									Part = part,
									StartSize = vector2,
									StartCF = v15
								}
								TweenService:Create(
									part,
									TweenInfo.new(0.125, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
									{
										Size = size,
										CFrame = cFrame2
									}
								):Play()
								cframe = cframe * CFrame.new(0, Y, 0) * cframe2 * CFrame.new(0, -Y, 0)
								total += Y
							end)
							v11:Execute()
							task.wait(0.5)
							local v12 = Scheduler.Repeat(4, 1, -1)
							v12:Instant()
							v12:Wait(0.025)
							v12:OnStep(function(p)
								local v13 = v9[p]
								local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.In)
								TweenService:Create(v13.Part, tweenInfo, {
									Size = Vector3.new(0, v13.Part.Size.Y, 0)
								}):Play()
								task.spawn(function()
									task.wait(0.1)
									v13.Part.Transparency = 1
								end)
							end)
							v12:Execute()
						end)
					end

					local v4 = Scheduler.Repeat(1, 4)
					v4:Instant()
					v4:OnStep(function(p)
						task.spawn(function()
							local clone3 = tree.ZBase.Spike:Clone()
							clone3:PivotTo(startCF * CFrame.new(-math.random(15, 25), -5, -25 * p) * CFrame.Angles(
								math.rad((math.random(-20, 20))),
								0,
								(math.rad((math.random(20, 40))))
							))
							clone3.Parent = effects
							_G.PU:Dust(clone3, 2)
							SpikeFunction(clone3) -- equivalent call inferred; original call site unknown
						end)
						task.spawn(function()
							local clone3 = tree.ZBase.Spike:Clone()
							clone3:PivotTo(startCF * CFrame.new(math.random(15, 25), -5, -25 * p) * CFrame.Angles(
								math.rad((math.random(-20, 20))),
								0,
								(math.rad(-math.random(20, 40)))
							))
							clone3.Parent = effects
							_G.PU:Dust(clone3, 2)
							SpikeFunction(clone3) -- equivalent call inferred; original call site unknown
						end)
					end)
					v4:Execute()
				end)
				PeodizService.HeartbeatWait({
					Time = 0.75
				}, function(p)
					local v4 = 1 - math.pow(1 - p, 3)
					local v5 = v4 * -60 + -60
					local v6 = 0 + 6.283185307179586 * v4
					clone2.CFrame = startCF * CFrame.new(0, 0, v5) * CFrame.Angles(1.5707963267948966, v6, 0)
				end)
			end
		elseif mode == "Tree X" then
			local fruitEffect = ReplicatedStorage.Chest.FruitEffect
			local character = v3.Character
			local _ = v3.StartCF
			local chargeFolder = v3.ChargeFolder
			local rootPart = v3.RootPart
			local skillFolder = v3.SkillFolder
			local tree_KL = character:FindFirstChild("Tree_KL")

			if tree_KL then
				local function shootVine(child)
					local cFMouse = child:GetAttribute("CFMouse")
					local cframe = CFrame.new(cFMouse.Position)

					if (localPlayer.Character.HumanoidRootPart.Position - cframe.Position).Magnitude < 300 then
						_G.CameraShake:ShakeOnce(1.5, 12, 0, 0.3, createVector(0, 0, -1))
					end

					task.spawn(function()
						-- equivalent calls inferred from this helper; original call sites unknown
						local function SpikeFunction(clone)
							task.spawn(function()
								local cFrame = clone.Base.CFrame
								math.rad((math.random(5, 15)))
								local v4 = math.random() * 3.141592653589793 * 2
								math.cos(v4)
								math.sin(v4)
								local v5 = {
									Part1 = createVector(15.706, 4.027, 15.706),
									Part2 = createVector(11.021, 11.403, 11.199),
									Part3 = createVector(6.693, 9.455, 9.699),
									Part4 = createVector(4.376, 15.575, 5.975)
								}
								local total = 0
								local cframe2 = CFrame.new()
								local v6 = {}
								local v7 = Scheduler.Repeat(1, 4)
								v7:Instant()
								v7:OnStep(function(p)
									local v8 = clone["Part" .. p]
									v8.Transparency = 0
									v8.Size = Vector3.new()
								end)
								v7:Execute()
								wait()
								local v8 = Scheduler.Repeat(1, 4)
								v8:Instant()
								v8:Wait(0.035)
								v8:OnStep(function(p)
									local part = clone["Part" .. p]
									local size = v5["Part" .. p]
									local Y = size.Y
									local vector2 = Vector3.new(size.X, 0, size.Z)
									local cframe3 = CFrame.new()
									local v11 = cFrame * cframe2 * CFrame.new(0, total, 0)
									local v12 = cFrame * cframe2 * CFrame.new(0, total + Y / 2, 0) * cframe3
									part.Size = vector2
									part.CFrame = v11
									local cFrame2 = v12 * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
									v6[p] = {
										Part = part,
										StartSize = vector2,
										StartCF = v11
									}
									TweenService:Create(
										part,
										TweenInfo.new(0.125, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
										{
											Size = size,
											CFrame = cFrame2
										}
									):Play()
									total += Y
									task.wait(0.035)

									if p == 1 then
										clone.VFXBase.CFrame = CFrame.new(cFrame2.p + createVector(0, 3, 0))
										clone.VFX.CFrame = cFrame2
										PolyLib:ParticleHandler(clone.VFX)
										PolyLib:ParticleHandler(clone.VFXBase)
									end
								end)
								v8:Execute()
								task.wait(0.5)
								local v9 = Scheduler.Repeat(4, 1, -1)
								v9:Instant()
								v9:Wait(0.025)
								v9:OnStep(function(p)
									local v10 = v6[p]
									local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.In)
									TweenService:Create(v10.Part, tweenInfo, {
										Size = Vector3.new(0, v10.Part.Size.Y, 0)
									}):Play()
									task.spawn(function()
										task.wait(0.1)
										v10.Part.Transparency = 1
									end)
								end)
								v9:Execute()
							end)
						end

						local v4 = cframe * CFrame.new(math.random(-25, 25), 0, math.random(-25, 25)) * CFrame.Angles(
							0,
							6.283185307179586 * math.random(),
							0
						) * CFrame.Angles(math.rad((math.random(5, 25))), 0, 0)
						local clone = fruitEffect.Tree.XMode.Spike3:Clone()
						clone:PivotTo(v4)
						clone.Parent = effects
						_G.PU:Dust(clone, 3)
						SpikeFunction(clone) -- equivalent call inferred; original call site unknown
						local sound = PeoUtils.CreateSound({
							RollOffMaxDistance = 1000,
							RollOffMinDistance = 50,
							RollOffMode = Enum.RollOffMode.InverseTapered,
							SoundId = "rbxassetid://105252212480701",
							Volume = 0.5
						})
						_G.PU:Dust(sound, 3)
						sound.Parent = clone.PrimaryPart
						sound:Play()
					end)
					local v4 = CFrame.new(cFMouse.Position) * CFrame.new(0, 3, 0)
					CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					local cframe2 = CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
					local v5 = v4 * cframe2 * CFrame.new(0, 0, 90)
					local v6 = v4 * cframe2 * CFrame.new(0, 0, -90)
					local clone = fruitEffect.Tree.XMode.Torando:Clone()
					clone:PivotTo(v5)
					clone.Parent = effects
					_G.PU:Dust(clone, 1.5)
					PolyLib:ParticleHandler(clone.Pillar.Impact)
					PolyLib:ParticleHandler(clone)

					for _, beam in pairs(clone.Tornado:GetDescendants()) do
						if not beam:IsA("Beam") then
							continue
						end

						beam.Enabled = true
						local width0 = beam.Width0
						local width1 = beam.Width1
						beam.Width0 = 0
						beam.Width1 = 0
						TweenService:Create(beam, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
							Width0 = width0,
							Width1 = width1
						}):Play()
						local v7 = beam
						task.spawn(function()
							task.wait(0.65)
							TweenService:Create(
								v7,
								TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Width0 = 0,
									Width1 = 0
								}
							):Play()
							task.wait(0.3)
							v7.Enabled = false
						end)
					end

					local total = 0
					task.spawn(function()
						task.wait(0.2)
						local clone2 = fruitEffect.Tree.XMode.exp:Clone()
						clone2.CFrame = CFrame.new(v4.p)
						clone2.Parent = effects
						_G.PU:Dust(clone2, 1)
						PolyLib:ParticleHandler(clone2)
					end)
					local v7 = Scheduler.new(0.7)
					v7:Ignore()
					v7:OnStep(function(p)
						local v8 = 1 - math.pow(1 - math.clamp(-0.1 + p * 0.9, 0, 1), 3)
						local lerped = v5:Lerp(v6, v8)
						local v9 = 3.141592653589793 + -2.792526803190927 * v8
						total += v9 * p

						for i = 1, 6 do
							clone.Tornado["Beam" .. i].Orientation += Vector3.new(0, i * 2, 0)
						end

						clone:PivotTo(lerped)
						clone.RootPart.Tornado.C0 = clone.RootPart.Tornado.C0 * CFrame.Angles(0, 0.5235987755982988, 0)
						clone.RootPart.Rotate.C0 = clone.RootPart.Rotate.C0 * CFrame.Angles(0, 0.17453292519943295, 0)
						clone.RootPart.Rotate2.C0 = clone.RootPart.Rotate2.C0 * CFrame.Angles(0, 0.10471975511965978, 0)
					end)
					v7:Execute()
				end

				local clone = fruitEffect.Tree.XMode.Pull:Clone()
				clone.CFrame = rootPart.CFrame * CFrame.new(5, -22, -15)
				clone.Parent = effects
				_G.PU:Dust(clone, 5)
				PolyLib:Active(clone, true)
				local childAddedConnection = skillFolder.ChildAdded:Connect(function(child)
					shootVine(child)
				end)
				local v4 = Scheduler.new(3)
				v4:Wait()
				v4:OnStep(function()
					if chargeFolder:IsDescendantOf(character) then
						clone.CFrame = rootPart.CFrame * CFrame.new(5, -22, -15)
					else
						v4:Destroy()
					end
				end)
				v4:Execute()

				if clone and clone.Parent then
					PolyLib:Active(clone, false)
					_G.PU:Dust(clone, 1)
				end

				if childAddedConnection and childAddedConnection.Connected then
					childAddedConnection:Disconnect()
				end
			elseif not tree_KL then
				local clone = fruitEffect.Tree.XBase.StartUp:Clone()
				clone:PivotTo(CFrame.new(rootPart.Position))
				clone.Parent = effects
				_G.PU:Dust(clone, 2)
				PolyLib:ParticleHandler(clone)

				if localPlayer == v then
					local clone2 = fruitEffect.Tree.Transfrom.CameraFX:Clone()
					SetupPart(clone2)
					clone2.Parent = effects
					_G.PU:Dust(clone2, 5)
					task.delay(3, function()
						Utility.ParticleHandler(clone2, false)
					end)
					task.spawn(function()
						FastRenderer.new({
							Time = 4
						}, function(_)
							if clone2 and clone2.Parent then
								clone2.CFrame = currentCamera.CFrame
							else
								return true
							end
						end)
					end)
				end

				local function SpikeFunction(clone2)
					local cFrame = clone2.Base.CFrame
					local v4 = math.rad((math.random(5, 15)))
					local v5 = math.random() * 3.141592653589793 * 2
					local v6 = math.cos(v5)
					local v7 = math.sin(v5)
					local v8 = {
						Part1 = createVector(14.944, 3.832, 14.944),
						Part2 = createVector(10.486, 10.849, 10.655),
						Part3 = createVector(6.368, 8.996, 9.228),
						Part4 = createVector(4.163, 14.818, 5.685)
					}
					local total = 0
					local cframe = CFrame.new()
					local v9 = {}
					local v10 = Scheduler.Repeat(1, 4)
					v10:Instant()
					v10:OnStep(function(p)
						local v11 = clone2["Part" .. p]
						v11.Transparency = 0
						v11.Size = Vector3.new()
					end)
					v10:Execute()
					wait()
					Scheduler.Repeat(1, 4):OnStep(function(p)
						local part = clone2["Part" .. p]
						local size = v8["Part" .. p]
						local Y = size.Y
						local vector2 = Vector3.new(size.X, 0, size.Z)
						CFrame.new()
						local v13 = v4 / 4 * p
						local cframe2 = CFrame.Angles(v6 * v13, 0, v7 * v13)
						local v14 = cFrame * cframe * CFrame.new(0, total, 0)
						local v15 = cFrame * cframe * CFrame.new(0, total + Y / 2, 0) * cframe2
						part.Size = vector2
						part.CFrame = v14
						local cFrame2 = v15 * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
						v9[p] = {
							Part = part,
							StartSize = vector2,
							StartCF = v14
						}
						TweenService:Create(
							part,
							TweenInfo.new(0.125, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								Size = size,
								CFrame = cFrame2
							}
						):Play()
						cframe = cframe * CFrame.new(0, Y, 0) * cframe2 * CFrame.new(0, -Y, 0)
						total += Y

						if p == 1 then
							clone2.VFX.CFrame = cFrame2
							PolyLib:ParticleHandler(clone2.VFX)
						end
					end):Wait(0.035):Execute()
					task.wait(0.5)
					Scheduler.Repeat(4, 1, -1):Wait(0.025):OnStep(function(p)
						local v11 = v9[p]
						local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.In)
						TweenService:Create(v11.Part, tweenInfo, {
							Size = Vector3.new(0, v11.Part.Size.Y, 0)
						}):Play()
						task.spawn(function()
							task.wait(0.1)
							v11.Part.Transparency = 1
						end)
					end):Execute()
				end

				local function CreateSpike(child)
					local startCF = child:GetAttribute("StartCF")
					local clone2 = fruitEffect.Tree.XBase.Spike3:Clone()
					clone2:PivotTo(startCF)
					clone2.Parent = effects
					_G.PU:Dust(clone2, 3)
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://123171254069142",
						Volume = 0.25
					})
					_G.PU:Dust(sound, 3)
					sound.Parent = clone2.PrimaryPart
					sound:Play()
					SpikeFunction(clone2)
				end

				local childAddedConnection = skillFolder.ChildAdded:Connect(function(child)
					CreateSpike(child)
				end)
				local v4 = Scheduler.new(3)
				v4:OnStep(function()
					if chargeFolder:IsDescendantOf(character) then
						return
					end

					v4:Destroy()
				end)
				v4:Execute()
				task.wait(0.075)
				local clone2 = fruitEffect.Tree.XBase.EndUp:Clone()
				clone2:PivotTo(CFrame.new(rootPart.Position))
				clone2.Parent = effects
				_G.PU:Dust(clone2, 2)
				PolyLib:ParticleHandler(clone2)
				task.wait(2)

				if childAddedConnection and childAddedConnection.Connected then
					childAddedConnection:Disconnect()
				end
			end
		elseif mode == "Tree C" then
			local fruitEffect = ReplicatedStorage.Chest.FruitEffect
			local chargeFolder = v3.ChargeFolder
			local character = v3.Character
			local startCF = v3.StartCF
			local speed = v3.Speed
			local cFMouse = v3.CFMouse
			local maxMouse = v3.MaxMouse
			local rootPart = v3.RootPart
			local skillFolder = v3.SkillFolder
			local tree_KL = character:FindFirstChild("Tree_KL")

			if tree_KL then
				local function GetGround(position, value)
					local v4 = value or 1000
					local raycastParams = RaycastParams.new()
					raycastParams.IgnoreWater = true
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					local raycastResult = workspace:Raycast(
						position + createVector(0, 5, 0),
						createVector(0, -1, 0) * (v4 + 2),
						raycastParams
					)

					if raycastResult then
						return {
							Position = raycastResult.Position,
							Object = raycastResult.Instance,
							Normal = raycastResult.Normal,
							IsWall = false
						}
					end

					for _, v5 in ipairs({
						createVector(1, 0, 0),
						createVector(-1, 0, 0),
						createVector(0, 0, 1),
						createVector(0, 0, -1)
					}) do
						local raycastResult2 = workspace:Raycast(position, v5 * v4, raycastParams)

						if raycastResult2 then
							return {
								Position = raycastResult2.Position,
								Object = raycastResult2.Instance,
								Normal = raycastResult2.Normal,
								IsWall = true
							}
						end
					end

					return nil
				end

				local function shoot(child)
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://108045912470712",
						Volume = 0.5
					})
					_G.PU:Dust(sound, 5)
					sound.Parent = rootPart
					sound:Play()
					local fromcf = child:GetAttribute("fromcf")
					local tocf = child:GetAttribute("tocf")
					local duration = child:GetAttribute("duration")
					local v4 = fromcf:Lerp(tocf, 0.5) * CFrame.Angles(
						6.283185307179586 * math.random(),
						0,
						6.283185307179586 * math.random()
					) * CFrame.new(0, math.random(10, 25) * 6, 0)
					local clone = fruitEffect.Tree.CMode.pjt:Clone()
					clone.CFrame = fromcf
					clone.Parent = effects
					_G.PU:Dust(clone, 1)

					local function cubicOut(p)
						return 1 - math.pow(1 - p, 3)
					end

					-- equivalent calls inferred from this helper; original call sites unknown
					local function quadBezier(p, fromcf2, p2, p3)
						return fromcf2:Lerp(p2, p):Lerp(p2:Lerp(p3, p), p)
					end

					local v5 = fromcf
					task.spawn(function()
						local v6 = Scheduler.Repeat(1, 3)
						v6:Wait(duration / 4)
						v6:OnStep(function(_)
							local clone2 = fruitEffect.Tree.CMode.spiral:Clone()
							clone2.CFrame = clone.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
							clone2.Parent = effects
							_G.PU:Dust(clone2, 1)
							PolyLib:ParticleHandler(clone2)
							TweenService:Create(
								clone2,
								TweenInfo.new(0.75, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
								{
									CFrame = clone2.CFrame * CFrame.Angles(0, 3.078760800517997, 0)
								}
							):Play()
						end)
						v6:Execute()
					end)
					PeodizService.HeartbeatWait({
						Time = duration
					}, function(p)
						local v8 = quadBezier(p, fromcf, v4, tocf) -- equivalent call inferred; original call site unknown

						if p >= 0.99 then
							clone.CFrame = tocf
						else
							local v12 = quadBezier(p + 0.05, fromcf, v4, tocf) -- equivalent call inferred; original call site unknown
							clone.CFrame = CFrame.new(v8.p, v12.p)
						end

						v5 = v8
					end)
					PolyLib:Active(clone, false)
					TweenService:Create(
						clone,
						TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()

					if (localPlayer.Character.HumanoidRootPart.Position - tocf.Position).Magnitude < 300 then
						_G.CameraShake:ShakeOnce(1.5, 6, 0, 0.3, createVector(0, 0, -1))
					end

					local clone2 = fruitEffect.Tree.CMode.exp:Clone()
					clone2.CFrame = CFrame.new(tocf.p)
					clone2.Parent = effects
					_G.PU:Dust(clone2, 3)
					PolyLib:ParticleHandler(clone2)
					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://92264016690708",
						Volume = 0.5
					})
					_G.PU:Dust(sound2, 3)
					sound2.Parent = clone2
					sound2:Play()
					local clone3 = fruitEffect.Tree.CMode.Rotate:Clone()
					clone3.CFrame = CFrame.new(tocf.p)
					clone3.Parent = effects
					_G.PU:Dust(clone3, 2)
					PolyLib:ParticleHandler(clone3)
					TweenService:Create(clone3, TweenInfo.new(0.8, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
						CFrame = clone3.CFrame * CFrame.Angles(0, 3.1101767270538954, 0)
					}):Play()
					local v6 = math.random(1, 3)
					local v7 = Scheduler.Repeat(1, v6)
					v7:Instant()
					v7:Wait()
					v7:OnStep(function(p)
						local v8 = math.random(5, 15)
						local v9 = CFrame.new(tocf.p) * CFrame.Angles(0, 6.283185307179586 / v6 * p, 0) * CFrame.new(
							0,
							0,
							-v8
						)
						local ground = GetGround(v9.Position, 40, {
							Enum.RaycastFilterType.Exclude,
							{ workspace.Effects }
						})

						if ground and ground.Position then
							local v11 = v9 - v9.p
							local part = Instance.new("Part")
							part.Size = Vector3.new(
								math.random(15, 40) / 10,
								math.random(15, 40) / 10,
								math.random(15, 40) / 10
							) * math.random(15, 25) / 13
							part.Color = ground.Object.Color
							part.Material = ground.Object.Material
							part.Anchored = true
							part.CanCollide = false
							part.CFrame = CFrame.new(ground.Position) * CFrame.Angles(
								6.283185307179586 * math.random(),
								6.283185307179586 * math.random(),
								6.283185307179586 * math.random()
							)
							part.Parent = effects
							_G.PU:Dust(part, 1.25)
							local cFrame = CFrame.new(ground.Position) * v11 * CFrame.new(
								math.random(0, 10),
								math.random(25, 40) * 1.5,
								math.random(0, 10)
							) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.Angles(
								6.283185307179586 * math.random(),
								6.283185307179586 * math.random(),
								6.283185307179586 * math.random()
							)
							TweenService:Create(
								part,
								TweenInfo.new(
									math.random(40, 60) / 100,
									Enum.EasingStyle.Exponential,
									Enum.EasingDirection.Out
								),
								{
									CFrame = cFrame
								}
							):Play()
							task.delay(math.random(10, 20) / 100, function()
								TweenService:Create(
									part,
									TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Size = Vector3.new()
									}
								):Play()
							end)
						end
					end)
					v7:Execute()
				end

				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://96069860490826",
					Volume = 0.5
				})
				_G.PU:Dust(sound, 5)
				sound.Parent = rootPart
				sound:Play()
				local clone = fruitEffect.Tree.CMode.charge:Clone()
				clone.CFrame = rootPart.CFrame * CFrame.new(0, -10, -30)
				clone.Parent = effects
				_G.PU:Dust(clone, 12)
				Utility.ParticleHandler(clone, true)
				local childAddedConnection = skillFolder.ChildAdded:Connect(function(child)
					task.spawn(function()
						shoot(child)
					end)
				end)
				local v4 = Scheduler.new(10)
				v4:Wait()
				v4:OnStep(function()
					if not chargeFolder:IsDescendantOf(character) then
						v4:Destroy()
					elseif not clone then
						v4:Destroy()
					elseif clone and not clone.Parent then
						v4:Destroy()
					else
						clone.CFrame = rootPart.CFrame * CFrame.new(0, -10, -30)
					end
				end)
				v4:Execute()
				Utility.ParticleHandler(clone, false)
				local clone2 = fruitEffect.Tree.CMode.Rotate:Clone()
				clone2.CFrame = clone.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
				clone2.Parent = effects
				_G.PU:Dust(clone2, 2)
				TweenService:Create(clone2, TweenInfo.new(0.8, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					CFrame = clone2.CFrame * CFrame.Angles(0, 3.1101767270538954, 0)
				}):Play()
				PolyLib:ParticleHandler(clone2)
				local tree_KL2 = character:FindFirstChild("Tree_KL")

				if tree_KL2 then
					local highlight = Instance.new("Highlight")
					highlight.DepthMode = Enum.HighlightDepthMode.Occluded
					highlight.FillColor = Color3.fromRGB(170, 255, 127)
					highlight.OutlineTransparency = 1
					highlight.FillTransparency = 0
					highlight.Parent = tree_KL2
					_G.PU:Dust(highlight, 2)
					TweenService:Create(
						highlight,
						TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							FillTransparency = 1
						}
					):Play()
				end

				local clone3 = fruitEffect.Tree.CMode.Impact:Clone()
				clone3.CFrame = clone.CFrame
				clone3.Parent = effects
				_G.PU:Dust(clone3, 3)
				Utility.EmitParticles(clone3)
				task.wait(3)

				if childAddedConnection and childAddedConnection.Connected then
					childAddedConnection:Disconnect()
				end
			elseif not tree_KL then
				local clone = fruitEffect.Tree.CBase.shootfx:Clone()
				clone.CFrame = startCF * CFrame.new(0, 0, -5)
				clone.Parent = effects
				_G.PU:Dust(clone, 1)
				PolyLib:ParticleHandler(clone)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://71487530100533",
					Volume = 0.5
				})
				_G.PU:Dust(sound, 4)
				sound.Parent = rootPart
				sound:Play()
				local clone2 = fruitEffect.Tree.CBase.Bullet:Clone()
				clone2.CFrame = startCF * CFrame.new(0, 0, -5) * CFrame.Angles(-1.5707963267948966, 0, 0)
				clone2.Parent = effects
				_G.PU:Dust(clone2, 1)
				TweenService:Create(clone2, TweenInfo.new(speed, Enum.EasingStyle.Linear), {
					CFrame = startCF * CFrame.new(0, 0, -maxMouse) * CFrame.Angles(-1.5707963267948966, 0, 0)
				}):Play()
				task.spawn(function()
					local v4 = math.floor(speed / 0.035)
					local v5 = Scheduler.Repeat(1, v4)
					v5:Wait(0.035)
					v5:OnStep(function(_)
						local clone3 = fruitEffect.Tree.CBase.spiral:Clone()
						clone3.CFrame = clone2.CFrame
						clone3.Parent = effects
						_G.PU:Dust(clone3, 1)
						PolyLib:ParticleHandler(clone3)
						task.delay(0.035, function()
							TweenService:Create(
								clone3,
								TweenInfo.new(0.75, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
								{
									CFrame = clone3.CFrame * CFrame.Angles(0, 3.078760800517997, 0)
								}
							):Play()
						end)
					end)
					v5:Execute()
				end)

				if (localPlayer.Character.HumanoidRootPart.Position - startCF.Position).Magnitude < 200 then
					_G.CameraShake:ShakeOnce(4, 12, 0, 0.2, createVector(0, 0, -1))
				end

				task.wait(speed)

				if clone2 and clone2.Parent then
					TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = Vector3.new()
					}):Play()
				end

				task.spawn(function()
					local v4 = cFMouse.Position + createVector(0, 10, 0)
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					local raycastResult = workspace:Raycast(v4, createVector(0, -40, 0), raycastParams)

					if raycastResult then
						local position = raycastResult.Position
						local clone3 = fruitEffect.Tree.CBase.Ground_Ray:Clone()
						clone3.Anchored = true
						clone3.CanCollide = false
						clone3.Transparency = 1
						clone3.CFrame = CFrame.new(position)
						clone3.Parent = effects
						_G.PU:Dust(clone3, 5)
						task.delay(2, function()
							Utility.ParticleHandler(clone3, false)
						end)
					end
				end)
				local clone3 = fruitEffect.Tree.CBase.Domain:Clone()
				clone3:PivotTo(CFrame.new(cFMouse.Position))
				clone3.Parent = effects
				_G.PU:Dust(clone3, 4)
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 75,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://139881391521420",
					Volume = 0.5
				})
				_G.PU:Dust(sound2, 4)
				sound2.Parent = clone3.PrimaryPart
				sound2:Play()
				PolyLib:ParticleHandler(clone3, true)

				for _, part in pairs(clone3:GetChildren()) do
					if not part:IsA("BasePart") then
						continue
					end

					local size = part.Size
					part.Size = Vector3.new()
					TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = size
					}):Play()
					local v4 = part
					task.delay(2.2, function()
						TweenService:Create(
							v4,
							TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Size = Vector3.new()
							}
						):Play()
					end)
				end

				if (localPlayer.Character.HumanoidRootPart.Position - cFMouse.Position).Magnitude < 200 then
					_G.CameraShake:ShakeOnce(10, 18, 0, 0.45, createVector(0, 0, -1))
				end

				local lastTime = tick()
				local clone4 = fruitEffect.Tree.CBase.Rotate:Clone()
				clone4.CFrame = CFrame.new(cFMouse.p)
				clone4.Parent = effects
				_G.PU:Dust(clone4, 2)
				TweenService:Create(clone4, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					CFrame = clone4.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, 3.1101767270538954, 0)
				}):Play()
				PolyLib:ParticleHandler(clone4)
				PeodizService.HeartbeatWait({
					Time = 2.5
				}, function(_)
					if tick() - lastTime > 0.1 then
						lastTime = tick()

						if (localPlayer.Character.HumanoidRootPart.Position - cFMouse.Position).Magnitude < 200 then
							_G.CameraShake:ShakeOnce(1, 12, 0, 0.2, createVector(0, 0, -1))
						end
					end

					if clone3 and clone3.Parent then
						if clone3:FindFirstChild("Petal1") then
							clone3.Petal1.CFrame = clone3.Petal1.CFrame * CFrame.Angles(0, 0.13962634015954636, 0)
						end

						if clone3:FindFirstChild("Petal2") then
							clone3.Petal2.CFrame = clone3.Petal2.CFrame * CFrame.Angles(0, 0.09308422677303091, 0)
						end
					end
				end)
			end
		elseif mode == "Tree V" then
			local fruitEffect = ReplicatedStorage.Chest.FruitEffect
			local state = v3.State
			local character = v3.Character
			local rootPart = v3.RootPart
			local toCF = v3.ToCF
			local humanoid = v3.Humanoid

			if state == "Transform" then
				local function GetGround(position, value)
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					local raycastResult = workspace:Raycast(
						position + createVector(0, 5, 0),
						createVector(0, -1, 0) * ((value or 1000) + 2),
						raycastParams
					)

					if raycastResult then
						return {
							Position = raycastResult.Position,
							Object = raycastResult.Instance
						}
					end
				end

				local function transfromfx(toCF2)
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://126676062055293",
						Volume = 0.5
					})
					_G.PU:Dust(sound, 5)
					sound.Parent = rootPart
					sound:Play()

					if localPlayer == v then
						local clone = fruitEffect.Tree.Transfrom.CameraFX:Clone()
						SetupPart(clone)
						clone.Parent = effects
						_G.PU:Dust(clone, 5)
						task.delay(0.8, function()
							Utility.ParticleHandler(clone, false)
						end)
						task.spawn(function()
							FastRenderer.new({
								Time = 3
							}, function(_)
								if clone and clone.Parent then
									clone.CFrame = currentCamera.CFrame
								else
									return true
								end
							end)
						end)
					end

					local childAddedConnection = nil
					task.delay(5, function()
						if childAddedConnection and childAddedConnection.Connected then
							childAddedConnection:Disconnect()
						end
					end)
					childAddedConnection = character.ChildAdded:Connect(function(parent)
						if parent.Name == "Tree_KL" then
							local highlight = Instance.new("Highlight")
							highlight.DepthMode = Enum.HighlightDepthMode.Occluded
							highlight.FillColor = Color3.fromRGB(170, 255, 127)
							highlight.OutlineTransparency = 1
							highlight.FillTransparency = 0
							highlight.Parent = parent
							_G.PU:Dust(highlight, 2)
							task.spawn(function()
								TweenService:Create(
									highlight,
									TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
									{
										FillTransparency = 1
									}
								):Play()
							end)
							childAddedConnection:Disconnect()
							childAddedConnection = nil
						end
					end)
					local clone = fruitEffect.Tree.Transfrom.Lightning:Clone()
					clone:PivotTo(toCF2)
					clone.Parent = effects
					_G.PU:Dust(clone, 2)
					PolyLib:ParticleHandler(clone)
					local clone2 = fruitEffect.Tree.Transfrom.charge:Clone()
					clone2.CFrame = toCF2
					clone2.Parent = effects
					_G.PU:Dust(clone2, 2)
					PolyLib:ParticleHandler(clone2)
					local v4 = Scheduler.new(1)
					v4:Ignore()
					v4:OnStep(function()
						if not rootPart then
							v4:Destroy()
						end

						if rootPart and not rootPart.Parent then
							v4:Destroy()
						end

						if clone and clone.PrimaryPart and clone.PrimaryPart.Parent then
							clone:PivotTo(rootPart.CFrame)
						end

						if clone2 and clone2.Parent then
							clone2.CFrame = rootPart.CFrame
						end
					end)
					v4:Execute()

					if (localPlayer.Character.HumanoidRootPart.Position - toCF.Position).Magnitude < 200 then
						local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
						colorCorrectionEffect.Brightness = 0.25
						colorCorrectionEffect.Parent = Lighting
						_G.PU:Dust(colorCorrectionEffect, 2)
						task.spawn(function()
							TweenService:Create(
								colorCorrectionEffect,
								TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Brightness = -0.15,
									Contrast = 0.5,
									Saturation = -0.2,
									TintColor = Color3.fromRGB(228, 255, 199)
								}
							):Play()
							task.wait(0.2)
							TweenService:Create(
								colorCorrectionEffect,
								TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
								{
									Brightness = 0,
									Contrast = 0,
									Saturation = 0,
									TintColor = Color3.fromRGB(255, 255, 255)
								}
							):Play()
						end)
					end

					task.wait(0.55)
					local clone3 = fruitEffect.Tree.Transfrom.Step2:Clone()
					clone3.CFrame = rootPart.CFrame
					clone3.Parent = effects
					_G.PU:Dust(clone3, 3)
					Utility.EmitParticles(clone3)
					local weld = Instance.new("Weld")
					weld.Part0 = rootPart
					weld.Part1 = clone3
					weld.Parent = clone3
					_G.PU:Dust(weld, 3)
					local v5 = nil
					task.spawn(function()
						local position = rootPart.Position
						local raycastParams = RaycastParams.new()
						raycastParams.FilterType = Enum.RaycastFilterType.Include
						raycastParams.FilterDescendantsInstances = { workspace.Island }
						local raycastResult = workspace:Raycast(position, createVector(0, -50, 0), raycastParams)

						if raycastResult then
							local position2 = raycastResult.Position
							v5 = position2
							local clone4 = fruitEffect.Tree.Transfrom.Ground_Ray:Clone()
							clone4.Anchored = true
							clone4.CanCollide = false
							clone4.Transparency = 1
							clone4.CFrame = CFrame.new(position2 + Vector3.new(0, clone4.Size.Y / 2, 0)) * CFrame.Angles(
								0,
								math.rad(rootPart.Orientation.Y),
								0
							)
							task.delay(1, function()
								for _, emitter in pairs(clone4:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter.Enabled = false
									end
								end
							end)
							clone4.Parent = effects
							_G.PU:Dust(clone4, 5)
							task.spawn(function()
								local v6 = Scheduler.Repeat(1, 20)
								v6:Instant()
								v6:OnStep(function(_)
									local part = Instance.new("Part")
									part.Anchored = true
									part.CanCollide = false
									part.CollisionGroup = "Effect"
									part.Size = Vector3.new(math.random(1, 10), math.random(1, 10), math.random(1, 10))
									part.Material = raycastResult.Material
									part.Color = raycastResult.Instance.Color
									local vector2 = Vector3.new(math.random(-45, 45), 0, math.random(-45, 45))
									part.CFrame = CFrame.new(position2 + vector2)
									part.Orientation = Vector3.new(
										math.random(0, 360),
										math.random(0, 360),
										math.random(0, 360)
									)
									part.Parent = effects
									local v7 = math.random(6, 45)
									TweenService:Create(
										part,
										TweenInfo.new(1.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Position = part.Position + Vector3.new(0, v7, 0),
											Size = createVector(0, 0, 0),
											CFrame = part.CFrame * CFrame.Angles(
												math.random(0, 360),
												math.random(0, 360),
												math.random(0, 360)
											)
										}
									):Play()
									_G.PU:Dust(part, 2)
								end)
								v6:Execute()
							end)
						end
					end)

					if localPlayer == v then
						_G.PU.PlayOneShotAnim({
							Animator = humanoid,
							Animation = "rbxassetid://103729045301407"
						})
					end

					local _, v6, _ = rootPart.CFrame:ToOrientation()
					local v7 = CFrame.new(rootPart.Position) * CFrame.new(0, -30, 0) * CFrame.fromOrientation(0, v6, 0)
					task.spawn(function()
						task.spawn(function()
							local v8 = Scheduler.Repeat(1, 12)
							v8:Instant()
							v8:OnStep(function(p)
								local v9 = math.random(25, 30)
								local _ = math.random(10, 18) * (math.random() > 0.5 and 1 or -1)
								local v10 = v7 * CFrame.Angles(0, 0.5235987755982988 * p, 0) * CFrame.new(0, 0, -v9)
								local ground = GetGround(v10.Position, 40)

								if ground and ground.Position then
									local v12 = v10 - v10.p
									local part = Instance.new("Part")
									part.Size = Vector3.new(
										math.random(15, 40) / 10,
										math.random(15, 40) / 10,
										math.random(15, 40) / 10
									) * math.random(15, 25) / 13
									part.Color = ground.Object.Color
									part.Material = ground.Object.Material
									part.Anchored = true
									part.CanCollide = false
									part.CFrame = CFrame.new(ground.Position) * CFrame.Angles(
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random()
									)
									part.Parent = effects
									_G.PU:Dust(part, 1.25)
									local cFrame = CFrame.new(ground.Position) * v12 * CFrame.new(
										math.random(25, 40),
										math.random(25, 40),
										math.random(0, 10)
									) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.Angles(
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random()
									)
									TweenService:Create(
										part,
										TweenInfo.new(
											math.random(40, 60) / 100,
											Enum.EasingStyle.Exponential,
											Enum.EasingDirection.Out
										),
										{
											CFrame = cFrame
										}
									):Play()
									task.delay(math.random(5, 20) / 100, function()
										TweenService:Create(
											part,
											TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
											{
												Size = Vector3.new()
											}
										):Play()
									end)
								end
							end)
							v8:Execute()
						end)
						task.wait(0.1)
						task.spawn(function()
							local v8 = Scheduler.Repeat(1, 12)
							v8:Instant()
							v8:OnStep(function(p)
								local v9 = math.random(35, 45)
								local _ = math.random(10, 18) * (math.random() > 0.5 and 1 or -1)
								local v10 = v7 * CFrame.Angles(0, 0.5235987755982988 * p, 0) * CFrame.new(0, 0, -v9)
								local ground = GetGround(v10.Position, 40)

								if ground and ground.Position then
									local v12 = v10 - v10.p
									local part = Instance.new("Part")
									part.Size = Vector3.new(
										math.random(15, 40) / 10,
										math.random(15, 40) / 10,
										math.random(15, 40) / 10
									) * math.random(15, 25) / 10
									part.Color = ground.Object.Color
									part.Material = ground.Object.Material
									part.Anchored = true
									part.CanCollide = false
									part.CFrame = CFrame.new(ground.Position) * CFrame.Angles(
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random()
									)
									part.Parent = effects
									_G.PU:Dust(part, 1.25)
									local cFrame = CFrame.new(ground.Position) * v12 * CFrame.new(
										math.random(25, 40) * 1.15,
										math.random(25, 40) * 1.15,
										math.random(0, 10)
									) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.Angles(
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random()
									)
									TweenService:Create(
										part,
										TweenInfo.new(
											math.random(40, 60) / 100,
											Enum.EasingStyle.Exponential,
											Enum.EasingDirection.Out
										),
										{
											CFrame = cFrame
										}
									):Play()
									task.delay(math.random(5, 20) / 100, function()
										TweenService:Create(
											part,
											TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
											{
												Size = Vector3.new()
											}
										):Play()
									end)
								end
							end)
							v8:Execute()
						end)
						task.wait(0.1)
						task.spawn(function()
							local v8 = Scheduler.Repeat(1, 12)
							v8:Instant()
							v8:OnStep(function(p)
								local v9 = math.random(45, 55)
								local _ = math.random(10, 18) * (math.random() > 0.5 and 1 or -1)
								local v10 = v7 * CFrame.Angles(0, 0.5235987755982988 * p, 0) * CFrame.new(0, 0, -v9)
								local ground = GetGround(v10.Position, 40)

								if ground and ground.Position then
									local v12 = v10 - v10.p
									local part = Instance.new("Part")
									part.Size = Vector3.new(
										math.random(15, 40) / 10,
										math.random(15, 40) / 10,
										math.random(15, 40) / 10
									) * math.random(15, 25) / 8
									part.Color = ground.Object.Color
									part.Material = ground.Object.Material
									part.Anchored = true
									part.CanCollide = false
									part.CFrame = CFrame.new(ground.Position) * CFrame.Angles(
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random()
									)
									part.Parent = effects
									_G.PU:Dust(part, 1.25)
									local cFrame = CFrame.new(ground.Position) * v12 * CFrame.new(
										math.random(25, 40) * 1.15,
										math.random(25, 40) * 1.15,
										math.random(0, 10)
									) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.Angles(
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random()
									)
									TweenService:Create(
										part,
										TweenInfo.new(
											math.random(40, 60) / 100,
											Enum.EasingStyle.Exponential,
											Enum.EasingDirection.Out
										),
										{
											CFrame = cFrame
										}
									):Play()
									task.delay(math.random(5, 20) / 100, function()
										TweenService:Create(
											part,
											TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
											{
												Size = Vector3.new()
											}
										):Play()
									end)
								end
							end)
							v8:Execute()
						end)
					end)
					local clone4 = fruitEffect.Tree.Transfrom.floor:Clone()
					clone4.CFrame = v7 * CFrame.new(0, -2, 0)
					clone4.floor23.CFrame = clone4.CFrame
					clone4.Parent = effects
					_G.PU:Dust(clone4, 2)
					local attachmentGround = clone4:FindFirstChild("AttachmentGround")

					if v5 and attachmentGround then
						attachmentGround.WorldCFrame = CFrame.new(v5)
					end

					PolyLib:ParticleHandler(clone4)
				end

				task.spawn(function()
					transfromfx(toCF)
				end)
				local v4 = Scheduler.Repeat(1, 4)
				v4:Instant()
				v4:Wait(0.1)
				v4:OnStep(function()
					_G.CameraShake:ShakeOnce(4, 10, 0, 0.3)
				end)
				v4:Execute()
			else
				if state ~= "Untransform" then
					return
				end

				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://85251003819704",
					Volume = 0.5
				})
				_G.PU:Dust(sound, 5)
				sound.Parent = rootPart
				sound:Play()
				local clone = fruitEffect.Tree.Transfrom.Defrom.Attachment:Clone()
				clone.Parent = rootPart
				_G.PU:Dust(clone, 2)
				PolyLib:ParticleHandler(clone)
			end
		elseif mode == "Tree E" then
			local chargeFolder = v3.ChargeFolder
			local character = v3.Character
			local skillFolder = v3.SkillFolder
			local rootPart = v3.RootPart
			local wings = v3.Wings
			local humanoid = v3.Humanoid
			local fruitEffect = ReplicatedStorage.Chest.FruitEffect
			local tree_KL = character:FindFirstChild("Tree_KL")

			if tree_KL then
				local function GetGround(p, value)
					local v4 = value or 1000
					local raycastParams = RaycastParams.new()
					raycastParams.IgnoreWater = true
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					local raycastResult = workspace:Raycast(
						p + createVector(0, 5, 0),
						createVector(0, -1, 0) * (v4 + 2),
						raycastParams
					)

					if raycastResult then
						return {
							Position = raycastResult.Position,
							Object = raycastResult.Instance,
							Normal = raycastResult.Normal,
							IsWall = false
						}
					end

					for _, v5 in ipairs({
						createVector(1, 0, 0),
						createVector(-1, 0, 0),
						createVector(0, 0, 1),
						createVector(0, 0, -1)
					}) do
						local raycastResult2 = workspace:Raycast(p, v5 * v4, raycastParams)

						if raycastResult2 then
							return {
								Position = raycastResult2.Position,
								Object = raycastResult2.Instance,
								Normal = raycastResult2.Normal,
								IsWall = true
							}
						end
					end

					return nil
				end

				local function shootMeteor(child)
					local fromCF = child:GetAttribute("FromCF")
					local toCF = child:GetAttribute("ToCF")
					local lifetime = child:GetAttribute("Lifetime")
					local clone = fruitEffect.Tree.EMode.portal:Clone()
					clone.CFrame = CFrame.new(fromCF.p, toCF.p)
					clone.Parent = effects
					_G.PU:Dust(clone, 2)
					PolyLib:ParticleHandler(clone)
					local cframe = CFrame.new(fromCF.p, toCF.p)
					local clone2 = fruitEffect.Tree.EMode.WoodMeteor:Clone()
					clone2.Parent = effects
					clone2:SetPrimaryPartCFrame(cframe)
					_G.PU:Dust(clone2, 1)
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://92264016690708",
						Volume = 0.5
					})
					_G.PU:Dust(sound, 1)
					sound.Parent = clone2.PrimaryPart
					sound:Play()
					PolyLib:ParticleHandler(clone2)
					PolyLib:Active(clone2, true)

					-- equivalent calls inferred from this helper; original call sites unknown
					local function SineOut(p)
						return (math.sin(p * 1.5707963267948966))
					end

					local position = cframe.Position
					local position2 = toCF.Position
					local lerped = position:Lerp(position2, 0.5)
					local v4 = math.random(60, 100) * 1.25
					local position3 = (CFrame.new(lerped, position2) * CFrame.Angles(
						0,
						0,
						6.283185307179586 * math.random()
					) * CFrame.new(0, v4, 0)).Position
					local v5 = position
					task.wait()
					task.spawn(function()
						task.wait(lifetime * 0.8)

						if (localPlayer.Character.HumanoidRootPart.Position - position2).Magnitude < 300 then
							_G.CameraShake:ShakeOnce(1.5, 12, 0, 0.3, createVector(0, 0, -1))
						end

						local clone3 = fruitEffect.Tree.EMode.exp:Clone()
						clone3.CFrame = CFrame.new(position2)
						clone3.Parent = effects
						_G.PU:Dust(clone3, 2)
						PolyLib:ParticleHandler(clone3)
						local sound2 = PeoUtils.CreateSound({
							RollOffMaxDistance = 1000,
							RollOffMinDistance = 50,
							RollOffMode = Enum.RollOffMode.InverseTapered,
							SoundId = "rbxassetid://92264016690708",
							Volume = 0.5
						})
						_G.PU:Dust(sound2, 2)
						sound2.Parent = clone3
						sound2:Play()
					end)
					task.spawn(function()
						PeodizService.HeartbeatWait({
							Time = lifetime
						}, function(p)
							local sineOut = SineOut(p) -- equivalent call inferred; original call site unknown
							local v7 = (1 - sineOut) ^ 2 * position + 2 * (1 - sineOut) * sineOut * position3 + sineOut ^ 2 * position2
							local unit = (v7 - v5).Unit

							if unit.Magnitude > 0 then
								clone2:SetPrimaryPartCFrame(CFrame.new(v7, v7 + unit))
							else
								clone2:SetPrimaryPartCFrame(CFrame.new(v7))
							end

							v5 = v7

							if p >= 1 then
								clone2:SetPrimaryPartCFrame(CFrame.new(
									position2,
									position2 + (position2 - position).Unit
								))
							end

							if p > 0.8 then
								PolyLib:Active(clone2, false)
							end
						end)

						for _, part in pairs(clone2:GetChildren()) do
							if part:IsA("BasePart") then
								TweenService:Create(
									part,
									TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
									{
										Size = Vector3.new()
									}
								):Play()
							end
						end
					end)
				end

				local childAddedConnection = skillFolder.ChildAdded:Connect(function(child)
					shootMeteor(child)
				end)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://110801097855199",
					Volume = 0.5
				})
				_G.PU:Dust(sound, 4)
				sound.Parent = rootPart
				sound:Play()
				task.wait(0.25)
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://102175020545330",
					Volume = 0.5
				})
				_G.PU:Dust(sound2, 4)
				sound2.Parent = rootPart
				sound2:Play()
				local clone = fruitEffect.Tree.EMode.ground:Clone()
				clone:PivotTo(rootPart.CFrame)
				clone.Parent = effects
				_G.PU:Dust(clone, 5)
				Utility.ParticleHandler(clone, true)
				local v4 = Scheduler.new(3)
				v4:Wait()
				v4:OnStep(function()
					if not chargeFolder:IsDescendantOf(character) then
						v4:Destroy()
					elseif clone and clone.Parent then
						clone:PivotTo(rootPart.CFrame)
					end
				end)
				v4:Execute()

				if clone and clone.Parent then
					Utility.ParticleHandler(clone, false)
					_G.PU:Dust(clone, 1)
				end

				task.wait(3)

				if childAddedConnection and childAddedConnection.Connected then
					childAddedConnection:Disconnect()
				end
			elseif not tree_KL then
				local clone = nil
				local v4 = nil
				local v5, keyframeReachedConnection

				if localPlayer == v then
					v5 = _G.PU.PlayOneShotAnim({
						Animator = humanoid,
						Animation = "rbxassetid://105229982219473"
					})
					keyframeReachedConnection = v5.KeyframeReached:Connect(function(p)
						if p == "PlaySound" then
							local sound = PeoUtils.CreateSound({
								RollOffMaxDistance = 1000,
								RollOffMinDistance = 50,
								RollOffMode = Enum.RollOffMode.Inverse,
								SoundId = "rbxassetid://82814830488155",
								Volume = 0.5
							})
							_G.PU:Dust(sound, 2)
							sound.Parent = rootPart
							sound:Play()
						end
					end)
				end

				local function CreateWingsWind()
					if not v4 then
						v4 = PeoUtils.CreateSound({
							RollOffMaxDistance = 1000,
							RollOffMinDistance = 10,
							RollOffMode = Enum.RollOffMode.InverseTapered,
							SoundId = "rbxassetid://129861166866368",
							Volume = 0.7,
							Looped = true
						})
						_G.PU:Dust(v4, 65)
						v4.Parent = rootPart
						v4:Play()
					end

					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://128042325038244",
						Volume = 1
					})
					_G.PU:Dust(sound, 2)
					sound.Parent = rootPart
					sound:Play()
					clone = fruitEffect.Tree.EBase.Mount:Clone()
					clone:PivotTo(rootPart.CFrame)
					clone.Parent = effects
					_G.PU:Dust(clone, 65)
					local weld = Instance.new("Weld")
					weld.Part0 = clone.PrimaryPart
					weld.Part1 = rootPart
					weld.Parent = clone
					PolyLib:ParticleHandler(clone.body.Impact)
					PolyLib:ParticleHandler(clone.body.Impact2)
					PolyLib:Active(clone.Rotate, true)
					PolyLib:Active(clone.Rotate2, true)
					PolyLib:Active(clone.body.body, true)
					PolyLib:Active(clone.body.Attachment, true)
				end

				CreateWingsWind()

				if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 1000 then
					local highlight = Instance.new("Highlight")
					highlight.DepthMode = Enum.HighlightDepthMode.Occluded
					highlight.FillColor = Color3.fromRGB(190, 255, 121)
					highlight.OutlineTransparency = 1
					highlight.FillTransparency = 0
					highlight.Parent = wings
					_G.PU:Dust(highlight, 2)
					task.spawn(function()
						TweenService:Create(
							highlight,
							TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
							{
								FillTransparency = 1
							}
						):Play()
					end)
				end

				local lastTime = tick()
				local v6 = Scheduler.new(60)
				v6:OnStep(function()
					if not chargeFolder:IsDescendantOf(character) then
						v6:Destroy()
					elseif tick() - lastTime > 1 then
						lastTime = tick()

						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 1000 then
							if not clone then
								CreateWingsWind()
							end
						else
							if clone and clone.Parent then
								clone:Destroy()
								clone = nil
							end

							if v4 and v4.Parent then
								v4:Destroy()
								v4 = nil
							end
						end
					end
				end)
				v6:Execute()

				if keyframeReachedConnection and keyframeReachedConnection.Connected then
					keyframeReachedConnection:Disconnect()
				end

				if v5 then
					v5:Stop()
				end

				if v4 and v4.Parent then
					_G.PU:Dust(v4, 1)
					TweenService:Create(v4, TweenInfo.new(0.5), {
						Volume = 0
					}):Play()
				end

				if clone and clone.Parent then
					PolyLib:Active(clone.Rotate, false)
					PolyLib:Active(clone.Rotate2, false)
					PolyLib:Active(clone.body.body, false)
					PolyLib:Active(clone.body.Attachment, false)
					_G.PU:Dust(clone, 2)
				end

				if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 1000 then
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://86739924672899",
						Volume = 1
					})
					_G.PU:Dust(sound, 2)
					sound.Parent = rootPart
					sound:Play()
					local highlight = Instance.new("Highlight")
					highlight.DepthMode = Enum.HighlightDepthMode.Occluded
					highlight.FillColor = Color3.fromRGB(190, 255, 121)
					highlight.OutlineTransparency = 1
					highlight.FillTransparency = 0
					highlight.Parent = character
					_G.PU:Dust(highlight, 2)
					task.spawn(function()
						TweenService:Create(
							highlight,
							TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
							{
								FillTransparency = 1
							}
						):Play()
					end)
				end
			end
		elseif mode == "Demon Z" then
			local character = v3.Character
			local skillFolder = v3.SkillFolder
			local _ = v3.StartCF
			local chargeFolder = v3.ChargeFolder
			local rootPart = v3.RootPart
			local demon_KL = character:FindFirstChild("Demon_KL")

			if demon_KL then
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 60,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://86152779798704",
					Volume = 1
				})
				_G.PU:Dust(sound, 7)
				sound.Parent = rootPart
				sound:Play()
				local skillZ = ReplicatedStorage.Chest.FruitEffect.Demon.Ifrist.SkillZ
				local clone = skillZ.Step1:Clone()
				clone:PivotTo(rootPart.CFrame * CFrame.new(0, 3, -10))
				clone.Parent = effects
				_G.PU:Dust(clone, 15)
				local v4 = Scheduler.Repeat(1, 4, 0.48)
				v4:Wait()
				v4:Instant()
				v4:Ignore()
				v4:OnStep(function(p)
					clone:ScaleTo(p)
				end)
				v4:Execute()

				local function ShootHellBall(child)
					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 60,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://139553810368744",
						Volume = 0.7
					})
					_G.PU:Dust(sound2, 3)
					sound2.Parent = rootPart
					sound2:Play()
					task.delay(0.1, function()
						local speed = child:GetAttribute("Speed")
						local cFMouse = child:GetAttribute("CFMouse")

						if (localPlayer.Character.HumanoidRootPart.Position - cFMouse.Position).Magnitude < 150 then
							Motion:Shake("Rise")
						end

						local clone2 = skillZ.Step2:Clone()
						SetupPart(clone2)
						clone2.CFrame = clone:GetPivot()
						clone2.Parent = effects
						Emit(clone2)
						TweenService:Create(
							clone.Step1Main,
							TweenInfo.new(speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								CFrame = cFMouse
							}
						):Play()
						task.spawn(function()
							task.wait(speed)
							Utility.ParticleHandler(clone, false)

							if (localPlayer.Character.HumanoidRootPart.Position - cFMouse.Position).Magnitude < 300 then
								_G.CameraShake:ShakeOnce(8, 14, 0, 0.33, createVector(0, 0, -1))
							end

							local clone3 = skillZ.Step3:Clone()
							SetupPart(clone3)
							clone3.CFrame = cFMouse * CFrame.new(0, 10, 0)
							clone3.Parent = effects
							Emit(clone3)
							_G.PU:Dust(clone3, 5)
							local sound3 = PeoUtils.CreateSound({
								RollOffMaxDistance = 1000,
								RollOffMinDistance = 60,
								RollOffMode = Enum.RollOffMode.InverseTapered,
								SoundId = "rbxassetid://116640050491579",
								Volume = 1
							})
							_G.PU:Dust(sound3, 5)
							sound3.Parent = rootPart
							sound3:Play()
							local clone4 = skillZ.PartTrail:Clone()
							SetupPart(clone4)
							clone4.CFrame = clone3.CFrame
							clone4.Parent = effects
							TweenService:Create(
								clone4,
								TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									CFrame = clone4.CFrame * CFrame.new(0, 50, 0) * CFrame.Angles(
										0,
										3.0543261909900767,
										0
									)
								}
							):Play()
							_G.PU:Dust(clone4, 2)
							local clone5 = skillZ.PartTrail2:Clone()
							SetupPart(clone5)
							clone5.CFrame = clone3.CFrame
							clone5.Parent = effects
							TweenService:Create(
								clone5,
								TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									CFrame = clone5.CFrame * CFrame.new(0, -50, 0) * CFrame.Angles(
										0,
										3.0543261909900767,
										0
									)
								}
							):Play()
							_G.PU:Dust(clone5, 2)
							local position = (clone3.CFrame * CFrame.new(0, 0, -0.5)).Position
							local raycastParams = RaycastParams.new()
							raycastParams.FilterType = Enum.RaycastFilterType.Include
							raycastParams.FilterDescendantsInstances = { workspace.Island }
							local raycastResult = workspace:Raycast(position, createVector(0, -60, 0), raycastParams)

							if raycastResult then
								local position2 = raycastResult.Position
								local clone6 = skillZ.Ground_Ray:Clone()
								clone6.Anchored = true
								clone6.CanCollide = false
								clone6.Transparency = 1
								clone6.CFrame = CFrame.new(position2 + Vector3.new(0, clone6.Size.Y / 2, 0)) * CFrame.Angles(
									0,
									math.rad(clone3.Orientation.Y),
									0
								)
								clone6.Parent = effects
								Emit(clone6)
								_G.PU:Dust(clone6, 4)
								task.spawn(function()
									for _, emitter in ipairs(clone6:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter.Enabled = true
										end
									end

									task.wait(1.7)

									for _, emitter in ipairs(clone6:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter.Enabled = false
										end
									end
								end)
							end

							local v5 = Scheduler.Repeat(1, 6)
							v5:Ignore()
							v5:Instant()
							v5:OnStep(function(_)
								local clone6 = skillZ.PartDrop:Clone()
								clone6.Anchored = false
								clone6.CanCollide = false
								clone6.CollisionGroup = "Effect"
								clone6.Transparency = 1
								clone6.CFrame = clone3.CFrame
								clone6.Parent = effects
								local bodyVelocity = Instance.new("BodyVelocity")
								bodyVelocity.Velocity = Vector3.new(
									math.random(-40, 40),
									math.random(40, 130),
									math.random(-40, 40)
								)
								bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
								bodyVelocity.Parent = clone6
								_G.PU:Dust(clone2, 2)
								_G.PU:Dust(clone6, 5)
								_G.PU:Dust(bodyVelocity, 0.3)
							end)
							v5:Execute()
							task.spawn(function()
								local v6 = Scheduler.Repeat(1, 10)
								v6:Ignore()
								v6:Instant()
								v6:OnStep(function(_)
									local clone6 = skillZ.TrailCurve:Clone()
									SetupPart(clone6)
									clone6.CFrame = clone3.CFrame
									clone6.Parent = effects
									local position2 = clone3.Position
									local v7 = position2 + Vector3.new(
										math.random(-50, 50),
										math.random(-50, 50),
										math.random(-50, 50)
									)

									local function getRandomMiddle(position3, p)
										local v8 = math.random(40, 60) / 100
										local v9 = math.random(-100, 100)
										local v10 = math.random(-100, 100)
										local v11 = math.random(-50, 50)
										return position3:Lerp(p, v8) + Vector3.new(v9, v10, v11)
									end

									local randomMiddle = getRandomMiddle(position2, v7)
									local v8 = Bezier.new(position2, randomMiddle, v7)
									task.spawn(function()
										local v9 = Scheduler.Repeat(1, 60)
										v9:Wait()
										v9:Instant()
										v9:OnStep(function(p)
											local v10 = v8:Get(p / 60)
											v8:Get((math.min((p + 1) / 60, 1)))
											clone6.CFrame = CFrame.new(v10)
										end)
										v9:Execute()
									end)
									task.spawn(function()
										task.wait(1)

										for _, emitter in pairs(clone6:GetDescendants()) do
											if emitter:IsA("ParticleEmitter") then
												emitter.Enabled = false
											end
										end
									end)
									_G.PU:Dust(clone6, 3)
								end)
								v6:Execute()
							end)
						end)
						_G.PU:Dust(clone2, 2)
					end)
				end

				local childAddedConnection = nil
				childAddedConnection = skillFolder.ChildAdded:Connect(function(child)
					ShootHellBall(child)
					childAddedConnection:Disconnect()
				end)
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://130972723958156",
					Volume = 1,
					Looped = true
				})
				_G.PU:Dust(sound2, 15)
				sound2.Parent = rootPart
				sound2:Play()
				local v5 = Scheduler.new(10)
				v5:Wait()
				v5:OnStep(function()
					if not chargeFolder:IsDescendantOf(character) then
						v5:Destroy()
					elseif clone and clone.Parent then
						clone:PivotTo(rootPart.CFrame * CFrame.new(0, 0, -15))
					end
				end)
				v5:Execute()

				if sound2 and sound2.Parent then
					TweenService:Create(sound2, TweenInfo.new(0.5), {
						Volume = 0
					}):Play()
					_G.PU:Dust(sound2, 1)
				end

				_G.PU:Dust(clone, 2)
			elseif not demon_KL then
				local skillZ = ReplicatedStorage.Chest.FruitEffect.Demon.Human.SkillZ
				local childAddedConnection = nil

				local function ShootHellBall(child)
					local startCF = child:GetAttribute("StartCF")
					local cFMouse = child:GetAttribute("CFMouse")
					child:GetAttribute("Distance")
					local speed = child:GetAttribute("Speed")

					if child:GetAttribute("i") == 6 then
						childAddedConnection:Disconnect()
					end

					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://113010755367943",
						Volume = 0.2
					})
					_G.PU:Dust(sound, 4)
					sound.Parent = rootPart
					sound:Play()
					local clone = skillZ.Start:Clone()
					SetupPart(clone)
					clone.CFrame = startCF * CFrame.new(0, 0, -6)
					clone.Parent = effects
					Emit(clone)
					local clone2 = skillZ.Step1:Clone()
					SetupPart(clone2)
					clone2.CFrame = startCF * CFrame.new(0, 0, -6)
					clone2.Parent = effects
					task.spawn(function()
						local cFrame = clone2.CFrame
						local v4 = cFrame * CFrame.new(math.random(-30, 30), math.random(-3, 30), 0)
						local position = cFMouse.Position
						local v5 = Bezier.new(cFrame.Position, v4.Position, position)
						local step = math.floor(speed / 0.01)
						task.spawn(function()
							PeodizService.ForLoop({
								Step = step,
								WaitTime = 0.01
							}, function(p)
								local v7 = math.floor(p * step)
								local v8 = v5:Get(v7 / step)
								local v9 = v5:Get((v7 + 1) / step)
								clone2.CFrame = CFrame.new(v8, v9)
							end)
						end)
						task.wait(speed)

						for _, emitter in pairs(clone2:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							emitter:Clear()
							emitter.Enabled = false
						end

						if (localPlayer.Character.HumanoidRootPart.Position - position).Magnitude < 200 then
							_G.CameraShake:ShakeOnce(2, 7, 0, 0.3)
						end

						local clone3 = skillZ.Step2:Clone()
						SetupPart(clone3)
						clone3.CFrame = CFrame.new(position) * CFrame.new(0, 3, 0)
						clone3.Parent = effects
						Emit(clone3)
						local sound2 = PeoUtils.CreateSound({
							RollOffMaxDistance = 1000,
							RollOffMinDistance = 50,
							RollOffMode = Enum.RollOffMode.InverseTapered,
							SoundId = "rbxassetid://80202920339972",
							Volume = 0.35
						})
						_G.PU:Dust(sound2, 4)
						sound2.Parent = clone3
						sound2:Play()
						local v7 = position + createVector(0, 10, 0)
						local raycastParams = RaycastParams.new()
						raycastParams.FilterType = Enum.RaycastFilterType.Include
						raycastParams.FilterDescendantsInstances = { workspace.Island }
						local raycastResult = workspace:Raycast(v7, createVector(0, -40, 0), raycastParams)

						if raycastResult then
							local position2 = raycastResult.Position
							local clone4 = skillZ.Ground_Ray:Clone()
							clone4.Anchored = true
							clone4.CanCollide = false
							clone4.Transparency = 1
							clone4.CFrame = CFrame.new(position2 + Vector3.new(0, clone4.Size.Y / 2, 0)) * CFrame.Angles(
								0,
								math.rad(clone3.Orientation.Y),
								0
							)
							clone4.Parent = effects
							Emit(clone4)
							_G.PU:Dust(clone4, 2)
						end

						task.spawn(function()
							local v8 = Scheduler.Repeat(1, 2)
							v8:Instant()
							v8:OnStep(function(_)
								local clone4 = skillZ.TrailCurve:Clone()
								SetupPart(clone4)
								clone4.CFrame = clone3.CFrame
								clone4.Parent = effects
								local position2 = clone3.Position
								local v9 = position2 + Vector3.new(
									math.random(-10, 10),
									math.random(-10, 10),
									math.random(-10, 10)
								)

								local function getRandomMiddle(position3, p)
									local v10 = math.random(40, 60) / 100
									local v11 = math.random(-50, 50)
									local v12 = math.random(-50, 50)
									local v13 = math.random(-50, 50)
									return position3:Lerp(p, v10) + Vector3.new(v11, v12, v13)
								end

								local randomMiddle = getRandomMiddle(position2, v9)
								local v10 = Bezier.new(position2, randomMiddle, v9)
								task.spawn(function()
									for i = 1, 50 do
										task.wait(0.01)
										local v11 = v10:Get(i / 50)
										v10:Get((math.min((i + 1) / 50, 1)))
										clone4.CFrame = CFrame.new(v11)
									end
								end)
								task.spawn(function()
									task.wait(0.8)

									for _, emitter in pairs(clone4:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter.Enabled = false
										end
									end
								end)
								_G.PU:Dust(clone, 2)
								_G.PU:Dust(clone4, 3)
								_G.PU:Dust(clone2, 2)
								_G.PU:Dust(clone3, 2)
							end)
							v8:Execute()
						end)
					end)
				end

				childAddedConnection = skillFolder.ChildAdded:Connect(function(child)
					ShootHellBall(child)
				end)
			end
		elseif mode == "Demon X" then
			local character = v3.Character
			local startCF = v3.StartCF
			local cFMouse = v3.CFMouse
			local speed = v3.Speed
			local rootPart = v3.RootPart
			local humanoid = v3.Humanoid
			local animSpeed = v3.AnimSpeed
			local demon_KL = character:FindFirstChild("Demon_KL")

			if demon_KL then
				local function create_ground_pter()
					local ray = Ray.new(rootPart.Position, createVector(0, -70, 0))
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)

					if not (raycastResult and raycastResult.Position) then
						local _ = ray.Origin + ray.Direction
					end

					local _, v4, _ = rootPart.CFrame:ToOrientation()
					local cframe = CFrame.fromOrientation(0, v4, 0)

					if raycastResult and raycastResult.Instance then
						local clone = ReplicatedStorage.Chest.FruitEffect.Demon.ground:Clone()
						clone:PivotTo(CFrame.new(raycastResult.Position) * cframe)
						clone:ScaleTo(1.2)
						clone.PrimaryPart.Inner.CFrame = clone.PrimaryPart.CFrame
						clone.Parent = effects
						_G.PU:Dust(clone, 2)
						PolyLib:ParticleHandler(clone)
					end
				end

				local v4 = Scheduler.new(speed * 0.85)
				v4:Ignore()
				v4:Wait()
				v4:OnStep(function()
					create_ground_pter()
				end)
				v4:Execute()
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 60,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://96433573606269",
					Volume = 0.5
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = rootPart
				sound:Play()

				if localPlayer == v then
					rootPart.CFrame = startCF
					PeoUtils.LerpCF(
						rootPart,
						TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						cFMouse
					)
					_G.PU.PlayOneShotAnim({
						Animator = humanoid,
						Animation = "rbxassetid://135609532237971",
						Speed = animSpeed
					})
				end

				if (localPlayer.Character.HumanoidRootPart.Position - startCF.Position).Magnitude < 150 then
					Motion:Shake("Rise")
				end

				local skillX = ReplicatedStorage.Chest.FruitEffect.Demon.Ifrist.SkillX
				local clone = skillX.Step1:Clone()
				SetupPart(clone)
				clone.CFrame = startCF * CFrame.new(0, 2, 1)
				clone.Parent = effects
				Emit(clone)
				_G.PU:Dust(clone, 2)
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Demon.Human.SkillX.Step3:Clone()
				clone2.CFrame = startCF
				clone2.Parent = effects
				_G.PU:Dust(clone2, 2)
				Utility.ParticleHandler(clone2, true)
				TweenService:Create(clone2, TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					CFrame = cFMouse
				}):Play()
				task.delay(speed, function()
					Utility.ParticleHandler(clone2, false)
					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 60,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://138314120513247",
						Volume = 0.5
					})
					_G.PU:Dust(sound2, 3)
					sound2.Parent = rootPart
					sound2:Play()
					local clone3 = skillX.Step2:Clone()
					SetupPart(clone3)
					clone3.CFrame = cFMouse * CFrame.Angles(0, 0, 0.9599310885968813)
					clone3.Parent = effects
					task.spawn(function()
						PeodizService.new({
							Time = 0.2
						}, function(_, p)
							clone3.CFrame *= CFrame.Angles(-0.41887902047863906 * p * 40, 0, 0)
						end)
					end)
					task.delay(0.2, function()
						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 200 then
							_G.CameraShake:ShakeOnce(8, 14, 0, 0.33, createVector(0, 0, -1))
						end

						for _, beam in pairs(clone3:GetDescendants()) do
							if beam:IsA("Beam") then
								TweenService:Create(
									beam,
									TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
									{
										Width0 = 0,
										Width1 = 0
									}
								):Play()
							end
						end

						local sound3 = PeoUtils.CreateSound({
							RollOffMaxDistance = 1000,
							RollOffMinDistance = 60,
							RollOffMode = Enum.RollOffMode.InverseTapered,
							SoundId = "rbxassetid://125737702938029",
							Volume = 0.5
						})
						_G.PU:Dust(sound3, 7)
						sound3.Parent = rootPart
						sound3:Play()
						local cFrame = cFMouse * CFrame.new(0, 3, -15)
						local clone4 = skillX.Step3:Clone()
						SetupPart(clone4)
						clone4.CFrame = CFrame.new(cFrame.Position)
						clone4.Parent = effects
						Emit(clone4)
						_G.PU:Dust(clone4, 2)
						local part = Instance.new("Part")
						part.Transparency = 1
						part.Anchored = true
						part.CanCollide = false
						part.CastShadow = false
						part.Size = Vector3.new()
						part.CFrame = cFrame
						part.Parent = effects
						_G.PU:Dust(part, 2)

						if localPlayer == v then
							local clone5 = skillX.CameraFX:Clone()
							SetupPart(clone5)
							clone5.Parent = effects
							Utility.EmitParticles(clone5)
							_G.PU:Dust(clone5, 5)
							task.spawn(function()
								FastRenderer.new({
									Time = 5
								}, function()
									if clone5 and clone5.Parent then
										clone5.CFrame = currentCamera.CFrame
									else
										return true
									end
								end)
							end)
						end

						task.spawn(function()
							local v6 = Scheduler.Repeat(1, 4)
							v6:Instant()
							v6:OnStep(function()
								local clone5 = skillX.PartDrop:Clone()
								clone5.Anchored = false
								clone5.CanCollide = false
								clone5.CollisionGroup = "Effect"
								clone5.Transparency = 1
								clone5.CFrame = clone4.CFrame
								clone5.Parent = effects
								local bodyVelocity = Instance.new("BodyVelocity")
								bodyVelocity.Velocity = Vector3.new(
									math.random(-40, 40),
									math.random(40, 130),
									math.random(-40, 40)
								)
								bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
								bodyVelocity.Parent = clone5
								_G.PU:Dust(clone5, 5)
								_G.PU:Dust(bodyVelocity, 0.3)
							end)
							v6:Execute()
						end)
						local v6 = part.Position + createVector(0, 5, 0)
						local raycastParams = RaycastParams.new()
						raycastParams.FilterType = Enum.RaycastFilterType.Include
						raycastParams.FilterDescendantsInstances = { workspace.Island }
						local raycastResult = workspace:Raycast(v6, createVector(0, -60, 0), raycastParams)

						if raycastResult then
							local position = raycastResult.Position
							local clone5 = skillX.Ground_Ray:Clone()
							clone5.Anchored = true
							clone5.CanCollide = false
							clone5.Transparency = 1
							local clone6 = skillX.Rock:Clone()
							SetupPart(clone6)
							clone6.CFrame = CFrame.new(position + Vector3.new(0, clone6.Size.Y / 2, 0)) * CFrame.Angles(
								0,
								math.rad(part.Orientation.Y),
								0
							)
							clone6.Parent = effects
							_G.PU:Dust(clone6, 5)
							task.spawn(function()
								for _, weld in pairs(clone6:GetChildren()) do
									if not weld:IsA("Weld") then
										continue
									end

									local v7 = math.random(25, 50)
									local v8 = math.random(10, 50) / 100
									weld.C0 *= CFrame.new(0, -v7, 0)
									TweenService:Create(weld, TweenInfo.new(v8, Enum.EasingStyle.Exponential), {
										C0 = weld.C0 * CFrame.new(0, v7, 0)
									}):Play()
								end

								task.wait(1.5)
								TweenService:Create(clone6, TweenInfo.new(0.5), {
									CFrame = clone6.CFrame * CFrame.new(0, -20, 0)
								}):Play()

								for _, descendant in pairs(clone6:GetDescendants()) do
									if descendant:IsA("SpecialMesh") or descendant:IsA("MeshPart") then
										TweenService:Create(
											descendant,
											TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
											{
												Size = createVector(1, 1, 1)
											}
										):Play()
									end
								end

								for _, decal in pairs(clone6:GetDescendants()) do
									if decal:IsA("Decal") then
										TweenService:Create(decal, TweenInfo.new(0.3), {
											Transparency = 1
										}):Play()
									end
								end

								for _, emitter in pairs(clone6:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter.Enabled = false
									end
								end
							end)
							clone5.CFrame = CFrame.new(position + Vector3.new(0, clone5.Size.Y / 2, 0)) * CFrame.Angles(
								0,
								math.rad(part.Orientation.Y),
								0
							)
							clone5.Parent = effects
							Emit(clone5)
							_G.PU:Dust(clone5, 4)
							task.spawn(function()
								for _, emitter in ipairs(clone5:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter.Enabled = true
									end
								end

								task.wait(1.7)

								for _, emitter in ipairs(clone5:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter.Enabled = false
									end
								end
							end)
						end
					end)
					_G.PU:Dust(clone3, 2)
				end)
			elseif not demon_KL then
				local function create_ground_pter()
					local ray = Ray.new(rootPart.Position, createVector(0, -50, 0))
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)

					if not (raycastResult and raycastResult.Position) then
						local _ = ray.Origin + ray.Direction
					end

					local _, v4, _ = rootPart.CFrame:ToOrientation()
					local cframe = CFrame.fromOrientation(0, v4, 0)

					if raycastResult and raycastResult.Instance then
						local clone = ReplicatedStorage.Chest.FruitEffect.Demon.ground:Clone()
						clone:ScaleTo(0.8)
						clone:PivotTo(CFrame.new(raycastResult.Position) * cframe)
						clone.PrimaryPart.Inner.CFrame = clone.PrimaryPart.CFrame
						clone.Parent = effects
						_G.PU:Dust(clone, 2)
						PolyLib:ParticleHandler(clone)
					end
				end

				local v4 = Scheduler.new(speed * 0.85)
				v4:Ignore()
				v4:Wait()
				v4:OnStep(function()
					create_ground_pter()
				end)
				v4:Execute()

				if localPlayer == v then
					rootPart.CFrame = startCF
					PeoUtils.LerpCF(
						rootPart,
						TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						cFMouse
					)
					_G.PU.PlayOneShotAnim({
						Animator = humanoid,
						Animation = "rbxassetid://82831290539492",
						Speed = animSpeed
					})
				end

				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://101111910253648",
					Volume = 0.5
				})
				_G.PU:Dust(sound, 4)
				sound.Parent = rootPart
				sound:Play()
				local skillX = ReplicatedStorage.Chest.FruitEffect.Demon.Human.SkillX
				local clone = skillX.Step1:Clone()
				SetupPart(clone)
				clone.CFrame = startCF * CFrame.new(0, 1, 0)
				clone.Parent = effects
				_G.PU:Dust(clone, 2)
				Utility.EmitParticles(clone)
				local clone2 = skillX.Step3:Clone()
				clone2.CFrame = startCF
				clone2.Parent = effects
				_G.PU:Dust(clone2, 2)
				Utility.ParticleHandler(clone2, true)
				TweenService:Create(clone2, TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					CFrame = cFMouse
				}):Play()
				task.delay(speed, function()
					Utility.ParticleHandler(clone2, false)
					task.wait(0.1)

					if (localPlayer.Character.HumanoidRootPart.Position - cFMouse.Position).Magnitude < 200 then
						_G.CameraShake:ShakeOnce(2, 7, 0, 0.5, createVector(4, 1, 1))
					end

					local clone3 = skillX.Step2:Clone()
					SetupPart(clone3)
					clone3.CFrame = cFMouse * CFrame.new(0, 3, -3)
					clone3.Parent = effects
					_G.PU:Dust(clone3, 5)
					Utility.EmitParticles(clone3)
					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://130552823944491",
						Volume = 0.5
					})
					_G.PU:Dust(sound2, 5)
					sound2.Parent = clone3
					sound2:Play()
					local clone4 = skillX.PartTrail:Clone()
					SetupPart(clone4)
					clone4.CFrame = clone3.CFrame * CFrame.new(0, 1, 0)
					clone4.Parent = effects
					TweenService:Create(clone4, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						CFrame = clone4.CFrame * CFrame.new(0, 0, -20) * CFrame.Angles(0, 0, 3.0543261909900767)
					}):Play()
					local clone5 = skillX.PartTrail2:Clone()
					SetupPart(clone5)
					clone5.CFrame = clone3.CFrame * CFrame.new(0, 1, 0)
					clone5.Parent = effects
					TweenService:Create(clone5, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						CFrame = clone5.CFrame * CFrame.new(0, 0, -15) * CFrame.Angles(0, 0, -3.0543261909900767)
					}):Play()
					_G.PU:Dust(clone4, 2)
					_G.PU:Dust(clone5, 2)
					local position = (clone3.CFrame * CFrame.new(0, 0, -0.5)).Position
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					local raycastResult = workspace:Raycast(position, createVector(0, -30, 0), raycastParams)

					if raycastResult then
						local position2 = raycastResult.Position
						local clone6 = skillX.Ground_Ray:Clone()
						clone6.Anchored = true
						clone6.CanCollide = false
						clone6.Transparency = 1
						clone6.CFrame = CFrame.new(position2 + Vector3.new(0, clone6.Size.Y / 2, 0)) * CFrame.Angles(
							0,
							math.rad(clone3.Orientation.Y),
							0
						)
						clone6.Parent = effects
						Emit(clone6)
						_G.PU:Dust(clone6, 4)
						local v5 = Scheduler.Repeat(1, 5)
						v5:Instant()
						v5:Ignore()
						v5:OnStep(function(_)
							local clone7 = skillX.PartDrop:Clone()
							clone7.Anchored = false
							clone7.CanCollide = true
							clone7.CollisionGroup = "Effect"
							clone7.Transparency = 1
							clone7.CFrame = clone6.CFrame * CFrame.new(math.random(-10, 10), 2, -25)
							clone7.Parent = effects
							local bodyVelocity = Instance.new("BodyVelocity")
							bodyVelocity.Velocity = Vector3.new(
								math.random(-60, 60),
								math.random(30, 70),
								math.random(-70, 70)
							)
							bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
							bodyVelocity.Parent = clone7
							task.delay(1, function()
								for _, emitter in pairs(clone7:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter.Enabled = false
									end
								end
							end)
							_G.PU:Dust(clone7, 3)
							_G.PU:Dust(bodyVelocity, 0.1)
						end)
						v5:Execute()
						task.spawn(function()
							local rockFolder = ReplicatedStorage.Chest.FruitEffect.Demon.Human.RockFolder
							local v6 = Scheduler.Repeat(1, 4)
							v6:Wait(0.03)
							v6:Instant()
							v6:OnStep(function(p)
								local v7 = math.random(1, 3)
								local v8 = math.random(1, 3)
								local child = rockFolder:FindFirstChild((`Rock{v7}`))
								local child2 = rockFolder:FindFirstChild((`Black{v7}`))
								local child3 = rockFolder:FindFirstChild((`Rock{v8}`))
								local child4 = rockFolder:FindFirstChild((`Black{v8}`))
								local v9 = math.random(20, 40) / 10
								local v10 = math.random(20, 40) / 10
								local clone7 = child:Clone()
								clone7.Anchored = true
								clone7.CanCollide = false
								clone7.Transparency = 0
								clone7.CFrame = clone6.CFrame * CFrame.new(20, -0.3, -(p * 10)) * CFrame.Angles(
									-0.17453292519943295,
									math.random(-0.7, 0.7),
									-0.7853981633974483
								)
								clone7.Parent = effects
								Emit(clone7)
								TweenService:Create(
									clone7,
									TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
									{
										Size = child.Size * v9
									}
								):Play()
								local clone8 = child2:Clone()
								clone8.Anchored = true
								clone8.CanCollide = false
								clone8.Transparency = 0.05
								clone8.CFrame = clone6.CFrame * CFrame.new(20, -0.3, -(p * 10)) * CFrame.Angles(
									-0.17453292519943295,
									math.random(-0.7, 0.7),
									-0.7853981633974483
								)
								clone8.Parent = effects
								TweenService:Create(
									clone8,
									TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
									{
										Size = child2.Size * v9
									}
								):Play()
								task.delay(0.5, function()
									for _, emitter in pairs(clone7:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter.Enabled = false
										end
									end

									TweenService:Create(
										clone7,
										TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
										{
											Size = createVector(0.1, 0.1, 0.1),
											CFrame = clone7.CFrame * CFrame.new(0, -3, 0)
										}
									):Play()
									TweenService:Create(
										clone8,
										TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
										{
											Size = createVector(0.1, 0.1, 0.1),
											CFrame = clone8.CFrame * CFrame.new(0, -3, 0)
										}
									):Play()
								end)
								_G.PU:Dust(clone8, 1.5)
								_G.PU:Dust(clone7, 1.5)
								local clone9 = child3:Clone()
								clone9.Anchored = true
								clone9.CanCollide = false
								clone9.Transparency = 0
								clone9.CFrame = clone6.CFrame * CFrame.new(-20, -0.3, -(p * 12)) * CFrame.Angles(
									-0.17453292519943295,
									math.random(-0.7, 0.7),
									0.7853981633974483
								)
								clone9.Parent = effects
								Emit(clone9)
								TweenService:Create(
									clone9,
									TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
									{
										Size = child3.Size * v10
									}
								):Play()
								local clone10 = child4:Clone()
								clone10.Anchored = true
								clone10.CanCollide = false
								clone10.Transparency = 0.05
								clone10.CFrame = clone6.CFrame * CFrame.new(-20, -0.3, -(p * 12)) * CFrame.Angles(
									-0.17453292519943295,
									math.random(-0.7, 0.7),
									0.7853981633974483
								)
								clone10.Parent = effects
								TweenService:Create(
									clone10,
									TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
									{
										Size = child4.Size * v10
									}
								):Play()
								task.delay(0.5, function()
									for _, emitter in pairs(clone9:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter.Enabled = false
										end
									end

									TweenService:Create(
										clone9,
										TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
										{
											Size = createVector(0.1, 0.1, 0.1),
											CFrame = clone9.CFrame * CFrame.new(0, -3, 0)
										}
									):Play()
									TweenService:Create(
										clone10,
										TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
										{
											Size = createVector(0.1, 0.1, 0.1),
											CFrame = clone10.CFrame * CFrame.new(0, -3, 0)
										}
									):Play()
								end)
								_G.PU:Dust(clone10, 1.5)
								_G.PU:Dust(clone9, 1.5)
							end)
							v6:Execute()
						end)
					end
				end)
			end
		elseif mode == "Demon C" then
			local character = v3.Character
			local startCF = v3.StartCF
			local chargeFolder = v3.ChargeFolder
			local rootPart = v3.RootPart
			local skillFolder = v3.SkillFolder
			local demon_KL = character:FindFirstChild("Demon_KL")

			if demon_KL then
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 60,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://81785508927443",
					Volume = 0.5
				})
				_G.PU:Dust(sound, 5)
				sound.Parent = rootPart
				sound:Play()
				local skillC = ReplicatedStorage.Chest.FruitEffect.Demon.Ifrist.SkillC
				local clone = skillC.Step1:Clone()
				SetupPart(clone)
				clone.CFrame = CFrame.new(rootPart.Position)
				clone.Parent = effects
				_G.PU:Dust(clone, 2)
				Utility.EmitParticles(clone)

				-- equivalent calls inferred from this helper; original call sites unknown
				local function DemonCCast(child)
					task.spawn(function()
						local sound2 = PeoUtils.CreateSound({
							RollOffMaxDistance = 1000,
							RollOffMinDistance = 60,
							RollOffMode = Enum.RollOffMode.InverseTapered,
							SoundId = "rbxassetid://125737702938029",
							Volume = 0.5
						})
						_G.PU:Dust(sound2, 5)
						sound2.Parent = rootPart
						sound2:Play()
						local startCF2 = child:GetAttribute("StartCF")

						if (localPlayer.Character.HumanoidRootPart.Position - startCF2.Position).Magnitude < 250 then
							Motion:Shake("Rise")
						end

						local clone2 = skillC.Step2:Clone()
						SetupPart(clone2)
						clone2.CFrame = startCF2 * CFrame.new(0, 2.9, -3)
						clone2.Parent = effects
						Emit(clone2)
						_G.PU:Dust(clone2, 2)
						task.spawn(function()
							local v4 = Scheduler.Repeat(1, 6)
							v4:Instant()
							v4:OnStep(function(_)
								local clone3 = skillC.PartDrop:Clone()
								clone3.Anchored = false
								clone3.CanCollide = false
								clone3.CollisionGroup = "Effect"
								clone3.Transparency = 1
								clone3.CFrame = clone2.CFrame
								clone3.Parent = effects
								local bodyVelocity = Instance.new("BodyVelocity")
								bodyVelocity.Velocity = Vector3.new(
									math.random(-40, 40),
									math.random(20, 80),
									math.random(-40, 40)
								)
								bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
								bodyVelocity.Parent = clone3
								_G.PU:Dust(clone3, 5)
								_G.PU:Dust(bodyVelocity, 0.1)
							end)
							v4:Execute()
						end)
						local _ = (clone2.CFrame * CFrame.new(0, 10, 0)).Position
						local raycastParams = RaycastParams.new()
						raycastParams.FilterType = Enum.RaycastFilterType.Include
						raycastParams.FilterDescendantsInstances = { workspace.Island }
						task.delay(0.18, function()
							if (localPlayer.Character.HumanoidRootPart.Position - startCF2.Position).Magnitude < 250 then
								_G.CameraShake:ShakeOnce(8, 14, 0, 0.33, createVector(0, 0, -1))
							end

							local clone3 = skillC.Step3:Clone()
							SetupPart(clone3)
							clone3.CFrame = clone2.CFrame
							clone3.Parent = effects
							Emit(clone3)
							_G.PU:Dust(clone3, 2)

							if localPlayer == v then
								local clone4 = skillC.CameraFX:Clone()
								SetupPart(clone4)
								clone4.Parent = effects
								task.spawn(function()
									FastRenderer.new({
										Time = 5
									}, function()
										if clone4 and clone4.Parent then
											clone4.CFrame = currentCamera.CFrame
										else
											return true
										end
									end)
								end)
								Utility.EmitParticles(clone4)
								_G.PU:Dust(clone4, 5)
							end

							local clone4 = skillC.PartTrail:Clone()
							SetupPart(clone4)
							clone4.CFrame = clone3.CFrame
							clone4.Parent = effects
							TweenService:Create(
								clone4,
								TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									CFrame = clone4.CFrame * CFrame.new(0, 25, 0) * CFrame.Angles(
										0,
										3.0543261909900767,
										0
									)
								}
							):Play()
							_G.PU:Dust(clone4, 2)
							task.spawn(function()
								local v4 = Scheduler.Repeat(1, 6)
								v4:Instant()
								v4:Wait(0.03)
								v4:OnStep(function(_)
									local clone5 = skillC.PartDrop:Clone()
									clone5.Anchored = false
									clone5.CanCollide = false
									clone5.CollisionGroup = "Effect"
									clone5.Transparency = 1
									clone5.CFrame = clone2.CFrame
									clone5.Parent = effects
									local bodyVelocity = Instance.new("BodyVelocity")
									bodyVelocity.Velocity = Vector3.new(
										math.random(-40, 40),
										math.random(40, 150),
										math.random(-40, 40)
									)
									bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
									bodyVelocity.Parent = clone5
									_G.PU:Dust(clone5, 5)
									_G.PU:Dust(bodyVelocity, 0.1)
								end)
								v4:Execute()
								local v5 = Scheduler.Repeat(1, 6)
								v5:Instant()
								v5:Wait(0.03)
								v5:OnStep(function(_)
									local clone5 = skillC.PartDrop2:Clone()
									clone5.Anchored = false
									clone5.CanCollide = false
									clone5.CollisionGroup = "Effect"
									clone5.Transparency = 1
									clone5.CFrame = clone2.CFrame
									clone5.Parent = effects
									local bodyVelocity = Instance.new("BodyVelocity")
									bodyVelocity.Velocity = Vector3.new(
										math.random(-40, 40),
										math.random(50, 150),
										math.random(-40, 40)
									)
									bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
									bodyVelocity.Parent = clone5
									_G.PU:Dust(clone5, 5)
									_G.PU:Dust(bodyVelocity, 0.1)
								end)
								v5:Execute()
							end)
							local v4 = clone2.Position + createVector(0, 5, 0)
							local raycastResult = workspace:Raycast(v4, createVector(0, -60, 0), raycastParams)

							if raycastResult then
								local position = raycastResult.Position
								local clone5 = skillC.Ground_Ray2:Clone()
								clone5.Anchored = true
								clone5.CanCollide = false
								clone5.Transparency = 1
								local clone6 = skillC.Rock2:Clone()
								SetupPart(clone6)
								clone6.CFrame = CFrame.new(position + Vector3.new(0, clone6.Size.Y / 2, 0)) * CFrame.Angles(
									0,
									math.rad(clone2.Orientation.Y),
									0
								)
								clone6.Parent = effects
								_G.PU:Dust(clone6, 5)
								task.spawn(function()
									for _, weld in pairs(clone6:GetChildren()) do
										if not weld:IsA("Weld") then
											continue
										end

										local v5 = math.random(25, 50)
										local v6 = math.random(10, 50) / 100
										weld.C0 *= CFrame.new(0, -v5, 0)
										TweenService:Create(weld, TweenInfo.new(v6, Enum.EasingStyle.Exponential), {
											C0 = weld.C0 * CFrame.new(0, v5, 0)
										}):Play()
									end

									task.wait(1.5)

									for _, weld in pairs(clone6:GetDescendants()) do
										if not (weld:IsA("Weld") and weld.Name == "Neon") then
											continue
										end

										local v5 = math.random(10, 300) / 100
										local v6 = math.random(50, 75)
										local tween = TweenService:Create(
											weld,
											TweenInfo.new(v5, Enum.EasingStyle.Quad),
											{
												C0 = weld.C0 * CFrame.new(0, -v6, 0)
											}
										)
										tween:Play()
										local v8 = weld
										task.spawn(function()
											tween.Completed:Wait()

											if v8.Part1 and v8.Part1.Parent then
												v8.Part1.Parent:Destroy()
											end
										end)
									end

									for _, emitter in pairs(clone6:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter.Enabled = false
										end
									end
								end)
								clone5.CFrame = CFrame.new(position + Vector3.new(0, clone5.Size.Y / 2, 0)) * CFrame.Angles(
									0,
									math.rad(clone2.Orientation.Y),
									0
								)
								clone5.Parent = effects
								Emit(clone5)
								_G.PU:Dust(clone5, 4)
								task.spawn(function()
									for _, emitter in ipairs(clone5:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter.Enabled = true
										end
									end

									task.wait(1.5)

									for _, emitter in ipairs(clone5:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter.Enabled = false
										end
									end
								end)
							end
						end)
					end)
				end

				local childAddedConnection = nil
				childAddedConnection = skillFolder.ChildAdded:Connect(function(child)
					DemonCCast(child) -- equivalent call inferred; original call site unknown
					childAddedConnection:Disconnect()
				end)
				local v4 = Scheduler.new(10)
				v4:OnStep(function()
					if not chargeFolder:IsDescendantOf(character) then
						v4:Destroy()
					elseif clone and clone.Parent then
						clone.CFrame = CFrame.new(rootPart.Position)
					end
				end)
				v4:Execute()
			elseif not demon_KL then
				if (localPlayer.Character.HumanoidRootPart.Position - startCF.Position).Magnitude < 200 then
					_G.CameraShake:ShakeOnce(5, 10, 0, 0.5)
				end

				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 60,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://111834334261655",
					Volume = 0.5
				})
				_G.PU:Dust(sound, 5)
				sound.Parent = rootPart
				sound:Play()
				local skillC = ReplicatedStorage.Chest.FruitEffect.Demon.Human.SkillC
				local clone = skillC.Step1:Clone()
				SetupPart(clone)
				clone.CFrame = startCF
				clone.Parent = effects
				Utility.EmitParticles(clone)
				_G.PU:Dust(clone, 2)

				if localPlayer == v then
					local clone2 = skillC.CameraFX:Clone()
					SetupPart(clone2)
					clone2.Parent = effects
					task.spawn(function()
						FastRenderer.new({
							Time = 5
						}, function()
							if clone2 and clone2.Parent then
								clone2.CFrame = currentCamera.CFrame
							else
								return true
							end
						end)
					end)
					Utility.EmitParticles(clone2)
					_G.PU:Dust(clone2, 5)
				end

				task.spawn(function()
					local v4 = Scheduler.Repeat(1, 4)
					v4:Instant()
					v4:OnStep(function(_)
						local clone2 = skillC.TrailCurve:Clone()
						SetupPart(clone2)
						clone2.CFrame = clone.CFrame
						clone2.Parent = effects
						local position = clone.Position
						local v5 = position + Vector3.new(
							math.random(-20, 20),
							math.random(-20, 20),
							math.random(-20, 20)
						)

						local function getRandomMiddle(position2, p)
							local v6 = math.random(40, 60) / 100
							local v7 = math.random(-50, 50)
							local v8 = math.random(-50, 50)
							local v9 = math.random(-50, 50)
							return position2:Lerp(p, v6) + Vector3.new(v7, v8, v9)
						end

						local randomMiddle = getRandomMiddle(position, v5)
						local v6 = Bezier.new(position, randomMiddle, v5)
						task.spawn(function()
							for i = 1, 51 do
								task.wait(0.01)
								local v7 = v6:Get(i / 51)
								v6:Get((math.min((i + 1) / 51, 1)))
								clone2.CFrame = CFrame.new(v7)
							end
						end)
						task.spawn(function()
							task.wait(0.8)

							for _, emitter in pairs(clone2:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end
						end)
						_G.PU:Dust(clone2, 3)
					end)
					v4:Execute()
				end)
				local v4 = Scheduler.Repeat(1, 3)
				v4:Instant()
				v4:Ignore()
				v4:OnStep(function(_)
					local clone2 = skillC.PartDrop:Clone()
					clone2.Anchored = false
					clone2.CanCollide = false
					clone2.CollisionGroup = "Effect"
					clone2.Transparency = 1
					clone2.CFrame = clone.CFrame
					clone2.Parent = effects
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Velocity = Vector3.new(math.random(-40, 40), math.random(20, 80), math.random(-40, 40))
					bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
					bodyVelocity.Parent = clone2
					_G.PU:Dust(clone2, 5)
					_G.PU:Dust(bodyVelocity, 0.1)
				end)
				v4:Execute()
				local v5 = Scheduler.Repeat(1, 5)
				v5:Instant()
				v5:Ignore()
				v5:OnStep(function(_)
					local clone2 = skillC.PartDrop2:Clone()
					clone2.Anchored = false
					clone2.CanCollide = true
					clone2.CollisionGroup = "Effect"
					clone2.Transparency = 1
					clone2.CFrame = clone.CFrame * CFrame.new(math.random(-30, 30), -5, math.random(-30, 30))
					clone2.Parent = effects
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Velocity = Vector3.new(
						math.random(-40, 40),
						math.random(30, 100),
						math.random(-40, 40)
					)
					bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
					bodyVelocity.Parent = clone2
					task.delay(1, function()
						for _, emitter in pairs(clone2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end)
					_G.PU:Dust(clone2, 3)
					_G.PU:Dust(bodyVelocity, 0.1)
				end)
				v5:Execute()
				local clone2 = skillC.PartTrail:Clone()
				SetupPart(clone2)
				clone2.CFrame = clone.CFrame * CFrame.new(0, 1, 0)
				clone2.Parent = effects
				TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					CFrame = clone2.CFrame * CFrame.new(0, 20, 0) * CFrame.Angles(0, 3.0543261909900767, 0)
				}):Play()
				local clone3 = skillC.PartTrail2:Clone()
				SetupPart(clone3)
				clone3.CFrame = clone.CFrame * CFrame.new(0, 1, 0)
				clone3.Parent = effects
				TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					CFrame = clone3.CFrame * CFrame.new(0, 15, 0) * CFrame.Angles(0, -3.0543261909900767, 0)
				}):Play()
				_G.PU:Dust(clone2, 2)
				_G.PU:Dust(clone3, 2)
				local v6 = clone.Position + createVector(0, 5, 0)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				local raycastResult = workspace:Raycast(v6, createVector(0, -60, 0), raycastParams)

				if raycastResult then
					local position = raycastResult.Position
					local clone4 = skillC.Ground_Ray:Clone()
					clone4.Anchored = true
					clone4.CanCollide = false
					clone4.Transparency = 1
					clone4.CFrame = CFrame.new(position + Vector3.new(0, clone4.Size.Y / 2, 0)) * CFrame.Angles(
						0,
						math.rad(clone.Orientation.Y),
						0
					)
					clone4.Parent = effects
					Emit(clone4)
					_G.PU:Dust(clone4, 4)
					local position2 = raycastResult.Position
					Vector3.new(math.random(8, 13), math.random(20, 27), math.random(8, 13))
					local rockFolder = ReplicatedStorage.Chest.FruitEffect.Demon.Human.RockFolder
					local v7 = Scheduler.Repeat(1, 8)
					v7:Instant()
					v7:Ignore()
					v7:OnStep(function(p)
						local v8 = p / 8 * 3.141592653589793 * 2
						local vector2 = Vector3.new(math.sin(v8) * 18, 0, math.cos(v8) * 18)
						local v9 = math.random(1, 3)
						local v10 = math.random(20, 40) / 15
						local child = rockFolder:FindFirstChild((`Rock{v9}`))
						local child2 = rockFolder:FindFirstChild((`Black{v9}`))
						local clone5 = child:Clone()
						clone5.Anchored = true
						clone5.CanCollide = false
						clone5.CFrame = CFrame.new(position2 + vector2)
						clone5.Parent = effects
						Emit(clone5)
						TweenService:Create(
							clone5,
							TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								Size = clone5.Size * v10
							}
						):Play()
						local clone6 = child2:Clone()
						clone6.Anchored = true
						clone6.CanCollide = false
						clone6.CFrame = CFrame.new(position2 + vector2)
						clone6.Parent = effects
						TweenService:Create(
							clone6,
							TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								Size = clone6.Size * v10
							}
						):Play()
						task.delay(0.8, function()
							for _, emitter in pairs(clone5:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end

							TweenService:Create(
								clone5,
								TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									Size = createVector(0.1, 0.1, 0.1),
									CFrame = clone5.CFrame * CFrame.new(0, -3, 0)
								}
							):Play()
							TweenService:Create(
								clone6,
								TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									Size = createVector(0.1, 0.1, 0.1),
									CFrame = clone6.CFrame * CFrame.new(0, -3, 0)
								}
							):Play()
						end)
						_G.PU:Dust(clone5, 1.5)
						_G.PU:Dust(clone6, 1.5)
					end)
					v7:Execute()
				end
			end
		elseif mode == "Demon V" then
			local _ = ReplicatedStorage.Chest.FruitEffect
			local state = v3.State
			local character = v3.Character
			local rootPart = v3.RootPart
			local humanoid = v3.Humanoid

			if state == "Transform" then
				local skillV = ReplicatedStorage.Chest.FruitEffect.Demon.Human.SkillV
				local childAddedConnection = nil
				task.delay(5, function()
					if childAddedConnection and childAddedConnection.Connected then
						childAddedConnection:Disconnect()
					end
				end)
				childAddedConnection = character.ChildAdded:Connect(function(parent)
					if parent.Name == "Demon_KL" then
						if localPlayer == v then
							_G.PU.PlayOneShotAnim({
								Animator = humanoid,
								Animation = "rbxassetid://78385323874174"
							})
						end

						local highlight = Instance.new("Highlight")
						highlight.DepthMode = Enum.HighlightDepthMode.Occluded
						highlight.FillColor = Color3.fromRGB(255, 85, 0)
						highlight.OutlineTransparency = 1
						highlight.FillTransparency = 0
						highlight.Parent = parent
						_G.PU:Dust(highlight, 2)
						task.spawn(function()
							TweenService:Create(
								highlight,
								TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
								{
									FillTransparency = 1
								}
							):Play()
						end)
						childAddedConnection:Disconnect()
						childAddedConnection = nil
					end
				end)

				if localPlayer == v then
					local clone = skillV.CameraFX:Clone()
					SetupPart(clone)
					clone.Parent = effects
					task.spawn(function()
						FastRenderer.new({
							Time = 5
						}, function()
							if clone and clone.Parent then
								clone.CFrame = currentCamera.CFrame
							else
								return true
							end
						end)
					end)
					Utility.EmitParticles(clone)
					_G.PU:Dust(clone, 5)
					task.delay(0.6, function()
						Utility.ParticleHandler(clone, false)
					end)
				end

				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://89641042854454",
					Volume = 0.5
				})
				_G.PU:Dust(sound, 5)
				sound.Parent = rootPart
				sound:Play()
				local clone = skillV.Step1:Clone()
				clone:PivotTo(rootPart.CFrame)
				clone.Parent = effects
				_G.PU:Dust(clone, 5)
				local weld = Instance.new("Weld")
				weld.Part0 = rootPart
				weld.Part1 = clone.PrimaryPart
				weld.Parent = clone.PrimaryPart
				task.spawn(function()
					local v4 = Scheduler.Repeat(3, 0.01, -0.096)
					v4:Wait()
					v4:OnStep(function(p)
						clone:ScaleTo(p)
					end)
					v4:Execute()
				end)
				task.spawn(function()
					local v4 = Scheduler.Repeat(1, 11)
					v4:Wait(0.1)
					v4:OnStep(function()
						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 150 then
							Motion:Shake("Rise")
						end
					end)
					v4:Execute()
				end)
				task.delay(0.1, function()
					local clone2 = skillV.FireCircle:Clone()
					SetupPart(clone2)
					clone2.CFrame = rootPart.CFrame * CFrame.Angles(0, 0, -1.5707963267948966)
					clone2.Parent = effects
					_G.PU:Dust(clone2, 5)
					task.delay(0.3, function()
						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 200 then
							_G.CameraShake:ShakeOnce(8, 14, 0, 0.33, createVector(0, 0, -1))
						end

						for _, emitter in pairs(clone:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						for _, emitter in pairs(clone2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						local clone3 = skillV.Step2:Clone()
						SetupPart(clone3)
						clone3.CFrame = rootPart.CFrame * CFrame.new(0, 2, 0)
						clone3.Parent = effects
						Utility.EmitParticles(clone3)
						_G.PU:Dust(clone3, 2)
						local v4 = Scheduler.Repeat(1, 3)
						v4:Ignore()
						v4:Instant()
						v4:OnStep(function()
							local clone4 = skillV.PartDrop:Clone()
							clone4.Anchored = false
							clone4.CanCollide = false
							clone4.CollisionGroup = "Effect"
							clone4.Transparency = 1
							clone4.CFrame = clone3.CFrame
							clone4.Parent = effects
							local bodyVelocity = Instance.new("BodyVelocity")
							bodyVelocity.Velocity = Vector3.new(
								math.random(-70, 70),
								math.random(40, 70),
								math.random(-70, 70)
							)
							bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
							bodyVelocity.Parent = clone4
							_G.PU:Dust(clone4, 5)
							_G.PU:Dust(bodyVelocity, 0.1)
						end)
						v4:Execute()
						local v5 = Scheduler.Repeat(1, 3)
						v5:Ignore()
						v5:Instant()
						v5:OnStep(function()
							local clone4 = skillV.PartDrop2:Clone()
							clone4.Anchored = false
							clone4.CanCollide = false
							clone4.CollisionGroup = "Effect"
							clone4.Transparency = 1
							clone4.CFrame = clone3.CFrame
							clone4.Parent = effects
							local bodyVelocity = Instance.new("BodyVelocity")
							bodyVelocity.Velocity = Vector3.new(
								math.random(-70, 70),
								math.random(40, 70),
								math.random(-70, 70)
							)
							bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
							bodyVelocity.Parent = clone4
							_G.PU:Dust(clone4, 5)
							_G.PU:Dust(bodyVelocity, 0.1)
						end)
						v5:Execute()
						task.spawn(function()
							local v6 = Scheduler.Repeat(1, 5)
							v6:Ignore()
							v6:Instant()
							v6:OnStep(function()
								local clone4 = skillV.TrailCurve:Clone()
								SetupPart(clone4)
								clone4.CFrame = rootPart.CFrame
								clone4.Parent = effects
								local position = rootPart.Position
								local v7 = position + Vector3.new(
									math.random(-20, 20),
									math.random(10, 30),
									math.random(-50, 50)
								)

								local function getRandomMiddle(position2, p)
									local v8 = math.random(40, 60) / 100
									local v9 = math.random(-100, 100)
									local v10 = math.random(-100, 100)
									local v11 = math.random(-50, 50)
									return position2:Lerp(p, v8) + Vector3.new(v9, v10, v11)
								end

								local randomMiddle = getRandomMiddle(position, v7)
								local v8 = Bezier.new(position, randomMiddle, v7)
								task.spawn(function()
									local v9 = Scheduler.Repeat(1, 60)
									v9:Wait()
									v9:Instant()
									v9:OnStep(function(p)
										local v10 = v8:Get(p / 60)
										v8:Get((math.min((p + 1) / 60, 1)))
										clone4.CFrame = CFrame.new(v10)
									end)
									v9:Execute()
								end)
								task.spawn(function()
									task.wait(1)

									for _, emitter in pairs(clone4:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter.Enabled = false
										end
									end
								end)
								_G.PU:Dust(clone4, 3)
							end)
							v6:Execute()
							local v7 = Scheduler.Repeat(1, 10)
							v7:Ignore()
							v7:Instant()
							v7:OnStep(function()
								local clone4 = skillV.TrailCurve2:Clone()
								SetupPart(clone4)
								clone4.CFrame = rootPart.CFrame
								clone4.Parent = effects
								local position = rootPart.Position
								local v8 = position + Vector3.new(
									math.random(-20, 20),
									math.random(10, 30),
									math.random(-50, 50)
								)

								local function getRandomMiddle(position2, p)
									local v9 = math.random(40, 60) / 100
									local v10 = math.random(-100, 100)
									local v11 = math.random(-100, 100)
									local v12 = math.random(-50, 50)
									return position2:Lerp(p, v9) + Vector3.new(v10, v11, v12)
								end

								local randomMiddle = getRandomMiddle(position, v8)
								local v9 = Bezier.new(position, randomMiddle, v8)
								task.spawn(function()
									local v10 = Scheduler.Repeat(1, 60)
									v10:Wait()
									v10:Instant()
									v10:OnStep(function(p)
										local v11 = v9:Get(p / 60)
										v9:Get((math.min((p + 1) / 60, 1)))
										clone4.CFrame = CFrame.new(v11)
									end)
									v10:Execute()
								end)
								task.spawn(function()
									task.wait(1)

									for _, emitter in pairs(clone4:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter.Enabled = false
										end
									end
								end)
								_G.PU:Dust(clone4, 3)
							end)
							v7:Execute()
						end)
					end)
				end)
			else
				if state ~= "Untransform" then
					return
				end

				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://100267545984210",
					Volume = 0.5
				})
				_G.PU:Dust(sound, 5)
				sound.Parent = rootPart
				sound:Play()
				local skillV = ReplicatedStorage.Chest.FruitEffect.Demon.Ifrist.SkillV
				local clone = skillV.Step1:Clone()
				SetupPart(clone)
				clone.CFrame = rootPart.CFrame
				clone.Parent = effects
				Utility.EmitParticles(clone)
				_G.PU:Dust(clone, 2)

				if localPlayer == v then
					local clone2 = skillV.CameraFX:Clone()
					SetupPart(clone2)
					clone2.Parent = effects
					task.spawn(function()
						FastRenderer.new({
							Time = 5
						}, function()
							if clone2 and clone2.Parent then
								clone2.CFrame = currentCamera.CFrame
							else
								return true
							end
						end)
					end)
					Utility.EmitParticles(clone2)
					_G.PU:Dust(clone2, 5)
				end
			end
		elseif mode == "Demon E" then
			local character = v3.Character
			local chargeFolder = v3.ChargeFolder
			local rootPart = v3.RootPart
			local demon_KL = character:FindFirstChild("Demon_KL")

			if demon_KL then
				if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 250 then
					Motion:Shake("Rise")
				end

				local highlight = Instance.new("Highlight")
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.FillColor = Color3.fromRGB(255, 85, 0)
				highlight.OutlineTransparency = 1
				highlight.FillTransparency = 0
				highlight.Parent = demon_KL
				_G.PU:Dust(highlight, 11)
				local skillE = ReplicatedStorage.Chest.FruitEffect.Demon.Ifrist.SkillE
				local clone = skillE.Step1:Clone()
				SetupPart(clone)
				clone.CFrame = rootPart.CFrame
				clone.Parent = effects
				_G.PU:Dust(clone, 2)
				local clone2

				if localPlayer == v then
					clone2 = skillE.CameraFX:Clone()
					SetupPart(clone2)
					clone2.Parent = effects
					_G.PU:Dust(clone2, 11)
				else
					clone2 = nil
				end

				task.spawn(function()
					local v4 = Scheduler.Repeat(1, 10)
					v4:Wait(0.1)
					v4:Instant()
					v4:OnStep(function()
						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 150 then
							Motion:Shake("Rise")
						end
					end)
					v4:Execute()
				end)
				local clone3 = skillE.Step2:Clone()
				clone3:PivotTo(rootPart.CFrame * CFrame.new(0, -3, 0) * CFrame.Angles(0, 0, -1.5707963267948966))
				clone3.Parent = effects
				_G.PU:Dust(clone3, 11)
				task.spawn(function()
					local v4 = Scheduler.Repeat(1, 2, 0.032)
					v4:Instant()
					v4:Wait()
					v4:OnStep(function(p)
						clone3:ScaleTo(p)
					end)
					v4:Execute()
				end)
				local clone4 = skillE.Step3:Clone()
				SetupPart(clone4)
				clone4.CFrame = rootPart.CFrame * CFrame.new(0, 2, 0)
				clone4.Parent = effects
				_G.PU:Dust(clone4, 11)
				local position = (clone4.CFrame * CFrame.new(0, 0, -0.5)).Position
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				local clone5 = skillE.Ground_Ray:Clone()
				clone5.Anchored = true
				clone5.CanCollide = false
				clone5.Transparency = 1
				clone5.CFrame = CFrame.new(rootPart.Position) * CFrame.new(0, -18, 0)
				clone5.Parent = effects
				_G.PU:Dust(clone5, 11)
				Utility.ParticleHandler(clone5, true)
				local raycastResult = workspace:Raycast(position, createVector(0, -60, 0), raycastParams)

				if raycastResult then
					local position2 = raycastResult.Position
					clone5.CFrame = CFrame.new(position2 + Vector3.new(0, clone5.Size.Y / 2, 0)) * CFrame.Angles(
						0,
						math.rad(clone4.Orientation.Y),
						0
					)
				end

				local clone6 = skillE.PartTrail:Clone()
				SetupPart(clone6)
				clone6.CFrame = rootPart.CFrame
				clone6.Parent = effects
				_G.PU:Dust(clone6, 11)
				local total = 0
				local v4 = 1
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 60,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://113917471889659",
					Volume = 0.5
				})
				_G.PU:Dust(sound, 7)
				sound.Parent = rootPart
				sound:Play()
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 60,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://83271470693302",
					Volume = 0.5,
					Looped = true
				})
				_G.PU:Dust(sound2, 15)
				sound2.Parent = rootPart
				sound2:Play()
				FastRenderer.new({
					Time = 10
				}, function(_, p)
					if not chargeFolder:IsDescendantOf(character) then
						return true
					end

					if clone2 and clone2.Parent then
						clone2.CFrame = currentCamera.CFrame
					end

					clone6.CFrame *= CFrame.Angles(0, 0.241660973353061 * p * 60, 0)

					if highlight and highlight.Parent then
						total += p * 10 * v4

						if total >= 1 then
							total = 1
							v4 = -1
						elseif total <= 0.01 then
							total = 0.01
							v4 = 1
						end

						highlight.FillTransparency = total
					end
				end)

				if sound2 and sound2.Parent then
					TweenService:Create(sound2, TweenInfo.new(0.5), {
						Volume = 0
					}):Play()
				end

				if clone5 and clone5.Parent then
					Utility.ParticleHandler(clone5, false)
					_G.PU:Dust(clone5, 2)
				end

				if highlight and highlight.Parent then
					highlight:Destroy()
				end

				task.spawn(function()
					FastRenderer.new({
						Time = 1
					}, function(_, _)
						if clone2 and clone2.Parent then
							clone2.CFrame = currentCamera.CFrame
						else
							return true
						end
					end)
				end)
				task.spawn(function()
					Utility.ParticleHandler(clone2, false)
					local sound3 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 60,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://108309510614926",
						Volume = 0.5
					})
					_G.PU:Dust(sound3, 7)
					sound3.Parent = rootPart
					sound3:Play()
					local sound4 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 60,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://85007593827203",
						Volume = 1
					})
					_G.PU:Dust(sound4, 4)
					sound4.Parent = rootPart
					sound4:Play()

					if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 200 then
						_G.CameraShake:ShakeOnce(9, 17, 0, 1.25, createVector(0, 0, -1))
						Utility.BloomBlur()
					end

					for _, emitter in pairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					for _, emitter in pairs(clone4:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					local clone7 = skillE.Step4:Clone()
					SetupPart(clone7)
					clone7.CFrame = rootPart.CFrame * CFrame.new(0, 12, 0)
					clone7.Parent = effects
					Emit(clone7)
					_G.PU:Dust(clone7, 2)
					local v5 = Scheduler.Repeat(1, 10)
					v5:Instant()
					v5:Ignore()
					v5:OnStep(function()
						local clone8 = skillE.PartDrop:Clone()
						clone8.Anchored = false
						clone8.CanCollide = false
						clone8.CollisionGroup = "Effect"
						clone8.Transparency = 1
						clone8.CFrame = rootPart.CFrame
						clone8.Parent = effects
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.Velocity = Vector3.new(
							math.random(-70, 70),
							math.random(40, 70),
							math.random(-70, 70)
						)
						bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
						bodyVelocity.Parent = clone8
						_G.PU:Dust(clone8, 5)
						_G.PU:Dust(bodyVelocity, 0.1)
					end)
					v5:Execute()
					local v6 = Scheduler.Repeat(1, 10)
					v6:Instant()
					v6:Ignore()
					v6:OnStep(function()
						local clone8 = skillE.PartDrop2:Clone()
						clone8.Anchored = false
						clone8.CanCollide = false
						clone8.CollisionGroup = "Effect"
						clone8.Transparency = 1
						clone8.CFrame = rootPart.CFrame
						clone8.Parent = effects
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.Velocity = Vector3.new(
							math.random(-70, 70),
							math.random(40, 70),
							math.random(-70, 70)
						)
						bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
						bodyVelocity.Parent = clone8
						_G.PU:Dust(clone8, 5)
						_G.PU:Dust(bodyVelocity, 0.1)
					end)
					v6:Execute()
					task.spawn(function()
						local v7 = Scheduler.Repeat(1, 10)
						v7:Instant()
						v7:Ignore()
						v7:OnStep(function()
							local clone8 = skillE.TrailCurve:Clone()
							SetupPart(clone8)
							clone8.CFrame = rootPart.CFrame
							clone8.Parent = effects
							local position2 = rootPart.Position
							local v8 = position2 + Vector3.new(
								math.random(-20, 20),
								math.random(10, 30),
								math.random(-100, 100)
							)

							local function getRandomMiddle(position3, p)
								local v9 = math.random(40, 60) / 100
								local v10 = math.random(-100, 100)
								local v11 = math.random(-100, 100)
								local v12 = math.random(-50, 50)
								return position3:Lerp(p, v9) + Vector3.new(v10, v11, v12)
							end

							local randomMiddle = getRandomMiddle(position2, v8)
							local v9 = Bezier.new(position2, randomMiddle, v8)
							task.spawn(function()
								local v10 = Scheduler.Repeat(1, 60)
								v10:Wait()
								v10:Instant()
								v10:OnStep(function(p)
									local v11 = v9:Get(p / 60)
									v9:Get((math.min((p + 1) / 60, 1)))
									clone8.CFrame = CFrame.new(v11)
								end)
								v10:Execute()
							end)
							task.spawn(function()
								task.wait(1)

								for _, emitter in pairs(clone8:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter.Enabled = false
									end
								end
							end)
							_G.PU:Dust(clone8, 3)
						end)
						v7:Execute()
					end)
					local v7 = clone7.Position + createVector(0, 5, 0)
					local raycastResult2 = workspace:Raycast(v7, createVector(0, -60, 0), raycastParams)

					if raycastResult2 then
						local position2 = raycastResult2.Position
						local clone8 = skillE.Ground_Ray2:Clone()
						clone8.Anchored = true
						clone8.CanCollide = false
						clone8.Transparency = 1
						local clone9 = skillE.Rock:Clone()
						SetupPart(clone9)
						clone9.CFrame = CFrame.new(position2 + Vector3.new(0, clone9.Size.Y / 2, 0)) * CFrame.Angles(
							0,
							math.rad(clone7.Orientation.Y),
							0
						)
						clone9.Parent = effects
						_G.PU:Dust(clone9, 5)
						task.spawn(function()
							for _, weld in pairs(clone9:GetChildren()) do
								if not weld:IsA("Weld") then
									continue
								end

								local v8 = math.random(25, 50)
								local v9 = math.random(10, 50) / 100
								weld.C0 *= CFrame.new(0, -v8, 0)
								TweenService:Create(weld, TweenInfo.new(v9, Enum.EasingStyle.Exponential), {
									C0 = weld.C0 * CFrame.new(0, v8, 0)
								}):Play()
							end

							task.wait(1.5)

							for _, descendant in pairs(clone9:GetDescendants()) do
								if not (descendant:IsA("SpecialMesh") or descendant:IsA("MeshPart")) then
									continue
								end

								local v8 = descendant
								task.spawn(function()
									local cFrame = v8.CFrame
									local v9 = Scheduler.Repeat(1, 5)
									v9:Instant()
									v9:Wait(0.03)
									v9:OnStep(function(p)
										v8.CFrame = cFrame * CFrame.new(
											math.random(-10, 10) * 0.1,
											math.random(-10, 10) * 0.1,
											math.random(-10, 10) * 0.1
										)
									end)
									v9:Execute()
									v8.CFrame = cFrame
								end)
								TweenService:Create(
									descendant,
									TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
									{
										Size = createVector(1, 1, 1)
									}
								):Play()
								TweenService:Create(clone9, TweenInfo.new(0.5), {
									CFrame = clone9.CFrame * CFrame.new(0, -20, 0)
								}):Play()
							end

							for _, decal in pairs(clone9:GetDescendants()) do
								if decal:IsA("Decal") then
									TweenService:Create(decal, TweenInfo.new(0.3), {
										Transparency = 1
									}):Play()
								end
							end

							for _, emitter in pairs(clone9:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end
						end)
						clone8.CFrame = CFrame.new(position2 + Vector3.new(0, clone8.Size.Y / 2, 0)) * CFrame.Angles(
							0,
							math.rad(clone7.Orientation.Y),
							0
						)
						clone8.Parent = effects
						Emit(clone8)
						_G.PU:Dust(clone8, 4)
						task.spawn(function()
							for _, emitter in ipairs(clone8:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = true
								end
							end

							task.wait(1.5)

							for _, emitter in ipairs(clone8:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end
						end)
					end
				end)
			elseif not demon_KL then
				local skillE = ReplicatedStorage.Chest.FruitEffect.Demon.Human.SkillE
				local clone = nil
				local highlight = nil
				local attachment = nil
				local attachment2 = nil
				local clone2 = nil
				local v4 = nil
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 60,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://98532080134887",
					Volume = 0.5
				})
				_G.PU:Dust(sound, 5)
				sound.Parent = rootPart
				sound:Play()

				local function CreateFlame()
					v4 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 60,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://7978653185",
						Volume = 0.5,
						Looped = true
					})
					_G.PU:Dust(v4, 65)
					v4.Parent = rootPart
					v4:Play()
					clone = skillE.Step1:Clone()
					clone.Anchored = false
					clone.CanCollide = false
					clone.Transparency = 1
					clone.CFrame = rootPart.CFrame
					clone.Parent = effects
					_G.PU:Dust(clone, 65)
					local weld = Instance.new("Weld")
					weld.Part0 = rootPart
					weld.Part1 = clone
					weld.C0 = CFrame.new(0, -1, 0)
					weld.Parent = clone
					highlight = Instance.new("Highlight")
					highlight.DepthMode = Enum.HighlightDepthMode.Occluded
					highlight.FillColor = Color3.fromRGB(255, 85, 0)
					highlight.OutlineTransparency = 1
					highlight.FillTransparency = 0.5
					highlight.Parent = character
					_G.PU:Dust(highlight, 65)
					attachment = Instance.new("Attachment")
					attachment.Position = createVector(-1.25, 0, 0)
					attachment.Parent = character.RightFoot
					_G.PU:Dust(attachment, 65)
					attachment2 = Instance.new("Attachment")
					attachment2.Position = createVector(1.25, 0, 0)
					attachment2.Parent = rootPart
					_G.PU:Dust(attachment2, 65)
					clone2 = ReplicatedStorage.Chest.FruitEffect.FlameNew.Trail:Clone()
					clone2.Lifetime = 0.3
					clone2.Color = ColorSequence.new(Color3.fromRGB(255, 85, 0))
					clone2.Attachment0 = attachment
					clone2.Attachment1 = attachment2
					clone2.Parent = rootPart
					_G.PU:Dust(clone2, 65)
				end

				CreateFlame()
				local clone3 = ReplicatedStorage.Chest.FruitEffect.Demon.Human.SkillX.Step1:Clone()
				SetupPart(clone3)
				clone3.CFrame = rootPart.CFrame * CFrame.new(0, 1, 0)
				clone3.Parent = effects
				_G.PU:Dust(clone3, 2)
				Utility.EmitParticles(clone3)
				local lastTime = tick()
				local v5 = Scheduler.new(60)
				v5:OnStep(function()
					if not chargeFolder:IsDescendantOf(character) then
						v5:Destroy()
					elseif tick() - lastTime > 1 then
						lastTime = tick()

						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 1000 then
							if not clone then
								CreateFlame()
							end
						else
							if clone and clone.Parent then
								clone:Destroy()
								clone = nil
							end

							if v4 and v4.Parent then
								v4:Destroy()
								v4 = nil
							end

							if highlight and highlight.Parent then
								highlight:Destroy()
								highlight = nil
							end

							if attachment and attachment.Parent then
								attachment:Destroy()
								attachment = nil
							end

							if attachment2 and attachment2.Parent then
								attachment2:Destroy()
								attachment2 = nil
							end

							if clone2 and clone2.Parent then
								clone2:Destroy()
							end
						end
					end
				end)
				v5:Execute()

				if clone and clone.Parent then
					Utility.ParticleHandler(clone, false)
					_G.PU:Dust(clone, 2)
				end

				if highlight and highlight.Parent then
					TweenService:Create(
						highlight,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
						{
							FillTransparency = 1
						}
					):Play()
					_G.PU:Dust(highlight, 1)
				end

				if attachment then
					_G.PU:Dust(attachment, 1)
				end

				if attachment2 then
					_G.PU:Dust(attachment2, 1)
				end

				if clone2 then
					clone2.Enabled = false
					_G.PU:Dust(clone2, 1)
				end

				if v4 and v4.Parent then
					TweenService:Create(v4, TweenInfo.new(0.5), {
						Volume = 0
					}):Play()
					_G.PU:Dust(v4, 1)
				end
			end
		elseif mode == "Pyreblade Z" then
			local rootPart = v3.RootPart
			local skillFolder = v3.SkillFolder
			local skillZ = ReplicatedStorage.Chest.SwordEffect.Pyreblade.SkillZ

			local function CreateDragon(child)
				local clone = skillZ.Pteradragon:Clone()
				clone:PivotTo(rootPart.CFrame * CFrame.new(0, 10, 0))
				clone.Parent = effects
				_G.PU:Dust(clone, 5)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://109312518223078",
					Volume = 0.2,
					PlaybackSpeed = 2
				})
				_G.PU:Dust(sound, 5)
				sound.Parent = clone
				sound:Play()
				task.spawn(function()
					local startCF = child:GetAttribute("StartCF")
					local v4 = startCF * CFrame.new(math.random(-90, 90), math.random(75, 150), math.random(-40, 40))
					local endCF = child:GetAttribute("EndCF")
					local v5 = Bezier.new(startCF.Position, v4.Position, endCF.Position)
					local v6 = Scheduler.Repeat(1, 45)
					v6:Wait()
					v6:OnStep(function(p)
						local v7 = v5:Get(p / 45)
						local v8 = v5:Get((p + 1) / 45)
						clone.RootPart.CFrame = CFrame.new(v7, v8)
					end)
					v6:Execute()

					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					for _, part in pairs(clone:GetDescendants()) do
						if part:IsA("MeshPart") then
							part.Transparency = 1
						end
					end

					if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 150 then
						Motion:Shake("Rise")
					end

					local clone2 = skillZ.Dragon_Exp:Clone()
					SetupPart(clone2)
					clone2.CFrame = CFrame.new(endCF.Position)
					clone2.Parent = effects
					_G.PU:Dust(clone2, 5)
					Emit(clone2)
					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://131338899422097",
						Volume = 0.35
					})
					_G.PU:Dust(sound2, 3)
					sound2.Parent = clone2
					sound2:Play()
					local v7 = endCF.Position + createVector(0, 10, 0)
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					local raycastResult = workspace:Raycast(v7, createVector(0, -40, 0), raycastParams)

					if raycastResult then
						local position = raycastResult.Position
						local clone3 = ReplicatedStorage.Chest.SwordEffect.Pyreblade.SkillX.Ground_Ray2:Clone()
						clone3.Anchored = true
						clone3.CanCollide = false
						clone3.Transparency = 1
						clone3.CFrame = CFrame.new(position + Vector3.new(0, clone3.Size.Y / 2, 0)) * CFrame.Angles(
							0,
							math.rad(clone2.Orientation.Y),
							0
						)
						clone3.Parent = effects
						Emit(clone3)
						task.delay(2, function()
							for _, emitter in pairs(clone3:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end
						end)
						_G.PU:Dust(clone3, 4)
					end
				end)
			end

			local childAddedConnection = skillFolder.ChildAdded:Connect(function(child)
				CreateDragon(child)
			end)
			task.delay(5, function()
				if childAddedConnection and childAddedConnection.Connected then
					childAddedConnection:Disconnect()
				end
			end)
			task.spawn(function()
				if localPlayer == v then
					local clone = skillZ.CameraFX:Clone()
					SetupPart(clone)
					clone.Parent = effects
					task.delay(2.5, function()
						Utility.ParticleHandler(clone, false)
					end)
					_G.PU:Dust(clone, 5)
					FastRenderer.new({
						Time = 5
					}, function()
						if clone and clone.Parent then
							clone.CFrame = currentCamera.CFrame
						else
							return true
						end
					end)
				end
			end)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://139394734327517",
				Volume = 0.5
			})
			_G.PU:Dust(sound, 6)
			sound.Parent = rootPart
			sound:Play()
			local clone = skillZ.Step1:Clone()
			clone.Anchored = false
			clone.CanCollide = false
			clone.Transparency = 1
			clone.CFrame = rootPart.CFrame
			clone.Parent = effects
			_G.PU:Dust(clone, 5)
			local weld = Instance.new("Weld")
			weld.Part0 = rootPart
			weld.Part1 = clone
			weld.C1 *= CFrame.new(0, -1, 0)
			weld.Parent = clone
			task.spawn(function()
				local v4 = Scheduler.new(1)
				v4:Wait(0.1)
				v4:Ignore()
				v4:OnStep(function()
					if not clone then
						v4:Destroy()
						return
					end

					if clone and not clone.Parent then
						v4:Destroy()
						return
					end

					local position = rootPart.Position
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					local raycastResult = workspace:Raycast(position, createVector(0, -30, 0), raycastParams)

					if raycastResult then
						local position2 = raycastResult.Position
						local clone2 = skillZ.Ground_Ray:Clone()
						clone2.Anchored = true
						clone2.CanCollide = false
						clone2.Transparency = 1
						clone2.CFrame = CFrame.new(position2 + Vector3.new(0, clone2.Size.Y / 2, 0)) * CFrame.Angles(
							0,
							math.rad(clone.Orientation.Y),
							0
						)
						clone2.Parent = effects
						_G.PU:Dust(clone2, 4)
						task.delay(1, function()
							for _, emitter in pairs(clone2:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end
						end)
					end
				end)
				v4:Execute()
				task.delay(1, function()
					for _, effect in pairs(clone:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://115552876262349",
						Volume = 0.5
					})
					_G.PU:Dust(sound2, 6)
					sound2.Parent = rootPart
					sound2:Play()
					local clone2 = skillZ.Step2:Clone()
					SetupPart(clone2)
					clone2.CFrame = rootPart.CFrame
					clone2.Parent = effects
					_G.PU:Dust(clone2, 5)
					task.spawn(function()
						local v5 = Scheduler.Repeat(1, 15)
						v5:Wait(0.1)
						v5:OnStep(function()
							if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 150 then
								Motion:Shake("Rise")
							end
						end)
						v5:Execute()
					end)
					local v5 = clone2.Position + createVector(0, 5, 0)
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					local raycastResult = workspace:Raycast(v5, createVector(0, -50, 0), raycastParams)

					if raycastResult then
						local position = raycastResult.Position
						local clone3 = skillZ.Ground_Ray2:Clone()
						clone3.Anchored = true
						clone3.CanCollide = false
						clone3.Transparency = 1
						clone3.CFrame = CFrame.new(position + Vector3.new(0, clone3.Size.Y / 2, 0)) * CFrame.Angles(
							0,
							math.rad(clone2.Orientation.Y),
							0
						)
						clone3.Parent = effects
						task.delay(1.5, function()
							for _, emitter in pairs(clone3:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end
						end)
						_G.PU:Dust(clone3, 4)
					end

					task.delay(1.5, function()
						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 200 then
							_G.CameraShake:ShakeOnce(8, 14, 0, 0.33, createVector(0, 0, -1))
						end

						for _, emitter in pairs(clone2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end

						local clone3 = skillZ.Step3:Clone()
						SetupPart(clone3)
						clone3.CFrame = rootPart.CFrame * CFrame.new(0, 18, 0)
						clone3.Parent = effects
						Emit(clone3)
						_G.PU:Dust(clone3, 5)
						task.spawn(function()
							local v6 = Scheduler.Repeat(1, 10)
							v6:Ignore()
							v6:Instant()
							v6:OnStep(function()
								local clone4 = skillZ.PartCurve:Clone()
								SetupPart(clone4)
								clone4.CFrame = clone3.CFrame
								clone4.Parent = effects
								local v7 = clone3.Position + createVector(0, -35, 0)
								local v8 = v7 + Vector3.new(
									math.random(-70, 70),
									math.random(1, 100),
									math.random(-70, 70)
								)

								local function getRandomMiddle(p, p2)
									local v9 = math.random(40, 60) / 100
									local v10 = math.random(-100, 100)
									local v11 = math.random(-60, 60)
									local v12 = math.random(-50, 50)
									return p:Lerp(p2, v9) + Vector3.new(v10, v11, v12)
								end

								local randomMiddle = getRandomMiddle(v7, v8)
								local v9 = Bezier.new(v7, randomMiddle, v8)
								task.spawn(function()
									local v10 = Scheduler.Repeat(1, 50)
									v10:Wait()
									v10:Instant()
									v10:OnStep(function(p)
										local v11 = v9:Get(p / 50)
										v9:Get((math.min((p + 1) / 50, 1)))
										clone4.CFrame = CFrame.new(v11)
									end)
									v10:Execute()
								end)
								task.spawn(function()
									task.wait(1)

									for _, emitter in pairs(clone4:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter.Enabled = false
										end
									end
								end)
								_G.PU:Dust(clone4, 3)
							end)
							v6:Execute()
						end)
						local v6 = clone3.Position + createVector(0, 5, 0)
						local v7 = clone3.CFrame.UpVector * -25
						local raycastParams2 = RaycastParams.new()
						raycastParams2.FilterType = Enum.RaycastFilterType.Include
						raycastParams2.FilterDescendantsInstances = { workspace.Island }
						local raycastResult2 = workspace:Raycast(v6, v7, raycastParams2)

						if raycastResult2 then
							local position = raycastResult2.Position
							local clone4 = skillZ.Ground_Ray3:Clone()
							clone4.Anchored = true
							clone4.CanCollide = false
							clone4.Transparency = 1
							clone4.CFrame = CFrame.new(position + Vector3.new(0, clone4.Size.Y / 2, 0)) * CFrame.Angles(
								0,
								math.rad(clone3.Orientation.Y),
								0
							)
							clone4.Parent = effects
							Emit(clone4)
							task.delay(2, function()
								for _, emitter in pairs(clone4:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter.Enabled = false
									end
								end
							end)
							_G.PU:Dust(clone4, 4)
							task.spawn(function()
								local raycastParams3 = RaycastParams.new()
								raycastParams3.FilterType = Enum.RaycastFilterType.Include
								raycastParams3.FilterDescendantsInstances = { workspace.Island }
								raycastParams3.IgnoreWater = true
								local position2 = raycastResult2.Position
								local v8 = Scheduler.Repeat(1, 20)
								v8:Instant()
								v8:Ignore()
								v8:OnStep(function(p)
									local v9 = p / 20 * 3.141592653589793 * 2
									local vector2 = Vector3.new(math.sin(v9) * 35, 0, math.cos(v9) * 35)
									local part = Instance.new("Part")
									part.Anchored = true
									part.CanCollide = false
									part.Size = Vector3.new(math.random(10, 20), math.random(1, 3), math.random(10, 20))
									local v10 = position2 + vector2 + createVector(0, 20, 0)
									local raycastResult3 = workspace:Raycast(
										v10,
										createVector(0, -50, 0),
										raycastParams3
									)

									if raycastResult3 then
										part.Material = raycastResult3.Material
										part.Color = raycastResult3.Instance.Color
									end

									part.CFrame = CFrame.new(position2 + vector2) * CFrame.Angles(
										math.rad((math.random(-10, 10))),
										math.rad((math.random(0, 360))),
										(math.rad((math.random(-10, 10))))
									)
									part.Parent = effects
									task.delay(2, function()
										TweenService:Create(
											part,
											TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
											{
												Transparency = 1,
												CFrame = part.CFrame * CFrame.new(0, -5, 0)
											}
										):Play()
										_G.PU:Dust(part, 5)
									end)
								end)
								v8:Execute()
							end)
						end
					end)
				end)
			end)
		elseif mode == "Pyreblade X" then
			local character = v3.Character
			local chargeFolder = v3.ChargeFolder
			local skillFolder = v3.SkillFolder
			local skillFolder2 = v3.SkillFolder2
			local rootPart = v3.RootPart
			local pyreblade = ReplicatedStorage.Chest.SwordEffect.Pyreblade
			local skillZ = pyreblade.SkillZ
			local skillX = pyreblade.SkillX
			local clone = skillX.Step1:Clone()
			SetupPart(clone)
			clone.CFrame = rootPart.CFrame * CFrame.new(0, 7, -5)
			clone.Parent = effects
			_G.PU:Dust(clone, 12)

			local function CreateDragon(child)
				local startCF = child:GetAttribute("StartCF")
				local endCF = child:GetAttribute("EndCF")
				local clone2 = skillZ.Pteradragon:Clone()
				clone2:PivotTo(startCF)
				clone2.Parent = effects
				_G.PU:Dust(clone2, 5)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://109312518223078",
					Volume = 0.12,
					PlaybackSpeed = 2
				})
				_G.PU:Dust(sound, 5)
				sound.Parent = clone2
				sound:Play()
				task.spawn(function()
					local v4 = startCF
					local v5 = v4 * CFrame.new(math.random(-90, 90), math.random(50, 100), math.random(-40, 40))
					local v6 = endCF
					local v7 = Bezier.new(v4.Position, v5.Position, v6.Position)
					local v8 = Scheduler.Repeat(1, 55)
					v8:Wait()
					v8:OnStep(function(p)
						local v9 = v7:Get(p / 55)
						local v10 = v7:Get((p + 1) / 55)
						clone2.RootPart.CFrame = CFrame.new(v9, v10)
					end)
					v8:Execute()

					for _, emitter in pairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					for _, part in pairs(clone2:GetDescendants()) do
						if part:IsA("MeshPart") then
							part.Transparency = 1
						end
					end

					if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 150 then
						Motion:Shake("Rise")
					end

					local clone3 = skillX.Dragon_Exp2:Clone()
					SetupPart(clone3)
					clone3.CFrame = CFrame.new(v6.Position)
					clone3.Parent = effects
					_G.PU:Dust(clone3, 5)
					Emit(clone3)
					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://138262437681497",
						Volume = 0.3
					})
					_G.PU:Dust(sound2, 5)
					sound2.Parent = clone3
					sound2:Play()
					local v9 = endCF.Position + createVector(0, 10, 0)
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					local raycastResult = workspace:Raycast(v9, createVector(0, -40, 0), raycastParams)

					if raycastResult then
						local position = raycastResult.Position
						local clone4 = skillX.Ground_Ray2:Clone()
						clone4.Anchored = true
						clone4.CanCollide = false
						clone4.Transparency = 1
						clone4.CFrame = CFrame.new(position + Vector3.new(0, clone4.Size.Y / 2, 0)) * CFrame.Angles(
							0,
							math.rad(clone3.Orientation.Y),
							0
						)
						clone4.Parent = effects
						Emit(clone4)
						task.delay(2, function()
							for _, emitter in pairs(clone4:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end
						end)
						_G.PU:Dust(clone4, 4)
					end
				end)
			end

			local function DragonCast(child)
				local startCF = child:GetAttribute("StartCF")
				local endCF = child:GetAttribute("EndCF")
				local speed = child:GetAttribute("Speed")
				local clone2 = skillX.Step2:Clone()
				SetupPart(clone2)
				clone2.CFrame = startCF * CFrame.new(0, 10, -50)
				clone2.Parent = effects
				_G.PU:Dust(clone2, 5)
				Emit(clone2)
				local clone3 = skillZ.Pteradragon:Clone()
				clone3:ScaleTo(1.057)
				clone3:PivotTo(clone2.CFrame * CFrame.new(0, 5, 0))
				clone3.Parent = effects
				_G.PU:Dust(clone3, 5)
				TweenService:Create(
					clone3.RootPart,
					TweenInfo.new(speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						CFrame = endCF
					}
				):Play()
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://71053127022066",
					Volume = 0.5
				})
				_G.PU:Dust(sound, 5)
				sound.Parent = rootPart
				sound:Play()
				task.wait(speed)

				if (localPlayer.Character.HumanoidRootPart.Position - endCF.Position).Magnitude < 150 then
					Motion:Shake("Rise")
				end

				for _, effect in pairs(clone3:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				for _, part in pairs(clone3:GetDescendants()) do
					if part:IsA("MeshPart") then
						part.Transparency = 1
					end
				end

				local clone4 = skillX.Dragon_Exp:Clone()
				SetupPart(clone4)
				clone4.CFrame = CFrame.new(endCF.Position) * CFrame.new(0, 20, 0)
				clone4.Parent = effects
				_G.PU:Dust(clone4, 8)
				Emit(clone4)
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://70639980849549",
					Volume = 0.5
				})
				_G.PU:Dust(sound2, 5)
				sound2.Parent = rootPart
				sound2:Play()
				local v4 = endCF.Position + createVector(0, 10, 0)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				local raycastResult = workspace:Raycast(v4, createVector(0, -40, 0), raycastParams)

				if raycastResult then
					local position = raycastResult.Position
					local clone5 = skillX.Ground_Ray:Clone()
					clone5.Anchored = true
					clone5.CanCollide = false
					clone5.Transparency = 1
					clone5.CFrame = CFrame.new(position + Vector3.new(0, clone5.Size.Y / 2, 0)) * CFrame.Angles(
						0,
						math.rad(clone4.Orientation.Y),
						0
					)
					clone5.Parent = effects
					Emit(clone5)
					task.delay(2, function()
						for _, emitter in pairs(clone5:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end)
					_G.PU:Dust(clone5, 4)
				end

				task.spawn(function()
					local v5 = Scheduler.Repeat(1, 10)
					v5:Instant()
					v5:OnStep(function(_)
						local clone5 = skillX.PartCurve:Clone()
						SetupPart(clone5)
						clone5.CFrame = clone4.CFrame
						clone5.Parent = effects
						local v6 = clone4.Position + createVector(0, -35, 0)
						local v7 = v6 + Vector3.new(math.random(-70, 70), math.random(1, 100), math.random(-70, 70))

						local function getRandomMiddle(p, p2)
							local v8 = math.random(40, 60) / 100
							local v9 = math.random(-100, 100)
							local v10 = math.random(-60, 60)
							local v11 = math.random(-50, 50)
							return p:Lerp(p2, v8) + Vector3.new(v9, v10, v11)
						end

						local randomMiddle = getRandomMiddle(v6, v7)
						local v8 = Bezier.new(v6, randomMiddle, v7)
						task.spawn(function()
							local v9 = Scheduler.Repeat(1, 45)
							v9:Wait()
							v9:OnStep(function(p)
								local v10 = v8:Get(p / 45)
								v8:Get((math.min((p + 1) / 45, 1)))
								clone5.CFrame = CFrame.new(v10)
							end)
							v9:Execute()
						end)
						task.spawn(function()
							task.wait(0.8)

							for _, emitter in pairs(clone5:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end
						end)
						_G.PU:Dust(clone5, 3)
					end)
					v5:Execute()
				end)
				task.spawn(function()
					local v5 = Scheduler.Repeat(1, 4)
					v5:Instant()
					v5:OnStep(function(_)
						local clone5 = skillX.PartDrop:Clone()
						clone5.Anchored = false
						clone5.CanCollide = false
						clone5.CollisionGroup = "Effect"
						clone5.Transparency = 1
						clone5.CFrame = clone4.CFrame
						clone5.Parent = effects
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.Velocity = Vector3.new(
							math.random(-60, 60),
							math.random(40, 150),
							math.random(-70, 60)
						)
						bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
						bodyVelocity.Parent = clone5
						_G.PU:Dust(clone5, 5)
						_G.PU:Dust(bodyVelocity, 0.1)
						local clone6 = skillX.PartDrop2:Clone()
						clone6.Anchored = false
						clone6.CanCollide = false
						clone6.CollisionGroup = "Effect"
						clone6.Transparency = 1
						clone6.CFrame = clone4.CFrame
						clone6.Parent = effects
						local bodyVelocity2 = Instance.new("BodyVelocity")
						bodyVelocity2.Velocity = Vector3.new(
							math.random(-60, 60),
							math.random(40, 150),
							math.random(-70, 60)
						)
						bodyVelocity2.MaxForce = createVector(1000000, 1000000, 1000000)
						bodyVelocity2.Parent = clone6
						_G.PU:Dust(clone6, 5)
						_G.PU:Dust(bodyVelocity2, 0.1)
						task.spawn(function()
							task.wait(1.5)

							for _, emitter in pairs(clone5:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end

							for _, emitter in pairs(clone6:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end
						end)
					end)
					v5:Execute()
				end)
			end

			local childAddedConnection = nil
			childAddedConnection = skillFolder.ChildAdded:Connect(function(child)
				DragonCast(child)
				childAddedConnection:Disconnect()
			end)
			skillFolder2.ChildAdded:Connect(function(child)
				CreateDragon(child)
			end)
			local lastTime = tick()
			local v4 = true
			local clone2 = nil
			task.spawn(function()
				if localPlayer == v then
					clone2 = skillX.CameraFX:Clone()
					SetupPart(clone2)
					clone2.Parent = effects
					FastRenderer.new({
						Time = 10
					}, function()
						if not (clone2 and clone2.Parent and v4) then
							return true
						end

						clone2.CFrame = currentCamera.CFrame
					end)
				end
			end)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://91390506703669",
				Volume = 0.5
			})
			_G.PU:Dust(sound, 5)
			sound.Parent = rootPart
			sound:Play()
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://139142009146966",
				Volume = 0.5,
				Looped = true
			})
			_G.PU:Dust(sound2, 15)
			sound2.Parent = rootPart
			sound2:Play()
			local v5 = Scheduler.new(10)
			v5:OnStep(function()
				if not chargeFolder:IsDescendantOf(character) then
					v5:Destroy()
					return
				end

				if clone and clone.Parent then
					clone.CFrame = rootPart.CFrame * CFrame.new(0, 7, -5)
				end

				if tick() - lastTime > 0.1 then
					lastTime = tick()

					if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 150 then
						Motion:Shake("Rise")
					end
				end
			end)
			v5:Execute()

			if sound2 and sound2.Parent then
				TweenService:Create(sound2, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()
				_G.PU:Dust(sound2, 1)
			end

			task.delay(1, function()
				v4 = nil
			end)

			if clone2 and clone2.Parent then
				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				_G.PU:Dust(clone2, 2)
			end

			if clone and clone.Parent then
				_G.PU:Dust(clone, 2)

				for _, effect in pairs(clone:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = false
					end
				end
			end

			if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 150 then
				Motion:Shake("Rise")
			end
		elseif mode == "OFA Z" then
			local startCF = v3.StartCF
			local rootPart = v3.RootPart
			local humanoid = v3.Humanoid
			local skillZ = ReplicatedStorage.Chest.Etc.OFA.SkillZ

			if localPlayer == v then
				_G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = "rbxassetid://88940688465947"
				})
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Velocity = Vector3.new()
				bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
				bodyVelocity.Parent = rootPart
				_G.PU:Dust(bodyVelocity, 1.3)
				local bodyGyro = Instance.new("BodyGyro")
				bodyGyro.MaxTorque = createVector(1e999, 1e999, 1e999)
				bodyGyro.P = 20000
				bodyGyro.CFrame = startCF
				bodyGyro.Parent = rootPart
				_G.PU:Dust(bodyGyro, 1.3)
				local clone = skillZ.CameraFX:Clone()
				SetupPart(clone)
				clone.Parent = effects

				for _, emitter in pairs(clone:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
					emitter.Color = ColorSequence.new(color)
				end

				task.spawn(function()
					FastRenderer.new({
						Time = 3
					}, function(_)
						if clone and clone.Parent then
							clone.CFrame = currentCamera.CFrame
						else
							return true
						end
					end)
				end)
				task.delay(1, function()
					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)
				_G.PU:Dust(clone, 5)
			end

			local clone = skillZ.Charge:Clone()
			SetupPart(clone)
			clone.CFrame = rootPart.CFrame * CFrame.new(0, -3, 0)
			clone.Parent = effects
			_G.PU:Dust(clone, 5)

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
				emitter.Color = ColorSequence.new(color)
			end

			task.spawn(function()
				local v4 = Scheduler.Repeat(1, 10)
				v4:Wait(0.1)
				v4:OnStep(function(_)
					if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 150 then
						Motion:Shake("Rise")
					end

					local clone2 = skillZ.Glass:Clone()
					clone2.Size = createVector(200, 200, 200)
					clone2.Anchored = true
					clone2.CanCollide = false
					clone2.CFrame = rootPart.CFrame
					clone2.Parent = effects
					TweenService:Create(
						clone2,
						TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(1, 1, 1)
						}
					):Play()
					local highlight = Instance.new("Highlight")
					highlight.FillTransparency = 1
					highlight.OutlineTransparency = 1
					highlight.Parent = clone2
					_G.PU:Dust({ clone2, highlight }, 0.3)
				end)
				v4:Execute()
			end)
			task.spawn(function()
				local v4 = Scheduler.Repeat(1, 20)
				v4:Wait(0.05)
				v4:OnStep(function(_)
					local clone2 = skillZ.PartTrail:Clone()
					SetupPart(clone2)
					clone2.CFrame = rootPart.CFrame
					clone2.Parent = effects

					for _, trail in pairs(clone2:GetDescendants()) do
						if not trail:IsA("Trail") then
							continue
						end

						local color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
						trail.Color = ColorSequence.new(color)
					end

					local v5 = rootPart.CFrame * CFrame.new(
						math.random(-100, 100),
						math.random(-100, 100),
						math.random(-100, 100)
					)
					local v6 = v5 * CFrame.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
					local cFrame = rootPart.CFrame
					local v7 = Bezier.new(v5.Position, v6.Position, cFrame.Position)
					task.spawn(function()
						local v8 = Scheduler.Repeat(1, 20)
						v8:Wait()
						v8:Instant()
						v8:OnStep(function(p)
							local v9 = v7:Get(p / 20)
							local v10 = v7:Get((p + 1) / 20)
							clone2.CFrame = CFrame.new(v9, v10)
						end)
						v8:Execute()
					end)
					_G.PU:Dust(clone2, 5)
				end)
				v4:Execute()
			end)
			task.delay(0.6, function()
				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				local clone2 = skillZ.Step1:Clone()
				SetupPart(clone2)
				clone2.CFrame = startCF * CFrame.new(0, 45, -175)
				clone2.Parent = effects
				_G.PU:Dust(clone2, 5)

				for _, emitter in pairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
					emitter.Color = ColorSequence.new(color)
				end

				task.delay(0.3, function()
					for _, emitter in pairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)
				task.delay(0.3, function()
					if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 200 then
						_G.CameraShake:ShakeOnce(8, 14, 0, 0.33, createVector(0, 0, -1))
					end

					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://87610143168846",
						Volume = 3
					})
					_G.PU:Dust(sound, 3.5)
					sound.Parent = rootPart
					sound:Play()
					local clone3 = skillZ.Step2:Clone()
					SetupPart(clone3)
					clone3.CFrame = startCF * CFrame.new(0, 45, -175)
					clone3.Parent = effects

					for _, emitter in pairs(clone3:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
						emitter.Color = ColorSequence.new(color)
					end

					Emit(clone3)
					_G.PU:Dust(clone3, 5)
					task.spawn(function()
						local v4 = Scheduler.Repeat(1, 10)
						v4:Instant()
						v4:OnStep(function()
							local clone4 = skillZ.PartCurve:Clone()
							SetupPart(clone4)
							clone4.CFrame = clone3.CFrame
							clone4.Parent = effects

							for _, emitter in pairs(clone4:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								local color = Color3.fromRGB(
									math.random(0, 255),
									math.random(0, 255),
									math.random(0, 255)
								)
								emitter.Color = ColorSequence.new(color)
							end

							local v5 = clone3.Position + Vector3.new(
								math.random(-100, 100),
								math.random(-40, 25),
								math.random(-150, 150)
							)
							local v6 = v5 + Vector3.new(
								math.random(-150, 150),
								math.random(1, 70),
								math.random(-200, 200)
							)

							local function getRandomMiddle(p, p2)
								local v7 = math.random(40, 60) / 100
								local v8 = math.random(-100, 100)
								local v9 = math.random(-60, 60)
								local v10 = math.random(-100, 100)
								return p:Lerp(p2, v7) + Vector3.new(v8, v9, v10)
							end

							local randomMiddle = getRandomMiddle(v5, v6)
							local v7 = Bezier.new(v5, randomMiddle, v6)
							task.spawn(function()
								local v8 = Scheduler.Repeat(1, 50)
								v8:Wait()
								v8:Instant()
								v8:OnStep(function(p)
									local v9 = v7:Get(p / 50)
									v7:Get((math.min((p + 1) / 50, 1)))
									clone4.CFrame = CFrame.new(v9)
								end)
								v8:Execute()
							end)
							task.spawn(function()
								task.wait(1)

								for _, emitter in pairs(clone4:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter.Enabled = false
									end
								end
							end)
							_G.PU:Dust(clone4, 3)
						end)
						v4:Execute()
					end)
					task.spawn(function()
						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 200 then
							local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
							colorCorrectionEffect.Parent = Lighting
							colorCorrectionEffect.Name = "ImpactFlash"
							colorCorrectionEffect.Brightness = -0
							colorCorrectionEffect.Contrast = 10
							colorCorrectionEffect.Saturation = -1
							colorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
							colorCorrectionEffect.Enabled = true
							task.wait(0.13)
							colorCorrectionEffect.Enabled = false
							_G.PU:Dust(colorCorrectionEffect, 2)
						end
					end)
					local clone4 = skillZ.Mesh1:Clone()
					clone4.Anchored = true
					clone4.CanCollide = false
					clone4.Transparency = 0.7
					clone4.CFrame = clone3.CFrame * CFrame.new(0, 0, 60) * CFrame.Angles(1.5707963267948966, 0, 0)
					clone4.Parent = effects
					_G.PU:Dust(clone4, 5)
					TweenService:Create(
						clone4,
						TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1,
							CFrame = clone4.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
						}
					):Play()

					for _, part in pairs(clone4:GetDescendants()) do
						if part:IsA("MeshPart") then
							TweenService:Create(
								part,
								TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Transparency = 1,
									CFrame = clone4.CFrame * CFrame.Angles(0, 2.443460952792061, 0)
								}
							):Play()
						end
					end

					local clone5 = skillZ.Mesh2:Clone()
					clone5.Anchored = true
					clone5.CanCollide = false
					clone5.Transparency = 0.7
					clone5.CFrame = clone3.CFrame * CFrame.new(0, 0, -30) * CFrame.Angles(1.5707963267948966, 0, 0)
					clone5.Parent = effects
					_G.PU:Dust(clone5, 5)
					TweenService:Create(
						clone5,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1,
							CFrame = clone5.CFrame * CFrame.Angles(0, -2.6179938779914944, 0)
						}
					):Play()
					local clone6 = skillZ.Mesh3:Clone()
					clone6.Anchored = true
					clone6.CanCollide = false
					clone6.Transparency = 0
					clone6.CFrame = clone3.CFrame * CFrame.new(0, -15, 70)
					clone6.Parent = effects
					_G.PU:Dust(clone6, 5)
					TweenService:Create(
						clone6,
						TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 0, 300),
							CFrame = clone6.CFrame * CFrame.new(0, 0, -150)
						}
					):Play()
					task.delay(0.16, function()
						TweenService:Create(
							clone6,
							TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end)
					local clone7 = skillZ.Mesh4:Clone()
					clone7.Anchored = true
					clone7.CanCollide = false
					clone7.Transparency = 0.09
					clone7.CFrame = clone3.CFrame * CFrame.new(0, 0, 20) * CFrame.Angles(1.5707963267948966, 0, 0)
					clone7.Parent = effects
					_G.PU:Dust(clone7, 5)
					TweenService:Create(clone7, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Transparency = 1,
						Size = createVector(161.334, 250, 164.762),
						CFrame = clone7.CFrame * CFrame.Angles(0, -2.6179938779914944, 0)
					}):Play()
					local clone8 = skillZ.Mesh5:Clone()
					clone8.Anchored = true
					clone8.CanCollide = false
					clone8.Transparency = 0.09
					clone8.CFrame = clone3.CFrame * CFrame.new(0, 0, 50) * CFrame.Angles(1.5707963267948966, 0, 0)
					clone8.Parent = effects
					_G.PU:Dust(clone8, 5)
					TweenService:Create(clone8, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Transparency = 1,
						Size = createVector(161.334, 250, 164.762),
						CFrame = clone8.CFrame * CFrame.Angles(0, -2.6179938779914944, 0)
					}):Play()
				end)
			end)
		elseif mode == "OFA X" then
			local startCF = v3.StartCF
			local rootPart = v3.RootPart
			local humanoid = v3.Humanoid
			local skillX = ReplicatedStorage.Chest.Etc.OFA.SkillX

			if localPlayer == v then
				_G.PU.PlayOneShotAnim({
					Animator = humanoid,
					Animation = "rbxassetid://99552816587010"
				})
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Velocity = Vector3.new()
				bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
				bodyVelocity.Parent = rootPart
				_G.PU:Dust(bodyVelocity, 1.3)
				local bodyGyro = Instance.new("BodyGyro")
				bodyGyro.MaxTorque = createVector(0, 1e999, 0)
				bodyGyro.P = 20000
				bodyGyro.CFrame = startCF
				bodyGyro.Parent = rootPart
				_G.PU:Dust(bodyGyro, 1.3)
				local clone = skillX.CameraFX:Clone()
				SetupPart(clone)
				clone.Parent = effects

				for _, emitter in pairs(clone:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
					emitter.Color = ColorSequence.new(color)
				end

				task.spawn(function()
					FastRenderer.new({
						Time = 3
					}, function(_)
						if clone and clone.Parent then
							clone.CFrame = currentCamera.CFrame
						else
							return true
						end
					end)
				end)
				task.delay(1, function()
					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end)
				_G.PU:Dust(clone, 5)
			end

			local clone = skillX.Charge:Clone()
			SetupPart(clone)
			clone.CFrame = startCF * CFrame.new(0, -3, 0)
			clone.Parent = effects
			_G.PU:Dust(clone, 5)

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
				emitter.Color = ColorSequence.new(color)
			end

			task.spawn(function()
				local v4 = Scheduler.Repeat(1, 13)
				v4:Wait(0.1)
				v4:OnStep(function(_)
					if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 150 then
						Motion:Shake("Rise")
					end

					local clone2 = skillX.Glass:Clone()
					clone2.Size = createVector(200, 200, 200)
					clone2.Anchored = true
					clone2.CanCollide = false
					clone2.CFrame = startCF
					clone2.Parent = effects
					TweenService:Create(
						clone2,
						TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(1, 1, 1)
						}
					):Play()
					local highlight = Instance.new("Highlight")
					highlight.FillTransparency = 1
					highlight.OutlineTransparency = 1
					highlight.Parent = clone2
					_G.PU:Dust({ clone2, highlight }, 0.3)
				end)
				v4:Execute()
			end)
			task.spawn(function()
				local v4 = Scheduler.Repeat(1, 20)
				v4:Wait(0.05)
				v4:OnStep(function(_)
					local clone2 = skillX.PartTrail:Clone()
					SetupPart(clone2)
					clone2.CFrame = startCF
					clone2.Parent = effects

					for _, trail in pairs(clone2:GetDescendants()) do
						if not trail:IsA("Trail") then
							continue
						end

						local color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
						trail.Color = ColorSequence.new(color)
					end

					local v5 = startCF * CFrame.new(
						math.random(-100, 100),
						math.random(-100, 100),
						math.random(-100, 100)
					)
					local v6 = v5 * CFrame.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
					local v8 = Bezier.new(v5.Position, v6.Position, startCF.Position)
					task.spawn(function()
						local v9 = Scheduler.Repeat(1, 20)
						v9:Wait()
						v9:Instant()
						v9:OnStep(function(p)
							local v10 = v8:Get(p / 20)
							local v11 = v8:Get((p + 1) / 20)
							clone2.CFrame = CFrame.new(v10, v11)
						end)
						v9:Execute()
					end)
					_G.PU:Dust(clone2, 5)
				end)
				v4:Execute()
			end)
			task.spawn(function()
				local clone2 = skillX.PartTrail2:Clone()
				SetupPart(clone2)
				clone2.CFrame = startCF
				clone2.Parent = effects
				_G.PU:Dust(clone2, 5)

				for _, trail in pairs(clone2:GetDescendants()) do
					if not trail:IsA("Trail") then
						continue
					end

					local color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
					trail.Color = ColorSequence.new(color)
				end

				local clone3 = skillX.PartTrail3:Clone()
				SetupPart(clone3)
				clone3.CFrame = startCF
				clone3.Parent = effects
				_G.PU:Dust(clone3, 5)

				for _, trail in pairs(clone3:GetDescendants()) do
					if not trail:IsA("Trail") then
						continue
					end

					local color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
					trail.Color = ColorSequence.new(color)
				end

				local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
					clone2.CFrame *= CFrame.Angles(0, -0.4487989505128276 * dt * 30, 0)
					clone3.CFrame = clone2.CFrame * CFrame.Angles(0, -0.4487989505128276 * dt * 30, 0)
				end)
				task.delay(1.3, function()
					renderSteppedConnection:Disconnect()
				end)
			end)
			task.delay(0.7, function()
				if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 200 then
					_G.CameraShake:ShakeOnce(8, 14, 0, 0.33, createVector(0, 0, -1))
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
					colorCorrectionEffect.Parent = Lighting
					colorCorrectionEffect.Name = "ImpactFlash"
					colorCorrectionEffect.Brightness = -0
					colorCorrectionEffect.Contrast = 10
					colorCorrectionEffect.Saturation = -1
					colorCorrectionEffect.TintColor = Color3.fromRGB(255, 255, 255)
					colorCorrectionEffect.Enabled = true
					task.wait(0.1)
					colorCorrectionEffect.Enabled = false
					_G.PU:Dust(colorCorrectionEffect, 2)
				end

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				local clone2 = skillX.Step1:Clone()
				SetupPart(clone2)
				clone2.CFrame = startCF * CFrame.new(0, 170, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone2.Parent = effects
				Emit(clone2)

				for _, emitter in pairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
					emitter.Color = ColorSequence.new(color)
				end

				_G.PU:Dust(clone2, 5)
				local clone3 = skillX.Mesh1:Clone()
				clone3.Anchored = true
				clone3.CanCollide = false
				clone3.Transparency = 0.7
				clone3.Position = clone2.Position + createVector(0, 120, 0)
				clone3.Parent = effects
				_G.PU:Dust(clone3, 5)
				TweenService:Create(
					clone3,
					TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1,
						CFrame = clone3.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
					}
				):Play()

				for _, part in pairs(clone3:GetDescendants()) do
					if part:IsA("MeshPart") then
						TweenService:Create(
							part,
							TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 1,
								CFrame = clone3.CFrame * CFrame.Angles(0, 2.443460952792061, 0)
							}
						):Play()
					end
				end

				local clone4 = skillX.Mesh2:Clone()
				clone4.Anchored = true
				clone4.CanCollide = false
				clone4.Transparency = 0.7
				clone4.Position = clone2.Position + createVector(0, -55, 0)
				clone4.Parent = effects
				_G.PU:Dust(clone4, 5)
				TweenService:Create(
					clone4,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1,
						CFrame = clone4.CFrame * CFrame.Angles(0, -2.6179938779914944, 0)
					}
				):Play()
				local clone5 = skillX.Mesh3:Clone()
				clone5.Anchored = true
				clone5.CanCollide = false
				clone5.Transparency = 0
				clone5.Position = clone2.Position + createVector(0, 0, 0)
				clone5.Parent = effects
				_G.PU:Dust(clone5, 5)
				TweenService:Create(clone5, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Size = createVector(0, 600, 0),
					CFrame = clone5.CFrame * CFrame.new(0, -300, 0)
				}):Play()
				task.delay(0.16, function()
					TweenService:Create(clone5, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end)
				local clone6 = skillX.Mesh4:Clone()
				clone6.Anchored = true
				clone6.CanCollide = false
				clone6.Transparency = 0.09
				clone6.Position = clone2.Position + createVector(0, -35, 0)
				clone6.Parent = effects
				_G.PU:Dust(clone6, 5)
				TweenService:Create(clone6, TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Transparency = 1,
					Size = createVector(161.334, 250, 164.762),
					CFrame = clone6.CFrame * CFrame.Angles(0, -2.6179938779914944, 0)
				}):Play()
				local clone7 = skillX.Mesh5:Clone()
				clone7.Anchored = true
				clone7.CanCollide = false
				clone7.Transparency = 0.09
				clone7.Position = clone2.Position + createVector(0, -30, 0)
				clone7.Parent = effects
				_G.PU:Dust(clone7, 5)
				TweenService:Create(clone7, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					Transparency = 1,
					Size = createVector(161.334, 250, 164.762),
					CFrame = clone7.CFrame * CFrame.Angles(0, -2.6179938779914944, 0)
				}):Play()
				local clone8 = skillX.PartTrail4:Clone()
				SetupPart(clone8)
				clone8.Position = clone2.Position
				clone8.Parent = effects
				_G.PU:Dust(clone8, 5)

				for _, trail in pairs(clone8:GetDescendants()) do
					if not trail:IsA("Trail") then
						continue
					end

					local color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
					trail.Color = ColorSequence.new(color)
				end

				TweenService:Create(clone8, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					CFrame = clone8.CFrame * CFrame.new(0, 200, 0) * CFrame.Angles(0, 3.141592653589793, 0)
				}):Play()
				local clone9 = skillX.PartTrail4:Clone()
				SetupPart(clone9)
				clone9.Position = clone2.Position
				clone9.Parent = effects
				_G.PU:Dust(clone9, 5)

				for _, trail in pairs(clone9:GetDescendants()) do
					if not trail:IsA("Trail") then
						continue
					end

					local color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
					trail.Color = ColorSequence.new(color)
				end

				TweenService:Create(clone9, TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
					CFrame = clone9.CFrame * CFrame.new(0, -130, 0) * CFrame.Angles(0, -3.141592653589793, 0)
				}):Play()
				task.spawn(function()
					local v4 = Scheduler.Repeat(1, 15)
					v4:Instant()
					v4:OnStep(function()
						local clone10 = skillX.PartCurve:Clone()
						SetupPart(clone10)
						clone10.CFrame = clone2.CFrame
						clone10.Parent = effects

						for _, emitter in pairs(clone10:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
							emitter.Color = ColorSequence.new(color)
						end

						local v5 = clone2.Position + Vector3.new(
							math.random(-100, 100),
							math.random(-40, 25),
							math.random(-150, 150)
						)
						local v6 = v5 + Vector3.new(math.random(-70, 70), math.random(-200, 300), math.random(-70, 70))

						local function getRandomMiddle(p, p2)
							local v7 = math.random(40, 60) / 100
							local v8 = math.random(-100, 100)
							local v9 = math.random(-60, 60)
							local v10 = math.random(-100, 100)
							return p:Lerp(p2, v7) + Vector3.new(v8, v9, v10)
						end

						local randomMiddle = getRandomMiddle(v5, v6)
						local v7 = Bezier.new(v5, randomMiddle, v6)
						task.spawn(function()
							local v8 = Scheduler.Repeat(1, 50)
							v8:Wait()
							v8:Instant()
							v8:OnStep(function(p)
								local v9 = v7:Get(p / 50)
								v7:Get((math.min((p + 1) / 50, 1)))
								clone10.CFrame = CFrame.new(v9)
							end)
							v8:Execute()
						end)
						task.spawn(function()
							task.wait(1)

							for _, emitter in pairs(clone10:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end
						end)
						_G.PU:Dust(clone10, 3)
					end)
					v4:Execute()
				end)
				task.spawn(function()
					local v4 = Scheduler.Repeat(1, 15)
					v4:Instant()
					v4:OnStep(function(_)
						local clone10 = skillX.PartDrop:Clone()
						clone10.Anchored = false
						clone10.CanCollide = false
						clone10.CollisionGroup = "Effect"
						clone10.Transparency = 1
						clone10.Position = clone2.Position + Vector3.new(
							math.random(-20, 20),
							-170,
							math.random(-20, 20)
						)
						clone10.Parent = effects

						for _, effect in pairs(clone10:GetDescendants()) do
							if not (effect:IsA("Trail") or effect:IsA("ParticleEmitter")) then
								continue
							end

							local color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
							effect.Color = ColorSequence.new(color)
						end

						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.Velocity = Vector3.new(
							math.random(-200, 200),
							math.random(100, 500),
							math.random(-200, 200)
						)
						bodyVelocity.MaxForce = createVector(1000000, 1000000, 1000000)
						bodyVelocity.Parent = clone10
						_G.PU:Dust(clone10, 5)
						_G.PU:Dust(bodyVelocity, 0.1)
						task.spawn(function()
							task.wait(0.9)

							for _, emitter in pairs(clone10:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = false
								end
							end
						end)
					end)
					v4:Execute()
				end)
			end)
		elseif mode == "Pickup Egg" then
			local effects2 = workspace.Effects
			local easterEgg = ReplicatedStorage.Chest.Etc.EasterEgg
			local mainEgg = v3.MainEgg
			local rarity = v3.Rarity
			local rootPart = v3.RootPart
			local experience = v3.Experience
			local pivot = mainEgg:GetPivot()
			local cframe = CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			local v4 = rootPart.CFrame * cframe
			local position = pivot.Position
			local position2 = v4.Position
			local v5 = rarity == "Mythic"
			local soundId = rarity == "Uncommon" and "rbxassetid://119342251139315" or rarity == "Mythic" and "rbxassetid://94971922347527" or "rbxassetid://89926981147331"
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = soundId,
				Volume = 1
			})
			_G.PU:Dust(sound, 5)
			sound.Parent = rootPart
			sound:Play()
			local clone = mainEgg:Clone()

			for _, part in pairs(clone:GetChildren()) do
				if not part:IsA("BasePart") then
					part:Destroy()
				end
			end

			clone:PivotTo(pivot)
			clone.Parent = effects2
			_G.PU:Dust(clone, 5)
			local clone2 = easterEgg[rarity].trail:Clone()
			clone2.CFrame = pivot
			clone2.Parent = effects2
			_G.PU:Dust(clone2, 2)
			wait(0.25)
			local color = Color3.fromRGB(255, 205, 134)

			if rarity == "Normal" then
				color = Color3.fromRGB(108, 167, 255)
			end

			local highlight = Instance.new("Highlight")
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillColor = color
			highlight.OutlineColor = color
			highlight.FillTransparency = 0
			highlight.OutlineTransparency = 0
			highlight.Parent = clone
			_G.PU:Dust(highlight, 5)
			task.spawn(function()
				wait()
				TweenService:Create(highlight, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					FillTransparency = 1
				}):Play()
			end)
			local colorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 58, 61)),
				ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 220, 78)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 255, 67)),
				ColorSequenceKeypoint.new(0.75, Color3.fromRGB(60, 161, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(185, 139, 255))
			})
			PeodizService.HeartbeatWait({
				Time = 0.6
			}, function(p)
				v4 = rootPart.CFrame * cframe
				position2 = v4.Position
				local v7 = 1 - (1 - p) ^ 3
				local lerped = position:Lerp(position2, v7)
				local v8 = 48 * p * (1 - p)
				local v9 = pivot:Lerp(v4, v7) - pivot:Lerp(v4, v7).Position
				clone:SetPrimaryPartCFrame(v9 + lerped + Vector3.new(0, v8, 0))
				clone2.CFrame = v9 + lerped + Vector3.new(0, v8, 0)

				if v5 then
					local v10 = evaluateColorSequence(colorSequence, p)
					highlight.FillColor = v10
					highlight.OutlineColor = v10
					clone2.Trail.Color = ColorSequence.new(v10)
					clone2.Specs_3.Color = ColorSequence.new(v10)
				end
			end)

			if rarity ~= "Normal" then
				PolyLib:Active(clone2, false)
			end

			clone:Destroy()
			local clone3 = easterEgg[rarity].obtain:Clone()
			clone3.CFrame = CFrame.new(v4.p)
			clone3.Parent = effects2
			_G.PU:Dust(clone3, 2)
			PolyLib:ParticleHandler(clone3)
			clone3.egg.Position = createVector(0, 2, 0)
			wait()
			TweenService:Create(
				clone3.egg,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Position = createVector(0, 6, 0)
				}
			):Play()
			wait(0.05)
			TweenService:Create(
				clone3.egg.Attachment,
				TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Position = createVector(0, -1.5, 0)
				}
			):Play()
			task.spawn(function()
				local clone4 = easterEgg[rarity].score:Clone()
				clone4.CFrame = CFrame.new(v4.p)
				clone4.Parent = effects2
				_G.PU:Dust(clone4, 3)
				local billboardGui = clone4.BillboardGui
				local textLabel = billboardGui.Frame.TextLabel
				textLabel.Text = `+{experience}`
				textLabel.TextLabel.Text = `+{experience}`
				textLabel.RichText = true
				billboardGui.Size = UDim2.new()
				textLabel.Position = UDim2.new(0, 0, 1, 0)
				TweenService:Create(
					textLabel,
					TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Position = UDim2.new(0, 0, 0, 0)
					}
				):Play()
				wait(0.05)
				TweenService:Create(
					billboardGui,
					TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						Size = UDim2.new(4, 0, 2, 0)
					}
				):Play()
				wait(0.5)
				TweenService:Create(textLabel, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					TextTransparency = 1
				}):Play()
				TweenService:Create(
					textLabel.UIStroke,
					TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
				TweenService:Create(
					textLabel.TextLabel,
					TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						TextTransparency = 1
					}
				):Play()
			end)
		end
	end
end