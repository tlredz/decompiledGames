local GingerAbility = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local tower = TowerLUT:GetTower("Ginger")
local module = require(tower)
local IchorTransactions = require(ServerStorage.SharedModules.IchorTransactions)
local ActionEvent = require(ReplicatedStorage.SharedUtils.ActionEvent)
local healRange = module.HealRange
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
require(ReplicatedStorage.SharedData.Christmas25)

local function getHealChannelEvent()
	local events = ReplicatedStorage:FindFirstChild("Events")

	if not events then
		return nil
	end

	local v6 = events:FindFirstChild("GingerHealChannel")

	if not v6 then
		v6 = Instance.new("RemoteEvent")
		v6.Name = "GingerHealChannel"
		v6.Parent = events
	end

	return v6
end

local function countLiveGingers()
	local count = 0
	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if inGamePlayers then
		for _, child in ipairs(inGamePlayers:GetChildren()) do
			if TowerLUT:GetEffectiveTower(child) == tower then
				count += 1
			end
		end
	end

	return count
end

function GingerAbility.GetTapeCost()
	local v6 = countLiveGingers()
	return not (v6 > 1) and 100 or 100 + (v6 - 1) * 50
end

function GingerAbility.GetCooldown()
	local v6 = countLiveGingers()
	return not (v6 > 1) and 100 or 100 + (v6 - 1) * 30
end

local function isGinger(instance)
	local config = instance:FindFirstChild("Config")

	if config then
		local moduleName = config:FindFirstChild("ModuleName")

		if moduleName and moduleName.Value == "Ginger" then
			return true
		end
	end

	return false
end

local function targetNeedsHealing(instance)
	local humanoid = instance:FindFirstChild("Humanoid")
	return not not humanoid and not (humanoid.Health <= 0) and not (humanoid.Health >= humanoid.MaxHealth)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isFloorActive()
	if not workspace.CurrentRoom:FindFirstChildOfClass("Model") then
		return false
	end

	local floorActive = workspace.Info:FindFirstChild("FloorActive")

	if floorActive and floorActive.Value == true then
		return true
	end

	return false
end

local function cleanupFailedHeal(p, instance)
	if instance and v3[instance] == p then
		v3[instance] = nil
	end

	local v6 = v4[p]

	if v6 and v6.notified and v6.target then
		local events = ReplicatedStorage:FindFirstChild("Events")
		local v7

		if events then
			v7 = events:FindFirstChild("GingerHealChannel")

			if not v7 then
				v7 = Instance.new("RemoteEvent")
				v7.Name = "GingerHealChannel"
				v7.Parent = events
			end
		end

		local playerFromCharacter = v7 and Players:GetPlayerFromCharacter(v6.target)

		if playerFromCharacter then
			v7:FireClient(playerFromCharacter, "HealCancelled", p.Name)
		end
	end

	v4[p] = nil
end

local function updatePromptState(instance)
	local v6 = v[instance]

	if not v6 then
		return
	end

	local floorActive = isFloorActive() -- equivalent call inferred; original call site unknown
	local humanoid = instance:FindFirstChild("Humanoid")
	local v7

	if humanoid and not (humanoid.Health <= 0) then
		v7 = not (humanoid.Health >= humanoid.MaxHealth)
	else
		v7 = false
	end

	local enabled = floorActive and v7

	if v6.Enabled and not enabled then
		for character, v10 in pairs(v4) do
			if v10.target ~= instance then
				continue
			end

			local humanoid2 = instance:FindFirstChild("Humanoid")
			local v11

			if not humanoid2 or humanoid2.Health <= 0 then
				v11 = "Target died!"
			elseif humanoid2.Health >= humanoid2.MaxHealth then
				v11 = "Target was healed by someone else!"
			elseif not floorActive then
				v11 = "Floor ended!"
			else
				v11 = nil
			end

			if not v11 then
				break
			end

			local events = ReplicatedStorage:FindFirstChild("Events")
			local v12

			if events then
				v12 = events:FindFirstChild("GingerHealChannel")

				if not v12 then
					v12 = Instance.new("RemoteEvent")
					v12.Name = "GingerHealChannel"
					v12.Parent = events
				end
			end

			local playerFromCharacter = v12 and Players:GetPlayerFromCharacter(character)

			if playerFromCharacter then
				v12:FireClient(playerFromCharacter, "HealFailed", v11)
			end

			cleanupFailedHeal(character, instance)
			break
		end
	end

	v6.Enabled = enabled
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateAllPromptStates()
	for k, _ in pairs(v) do
		if k.Parent then
			updatePromptState(k)
		end
	end
