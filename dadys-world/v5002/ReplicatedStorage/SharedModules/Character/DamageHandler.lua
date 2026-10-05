local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ActionEvent = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("ActionEvent"))
local DamageInterceptors = require(script.Parent:WaitForChild("DamageInterceptors"))

local function getTrinketData(parent)
	local trinkets = parent:FindFirstChild("Trinkets")

	if not trinkets then
		return nil, nil
	end

	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getTrinketInfo(trinket12)
		if not trinket12 then
			return nil
		end

		local v = {
			Name = trinket12.Value or "None",
			Active = 0,
			Value = 0
		}
		local active

		if trinket12:FindFirstChild("Active") then
			active = trinket12.Active.Value or false
		else
			active = false
		end

		v.Active = active
		v.Value = trinket12.Value
		return v
	end

	local trinketInfo = getTrinketInfo(trinket1) -- equivalent call inferred; original call site unknown

	if not trinket2 then
		return trinketInfo, nil
	end

	local v = {
		Name = trinket2.Value or "None",
		Active = 0,
		Value = 0
	}
	local active2

	if trinket2:FindFirstChild("Active") then
		active2 = trinket2.Active.Value or false
	else
		active2 = false
	end

	v.Active = active2
	v.Value = trinket2.Value
	return trinketInfo, v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function grantInvincibility(parent)
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "Invincible"
	boolValue.Parent = parent
	Debris:AddItem(boolValue, 3)
end

local v = {}
local DamageHandler = {}

function DamageHandler.handleDamage(parent, damage: number, p2: string, hitCooldown: number, options)
	local options2 = options or {}
	local stats = parent:FindFirstChild("Stats")

	if stats and stats:FindFirstChild("InElevator") and stats.InElevator.Value == true then
		return false, hitCooldown, false
	end

	if (options2.isDecoy or parent:GetAttribute("DecoyTag") == true) and options2.forceAttackDecoys then
		if parent then
			print("[DamageHandler Debug] Attempting to set decoy health to 0 and make invincible for animation...")
			pcall(function()
				local humanoid = parent:FindFirstChild("Humanoid")

				if humanoid and humanoid.Health > 0 then
					humanoid.Health = 0
					print("[DamageHandler Debug] Set decoy health to 0. BlottAbility should now handle destruction.")

					if not parent:FindFirstChild("Invincible") then
						local boolValue = Instance.new("BoolValue")
						boolValue.Name = "Invincible"
						boolValue.Parent = parent
						Debris:AddItem(boolValue, 5)
						print("[DamageHandler Debug] Added Invincible tag to decoy for " .. 5 .. " seconds.")
					end
				elseif humanoid and humanoid.Health == 0 then
					print("[DamageHandler Debug] Decoy health already 0.")

					if not parent:FindFirstChild("Invincible") then
						local boolValue = Instance.new("BoolValue")
						boolValue.Name = "Invincible"
						boolValue.Parent = parent
						Debris:AddItem(boolValue, 5)
						print("[DamageHandler Debug] Health was 0, added Invincible tag to decoy for " .. 5 .. " seconds.")
					end
				else
					warn("[DamageHandler Debug] Could not find Humanoid in decoy to set health to 0.")
				end
			end)
		end

		return true, hitCooldown, false
	else
		if not options2.skipInvincibilityCheck and parent:FindFirstChild("Invincible") then
			return false, hitCooldown, false
		end

		local humanoid = parent:FindFirstChild("Humanoid")

		if not humanoid or humanoid.Health <= 0 then
			return false, hitCooldown, false
		end

		local trinketData, v3 = getTrinketData(parent)
		local flag = true
		local effectiveHitCooldown = hitCooldown

		local function deactivateTrinket(p4: string)
			local trinkets = parent:FindFirstChild("Trinkets")

			if not trinkets then
				return
			end

			local trinket1 = nil

			if trinkets:FindFirstChild("Trinket1") and trinkets.Trinket1.Value == p4 then
				trinket1 = trinkets.Trinket1
			elseif trinkets:FindFirstChild("Trinket2") and trinkets.Trinket2.Value == p4 then
				trinket1 = trinkets.Trinket2
			end

			if trinket1 and trinket1:FindFirstChild("Active") then
				trinket1.Active.Value = false
				print("[DamageHandler] Deactivated " .. p4 .. " trinket")
			end
		end

		local function processTrinket(p4)
			if not p4 then
				return
			end

			if p4.Name == "CardboardArmor" and flag and options2.isRangedAttack then
				if p4.Active then
					deactivateTrinket("CardboardArmor")
					flag = false
					local success, cardboardArmor = pcall(require, ReplicatedStorage.TrinketData.CardboardArmor)

					if success and cardboardArmor and cardboardArmor.SpecialEvent then
						cardboardArmor.SpecialEvent(parent)
					end
				end
			elseif p4.Name == "SavoryCharm" and flag and p2 ~= "DandyMonster" and p2 ~= "DyleMonster" then
				if p4.Active and humanoid.Health <= damage then
					deactivateTrinket("SavoryCharm")
					flag = false
					local success, savoryCharm = pcall(require, ReplicatedStorage.TrinketData.SavoryCharm)

					if success and savoryCharm and savoryCharm.SpecialEvent then
						savoryCharm.SpecialEvent(parent)
					end
				end
			elseif p4.Name == "BlushyBat" then
				effectiveHitCooldown += 3
			elseif p4.Name ~= "None" and p4.Name ~= "" then
				local success, result = pcall(require, ReplicatedStorage.TrinketData[p4.Name])

				if success and result and result.HasSpecialEvent then
					result.SpecialEvent(parent, effectiveHitCooldown, options2.monster)
				end
			end
		end

		processTrinket(trinketData)
		processTrinket(v3)
		local v5 = false

		if flag then
			local v6 = DamageInterceptors.run(parent, {
				damage = damage,
				monsterName = p2,
				hitCooldown = hitCooldown,
				effectiveHitCooldown = effectiveHitCooldown,
				options = options2
			})

			if v6 and v6.blocked then
				flag = false
				v5 = true
				effectiveHitCooldown += v6.extraHitCooldown or 0
				grantInvincibility(parent) -- equivalent call inferred; original call site unknown
			end
		end

		local playerFromCharacter = Players:GetPlayerFromCharacter(parent)

		if not flag then
			return flag, effectiveHitCooldown, v5
		end

		if humanoid.Health <= damage then
			humanoid.Health = 0
		else
			humanoid.Health -= damage
		end

		if playerFromCharacter then
			pcall(function()
				ActionEvent:Record(
					playerFromCharacter,
					humanoid.Health <= 0 and "KilledByTwisted" or "HurtByTwisted",
					p2
				)
			end)
		end

		if playerFromCharacter then
			for _, callback in ipairs(v) do
				local success, result = pcall(callback, playerFromCharacter, humanoid, p2, options2)

				if not success then
					warn("[DamageHandler] damage listener failed: " .. tostring(result))
				end
			end
		end

		if not options2.skipInvincibility then
			grantInvincibility(parent) -- equivalent call inferred; original call site unknown
		end

		if playerFromCharacter then
			local AnalyticsService = require(ReplicatedStorage.Modules.Services.AnalyticsService)
			AnalyticsService:TrackCustomEvent(playerFromCharacter, "TwistedDamage", {
				Monster = p2
			})
		end

		if options2.onAttackAbility and options2.monster and options2.script then
			options2.onAttackAbility(options2.monster, parent, options2.script)
		end

		return flag, effectiveHitCooldown, v5
	end
