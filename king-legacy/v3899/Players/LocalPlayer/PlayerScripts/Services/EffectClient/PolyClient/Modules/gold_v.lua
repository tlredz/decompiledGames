local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
return function(data, _)
	local localPlayer = game.Players.LocalPlayer

	local function localshake(p)
		if localPlayer == data.plr then
			_G.shake(p)
		end
	end

	local function rangeshake(p, value)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - data.cf.p).Magnitude then
			_G.shake(p)
		end
	end

	local function local_rangeshake(p, value, p2)
		task.spawn(function()
			value = value or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < value then
				_G.shake(p)
			end
		end)
	end

	local _ = data.cf
	PeodizService.ForLoop({
		Step = 7
	}, function(p)
		local v = math.floor(p * 7)
		task.spawn(function()
			local v2 = data.fromcf[v]
			local worldCFrame = data.tocf[v]
			local clone = replicatedStorage.Chest.FruitEffect.Gold.gob:Clone()
			_G.PU:Dust(clone, 3)
			clone.CFrame = CFrame.new(v2.p, worldCFrame.p)
			clone.AT1.WorldCFrame = CFrame.new(v2.p, worldCFrame.p)
			clone.AT2.WorldCFrame = CFrame.new(v2.p, worldCFrame.p)
			clone.explosion.WorldCFrame = CFrame.new(worldCFrame.p)
			clone.Beam.Width0 = 24
			clone.Beam.Width1 = 20
			clone.Parent = workspace.Effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://12764700089",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()
			TweenService:Create(clone.AT2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				WorldCFrame = worldCFrame
			}):Play()
			task.spawn(function()
				wait()
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 300,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://6948300574",
					Volume = 1
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = clone
				sound2:Play()
				TweenService:Create(clone.Beam, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					CurveSize0 = 0,
					CurveSize1 = 0
				}):Play()
				TweenService:Create(clone.Beam, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Width0 = 6,
					Width1 = 4
				}):Play()

				for _, emitter in pairs(clone.explosion:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
					end
				end

				local v4 = 20
				local p2 = worldCFrame.p
				local v5 = "SmallerBump"
				task.spawn(function()
					v4 = v4 or 100

					if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v4 then
						_G.shake(v5)
					end
				end)
			end)
			wait(0.75)

			for _, child in pairs(clone.AT1:GetChildren()) do
				child.Enabled = false
			end

			clone.AT1.spec.Enabled = true
			wait()
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://12764710018",
				Volume = 1
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone
			sound2:Play()
			TweenService:Create(clone.AT1, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				WorldCFrame = worldCFrame
			}):Play()
			clone.Attachment.star:Emit(2)
			clone.Attachment.specsemit:Emit(10)
			wait(0.25)

			if clone:FindFirstChild("AT1") and clone.AT1:FindFirstChild("spec") then
				clone.AT1.spec.Enabled = false
			end
		end)
	end)
	wait()
	wait()
	wait()
	wait()
	wait()
	wait()
	wait()
end