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
		local canCollectQuest, v = module.Shared.Quests.CanCollectQuest("A Captain's Promise", "Side", p2)

		if canCollectQuest then
			return {
				{
					Text = "I once entrusted a straw hat to the next generation. A true captain knows when to stand against a storm."
				},
				{
					Text = "Anel calls himself a god above these clouds. Defeat him once, and Karu will carry you toward your next adventure.",
					Options = {
						{
							Text = "Accept Quest",
							Color = Color3.new(0, 1, 0),
							Callback = function()
								module.Signal:Fire("General", "Quests", "Collect", "Side", "A Captain's Promise")
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

		local formatted = `Easy there, {p.DisplayName}. Even a captain needs a moment to read the winds. Speak to me again shortly.`

		if v == "AlreadyCollected" then
			if module.Shared.Quests.GetQuestProgress("A Captain's Promise", "Side", p2) >= 1 then
				return {
					{
						Text = `You faced the thunder and stood your ground, {p.DisplayName}. A captain keeps his word. Karu is ready to carry you toward your next adventure!`,
						Options = {
							{
								Text = "Claim Reward",
								Color = Color3.new(0, 1, 0),
								Callback = function()
									module.Signal:Fire("General", "Quests", "Claim", "Side", "A Captain's Promise")
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

			formatted = `Anel still rules the skies, {p.DisplayName}. Defeat him in Heaven Island, then return to me. Courage means sailing straight into the storm.`
		elseif v == "Claimed" or v == "MaxCompletions" then
			formatted = `Karu is yours now, {p.DisplayName}. Look after your companion, keep your promises, and leave the next generation a sea worth sailing.`
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