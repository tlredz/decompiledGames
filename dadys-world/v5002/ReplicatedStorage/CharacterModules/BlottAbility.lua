local createVector = vector.create
local BlottAbility = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")
game:GetService("Workspace")
game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
game:GetService("PhysicsService")
local _ = {
	"BrickColor",
	"Material",
	"Transparency",
	"Reflectance"
}
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local tower = TowerLUT:GetTower("Blott")

local function round3(p)
	return math.floor(p * 1000 + 0.5) / 1000
end

function BlottAbility.Init(instance)
	local v = {
		currentHealth = instance.Humanoid.Health,
		lastDecoyTime = 0,
		activeDecoy = nil,
		abilityEnabled = true
	}
	instance:SetAttribute("HasActiveDecoy", false)
	return v
end

function BlottAbility.CanUseDecoy(character, p)
	if not (character and p) then
		warn("[BlottAbility] Missing character or stats")
		return false
	end

	local now = tick()

	if now - p.lastDecoyTime < 30 then
		local v = math.ceil(30 - (now - p.lastDecoyTime))
		local playerFromCharacter = Players:GetPlayerFromCharacter(character)
		local displayMessage = playerFromCharacter and ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DisplayMessage")

		if displayMessage then
			displayMessage:FireClient(
				playerFromCharacter,
				"Decoy ability on cooldown: " .. v .. "s",
				Color3.fromRGB(255, 100, 100)
			)
		end

		return false
	else
		if not (p.activeDecoy and p.activeDecoy.Parent) then
			return true
		end

		local playerFromCharacter = Players:GetPlayerFromCharacter(character)
		local displayMessage = playerFromCharacter and ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DisplayMessage")

		if displayMessage then
			displayMessage:FireClient(
				playerFromCharacter,
				"You already have an active decoy!",
				Color3.fromRGB(255, 160, 0)
			)
		end

		return false
	end
end

