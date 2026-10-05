local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local PlayerProfile = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("PlayerProfile"))
local Character_info_provider = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Character_info_provider"))
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
local PlayerStatResolver = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("PlayerStatResolver"))
local CombatBalance = require(game.ReplicatedStorage.CAM.Global.CombatBalance)
local Stats = require(game.ReplicatedStorage.CAM.Global.SkillService.Stats)
local _ = string.gsub
local ManageCd = {}
local clock = os.clock
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()

local function scaleCooldown(p, value: number, p2: string)
	if typeof(value) == "number" and not (value <= 0) then
		return value * math.max(
			(1 - (PlayerStatResolver.GetStat(p, "Cooldown Reduction Factor") or 0)) * CombatBalance.CastKnob(
				p,
				p2,
				"Cooldown"
			),
			0.1
		)
	end

	return value
end

function ManageCd.fetch(p, p2: string)
	if p == nil or p2 == nil then
		return 9999
	end

	game.ReplicatedStorage:WaitForChild("Player_Service"):WaitForChild("Data"):WaitForChild(p.Name)
	local get_equipped_tool = Character_info_provider.Get_equipped_tool(p)
	local v = 9999
	local v2 = PlayerProfile.skill_info[p2]

	if not v2 then
		return v
	end

	if typeof(v2.Cooldown) == "number" then
		local cooldown = v2.Cooldown

		if typeof(cooldown) == "number" and not (cooldown <= 0) then
			return cooldown * math.max(
				(1 - (PlayerStatResolver.GetStat(p, "Cooldown Reduction Factor") or 0)) * CombatBalance.CastKnob(
					p,
					p2,
					"Cooldown"
				),
				0.1
			)
		end

		return cooldown
	elseif typeof(v2.Cooldown) == "table" then
		if get_equipped_tool == nil or not v2.Cooldown[get_equipped_tool.Name] then
			for _, v4 in pairs(v2.Cooldown) do
				v = v4
				break
			end
		else
			v = v2.Cooldown[get_equipped_tool.Name]
		end

		if typeof(v) ~= "number" or v <= 0 then
			return v
		end

		return v * math.max(
			(1 - (PlayerStatResolver.GetStat(p, "Cooldown Reduction Factor") or 0)) * CombatBalance.CastKnob(
				p,
				p2,
				"Cooldown"
			),
			0.1
		)
	else
		local defaultSkillCooldown = gameSettings.defaultSkillCooldown or 1

		if typeof(defaultSkillCooldown) == "number" and not (defaultSkillCooldown <= 0) then
			return defaultSkillCooldown * math.max(
				(1 - (PlayerStatResolver.GetStat(p, "Cooldown Reduction Factor") or 0)) * CombatBalance.CastKnob(
					p,
					p2,
					"Cooldown"
				),
				0.1
			)
		end

		return defaultSkillCooldown
	end
end

function ManageCd.skillStatus(player, value: string)
	local SHC = player ~= nil and player.Character ~= nil and (player.Character:FindFirstChild("SHC") or player.Character:FindFirstChild("SHCS"))

	if not SHC then
		return 0, false
	end

	if value == nil then
		value = SHC.Value
	end

	local v = PlayerProfile.skill_info[value]

	if v then
		return v.lastUsed or 0, SHC.Value == value
	end

	return 0, false
end

local function serverLead()
	if isServer then
		return 0.25
	end

	return 0
end

