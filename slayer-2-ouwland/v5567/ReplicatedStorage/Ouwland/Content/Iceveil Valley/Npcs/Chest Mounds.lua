local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return {
	Name = "Chest Mounds",
	Requirements = {
		Items = "Shovel"
	},
	WorldEvent = {
		Name = "ChestMound",
		Mounds = {
			{
				CFrame = CFrame.new(-1374.632, 1420.468, -3824.402),
				Schematic = "Firstlight Tanto Schematic",
				Requires = function(p)
					for _, v in Character_info_provider.getEquippedAccessoryStats(p) do
						if v == "Mushroom Lit Lantern" then
							return true
						end
					end

					return false
				end
			},
			{
				CFrame = CFrame.new(-424.566, 1353.615, -3528.637),
				Schematic = "Firstlight War Fans Schematic",
				Requires = function(p)
					local data = Utility.GetData(p)
					local worldEvents

					if data ~= nil then
						worldEvents = data:FindFirstChild("WorldEvents")
					end

					return worldEvents ~= nil and worldEvents:FindFirstChild("WarFansClue_4") ~= nil
				end
			},
			{
				CFrame = CFrame.new(315.261, 1352.279, -2685.55) * CFrame.Angles(0, 0.6108652381980153, 0)
			},
			{
				CFrame = CFrame.new(-1108.959, 1383.94, -2270.765) * CFrame.Angles(0, -0.7553785002631459, 0)
			},
			{
				CFrame = CFrame.new(215.186, 1211.435, -1645.934)
			},
			{
				CFrame = CFrame.new(-61.762, 1353.264, -2227.867)
			},
			{
				CFrame = CFrame.new(-805.652, 1329.754, -2212.839)
			},
			{
				CFrame = CFrame.new(879.42, 1223.919, -1747.849) * CFrame.Angles(0, 1.1168361883511715, 0)
			},
			{
				CFrame = CFrame.new(-126.965, 1354.096, -3323.666)
			},
			{
				CFrame = CFrame.new(483.505, 1351.467, -2346.814) * CFrame.Angles(0, 0.7855726963226477, 0)
			},
			{
				CFrame = CFrame.new(-503.728, 1383.197, -2987.042)
			},
			{
				CFrame = CFrame.new(-615.269, 1383.668, -2487.484) * CFrame.Angles(0, 1.0023425894203435, 0)
			}
		}
	}
}