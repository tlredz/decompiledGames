local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

function star(p, p2)
	task.spawn(function()
		p = p * CFrame.Angles(
			math.rad((math.random(-10, 10))),
			6.283185307179586 * math.random(),
			(math.rad((math.random(-10, 10))))
		) * CFrame.new(0, 5, -25)
		local clone = replicatedStorage.Chest.SwordEffect.Avalon.star:Clone()
		_G.PU:Dust(clone, 1)
		clone.Parent = workspace.Effects
		clone.CFrame = p * CFrame.new(0, 0, 43)
		clone.Trail.Color = ColorSequence.new(p2)
		clone.Attachment.specs.Color = ColorSequence.new(p2)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://13953400256",
			Volume = 1,
			PlaybackSpeed = 1.15
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		task.spawn(function()
			PeodizService.HeartbeatWait({
				Time = 0.35,
				Tween = {
					EasingStyle = Enum.EasingStyle.Quad,
					EasingDirection = Enum.EasingDirection.Out
				}
			}, function(p3)
				local v = math.floor(p3 * 360)
				clone.CFrame = p * CFrame.Angles(0, math.rad(v * 2), 0) * CFrame.new(0, p3 * -20, (360 - v) / 20 + 25)
			end)
		end)
		wait(0.3)

		if clone and clone:FindFirstChild("Attachment") then
			clone.Attachment.specs.Enabled = false
		end
	end)
end

return function(data, _)
	local localPlayer = game.Players.LocalPlayer

	local function local_rangeshake(p, value, p2)
		task.spawn(function()
			value = value or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < value then
				_G.shake(p)
			end
		end)
	end

	local cf = data.cf
	local value = data.value
	local v = {
		Color3.fromRGB(89, 255, 38),
		Color3.fromRGB(255, 37, 37),
		Color3.fromRGB(37, 113, 255),
		Color3.fromRGB(255, 48, 252),
		Color3.fromRGB(255, 255, 43)
	}
	PeodizService.ForLoop({
		Step = 2
	}, function(p)
		math.floor(p * 2)
	end)

	for i = 0, 2 do
		local v2 = i
		PeodizService.ForLoop({
			Step = 5,
			WaitTime = 0.06666666666666667
		}, function(p)
			local v3 = math.floor(p * 5)
			cf = CFrame.new(value.Value)
			task.spawn(function()
				local cFrame = cf * data.cf2[v2 * 5 + v3]
				local v5 = cFrame * data.cf3[v2 * 5 + v3]
				star(v5 * CFrame.new(0, 50, 0), v[v3])
				wait(0.15)
				local clone = replicatedStorage.Chest.SwordEffect.Avalon.sword:Clone()
				clone.Parent = workspace.Effects
				clone.CFrame = v5 * CFrame.new(0, 70, 0)
				clone.Color = v[v3]
				_G.PU:Dust(clone, 2)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://13953416423",
					Volume = 1,
					PlaybackSpeed = 1.15
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()
				clone.Trail.Color = ColorSequence.new(Color3.fromRGB(), v[v3])
				task.spawn(function()
					wait(1)
					TweenService:Create(
						clone,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end)
				TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					CFrame = clone.CFrame * CFrame.new(0, -60, 0)
				}):Play()
				wait(0.06666666666666667)
				local v6 = 60
				local p2 = cf.p
				local v7 = "SmallBump2"
				task.spawn(function()
					v6 = v6 or 100

					if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v6 then
						_G.shake(v7)
					end
				end)
				local clone2 = replicatedStorage.Chest.SwordEffect.Avalon.rainbow_exp:Clone()
				_G.PU:Dust(clone2, 1.5)
				clone2.CFrame = cFrame
				clone2.Parent = workspace.Effects
				local soundId = math.random(1, 2) == 2 and "rbxassetid://13953485247" or "rbxassetid://13953484111"
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = soundId,
					Volume = 1
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = clone2
				sound2:Play()

				for i2, emitter in pairs(clone2.Attachment:GetChildren()) do
					if not (emitter:IsA("ParticleEmitter") and emitter.Color ~= ColorSequence.new(Color3.fromRGB())) then
						continue
					end

					emitter.Color = ColorSequence.new(v[v3])
				end

				for i2, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)
		end)
	end
end