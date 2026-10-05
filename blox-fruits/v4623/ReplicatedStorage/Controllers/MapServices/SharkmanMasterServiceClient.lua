local NPCTable = require(game.ReplicatedStorage.NPCTable)
local Net = require(game.ReplicatedStorage.Modules.Net)
require(game.ReplicatedStorage.Util.runAsync)
local IrisLog = require(game.ReplicatedStorage.Util.IrisLog)
local sharkmanMaster = IrisLog.new("SharkmanMaster", nil, {
	Hidden = true
})
require(script.Types)
local v = nil
local SharkmanMasterServiceClient = {
	Enabled = true,
	BeltStages = {
		{
			Name = "Headband (White)",
			Color = "White",
			Color3 = Color3.new(1, 1, 1),
			Stage = 1,
			MinigameStats = {
				Health = 50,
				EnemyPrecisionMultiplier = 0.75,
				PrecisionRequiredMultiplier = 0.6,
				SpeedMultiplier = 0.5,
				GreenZoneMoves = false,
				EnemyFishName = "Angelfish"
			}
		},
		{
			Name = "Headband (Yellow)",
			Color = "Yellow",
			Color3 = Color3.new(1, 0.886275, 0.0392157),
			Stage = 2,
			MinigameStats = {
				Health = 75,
				EnemyPrecisionMultiplier = 0.8,
				PrecisionRequiredMultiplier = 0.7,
				SpeedMultiplier = 0.6,
				GreenZoneMoves = false,
				EnemyFishName = "Amber Trout"
			}
		},
		{
			Name = "Headband (Orange)",
			Color = "Orange",
			Color3 = Color3.new(1, 0.603922, 0.0470588),
			Stage = 3,
			MinigameStats = {
				Health = 100,
				EnemyPrecisionMultiplier = 1,
				SpeedMultiplier = 0.7,
				PrecisionRequiredMultiplier = 0.8,
				EnemyFishName = "Bullfish"
			}
		},
		{
			Name = "Headband (Green)",
			Color = "Green",
			Color3 = Color3.new(0, 0.670588, 0.0235294),
			Stage = 4,
			MinigameStats = {
				Health = 125,
				EnemyPrecisionMultiplier = 1.5,
				SpeedMultiplier = 0.8,
				PrecisionRequiredMultiplier = 1,
				EnemyFishName = "Leafy Trout"
			}
		},
		{
			Name = "Headband (Blue)",
			Color = "Blue",
			Color3 = Color3.new(0.305882, 0.698039, 1),
			Stage = 5,
			MinigameStats = {
				Health = 150,
				EnemyPrecisionMultiplier = 2,
				SpeedMultiplier = 0.9,
				PrecisionRequiredMultiplier = 1.15,
				EnemyFishName = "Frostjaw"
			}
		},
		{
			Name = "Headband (Purple)",
			Color = "Purple",
			Color3 = Color3.new(0.619608, 0.188235, 1),
			Stage = 6,
			MinigameStats = {
				Health = 175,
				EnemyPrecisionMultiplier = 3,
				SpeedMultiplier = 1,
				PrecisionRequiredMultiplier = 1.2,
				EnemyFishName = "Deepglow Oarfish"
			}
		},
		{
			Name = "Headband (Red)",
			Color = "Red",
			Color3 = Color3.new(0.811765, 0, 0),
			Stage = 7,
			MinigameStats = {
				Health = 200,
				EnemyPrecisionMultiplier = 3.5,
				SpeedMultiplier = 1.25,
				PrecisionRequiredMultiplier = 1.5,
				EnemyFishName = "Azure Marlin"
			}
		},
		{
			Name = "Headband (Black)",
			Color = "Black",
			Color3 = Color3.new(0, 0, 0),
			Stage = 8,
			MinigameStats = {
				Health = 200,
				EnemyPrecisionMultiplier = 10,
				SpeedMultiplier = 1,
				PrecisionRequiredMultiplier = 0.8,
				EnemyFishName = "Terrorfish"
			}
		}
	},
	CachedQuestData = nil,
	Upgrades = {
		{
			Name = "Twelve Water Palms",
			RequiredBeltStage = 2,
			FragmentsCost = 2000
		},
		{
			Name = "Pressure Vortex",
			RequiredBeltStage = 5,
			FragmentsCost = 3000
		},
		{
			Name = "Great Sea Spear",
			RequiredBeltStage = 8,
			FragmentsCost = 5000
		}
	}
}

if not SharkmanMasterServiceClient.Enabled then
	return SharkmanMasterServiceClient
end

local function formatBlue(...)
	return (`<Color=Cyan>{...}<Color=/>`)
end

local function formatFragments(p)
	return (`<Color=Purple>ƒ{p}<Color=/>`)
end

local v2 = nil

