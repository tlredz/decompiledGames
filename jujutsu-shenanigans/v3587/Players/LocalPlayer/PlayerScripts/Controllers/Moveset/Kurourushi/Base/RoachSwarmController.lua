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
local controller = Knit.CreateController({
	Name = "RoachSwarmController"
})

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function quadraticBezier(p, p2, p3, p4)
	local v4 = p + (p2 - p) * p4
	return v4 + (p2 + (p3 - p2) * p4 - v4) * p4
end

local function cubicBezier(position, p, p2, p3, p4)
	local v4 = position + (p - position) * p4
	local v5 = p + (p2 - p) * p4
	local v6 = p2 + (p3 - p2) * p4
	local v7 = v4 + (v5 - v4) * p4
	return v7 + (v5 + (v6 - v5) * p4 - v7) * p4
end

function controller.KnitStart(_)
	local v4 = {
		Hit = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Kurourushi.RoachSwarm.Hit, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Kurourushi.RoachExplosion:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(0.4)
			Debris:AddItem(model, 0.1)
			clone.Parent = workspace.Effects
			clone.CFrame = CFrame.new(humanoidRootPart.Position)
			v2:PlayParticles(clone)
			Debris:AddItem(clone, 3)
			v2:Flash(instance2, Color3.new(1, 1, 1))

			if instance == localPlayer.Character or instance2 == localPlayer.Character then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.MediumHit)
			end
		end,
		Swarm1 = function(instance, p, p2, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local cFrame = p * CFrame.new(0, 0, 2)
			local v6 = cFrame * CFrame.new(-10, 0, 15)
			local v7 = cFrame * CFrame.new(0, 0, -35)
			local _ = cFrame.Position
			local position = v6.Position
			local position2 = v7.Position

			if p2 == nil then
				v2:PlaySound(sounds.Kurourushi.RoachSwarm.Swarm1, humanoidRootPart, game.SoundService.Effect)
			else
				local v8 = cFrame * CFrame.new(0, -8, 0)
				local v9 = cFrame * CFrame.new(0, -5, -40)
				local _ = cFrame.Position
				position = v8.Position
				position2 = v9.Position
				v2:PlaySound(sounds.Kurourushi.RoachSwarm.Swarm2, humanoidRootPart, game.SoundService.Effect)
			end

			local clone = utils.Kurourushi.Swarm:Clone()
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			clone:SetAttribute("Owner", instance.Name)
			local lastTime = os.clock()
			local preRenderConnection = nil
			local v8 = true
			local now = 0
			preRenderConnection = RunService.PreRender:Connect(function()
				if clone:GetAttribute("Owner") == nil then
					preRenderConnection:Disconnect()
					return
				end

				if v8 == true and instance2.Parent and instance2:GetAttribute("KeepVFX") then
					v8 = false
				end

				local v9 = math.min((os.clock() - lastTime) / 0.5, 1)

				if tick() - now > 0.005 then
					now = tick()

					for _, child in pairs(clone:GetChildren()) do
						child.Size = NumberSequence.new(
							child.Size.Keypoints[1].Value + v9 / 8,
							child.Size.Keypoints[2].Value
						)
					end
				end

				local v10 = humanoidRootPart.CFrame * CFrame.new(0, 0, 2).Position
				local v11 = position
				local v13 = v10 + (v11 - v10) * v9
				local v14 = v13 + (v11 + (position2 - v11) * v9 - v13) * v9
				local v15 = clone
				local v16 = humanoidRootPart.CFrame * CFrame.new(0, 0, 2).Position
				local v17 = position
				local v19 = v9 + 0.01
				local v20 = v16 + (v17 - v16) * v19
				v15.CFrame = CFrame.lookAt(v14, v20 + (v17 + (position2 - v17) * v19 - v20) * v19)

				if v9 >= 1 or instance2.Parent == nil and v8 then
					preRenderConnection:Disconnect()

					for _, child in clone:GetChildren() do
						child.Enabled = false
					end

					task.wait(0.5)
					clone:Destroy()
				end
			end)
		end,
		Swarm2 = function(instance, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Kurourushi.RoachSwarm.SwarmFollowupWhoosh, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Kurourushi.RoachSwarm.SwarmFollowup, humanoidRootPart, game.SoundService.Effect)

			for i = 1, 2 do
				local v5 = i == 2 and 1 or -1
				local cFrame = p * CFrame.new(v5 * 1, 0, 2.5)
				local position = cFrame.Position
				local v6 = p * CFrame.new(v5 * 20, 1.5, 0)
				local v7 = p * CFrame.new(v5 * 20, 3.5, -10)
				local v8 = p * CFrame.new(0, 5, -20)
				local v9 = nil
				local flag = false

				for _, child in pairs(workspace.Effects:GetChildren()) do
					if not (child.Name == "Swarm" and child:GetAttribute("Owner") == instance.Name) then
						continue
					end

					v9 = child
					v9:SetAttribute("Owner", nil)
					cFrame = v9.CFrame
					v6 = cFrame * CFrame.new(v5 * 10, 1.5, 0)
					v7 = cFrame * CFrame.new(v5 * 10, 3.5, -10)
					position = cFrame.Position
					flag = true
					break
				end

				local v11 = v9 or utils.Kurourushi.Swarm:Clone()
				local position2 = v6.Position
				local position3 = v7.Position
				local position4 = v8.Position
				v11.CFrame = cFrame
				v11.Parent = workspace.Effects
				local v12 = 0.5 - (i == 2 and 0.2 or 0)
				local preRenderConnection = nil
				local now2 = 0
				local v13 = os.clock()
				preRenderConnection = RunService.PreRender:Connect(function()
					local value = TweenService:GetValue(
						math.min((os.clock() - v13) / v12, 1),
						Enum.EasingStyle.Cubic,
						Enum.EasingDirection.Out
					)

					if tick() - now2 > 0.005 then
						now2 = tick()

						for i2, child in pairs(v11:GetChildren()) do
							child.Size = NumberSequence.new(
								child.Size.Keypoints[1].Value + value / 4,
								child.Size.Keypoints[2].Value
							)
						end
					end

					local v19, v20

					if flag then
						v19 = cubicBezier(position, position2, position3, position4, value)
						v20 = cubicBezier(position, position2, position3, position4, value + 0.001)
					else
						local v21 = position
						local position5 = position3
						local v24 = v21 + (position5 - v21) * value
						v19 = v24 + (position5 + (position4 - position5) * value - v24) * value
						local v25 = position
						local position6 = position3
						local v28 = value + 0.001
						local v29 = v25 + (position6 - v25) * v28
						v20 = v29 + (position6 + (position4 - position6) * v28 - v29) * v28
					end

					v11.CFrame = CFrame.lookAt(v19, v20)

					if value >= 1 or p2.Parent == nil then
						preRenderConnection:Disconnect()

						for i2, child in v11:GetChildren() do
							child.Enabled = false
						end

						task.wait(v12 + 0.4)
						v11:Destroy()
					end
				end)
				task.wait(0.2)
			end
		end,
		Finisher = function(_, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = nil or utils.Kurourushi.Swarm:Clone()
			v5.CFrame = humanoidRootPart.CFrame
			v5.Parent = workspace.Effects
			local lastTime = tick()
			local preRenderConnection = nil
			local total = 0
			local lastTime2 = tick()
			preRenderConnection = RunService.PreRender:Connect(function(dt)
				local v6 = math.min((tick() - lastTime) / 1.75, 1)
				total += 50 * dt
				local position = humanoidRootPart.Position
				local v7 = math.cos(total) * 3
				local v8 = math.sin(total) * 3
				local v9 = position + Vector3.new(v7, math.sin(total * 0.7) * 3, v8)
				local v10 = total + 50 * dt
				local v11 = math.cos(v10) * 3
				local v12 = math.sin(v10) * 3
				local v13 = position + Vector3.new(v11, math.sin(v10 * 0.7) * 3, v12)
				v5.CFrame = CFrame.lookAt(v9, v13)

				if v6 >= 1 or instance.Parent == nil then
					preRenderConnection:Disconnect()

					for _, child in v5:GetChildren() do
						child.Enabled = false
					end

					task.wait(1.75)
					v5:Destroy()
				end

				if tick() - lastTime2 > 0.25 then
					lastTime2 = tick()
					local v14 = nil

					for _, child in instance:GetChildren() do
						if utils.Damage.Skeleton:FindFirstChild(child.Name) and child.Transparency == 0 then
							v14 = child
						end
					end

					if not v14 then
						return
					end

					v14.Transparency = 1
					local clone = utils.Damage.Skeleton:FindFirstChild(v14.Name):Clone()
					local weld = Instance.new("Weld", clone)
					weld.Part0 = v14
					weld.Part1 = clone
					clone.Parent = v14
					v2:PlaySound(sounds.Megumi.Rabbit.Eat, humanoidRootPart, game.SoundService.Effect)
				end
			end)
			v2:Bleed(instance)
		end,
		Explosion = function(position)
			local clone = utils.Kurourushi.RoachExplosion:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = CFrame.new(position)
			v2:PlayParticles(clone)
			Debris:AddItem(clone, 3)
			v2:PlaySound(sounds.Kurourushi.RoachSwarm.Explosion, clone, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 65 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
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
	v = Knit.GetService("RoachSwarmService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("KurourushiController")
end

return controller