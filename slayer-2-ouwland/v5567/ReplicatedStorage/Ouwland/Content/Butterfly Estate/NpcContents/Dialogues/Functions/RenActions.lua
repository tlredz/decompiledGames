local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DeliverAction = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.DeliverAction)
return {
	ReturnNichirinToRen = DeliverAction("Ill look for your blade(Lv 75)", "Return to Ren", "Ren_Thanks", "Ren_NoBlade")
}