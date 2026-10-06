local module = require("@game/ReplicatedStorage/Omni")

-- equivalent calls inferred from this helper; original call sites unknown
local function CanShowEffects()
	return not (module.Data.Settings["Hide Effects"] or module.Data.Settings["Low Mode"])
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearEffects(state, flag: boolean?)
	if state.ActiveShake then
		state.ActiveShake:Stop()
		state.ActiveShake = nil
	end

	local skillEffect = state.SkillEffect

	if not skillEffect then
		return
	end

	state.SkillEffect = nil
	module.Utils.Particles:DisableAll(skillEffect)

	if flag and CanShowEffects() then
		module.Services.Debris:AddItem(skillEffect, 3)
	else
		skillEffect:Destroy()
	end
end

local GomuGomu = {}

function GomuGomu:Setup()
	self.Stage = 0
	table.insert(self.Resources, function()
		ClearEffects(self, false) -- equivalent call inferred; original call site unknown
	end)

	if module.Data.Settings["Hide Effects"] or module.Data.Settings["Low Mode"] then
		return
	end

	local gomuGomu = module.Assets.Effects.Weapons:FindFirstChild("Gomu Gomu")
	local skill = gomuGomu and gomuGomu:FindFirstChild("Skill")
	local effect = skill and skill:FindFirstChild("Effect")

	if not (effect and effect:IsA("Model") and (effect:FindFirstChild("Wind") and effect:FindFirstChild("Impacts"))) then
		return
	end

	local clone = effect:Clone()
	self.SkillEffect = clone
	module.Utils.Particles:DisableAll(clone)

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
		elseif descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") then
			descendant:Destroy()
		end
	end

	clone:PivotTo(self.Transform)
	clone.Parent = workspace:FindFirstChild("Cache") or workspace
end

function GomuGomu:Update()
	if module.Data.Settings["Hide Effects"] or module.Data.Settings["Low Mode"] then
		ClearEffects(self, false) -- equivalent call inferred; original call site unknown
	else
		local skillEffect = self.SkillEffect

		if not (skillEffect and skillEffect.Parent) then
			return
		end

		local elapsed = self.Elapsed

		for i = 1, self.Index - 1 do
			elapsed += self.Skill.Phases[i].Duration
		end

		skillEffect:PivotTo(self.Transform)

		if elapsed >= 2.0833333333333335 then
			ClearEffects(self, true)
			return
		end

		if elapsed >= 0.18333333333333332 and self.Stage < 1 then
			self.Stage = 1
			module.Utils.Particles:EnableAll(skillEffect.Wind)
		end

		if elapsed >= 0.31666666666666665 and self.Stage < 2 then
			self.Stage = 2
			module.Utils.Particles:EnableAll(skillEffect.Impacts)
			self.ActiveShake = module.Utils.CameraShake:Play({
				Position = self.Origin,
				Amplitude = 1.5,
				Frequency = 0.05,
				SustainTime = math.max(0, 1.5 - (elapsed - 0.31666666666666665)),
				FadeOutTime = 0.23
			})
		end
	end
end

function GomuGomu.Clear(player)
	ClearEffects(
		player,
		player.Completed and player.Character:IsDescendantOf(workspace) and (not player.Player or player.Player.Character == player.Character)
	)
end

return GomuGomu