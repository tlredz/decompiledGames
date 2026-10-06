local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local localPlayer = game.Players.LocalPlayer
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local Bezier = require(ReplicatedStorage.Chest.Modules.Bezier)
game:GetService("RunService")
return function(list)
	local _, v, v2, _ = unpack(list)
	local success, result = pcall(function()
		if type(v2) == "table" and v2.LoopDistance then
			return false
		end

		if v then
			return (localPlayer.Character.HumanoidRootPart.Position - v.p).Magnitude > 1000
		end

		return false
	end)

	if success then
		if result then
			return
		end

		local mode = v2.Mode

		if mode == "Seasoned Fishman Z" then
			local rootPart = v2.RootPart
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://129315340713617",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = rootPart
			sound:Play()
			local clone = ReplicatedStorage.Chest.SwordEffect.VillainTrident.SkillZ.Step1:Clone()
			_G.PU:Dust(clone, 2)
			clone.Anchored = true
			clone.CanCollide = false
			clone.Transparency = 1
			clone.CFrame = CFrame.new(rootPart.Position)
			clone.Parent = workspace.Effects
			local lastTime = tick()
			task.spawn(function()
				PeodizService.new({
					Time = 1.5
				}, function(_, p)
					if tick() - lastTime > 1 then
						lastTime = tick()

						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 150 then
							_G.CameraShake:ShakeOnce(0.5, 10, 0, 0.25)
						end
					end

					clone.CFrame *= CFrame.Angles(0, 0.39269908169872414 * p * 60, 0)
				end)

				for _, effect in pairs(clone:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						effect.Enabled = false
					end
				end

				if sound and sound.Parent then
					TweenService:Create(sound, TweenInfo.new(0.5), {
						Volume = 0
					}):Play()
					_G.PU:Dust(sound, 1)
				end
			end)
		elseif mode == "Seasoned Fishman X" then
			local rootPart = v2.RootPart
			local startCF = v2.StartCF
			local endCF = v2.EndCF
			local randomEndPos = v2.RandomEndPos
			local cframe = CFrame.new(endCF.Position)

			local function Emit(folder)
				for _, emitter in pairs(folder:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
					end
				end
			end

			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://74497089419221",
				Volume = 0.25
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = rootPart
			sound:Play()
			local skillX = ReplicatedStorage.Chest.SwordEffect.VillainTrident.SkillX
			local clone = skillX.Step1:Clone()
			clone.Anchored = true
			clone.CanCollide = false
			clone.Transparency = 1
			clone.CFrame = rootPart.CFrame
			clone.Parent = workspace.Effects
			PeoUtils:Dust(clone, 2)
			local clone2 = skillX.Step2:Clone()
			clone2.Anchored = true
			clone2.CanCollide = false
			clone2.Transparency = 1
			clone2.Parent = workspace.Effects
			PeoUtils:Dust(clone2, 2)
			local midpoint = (startCF.Position + cframe.Position) / 2
			local cframe2 = CFrame.new(midpoint, cframe.Position)
			local v4 = cframe2.Position + cframe2.UpVector * 50
			local v5 = Bezier.new(startCF.Position, v4, cframe.Position)
			task.spawn(function()
				PeodizService.ForLoop({
					Step = 60,
					WaitTime = 0.01
				}, function(p)
					local v6 = math.floor(p * 60)
					local v7 = v5:Get(v6 / 60)
					local v8 = v5:Get((v6 + 1) / 60)
					clone.CFrame = CFrame.new(v7, v8)
				end)

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 150 then
					_G.CameraShake:ShakeOnce(2.5, 20, 0, 0.25)
				end

				for i = 1, 3 do
					local clone3 = skillX.Step1:Clone()
					clone3.Anchored = true
					clone3.CanCollide = false
					clone3.Transparency = 1
					clone3.CFrame = cframe
					clone3.Parent = workspace.Effects
					PeoUtils:Dust(clone3, 2)
					local clone4 = clone2:Clone()
					clone4.Parent = workspace.Effects
					PeoUtils:Dust(clone4, 2)
					local position = cframe.Position
					local middlePosC = randomEndPos[i].middlePosC
					local endPosC = randomEndPos[i].endPosC
					local v7 = Bezier.new(position, middlePosC, endPosC)
					local folder = clone3
					task.spawn(function()
						PeodizService.ForLoop({
							Step = 60,
							WaitTime = 0.01
						}, function(p)
							local v9 = math.floor(p * 60)
							local v10 = v7:Get(v9 / 60)
							local v11 = v7:Get((v9 + 1) / 60)
							folder.CFrame = CFrame.new(v10, v11)
						end)

						if (localPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude < 200 then
							_G.CameraShake:ShakeOnce(2, 10, 0, 0.1)
						end

						clone4.CFrame = folder.CFrame
						Emit(clone4)
						local sound2 = PeoUtils.CreateSound({
							RollOffMaxDistance = 500,
							RollOffMinDistance = 50,
							RollOffMode = Enum.RollOffMode.InverseTapered,
							SoundId = "rbxassetid://93084424571127",
							Volume = 0.15
						})
						_G.PU:Dust(sound2, 3)
						sound2.Parent = clone4
						sound2:Play()

						for i2, emitter in pairs(folder:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = false
							end
						end
					end)
				end

				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://74497089419221",
					Volume = 0.75
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = clone2
				sound2:Play()
				clone2.CFrame = clone.CFrame + createVector(0, 4.6, 0)
				Emit(clone2)
			end)
		end
	end
end