local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local ultimate = module.Shared.Weapons.Ultimate
local Keybinds = require(script.Parent.Keybinds)
local skill = module.Interface:WaitForChild("HUD"):WaitForChild("Skill")
local main = skill:WaitForChild("Main")
local heartbeatConnection = nil
local scope = nil
local v = nil
local v2 = false
local v3 = 0
local Skill = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function GetSkill()
	local equipped = module.Data.Weapons.Equipped
	local v4 = equipped and module.Data.Weapons.List[equipped]
	local v5 = v4 and module.Shared.Weapons.List[v4.Name]
	return v5 and v5.Ultimate
end

function Skill.SetProgress(value: number)
	local v4 = math.clamp(value, 0, 1)
	local v5 = math.max(0, (v4 - 0.5) / 0.5)
	local v6 = math.min(1, v4 / 0.5)
	main.Left.Bar.Rotation = v5 * 180 - 180
	main.Right.Bar.Rotation = v6 * 180 - 180
end

function Skill.Use()
	if Keybinds.IsCapturing() then
		return
	end

	local skill2 = GetSkill() -- equivalent call inferred; original call site unknown

	if not ultimate.Validate(skill2) then
		return
	end

	local serverTimeNow = workspace:GetServerTimeNow()

	if serverTimeNow - v3 < 0.25 or module.Instance:GetAttribute("SkillActive") or serverTimeNow < (module.Instance:GetAttribute("SkillReadyAt") or 0) then
		return
	end

	v3 = serverTimeNow
	module.Signal:Fire("General", "Combat", "WeaponSkill")
end

function Skill.Update()
	local skill2 = GetSkill() -- equivalent call inferred; original call site unknown
	local visible = skill2 ~= nil
	skill.Visible = visible

	if visible and not v2 and v then
		v:set(UDim2.fromScale(1, 1))
	elseif not visible and v then
		v:set(UDim2.fromScale(0, 0))
	end

	v2 = visible

	if not visible then
		return
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	local skillReadyAt = module.Instance:GetAttribute("SkillReadyAt") or 0
	local skillCooldown = module.Instance:GetAttribute("SkillCooldown") or skill2.Cooldown or 30
	local progress, v6 = ultimate.GetProgress(skillReadyAt, skillCooldown, serverTimeNow)

	if module.Instance:GetAttribute("SkillActive") then
		main.Value.Text = "Active"
		Skill.SetProgress(0)
	elseif v6 > 0 then
		main.Value.Text = `{math.ceil(v6)}s`
		Skill.SetProgress(progress)
	elseif ultimate.Validate(skill2) then
		main.Value.Text = "Ready"
		Skill.SetProgress(1)
	else
		main.Value.Text = "—"
		Skill.SetProgress(0)
	end
end

function Skill.Destroy()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if scope then
		scope:doCleanup()
		scope = nil
		v = nil
	end

	v2 = false
end

function Skill.Init()
	if heartbeatConnection then
		return
	end

	main.Active = true
	scope = fusion.scoped(fusion)
	v = scope:Value(UDim2.fromScale(0, 0))
	scope:Hydrate(main)({
		Size = scope:Spring(v, 10, 1)
	})
	table.insert(scope, main.Activated:Connect(Skill.Use))
	heartbeatConnection = module.Services.RunService.Heartbeat:Connect(Skill.Update)
	Skill.Update()
end

return Skill