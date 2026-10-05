local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Combat_presets = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Combat_presets"))
local clock = os.clock
local Checker = {
	Enabled = true,
	Dashing = false,
	Climbing = false,
	Swimming = false,
	ShallowWater = false,
	MobVsMobAttribute = "CanHitMobs",
	DuelAttribute = "DuelId"
}
local v = { "Rasengan_Part" }
local isServer = RunService:IsServer()
local SkillStorage

if isServer then
	local ServerStorage = game:GetService("ServerStorage")
	SkillStorage = require(ServerStorage.SAM.Utility.SkillStorage)
else
	SkillStorage = nil
end

local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local MuzanSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("MuzanSettings"))
local MinigameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("MinigameSettings"))
local Allegiance = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Allegiance"))
local StatsFetch = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("StatsFetch"))
local Character_info_provider = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Character_info_provider"))
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local v2 = { "dodge_left", "dodge_right" }

function Checker.PlayDodge(instance)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local animator

	if humanoid ~= nil then
		animator = humanoid:FindFirstChildOfClass("Animator") or nil
	end

	if animator == nil then
		return
	end

	local v3 = (tonumber(instance:GetAttribute("DodgeSide")) or 0) % #v2 + 1
	instance:SetAttribute("DodgeSide", v3)
	local get_core_anim = Character_info_provider.get_core_anim(instance, v2[v3])

	if get_core_anim == nil then
		return
	end

	local track = animator:LoadAnimation(get_core_anim)
	track.Stopped:Once(function()
		track:Destroy()
	end)
	track:Play()
end

local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local SignalEvent

if isServer then
	SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
else
	SignalEvent = nil
end

function Checker.MinigameSidelined(instance)
	if workspace:GetAttribute("MinigameKey") == nil then
		return false
	end

	return workspace:GetAttribute("MinigameState") == "Lobby" or instance:GetAttribute("Spectating") == true or instance:GetAttribute("MinigameLobby") ~= nil
end

function Checker.DenyLoadoutChange(player)
	if MinigameSettings.Get("LoadoutLockedWhileFielded") ~= true then
		return false
	end

	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

	if workspace:GetAttribute("MinigameState") ~= "Fighting" or Checker.MinigameSidelined(player) or humanoid == nil or humanoid.Health <= 0 then
		return false
	end

	local v3 = {
		Text = "Equipment can only be changed between lives",
		Type = "Denied"
	}

	if SignalEvent == nil then
		ReplicatedStorage.Communication.CnC.Notifications.Notification:Fire("Notify", v3)
	else
		SignalEvent.ToClient(player, "Notify", v3)
	end

	return true
end

