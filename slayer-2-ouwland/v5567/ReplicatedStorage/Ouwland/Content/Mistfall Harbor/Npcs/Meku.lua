local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local cframe = CFrame.new(-138.148, 801.157, 518.745, 0, 0, 1, 0, 1, 0, -1, 0, 0)
return {
	Type = Menum.npcType.Stationary,
	Name = "Alchemist Meku",
	Icon = "rbxassetid://139500554697071",
	Marker = true,
	Appearance = script:FindFirstChild("Model"),
	Animations = {
		idle = { "rbxassetid://136511930465313" }
	},
	Spawns = { cframe },
	Shop = {
		["Health Elixir"] = {
			Price = {
				Wen = 350,
				["Demon Horns"] = 2
			}
		},
		["Stamina Regen Elixir"] = {
			Price = {
				Wen = 750,
				["Demon Horns"] = 2
			}
		},
		["Health Regen Elixir"] = {
			Price = {
				Wen = 500,
				["Demon Horns"] = 2
			}
		},
		["Underwater Breathing Potion"] = {
			Price = {
				Wen = 600,
				["Demon Horns"] = 6
			}
		}
	}
}