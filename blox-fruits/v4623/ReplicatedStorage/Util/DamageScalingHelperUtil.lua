local DamageScalingHelperUtil = {
	Config = {
		LevelNeutral = 1,
		LowLevelBias = 0.3,
		MaxLowBiasDelta = 400,
		GroupPenaltyPerExtra = 0.1,
		MaxHitFraction = 0.6,
		HpChipScale = 1,
		EqualizedMultiplier = 1
	},
	PVPConfig = {
		LevelNeutral = 1,
		LowLevelBias = 0.2,
		MaxLowBiasDelta = 300,
		GroupPenaltyPerExtra = 0,
		MaxHitFraction = 0.5,
		HpChipScale = 0,
		EqualizedMultiplier = 1
	}
}

local function CloneConfig(items)
	local result = {}

	for k, item in items do
		result[k] = item
	end

	return result
end

function DamageScalingHelperUtil.GetSchema(p: string?)
	local v = p == "PVP" and "PVP" or "PVE"
	return {
		{
			key = "LevelNeutral",
			min = 0,
			max = 1,
			step = 0.05,
			label = v .. ": level scaling"
		},
		{
			key = "LowLevelBias",
			min = 0,
			max = 1,
			step = 0.05,
			label = v .. ": low level bonus"
		},
		{
			key = "MaxLowBiasDelta",
			min = 50,
			max = 1000,
			step = 50,
			label = v .. ": max level gap for boost"
		},
		{
			key = "GroupPenaltyPerExtra",
			min = 0,
			max = 0.3,
			step = 0.01,
			label = v .. ": group penalty / extra"
		},
		{
			key = "MaxHitFraction",
			min = 0.1,
			max = 1,
			step = 0.05,
			label = v .. ": max HP per hit"
		},
		{
			key = "HpChipScale",
			min = 0,
			max = 1,
			step = 0.05,
			label = v .. ": %HP damage strength"
		},
		{
			key = "EqualizedMultiplier",
			min = 0.1,
			max = 1.5,
			step = 0.05,
			label = v .. ": equalized damage multiplier"
		}
	}
end

local defaultConfig = {}

for k, v2 in DamageScalingHelperUtil.Config do
	defaultConfig[k] = v2
end

DamageScalingHelperUtil.DefaultConfig = defaultConfig
local defaultPVPConfig2 = {}

for k, v3 in DamageScalingHelperUtil.PVPConfig do
	defaultPVPConfig2[k] = v3
end

DamageScalingHelperUtil.DefaultPVPConfig = defaultPVPConfig2

function DamageScalingHelperUtil.ResetProfile(p: string)
	local defaultPVPConfig

	if p == "PVP" then
		defaultPVPConfig = DamageScalingHelperUtil.DefaultPVPConfig
	else
		defaultPVPConfig = DamageScalingHelperUtil.DefaultConfig
	end

	local pVPConfig

	if p == "PVP" then
		pVPConfig = DamageScalingHelperUtil.PVPConfig
	else
		pVPConfig = DamageScalingHelperUtil.Config
	end

	for k, v3 in defaultPVPConfig do
		pVPConfig[k] = v3
	end
end

function DamageScalingHelperUtil.SetParam(p: string, p2: string, p3: number)
	local pVPConfig

	if p == "PVP" then
		pVPConfig = DamageScalingHelperUtil.PVPConfig
	else
		pVPConfig = DamageScalingHelperUtil.Config
	end

	if pVPConfig[p2] ~= nil then
		pVPConfig[p2] = p3
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetLevel(p)
	local data = p and p.Data
	local level = data and data.Level

	if typeof(level) == "number" then
		return level
	end

	return 1
end

local function GetBaseHP(p: number, value: number?)
	if typeof(value) == "number" and value > 0 then
		return value
	end

	return (math.max(p, 1) - 1) * 5 + 100
end

local function CountDealers(p)
	local damages = p and p.Damages

	if not damages then
		return 1
	end

	local count = 0

	for _ in damages do
		count += 1
	end

	return count <= 0 and 1 or count
end