function Checker.check(player, childName, p, _)
	local v3 = childName ~= nil and game.ReplicatedStorage.Skills.Misc.Dashes:FindFirstChild(childName) and "Dash" or childName
	local getvaluesfolder = Utility.getvaluesfolder(player)
	local v4 = true
	local v5 = true
	local character

	if player.Parent == game.Players then
		character = player.Character
	else
		character = player
	end

	if character then
		for _, childName2 in pairs(v) do
			if character:FindFirstChild(childName2) ~= nil then
				v5 = false
			end
		end
	end

	local SHC

	if character == nil then
		SHC = false
	else
		SHC = character:FindFirstChild("SHC") or character:FindFirstChild("SHCS")
	end

	local flag = true
	local playerFromCharacter

	if player == nil or player.Parent ~= game.Players or not player then
		if character ~= nil then
			playerFromCharacter = Players:GetPlayerFromCharacter(character) or nil
		end
	else
		playerFromCharacter = player
	end

	if playerFromCharacter ~= nil and playerFromCharacter:GetAttribute(MuzanSettings.LairAttribute) == true and MuzanSettings.LairActionBypasses[p] ~= true then
		flag = false
	end

	local v6

	if playerFromCharacter == nil then
		v6 = false
	else
		v6 = Checker.MinigameSidelined(playerFromCharacter)
	end

	local v7

	if p == "Riding" then
		v7 = getvaluesfolder:FindFirstChild("RidingHorse") ~= nil
	else
		v7 = false
	end

	v7 = v3 ~= "combat" or getvaluesfolder:FindFirstChild("combatdisabled") == nil

	if v6 == false or v3 == "Dash" or v3 == "Run" or v3 == "Double Jump" or v3 == "Climb" then
		if v7 then
			if flag then
				if character == nil or character:FindFirstChild("Transforming_to_mode") ~= nil then
					v7 = false
				elseif getvaluesfolder:FindFirstChild("pause_gameplay") == nil or v7 then
					v7 = getvaluesfolder:FindFirstChild("Stun") == nil and getvaluesfolder:FindFirstChild("CombatStun") == nil or StatsFetch.HasStunBypass(
						character,
						v3
					)

					if v7 then
						if getvaluesfolder:FindFirstChild("Strict_Stun") == nil and (v5 == true or v3 == "Dash" or v3 == "Double_Jump" or v3 == "Run") and character ~= nil and character:FindFirstChild("Humanoid") ~= nil and character.Humanoid.Health > 0 and character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
							v7 = getvaluesfolder:FindFirstChild("Blocking") == nil or StatsFetch.CanPlayOver(
								character,
								v3,
								"Blocking"
							)

							if v7 then
								if getvaluesfolder:FindFirstChild("Swapping") == nil then
									v7 = getvaluesfolder:FindFirstChild("Training") == nil or v3 == "Dash" or v3 == "Run" or v3 == "Double Jump" or p == "Training"
								else
									v7 = false
								end
							end
						else
							v7 = false
						end
					end
				end
			else
				v7 = flag
			end
		end
	else
		v7 = false
	end

	if RunService:IsClient() == true then
		local v8 = (player == nil or character == nil or (SHC == nil or SHC.Value == "" or StatsFetch.CanPlayOver(
			character,
			v3,
			SHC.Value
		)) and getvaluesfolder:FindFirstChild("Using_Skill_Switch") == nil) and true or false

		if Checker.Enabled == true and v8 == true and (Checker.Dashing == false or v3 == "combat" or v3 == "Dash" or v3 == "Double_Jump") and (Checker.Climbing == false or v3 == "Climb") and (Checker.Swimming == false or v3 == "Climb" or v3 == "Run" and Checker.ShallowWater == true) then
			v4 = clock() - Combat_presets.Last_Punched > Combat_presets.slow_walk_duration or v3 == "combat"
		else
			v4 = false
		end
	elseif character ~= nil and SHC ~= nil and SHC.Value ~= "" and not StatsFetch.CanPlayOver(character, v3, SHC.Value) then
		v7 = false
	end

	return v7 == true and v4 == true
end

function Checker.check_can_select(p, p2, p3)
	if p == nil or p2 == nil or p3 == nil then
		return
	end

	local v3 = true

	if Allegiance.Protected(p2, p3) or p3 ~= nil and StatsFetch.HasInvisibility(p3) then
		return false
	end

	return v3
end

function check_iframe(_, instance, instance2)
	local v3 = false

	if not (instance:FindFirstChild("Clone_Owner") or instance2:FindFirstChild("Clone_Owner")) then
		return StatsFetch.GetIFrame(instance2, instance) ~= nil or false
	end

	local v4 = instance:FindFirstChild("Clone_Owner") and instance.Clone_Owner.Value == instance2.Name
	local v5 = instance2:FindFirstChild("Clone_Owner") and instance2.Clone_Owner.Value == instance.Name
	local clone_Owner = instance2:FindFirstChild("Clone_Owner") and instance:FindFirstChild("Clone_Owner")
	local v6

	if clone_Owner then
		v6 = instance2.Clone_Owner.Value == instance.Clone_Owner.Value
	else
		v6 = false
	end

	v3 = v4 or v5 or clone_Owner and v6 or v3
	return StatsFetch.GetIFrame(instance2, instance) ~= nil or v3
end

local ServerStorage = game:GetService("ServerStorage")
local combats

if ServerStorage:FindFirstChild("SAM") == nil then
	combats = nil
else
	combats = game.ServerStorage.SAM.Game_Play.Combats
end

local ServerStorage2 = game:GetService("ServerStorage")
local aiSkills = ServerStorage2:FindFirstChild("AiSkills")

-- equivalent calls inferred from this helper; original call sites unknown
local function moveName(instance)
	if aiSkills ~= nil and instance:IsDescendantOf(aiSkills) then
		return instance.Name
	end

	if instance.Parent == nil then
		return nil
	end

	return instance.Parent.Name
end

local function trainingShields(parent, instance)
	local training = instance:FindFirstChild("Training")

	if training == nil then
		return false
	end

	local leashCenter = training:GetAttribute("LeashCenter")
	local leashRadius = training:GetAttribute("LeashRadius")

	if leashCenter == nil or leashRadius == nil then
		return true
	end

	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
	return humanoidRootPart ~= nil and (humanoidRootPart.Position - leashCenter).Magnitude <= leashRadius
