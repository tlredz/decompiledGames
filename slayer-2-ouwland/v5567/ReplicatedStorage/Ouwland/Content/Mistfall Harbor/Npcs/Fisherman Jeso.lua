local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local shop = script:FindFirstChild("Shop")
local cframe = CFrame.new(
	-192.001,
	806.932,
	602.667,
	0,
	-0.012993624,
	0.9999156,
	-0.001577827,
	0.999914348,
	0.012993609,
	-1,
	-0.001577693,
	-0.0000205
)
return {
	Type = Menum.npcType.Stationary,
	Name = "Fisherman Jeso",
	Icon = "rbxassetid://89282262782460",
	Marker = true,
	RequiresQuestDone = "Ill find the permit stamp(Lv 45)",
	Appearance = script:FindFirstChild("Model"),
	ModelAttributes = {
		NoDialogueTurn = true,
		NoDialogueAnim = true
	},
	Animations = {
		idle = { "rbxassetid://121102714052854" }
	},
	Shop = {
		["Basic Fishing Rod"] = {
			Model = shop and shop:FindFirstChild("Basic Fishing Rod"),
			SuccessDialogue = "Jeso_PurchaseSuccess",
			FailDialogue = "Jeso_PurchaseFail"
		},
		["Rare Fishing Rod"] = {
			Model = shop and shop:FindFirstChild("Rare Fishing Rod"),
			SuccessDialogue = "Jeso_RarePurchaseSuccess",
			FailDialogue = "Jeso_RarePurchaseFail"
		},
		Worm = {
			AlsoSoldBy = { "Baitmonger Nori" }
		}
	},
	Spawns = { cframe }
}