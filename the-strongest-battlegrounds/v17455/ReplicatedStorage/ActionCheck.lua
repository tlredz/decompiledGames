return {
	Check = function(_, instance, options)
		local v = options or {}
		local ultimate = v.ultimate
		local v2 = false
		local freeze = instance:FindFirstChild("Freeze") or instance:FindFirstChild("Slowed")

		if freeze and instance:GetAttribute("InMech") and not (instance:FindFirstChild("FinalDeath") or instance:FindFirstChild("AbsoluteImmortal") or instance:GetAttribute("Finisherd") or instance:FindFirstChild("RootAnchor") or instance:FindFirstChild("CanEscape") or freeze:GetAttribute("Forced")) then
			freeze = nil
		end

		if freeze and freeze.Name == "Freeze" and freeze:GetAttribute("OverrideByDeath") and table.find(v, "Death Blow") then
			freeze = nil
		end

		if freeze and instance:FindFirstChild("DoingEmote") and table.find(v, "Dashh") then
			freeze = nil
		end

		local forceField = instance:FindFirstChildOfClass("ForceField")

		if table.find(v, "Emote") and freeze and forceField and forceField:GetAttribute("Emote") then
			freeze = nil
		end

		if freeze and table.find(v, "Burst") and not instance:FindFirstChild("RootAnchor") then
			freeze = nil
		end

		if freeze and not table.find(v, "FakeRagdoll") then
			return
		end

		if instance:GetAttribute("NoUp") then
			table.insert(v, "Ragdoll")
		end

		if (instance:FindFirstChild("Ragdoll") and not table.find(v, "Ragdoll") or instance.Humanoid.Health <= 0) and (not ultimate or instance:GetAttribute("Character") ~= "Zombie") then
			return
		end

		if instance:GetAttribute("Blocking") and not table.find(v, "Block") then
			return
		end

		if workspace:GetAttribute("NoAttack") and workspace:GetAttribute("VIPServerOwner") ~= instance.Name and not table.find(
			v,
			"Emote"
		) then
			return
		end

		if workspace:GetAttribute("VIPServer") then
			local CollectionService = game:GetService("CollectionService")
			local tagged = CollectionService:GetTagged("NoAttackPS")

			if not (table.find(v, "Emote") or table.find(v, "Run")) then
				v2 = workspace:GetAttribute("RoundOngoing") and workspace:GetAttribute("RoundType") == 2 and not instance:GetAttribute("CanAttack") and true or v2

				if #tagged > 0 then
					for _, v4 in pairs(workspace:GetPartsInPart(instance.PrimaryPart)) do
						if not table.find(tagged, v4) then
							continue
						end

						v2 = true
						break
					end
				end
			end
		end

		if workspace:GetAttribute("GlobalStun") and not table.find(v, "Emote") or v2 then
			return
		end

		local torso = instance:FindFirstChild("Torso")
		local primaryPart = instance.PrimaryPart

		if not (torso and primaryPart and (torso.Position - primaryPart.Position).magnitude > 5) then
			return true
		end

		local v3 = true
		local humanoid = instance:FindFirstChildOfClass("Humanoid")

		if humanoid then
			local v4 = {
				18182456608,
				16065180813,
				14901894832,
				13632671563,
				13633468484,
				18182425133,
				136370737633649
			}

			for _, v6 in pairs(humanoid:GetPlayingAnimationTracks()) do
				local v7 = tonumber((string.match(v6.Animation.AnimationId, "%d+")))

				if not table.find(v4, v7) then
					continue
				end

				v3 = false
				break
			end
		end

		if not v3 then
			return
		end

		return true
	end
}