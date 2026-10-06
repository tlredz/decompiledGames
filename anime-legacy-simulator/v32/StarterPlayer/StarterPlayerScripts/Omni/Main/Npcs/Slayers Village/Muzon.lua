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
		local canCollectQuest, v = module.Shared.Quests.CanCollectQuest("Beneath the Crimson Moon", "Side", p2)

		if canCollectQuest then
			return {
				{
					Text = "Six eyes, moonlit blades, and still Kukushibe forgets who rules the night. Such arrogance must be corrected."
				},
				{
					Text = "Defeat Kukushibe once. Return alive, and Chachamare, a quiet messenger of the night, will be yours to ride.",
					Options = {
						{
							Text = "Accept Quest",
							Color = Color3.new(0, 1, 0),
							Callback = function()
								module.Signal:Fire("General", "Quests", "Collect", "Side", "Beneath the Crimson Moon")
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

		local formatted = `Patience, {p.DisplayName}. The night answers to me, and I will summon you when I am ready. Speak to me again shortly.`

		if v == "AlreadyCollected" then
			if module.Shared.Quests.GetQuestProgress("Beneath the Crimson Moon", "Side", p2) >= 1 then
				return {
					{
						Text = `Kukushibe's moonlit blades have fallen silent. Acceptable work, {p.DisplayName}. Take Chachamare. Even the smallest shadow can carry great power.`,
						Options = {
							{
								Text = "Claim Reward",
								Color = Color3.new(0, 1, 0),
								Callback = function()
									module.Signal:Fire("General", "Quests", "Claim", "Side", "Beneath the Crimson Moon")
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

			formatted = `Kukushibe still draws his blade beneath my moon, {p.DisplayName}. Defeat him in Slayers Village. Do not mistake my patience for mercy.`
		elseif v == "Claimed" or v == "MaxCompletions" then
			formatted = `Chachamare already travels at your side, {p.DisplayName}. Our bargain is complete. Go, before the first light finds you.`
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