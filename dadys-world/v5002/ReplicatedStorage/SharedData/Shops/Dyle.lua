local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Key = "Dyle",
	ShopName = "DyleStore",
	NpcName = "Dyle",
	WaveAnimId = "rbxassetid://113260134852958",
	NPC = {
		TowerName = "Dyle",
		DisplayName = "Dyle",
		AnimationSource = "model",
		Animations = {
			Wave = "rbxassetid://113260134852958"
		}
	},
	DialogOffsets = {
		height = 6.5,
		xOffset = -1.5,
		zOffset = 0
	},
	GossipAnimationStyle = "StartLoopEnd",
	Workspace = {
		Prompt = function()
			return workspace:WaitForChild("DyleShop", true):WaitForChild("Prompt", true):WaitForChild(
				"ProximityPrompt",
				true
			)
		end,
		Npc = function()
			return workspace:WaitForChild("DyleStore", true)
		end,
		CamNormal = function()
			return workspace:WaitForChild("DyleShop", true):WaitForChild("Cams"):WaitForChild("StoreCamera")
		end,
		CamMobile = function()
			return workspace:WaitForChild("DyleShop", true):WaitForChild("Cams"):WaitForChild("StoreCameraMobile")
		end
	},
	InfoFolders = {
		skins = function()
			local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
			return TowerLUT:GetSkinModuleFolder():GetChildren()
		end,
		ugc = function()
			local UGCCatalog = require(ReplicatedStorage.SharedData.UGCCatalog)
			return UGCCatalog.Resolve()
		end
	}
}