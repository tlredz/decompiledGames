local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
game:GetService("TweenService")
game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback()
		end
	end
end

local function puff(position)
	local clone = script.FPoof:Clone()
	Util.Debris:AddItem(clone, 5)
	clone.Position = position
	clone.Parent = _WorldOrigin

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Parent = clone
		emitter.Enabled = false
	end

	local v = {
		GlowDust = 5,
		LingerSmoke = 4,
		Smoke = 5,
		SpikyShockwave = 1
	}

	for _, child in pairs(clone:GetChildren()) do
		if v[child.Name] then
			child:Emit(v[child.Name])
		end
	end

	local parent = Util.Sound:Play("ShadowAura", position, nil, 1.5 + math.random(-15, 15) / 100, 1)
	local flangeSoundEffect = Instance.new("FlangeSoundEffect")
	flangeSoundEffect.Depth = 1
	flangeSoundEffect.Rate = 10
	flangeSoundEffect.Mix = 0.85
	flangeSoundEffect.Parent = parent
end

local function newCrow(root)
	local position = root.Position + Vector3.new(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3))
	local bezier = {
		position,
		Vector3.new(math.random(-30, 30), math.random(-6, 12), math.random(-30, 30)),
		Vector3.new(math.random(-30, 30), math.random(-6, 12), math.random(-30, 30)),
		root
	}
	Effect.new("Shadow.Crows"):replicate({
		Type = -1,
		Life = 0.5,
		Bezier = bezier,
		Amount = 1
	})
	Effect.new("Shadow.Misc"):replicate({
		Type = 1,
		Position = position
	})
end

return function(instance)
	local stage = instance.Stage or 1

	if stage == 1 then
		local root = instance.Root
		local humanoid = instance.Humanoid
		local holdValue = instance.HoldValue

		if humanoid and root then
			puff(root.Position)
			local diedConnection = nil

			if humanoid then
				diedConnection = humanoid.Died:Connect(function()
					diedConnection:Disconnect()
				end)
			end

			local lastTime = tick()

			local function running()
				return tick() - lastTime < 0.2 or diedConnection and instance.HoldValue and instance.HoldValue.Value == true
			end

			local lastTime2 = tick()
			local lastTime3 = tick()

			while (tick() - lastTime < 0.2 or diedConnection and instance.HoldValue and instance.HoldValue.Value == true) and holdValue.Parent ~= nil and holdValue.Parent.Parent ~= nil and root and humanoid do
				if tick() - lastTime2 > 0.05 then
					newCrow(root)
					lastTime2 = tick()
				end

				if tick() - lastTime3 > 0.15 then
					Util.Sound:Play("WingFlaps", root, nil, 1 + math.random(-15, 15) / 100, 1)
					lastTime3 = tick()
				end

				RunService.RenderStepped:Wait()
			end

			if diedConnection then
				diedConnection:Disconnect()
			end
		end
	else
		local root = stage == 2 and instance.Root

		if root then
			if (root.Position - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
				return
			else
				puff(root.Position)
			end
		end
	end
end