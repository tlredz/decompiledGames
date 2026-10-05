local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local cframe = CFrame.new(273.7995, 941.500061, 528.189148)
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = "rbxassetid://134965430765504",
	Marker = true,
	Requirements = {
		Level = 45
	},
	Appearance = script:FindFirstChild("Model"),
	ModelAttributes = {
		NoDialogueTurn = true,
		NoDialogueAnim = true
	},
	Animations = {
		idle = { "rbxassetid://123294887820062" }
	},
	Spawns = { cframe },
	Shop = {
		["Metal Scraps"] = {
			Price = {
				Wen = 500
			}
		},
		["Silk Thread"] = {
			Price = {
				Wen = 350
			}
		}
	}
}