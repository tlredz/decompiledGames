local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.CAM.Global.BunchaIcons)
local v = nil

local function utility()
	if v == nil then
		local Utility = require(ReplicatedStorage.CAM.Global.Utility)
		v = Utility
	end

	return v
end

local isServer = RunService:IsServer()
local v2 = {
	Slayer = "Slayers",
	Demon = "Demons"
}
local PlayerProgression = {
	Progressers = {
		Slayers = {
			["Small Gourd"] = 25,
			["Medium Gourd"] = 100,
			["Large Gourd"] = 300
		},
		Demons = {
			["Weak Soul"] = 5,
			["Strong Soul"] = 10,
			["Brave Soul"] = 25
		}
	},
	Levels = {
		{
			Max = 2000,
			Stats = {
				Demons = {},
				Slayers = {}
			},
			Rewards = {
				Demons = {},
				Slayers = {}
			}
		},
		{
			Max = 3000,
			Stats = {
				Demons = {
					["Max Health"] = 50,
					["Max Health Factor"] = 0.05,
					Illumination = 0.2
				},
				Slayers = {
					["Max Health"] = 50,
					["Max Health Factor"] = 0.05,
					["Max Stamina"] = 15
				}
			},
			Rewards = {
				Demons = {
					Exp = 2000,
					Wen = 1800
				},
				Slayers = {
					Exp = 2000,
					Wen = 1800
				}
			}
		},
		{
			Max = 7000,
			Stats = {
				Demons = {
					["Max Health"] = 75,
					["Max Health Factor"] = 0.07,
					["Health Regen Speed"] = 0.1
				},
				Slayers = {
					["Max Health"] = 75,
					["Max Health Factor"] = 0.07,
					["Max Stamina"] = 25
				}
			},
			Rewards = {
				Demons = {
					Exp = 5000,
					Wen = 4000
				},
				Slayers = {
					Exp = 5000,
					Wen = 4000
				}
			}
		},
		{
			Max = 1,
			Stats = {
				Demons = {
					["Max Health"] = 100,
					["Max Health Factor"] = 0.08,
					Illumination = 0.15,
					["Evil Art Damage Factor"] = 0.04,
					["Additional Damage"] = 2
				},
				Slayers = {
					["Max Health"] = 100,
					["Max Health Factor"] = 0.08,
					["Breathing Boost"] = true
				}
			},
			Rewards = {
				Demons = {
					Exp = 12000,
					Wen = 10000
				},
				Slayers = {
					Exp = 12000,
					Wen = 10000
				}
			}
		}
	},
	Sides = table.freeze({ "Slayer", "Demon" }),
	GrantedSkills = {
		["Breathing Boost"] = {
			Side = "Slayer",
			Skill = {
				Name = "Breathing Boost",
				CoolDown = 30,
				icon = "rbxassetid://87454770374594",
				SkillStats = {}
			}
		}
	}
}

function PlayerProgression.HasGrantedSkill(p, p2: string)
	local grantedSkill = PlayerProgression.GrantedSkills[p2]
	local side

	if grantedSkill ~= nil then
		side = grantedSkill.Side
	end

	if side == nil or table.find(PlayerProgression.SidesFor(p), side) == nil then
		return false
	end

	return PlayerProgression.HasPerk(p, side, p2)
end

local v3 = {
	Hybrid = table.freeze({ "Slayer", "Demon" }),
	Demon = table.freeze({ "Demon" })
}
local frozen = table.freeze({ "Slayer" })

local function sideKey(p: string)
	return v2[p]
end

function PlayerProgression.ResolveSide(value)
	if type(value) ~= "string" then
		return nil
	end

	local v4 = string.lower(value)

	for _, side in PlayerProgression.Sides do
		if string.lower(side) == v4 then
			return side
		end
	end

	return nil
end

function PlayerProgression.SidesFor(p)
	if p == nil then
		return frozen
	end

	if v == nil then
		local Utility = require(ReplicatedStorage.CAM.Global.Utility)
		v = Utility
	end

	local data = v.GetData(p)
	local race = data ~= nil and data:FindFirstChild("Race") or nil

	if race == nil or not race:IsA("ValueBase") then
		return frozen
	end

	return v3[race.Value] or frozen
end

