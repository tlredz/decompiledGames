local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	["Health Regen Speed"] = {
		Icon = "rbxassetid://84635437632627",
		Ratio = 37,
		Postfix = "x",
		IsRatio = true,
		Value = {
			Start = 1,
			StepFactor = 0.15
		}
	},
	["Max Health"] = {
		Icon = "rbxassetid://110875674970103",
		Ratio = 37,
		Value = {
			Start = 40,
			StepFactor = 75,
			StepAccel = 2
		},
		Rule = {
			Start = 7,
			IncrementAmount = 9
		}
	},
	["Max Stamina"] = {
		Icon = "rbxassetid://107011396783956",
		Ratio = 28,
		Value = {
			Start = 15,
			StepFactor = 17,
			StepAccel = 2
		},
		Rule = {
			Start = 4,
			IncrementAmount = 4
		}
	},
	["Stamina Regen Speed"] = {
		Icon = "rbxassetid://115769583119321",
		Ratio = 37,
		Postfix = "x",
		IsRatio = true,
		Value = {
			Start = 1,
			StepFactor = 0.15,
			Custom = {
				1.17,
				1.32,
				1.46,
				1.58,
				1.7,
				1.8
			}
		},
		Rule = {
			Start = 6,
			IncrementAmount = 6
		}
	},
	["Block Points"] = {
		Icon = "rbxassetid://123207804589469",
		Ratio = 37,
		Value = {
			Start = 1,
			StepFactor = 1.25,
			StepAccel = 0.1
		},
		Rule = {
			Start = 12,
			IncrementAmount = 12
		}
	},
	["Block Regen"] = {
		Icon = "rbxassetid://103261465419662",
		Ratio = 56,
		Postfix = "x",
		IsRatio = true,
		Value = {
			Start = 1,
			StepFactor = 0.15
		},
		Rule = {
			Start = 12,
			IncrementAmount = 12
		}
	},
	["Additional Damage"] = {
		Icon = "rbxassetid://123835775088197",
		Ratio = 45,
		Value = {
			Start = 0.5,
			StepFactor = 0.5,
			StepAccel = 0.1
		},
		Rule = {
			Start = 12,
			IncrementAmount = 12
		}
	}
}