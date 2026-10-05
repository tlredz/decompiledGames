local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
require(ReplicatedStorage.packages.Net)
require(ReplicatedStorage.shared.utils.GeneralUtils)
local module = require("./PassiveHandler")
local GreatDreamWaker = {
	MorphHarpoon = function(state, _, object)
		state.random = object:GetRandom(-66)
		state.buttonThresholds = object.data.GreatDreamWaker_ButtonThresholds or {}
		state.buttonsSpawned = 0
		state.reelTrove:Add(object.OnButtonClick:Connect(function(p)
			if p.buttonType == "curse" then
				state.bar.value += 1
			end
		end))
		state.bar = object:CreatePassiveBar("curse", script.curse, {
			value = object.data.GreatDreamWaker_StartingCharge or 0,
			min = 0,
			max = object.data.GreatDreamWaker_MaxCharge or 5
		})
		object.BuildEndingData:Bind(function(p)
			p.GreatDreamWaker_EndingCharge = state.bar.value
			return p
		end)
	end,
	TickLogic_Harpoon = function(state, object, _: number)
		local buttonThreshold = state.buttonThresholds[state.buttonsSpawned + 1]

		if not buttonThreshold then
			return
		end

		if buttonThreshold <= object.progress then
			state.buttonsSpawned += 1
			object:SpawnButton("curse", object:GetRandomButtonPosition(state.random, object.buttonSize))
		end
	end
}
setmetatable(GreatDreamWaker, module)
return GreatDreamWaker