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
		local canCollectQuest, v = module.Shared.Quests.CanCollectQuest("Cursed Academy", "Main", p2)

		if canCollectQuest then
			return {
				{
					Text = "My shadows have been restless. Something is drawing curses toward the academy."
				},
				{
					Text = "Push back the threats outside the grounds. I choose who I protect, and today that includes everyone here.",
					Options = {
						{
							Text = "Accept Quest",
							Color = Color3.new(0, 1, 0),
							Callback = function()
								module.Signal:Fire("General", "Quests", "Collect", "Main", "Cursed Academy")
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

		local formatted = `Something is interfering with my shadows, {p.DisplayName}. Give me a moment to focus, then try again.`

		if v == "AlreadyCollected" then
			if module.Shared.Quests.GetQuestProgress("Cursed Academy", "Main", p2) >= 1 then
				return {
					{
						Text = `It's quiet again, {p.DisplayName}. You kept them safe. Take these 25,000 Yen from the mission fund. The strength you earned is yours to keep.`,
						Options = {
							{
								Text = "Claim Reward",
								Color = Color3.new(0, 1, 0),
								Callback = function()
									module.Signal:Fire("General", "Quests", "Claim", "Main", "Cursed Academy")
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

			formatted = `The shadows are still moving, {p.DisplayName}. Check the remaining targets in your quest list. We can't leave a threat behind the students.`
		elseif v == "Claimed" or v == "MaxCompletions" then
			formatted = `The academy is safe for now, {p.DisplayName}. You've done enough here. Save your strength for the next person who needs it.`
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