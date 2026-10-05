local v = {
	Tag = "ValleyWeaponVFX",
	FadeStart = 60,
	MaxDistance = 100,
	position = function(instance)
		for _, part in instance:GetChildren() do
			if not (part:IsA("BasePart") and part:GetAttribute("WeaponVFX") == true) then
				continue
			end

			local vFXWeld = part:FindFirstChild("VFXWeld")

			if vFXWeld and vFXWeld:IsA("Weld") and vFXWeld.Part0 and vFXWeld.Part1 == part then
				part.CFrame = vFXWeld.Part0.CFrame * vFXWeld.C0 * vFXWeld.C1:Inverse()
			end
		end
	end,
	detail = function(p)
		local value = p.Value

		if value > 0 and value <= 3 then
			return 0.6
		end

		return 1
	end
}

function v.update(folder, p, value)
	local vFXWeld = folder:FindFirstChild("VFXWeld")
	local part0 = vFXWeld and vFXWeld:IsA("Weld") and vFXWeld.Part0
	local v2

	if p == nil then
		v2 = false
	else
		v2 = folder:IsDescendantOf(workspace) and part0 and part0:IsDescendantOf(workspace)

		if v2 then
			if part0.Transparency < 0.99 then
				v2 = part0.LocalTransparencyModifier < 0.99
			else
				v2 = false
			end
		end
	end

	local v3 = not v2 and 1e999 or (p - folder.Position).Magnitude or 1e999
	local v4 = v2 and math.clamp((v.MaxDistance - v3) / (v.MaxDistance - v.FadeStart), 0, 1) * (value or 1) or 0

	for _, effect in folder:GetDescendants() do
		if effect:IsA("ParticleEmitter") then
			local enabled

			if v4 > 0 then
				enabled = effect:GetAttribute("VFXAuthoredEnabled") ~= false
			else
				enabled = false
			end

			local rate = (effect:GetAttribute("VFXBaseRate") or effect.Rate) * v4

			if math.abs(effect.Rate - rate) > 0.05 then
				effect.Rate = rate
			end

			if effect.Enabled ~= enabled then
				effect.Enabled = enabled

				if not enabled then
					effect:Clear()
				end
			end
		elseif effect:IsA("Beam") or effect:IsA("Trail") then
			effect.Enabled = v4 > 0 and effect:GetAttribute("VFXAuthoredEnabled") ~= false
		end
	end
end

return table.freeze(v)