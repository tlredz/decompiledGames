local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local map = workspace.Map
local _ = Util.Debris
require(game.ReplicatedStorage.FX)
game:GetService("TweenService")
local Players = game:GetService("Players")
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local _ = Players.LocalPlayer
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { map }
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace.Characters }
local FX = require(game.ReplicatedStorage.FX)
local throwablePotionCandyExplosion = FX:Get("ThrowablePotion_CandyExplosion")
local random = Random.new()
local v = {
	ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 0.278431, 0.32549)),
		ColorSequenceKeypoint.new(1, Color3.new(1, 0.278431, 0.32549))
	}),
	ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(0.34902, 1, 0.423529)),
		ColorSequenceKeypoint.new(1, Color3.new(0.34902, 1, 0.423529))
	}),
	ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(0.490196, 0.541176, 1)),
		ColorSequenceKeypoint.new(1, Color3.new(0.490196, 0.541176, 1))
	})
}

local function ParticleState(folder, enabled: boolean)
	local max = 0

	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if enabled == nil then
			if not effect:IsA("ParticleEmitter") then
				continue
			end

			effect:Emit(effect:GetAttribute("EmitCount"))
		else
			effect.Enabled = enabled
		end

		if not effect:IsA("ParticleEmitter") or effect.Lifetime.Max <= max then
			continue
		end

		max = effect.Lifetime.Max
	end

	return max
end

local function Sin(p)
	return (math.sin((math.rad(p))))
end

local function Cos(p)
	return (math.cos((math.rad(p))))
