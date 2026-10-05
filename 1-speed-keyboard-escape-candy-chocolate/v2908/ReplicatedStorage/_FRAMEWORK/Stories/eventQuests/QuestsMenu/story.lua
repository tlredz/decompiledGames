local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UILabs = require(ReplicatedStorage.Packages["UI-Labs"])
local Vide = require(ReplicatedStorage.Packages.Vide)
local EventsConfig = require(ReplicatedStorage.EventsConfig)
local QuestsMenu = require(ReplicatedStorage._FRAMEWORK.Features.eventQuests.QuestsMenu)
local Themes = require(ReplicatedStorage._FRAMEWORK.Features.eventQuests.Themes)
require(ReplicatedStorage._FRAMEWORK.Features.eventQuests.Types)
local v = {
	halloween = "CandyCorn",
	summer = "SummerCoins"
}
local controls2 = {
	Theme = UILabs.Choose({ "halloween", "summer" }),
	Label = "Run 2000 studs",
	Progress = UILabs.Slider(750, 0, 2000, 1),
	Target = 2000,
	Reward = 300,
	State = UILabs.Choose({ "InProgress", "Completed", "Claimed" })
}

local function currencyIcon(p: string)
	local v3 = ""

	for _, currency in EventsConfig.Currencies do
		if currency.Key == p then
			v3 = "rbxassetid://" .. currency.Icon
		end
	end

	return v3
end

local function story(p)
	local controls = p.controls

	local function quests()
		return {
			{
				id = "run_studs",
				label = controls.Label(),
				progress = controls.Progress(),
				target = controls.Target(),
				reward = controls.Reward(),
				state = controls.State()
			},
			{
				id = "golden_key",
				label = "Get one golden key",
				progress = 1,
				target = 1,
				reward = 400,
				state = "Completed"
			},
			{
				id = "win_button",
				label = "Hit one win button",
				progress = 1,
				target = 1,
				reward = 300,
				state = "Claimed"
			}
		}
	end

	return QuestsMenu({
		Theme = function()
			return Themes[controls.Theme()]
		end,
		RewardIcon = function()
			local v3 = v[controls.Theme()]
			local v4 = ""

			for _, currency in EventsConfig.Currencies do
				if currency.Key == v3 then
					v4 = "rbxassetid://" .. currency.Icon
				end
			end

			return v4
		end,
		Quests = quests,
		OnClaim = function(p2: string)
			print("[QuestsMenu.story] claim", p2)
		end,
		OnSkip = function(p2: string)
			print("[QuestsMenu.story] skip", p2)
		end,
		OnRefresh = function()
			print("[QuestsMenu.story] refresh")
		end,
		OnClose = function()
			print("[QuestsMenu.story] close")
		end
	})
end

return UILabs.CreateVideStory({
	name = "Event Quests — Menu",
	vide = Vide,
	controls = controls2
}, story)