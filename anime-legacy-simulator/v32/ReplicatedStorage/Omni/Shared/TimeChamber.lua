local TimeChamber = {
	Enabled = false,
	ReleaseTime = 1791050400,
	RoleAttribute = "TimeChamberRole",
	LeftAttribute = "TimeChamberLeft",
	AllowedScripts = {
		"TimeChamber",
		"Marketplace",
		"Settings",
		"AntiAfk",
		"Analytics",
		"Inbox",
		"Guilds",
		"Profile"
	},
	Roles = {
		Normal = {
			Order = 1,
			EarlyAccess = 0
		},
		["Early Access"] = {
			Order = 2,
			EarlyAccess = 1800,
			Description = "You have the benefit of accessing the game earlier than the other players"
		},
		["Early Access Plus"] = {
			Order = 3,
			EarlyAccess = 1800,
			Description = "You access the game earlier than the other players and receive exclusive rewards"
		},
		Developer = {
			Order = 4,
			Bypass = true
		}
	},
	GroupRanks = {
		[2] = "Early Access",
		[10] = "Early Access Plus",
		[11] = "Early Access Plus",
		[12] = "Early Access Plus",
		[32] = "Early Access",
		[33] = "Early Access Plus"
	},
	Boosts = {
		["V.I.P"] = {
			Order = 1,
			Kind = "Gamepass",
			Multiplier = 0.25,
			Title = "VIP",
			Description = "Earn periodic rewards 25% faster and unlock permanent VIP benefits!",
			Icon = ""
		},
		["Roblox Plus"] = {
			Order = 2,
			Kind = "Premium",
			Multiplier = 0.25,
			Title = "Roblox Plus",
			Description = "Earn periodic rewards 25% faster while you have Roblox Plus!",
			Icon = "rbxasset://textures/ui/PlayerList/PremiumIcon@3x.png",
			Color = Color3.fromRGB(62, 160, 255)
		}
	},
	Confirmed = {
		{
			Time = 900,
			Reward = {
				Type = "Item",
				Name = "Haki Token",
				Amount = 250
			}
		},
		{
			Time = 1800,
			Reward = {
				Type = "Item",
				Name = "Free Gems",
				Amount = 250
			}
		},
		{
			Time = 3600,
			Reward = {
				Type = "Item",
				Name = "Trait Shard",
				Amount = 250
			}
		},
		{
			Time = 7200,
			Reward = {
				Type = "Item",
				Name = "Free Gems",
				Amount = 500
			}
		},
		{
			Time = 10800,
			Reward = {
				Type = "Item",
				Name = "Haki Token",
				Amount = 750
			}
		},
		{
			Time = 14400,
			Reward = {
				Type = "Item",
				Name = "Free Gems",
				Amount = 750
			}
		},
		{
			Time = 21600,
			Reward = {
				Type = "Item",
				Name = "Trait Shard",
				Amount = 750
			}
		},
		{
			Time = 28800,
			Reward = {
				Type = "Item",
				Name = "Free Gems",
				Amount = 1000
			}
		},
		{
			Time = 36000,
			Reward = {
				Type = "Role",
				Name = "Early Access",
				Amount = 1
			},
			Icon = "rbxassetid://78527115084676"
		},
		{
			Time = 43200,
			Reward = {
				Type = "Item",
				Name = "Free Gems",
				Amount = 1500
			}
		},
		{
			Time = 50400,
			Reward = {
				Type = "Mount",
				Name = "Boar",
				Amount = 1
			}
		}
	},
	Periodic = {
		{
			Interval = 150,
			Reward = {
				Type = "Currency",
				Name = "Yen",
				Amount = 10
			}
		}
	},
	Chance = {
		{
			Chance = 10,
			Interval = 180,
			Reward = {
				Type = "Item",
				Name = "Free Gems",
				Amount = 10
			}
		}
	},
	Random = {
		Interval = 300,
		Rewards = {
			{
				Chance = 18.575,
				MinAmount = 5,
				MaxAmount = 5,
				Reward = {
					Type = "Item",
					Name = "Haki Token"
				}
			},
			{
				Chance = 18.575,
				MinAmount = 5,
				MaxAmount = 5,
				Reward = {
					Type = "Item",
					Name = "Trait Shard"
				}
			},
			{
				Chance = 18.575,
				MinAmount = 5,
				MaxAmount = 5,
				Reward = {
					Type = "Item",
					Name = "Slayer Token"
				}
			},
			{
				Chance = 18.575,
				MinAmount = 5,
				MaxAmount = 5,
				Reward = {
					Type = "Item",
					Name = "Breathing Token"
				}
			},
			{
				Chance = 18.575,
				MinAmount = 5,
				MaxAmount = 5,
				Reward = {
					Type = "Item",
					Name = "Adventurer Token"
				}
			},
			{
				Chance = 1.25,
				Reward = {
					Type = "Item",
					Name = "Luck Boost",
					Amount = 1
				}
			},
			{
				Chance = 1.25,
				Reward = {
					Type = "Item",
					Name = "Speed Boost",
					Amount = 1
				}
			},
			{
				Chance = 1.25,
				Reward = {
					Type = "Item",
					Name = "Yen Boost",
					Amount = 1
				}
			},
			{
				Chance = 1.25,
				Reward = {
					Type = "Item",
					Name = "Damage Boost",
					Amount = 1
				}
			},
			{
				Chance = 1.25,
				Reward = {
					Type = "Item",
					Name = "Drops Boost",
					Amount = 1
				}
			},
			{
				Chance = 0.35,
				Reward = {
					Type = "Gamepass",
					Name = "Lucky",
					Amount = 1
				}
			},
			{
				Chance = 0.25,
				Reward = {
					Type = "Gamepass",
					Name = "Big Backpack",
					Amount = 1
				}
			},
			{
				Chance = 0.15,
				Reward = {
					Type = "Gamepass",
					Name = "2x EXP",
					Amount = 1
				}
			},
			{
				Chance = 0.075,
				Reward = {
					Type = "Gamepass",
					Name = "Remote Access",
					Amount = 1
				}
			},
			{
				Chance = 0.05,
				Reward = {
					Type = "Gamepass",
					Name = "Extra Equip",
					Amount = 1
				}
			}
		}
	},
	GetNow = function()
		return workspace:GetServerTimeNow()
	end
}

