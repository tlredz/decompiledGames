local LoginRewardLibrary = {
	NUM_ONBOARDING_LOGIN_REWARD_MILESTONES = 0,
	NUM_LOOPED_LOGIN_REWARD_MILESTONES = 0,
	OnboardingRewards = {},
	LoopedRewards = {},
	GetLoginRewardInfoFromDay = function(data, p)
		if p <= data.NUM_ONBOARDING_LOGIN_REWARD_MILESTONES then
			return data.OnboardingRewards[p]
		end

		local v = (p - data.NUM_ONBOARDING_LOGIN_REWARD_MILESTONES - 1) % data.NUM_LOOPED_LOGIN_REWARD_MILESTONES + 1
		return data.LoopedRewards[v]
	end
}

local function add_login_reward(p, value, rewards)
	local onboardingRewards

	if p then
		onboardingRewards = LoginRewardLibrary.OnboardingRewards
	else
		onboardingRewards = LoginRewardLibrary.LoopedRewards
	end

	local v = #onboardingRewards + 1
	table.insert(onboardingRewards, {
		LoginRewardID = (p and "LoginRewardOnboarding" or "LoginRewardLooped") .. v,
		Rewards = rewards,
		Title = "Day " .. (v - 1) % 7 + 1,
		Description = value or ""
	})

	if p then
		LoginRewardLibrary.NUM_ONBOARDING_LOGIN_REWARD_MILESTONES += 1
	else
		LoginRewardLibrary.NUM_LOOPED_LOGIN_REWARD_MILESTONES += 1
	end
end