local function onSharkmanMasterInteracted()
	local v3 = v2:InvokeServer("Check")
	SharkmanMasterServiceClient.CachedQuestData = v3.QuestData and v3.QuestData.SharkQuest
	local currentUTCTime = v3.CurrentUTCTime
	local questData = v3.QuestData
	local v4 = not (questData and questData.SharkQuest) and 0 or questData.SharkQuest.BeltStage or 0

	local function formatTime(p)
		local v5 = math.floor(p / 60)
		local v6 = p % 60
		return string.format("%d:%02d", v5, v6)
	end

	local function getTrainingDialogue()
		if currentUTCTime < questData.SharkQuest.CD then
			local v5 = math.ceil((questData.SharkQuest.CD - currentUTCTime) / 60)
			return {
				Text = { (`I'm too tired to spar with you right now.. I need to rest.\n[{v5} {v5 > 1 and "minutes" or "minute"} remaining]`) }
			}
		else
			return {
				Text = { v4 >= 8 and "There's nothing more I can teach you. I'm more than willing to spar with you again, though." or "You wish to master Sharkman Karate? Defeat me in consecutive battles to earn new belts. But be warned, if you lose even once, you must start over." },
				Option1 = {
					Label = "Start Training",
					JumpTo = function()
						local v5 = nil
						v.resumeWhenCallbackFinishes(function()
							local clone = script.DomainFog:Clone()
							clone.Parent = game.Lighting.LightingLayers
							clone:SetAttribute("Enabled", true)
							clone.Intensity.Value = 0

							if not v2:InvokeServer("Challenge").Success then
								return false
							end

							v5 = false
							return false
						end)
						return v5
					end
				}
			}
		end
	end

	local function getUpgradesDialogue()
		local result = {
			Text = { (`Which {formatBlue("upgrade")} would you like to unlock?`) }
		}

		for i = 1, 3 do
			local upgrade = SharkmanMasterServiceClient.Upgrades[i]
			local v6 = questData.SharkQuest.Upgrades[i]
			local v7 = i
			result[`Option{i}`] = {
				Label = `{upgrade.Name}`,
				JumpTo = function()
					if v4 < upgrade.RequiredBeltStage then
						return {
							Text = { (`Come back when you have earned your {SharkmanMasterServiceClient.BeltStages[upgrade.RequiredBeltStage].Name}`) }
						}
					end

					if not v6.own then
						return {
							Text = { (`Would you like to buy the {formatBlue(upgrade.Name)} upgrade? Just give me {`<Color=Purple>ƒ{upgrade.FragmentsCost}<Color=/>`} for my services.`) },
							Option1 = {
								Label = "Confirm",
								JumpTo = function()
									local v8 = v2:InvokeServer("Upgrade", v7, "Purchase")
									SharkmanMasterServiceClient.CachedQuestData = v8.QuestData and v8.QuestData.SharkQuest

									if v8.Success then
										return {
											Text = { "I have upgraded your ability. Come back any time and I can disable or enable it for you for free." }
										}
									end

									if v8.Reason == "fragments" then
										return {
											Text = { "You don't have enough fragments for that." }
										}
									end
								end
							}
						}
					end

					local v10

					if v6.en then
						v10 = `Would you like to disable your {formatBlue(upgrade.Name)} upgrade? You can re-enable it at any time for free.`
					else
						v10 = `Would you like to re-enable your {formatBlue(upgrade.Name)} upgrade?`
					end

					return {
						Text = { v10 },
						Option1 = {
							Label = "Confirm",
							JumpTo = function()
								local v11 = v2:InvokeServer("Upgrade", v7, "ToggleDisable")
								SharkmanMasterServiceClient.CachedQuestData = v11.QuestData and v11.QuestData.SharkQuest

								if v11.Success then
									return {
										Text = { (`Your {formatBlue(upgrade.Name)} upgrade has been {v6.en and "disabled" or "enabled"}.`) }
									}
								end
							end
						}
					}
				end
			}
		end

		return result
	end

	local function baseDialogue()
		if questData.CanTalk then
			return {
				Text = { (`I am a {formatBlue("Sharkman Karate")} master. I can teach you advanced techniques hidden within this fighting style.`) },
				Option1 = {
					Label = "Train",
					JumpTo = getTrainingDialogue
				},
				Option2 = {
					Label = "Upgrades",
					JumpTo = getUpgradesDialogue
				}
			}
		end

		return {
			Text = { "You are not yet strong enough to learn from my teachings." }
		}
	end

	return {
		Title = "Sharkman Master",
		Get = baseDialogue
	}
end

function SharkmanMasterServiceClient.InitNetwork()
	v2 = Net:RemoteFunction("SharkmanMaster")
end

function SharkmanMasterServiceClient.OnStart()
	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	v = DialogueController
	NPCTable.onLoaded(function(p)
		p.new("Sharkman Master", onSharkmanMasterInteracted, 4)
	end)
	SharkmanMasterServiceClient.InitNetwork()
	task.spawn(function()
		sharkmanMaster:AppendToTab(
			"Progression",
			sharkmanMaster:AuthorityButton("Admin", "Start SharkmanMaster Dialogue", function(_)
				local DialogueController2 = require(game.ReplicatedStorage.DialogueController)
				DialogueController2.start((onSharkmanMasterInteracted()))
			end)
		)
	end)
end

return SharkmanMasterServiceClient