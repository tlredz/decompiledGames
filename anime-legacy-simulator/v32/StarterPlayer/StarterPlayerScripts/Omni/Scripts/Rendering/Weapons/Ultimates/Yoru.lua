local module = require("@game/ReplicatedStorage/Omni")

local function CanShowEffects()
	return not (module.Data.Settings["Hide Effects"] or module.Data.Settings["Low Mode"])
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearEffects(p)
	local skillEffect = p.SkillEffect

	if not skillEffect then
		return
	end

	p.SkillEffect = nil
	skillEffect:Destroy()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetOffset(damage, p: number)
	local v = math.clamp(p / damage.Interval, 0, #damage.Offsets - 1)
	local v2 = math.floor(v) + 1
	local v3 = math.min(v2 + 1, #damage.Offsets)
	return damage.Offsets[v2]:Lerp(damage.Offsets[v3], v % 1)
end

local Yoru = {}

function Yoru:Setup()
	self.Stage = 0
	table.insert(self.Resources, function()
		ClearEffects(self) -- equivalent call inferred; original call site unknown
	end)

	if module.Data.Settings["Hide Effects"] or module.Data.Settings["Low Mode"] then
		return
	end

	local yoru = module.Assets.Effects.Weapons:FindFirstChild("Yoru")
	local skill = yoru and yoru:FindFirstChild("Skill")
	local effect = skill and skill:FindFirstChild("Effect")

	if not (effect and effect:IsA("Model")) then
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

	clone:PivotTo(self.Transform * self.Skill.Phases[2].Damage.Offsets[1])
	clone.Parent = workspace:FindFirstChild("Cache") or workspace
end

function Yoru:Update()
	if module.Data.Settings["Hide Effects"] or module.Data.Settings["Low Mode"] then
		ClearEffects(self) -- equivalent call inferred; original call site unknown
	else
		local skillEffect = self.SkillEffect

		if not (skillEffect and skillEffect.Parent) then
			return
		end

		local elapsed = self.Elapsed

		for i = 1, self.Index - 1 do
			elapsed += self.Skill.Phases[i].Duration
		end

		local phas = self.Skill.Phases[2]
		local duration = self.Skill.Phases[1].Duration
		local v = duration + phas.Duration

		if v + 0.5 <= elapsed then
			ClearEffects(self) -- equivalent call inferred; original call site unknown
		else
			skillEffect:PivotTo(self.Transform * GetOffset(phas.Damage, elapsed - duration))

			if v <= elapsed then
				if self.Stage < 2 then
					self.Stage = 2
					module.Utils.Particles:DisableAll(skillEffect)
				end
			elseif duration <= elapsed and self.Stage < 1 then
				self.Stage = 1
				module.Utils.Particles:EnableAll(skillEffect)
			end
		end
	end
end

function Yoru:Clear()
	local skillEffect = self.SkillEffect

	if not skillEffect then
		return
	end

	self.SkillEffect = nil
	skillEffect:Destroy()
end

return Yoru