local createVector = vector.create
local _ = game.Players.LocalPlayer
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Sharkman2").Z.Assets
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local function GetSharkmanColorOwner(player, model)
	local player2 = player.Player or player.player

	if typeof(player2) == "Instance" and player2:IsA("Player") and player2.Parent then
		return player2
	end

	if typeof(model) ~= "Instance" or not model:IsA("Model") then
		return player2
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(model)

	if playerFromCharacter and playerFromCharacter.Parent then
		return playerFromCharacter
	end

	return model
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

local function curve(instance, position)
	local position2 = instance.Position
	local magnitude = (position2 - position).Magnitude
	instance.CFrame = CFrame.new(position2, position)
	local v = (position2 - position) / 2
	local position3 = CFrame.new(CFrame.new(position2) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position) * (v / 1.5)).Position
	local v2 = math.random(5, 10) * 3
	local v3 = position3 + Vector3.new(math.random(-v2, v2), math.random(-2, v2), math.random(-v2, v2))
	local v4 = position4 + Vector3.new(math.random(-v2, v2), math.random(-2, v2), math.random(-v2, v2))
	local v5 = math.random(20, 30) / 50
	local lastTime = tick()
	local v6 = magnitude / v5 / 60

	while tick() - lastTime < v6 do
		local v7 = (tick() - lastTime) / v6
		local v8 = cubicBezier(v7, position2, v3, v4, position)
		instance.CFrame = instance.CFrame:Lerp(CFrame.new(v8, position), v7)
		RunService.Heartbeat:Wait()
	end
end

local function DashTrail(instance, position)
	local position2 = instance.Position
	local magnitude = (position2 - position).Magnitude
	instance.CFrame = CFrame.new(position2, position)
	local v = (position2 - position) / 2
	local position3 = CFrame.new(CFrame.new(position2) * (v / -1.5)).Position
	local position4 = CFrame.new(CFrame.new(position) * (v / 1.5)).Position
	local v2 = math.random(20, 30)
	local v3 = position3 + Vector3.new(math.random(-v2, v2), math.random(-2, v2), math.random(-v2, v2))
	local v4 = position4 + Vector3.new(math.random(-v2, v2), math.random(-2, v2), math.random(-v2, v2))
	local v5 = math.random(15, 30) / 7
	local lastTime = tick()
	local v6 = magnitude / v5 / 60

	while tick() - lastTime < v6 do
		local v7 = (tick() - lastTime) / v6
		local v8 = cubicBezier(v7, position2, v3, v4, position)
		instance.CFrame = instance.CFrame:Lerp(CFrame.new(v8, position), v7)
		RunService.Heartbeat:Wait()
	end
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

local function SkillUse(player)
	local character = player.Character
	local _ = player.Humanoid
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local sharkmanColorOwner = GetSharkmanColorOwner(player, character)
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 7)
	task.spawn(function()
		task.wait(0.3)
		local clone = assets.Extra.Start:Clone()
		clone.CFrame = humanoidRootPart.CFrame
		Util.SetParentOverrideWithColor(clone, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		task.wait(0.1)
		local clone2 = assets.Extra.StartImpact:Clone()
		clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -5)
		Util.SetParentOverrideWithColor(clone2, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
		Util.Sound:Play("SharkmanK_Z_Release_01", humanoidRootPart)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v2 = emitter
			task.spawn(function()
				if v2:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v2:GetAttribute("EmitDelay"))
				end

				v2:Emit(v2:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.lookAt(
			player.State:GetAttribute("NextPos"),
			player.State:GetAttribute("MousePos") + createVector(0, 1, 0) * player.height
		)
		local speed = player.Speed
		local lifetime = player.Lifetime
		local clone3 = assets.Extra.Projectile:Clone()
		clone3.CFrame = cframe
		Util.SetParentOverrideWithColor(clone3, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
		local v2 = (cframe.LookVector + createVector(0, 0.6, 0)).Unit * speed
		local lastTime = tick()
		local flag = false
		local hiddenGrab = player.HiddenGrab
		hiddenGrab.Value = clone3.CFrame
		local raycastResult = workspace:Raycast(clone3.Position, v2.Unit * 6, raycastParams)
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			if lifetime < tick() - lastTime then
				heartbeatConnection:Disconnect()
				clone3:Destroy()
				flag = true
			else
				raycastResult = workspace:Raycast(clone3.Position, v2.Unit * 6, raycastParams)

				if raycastResult then
					heartbeatConnection:Disconnect()
					clone3:Destroy()
					flag = true
				end

				v2 += createVector(0, -300, 0) * dt
				local v4 = clone3.Position + v2 * dt
				clone3.CFrame = CFrame.lookAt(v4, v4 + v2)
				hiddenGrab.Value = clone3.CFrame
			end
		end)

		repeat
			task.wait()
		until flag

		hiddenGrab.Value = clone3.CFrame
		clone3:Destroy()
		local clone4 = assets.Extra.Explosion:Clone()

		if not raycastResult then
			clone4.Explosion2:Destroy()
		end

		clone4.CFrame = clone3.CFrame
		Util.SetParentOverrideWithColor(clone4, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")
		Util.Sound:Play("SharkmanK_X_Explode_01", clone4.CFrame.Position)

		for _, emitter in pairs(clone4:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v3 = emitter
			task.spawn(function()
				if v3:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v3:GetAttribute("EmitDelay"))
				end

				v3:Emit(v3:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone4) -- equivalent call inferred; original call site unknown

		if raycastResult then
			local clone5 = assets.Extra.WaterSplash:Clone()
			clone5.CFrame = clone4.CFrame * CFrame.new(0, 10, 0)
			Util.SetParentOverrideWithColor(clone5, folder, sharkmanColorOwner, "SharkmanKarateFruitVFXColor")

			for _, emitter in pairs(clone5:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				emitter:Emit(1)
			end

			local raycastResult2 = workspace:Raycast(
				clone4.Position + createVector(0, 15, 0) + createVector(0, 1, 0),
				createVector(-0, -25, -0),
				raycastParams
			)

			if raycastResult2 then
				clone5.WaterSplash3.CFrame = AlignCFrame(CFrame.new(raycastResult2.Position), raycastResult2.Normal) + raycastResult2.Normal * 0.01
			else
				clone5.WaterSplash3:Destroy()
			end

			task.wait(0.5)

			for _, emitter in pairs(clone5:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				if emitter.Parent.Name == "WaterSplash3" then
					local v3 = emitter
					task.delay(0.25, function()
						v3.Enabled = false
					end)
				else
					emitter.Enabled = false
				end
			end
		end
	end)
end

return SkillUse