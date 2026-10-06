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
		local canCollectQuest, v = module.Shared.Quests.CanCollectQuest("Heaven Island", "Main", p2)

		if canCollectQuest then
			return {
				{
					Text = "A sea of clouds, a missing chart, and trouble on every shore. This voyage is getting expensive!"
				},
				{
					Text = "Clear the island's strongest patrols, and I'll chart a safe course to Slayers Village. Try not to sink my profits.",
					Options = {
						{
							Text = "Accept Quest",
							Color = Color3.new(0, 1, 0),
							Callback = function()
								module.Signal:Fire("General", "Quests", "Collect", "Main", "Heaven Island")
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

		local formatted = `The winds are shifting, {p.DisplayName}. Give me a moment to check my charts, then speak to me again.`

		if v == "AlreadyCollected" then
			if module.Shared.Quests.GetQuestProgress("Heaven Island", "Main", p2) >= 1 then
				return {
					{
						Text = `The route is clear, {p.DisplayName}! Here's your passage to Slayers Village. You even came back stronger. That's what I call a profitable voyage!`,
						Options = {
							{
								Text = "Claim Reward",
								Color = Color3.new(0, 1, 0),
								Callback = function()
									module.Signal:Fire("General", "Quests", "Claim", "Main", "Heaven Island")
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

			formatted = `Those patrols are still blocking our route, {p.DisplayName}. Check your quest list and finish clearing the island. My charts won't draw themselves!`
		elseif v == "Claimed" or v == "MaxCompletions" then
			formatted = `Safe sailing, {p.DisplayName}! That route to Slayers Village is yours now. If you find treasure out there, remember who drew the chart.`
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