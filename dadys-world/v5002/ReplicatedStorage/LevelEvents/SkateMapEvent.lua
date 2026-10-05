local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local IceSkatingConfig = require(ReplicatedStorage.Modules.Zones.IceSkatingConfig)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local MonsterAI

if RunService:IsServer() then
	MonsterAI = require(ServerScriptService:WaitForChild("MonsterAI"):WaitForChild("MonsterAI"))
else
	MonsterAI = nil
end

local SkateMapEvent = {}
SkateMapEvent.properties = {
	SpawnsBobetteMonsters = true,
	AltersLighting = true,
	AltersPhysics = true,
	IceSkatingMode = "Enhanced",
	BobetteScale = 2.4
}
SkateMapEvent.loadDelay = 0.5
SkateMapEvent.setupDelay = 0.1

function SkateMapEvent.onRoomLoad(instance, _)
	print("[SkateMapEvent] Setting up SkateMap special event")
	instance:SetAttribute("OriginalBrightness", Lighting.Brightness)
	instance:SetAttribute("OriginalAmbient_R", Lighting.Ambient.R)
	instance:SetAttribute("OriginalAmbient_G", Lighting.Ambient.G)
	instance:SetAttribute("OriginalAmbient_B", Lighting.Ambient.B)
	instance:SetAttribute("OriginalOutdoorAmbient_R", Lighting.OutdoorAmbient.R)
	instance:SetAttribute("OriginalOutdoorAmbient_G", Lighting.OutdoorAmbient.G)
	instance:SetAttribute("OriginalOutdoorAmbient_B", Lighting.OutdoorAmbient.B)
	instance:SetAttribute("OriginalFogEnd", Lighting.FogEnd)
	instance:SetAttribute("OriginalFogColor_R", Lighting.FogColor.R)
	instance:SetAttribute("OriginalFogColor_G", Lighting.FogColor.G)
	instance:SetAttribute("OriginalFogColor_B", Lighting.FogColor.B)
	TweenService:Create(Lighting, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Brightness = 3,
		Ambient = Color3.fromRGB(220, 240, 255),
		OutdoorAmbient = Color3.fromRGB(220, 240, 255),
		FogEnd = 500,
		FogColor = Color3.fromRGB(200, 220, 255)
	}):Play()
	print("[SkateMapEvent] Lighting adjusted")
end