end

function Checker.check_victim(instance, instance2, parent, p)
	local v3 = nil

	if parent == nil then
		return
	end

	local isMob = instance2:GetAttribute("IsMob")
	local isMob2 = parent:GetAttribute("IsMob")
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance2)

	if playerFromCharacter == nil then
		local clone_Owner = instance2:FindFirstChild("Clone_Owner")

		if clone_Owner ~= nil and clone_Owner:IsA("StringValue") then
			playerFromCharacter = Players:FindFirstChild(clone_Owner.Value)
		end
	end

	if instance2 ~= parent and playerFromCharacter ~= nil and not isMob2 then
		local playerFromCharacter2 = Players:GetPlayerFromCharacter(parent)

		if playerFromCharacter2 ~= nil and playerFromCharacter2:GetAttribute("Situation") == "Safezone" or playerFromCharacter:GetAttribute("Situation") == "Safezone" then
			return
		end
	end

	if instance2 ~= parent then
		local playerFromCharacter2 = Players:GetPlayerFromCharacter(parent)

		if playerFromCharacter2 ~= nil and playerFromCharacter2:GetAttribute(MuzanSettings.LairAttribute) == true and playerFromCharacter2:GetAttribute("SecondarySituation") == MuzanSettings.LairSituation.SecondaryName then
			return
		end
	end

	if instance2 ~= parent then
		local character

		if playerFromCharacter == nil then
			character = instance2
		else
			character = playerFromCharacter.Character
		end

		local v4

		if character ~= nil then
			v4 = character:GetAttribute(Checker.DuelAttribute)
		end

		if v4 ~= parent:GetAttribute(Checker.DuelAttribute) then
			return
		end
	end

	if instance2 ~= parent and isMob and isMob2 and instance2:GetAttribute(Checker.MobVsMobAttribute) ~= true and parent:GetAttribute(Checker.MobVsMobAttribute) ~= true then
		return
	end

	if instance2 ~= parent and workspace:GetAttribute("MinigameKey") ~= nil then
		local playerFromCharacter2 = Players:GetPlayerFromCharacter(parent)

		if playerFromCharacter2 ~= nil and Checker.MinigameSidelined(playerFromCharacter2) then
			return
		end
	end

	if instance2 ~= parent and MinigameSettings.Get("NoPlayerVersusPlayer") == true and Players:GetPlayerFromCharacter(parent) ~= nil then
		if Players:GetPlayerFromCharacter(instance2) ~= nil then
			return
		end

		local clone_Owner = instance2:FindFirstChild("Clone_Owner")

		if clone_Owner ~= nil and clone_Owner:IsA("StringValue") and Players:FindFirstChild(clone_Owner.Value) ~= nil then
			return
		end
	end

	if Allegiance.Protected(instance2, parent) then
		return
	end

	local humanoid = parent:FindFirstChild("Humanoid")

	if humanoid ~= nil and not humanoid:IsA("Humanoid") then
		humanoid = nil
	end

	local getvaluesfolder = Utility.getvaluesfolder(parent)

	if humanoid == nil or instance == nil or instance2 == nil or parent == nil or parent.Parent == nil or not (humanoid.Health > 0) or getvaluesfolder:FindFirstChild("Swapping") ~= nil or trainingShields(
		parent,
		getvaluesfolder
	) or check_iframe(instance, instance2, parent) ~= false and (not p or p.iframe == nil) then
		return v3
	end

	local v4

	if typeof(p) == "table" then
		v4 = p.NoReactions == true
	else
		v4 = false
	end

	if instance2 ~= parent and not v4 and (p == nil or p and p.iframe == nil) then
		if instance2 ~= parent and isServer and Players:GetPlayerFromCharacter(parent) == nil then
			local npcCounter = parent:GetAttribute("NpcCounter")

			if npcCounter ~= nil then
				local v5

				if combats == nil then
					v5 = false
				else
					v5 = instance:IsDescendantOf(combats)
				end

				if npcCounter == 1 and v5 or npcCounter == 3 and v5 == false or npcCounter == 2 then
					parent:SetAttribute("NpcCounter", nil)
					local objectValue = Instance.new("ObjectValue")
					objectValue.Name = "NpcCounterTriggered"
					objectValue.Value = instance2
					objectValue.Parent = parent
					task.delay(1, function()
						if objectValue.Parent ~= nil then
							objectValue:Destroy()
						end
					end)
					return
				end
			end
		end

		local counter, v5, v6 = StatsFetch.GetCounter(parent, getvaluesfolder)
		local v7

		if combats == nil then
			v7 = false
		else
			v7 = instance:IsDescendantOf(combats)
		end

		if counter and counter > 0 then
			local v8 = (counter == 1 and v7 or counter == 3 and v7 == false) and true or counter == 2 or false

			if v8 and v6 ~= nil and v6:GetAttribute("Record") == true then
				v8 = false
				local name

				if not v7 then
					if aiSkills == nil or not instance:IsDescendantOf(aiSkills) then
						if instance.Parent ~= nil then
							name = instance.Parent.Name
						end
					else
						name = instance.Name
					end
				end

				if name ~= nil then
					local recorded = v6:GetAttribute("Recorded")

					if recorded == nil then
						v6:SetAttribute("Recorded", name)
					elseif recorded == name then
						v6:SetAttribute("Recorded", nil)
						v8 = true
					end
				end
			end

			if v8 then
				local playerFromCharacter2 = game.Players:GetPlayerFromCharacter(parent)

				if SkillStorage ~= nil and playerFromCharacter2 ~= nil then
					local getID = SkillStorage.GetID(playerFromCharacter2, v5)
					getID.CounterTarget = instance2
				end

				EffectsEvent.ToClient(
					playerFromCharacter2,
					"force_skill_actions_server",
					v5,
					"Counter",
					nil,
					true,
					instance2
				)
				return
			end
		end

		local intValue = getvaluesfolder:FindFirstChild(Utility.DODGE_VALUE)

		if intValue == nil or not intValue:IsA("IntValue") or not (intValue.Value > 0) or intValue:GetAttribute("Mode") == "Combat" and not v7 then
			local v8 = false
			local v9 = {}

			if getvaluesfolder:FindFirstChild("SkillToggle") then
				for _, child in pairs(getvaluesfolder:GetChildren()) do
					if not (child.Name == "SkillToggle" and child.Value ~= "" and table.find(v9, child.Value) == nil) then
						continue
					end

					local onlySkill = child:GetAttribute("OnlySkill")

					if onlySkill ~= nil then
						if v7 then
							continue
						end

						local v10 = moveName(instance) -- equivalent call inferred; original call site unknown

						if v10 ~= onlySkill then
							continue
						end
					end

					local latchFor = child:GetAttribute("LatchFor")
					local latch = child:FindFirstChild("Latch")

					if not ((latch == nil or latch.Value == instance2) and child and child:FindFirstChild("Mode")) then
						continue
					end

					if (child.Mode.Value == Menum.toggleSkillMode.combat and v7 == true or child.Mode.Value == Menum.toggleSkillMode.skill and v7 == false or (child.Mode.Value == Menum.toggleSkillMode.all or false)) == true then
						local value = child.Value

						if latch == nil then
							if isServer then
								game.ServerStorage.SAM.Services.Skill_Controller_S.Function:Invoke(
									game.Players:GetPlayerFromCharacter(parent),
									value,
									instance2,
									child.Remaining.Value - 1
								)
							end

							EffectsEvent.ToClient(
								game.Players:GetPlayerFromCharacter(parent),
								"force_skill_actions_server",
								value,
								"Toggle",
								nil,
								false,
								instance2,
								child.Remaining.Value - 1
							)
						end

						v8 = child.Type.Value == Menum.toggleSkillType.iframe or v8
					end

					table.insert(v9, child.Value)

					if latchFor == nil then
						if child.Remaining.Value > 1 then
							child.Remaining.Value -= 1
						else
							child:Destroy()
						end
					elseif latch == nil and isServer then
						local objectValue = Instance.new("ObjectValue")
						objectValue.Name = "Latch"
						objectValue.Value = instance2
						objectValue.Parent = child
						DebrisModule:AddItem(child, latchFor)
					end
				end
			end

			if v8 then
				return
			end
		else
			if not isServer then
				return
			end

			intValue.Value -= 1

			if intValue.Value <= 0 then
				intValue:Destroy()
			end

			Checker.PlayDodge(parent)
			return
		end
	end

	if getvaluesfolder:FindFirstChild("Blocking") == nil or getvaluesfolder:FindFirstChild("PierceBlock") ~= nil then
		return true
	elseif getvaluesfolder:FindFirstChild("Blocking") ~= nil and false == false and false == false then
		return getvaluesfolder.Blocking:FindFirstChild("Perfect") == nil and (not isMob or getvaluesfolder.Blocking:FindFirstChild("PerfectNpc") == nil) and "Blocking" or "Perfect"
	end

	return v3
end

return Checker