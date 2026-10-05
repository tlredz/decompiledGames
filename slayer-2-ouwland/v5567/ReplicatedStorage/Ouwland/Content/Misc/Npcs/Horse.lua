local createVector = vector.create
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
return {
	Type = Menum.npcType.Active,
	Name = "Horse",
	Quantity = 1,
	ParentToDebree = true,
	SendOver = {
		Profile = "Horse",
		Spawning = {
			Locations = {
				createVector(-1740.47, 311.5, 881.24),
				createVector(128.307, 827.359, 987.86),
				createVector(607.25, 1017.5, -224.46),
				createVector(-1035.752, 1130.074, -718.828),
				createVector(-299.885, 1307.598, -1775.326),
				createVector(1165.37, 1102.5, -963.35)
			},
			DespawnDistance = 250,
			Announcement = {
				Npc = "MoldySugar",
				Text = "[One of MoldySugar's horses]<Color=(.85,.68,.4)> has escaped… tame it [first.]<Style=Fade,Color=(.7,.6,.45)>",
				Duration = 6
			},
			TrackedBy = "Horse Locator",
			TrackedIcon = "rbxassetid://130298231932875",
			Appearance = script.Model,
			ModelAttributes = {
				NoOverhead = true
			}
		},
		HumanoidDefaults = {
			WalkSpeed = 4
		},
		Idling = {
			Enabled = true,
			Radius = 60,
			WaitBeforeChangingDirection = {
				Min = 4,
				Max = 10
			}
		},
		Settings = {
			NpcCode = "Horse"
		}
	}
}