function BlottAbility.CreateDecoy(instance, position, value)
	local function createSpawnEffect(position2)
		local part = Instance.new("Part")
		part.Name = "SpawnPoofEffect"
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 1
		part.Size = createVector(1, 1, 1)
		part.Position = position2

		if not workspace:FindFirstChild("Effects") then
			local folder = Instance.new("Folder")
			folder.Name = "Effects"
			folder.Parent = workspace
		end

		part.Parent = workspace.Effects
		local smoke = Instance.new("Smoke")
		smoke.Color = Color3.fromRGB(200, 200, 200)
		smoke.Opacity = 0.8
		smoke.RiseVelocity = 10
		smoke.Size = 5
		smoke.Parent = part
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Texture = "rbxassetid://6101261097"
		particleEmitter.Rate = 50
		particleEmitter.Rotation = NumberRange.new(0, 360)
		particleEmitter.RotSpeed = NumberRange.new(-30, 30)
		particleEmitter.Speed = NumberRange.new(5, 10)
		particleEmitter.SpreadAngle = Vector2.new(0, 180)
		particleEmitter.Lifetime = NumberRange.new(0.5, 1)
		particleEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.5, 3),
			NumberSequenceKeypoint.new(1, 0)
		})
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.7, 0.5),
			NumberSequenceKeypoint.new(1, 1)
		})
		particleEmitter.Parent = part
		particleEmitter:Emit(50)
		Debris:AddItem(part, 2)
	end

	if not (instance and instance:FindFirstChild("Humanoid")) then
		warn("[BlottAbility] Invalid character")
		return nil
	end

	local cframe

	if position then
		cframe = CFrame.new(position)
	else
		cframe = instance:GetPrimaryPartCFrame() + createVector(0, -0.5, 0)

		if cframe then
			local _ = cframe.Position
		else
			warn("[BlottAbility] Could not determine character's CFrame for decoy placement.")
			return nil
		end
	end

	if not workspace:FindFirstChild("InGamePlayers") then
		warn("[BlottAbility] InGamePlayers folder not found in workspace")
		return nil
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if not playerFromCharacter then
		warn("[BlottAbility] No player found for character")
		return nil
	end

	local clone = nil
	local success, result = pcall(function()
		if not playerFromCharacter.Character then
			return
		end

		local parts = ServerStorage:WaitForChild("Parts")
		local currentSkin = instance:GetAttribute("CurrentSkin") or "Default"
		local skin = not ({
			Default = true
		})[currentSkin] and TowerLUT:GetSkin("Blott", currentSkin)
		local blotDecoy = parts:WaitForChild("BlotDecoy")
		print(currentSkin, skin)

		if skin then
			local module = require(skin)
			blotDecoy = parts:FindFirstChild(module.DecoyName or "BlotDecoy") or blotDecoy
		end

		clone = blotDecoy:Clone()
		clone.Name = "BlottDecoy_" .. playerFromCharacter.Name

		for _, part in ipairs(clone:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Transparency = 1
			end
		end

		local v = clone:FindFirstChildOfClass("Humanoid")

		if v then
			v.MaxHealth = 1
			v.Health = 1
			v.WalkSpeed = 0
			v.JumpPower = 0
			v.AutoRotate = false
			v:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
			v:SetStateEnabled(Enum.HumanoidStateType.Running, false)
			v:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
			v:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
			v.DisplayName = "Blott's Decoy"
		else
			if clone:FindFirstChildOfClass("Humanoid") then
				clone:FindFirstChildOfClass("Humanoid"):Destroy()
			end

			local animationController = Instance.new("AnimationController")
			animationController.Name = "AnimationController"
			animationController.Parent = clone
			v = Instance.new("Humanoid")
			v.MaxHealth = 1
			v.Health = 1
			v.WalkSpeed = 0
			v.JumpPower = 0
			v.AutoRotate = false
			v.DisplayName = "Blott's Decoy"
			v.Parent = clone
			clone:SetAttribute("DecoyTag", true)
			clone:SetAttribute("StealthValue", -999)
		end

		local primaryPart = clone:FindFirstChild("HumanoidRootPart")

		if primaryPart then
			primaryPart.Transparency = 1
		else
			primaryPart = Instance.new("Part")
			primaryPart.Name = "HumanoidRootPart"
			primaryPart.Size = createVector(2, 2, 1)
			primaryPart.Transparency = 1
			primaryPart.CanCollide = false
			primaryPart.Parent = clone
		end

		primaryPart.Anchored = true
		clone.PrimaryPart = primaryPart
		clone:SetPrimaryPartCFrame(cframe)

		for _, script in ipairs(clone:GetDescendants()) do
			if script:IsA("Script") or script:IsA("LocalScript") then
				script:Destroy()
			end
		end

		for _, motor6D in ipairs(clone:GetDescendants()) do
			if not motor6D:IsA("Motor6D") then
				continue
			end

			if motor6D.Part0 and motor6D.Part0.Parent ~= clone and motor6D.Part0.Parent ~= nil then
				local name = motor6D.Part0.Name
				local child = clone:FindFirstChild(name)

				if child then
					motor6D.Part0 = child
				end
			end

			if not (motor6D.Part1 and motor6D.Part1.Parent ~= clone and motor6D.Part1.Parent ~= nil) then
				continue
			end

			local name = motor6D.Part1.Name
			local child = clone:FindFirstChild(name)

			if child then
				motor6D.Part1 = child
			end
		end

		if clone.PrimaryPart and clone.PrimaryPart:IsA("BasePart") then
			clone.PrimaryPart.Transparency = 1
		end

		for _, part in ipairs(clone:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			if part == clone.PrimaryPart then
				part.Transparency = 1
			elseif part.Name == "RootPart" then
				part.Transparency = 1
			elseif part.Name == "Particle" then
				part.Transparency = 1
			elseif CollectionService:HasTag(part, "StayTransparent") then
				part.Transparency = 0.5
			else
				part.Transparency = 0
			end
		end

		local folder = Instance.new("Folder")
		folder.Name = "Stats"
		folder.Parent = clone
		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "Sprinting"
		boolValue.Value = false
		boolValue.Parent = folder
		local boolValue2 = Instance.new("BoolValue")
		boolValue2.Name = "Injured"
		boolValue2.Value = false
		boolValue2.Parent = folder
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = "Stealth"
		numberValue.Value = -999
		numberValue.Parent = folder
		local numberValue2 = Instance.new("NumberValue")
		numberValue2.Name = "StealthModifier"
		numberValue2.Value = 1
		numberValue2.Parent = folder
		local objectValue = Instance.new("ObjectValue")
		objectValue.Name = "Decoding"
		objectValue.Value = nil
		objectValue.Parent = clone
		clone:SetAttribute("DecoyTag", true)
		clone:SetAttribute("Stealth", -999)
		clone:SetAttribute("StealthModifier", 1)
		local boolValue3 = Instance.new("BoolValue")
		boolValue3.Name = "DecoyTag"
		boolValue3.Value = true
		boolValue3.Parent = clone

		if v then
			v.WalkSpeed = 0
			v.JumpPower = 0
			v.AutoRotate = false
		end

		local folder2 = Instance.new("Folder")
		folder2.Name = "Config"
		folder2.Parent = clone
		local stringValue = Instance.new("StringValue")
		stringValue.Name = "ModuleName"
		stringValue.Value = "Blott"
		stringValue.Parent = folder2
		local parent2 = workspace:FindFirstChild("Decoys")

		if not parent2 then
			parent2 = Instance.new("Folder")
			parent2.Name = "Decoys"
			parent2.Parent = workspace
		end

		if parent2 then
			clone.Parent = parent2
		else
			clone.Parent = workspace
		end

		clone:FindFirstChild("Humanoid")
		clone:FindFirstChildOfClass("AnimationController")

		local function waitForAnimationEnd(track, value2)
			local v4 = value2 or 5
			local v5 = false
			local v6 = false
			local endedConnection = nil
			local thread = coroutine.create(function()
				endedConnection = track.Ended:Connect(function()
					v6 = true
				end)
				track:Play()
				local total = 0

				while not v6 and total < v4 do
					total += task.wait(0.1)
				end

				v5 = v6

				if endedConnection then
					endedConnection:Disconnect()
				end
			end)
			local v7, _ = coroutine.resume(thread)

			if v7 then
				local lastTime = tick()

				while coroutine.status(thread) ~= "dead" and tick() - lastTime < v4 + 0.5 do
					task.wait()
				end

				if coroutine.status(thread) ~= "dead" and endedConnection then
					endedConnection:Disconnect()
				end

				if not v5 then
					warn(
						"[BlottAbility] Animation track (",
						track.Animation and track.Animation.Name or "UnknownAnimation",
						") did not finish within timeout (",
						v4,
						"s) or failed."
					)
				end

				return v5
			else
				warn(
					"[BlottAbility] Coroutine for waiting for animation failed to resume for track: ",
					track.Animation and track.Animation.Name or "UnknownAnimation"
				)

				if endedConnection then
					endedConnection:Disconnect()
				end

				return false
			end
		end

		local function triggerAnimatedDestruction(folder3, instance2)
			if not folder3 or not folder3.Parent or folder3:GetAttribute("IsDestroying") then
				return
			end

			folder3:SetAttribute("IsDestroying", true)

			if folder3 and folder3.Parent then
				for _, part in ipairs(folder3:GetDescendants()) do
					if not (part:IsA("BasePart") or part:IsA("MeshPart")) then
						continue
					end

					part.CanCollide = false
					part.CollisionGroupId = 0
				end
			end

			local function performCleanupEffectsAndDestroy(name, vector2)
				if not vector2 then
					warn(
						"[BlottAbility] No effect position provided for cleanup effects of: ",
						name or "UnknownModel",
						". Using default fallback."
					)
					vector2 = Vector3.new(0, workspace.FallenPartsDestroyHeight + 10, 0)
				end

				local part = Instance.new("Part")
				part.Name = (name or "UnknownModel") .. "_DestroyPoofEffect"
				part.Anchored = true
				part.CanCollide = false
				part.Transparency = 1
				part.Size = createVector(1, 1, 1)
				part.Position = vector2
				local parent = workspace:FindFirstChild("Effects")

				if not parent then
					parent = Instance.new("Folder", workspace)
					parent.Name = "Effects"
				end

				part.Parent = parent
				local smoke = Instance.new("Smoke")
				smoke.Color = Color3.fromRGB(200, 200, 200)
				smoke.Opacity = 0.8
				smoke.RiseVelocity = 10
				smoke.Size = 5
				smoke.Parent = part
				local particleEmitter = Instance.new("ParticleEmitter")
				particleEmitter.Texture = "rbxassetid://6101261097"
				particleEmitter.Rate = 50
				particleEmitter.Rotation = NumberRange.new(0, 360)
				particleEmitter.RotSpeed = NumberRange.new(-30, 30)
				particleEmitter.Speed = NumberRange.new(5, 10)
				particleEmitter.SpreadAngle = Vector2.new(0, 180)
				particleEmitter.Lifetime = NumberRange.new(0.5, 1)
				particleEmitter.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.5, 3),
					NumberSequenceKeypoint.new(1, 0)
				})
				particleEmitter.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.7, 0.5),
					NumberSequenceKeypoint.new(1, 1)
				})
				particleEmitter.Parent = part
				particleEmitter:Emit(50)
				Debris:AddItem(part, 2.5)
				task.delay(2, function()
					if part and part.Parent then
						local smoke2 = part:FindFirstChildOfClass("Smoke")
						local particleEmitter2 = part:FindFirstChildOfClass("ParticleEmitter")

						if smoke2 then
							smoke2.Enabled = false
						end

						if particleEmitter2 then
							particleEmitter2.Enabled = false
						end
					end
				end)
				task.wait(2)
			end

			task.spawn(function()
				local animator = instance2 and instance2:FindFirstChild("Animator")
				local animations = folder3:FindFirstChild("Animations")
				local name = folder3 and folder3.Name or "UnknownModel_PreCapture"
				local position2 = folder3 and folder3.PrimaryPart and folder3.PrimaryPart.Position

				-- [DEDUP] synthesized from 3 duplicated terminal regions
				local function deduplicatedTail()
					if folder3 and folder3.Parent then
						for _, part in ipairs(folder3:GetDescendants()) do
							if part:IsA("BasePart") or part:IsA("MeshPart") then
								part.Transparency = 1
							end
						end

						name = folder3.Name
						position2 = folder3.PrimaryPart and folder3.PrimaryPart.Position or folder3:GetModelCFrame() and folder3:GetModelCFrame().Position
						folder3:Destroy()
					end

					performCleanupEffectsAndDestroy(name, position2)
				end

				if not position2 then
					position2 = folder3 and folder3:GetModelCFrame() and folder3:GetModelCFrame().Position or createVector(
						0,
						0,
						0
					)
				end

				if animator and animations then
					local destroy = animations:FindFirstChild("Destroy")

					if destroy and destroy:IsA("Animation") then
						local track = animator:LoadAnimation(destroy)

						if track then
							local connection = nil
							local endedConnection = nil
							local ancestryChangedConnection = nil
							local connection2 = nil
							local connection3 = nil
							local connection4 = nil
							local connection5 = nil
							local flag = false

							local function cleanupAllConnections(p, p2, p3)
								if p then
									if connection then
										connection:Disconnect()
										connection = nil
									end

									if connection2 then
										connection2:Disconnect()
										connection2 = nil
									end
								else
									if connection then
										connection:Disconnect()
										connection = nil
									end

									if connection2 then
										connection2:Disconnect()
										connection2 = nil
									end

									if endedConnection and (p2 or not p) then
										endedConnection:Disconnect()
										endedConnection = nil
									end

									if connection3 and (p3 or not p) then
										connection3:Disconnect()
										connection3 = nil
									end

									if ancestryChangedConnection and not p then
										ancestryChangedConnection:Disconnect()
										ancestryChangedConnection = nil
									end

									if connection4 then
										connection4:Disconnect()
										connection4 = nil
									end

									if connection5 then
										connection5:Disconnect()
										connection5 = nil
									end
								end
							end

							local function playDissapearSequence()
								if flag then
									return
								end

								flag = true

								if folder3 and folder3.Parent then
									name = folder3.Name
									position2 = folder3.PrimaryPart and folder3.PrimaryPart.Position or folder3:GetModelCFrame() and folder3:GetModelCFrame().Position
								end

								if animator then
									local animations2 = animations

									if folder3 and folder3.Parent then
										animations2 = folder3:FindFirstChild("Animations")
									end

									if animations2 then
										if folder3 and folder3.Parent then
											for _, part in ipairs(folder3:GetDescendants()) do
												if part:IsA("BasePart") or part:IsA("MeshPart") then
													part.Transparency = 1
												end
											end

											if ancestryChangedConnection then
												ancestryChangedConnection:Disconnect()
												ancestryChangedConnection = nil
											end

											folder3:Destroy()
											folder3 = nil
										end
									else
										warn(
											"[BlottAbility] Animations folder lost before playing 'Dissapear' for: ",
											name
										)
										performCleanupEffectsAndDestroy(name, position2)
									end

									cleanupAllConnections()
								else
									warn(
										"[BlottAbility] Animator lost before playing 'Dissapear' animation for: ",
										name
									)
									performCleanupEffectsAndDestroy(name, position2)
									cleanupAllConnections()
								end
							end

							connection = track:GetMarkerReachedSignal("Pause"):Connect(function()
								if track and folder3 and folder3.Parent then
									track:AdjustSpeed(0)
									task.delay(1, function()
										if not track or not folder3 or not folder3.Parent or track.Speed ~= 0 then
											return
										end

										track:AdjustSpeed(1)
									end)
								else
									if track then
										track:Stop()
									end

									cleanupAllConnections()
								end
							end)
							connection2 = track:GetMarkerReachedSignal("Particle"):Connect(function()
								if folder3 and folder3.Parent then
									for _, emitter in ipairs(folder3:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter:Emit(5)
										end
									end
								else
									if track then
										track:Stop()
									end

									cleanupAllConnections()
								end
							end)
							connection3 = track:GetMarkerReachedSignal("Destroy"):Connect(function()
								if flag then
									return
								end

								if folder3 and folder3.Parent then
									if track then
										track:Stop()
									end

									if connection then
										connection:Disconnect()
										connection = nil
									end

									if connection2 then
										connection2:Disconnect()
										connection2 = nil
									end

									playDissapearSequence()
								else
									warn("[BlottAbility] Main 'Destroy' event reached but model invalid for: ", name)

									if track then
										track:Stop()
									end

									performCleanupEffectsAndDestroy(name, position2)

									if connection then
										connection:Disconnect()
										connection = nil
									end

									if connection2 then
										connection2:Disconnect()
										connection2 = nil
									end
								end
							end)
							endedConnection = track.Ended:Connect(function()
								local name2 = folder3 and folder3.Name or name

								if flag then
									cleanupAllConnections(false, true, true)
									return
								end

								warn(
									"[BlottAbility] Main animation ended without 'Destroy' event triggering Dissapear for ",
									name2,
									". Attempting Dissapear as fallback."
								)

								if connection then
									connection:Disconnect()
									connection = nil
								end

								if connection2 then
									connection2:Disconnect()
									connection2 = nil
								end

								playDissapearSequence()
							end)
							ancestryChangedConnection = folder3.AncestryChanged:Connect(function(p, parent)
								if p == folder3 and not parent then
									local v4 = name or folder3 and folder3.Name or "UnknownModel_Ancestry"
									warn(string.format(
										"[BlottAbility] Model %s parent became nil (ancestry). Stopping animations and cleaning connections.",
										v4
									))

									if track and track.IsPlaying then
										track:Stop()
										print("Stopped main anim track.")
									end

									cleanupAllConnections()
									folder3 = nil
								end
							end)
							track.Looped = false
							track:Play()
						else
							warn(
								"[BlottAbility] Could not load main 'Destroy' animation track for: ",
								name,
								". Proceeding with immediate simplified cleanup."
							)
							return deduplicatedTail()
						end
					else
						warn(
							"[BlottAbility] Main 'Destroy' animation not found for: ",
							name,
							". Proceeding with immediate simplified cleanup."
						)
						return deduplicatedTail()
					end
				else
					warn(
						"[BlottAbility] Animator or Animations folder not found for animated destruction of: ",
						name,
						". Proceeding with immediate simplified cleanup."
					)
					return deduplicatedTail()
				end
			end)
		end

		task.spawn(function()
			local v4 = false

			if v then
				local animator = v:FindFirstChild("Animator") or Instance.new("Animator", v)
				local animations = clone:FindFirstChild("Animations")

				if animations then
					local rise = animations:FindFirstChild("Rise")

					if rise and rise:IsA("Animation") then
						local track = animator:LoadAnimation(rise)

						if track then
							if waitForAnimationEnd(track, 5) then
								v4 = true
							else
								warn("[BlottAbility] Rise animation did not complete or timed out.")
							end
						end
					end
				end
			end

			if not v4 then
				warn("[BlottAbility] Rise animation not found, failed to play, or did not complete. Waiting fallback time.")
				task.wait(0.5)
			end

			if not (clone and clone.Parent) then
				warn("[BlottAbility] Decoy was destroyed before Rise animation sequence could complete fully. Skipping final transparency set.")
				return
			end

			for _, part in ipairs(clone:GetDescendants()) do
				if not part:IsA("BasePart") then
					continue
				end

				if part == clone.PrimaryPart or part.Name == "RootPart" then
					part.Transparency = 1
				elseif CollectionService:HasTag(part, "StayTransparent") then
					part.Transparency = 0.5
				else
					part.Transparency = 0
				end
			end
		end)
		task.spawn(function()
			task.wait((value or 200) - 0.5)

			if clone and clone.Parent and not clone:GetAttribute("IsDestroying") then
				triggerAnimatedDestruction(clone, v)
			end
		end)

		if v then
			local diedConnection = nil
			diedConnection = v.Died:Connect(function()
				if diedConnection then
					diedConnection:Disconnect()
				end

				if clone and clone.Parent and not clone:GetAttribute("IsDestroying") then
					triggerAnimatedDestruction(clone, v)
				end
			end)
		end

		task.spawn(function()
			task.wait(0.1)

			if clone and clone.Parent and not clone:GetAttribute("IsDestroying") then
				pcall(function()
					if clone and clone:FindFirstChild("StealthLevel") then
						clone.StealthLevel.Value = -2
					end

					local currentRoom = workspace:FindFirstChild("CurrentRoom")
					local monsters = currentRoom and currentRoom:FindFirstChild("Monsters")

					if monsters then
						for _, child in pairs(monsters:GetChildren()) do
							local chaser = child:FindFirstChild("Chaser")

							if not chaser then
								continue
							end

							local attackCooldown = chaser:FindFirstChild("AttackCooldown")

							if attackCooldown then
								attackCooldown.Value = 0
							end

							local calculatingPath = chaser:FindFirstChild("CalculatingPath")

							if calculatingPath then
								calculatingPath.Value = false
							end

							local chasing = chaser:FindFirstChild("Chasing")

							if chasing then
								chasing.Value = clone
							end

							local attacking = chaser:FindFirstChild("Attacking")

							if attacking then
								attacking.Value = true
							end
						end
					end
				end)
			end
		end)
	end)

	if success then
		return clone
	end

	warn("[BlottAbility] P μεγάλη αποτυχία (Pcall failed) to create decoy:", result)

	if clone then
		clone:Destroy()
	end

	return nil