function TimeChamber.IsRunning()
	return TimeChamber.Enabled and TimeChamber.GetNow() < TimeChamber.ReleaseTime
end

function TimeChamber.GetRole(instance)
	local timeChamberRole = instance:GetAttribute("TimeChamberRole")

	if typeof(timeChamberRole) == "string" and TimeChamber.Roles[timeChamberRole] then
		return timeChamberRole
	end

	return nil
end

function TimeChamber.GetAccessTime(p: string)
	local role = TimeChamber.Roles[p]

	if role and not role.Bypass then
		return TimeChamber.ReleaseTime - (role.EarlyAccess or 0)
	end

	return 0
end

function TimeChamber.HasAccess(p)
	if not TimeChamber.IsRunning() then
		return true
	end

	local role = TimeChamber.GetRole(p)

	if role then
		return TimeChamber.GetNow() >= TimeChamber.GetAccessTime(role)
	end

	return false
end

function TimeChamber.Check(instance)
	if not (TimeChamber.Enabled and instance:GetAttribute("TimeChamberLeft") ~= true) then
		return true
	end

	local role = TimeChamber.GetRole(instance)
	return role ~= nil and TimeChamber.Roles[role].Bypass == true
end

function TimeChamber.GetRemainingTime(p)
	local v = TimeChamber.GetRole(p) or "Normal"
	return (math.max(0, TimeChamber.GetAccessTime(v) - TimeChamber.GetNow()))
end

function TimeChamber.IsScriptAllowed(p: string)
	return table.find(TimeChamber.AllowedScripts, p) ~= nil
end

function TimeChamber.IsBoostActive(instance, p: string)
	local boost = TimeChamber.Boosts[p]

	if not boost then
		return false
	end

	if boost.Kind == "Gamepass" then
		return instance:GetAttribute("VIP") == true
	end

	return boost.Kind == "Premium" and instance.MembershipType == Enum.MembershipType.Premium
end

function TimeChamber.GetMultiplier(p)
	local total = 1

	for k, boost in TimeChamber.Boosts do
		if TimeChamber.IsBoostActive(p, k) then
			total += boost.Multiplier
		end
	end

	return total
end

function TimeChamber.GetRewardKey(p)
	return (`{p.Type}:{p.Name}`)
end

function TimeChamber.IsRandomAvailable(p, p2)
	return p2.Reward.Type ~= "Gamepass" or not (p and p.Gamepasses and p.Gamepasses[p2.Reward.Name])
end

function TimeChamber.GetRandomPool(p)
	local total = 0
	local result = {}

	for k, reward in TimeChamber.Random.Rewards do
		if not TimeChamber.IsRandomAvailable(p, reward) then
			continue
		end

		total += reward.Chance
		table.insert(result, {
			Index = k,
			Info = reward,
			Chance = reward.Chance
		})
	end

	for _, v in result do
		v.Chance = not (total > 0) and 0 or v.Chance / total * 100
	end

	return result
end

function TimeChamber.GetRandomAmountRange(data)
	local minAmount = data.MinAmount or data.Reward.Amount or 1
	return minAmount, (math.max(minAmount, data.MaxAmount or minAmount))
end

function TimeChamber.GetCommercePlayedTime(p, p2: number)
	return (math.max(0, p2 - (p and p.TimeChamber and p.TimeChamber.Time or 0)))
end

return TimeChamber