local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserService = game:GetService("UserService")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local BountyLibrary = {
	Players = {},
	Rewards = {}
}

local function add_player(p, eliminationReward, winReward)
	local v = {
		EliminationReward = eliminationReward,
		WinReward = winReward
	}
	BountyLibrary.Players[tostring(p)] = v

	if v.EliminationReward then
		local v2 = p == 324386852 and Utility:IsAprilFools() and "spell mud backwards" or nil
		BountyLibrary.Rewards[v.EliminationReward] = true
		CosmeticLibrary.Cosmetics[v.EliminationReward].Description = v2 or string.format(
			"Earned by eliminating @%s with a weapon",
			"• • •"
		)
		CosmeticLibrary.Cosmetics[v.EliminationReward].DescriptionSpecific = v2 or string.format(
			"Earned by eliminating @%s with this weapon",
			"• • •"
		)
	end

	if v.WinReward then
		BountyLibrary.Rewards[v.WinReward] = true
		CosmeticLibrary.Cosmetics[v.WinReward].Description = string.format(
			"Earned by winning with or against @%s",
			"• • •"
		)
	end
end

add_player(15941965, "SenseiWarrior", "Sensite")
add_player(20349956, "Nosniy", "Nosnite")
add_player(780350915, "nekoanims", "Nekore")
add_player(13108868, "ShadowTrojan", "Shadore")
add_player(1730213868, "Brian1KB", "Brianore")
add_player(8034104, "GreatGuyBoom", "Boomore")
add_player(42477697, "D_reamz", nil)
add_player(266340204, "Blizmid")
add_player(487532097, "CarbonMeister")
add_player(964088769, "DV")
add_player(64516, "Bandites")
add_player(84743203, "TanqR")
add_player(301707243, "BobbVX")
add_player(341006533, "oPixel")
add_player(52392831, "MiniBloxia")
add_player(72777686, "enriquebruv")
add_player(15315966, "hoppy819")
add_player(2528007458, "Chex")
add_player(264355696, "Hoopie")
add_player(4891355965, "Kaye")
add_player(103070346, "Karful")
add_player(19737278, "Khayri")
add_player(68729698, "viecti")
add_player(18394211, "SharkTactics")
add_player(1010680683, "Applino")
add_player(172669397, "8sty")
add_player(11127106743, "atorix")
add_player(3410760577, "philhood")
add_player(324386852, "Mud")
add_player(527669241, "KaiM")
add_player(121130556, "Darktru")
add_player(4378716640, "Kashy")
add_player(6114260623, "Milo")
add_player(147139016, "elixir")
add_player(2466113945, "WE1RD")
add_player(42306452, "Cruz")
add_player(7474730049, "Stefan")
add_player(152334685, "Mixedify")
add_player(719253194, "SlingshotBwai")
add_player(817372683, "TinyDude")

local function setup_descriptions()
	local v = {}

	for k in pairs(BountyLibrary.Players) do
		table.insert(v, (tonumber(k)))
	end

	local success, userInfosByUserIdsAsync = pcall(UserService.GetUserInfosByUserIdsAsync, UserService, v)

	if not success then
		warn("Failed to fetch user infos:", userInfosByUserIdsAsync, v)
		return
	end

	for _, v2 in pairs(userInfosByUserIdsAsync) do
		local player = BountyLibrary.Players[tostring(v2.Id)]

		if not player then
			continue
		end

		if player.EliminationReward then
			CosmeticLibrary.Cosmetics[player.EliminationReward].Description = string.format(
				"Earned by eliminating @%s with a weapon",
				v2.Username
			)
			CosmeticLibrary.Cosmetics[player.EliminationReward].DescriptionSpecific = string.format(
				"Earned by eliminating @%s with this weapon",
				v2.Username
			)
		end

		if player.WinReward then
			CosmeticLibrary.Cosmetics[player.WinReward].Description = string.format(
				"Earned by winning with or against @%s",
				v2.Username
			)
		end
	end
end

task.defer(setup_descriptions)
return BountyLibrary