end

local function createPromptOnTarget(child)
	local humanoidRootPart = child:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return nil
	end

	local gingerHealPrompt = humanoidRootPart:FindFirstChild("GingerHealPrompt")

	if gingerHealPrompt then
		v[child] = gingerHealPrompt
		return gingerHealPrompt
	end

	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.Name = "GingerHealPrompt"
	proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	proximityPrompt.HoldDuration = 3
	proximityPrompt.MaxActivationDistance = healRange
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.KeyboardKeyCode = Enum.KeyCode.Pause
	proximityPrompt.GamepadKeyCode = Enum.KeyCode.ButtonR3
	proximityPrompt.ObjectText = ""
	proximityPrompt.ActionText = ""
	proximityPrompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
	proximityPrompt.Enabled = false
	proximityPrompt.Parent = humanoidRootPart
	v[child] = proximityPrompt
	local triggeredConnection = proximityPrompt.Triggered:Connect(function(player)
		local character = player.Character

		if not character then
			return
		end

		local config = character:FindFirstChild("Config")
		local v6

		if config then
			local moduleName = config:FindFirstChild("ModuleName")
			v6 = moduleName and moduleName.Value == "Ginger" and true or false
		else
			v6 = false
		end

		if not v6 then
			return
		end

		if character == child then
			local events = ReplicatedStorage:FindFirstChild("Events")
			local v7

			if events then
				v7 = events:FindFirstChild("GingerHealChannel")

				if not v7 then
					v7 = Instance.new("RemoteEvent")
					v7.Name = "GingerHealChannel"
					v7.Parent = events
				end
			end

			if v7 then
				v7:FireClient(player, "HealFailed", "Can't heal yourself!")
			end
		else
			local v7, v8 = GingerAbility.ExecuteHeal(character, child)

			if not v7 and v8 then
				local events = ReplicatedStorage:FindFirstChild("Events")
				local v9

				if events then
					v9 = events:FindFirstChild("GingerHealChannel")

					if not v9 then
						v9 = Instance.new("RemoteEvent")
						v9.Name = "GingerHealChannel"
						v9.Parent = events
					end
				end

				if v9 then
					v9:FireClient(player, "HealFailed", v8)
				end
			end
		end
	end)
	table.insert(v2, triggeredConnection)
	local humanoid = child:FindFirstChild("Humanoid")

	if humanoid then
		local healthChangedConnection = humanoid.HealthChanged:Connect(function()
			updatePromptState(child)
		end)
		table.insert(v2, healthChangedConnection)
	end

	return proximityPrompt
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removePromptFromTarget(child)
	local v6 = v[child]

	if v6 then
		v6:Destroy()
		v[child] = nil
	end

	local v7 = v3[child]

	if v7 then
		v4[v7] = nil
	end

	v3[child] = nil
end

local function cleanupHealerOnRemove(child)
	if not v5[child] then
		return
	end

	for character, v6 in pairs(v3) do
		if v6 ~= child then
			continue
		end

		v3[character] = nil
		local v7 = v4[child]

		if not (v7 and v7.notified) then
			break
		end

		local events = ReplicatedStorage:FindFirstChild("Events")
		local v8

		if events then
			v8 = events:FindFirstChild("GingerHealChannel")

			if not v8 then
				v8 = Instance.new("RemoteEvent")
				v8.Name = "GingerHealChannel"
				v8.Parent = events
			end
		end

		local playerFromCharacter = v8 and Players:GetPlayerFromCharacter(character)

		if not playerFromCharacter then
			break
		end

		v8:FireClient(playerFromCharacter, "HealCancelled", child.Name)
		break
	end

	v4[child] = nil
	v5[child] = nil
end

