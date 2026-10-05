local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VolcanoClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Random.new()
local emitters = {}
local v = 0
local v2 = nil

function EmitParticles(p)
	for _, emitter in pairs(emitters) do
		if not (emitter:IsA("ParticleEmitter") and (string.find(emitter.Name, p .. "_") or string.find(
			emitter.Name,
			"All_"
		))) then
			continue
		end

		emitter:Clear()
		local emitCount = emitter:GetAttribute("EmitCount")
		local emitDelay = emitter:GetAttribute("EmitDelay")
		local emitDuration = emitter:GetAttribute("EmitDuration")
		local v3 = emitCount == nil and 0 or emitCount
		local v4 = emitDelay == nil and 0 or emitDelay
		local v5 = emitDuration == nil and 0 or emitDuration
		local v6 = emitter
		task.delay(v4, function()
			v6:Emit(v3)

			if v5 ~= 0 then
				v6.Enabled = true
				task.delay(v5, function()
					v6.Enabled = false
				end)
			end
		end)
	end
end

local count = 0
local v3 = {}
local v4 = {}

function SacrificeReceived(p)
	v = p

	if not v2 then
		return
	end

	count += 1
	local v5 = count
	local sacrifice = v2:WaitForChild("Functional"):WaitForChild("Sacrifice")
	local lanterns = sacrifice:WaitForChild("Lanterns")

	for k, v6 in pairs(v3) do
		v6:Cancel()
		v3[k] = nil
	end

	if p == 8 then
		local clone = sacrifice.Altar:WaitForChild("Platform").LargeSound:Clone()
		clone.Parent = sacrifice.Altar.Platform
		clone:Play()
		v4 = {}
	elseif p > 0 then
		local clone = sacrifice.Altar:WaitForChild("Platform").SmallSound:Clone()
		clone.Parent = sacrifice.Altar.Platform
		clone:Play()
	end

	local flag = true

	for i = 1, 8 do
		if v4[i] ~= nil then
			continue
		end

		flag = false
		break
	end

	for i = 1, 8 do
		local child = lanterns:WaitForChild(i)

		if not child then
			continue
		end

		child:WaitForChild("Part")

		for _, descendant in pairs(child.Light:GetDescendants()) do
			if descendant:IsA("PointLight") then
				descendant.Enabled = i <= p
			end

			if not descendant:IsA("BasePart") then
				continue
			end

			if p == 8 then
				descendant.Material = Enum.Material.Neon

				if flag then
					descendant.Color = Color3.fromRGB(255, 85, 255)
				else
					descendant.Color = Color3.fromRGB(213, 70, 34)
				end

				local tween = TweenService:Create(
					descendant,
					TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{
						Color = Color3.fromRGB(0, 0, 0)
					}
				)
				table.insert(v3, tween)
				tween:Play()
				task.spawn(function()
					wait(4)
					local _ = v5 == count
				end)
			elseif i <= p then
				descendant.Material = Enum.Material.Neon

				if v4[i] then
					descendant.Color = Color3.fromRGB(255, 85, 255)
				else
					descendant.Color = Color3.fromRGB(213, 115, 61)
				end
			else
				descendant.Color = Color3.fromRGB(0, 0, 0)
			end
		end
	end

	if p == 0 then
		return
	end

	if p ~= 8 then
		EmitParticles("Red")
		return
	end

	v = 0

	if flag then
		EmitParticles("Purple")
	else
		EmitParticles("Red")
	end
end

Client.Events.AddSacrificeParticles:Connect(function(p)
	local clone = ReplicatedStorage.Assets.Particles.LavaSplashVFX:Clone()
	clone:PivotTo(CFrame.new(p.Position) + createVector(0, 32, 0))
	clone.Parent = workspace.Particles
	clone.LavaSplashVfx.Sound:Play()

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter:Clear()
		local emitCount = emitter:GetAttribute("EmitCount")
		local emitDelay = emitter:GetAttribute("EmitDelay")
		local emitDuration = emitter:GetAttribute("EmitDuration")
		local v5 = emitCount == nil and 0 or emitCount
		local v6 = emitDelay == nil and 0 or emitDelay
		local v7 = emitDuration == nil and 0 or emitDuration
		local v8 = emitter
		task.delay(v6, function()
			v8:Emit(v5)

			if v7 ~= 0 then
				v8.Enabled = true
				task.delay(v7, function()
					v8.Enabled = false
				end)
			end
		end)
	end

	task.spawn(function()
		wait(10)
		clone:Destroy()
	end)
end)
Client.Events.SacrificeAdded:Connect(function(p, p2, p3)
	local clone = nil
	task.spawn(function()
		wait(2)
		local v5 = p2 - workspace:GetServerTimeNow()

		if v5 > 0 and v2 and v2:FindFirstChild("Functional") and v2.Functional:FindFirstChild("Sacrifice") and v2.Functional.Sacrifice:FindFirstChild("Fuse") then
			clone = p3 and ReplicatedStorage.Assets.Particles.VolcanoEasterSparks:Clone() or ReplicatedStorage.Assets.Particles.VolcanoSparks:Clone()
			clone:PivotTo(v2.Functional.Sacrifice.Fuse.Start.WorldCFrame)
			clone.Parent = workspace.Particles
			clone.Sound:Play()
			TweenService:Create(clone, TweenInfo.new(v5, Enum.EasingStyle.Linear), {
				CFrame = v2.Functional.Sacrifice.Fuse.End.WorldCFrame
			}):Play()
		end
	end)

	if p2 <= workspace:GetServerTimeNow() then
		if clone then
			clone:Destroy()
		end

		if p3 then
			v4[p] = true
		else
			v4 = {}
		end

		SacrificeReceived(p)
	else
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if p2 <= workspace:GetServerTimeNow() then
				if clone then
					clone:Destroy()
				end

				if p3 then
					v4[p] = true
				else
					v4 = {}
				end

				SacrificeReceived(p)
				heartbeatConnection:Disconnect()
			end
		end)
	end
end)

function VolcanoAdded(instance)
	if not instance:IsDescendantOf(workspace) then
		return
	end

	v2 = instance
	SacrificeReceived(v or 0)

	for _, emitter in pairs(instance:WaitForChild("Functional"):WaitForChild("Sacrifice"):WaitForChild("Altar"):WaitForChild("Platform"):GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") or table.find(emitters, emitter) then
			continue
		end

		table.insert(emitters, emitter)
	end
end

function VolcanoClient.Init()
	Client.Utility.ForAllTagged("Volcano", VolcanoAdded)
end

return VolcanoClient