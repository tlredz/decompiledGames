local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Net = require(ReplicatedStorage.Packages.Net)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.ServerInfo)
local Utils = require(ReplicatedStorage.Common.Utils)
local SpeedModifiers = require(ReplicatedStorage.Shared.SpeedModifiers)
local remoteEvent = Net:RemoteEvent("RequestSelfDamage")
local localPlayer = Players.LocalPlayer
return Observers.observeTag("Dungeons_HitboxDamage", function(folder)
	local v = folder:GetAttribute("DamageRootOnly") and true or false
	local postSimulationConnection = nil
	local thread = nil
	local thread2 = nil
	local thread3 = nil
	local v2 = nil
	local v3 = math.random()
	local v4 = false
	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cancelAll()
		if thread3 then
			Utils.Thread.SafeCancel(thread3)
			thread3 = nil
		end

		if postSimulationConnection then
			postSimulationConnection:Disconnect()
			postSimulationConnection = nil
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cancelDamage()
		if not v4 then
			cancelAll() -- equivalent call inferred; original call site unknown
		end

		if thread then
			Utils.Thread.SafeCancel(thread)
		end

		flag = false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cancelSlow()
		if not flag then
			cancelAll() -- equivalent call inferred; original call site unknown
		end

		if thread2 then
			Utils.Thread.SafeCancel(thread2)
		end

		if v2 then
			v2()
			v2 = nil
		end

		v4 = false
	end

	local function cleanup()
		cancelSlow() -- equivalent call inferred; original call site unknown
		cancelDamage() -- equivalent call inferred; original call site unknown

		if folder:GetAttribute("EnableVFX") and not folder:GetAttribute("DisableVFX") then
			for _, effect in folder:GetDescendants() do
				if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
					effect.Enabled = false
				end
			end
		end

		Utils.Visual:TurnOffVisuals(folder)
	end

	local damageHitbox = folder:FindFirstChild("DamageHitbox") or folder

	local function damage()
		local damage2 = folder:GetAttribute("Damage")

		if damage2 == 0 then
			return
		end

		local character = localPlayer.Character

		if character then
			local lastHitboxDamage = character:GetAttribute("LastHitboxDamage")
			local now = os.clock()

			if lastHitboxDamage and now - lastHitboxDamage < 0.75 then
				return
			end

			character:SetAttribute("LastHitboxDamage", now)
			task.delay(0.75, function()
				if character and character:GetAttribute("LastHitboxDamage") == now then
					character:SetAttribute("LastHitboxDamage", nil)
				end
			end)
		end

		remoteEvent:FireServer(damage2 or 1)
		local remoteEvent2 = folder:FindFirstChildWhichIsA("RemoteEvent")

		if remoteEvent2 then
			remoteEvent2:FireServer()
		end
	end

	local v5 = 0

	local function slow()
		local character = Players.LocalPlayer.Character

		if character then
			if v2 then
				v2()
			end

			local v6 = v5 + 1
			v5 = v6
			v2 = SpeedModifiers:SetModifierFor(
				character,
				`HitboxDamage{v3}`,
				SpeedModifiers.Utils.MinDebuff(character, folder:GetAttribute("SlowSpeedValue") or 12),
				SpeedModifiers.Priority.DEBUFF
			)
			task.delay(folder:GetAttribute("SlowDuration") or 1, function()
				if v6 == v5 and v2 then
					v2()
					v2 = nil
				end
			end)
		end
	end

	thread3 = task.delay(folder:GetAttribute("WaitTime") or 0, function()
		if not folder:GetAttribute("DisableVFX") then
			task.delay(folder:GetAttribute("VFXWaitTime") or 0, function()
				if folder:GetAttribute("EnableVFX") then
					for _, effect in folder:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							effect.Enabled = true
						end
					end
				end

				Utils.Visual:PlayEffects(folder)
			end)
		end

		local damageTimeout = folder:GetAttribute("DamageTimeout")
		local slowTimeout = folder:GetAttribute("SlowSpeed") and folder:GetAttribute("SlowTimeout")
		local v6 = 0
		local v7 = 0
		postSimulationConnection = RunService.PostSimulation:Connect(function(_: number)
			local character = Players.LocalPlayer.Character
			local overlapParams = OverlapParams.new()
			overlapParams.MaxParts = 1
			overlapParams.FilterType = Enum.RaycastFilterType.Include

			if v and character then
				character = character:FindFirstChild("HumanoidRootPart")
			end

			overlapParams.FilterDescendantsInstances = { character }

			if #workspace:GetPartsInPart(damageHitbox, overlapParams) > 0 then
				local damageCooldown = folder:GetAttribute("DamageCooldown")
				local slowCooldown = folder:GetAttribute("SlowSpeed") and folder:GetAttribute("SlowCooldown")

				if damageCooldown or slowCooldown then
					local now = os.clock()

					if flag and damageCooldown and damageCooldown < now - v6 then
						damage()
						v6 = now
					end

					if v4 and slowCooldown and slowCooldown < now - v7 then
						slow()
						v7 = now
					end
				else
					if flag then
						damage()
					end

					cleanup()
				end
			end
		end)
		flag = true

		if damageTimeout then
			thread = task.delay(damageTimeout, cancelDamage)
		end

		if slowTimeout then
			v4 = true
			thread2 = task.delay(slowTimeout, cancelSlow)
		end
	end)
	return cleanup
end, { workspace })