function GingerAbility.ExecuteHeal(instance, instance2)
	local effectiveTower = TowerLUT:GetEffectiveTower(instance)

	if effectiveTower == nil or effectiveTower ~= TowerLUT:GetTower("Ginger") then
		cleanupFailedHeal(instance, instance2)
		return false, "You can't heal right now."
	end

	if instance == instance2 then
		cleanupFailedHeal(instance, instance2)
		return false, "Can't heal yourself!"
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if not playerFromCharacter then
		cleanupFailedHeal(instance, instance2)
		return false, "Invalid player"
	end

	local humanoid = instance2:FindFirstChild("Humanoid")

	if not humanoid then
		cleanupFailedHeal(instance, instance2)
		return false, "Invalid target"
	end

	local v6 = v3[instance2]

	if v6 and v6 ~= instance then
		return false, "Target is already being healed!"
	end

	if humanoid.Health <= 0 then
		cleanupFailedHeal(instance, instance2)
		return false, "Target died!"
	end

	if humanoid.Health >= humanoid.MaxHealth then
		cleanupFailedHeal(instance, instance2)
		return false, "Target was healed by someone else!"
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart2 then
		local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude

		if healRange + 2 < magnitude then
			cleanupFailedHeal(instance, instance2)
			return false, "Target moved out of range!"
		end
	end

	-- equivalent call inferred; original call site unknown
	if not isFloorActive() then
		cleanupFailedHeal(instance, instance2)
		return false, "Can't use that Ability in the Elevator!"
	end

	local abilities = instance:FindFirstChild("Abilities")

	if not abilities then
		cleanupFailedHeal(instance, instance2)
		return false, "No abilities"
	end

	local ability1 = abilities:FindFirstChild("Ability1")

	if not ability1 then
		cleanupFailedHeal(instance, instance2)
		return false, "No ability"
	end

	local currentCooldown = ability1:FindFirstChild("CurrentCooldown")

	if not currentCooldown then
		cleanupFailedHeal(instance, instance2)
		return false, "No cooldown"
	end

	if currentCooldown.Value > 0 then
		cleanupFailedHeal(instance, instance2)
		return false, "That Ability is on Cooldown!"
	end

	local child = workspace.Info.PlayerStats:FindFirstChild(instance.Name)

	if not child then
		cleanupFailedHeal(instance, instance2)
		return false, "Stats not found"
	end

	local survivalPoints = child:FindFirstChild("SurvivalPoints")

	if not survivalPoints then
		cleanupFailedHeal(instance, instance2)
		return false, "Stats not found"
	end

	local tapeCost = GingerAbility.GetTapeCost()

	if survivalPoints.Value < tapeCost then
		cleanupFailedHeal(instance, instance2)
		return false, "Not enough tapes!"
	end

	v3[instance2] = nil
	v4[instance] = nil
	survivalPoints.Value -= tapeCost

	if survivalPoints.Value < 0 then
		survivalPoints.Value = 0
	end

	local v7 = humanoid.MaxHealth - humanoid.Health
	humanoid.Health = humanoid.MaxHealth
	ActionEvent:Record(instance, "UseActiveAbility", v7)
	ActionEvent:Record(instance2, "ReceiveActiveAbility", "Ginger", playerFromCharacter and playerFromCharacter.UserId)
	local cooldown = ability1:FindFirstChild("Cooldown")
	currentCooldown.Value = cooldown and cooldown.Value or GingerAbility.GetCooldown()
	task.spawn(function()
		while instance and instance.Parent and currentCooldown.Value > 0 do
			currentCooldown.Value -= 0.1

			if currentCooldown.Value <= 0 then
				currentCooldown.Value = 0
				break
			else
				task.wait(0.1)
			end
		end
	end)
	local events = ReplicatedStorage:FindFirstChild("Events")
	local animateTower = events and events:FindFirstChild("AnimateTower")

	if animateTower then
		animateTower:FireAllClients(instance, "Ability")
	end

	local renderObject = events and events:FindFirstChild("RenderObject")

	if renderObject then
		pcall(function()
			local parts = ReplicatedStorage:FindFirstChild("Parts")

			if parts then
				local renderModules = parts:FindFirstChild("RenderModules")
				local gingerCookie = renderModules and renderModules:FindFirstChild("GingerCookie")

				if gingerCookie then
					renderObject:FireAllClients(gingerCookie, { instance, instance2 })
				end
			end
		end)
	end

	local events2 = ReplicatedStorage:FindFirstChild("Events")
	local v8

	if events2 then
		v8 = events2:FindFirstChild("GingerHealChannel")

		if not v8 then
			v8 = Instance.new("RemoteEvent")
			v8.Name = "GingerHealChannel"
			v8.Parent = events2
		end
	end

	if v8 then
		v8:FireClient(playerFromCharacter, "HealComplete", instance2.Name)
		local playerFromCharacter2 = Players:GetPlayerFromCharacter(instance2)

		if playerFromCharacter2 then
			v8:FireClient(playerFromCharacter2, "HealComplete", instance.Name)
		end
	end

	updatePromptState(instance2)
	local v9 = "GingerAbilityUsed_Floor" .. workspace.Info.Floor.Value
	local attribute = instance:GetAttribute(v9)
	local editData = ReplicatedStorage:FindFirstChild("editData")

	if editData then
		pcall(function()
			editData:Invoke(playerFromCharacter, function(p)
				if p then
					if not attribute and workspace.Info.FloorActive.Value then
						instance:SetAttribute(v9, true)
						local trinkets = instance:FindFirstChild("Trinkets")
						local hasIchorTrinket

						if trinkets then
							local trinket1 = trinkets:FindFirstChild("Trinket1")
							local trinket2 = trinkets:FindFirstChild("Trinket2")
							hasIchorTrinket = trinket1 and trinket1.Value == "UnreleasedIchorItem" and true or trinket2 and trinket2.Value == "UnreleasedIchorItem"
						else
							hasIchorTrinket = false
						end

						local v11 = hasIchorTrinket and 6 or 5
						survivalPoints.Value += 3
						IchorTransactions:GiveIchor(playerFromCharacter, p, v11, true)
						local AnalyticsService = require(ReplicatedStorage.Modules.Services.AnalyticsService)
						AnalyticsService:TrackCoinEarned(playerFromCharacter, v11, "ItemUse", {
							HasIchorTrinket = hasIchorTrinket
						})
						AnalyticsService:TrackItemUsed(playerFromCharacter, "Ginger", "Regular")
					end

					for _, v10 in pairs(p.Data.Mastery) do
						if v10.Name ~= "Ginger" then
							continue
						end

						for _, v11 in pairs(v10.RequirementList) do
							if v11.Name == "ActiveAbilityActivate" then
								v11.Current = math.min(v11.Current + 1, v11.Amount)
							end
						end

						return
					end
				end
			end)
		end)
	end

	local storyEvents = ReplicatedStorage:FindFirstChild("StoryEvents")
	local dialogueEvent = storyEvents and storyEvents:FindFirstChild("DialogueEvent")

	if not dialogueEvent then
		return true, nil
	end

	local dialogueModules = ReplicatedStorage:FindFirstChild("DialogueModules")
	local ginger = dialogueModules and dialogueModules:FindFirstChild("Ginger")

	if ginger then
		local success, result = pcall(require, ginger)

		if success and result.UseAbility then
			dialogueEvent:Fire(instance, "Ginger", result.UseAbility[math.random(1, #result.UseAbility)], 2.5)
		end
	end

	return true, nil
end

function GingerAbility.InitializePrompts(p)
	v5[p] = true
	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if inGamePlayers then
		for _, child in ipairs(inGamePlayers:GetChildren()) do
			if child == p or v[child] then
				continue
			end

			createPromptOnTarget(child)
			updatePromptState(child)
		end

		if not v2._listenersSetup then
			local childAddedConnection = inGamePlayers.ChildAdded:Connect(function(child)
				task.wait(0.5)

				if not v[child] then
					createPromptOnTarget(child)
					updatePromptState(child)
				end
			end)
			table.insert(v2, childAddedConnection)
			local childRemovedConnection = inGamePlayers.ChildRemoved:Connect(function(child)
				removePromptFromTarget(child) -- equivalent call inferred; original call site unknown
				cleanupHealerOnRemove(child)
			end)
			table.insert(v2, childRemovedConnection)
			local floorActive = workspace.Info:FindFirstChild("FloorActive")

			if floorActive then
				local changedConnection = floorActive.Changed:Connect(function()
					updateAllPromptStates() -- equivalent call inferred; original call site unknown
				end)
				table.insert(v2, changedConnection)
			end

			v2._listenersSetup = true
		end
	end

	local events = ReplicatedStorage:FindFirstChild("Events")
	local v6

	if events then
		v6 = events:FindFirstChild("GingerHealChannel")

		if not v6 then
			v6 = Instance.new("RemoteEvent")
			v6.Name = "GingerHealChannel"
			v6.Parent = events
		end
	else
		v6 = nil
	end

	if v6 then
		local onServerEventConnection = v6.OnServerEvent:Connect(function(player, p2, target)
			if player.Character ~= p then
				return
			end

			if p2 == "HealChannelStarted" and target then
				if target == p then
					v6:FireClient(player, "HealFailed", "Can't heal yourself!")
					return
				end

				local v7 = v3[target]

				if v7 and v7 ~= p then
					v6:FireClient(player, "HealFailed", "Target is already being healed!")
					return
				end

				v3[target] = p
				local now = tick()
				v4[p] = {
					target = target,
					startTime = now,
					notified = false
				}
				task.delay(0.5, function()
					local v8 = v4[p]

					if v8 and v8.target == target and v8.startTime == now and not v8.notified then
						v8.notified = true
						local playerFromCharacter = Players:GetPlayerFromCharacter(target)

						if playerFromCharacter then
							v6:FireClient(playerFromCharacter, "BeingHealed", p.Name)
						end
					end
				end)
			elseif p2 == "HealChannelCancelled" then
				local v7 = v4[p]

				if v7 then
					local target2 = v7.target
					local notified = v7.notified

					if target2 and v3[target2] == p then
						v3[target2] = nil
					end

					v4[p] = nil
					local playerFromCharacter = notified and target2 and Players:GetPlayerFromCharacter(target2)

					if playerFromCharacter then
						v6:FireClient(playerFromCharacter, "HealCancelled", p.Name)
					end
				end
			elseif p2 == "MobileHealComplete" then
				local v7 = v4[p]
				local notified = v7 and v7.notified

				if v7 and v7.target and v7.target.Parent then
					target = v7.target
				end

				v4[p] = nil

				if not target then
					warn("[GingerAbility] MobileHealComplete from", player.Name, "with no target and no active channel")
					return
				end

				local v8, v9 = GingerAbility.ExecuteHeal(p, target)
				print("[GingerAbility] MobileHealComplete", player.Name, "->", target.Name, "success:", v8, v9 or "")

				if not v8 and v9 then
					v6:FireClient(player, "HealFailed", v9)
					local playerFromCharacter = notified and Players:GetPlayerFromCharacter(target)

					if playerFromCharacter then
						v6:FireClient(playerFromCharacter, "HealCancelled", p.Name)
					end
				end
			end
		end)
		table.insert(v2, onServerEventConnection)
	end
end

function GingerAbility.CleanupPrompts(p)
	v5[p] = nil
	local v6 = v4[p]

	if v6 then
		local target = v6.target
		local notified = v6.notified

		if target and v3[target] == p then
			v3[target] = nil
		end

		if notified and target then
			local events = ReplicatedStorage:FindFirstChild("Events")
			local v7

			if events then
				v7 = events:FindFirstChild("GingerHealChannel")

				if not v7 then
					v7 = Instance.new("RemoteEvent")
					v7.Name = "GingerHealChannel"
					v7.Parent = events
				end
			end

			local playerFromCharacter = v7 and Players:GetPlayerFromCharacter(target)

			if playerFromCharacter then
				v7:FireClient(playerFromCharacter, "HealCancelled", p.Name)
			end
		end
	end

	v4[p] = nil
	local v7 = false

	for _ in pairs(v5) do
		v7 = true
		break
	end

	if not v7 then
		for _, connection in ipairs(v2) do
			if typeof(connection) == "RBXScriptConnection" then
				connection:Disconnect()
			end
		end

		v2 = {}

		for _, v9 in pairs(v) do
			if v9 then
				v9:Destroy()
			end
		end

		v = {}
		v3 = {}
	end
end

function GingerAbility.UpdateAllPromptStates()
	updateAllPromptStates() -- equivalent call inferred; original call site unknown
end

function GingerAbility.CancelChannel(character, p)
	local v6 = v4[character]

	if not v6 then
		return
	end

	local target = v6.target
	local notified = v6.notified

	if target and v3[target] == character then
		v3[target] = nil
	end

	v4[character] = nil
	local events = ReplicatedStorage:FindFirstChild("Events")
	local v7

	if events then
		v7 = events:FindFirstChild("GingerHealChannel")

		if not v7 then
			v7 = Instance.new("RemoteEvent")
			v7.Name = "GingerHealChannel"
			v7.Parent = events
		end
	end

	if v7 then
		local playerFromCharacter = notified and target and Players:GetPlayerFromCharacter(target)

		if playerFromCharacter then
			v7:FireClient(playerFromCharacter, "HealCancelled", character.Name)
		end

		local playerFromCharacter2 = Players:GetPlayerFromCharacter(character)

		if playerFromCharacter2 and p then
			v7:FireClient(playerFromCharacter2, "HealFailed", p)
		end
	end
end

function GingerAbility.IsChanneling(p)
	return v4[p] ~= nil
end

function GingerAbility.StartChannel()
	return false, "Use ProximityPrompt system"
end

function GingerAbility.FindValidTargets()
	return {}
end

function GingerAbility.CreateHealPrompts()
	return false
end

function GingerAbility.UpdatePromptCosts() end

return GingerAbility