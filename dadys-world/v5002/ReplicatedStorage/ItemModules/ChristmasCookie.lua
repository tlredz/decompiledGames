local ChristmasCookie = {
	Name = "ChristmasCookie",
	DandyStoreItem = false,
	AbilityOnlyItem = true,
	Rarity = "Rare",
	PointCost = 0,
	Icon = "rbxassetid://121366170175008",
	Description = "Use this item to create a pulse that increases the Movement Speed of Toons around you by 25% for 10 seconds.",
	ItemDuration = 10,
	AuraRadius = 15
}
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local BuffIndicator = require(ReplicatedStorage2.Modules.Gameplay.BuffIndicator)
require(ReplicatedStorage.Modules.Audio.SoundUtils)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function ChristmasCookie.UseItem(instance, p, p2)
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")

	if humanoidRootPart then
		Audio:Play("Sounds.Misc.UseSound", {
			Parent = humanoidRootPart
		})
	end

	local itemDuration = ChristmasCookie.ItemDuration

	if p2 and p2 > 0 then
		itemDuration += p2
	end

	local events = ReplicatedStorage:FindFirstChild("Events")
	local renderObject = events and events:FindFirstChild("RenderObject")

	if renderObject then
		local parts = ReplicatedStorage:FindFirstChild("Parts")
		local renderModules = parts and parts:FindFirstChild("RenderModules")
		local christmasCookieAOE = renderModules and renderModules:FindFirstChild("ChristmasCookieAOE")

		if christmasCookieAOE then
			renderObject:FireAllClients(christmasCookieAOE, { instance, itemDuration - 2 })
		end
	end

	local v2 = {}
	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if inGamePlayers then
		for _, child in ipairs(inGamePlayers:GetChildren()) do
			if child == instance then
				continue
			end

			local humanoidRootPart2 = child:FindFirstChild("HumanoidRootPart")
			local humanoid = child:FindFirstChild("Humanoid")
			local stats = child:FindFirstChild("Stats")

			if not (humanoidRootPart2 and humanoid and stats and humanoid.Health > 0) then
				continue
			end

			if not ((humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude <= ChristmasCookie.AuraRadius) then
				continue
			end

			local modifierIds = StatModifierManager.ApplySpeedModifiers(child, 1.25, "ChristmasCookie", {
				category = "item",
				antiCheat = true
			})
			local attachment = Instance.new("Attachment")
			attachment.Name = "CookieBuffParticle"
			attachment.Parent = humanoidRootPart2
			local clone = game.ReplicatedStorage.Parts.BuffParticles.Speed.BuffParticle:Clone()
			clone.Parent = attachment
			clone.Enabled = true
			local clone2 = game.ReplicatedStorage.Parts.BuffParticles.Speed.Glow:Clone()
			clone2.Parent = attachment
			clone2.Enabled = true
			BuffIndicator.raise(child, "ItemChristmasCookie", itemDuration)
			local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
			BuffIndicator.tell(
				child,
				string.format(
					"%s's Christmas Cookie! Speed +%d%% for %s!",
					playerFromCharacter and playerFromCharacter.DisplayName or instance.Name,
					25,
					BuffIndicator.seconds(itemDuration)
				)
			)
			table.insert(v2, {
				Character = child,
				ModifierIds = modifierIds,
				Attachment = attachment,
				SpeedParticle = clone,
				SpeedGlow = clone2
			})
			Debris:AddItem(clone, itemDuration + 1)
			Debris:AddItem(clone2, itemDuration + 1)
			Debris:AddItem(attachment, itemDuration + 1)
		end
	end

	task.delay(itemDuration, function()
		for _, v3 in ipairs(v2) do
			if not (v3.Character and v3.Character.Parent ~= nil) then
				continue
			end

			StatModifierManager.RemoveSpeedModifiers(v3.Character, v3.ModifierIds)

			if not v3.Attachment then
				continue
			end

			v3.SpeedParticle.Enabled = false
			v3.SpeedGlow.Enabled = false
		end
	end)
	p.Value = "None"
	local child = workspace.Info.PlayerStats:FindFirstChild(instance.Name)

	if child then
		local survivalPoints = child:WaitForChild("SurvivalPoints")
		survivalPoints.Value += 5
	end

	return {
		Outcome = true,
		Reason = "Christmas Cookie activated! Nearby toons receive a speed boost!"
	}
end

return ChristmasCookie