function SkateMapEvent.setupBehaviors(parent, _)
	print("[SkateMapEvent] Setting up ice skating and spawning Big Bobette")
	local v = {}
	local heartbeatConnection = nil
	local clone = nil
	local v2 = ReplicatedStorage:FindFirstChild("IceSkatingToggle")

	if not v2 then
		v2 = Instance.new("RemoteEvent")
		v2.Name = "IceSkatingToggle"
		v2.Parent = ReplicatedStorage
	end

	for _, v3 in pairs(Players:GetPlayers()) do
		if v3.Character then
			v3.Character:SetAttribute("IceSkatingMode", true)
		end

		IceSkatingConfig.ApplyAntiCheatExceptions(v3, "Enhanced")
	end

	local playerAddedConnection = Players.PlayerAdded:Connect(function(player)
		IceSkatingConfig.ApplyAntiCheatExceptions(player, "Enhanced")
	end)
	table.insert(v, function()
		playerAddedConnection:Disconnect()
	end)
	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if inGamePlayers then
		local childAddedConnection = inGamePlayers.ChildAdded:Connect(function(child)
			task.wait(0.3)
			child:SetAttribute("IceSkatingMode", true)
		end)
		table.insert(v, function()
			childAddedConnection:Disconnect()
		end)
	end

	local thread = task.spawn(function()
		while true do
			task.wait(1)

			for _, v3 in pairs(Players:GetPlayers()) do
				IceSkatingConfig.ApplyAntiCheatExceptions(v3, "Enhanced")
			end
		end
	end)
	table.insert(v, function()
		task.cancel(thread)
	end)
	task.wait(0.5)
	v2:FireAllClients("Activate", "Enhanced")
	v2:FireAllClients("FreezeLevel")
	print("[SkateMapEvent] Activated", "Enhanced", "ice skating preset")
	local bobetteMonster = ServerStorage.Monsters:FindFirstChild("BobetteMonster")

	if bobetteMonster then
		local monsterSpawnPoints = parent:FindFirstChild("MonsterSpawnPoints")

		if monsterSpawnPoints and #monsterSpawnPoints:GetChildren() > 0 then
			local parent3 = parent:FindFirstChild("Monsters")

			if not parent3 then
				parent3 = Instance.new("Folder")
				parent3.Name = "Monsters"
				parent3.Parent = parent
			end

			local children = monsterSpawnPoints:GetChildren()
			local v4 = children[math.random(1, #children)]
			clone = bobetteMonster:Clone()
			local humanoid = clone:WaitForChild("Humanoid")

			for _, part in pairs(clone:GetDescendants()) do
				if not part:IsA("BasePart") or CollectionService:HasTag(part, "IgnoreChangingCollision") then
					continue
				end

				part.CollisionGroup = "Monster"

				if part.Name ~= "HumanoidRootPart" then
					part.CanCollide = false
				end
			end

			clone:ScaleTo(2.4)
			local v5 = clone.PrimaryPart.Size.Y / 2 + humanoid.HipHeight
			clone.Parent = parent3
			clone:PivotTo(v4.CFrame * CFrame.new(0, v5, 0))
			print("[SkateMapEvent] Spawned Big Bobette at", v4.Name, "scale:", 2.4)
			local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")
			local v6 = {}
			local vector2 = createVector(0, 0, 0)
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				if humanoidRootPart and humanoidRootPart.Parent then
					local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
					vector2 = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)
				end
			end)
			local inGamePlayers2 = workspace:FindFirstChild("InGamePlayers")

			local function isPartProtected(part)
				local name = part.Name:lower()
				return name:match("baseplate") or name:match("floor") or name:match("generator") or name:match("spawn") or name:match("machine") or name:match("exit") or name:match("door")
			end

			local function isModelProtected(parent2)
				local name = parent2.Name:lower()
				return name:match("generator") or name:match("spawn") or name:match("machine") or name:match("exit") or name:match("door") or name:match("player")
			end

			local touchedConnection = nil
			touchedConnection = humanoidRootPart.Touched:Connect(function(part)
				if clone and clone.Parent then
					if v6[part] or vector2.Magnitude < 5 or not part:IsA("BasePart") or part:IsDescendantOf(clone) then
						return
					end

					if inGamePlayers2 and part:IsDescendantOf(inGamePlayers2) or isPartProtected(part) then
						return
					end

					local parent2 = part.Parent
					local parts = {}

					if parent2 and parent2:IsA("Model") and not parent2:IsDescendantOf(clone) then
						if isModelProtected(parent2) or inGamePlayers2 and parent2:IsDescendantOf(inGamePlayers2) or v6[parent2] then
							return
						end

						v6[parent2] = true
						v6[part] = true

						for _, part2 in pairs(parent2:GetDescendants()) do
							if not part2:IsA("BasePart") then
								continue
							end

							local v7 = math.max(part2.Size.X, part2.Size.Y, part2.Size.Z) > 40

							if not (isPartProtected(part2) or v7) then
								table.insert(parts, part2)
							end
						end

						print("[SkateMapEvent] Destroying Model:", parent2.Name, "with", #parts, "parts")
					else
						if math.max(part.Size.X, part.Size.Y, part.Size.Z) > 40 or not part.Anchored then
							return
						end

						v6[part] = true
						table.insert(parts, part)
					end

					if #parts == 0 then
						return
					end

					local unit = vector2.Unit
					local magnitude = vector2.Magnitude

					for _, parent4 in pairs(parts) do
						parent4.Anchored = false
						parent4.CanCollide = true
						local unit2 = (parent4.Position - humanoidRootPart.Position).Unit
						parent4.AssemblyLinearVelocity = (unit * 0.7 + unit2 * 0.3).Unit * (magnitude * 5) + createVector(
							0,
							60,
							0
						)
						parent4.AssemblyAngularVelocity = Vector3.new(
							math.random(-20, 20),
							math.random(-20, 20),
							math.random(-20, 20)
						)
						local particleEmitter = Instance.new("ParticleEmitter")
						particleEmitter.Parent = parent4
						particleEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
						particleEmitter.Rate = 30
						particleEmitter.Lifetime = NumberRange.new(1, 2)
						particleEmitter.Speed = NumberRange.new(3, 8)
						particleEmitter.SpreadAngle = Vector2.new(20, 20)
						particleEmitter.Color = ColorSequence.new(Color3.fromRGB(100, 100, 100))
						particleEmitter.Size = NumberSequence.new(1, 3)
						particleEmitter.Transparency = NumberSequence.new(0.3, 1)
						particleEmitter.Enabled = true
					end

					Audio:Play("Sounds.ZoneEvents.MapEvents.SkateImpact", {
						Volume = 0.8,
						PlaybackSpeed = math.random(80, 120) / 100,
						Parent = part
					})
					task.delay(5, function()
						for _, v7 in pairs(parts) do
							if v7 and v7.Parent then
								v7:Destroy()
							end
						end
					end)
					print("[SkateMapEvent] Destroyed", #parts, "parts!")
				elseif touchedConnection then
					touchedConnection:Disconnect()
				end
			end)
			clone.AncestryChanged:Connect(function()
				if not clone.Parent and touchedConnection then
					touchedConnection:Disconnect()
				end
			end)

			if MonsterAI then
				local bobetteMonster2 = ReplicatedStorage.MonsterData:FindFirstChild("BobetteMonster")

				if bobetteMonster2 then
					local module = require(bobetteMonster2)

					if module.SpecialChaser then
						module.SpecialChaser(clone)
					elseif not module.NoChase then
						task.spawn(function()
							MonsterAI.new(clone)
						end)
					end
				else
					task.spawn(function()
						MonsterAI.new(clone)
					end)
				end
			end
		else
			warn("[SkateMapEvent] No MonsterSpawnPoints found in room!")
		end
	else
		warn("[SkateMapEvent] BobetteMonster not found!")
	end

	return function()
		print("[SkateMapEvent] Cleaning up...")

		if v2 then
			v2:FireAllClients("Deactivate")
		end

		for _, v3 in pairs(Players:GetPlayers()) do
			if v3.Character then
				v3.Character:SetAttribute("IceSkatingMode", nil)
			end

			IceSkatingConfig.ClearAntiCheatExceptions(v3)
		end

		TweenService:Create(Lighting, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Brightness = parent:GetAttribute("OriginalBrightness") or 2,
			Ambient = Color3.new(
				parent:GetAttribute("OriginalAmbient_R") or 0,
				parent:GetAttribute("OriginalAmbient_G") or 0,
				parent:GetAttribute("OriginalAmbient_B") or 0
			),
			OutdoorAmbient = Color3.new(
				parent:GetAttribute("OriginalOutdoorAmbient_R") or 0,
				parent:GetAttribute("OriginalOutdoorAmbient_G") or 0,
				parent:GetAttribute("OriginalOutdoorAmbient_B") or 0
			)
		}):Play()

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end

		for _, callback in ipairs(v) do
			pcall(callback)
		end

		if clone and clone.Parent then
			clone:Destroy()
		end

		print("[SkateMapEvent] Cleanup complete")
	end
end

return SkateMapEvent