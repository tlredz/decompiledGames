local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local TweenService = game:GetService("TweenService")
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

	local chargeFolder = data.ChargeFolder
	local ball = data.Ball
	local ball2 = data.Ball2
	local rootPart = data.RootPart
	local char = data.Char
	spawn(function()
		PeodizService.new({
			Time = 15
		}, function()
			if not ball2:IsDescendantOf(workspace.Effects) then
				return true
			end

			ball2.CFrame *= CFrame.Angles(0, 0.1, 0)
		end)
	end)
	spawn(function()
		local clone = replicatedStorage.Chest.FruitEffect.Flame.V2.ChargeVFX2:Clone()
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
			if not chargeFolder:IsDescendantOf(char) then
				return true
			end

			clone.CFrame = CFrame.new(rootPart.Position) * CFrame.new(0, -2.5, 0)
			local cFrame = CFrame.new(ball.Position) * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			local v2 = math.random(60, 80)
			local v3 = math.random(100, 150)
			local clone2 = replicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
			clone2.CastShadow = false
			clone2.Transparency = -1
			clone2.Size = Vector3.new(10, 10, math.random(60, 80))
			clone2.Color = Color3.fromRGB(213, 115, 61)
			clone2.CFrame = cFrame * CFrame.new(0, 0, v3)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Size = Vector3.new(0, 0, v2),
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
end