end

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local v2 = {}
return function(data)
	if data.retrieveCandy then
		local v3 = data.retrieveCandy[1]

		if not v3 then
			return
		end

		if v2[data.id] then
			v2[data.id](v3)
		end
	else
		local pos = data.pos
		local normal = data.normal
		local duration = data.duration
		local folder = Instance.new("Folder", _WorldOrigin)
		task.delay(30, function()
			folder:Destroy()
		end)
		folder.Name = "CandyExplosion"
		local clone = throwablePotionCandyExplosion.Spawn:Clone()
		clone.CFrame = CFrame.lookAt(pos, pos + normal) * CFrame.Angles(-1.5707963267948966, 0, 0)
		local part2 = clone.Part2
		part2.CFrame = clone.CFrame * CFrame.new(0, 50, 0)
		local Sound = require(game.ReplicatedStorage.Util.Sound)
		local v3 = { "HalloweenPotions_CandyBomb_Explode_02" }
		Sound:Play(v3[math.random(1, #v3)], part2.Position)
		clone.Parent = folder
		TweenService:Create(part2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = clone.Position
		}):Play()
		TweenService:Create(clone.Beam, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		task.delay(ParticleState(clone) + 0.3, clone.Destroy, clone)
		task.spawn(function()
			for _ = 1, 6 do
				task.spawn(function()
					local clone2 = throwablePotionCandyExplosion.GhostSpawnTrailModel:Clone()
					local ghostTrail = clone2.GhostTrail
					clone2:ScaleTo(random:NextNumber(1, 3))
					local position = pos
					local v5 = pos + Vector3.new(
						random:NextNumber(-51, 51),
						random:NextNumber(-51, 51),
						random:NextNumber(-51, 51)
					)
					local v6 = pos + Vector3.new(
						random:NextNumber(-51, 51),
						random:NextNumber(-51, 51),
						random:NextNumber(-51, 51)
					)
					local position2 = pos + Vector3.new(
						random:NextNumber(-51, 51),
						random:NextNumber(-51, 51),
						random:NextNumber(-51, 51)
					)
					ghostTrail.Position = position
					ghostTrail.Parent = folder

					for i = 0, 1, RunService.Heartbeat:Wait() / random:NextNumber(0.4, 0.7) do
						local v8 = position + (v5 - position) * i
						local v9 = v5 + (v6 - v5) * i
						local v10 = v6 + (position2 - v6) * i
						local v11 = v8 + (v9 - v8) * i
						ghostTrail.Position = v11 + (v9 + (v10 - v9) * i - v11) * i
						task.wait()
					end

					ghostTrail.Position = position2
				end)
				task.wait(random:NextNumber(0.02, 0.06))
			end
		end)
		local clone2 = throwablePotionCandyExplosion.ForcefieldModel:Clone()
		local _ = clone2.Forcefield
		local Sound2 = require(game.ReplicatedStorage.Util.Sound)
		local v4 = { "HalloweenPotions_CandyAura_Loop_01" }
		local v5 = Sound2:Play(v4[math.random(1, #v4)], clone2.PrimaryPart)
		clone2:ScaleTo(0.01)
		clone2:PivotTo(CFrame.lookAt(pos, pos + normal) * CFrame.Angles(-1.5707963267948966, 0, 0))
		clone2.Parent = folder

		for i = 0, 1, RunService.Heartbeat:Wait() / 0.2 do
			clone2:ScaleTo((math.lerp(
				0.01,
				1,
				(TweenService:GetValue(i, Enum.EasingStyle.Circular, Enum.EasingDirection.Out))
			)))
			task.wait()
		end

		clone2:ScaleTo(1)

		for i = 1, 4 do
			local v6 = i * 90
			local total = 0
			local number = random:NextNumber(0, 360)
			local number2 = random:NextNumber(1700, 4700)
			local number3 = random:NextNumber(1, 2)
			local clone3 = throwablePotionCandyExplosion.Trail:Clone()
			clone3.CFrame = CFrame.lookAt(pos, pos + normal) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(
				math.sin((math.rad(v6))) * 30 + math.sin((math.rad(number))) * number3,
				math.sin((math.rad(total))) * 4 + 4,
				math.cos((math.rad(v6))) * 30 + math.sin((math.rad(number))) * number3
			)
			clone3.Parent = folder
			local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				total += 1200 * dt
				v6 += 360 * dt
				number += number2 * dt
				clone3.CFrame = CFrame.lookAt(pos, pos + normal) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(
					math.sin((math.rad(v6))) * 30 + math.sin((math.rad(number))) * number3,
					math.sin((math.rad(total))) * 4 + 4,
					math.cos((math.rad(v6))) * 30 + math.sin((math.rad(number))) * number3
				)
			end)
			local v15 = clone3
			task.delay(duration, function()
				task.wait((ParticleState(v15, false)))
				heartbeatConnection:Disconnect()
				v15:Destroy()
			end)
		end

		local lastTime = os.clock()
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if os.clock() - lastTime < 0.1 then
				return
			end

			lastTime = os.clock()
			local v6 = CFrame.new(pos) * CFrame.Angles(
				random:NextNumber(-1.5707963267948966, 1.5707963267948966),
				random:NextNumber(0, 6.283185307179586),
				random:NextNumber(-1.5707963267948966, 1.5707963267948966)
			)
			local clone3 = throwablePotionCandyExplosion.GhostTrailModel:Clone()
			local ghostTrail = clone3.GhostTrail
			clone3:ScaleTo(random:NextNumber(0.8, 2))
			local number = random:NextNumber(0, 360)
			local number2 = random:NextNumber(200, 350)
			local position = (v6 * CFrame.new(
				math.sin((math.rad(number))) * 31.1,
				0,
				math.cos((math.rad(number))) * 31.1
			)).Position
			local position2 = nil
			ghostTrail.Position = position
			clone3.Parent = folder
			local unit = nil
			local unit2 = nil
			local unit3 = nil
			local heartbeatConnection2 = nil
			heartbeatConnection2 = RunService.Heartbeat:Connect(function(dt)
				if not heartbeatConnection.Connected then
					heartbeatConnection2:Disconnect()
					return
				end

				number += number2 * dt
				position2 = (v6 * CFrame.new(
					math.sin((math.rad(number))) * 31.1,
					0,
					math.cos((math.rad(number))) * 31.1
				)).Position
				unit = (position2 - position).Unit
				unit2 = (pos - position2).Unit
				unit3 = unit:Cross(unit2)

				if unit3.Magnitude < 0.001 then
					unit3 = unit:Cross(createVector(0, 1, 0))
				end

				unit3 = unit3.Unit
				unit2 = unit3:Cross(unit)
				ghostTrail.CFrame = CFrame.fromMatrix(position2, unit3, unit2, -unit) * CFrame.Angles(
					0,
					0,
					1.5707963267948966
				)
				position = position2
			end)
			task.wait(random:NextNumber(1, 2))
			task.wait((ParticleState(ghostTrail, false)))
			heartbeatConnection2:Disconnect()
			ghostTrail:Destroy()
		end)
		workspace:GetPartBoundsInRadius(pos, 32.1, overlapParams)

		v2[data.id] = function(instance)
			local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
			local Sound3 = require(game.ReplicatedStorage.Util.Sound)
			local v6 = {
				"HalloweenPotions_Candy_Absorb_02",
				"HalloweenPotions_Candy_Absorb_01",
				"HalloweenPotions_Candy_Absorb_03",
				"HalloweenPotions_Candy_Absorb_04",
				"HalloweenPotions_Candy_Absorb_05"
			}
			Sound3:Play(v6[math.random(1, #v6)], humanoidRootPart)
			random:NextNumber(0.3, 0.6)
			task.spawn(function()
				for _ = 1, 7 do
					task.spawn(function()
						local clone3 = throwablePotionCandyExplosion.Candy:Clone()
						clone3.Position = (CFrame.new(pos) * CFrame.Angles(
							random:NextNumber(0, 6.283185307179586),
							random:NextNumber(0, 6.283185307179586),
							random:NextNumber(0, 6.283185307179586)
						) * CFrame.new(0, 0, random:NextNumber(0, 32.1))).Position
						clone3.Parent = folder
						local color = v[random:NextInteger(1, 3)]

						for _, effect in clone3:GetDescendants() do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Color = color
							end
						end

						local position = clone3.Position
						local v8 = pos + Vector3.new(
							random:NextNumber(-20, 20),
							random:NextNumber(-20, 20),
							random:NextNumber(-20, 20)
						)
						local v9 = pos + Vector3.new(
							random:NextNumber(-20, 20),
							random:NextNumber(-20, 20),
							random:NextNumber(-20, 20)
						)
						local position2 = humanoidRootPart.Position

						for i = 0, 1, RunService.Heartbeat:Wait() / random:NextNumber(0.5, 0.7) do
							position2 = humanoidRootPart.Position
							local v10 = position + (v8 - position) * i
							local v11 = v8 + (v9 - v8) * i
							local v12 = v9 + (position2 - v9) * i
							local v13 = v10 + (v11 - v10) * i
							clone3.Position = v13 + (v11 + (v12 - v11) * i - v13) * i
							task.wait()
						end

						for _, emitter in clone3:GetDescendants() do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							emitter.Enabled = false
							emitter:Clear()
						end

						clone3.Position = position2
						local clone4 = throwablePotionCandyExplosion.CandyCollect:Clone()
						clone4.CFrame = humanoidRootPart.CFrame
						clone4.Parent = folder

						for _, emitter in clone4:GetDescendants() do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							emitter.Color = color
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end

						task.wait(0.3)
						clone3:Destroy()
					end)
					task.wait(random:NextNumber(0.02, 0.05))
				end
			end)
			task.spawn(function()
				local clone3 = throwablePotionCandyExplosion.Absorb:Clone()
				clone3.Weld.Part0 = humanoidRootPart
				clone3.Parent = folder
				task.wait((ParticleState(clone3)))
				clone3:Destroy()
			end)
		end

		task.wait(duration)
		heartbeatConnection:Disconnect()
		Sound2:FadeOut(v5, 1)

		for i = 0, 1, RunService.Heartbeat:Wait() / 0.2 do
			clone2:ScaleTo((math.lerp(
				1,
				0.01,
				(TweenService:GetValue(i, Enum.EasingStyle.Circular, Enum.EasingDirection.In))
			)))
			task.wait()
		end

		clone2:Destroy()
		v2[data.id] = nil
	end
end