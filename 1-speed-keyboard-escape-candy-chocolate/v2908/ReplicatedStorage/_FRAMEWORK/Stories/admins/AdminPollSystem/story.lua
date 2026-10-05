local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PollView = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPollSystem.PollView)
local UILabs = require(ReplicatedStorage.Packages["UI-Labs"])
local Vide = require(ReplicatedStorage.Packages.Vide)
local controls2 = {
	visible = UILabs.Boolean(true),
	ending = UILabs.Boolean(false),
	question = UILabs.String("What should happen next?"),
	choiceAmount = UILabs.Slider(4, 2, 6, 1),
	firstChoiceVotes = UILabs.Slider(48, 0, 100, 1),
	secondChoiceVotes = UILabs.Slider(31, 0, 100, 1),
	thirdChoiceVotes = UILabs.Slider(16, 0, 100, 1),
	fourthChoiceVotes = UILabs.Slider(5, 0, 100, 1)
}
local v2 = {
	"Start the concert now",
	"Play one more warm-up song",
	"Release the beach balls",
	"Let the crowd decide",
	"Turn up the lights",
	"Play a surprise song"
}
return UILabs.CreateVideStory({
	name = "Admin Poll System",
	vide = Vide,
	controls = controls2
}, function(p)
	local controls = p.controls

	local function updatePoll()
		local choices = {}

		for i = 1, controls.choiceAmount() do
			table.insert(choices, {
				text = v2[i]
			})
		end

		PollView.setVisible(controls.visible())
		PollView.setPollData({
			question = controls.question(),
			choices = choices,
			endTime = os.time() + 30
		})
		local v4 = {
			controls.firstChoiceVotes(),
			controls.secondChoiceVotes(),
			controls.thirdChoiceVotes(),
			controls.fourthChoiceVotes()
		}

		for k, v5 in v4 do
			PollView.setChoiceAmount(k, v5)
		end

		if controls.ending() then
			PollView.setEndPoll(v4)
		else
			PollView.deactivateEndPoll()
		end
	end

	Vide.effect(updatePoll)
	return Vide.create("Frame")({
		Name = "AdminPollStory",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(12, 9, 25),
		BorderSizePixel = 0,
		Vide.action(function(p2)
			PollView.mount(function(p3, p4)
				print((`[AdminPollSystem.story] chose #{p3}: {p4.text}`))
			end, p2)
			updatePoll()
		end)
	})
end)