local function GetLevelFactor(data, p: number, p2: number)
	local v3 = math.max(p, 1)
	local v4 = math.max(p2, 1)
	local v5 = (math.log((math.clamp((v3 + 100) / (v4 + 100), 0.2, 5))) + 1.386) / 2.772 * 0.5 + 0.75
	local v6 = math.clamp(data.LevelNeutral, 0, 1)
	local v7 = (v5 - 1) * (1 - v6) + 1

	if data.LowLevelBias > 0 and v3 < v4 then
		local v8 = math.max(data.MaxLowBiasDelta, 1)
		return v7 * (math.clamp(v4 - v3, 0, v8) / v8 * data.LowLevelBias + 1)
	end

	return v7
end

local function ApplyGroupScale(p, p2, p3: number)
	local groupPenaltyPerExtra = p.GroupPenaltyPerExtra

	if groupPenaltyPerExtra <= 0 then
		return p3
	end

	local damages = p2 and p2.Damages
	local v3

	if damages then
		local count = 0

		for _ in damages do
			count += 1
		end

		v3 = count <= 0 and 1 or count
	else
		v3 = 1
	end

	local v4 = math.max(v3 - 1, 0)

	if v4 > 0 then
		p3 *= 1 / (v4 * groupPenaltyPerExtra + 1)
	end

	return p3
end

local function ClampBigHit(p, p2: number, p3: number, p4, p5: number)
	local maxHitFraction = p.MaxHitFraction

	if maxHitFraction <= 0 then
		return p5
	end

	local totalHealth = p4 and p4.TotalHealth

	if typeof(totalHealth) ~= "number" or not (totalHealth > 0) then
		totalHealth = (math.max(p3, 1) - 1) * 5 + 100
	end

	if (p2 + 100) / (p3 + 100) > 1.5 then
		local v3 = totalHealth * maxHitFraction

		if v3 < p5 then
			p5 = v3
		end
	end

	return p5
end

local function EqualizeImpl(data, p, data2, p2: number, p3: string?, _: string?, flag: boolean?)
	local level = GetLevel(p) -- equivalent call inferred; original call site unknown
	local level2 = GetLevel(data2) -- equivalent call inferred; original call site unknown
	local v5

	if flag == true then
		if level - level2 >= 100 then
			v5 = level2
		else
			v5 = level
		end
	else
		v5 = level
	end

	local v6

	if p3 == nil then
		v6 = p2 * GetLevelFactor(data, v5, level2)
	else
		local v7 = p2 * math.clamp(level2 / 17, 1, 1000)
		local totalHealth = data2 and data2.TotalHealth

		if totalHealth and data.HpChipScale > 0 then
			local total = 1

			if data2.ScaleBasedOnDealers then
				local damages = data2.Damages

				if damages then
					for _ in damages do
						total += 0.1
					end
				end
			end

			v7 += totalHealth / 100 * (p2 / 100) * data.HpChipScale / math.max(total, 0.001)
		end

		v6 = v7 * GetLevelFactor(data, v5, level2)
	end

	local groupPenaltyPerExtra = data.GroupPenaltyPerExtra

	if not (groupPenaltyPerExtra <= 0) then
		local damages = data2 and data2.Damages
		local v7

		if damages then
			local count = 0

			for _ in damages do
				count += 1
			end

			v7 = count <= 0 and 1 or count
		else
			v7 = 1
		end

		local v8 = math.max(v7 - 1, 0)

		if v8 > 0 then
			v6 *= 1 / (v8 * groupPenaltyPerExtra + 1)
		end
	end

	local damageMultiplier = 1

	if p then
		if typeof(p.DamageMultiplier) == "number" then
			damageMultiplier = p.DamageMultiplier
		else
			local data3 = p.Data

			if data3 and typeof(data3.DamageMultiplier) == "number" then
				damageMultiplier = data3.DamageMultiplier
			end
		end
	end

	local v7 = v6 * damageMultiplier * math.clamp(data.EqualizedMultiplier, 0, 10)
	local maxHitFraction = data.MaxHitFraction

	if maxHitFraction <= 0 then
		return v7
	end

	local totalHealth = data2 and data2.TotalHealth

	if typeof(totalHealth) ~= "number" or not (totalHealth > 0) then
		totalHealth = (math.max(level2, 1) - 1) * 5 + 100
	end

	if (level + 100) / (level2 + 100) > 1.5 then
		local v8 = totalHealth * maxHitFraction

		if v8 < v7 then
			return v8
		end
	end

	return v7
