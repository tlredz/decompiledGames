require(game.ReplicatedStorage.DialoguesList.Types)

-- equivalent calls inferred from this helper; original call sites unknown
local function getMoment()
	local BonusMomentsController = require(game.ReplicatedStorage.Controllers.BonusMomentsController)
	return BonusMomentsController:GetLoadedMoments()[script.Name]
end

return function()
	local moment = getMoment() -- equivalent call inferred; original call site unknown

	if not moment or moment.Progress ~= 1 or moment.Completed then
		return {
			Text = { "Aha! You look like you've been through many battles. Do you have what it takes to reign in glory within my grand colosseum?" },
			NoCancelButton = true,
			Option1 = {
				Label = "Yes!",
				JumpTo = function()
					local moment2 = getMoment() -- equivalent call inferred; original call site unknown

					if moment2 then
						moment2:FireServer("Interact")
					end

					return {
						Text = { "That's what I like to hear! Let's see how you do. Perhaps you can become one of my champions. Step into the arena, we're about to begin." }
					}
				end
			},
			Option2 = {
				Label = "Nevermind"
			}
		}
	end

	moment:FireServer("Report")
	return {
		Text = { "Well fought, warrior! You have earned your place amongst my champions. Seek out my informant near the front of the colosseum for your reward." }
	}
end