end

function BlottAbility.GetTapeCost()
	local count = 0
	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if inGamePlayers then
		for _, child in ipairs(inGamePlayers:GetChildren()) do
			if TowerLUT:GetEffectiveTower(child) == tower then
				count += 1
			end
		end
	end

	return not (count > 1) and 10 or count * 10
end

function BlottAbility.HasEnoughTapes(instance, p)
	return p <= (instance:GetAttribute("Tapes") or 0)
end

function BlottAbility.DeductTapes(instance, p)
	instance:SetAttribute("Tapes", (math.max(0, (instance:GetAttribute("Tapes") or 0) - p)))
end

function BlottAbility.UseDecoyAbility(instance, p, p2, p3)
	if not BlottAbility.CanUseDecoy(instance, p) then
		return p, nil
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if not playerFromCharacter then
		return p, nil
	end

	local tapeCost = BlottAbility.GetTapeCost()

	if BlottAbility.HasEnoughTapes(playerFromCharacter, tapeCost) then
		BlottAbility.DeductTapes(playerFromCharacter, tapeCost)
		local decoy = BlottAbility.CreateDecoy(instance, p2, p3)

		if not decoy then
			return p, decoy
		end

		p.lastDecoyTime = tick()
		p.activeDecoy = decoy
		instance:SetAttribute("HasActiveDecoy", true)
		local displayMessage = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DisplayMessage")

		if displayMessage then
			displayMessage:FireClient(
				playerFromCharacter,
				"Decoy deployed! Cost: " .. tapeCost .. " tapes.",
				Color3.fromRGB(0, 200, 255)
			)
		end

		task.spawn(function()
			local lastTime = tick()

			while decoy and decoy.Parent and tick() - lastTime < 201 do
				task.wait(0.5)
			end

			if instance and instance.Parent then
				instance:SetAttribute("HasActiveDecoy", false)

				if p then
					p.activeDecoy = nil
				end
			end
		end)
		return p, decoy
	else
		local displayMessage = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DisplayMessage")

		if displayMessage then
			displayMessage:FireClient(
				playerFromCharacter,
				"Not enough tapes! This ability costs " .. tapeCost .. " tapes.",
				Color3.fromRGB(255, 100, 100)
			)
		end

		return p, nil
	end
end

function BlottAbility.DestroyActiveDecoy(instance, p)
	if not (p and p.activeDecoy) then
		return p
	end

	local activeDecoy = p.activeDecoy

	if activeDecoy and activeDecoy.Parent then
		local humanoid = activeDecoy:FindFirstChild("Humanoid")

		if humanoid and humanoid.Health > 0 then
			humanoid.Health = 0
		else
			activeDecoy:Destroy()
		end
	end

	p.activeDecoy = nil

	if instance and instance.Parent then
		instance:SetAttribute("HasActiveDecoy", false)
	end

	return p
end

return BlottAbility