end

function DamageScalingHelperUtil.Equalize(p, p2, p3: number, p4: string?, p5: string?)
	return (EqualizeImpl(DamageScalingHelperUtil.Config, p, p2, p3, p4, p5))
end

function DamageScalingHelperUtil.EqualizeEventHighOnly(p, p2, p3: number, p4: string?, p5: string?)
	return (EqualizeImpl(DamageScalingHelperUtil.Config, p, p2, p3, p4, p5, true))
end

function DamageScalingHelperUtil.EqualizePvp(p, p2, p3: number, p4: string?, p5: string?)
	return (EqualizeImpl(DamageScalingHelperUtil.PVPConfig, p, p2, p3, p4, p5))
end

local RunService = game:GetService("RunService")

if not RunService:IsServer() then
	return DamageScalingHelperUtil
end

local IrisLog = require(game.ReplicatedStorage.Util.IrisLog)
local damageScaling = IrisLog.new("Damage Scaling", 1, {
	Hidden = true
})

local function fn(p: string)
	local schema = DamageScalingHelperUtil.GetSchema(p)
	damageScaling:AppendToTab(p, damageScaling:AuthorityButton("Tester", "[Reset defaults]", function(_)
		DamageScalingHelperUtil.ResetProfile(p)
		local pVPConfig

		if p == "PVP" then
			pVPConfig = DamageScalingHelperUtil.PVPConfig
		else
			pVPConfig = DamageScalingHelperUtil.Config
		end

		for _, v3 in schema do
			local key = v3.key
			local v4 = pVPConfig[key]
			damageScaling:GetServerState(p .. "_" .. key, v4):set(v4)
		end

		damageScaling:AppendToTab(
			"Log",
			damageScaling:Color("Orange", string.format("[%s] Reset damage scaling config to defaults", p))
		)
	end))
	damageScaling:AppendToTab(p, damageScaling:NewLine())
	damageScaling:AppendToTab(p, damageScaling:Text(" "))
	damageScaling:AppendToTab(p, damageScaling:NewLine())

	for _, v3 in schema do
		local key = v3.key
		local step = v3.step
		local min = v3.min
		local max = v3.max
		local label = v3.label
		local v4

		if p == "PVP" then
			v4 = DamageScalingHelperUtil.PVPConfig
		else
			v4 = DamageScalingHelperUtil.Config
		end

		local v5 = v4[key]
		local v6 = p .. "_" .. key
		local serverState = damageScaling:GetServerState(v6, v5)
		local v12 = key
		local step2 = step
		local min2 = min
		local max2 = max
		local v16 = serverState
		damageScaling:AppendToTab(
			p,
			damageScaling:Text(label .. " "),
			damageScaling:AuthorityButton("Tester", "-", function(p2)
				local v17

				if p == "PVP" then
					v17 = DamageScalingHelperUtil.PVPConfig
				else
					v17 = DamageScalingHelperUtil.Config
				end

				local v18 = math.clamp(v17[key] - step, min, max)
				DamageScalingHelperUtil.SetParam(p, key, v18)
				serverState:set(v18)
				damageScaling:AppendToTab(
					"Log",
					damageScaling:Color("Green", string.format("[%s] %s = %.3f (↓)", p, key, v18))
				)
			end),
			damageScaling:Text(" "),
			damageScaling:ServerState(v6),
			damageScaling:Text(" "),
			damageScaling:AuthorityButton("Tester", "+", function(p2)
				local v17

				if p == "PVP" then
					v17 = DamageScalingHelperUtil.PVPConfig
				else
					v17 = DamageScalingHelperUtil.Config
				end

				local v18 = math.clamp(v17[v12] + step2, min2, max2)
				DamageScalingHelperUtil.SetParam(p, v12, v18)
				v16:set(v18)
				damageScaling:AppendToTab(
					"Log",
					damageScaling:Color("Green", string.format("[%s] %s = %.3f (↑)", p, v12, v18))
				)
			end)
		)
		damageScaling:AppendToTab(p, damageScaling:NewLine())
		damageScaling:AppendToTab(p, damageScaling:Text(" "))
		damageScaling:AppendToTab(p, damageScaling:NewLine())
	end
end

fn("PVE")
fn("PVP")
return DamageScalingHelperUtil