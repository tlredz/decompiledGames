local BonusMomentsGuide = require(game.ReplicatedStorage.BonusMomentsGuide)
require(game.ReplicatedStorage.DialoguesList.Types)
local Library = require(game.ReplicatedStorage.DialoguesList.Library)
return {
	Title = "Ability Teacher",
	Get = function(self)
		local interactQuestGiver = BonusMomentsGuide.interactQuestGiver("FrozenAbilityTeacher")
		local openingDialogue

		if interactQuestGiver then
			openingDialogue = interactQuestGiver.OpeningDialogue
		end

		local text = {}

		if openingDialogue then
			for _, v2 in openingDialogue do
				table.insert(text, v2)
			end
		end

		table.insert(text, "Which special ability would you like to learn?")
		return {
			Text = text,
			Option1 = {
				Label = "Air Jump",
				Text = { "For only <Color=Green>$10,000<Color=/>, I'll teach you the ability to jump on the air multiple times!" },
				Option1 = {
					Label = "Learn",
					JumpTo = function()
						return Library.buyAbility("Geppo", "Skyjump")
					end
				},
				Option2 = {
					Label = "Return",
					JumpTo = function()
						return self:Get()
					end
				}
			},
			Option2 = {
				Label = "Aura",
				Text = { "For only <Color=Green>$25,000<Color=/>, I'll teach how to enhance your physical attacks and weapons to damage Elemental users. You can also train this ability to unlock its potential! [Hotkey: J]" },
				Option1 = {
					Label = "Learn",
					JumpTo = function()
						return Library.buyAbility("Buso", "Enhancement")
					end
				},
				Option2 = {
					Label = "Return",
					JumpTo = function()
						return self:Get()
					end
				}
			},
			Option3 = {
				Label = "Flash Step",
				Text = { "For only <Color=Green>$100,000<Color=/>, I'll teach you how to travel between medium distances extremely fast, as if you were teleporting! [Hotkey: R]" },
				Option1 = {
					Label = "Learn",
					JumpTo = function()
						return Library.buyAbility("Soru", "Flash Step")
					end
				},
				Option2 = {
					Label = "Return",
					JumpTo = function()
						return self:Get()
					end
				}
			}
		}
	end
}