function ManageCd.set_skill_cd(player, p: string, p2: number)
	if player ~= nil and player.Character ~= nil then
		local v = p2 == nil and 9999 or p2
		local SHC = player.Character:FindFirstChild("SHC") or player.Character:FindFirstChild("SHCS")

		if SHC then
			local filter_cd_name = ManageCd.filter_cd_name(player, p)

			if SHC:FindFirstChild(filter_cd_name) ~= nil then
				SHC[filter_cd_name]:Destroy()
			end

			local numberValue = Instance.new("NumberValue")
			numberValue.Name = filter_cd_name
			numberValue.Value = v
			numberValue:SetAttribute("Started", clock())
			numberValue.Parent = SHC
			DebrisModule:AddItem(numberValue, v - (isServer and 0.25 or 0))
			local cooldownGroup = PlayerProfile.skill_info[p].CooldownGroup

			if cooldownGroup ~= nil then
				local now = clock()

				for k, v2 in PlayerProfile.skill_info do
					if not (v2.CooldownGroup == cooldownGroup and k ~= p and Stats.SourceCheck(player, k)) then
						continue
					end

					local _, v3 = Stats.GetRequirements(player, k)

					if not v3 then
						continue
					end

					local filter_cd_name2 = ManageCd.filter_cd_name(player, k)
					local v4 = ManageCd.fetch(player, k) * gameSettings.CooldownGroupShare
					local child = SHC:FindFirstChild(filter_cd_name2)

					if child ~= nil then
						if v4 <= child:GetAttribute("Started") + child.Value - now then
							continue
						else
							child:Destroy()
						end
					end

					local numberValue2 = Instance.new("NumberValue")
					numberValue2.Name = filter_cd_name2
					numberValue2.Value = v4
					numberValue2:SetAttribute("Started", now)
					numberValue2.Parent = SHC
					DebrisModule:AddItem(numberValue2, v4 - (isServer and 0.25 or 0))
				end
			end
		end
	end
end

local name = isServer and "SHCS" or "SHC"

local function ensureSlot(parent)
	local v2 = parent:FindFirstChild(name)

	if v2 ~= nil then
		return v2
	end

	v2 = Instance.new("StringValue")
	v2.Name = name
	v2:SetAttribute("CK", "")
	v2:SetAttribute("en", false)
	v2.Parent = parent
	return v2
end

function ManageCd.RuleEnabled(p: string)
	local skillCooldownRules = gameSettings.SkillCooldownRules
	local v2

	if skillCooldownRules ~= nil then
		v2 = skillCooldownRules[p]
	end

	if v2 == nil or v2.Enabled ~= true then
		return false
	end

	for _, v3 in v2.DisabledPlaces or {} do
		if v3 == game.PlaceId then
			return false
		end
	end

	local pvPModes = v2.PvPModes

	if pvPModes == nil or workspace:GetAttribute("MinigameKey") ~= "PvP" then
		return true
	end

	local minigameGamemode = workspace:GetAttribute("MinigameGamemode")
	local default

	if typeof(minigameGamemode) == "string" then
		default = pvPModes[minigameGamemode]
	end

	if default == nil then
		default = pvPModes.Default
	end

	return default == nil or default == true
end

function ManageCd.snapshot(instance)
	if not ManageCd.RuleEnabled("CarryAcrossDeath") then
		return nil
	end

	local child

	if instance ~= nil then
		child = instance:FindFirstChild(name)
	end

	if child == nil then
		return nil
	end

	local now = clock()
	local result = {}

	for _, numberValue in child:GetChildren() do
		local started = numberValue:GetAttribute("Started")

		if not (numberValue:IsA("NumberValue") and typeof(started) == "number" and now < started + numberValue.Value) then
			continue
		end

		table.insert(result, {
			Name = numberValue.Name,
			CoolDown = numberValue.Value,
			Started = started
		})
	end

	if #result > 0 then
		return result
	end

	return nil
end

function ManageCd.restore(parent, items)
	if parent == nil or items == nil then
		return
	end

	local parent2 = parent:FindFirstChild(name)

	if parent2 == nil then
		parent2 = Instance.new("StringValue")
		parent2.Name = name
		parent2:SetAttribute("CK", "")
		parent2:SetAttribute("en", false)
		parent2.Parent = parent
	end

	local now = clock()
	local v3 = isServer and 0.25 or 0

	for _, item in items do
		local v4 = item.Started + item.CoolDown - now

		if v4 <= v3 or parent2:FindFirstChild(item.Name) ~= nil then
			continue
		end

		local numberValue = Instance.new("NumberValue")
		numberValue.Name = item.Name
		numberValue.Value = item.CoolDown
		numberValue:SetAttribute("Started", item.Started)
		numberValue.Parent = parent2
		DebrisModule:AddItem(numberValue, v4 - v3)
	end
end

function ManageCd.filter_cd_name(p, p2: string)
	if p == nil or p2 == nil then
		return
	else
		return PlayerProfile.skill_info[p2].CoolDownName or p2
	end
end

return ManageCd