local onboardingRewards = LoginRewardLibrary.OnboardingRewards
local v = #onboardingRewards + 1
table.insert(onboardingRewards, {
	LoginRewardID = "LoginRewardOnboarding" .. v,
	Rewards = {
		{
			Name = "Key",
			Quantity = 1
		}
	},
	Title = "Day " .. (v - 1) % 7 + 1,
	Description = "Welcome!"
})
LoginRewardLibrary.NUM_ONBOARDING_LOGIN_REWARD_MILESTONES += 1
local onboardingRewards2 = LoginRewardLibrary.OnboardingRewards
local v2 = #onboardingRewards2 + 1
table.insert(onboardingRewards2, {
	LoginRewardID = "LoginRewardOnboarding" .. v2,
	Rewards = {
		{
			Name = "Wrap Box",
			Quantity = 1,
			Weapon = "IsRandom"
		}
	},
	Title = "Day " .. (v2 - 1) % 7 + 1,
	Description = ""
})
LoginRewardLibrary.NUM_ONBOARDING_LOGIN_REWARD_MILESTONES += 1
local onboardingRewards3 = LoginRewardLibrary.OnboardingRewards
local v3 = #onboardingRewards3 + 1
table.insert(onboardingRewards3, {
	LoginRewardID = "LoginRewardOnboarding" .. v3,
	Rewards = {
		{
			Name = "Standard Weapon Crate",
			Quantity = 1
		}
	},
	Title = "Day " .. (v3 - 1) % 7 + 1,
	Description = "Free weapon!"
})
LoginRewardLibrary.NUM_ONBOARDING_LOGIN_REWARD_MILESTONES += 1
local onboardingRewards4 = LoginRewardLibrary.OnboardingRewards
local v4 = #onboardingRewards4 + 1
table.insert(onboardingRewards4, {
	LoginRewardID = "LoginRewardOnboarding" .. v4,
	Rewards = {
		{
			Name = "Prize Wheel",
			Quantity = 1,
			Weapon = "IsRandom"
		}
	},
	Title = "Day " .. (v4 - 1) % 7 + 1,
	Description = ""
})
LoginRewardLibrary.NUM_ONBOARDING_LOGIN_REWARD_MILESTONES += 1
local onboardingRewards5 = LoginRewardLibrary.OnboardingRewards
local v5 = #onboardingRewards5 + 1
table.insert(onboardingRewards5, {
	LoginRewardID = "LoginRewardOnboarding" .. v5,
	Rewards = {
		{
			Name = "Finisher Pack",
			Quantity = 1,
			Weapon = "IsRandom"
		}
	},
	Title = "Day " .. (v5 - 1) % 7 + 1,
	Description = "Super cool!"
})
LoginRewardLibrary.NUM_ONBOARDING_LOGIN_REWARD_MILESTONES += 1
local onboardingRewards6 = LoginRewardLibrary.OnboardingRewards
local v6 = #onboardingRewards6 + 1
table.insert(onboardingRewards6, {
	LoginRewardID = "LoginRewardOnboarding" .. v6,
	Rewards = {
		{
			Name = "Key",
			Quantity = 10
		}
	},
	Title = "Day " .. (v6 - 1) % 7 + 1,
	Description = ""
})
LoginRewardLibrary.NUM_ONBOARDING_LOGIN_REWARD_MILESTONES += 1
local onboardingRewards7 = LoginRewardLibrary.OnboardingRewards
local v7 = #onboardingRewards7 + 1
table.insert(onboardingRewards7, {
	LoginRewardID = "LoginRewardOnboarding" .. v7,
	Rewards = {
		{
			Name = "Skin Ticket",
			Quantity = 1
		}
	},
	Title = "Day " .. (v7 - 1) % 7 + 1,
	Description = "Free skins!"
})
LoginRewardLibrary.NUM_ONBOARDING_LOGIN_REWARD_MILESTONES += 1
local loopedRewards = LoginRewardLibrary.LoopedRewards
local v8 = #loopedRewards + 1
table.insert(loopedRewards, {
	LoginRewardID = "LoginRewardLooped" .. v8,
	Rewards = {
		{
			Name = "Key",
			Quantity = 1
		}
	},
	Title = "Day " .. (v8 - 1) % 7 + 1,
	Description = "Claim now!"
})
LoginRewardLibrary.NUM_LOOPED_LOGIN_REWARD_MILESTONES += 1
local loopedRewards2 = LoginRewardLibrary.LoopedRewards
local v9 = #loopedRewards2 + 1
table.insert(loopedRewards2, {
	LoginRewardID = "LoginRewardLooped" .. v9,
	Rewards = {
		{
			Name = "Goodie Bag",
			Quantity = 1,
			Weapon = "IsRandom"
		}
	},
	Title = "Day " .. (v9 - 1) % 7 + 1,
	Description = ""
})
LoginRewardLibrary.NUM_LOOPED_LOGIN_REWARD_MILESTONES += 1
local loopedRewards3 = LoginRewardLibrary.LoopedRewards
local v10 = #loopedRewards3 + 1
table.insert(loopedRewards3, {
	LoginRewardID = "LoginRewardLooped" .. v10,
	Rewards = {
		{
			Name = "Key",
			Quantity = 3
		}
	},
	Title = "Day " .. (v10 - 1) % 7 + 1,
	Description = ""
})
LoginRewardLibrary.NUM_LOOPED_LOGIN_REWARD_MILESTONES += 1
local loopedRewards4 = LoginRewardLibrary.LoopedRewards
local v11 = #loopedRewards4 + 1
table.insert(loopedRewards4, {
	LoginRewardID = "LoginRewardLooped" .. v11,
	Rewards = {
		{
			Name = "Goodie Bag",
			Quantity = 2,
			Weapon = "IsRandom"
		}
	},
	Title = "Day " .. (v11 - 1) % 7 + 1,
	Description = ""
})
LoginRewardLibrary.NUM_LOOPED_LOGIN_REWARD_MILESTONES += 1
local loopedRewards5 = LoginRewardLibrary.LoopedRewards
local v12 = #loopedRewards5 + 1
table.insert(loopedRewards5, {
	LoginRewardID = "LoginRewardLooped" .. v12,
	Rewards = {
		{
			Name = "Goodie Bag",
			Quantity = 3,
			Weapon = "IsRandom"
		}
	},
	Title = "Day " .. (v12 - 1) % 7 + 1,
	Description = ""
})
LoginRewardLibrary.NUM_LOOPED_LOGIN_REWARD_MILESTONES += 1
local loopedRewards6 = LoginRewardLibrary.LoopedRewards
local v13 = #loopedRewards6 + 1
table.insert(loopedRewards6, {
	LoginRewardID = "LoginRewardLooped" .. v13,
	Rewards = {
		{
			Name = "Key",
			Quantity = 5
		}
	},
	Title = "Day " .. (v13 - 1) % 7 + 1,
	Description = ""
})
LoginRewardLibrary.NUM_LOOPED_LOGIN_REWARD_MILESTONES += 1
local loopedRewards7 = LoginRewardLibrary.LoopedRewards
local v14 = #loopedRewards7 + 1
table.insert(loopedRewards7, {
	LoginRewardID = "LoginRewardLooped" .. v14,
	Rewards = {
		{
			Name = "Skin Ticket",
			Quantity = 1
		}
	},
	Title = "Day " .. (v14 - 1) % 7 + 1,
	Description = "Grand prize!"
})
LoginRewardLibrary.NUM_LOOPED_LOGIN_REWARD_MILESTONES += 1
local loopedRewards8 = LoginRewardLibrary.LoopedRewards
local v15 = #loopedRewards8 + 1
table.insert(loopedRewards8, {
	LoginRewardID = "LoginRewardLooped" .. v15,
	Rewards = {
		{
			Name = "Goodie Bag",
			Quantity = 1,
			Weapon = "IsRandom"
		}
	},
	Title = "Day " .. (v15 - 1) % 7 + 1,
	Description = "Claim now!"
})
LoginRewardLibrary.NUM_LOOPED_LOGIN_REWARD_MILESTONES += 1
local loopedRewards9 = LoginRewardLibrary.LoopedRewards
local v16 = #loopedRewards9 + 1
table.insert(loopedRewards9, {
	LoginRewardID = "LoginRewardLooped" .. v16,
	Rewards = {
		{
			Name = "Key",
			Quantity = 3
		}
	},
	Title = "Day " .. (v16 - 1) % 7 + 1,
	Description = ""
})
LoginRewardLibrary.NUM_LOOPED_LOGIN_REWARD_MILESTONES += 1
local loopedRewards10 = LoginRewardLibrary.LoopedRewards
local v17 = #loopedRewards10 + 1
table.insert(loopedRewards10, {
	LoginRewardID = "LoginRewardLooped" .. v17,
	Rewards = {
		{
			Name = "Goodie Bag",
			Quantity = 2,
			Weapon = "IsRandom"
		}
	},
	Title = "Day " .. (v17 - 1) % 7 + 1,
	Description = ""
})
LoginRewardLibrary.NUM_LOOPED_LOGIN_REWARD_MILESTONES += 1
local loopedRewards11 = LoginRewardLibrary.LoopedRewards
local v18 = #loopedRewards11 + 1
table.insert(loopedRewards11, {
	LoginRewardID = "LoginRewardLooped" .. v18,
	Rewards = {
		{
			Name = "Key",
			Quantity = 5
		}
	},
	Title = "Day " .. (v18 - 1) % 7 + 1,
	Description = ""
})
LoginRewardLibrary.NUM_LOOPED_LOGIN_REWARD_MILESTONES += 1
local loopedRewards12 = LoginRewardLibrary.LoopedRewards
local v19 = #loopedRewards12 + 1
table.insert(loopedRewards12, {
	LoginRewardID = "LoginRewardLooped" .. v19,
	Rewards = {
		{
			Name = "Goodie Bag",
			Quantity = 3,
			Weapon = "IsRandom"
		}
	},
	Title = "Day " .. (v19 - 1) % 7 + 1,
	Description = ""
})
LoginRewardLibrary.NUM_LOOPED_LOGIN_REWARD_MILESTONES += 1
local loopedRewards13 = LoginRewardLibrary.LoopedRewards
local v20 = #loopedRewards13 + 1
table.insert(loopedRewards13, {
	LoginRewardID = "LoginRewardLooped" .. v20,
	Rewards = {
		{
			Name = "Key",
			Quantity = 7
		}
	},
	Title = "Day " .. (v20 - 1) % 7 + 1,
	Description = ""
})
LoginRewardLibrary.NUM_LOOPED_LOGIN_REWARD_MILESTONES += 1
local loopedRewards14 = LoginRewardLibrary.LoopedRewards
local v21 = #loopedRewards14 + 1
table.insert(loopedRewards14, {
	LoginRewardID = "LoginRewardLooped" .. v21,
	Rewards = {
		{
			Name = "Prime Goodie Bag",
			Quantity = 1,
			Weapon = "IsRandom"
		}
	},
	Title = "Day " .. (v21 - 1) % 7 + 1,
	Description = "Grand prize!"
})
LoginRewardLibrary.NUM_LOOPED_LOGIN_REWARD_MILESTONES += 1
return LoginRewardLibrary