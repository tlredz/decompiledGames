local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Key = "Dandy",
	ShopName = "DandyStore",
	NpcName = "Dandy",
	UseFacialRig = true,
	NPC = {
		TowerName = "Dandy",
		DisplayName = "Dandy",
		Animations = {
			Idle = "L_Idle",
			Wave = "L_Wave",
			Talk = "L_Talk",
			Happy = "L_Celebration",
			Gossip = "L_Gossip_Happy",
			Celebration = "L_Celebration",
			CrazyCelebration = "L_Crazy_Celebration",
			GossipHappy = "L_Gossip_Happy",
			GossipReserved = "L_Gossip_Reserved",
			Quirk = "L_Quirk"
		},
		Celebrations = { "Celebration", "CrazyCelebration" }
	},
	DialogOffsets = {
		height = 3.5,
		xOffset = nil,
		zOffset = nil
	},
	Workspace = {
		Prompt = function()
			return workspace:WaitForChild("ShopPrompt"):WaitForChild("ProximityPrompt")
		end,
		Npc = function()
			return workspace:WaitForChild("DandyStore")
		end,
		CamNormal = function()
			return workspace:WaitForChild("StoreCamera")
		end,
		CamMobile = function()
			return workspace:WaitForChild("StoreCameraMobile")
		end
	},
	InfoFolders = {
		toons = function()
			return require(ReplicatedStorage.SharedUtils.TowerLUT)
		end,
		trinkets = function()
			return ReplicatedStorage.TrinketData:GetChildren()
		end
	}
}