return {
	Btn = 3,
	SortOrder = 6,
	Val = "SENS",
	Desc = "Change the sensitivity multiplier",
	Max = 10,
	Callback = function(mouseDeltaSensitivity)
		local UserInputService = game:GetService("UserInputService")
		UserInputService.MouseDeltaSensitivity = mouseDeltaSensitivity
	end
}