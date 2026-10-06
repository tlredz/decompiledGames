local v = {}
local PeoUtils = require(game.ReplicatedStorage.Chest.Modules.PeoUtils)
return {
	Logiapar = function(player)
		if not player then
			return
		end

		local character

		if player:IsA("Player") then
			character = player.Character
		else
			character = player
		end

		if not character or v[player] then
			return
		end

		v[player] = true
		spawn(function()
			wait(0.1)
			v[player] = nil
		end)
		local v2 = {
			DarkDark = {
				SoundId = "rbxassetid://11757082492",
				Volume = 0.5
			},
			FlameFlame = {
				SoundId = "rbxassetid://11757082768",
				Volume = 0.5
			},
			GasGas = {
				SoundId = "rbxassetid://11757082077",
				Volume = 0.5
			},
			IceIce = {
				SoundId = "rbxassetid://11757081281",
				Volume = 0.5
			},
			LightLight = {
				SoundId = "rbxassetid://11757081698",
				Volume = 0.5
			},
			MagmaMagma = {
				SoundId = "rbxassetid://11757080406",
				Volume = 0.5
			},
			RumbleRumble = {
				SoundId = "rbxassetid://11757080936",
				Volume = 0.3
			},
			SandSand = {
				SoundId = "rbxassetid://11757079842",
				Volume = 0.3
			},
			SmokeSmoke = {
				SoundId = "rbxassetid://11757078058",
				Volume = 0.5
			},
			SnowSnow = {
				SoundId = "rbxassetid://11757079069",
				Volume = 0.5
			}
		}

		for _, part in pairs(character:GetChildren()) do
			local value = character.Logia.Value

			if not part:IsA("BasePart") then
				continue
			end

			local clone = game.ServerStorage.ServerChest.Tools.LogiaEffect[value]:Clone()
			clone.Parent = part
			_G.PU:Dust(clone, 1)
			clone:Emit(1)

			if not (part.Name == "HumanoidRootPart" and v2[value]) then
				continue
			end

			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = v2[value].SoundId,
				Volume = v2[value].Volume
			})
			_G.PU:Dust(sound, 2)
			sound.Parent = part
			sound:Play()
		end

		table.clear(v2)
	end
}