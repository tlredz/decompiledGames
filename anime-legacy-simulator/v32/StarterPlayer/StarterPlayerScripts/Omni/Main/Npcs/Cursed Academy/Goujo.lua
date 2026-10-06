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
		local canCollectQuest, v = module.Shared.Quests.CanCollectQuest("The Weight of Infinity", "Side", p2)

		if canCollectQuest then
			return {
				{
					Text = "The blindfold? Let's call it a teaching aid. Today's lesson is what happens when the king of curses meets someone who refuses to kneel."
				},
				{
					Text = "Defeat Sokona once. Pass this test, and the Cursed Wolf will emerge from the shadows to carry you.",
					Options = {
						{
							Text = "Accept Quest",
							Color = Color3.new(0, 1, 0),
							Callback = function()
								module.Signal:Fire("General", "Quests", "Collect", "Side", "The Weight of Infinity")
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

		local formatted = `One moment, {p.DisplayName}. Even infinity needs room in the lesson plan. Speak to me again shortly.`

		if v == "AlreadyCollected" then
			if module.Shared.Quests.GetQuestProgress("The Weight of Infinity", "Side", p2) >= 1 then
				return {
					{
						Text = `You sent the king of curses packing, {p.DisplayName}! Full marks. The Cursed Wolf is yours. Try not to flood the classroom on your way out.`,
						Options = {
							{
								Text = "Claim Reward",
								Color = Color3.new(0, 1, 0),
								Callback = function()
									module.Signal:Fire("General", "Quests", "Claim", "Side", "The Weight of Infinity")
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

			formatted = `Sokona is still waiting in Cursed Academy, {p.DisplayName}. Defeat him once. Consider it homework, with slightly sharper consequences.`
		elseif v == "Claimed" or v == "MaxCompletions" then
			formatted = `You already earned the Cursed Wolf, {p.DisplayName}. Keep training. The best students eventually make their teacher look over his shoulder.`
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