function PlayerProgression.MaxLevel()
	return #PlayerProgression.Levels
end

function PlayerProgression.LevelOfMax(p: number)
	for k, level in PlayerProgression.Levels do
		if level.Max == p then
			return k
		end
	end

	for k, level in PlayerProgression.Levels do
		if p < level.Max then
			return k
		end
	end

	return PlayerProgression.MaxLevel()
end

function PlayerProgression.MaxForLevel(p: number)
	local level = PlayerProgression.Levels[p]
	return level ~= nil and level.Max or nil
end

function PlayerProgression.NextMax(p: number)
	return PlayerProgression.MaxForLevel(p + 1) or PlayerProgression.MaxForLevel(p) or PlayerProgression.Levels[1].Max
end

function PlayerProgression.GetLevelData(p: number)
	return PlayerProgression.Levels[p]
end

function PlayerProgression.GetFolder(p, childName: string, flag: boolean?)
	local v4 = v2[childName]

	if p == nil or v4 == nil then
		return nil
	end

	if v == nil then
		local Utility = require(ReplicatedStorage.CAM.Global.Utility)
		v = Utility
	end

	local data = v.GetData(p, flag == true)

	if data == nil then
		return nil
	end

	local progression = data:FindFirstChild("Progression")
	return progression ~= nil and progression:FindFirstChild(childName) or nil
end

local function barValues(p, p2: string)
	local folder = PlayerProgression.GetFolder(p, p2)

	if folder == nil then
		return nil, nil
	end

	local current = folder:FindFirstChild("Current")
	local max = folder:FindFirstChild("Max")

	if current == nil or not current:IsA("ValueBase") or typeof(current.Value) ~= "number" then
		return nil, nil
	end

	if max == nil or not max:IsA("ValueBase") or typeof(max.Value) ~= "number" then
		return nil, nil
	end

	return current, max
end

function PlayerProgression.Get(p, p2: string)
	local v4, v5 = barValues(p, p2)

	if v4 == nil or v5 == nil then
		return nil
	end

	return {
		Current = v4.Value,
		Max = v5.Value
	}
end

function PlayerProgression.GetCurrent(p, p2: string)
	local v4 = PlayerProgression.Get(p, p2)
	return v4 ~= nil and v4.Current or 0
end

function PlayerProgression.GetMax(p, p2: string)
	local v4 = PlayerProgression.Get(p, p2)
	return v4 ~= nil and v4.Max or PlayerProgression.Levels[1].Max
end

function PlayerProgression.GetLevel(p, p2: string)
	local v4 = PlayerProgression.Get(p, p2)

	if v4 == nil then
		return 1
	end

	return PlayerProgression.LevelOfMax(v4.Max)
end

function PlayerProgression.Fraction(p, p2: string)
	local v4 = PlayerProgression.Get(p, p2)

	if v4 == nil or v4.Max <= 0 then
		return 0
	end

	return (math.clamp(v4.Current / v4.Max, 0, 1))
end

function PlayerProgression.Remaining(p, p2: string)
	local v4 = PlayerProgression.Get(p, p2)

	if v4 == nil then
		return PlayerProgression.Levels[1].Max
	end

	return (math.max(v4.Max - v4.Current, 0))
end

function PlayerProgression.IsMaxLevel(p, p2: string)
	return PlayerProgression.GetLevel(p, p2) >= PlayerProgression.MaxLevel()
end

function PlayerProgression.GetStats(p: string, p2: number)
	local v4 = v2[p]
	local level = PlayerProgression.Levels[p2]

	if v4 == nil or level == nil then
		return {}
	end

	return level.Stats[v4] or {}
end

function PlayerProgression.GetRewards(p: string, p2: number)
	local v4 = v2[p]
	local level = PlayerProgression.Levels[p2]

	if v4 == nil or level == nil or level.Rewards == nil then
		return {}
	end

	return level.Rewards[v4] or {}
end

function PlayerProgression.GetEarnedStats(p: string, p2: number)
	local result = {}

	for i = 1, math.min(p2, PlayerProgression.MaxLevel()) do
		for k, v4 in PlayerProgression.GetStats(p, i) do
			if type(v4) == "number" then
				local v5 = result[k]
				result[k] = (type(v5) == "number" and v5 or 0) + v4
			elseif v4 == true then
				result[k] = true
			end
		end
	end

	return result
