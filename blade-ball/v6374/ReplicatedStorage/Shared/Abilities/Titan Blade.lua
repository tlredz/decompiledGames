local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
require3(ReplicatedStorage2.Common.Utils)
require3(script.Parent._Types)
local v = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Common.Utils.Utilities.SwordUtil)
local v2 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)
local v3 = require3(ReplicatedStorage2.Shared.SpeedModifiers)
local v4 = require3(ReplicatedStorage2.Shared.ScaleModifiers)
local TitanBlade = {}
TitanBlade.cooldown = 25
TitanBlade.cooldownReductionPerUpgrade = -35
TitanBlade.iconId = "rbxassetid://15460700443"

function TitanBlade.canBeUsed(_)
	return true
end

function TitanBlade.serverActivationAsync(data, _)
	local player = data.player

	if not player.Character then
		return
	end

	v.Server:GetReplionFor(player, "Data")
	local currentlyEquippedSword = player.Character:GetAttribute("CurrentlyEquippedSword") or "Base Sword"
	data.character:SetAttribute("OriginalSword", currentlyEquippedSword)
	local folder = v2:EquipSwordTo(data.character, "Titan Blade")
	folder.SASORD.SpawnEmitter:Emit(100)
	local part = Instance.new("Part")
	part.Name = "Parry"
	part.Transparency = 1
	part.Massless = true
	part.Shape = Enum.PartType.Ball
	part.Size = createVector(37.5, 37.5, 37.5)
	part.CollisionGroup = "GameplayColliders"
	part.CanCollide = false
	part.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0, 0)
	part.RootPriority = -127
	local weld = Instance.new("Weld")
	weld.Part0 = data.rootPart
	weld.Part1 = part
	weld.Parent = part
	part.Parent = data.character
	local upgrades = player:FindFirstChild("Upgrades")
	local titanBlade = upgrades and upgrades:FindFirstChild("Titan Blade")
	local value = titanBlade and titanBlade.Value or 0
	local v5 = value >= 1 and 0.75 or 0.6
	local v6 = v4:SetModifierFor(data.character, "Titan Blade", function(p: number)
		return p + 1
	end, v4.Priority.ADD)
	local v7 = v3:SetModifierFor(data.character, "Titan Blade", function(p: number)
		return p * v5
	end, v3.Priority.ADD)
	local titanBladeParriesLeftChangedConnection = nil
	local deadChangedConnection = nil
	local flag = true

	local function skip()
		if not flag then
			return
		end

		flag = false

		if titanBladeParriesLeftChangedConnection then
			titanBladeParriesLeftChangedConnection:Disconnect()
			titanBladeParriesLeftChangedConnection = nil
		end

		if deadChangedConnection then
			deadChangedConnection:Disconnect()
			deadChangedConnection = nil
		end

		v6()
		v7()
		data.character:SetAttribute("OriginalSword", nil)
		part:Destroy()

		if not (folder and folder.Parent) then
			return
		end

		folder.SASORD.DespawnEmitter:Emit(100)

		for _, effect in folder:GetDescendants() do
			if not (effect:IsA("Trail") or effect:IsA("Beam") or effect:IsA("ParticleEmitter")) then
				continue
			end

			effect.Enabled = false
		end

		local clone = folder.SASORD:Clone()
		clone.Parent = workspace.Runtime
		clone.Name = "DespawnEmitterPart"
		clone.Anchored = true
		clone.DespawnEmitter:Emit(100)
		Debris:AddItem(clone, 1)
		v2:EquipSwordTo(data.character, currentlyEquippedSword)
	end

	if value >= 1 then
		data.character:SetAttribute("TitanBladeParriesLeft", 1)
		titanBladeParriesLeftChangedConnection = data.character:GetAttributeChangedSignal("TitanBladeParriesLeft"):Connect(function()
			local titanBladeParriesLeft = data.character:GetAttribute("TitanBladeParriesLeft") or 0

			if not titanBladeParriesLeft or titanBladeParriesLeft <= 0 then
				skip()
			end
		end)
	end

	deadChangedConnection = data.character:GetAttributeChangedSignal("Dead"):Connect(function()
		skip()
	end)
	task.wait(12)
	skip()
end

return TitanBlade