end

function DamageHandler.addPlayerDamageListener(p)
	table.insert(v, p)
end

function DamageHandler.blockedAttackerCooldown(p: number, p2: number)
	return math.max(p2 - p, 0) + 3
end

DamageHandler.getTrinketData = getTrinketData

function DamageHandler.handleDecoyDestruction(parent)
	if not parent then
		return
	end

	print("[DamageHandler Debug] Attempting to set decoy health to 0 and make invincible for animation...")
	pcall(function()
		local humanoid = parent:FindFirstChild("Humanoid")

		if humanoid and humanoid.Health > 0 then
			humanoid.Health = 0
			print("[DamageHandler Debug] Set decoy health to 0. BlottAbility should now handle destruction.")

			if not parent:FindFirstChild("Invincible") then
				local boolValue = Instance.new("BoolValue")
				boolValue.Name = "Invincible"
				boolValue.Parent = parent
				Debris:AddItem(boolValue, 5)
				print("[DamageHandler Debug] Added Invincible tag to decoy for " .. 5 .. " seconds.")
			end
		elseif humanoid and humanoid.Health == 0 then
			print("[DamageHandler Debug] Decoy health already 0.")

			if not parent:FindFirstChild("Invincible") then
				local boolValue = Instance.new("BoolValue")
				boolValue.Name = "Invincible"
				boolValue.Parent = parent
				Debris:AddItem(boolValue, 5)
				print("[DamageHandler Debug] Health was 0, added Invincible tag to decoy for " .. 5 .. " seconds.")
			end
		else
			warn("[DamageHandler Debug] Could not find Humanoid in decoy to set health to 0.")
		end
	end)
end

return DamageHandler