end

function PlayerProgression.GetPlayerStats(p, p2: string)
	return PlayerProgression.GetEarnedStats(p2, PlayerProgression.GetLevel(p, p2))
end

function PlayerProgression.HasPerk(p, p2: string, p3: string)
	local v4 = PlayerProgression.GetPlayerStats(p, p2)[p3]

	if type(v4) == "number" then
		return v4 ~= 0
	end

	return v4 == true
end

function PlayerProgression.HasFlag(p, p2: string)
	for _, v4 in PlayerProgression.SidesFor(p) do
		if PlayerProgression.HasPerk(p, v4, p2) then
			return true
		end
	end

	return false
end

function PlayerProgression.GetStatTotal(p, p2: string)
	local total = 0

	for _, v4 in PlayerProgression.SidesFor(p) do
		local v5 = PlayerProgression.GetEarnedStats(v4, PlayerProgression.GetLevel(p, v4))[p2]

		if type(v5) == "number" then
			total += v5
		end
	end

	return total
end

function PlayerProgression.GetProgressers(p: string)
	local v4 = v2[p]

	if v4 == nil then
		return {}
	end

	return PlayerProgression.Progressers[v4] or {}
end

function PlayerProgression.ProgressValue(p: string, p2: string)
	return PlayerProgression.GetProgressers(p)[p2] or 0
end

function PlayerProgression.Add(p, p2: string, p3: number)
	if not isServer then
		error("PlayerProgression.Add is server-only")
	end

	local v4, v5 = barValues(p, p2)

	if v4 == nil or v5 == nil or p3 == 0 then
		return 0
	end

	local levelOfMax = PlayerProgression.LevelOfMax(v5.Value)
	local v6 = 0

	while p3 > 0 do
		local v7 = math.min(math.max(v5.Value - v4.Value, 0), p3)
		v4.Value += v7
		p3 -= v7

		if v4.Value < v5.Value then
			break
		end

		if PlayerProgression.MaxLevel() <= levelOfMax then
			v4.Value = v5.Value
			break
		end

		levelOfMax += 1
		v4.Value = 0
		v5.Value = PlayerProgression.Levels[levelOfMax].Max
		v6 += 1
	end

	while p3 < 0 do
		local v7 = math.min(v4.Value, -p3)
		v4.Value -= v7
		p3 += v7

		if p3 >= 0 then
			break
		end

		if levelOfMax <= 1 then
			v4.Value = 0
			return v6
		end

		levelOfMax -= 1
		v5.Value = PlayerProgression.Levels[levelOfMax].Max
		v4.Value = v5.Value
		v6 -= 1
	end

	return v6
end

function PlayerProgression.AddFrom(p, p2: string, p3: string, value: number?)
	local progressValue = PlayerProgression.ProgressValue(p2, p3)

	if progressValue == 0 then
		return 0
	end

	return PlayerProgression.Add(p, p2, progressValue * (value or 1))
end

function PlayerProgression.SetLevel(p, p2: string, p3: number)
	if not isServer then
		error("PlayerProgression.SetLevel is server-only")
	end

	local v4, v5 = barValues(p, p2)

	if v4 == nil or v5 == nil then
		return nil
	end

	local v6 = math.clamp(math.floor(p3), 1, PlayerProgression.MaxLevel())
	v4.Value = 0
	v5.Value = PlayerProgression.Levels[v6].Max
	return v6
end

function PlayerProgression.Listen(p, p2: string, callback)
	local connections = {}
	local v4 = true
	task.spawn(function()
		local folder = PlayerProgression.GetFolder(p, p2, true)

		if not v4 or folder == nil then
			return
		end

		local v5, v6 = barValues(p, p2)

		if v5 == nil or v6 == nil then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function fire()
			if not v4 then
				return
			end

			callback(v5.Value, v6.Value, PlayerProgression.LevelOfMax(v6.Value))
		end

		table.insert(connections, v5:GetPropertyChangedSignal("Value"):Connect(fire))
		table.insert(connections, v6:GetPropertyChangedSignal("Value"):Connect(fire))
		fire() -- equivalent call inferred; original call site unknown
	end)
	return function()
		v4 = false

		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)
	end
end

return PlayerProgression