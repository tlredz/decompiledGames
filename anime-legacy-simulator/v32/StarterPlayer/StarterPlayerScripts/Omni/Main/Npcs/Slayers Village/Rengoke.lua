local module = require("@game/ReplicatedStorage/Omni")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Omni.DataTemplate)
return {
	CustomName = `{script.Name} - Quest Giver`,
	AreaColor = Color3.new(1, 1, 0),
	Markers = {
		Quest = Color3.new(1, 1, 0)
	},
	Dialog = function(p, p2)
		local canCollectQuest, v = module.Shared.Quests.CanCollectQuest("Slayers Village", "Main", p2)

		if canCollectQuest then
			return {
				{
					Text = "Stand tall! A burning heart is worth little unless it lights the way for someone else!"
				},
				{
					Text = "Keep the village safe until dawn. Break the demons assault, and the road to Cursed Academy will be yours.",
					Options = {
						{
							Text = "Accept Quest",
							Color = Color3.new(0, 1, 0),
							Callback = function()
								module.Signal:Fire("General", "Quests", "Collect", "Main", "Slayers Village")
								return "Stop"
							end
						},
						{
							Text = "Maybe Later",
							Color = Color3.new(1, 0, 0),
							Callback = function()
								return "Stop"
							end
						}
					}
				}
			}
		end

		local formatted = `Even a bright flame needs a steady breath, {p.DisplayName}. Give me a moment, then we will speak again!`

		if v == "AlreadyCollected" then
			if module.Shared.Quests.GetQuestProgress("Slayers Village", "Main", p2) >= 1 then
				return {
					{
						Text = `Magnificent, {p.DisplayName}! The village can greet another dawn. Take the road to Cursed Academy, and carry that strength wherever people need you!`,
						Options = {
							{
								Text = "Claim Reward",
								Color = Color3.new(0, 1, 0),
								Callback = function()
									module.Signal:Fire("General", "Quests", "Claim", "Main", "Slayers Village")
									return "Stop"
								end
							},
							{
								Text = "Later",
								Color = Color3.new(1, 0, 0),
								Callback = function()
									return "Stop"
								end
							}
						}
					}
				}
			end

			formatted = `Keep your breathing steady, {p.DisplayName}! Demons still threaten the village. Finish the targets in your quest list and let no one face the darkness alone!`
		elseif v == "Claimed" or v == "MaxCompletions" then
			formatted = `Your courage has already protected this village, {p.DisplayName}! Keep that fire alive on the road ahead. There will always be someone worth defending!`
		end

		return {
			{
				Text = formatted,
				Options = {
					{
						Text = "Understood",
						Color = Color3.new(0, 1, 0),
						Callback = function()
							return "Stop"
						end
					}
				}
			}
		}
	end
}