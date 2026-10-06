local module = require("@game/ReplicatedStorage/Omni")
local AnimationSync = require(script.AnimationSync)
local Combat = require(script.Parent:WaitForChild("Combat"))
local v = {}
local effects = {}
local heartbeatConnection = nil
local v2 = Combat.IsMobile() and 4 or 8
local Weapons = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function GetRoot(clone)
	if clone:IsA("BasePart") then
		return clone
	end

	if clone:IsA("Model") and clone.PrimaryPart then
		return clone.PrimaryPart
	end

	return clone:FindFirstChildWhichIsA("BasePart", true)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetEvictableHitIndex(flag: boolean)
	for k, v3 in effects do
		if not v[v3].IsOwn then
			return k
		end
	end

	if flag then
		return 1
	end

	return nil
end

local function CanReserveHitEffect(flag: boolean)
	if #effects < v2 then
		return true
	else
		local evictableHitIndex = GetEvictableHitIndex(flag) -- equivalent call inferred; original call site unknown
		return evictableHitIndex ~= nil
	end
end

local function TrimHitEffects(flag: boolean)
	while true do
		if not (v2 < #effects) then
			break
		end

		local evictableHitIndex = GetEvictableHitIndex(flag) -- equivalent call inferred; original call site unknown

		if not evictableHitIndex then
			break
		end

		Weapons.RemoveEffect(effects[evictableHitIndex])
	end
end

local function PlayImpact(character, childName: string, p: number)
	local sounds = module.Assets:FindFirstChild("Sounds")
	local weapons = sounds and sounds:FindFirstChild("Weapons")
	local child = weapons and weapons:FindFirstChild(childName)
	local v3 = child and (child:FindFirstChild("Impact" .. p) or child:FindFirstChild("Impact"))
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not (v3 and humanoidRootPart) then
		return
	end

	local settingVolume = module.Sound:GetSettingVolume("Hits Volume")

	if settingVolume <= 0 then
		return
	end

	module.Sound:Play(v3, humanoidRootPart, false, {
		Group = humanoidRootPart,
		Cooldown = 0,
		MaxVoices = 3,
		VolumeMultiplier = settingVolume
	})
end

function Weapons.SetModelEffects(folder, flag: boolean)
	for _, descendant in folder:GetDescendants() do
		if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("Light")) then
			continue
		end

		local weaponEffectEnabled = descendant:GetAttribute("WeaponEffectEnabled")

		if weaponEffectEnabled == nil then
			weaponEffectEnabled = descendant.Enabled
			descendant:SetAttribute("WeaponEffectEnabled", weaponEffectEnabled)
		end

		descendant.Enabled = flag and weaponEffectEnabled

		if flag or not (descendant:IsA("ParticleEmitter") or descendant:IsA("Trail")) then
			continue
		end

		descendant:Clear()
	end
end

function Weapons.CreateModel(parent, weapon: string)
	local v3 = module.Shared.Weapons.List[weapon]
	local render = v3 and v3.Render

	if not (render and render.Model and render.Attachments) then
		return nil
	end

	local weapons = module.Assets:FindFirstChild("Weapons")
	local model = weapons and weapons:FindFirstChild(render.Model)

	if not (model and model:IsA("Model")) then
		return nil
	end

	for childName, childName2 in render.Attachments do
		if not (model:FindFirstChild(childName, true) and parent:FindFirstChild(childName2)) then
			return nil
		end
	end

	local clone = model:Clone()
	clone.Name = "WeaponModel"
	clone:SetAttribute("Weapon", weapon)

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = false
		part.Massless = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
	end

	local v4 = false

	for childName, childName2 in render.Attachments do
		local part = clone:FindFirstChild(childName, true)
		local part2 = parent:FindFirstChild(childName2)

		if not (part:IsA("BasePart") and part2:IsA("BasePart")) then
			clone:Destroy()
			return nil
		end

		if not v4 then
			clone:PivotTo(part2.CFrame * part.CFrame:Inverse() * clone:GetPivot())
			v4 = true
		end

		part.Transparency = 1
		part.CastShadow = false
		local weld = Instance.new("Weld")
		weld.Part0 = part2
		weld.Part1 = part
		weld.Parent = part
	end

	if render.ModelEffects then
		Weapons.SetModelEffects(clone, not (module.Data.Settings["Hide Effects"] or module.Data.Settings["Low Mode"]))
	end

	clone.Parent = parent
	AnimationSync.Bind(clone, parent, weapon)
	return clone
end

function Weapons.SetModelVisible(folder, flag: boolean)
	for _, descendant in folder:GetDescendants() do
		if not (descendant:IsA("BasePart") or descendant:IsA("Decal")) then
			continue
		end

		local weaponTransparency = descendant:GetAttribute("WeaponTransparency")

		if weaponTransparency == nil then
			weaponTransparency = descendant.Transparency
			descendant:SetAttribute("WeaponTransparency", weaponTransparency)
		end

		descendant.Transparency = not flag and 1 or weaponTransparency
	end
end

function Weapons.UpdateModel(p, flag: boolean)
	AnimationSync.Update(p, flag)
end

function Weapons.ClearEffects(p)
	for k, v3 in v do
		if v3.Character == p then
			Weapons.RemoveEffect(k)
		end
	end
end

function Weapons:RemoveEffect()
	if not self then
		return
	end

	local index = table.find(effects, self)

	if index then
		table.remove(effects, index)
	end

	v[self] = nil
	self:Destroy()
end

function Weapons.CreateEffect(instance, childName: string, childName2: string, data, cframe: CFrame, p: number?)
	if module.Data.Settings["Hide Effects"] or module.Data.Settings["Low Mode"] or not instance:IsDescendantOf(workspace) then
		return nil
	end

	local effects2 = module.Assets:FindFirstChild("Effects")
	local weapons = effects2 and effects2:FindFirstChild("Weapons")
	local child = weapons and weapons:FindFirstChild(childName)
	local child2 = child and child:FindFirstChild(childName2)

	if not child2 then
		return nil
	end

	local child3 = nil

	if data.Name then
		child3 = child2:FindFirstChild(data.Name)
	elseif p then
		child3 = child2:FindFirstChild((tostring(p))) or child2:FindFirstChild("Hit" .. p) or child2:FindFirstChild("Hit")
	end

	if not child3 then
		return nil
	end

	local clone = child3:Clone()
	local v3 = GetRoot(clone) -- equivalent call inferred; original call site unknown

	if not v3 then
		clone:Destroy()
		return nil
	end

	local part = instance:FindFirstChild(data.Part or "HumanoidRootPart")
	local offset = data.Offset or CFrame.identity
	local v4

	if data.Weld == true then
		v4 = part and part:IsA("BasePart")
	else
		v4 = false
	end

	local v5

	if v4 then
		v5 = part.CFrame * offset
	else
		v5 = cframe * offset
	end

	local descendants = {}
	local v6 = 1
	local descendants2 = {}
	local descendants3 = {}

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = not v4
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.Massless = true

			if descendant ~= v3 then
				table.insert(descendants, descendant)
			end
		elseif descendant:IsA("ParticleEmitter") then
			v6 = math.max(v6, descendant.Lifetime.Max)
			table.insert(descendants2, descendant)
		elseif descendant:IsA("Beam") or descendant:IsA("PointLight") then
			table.insert(descendants3, descendant)
		end
	end

	v3.Anchored = not v4
	v3.CanCollide = false
	v3.CanTouch = false
	v3.CanQuery = false
	v3.Massless = true
	clone:PivotTo(v5)
	clone.Parent = workspace:FindFirstChild("Cache") or workspace

	if v4 then
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = part
		weldConstraint.Part1 = v3
		weldConstraint.Parent = v3

		for _, v7 in descendants do
			local weldConstraint2 = Instance.new("WeldConstraint")
			weldConstraint2.Part0 = v3
			weldConstraint2.Part1 = v7
			weldConstraint2.Parent = v7
		end
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	local duration = data.Duration or v6
	local v7 = v
	local disableAt

	if data.Enable then
		disableAt = serverTimeNow + duration or nil
	end

	v7[clone] = {
		Character = instance,
		DisableAt = disableAt,
		DestroyAt = serverTimeNow + duration + (data.Enable and v6 or 0)
	}

	if data.Enable then
		for _, v10 in descendants2 do
			v10.Enabled = true
		end

		for _, v10 in descendants3 do
			v10.Enabled = true
		end
	else
		for _, v10 in descendants2 do
			v10:Emit(v10:GetAttribute("EmitCount") or v10.Rate)
		end
	end

	return clone
end

function Weapons.Hit(player, p: string, p2: number, p3: number, cframe: CFrame)
	local character = player.Character
	local v3 = module.Shared.Weapons.List[p]

	if not (character and v3) then
		return
	end

	local isOwn = player == module.Instance

	if not (isOwn or Combat.IsNear(cframe.Position)) then
		return
	end

	local hit = v3.Hits[p2]
	local vfx = hit and hit.Vfx or not v3.HitVfx and {} or v3.HitVfx[p2] or v3.HitVfx.Default or {}
	local delay = vfx.Delay or 0
	local v5 = math.max(0, p3 + delay - workspace:GetServerTimeNow())
	task.delay(v5, function()
		if player.Character ~= character or not character.Parent then
			return
		end

		local child = workspace.Server.Replication:FindFirstChild(player.Name)
		local weapon = child and child:FindFirstChild("Weapon")

		if not weapon or weapon.Value ~= p then
			return
		end

		local v6 = workspace:GetServerTimeNow() - p3

		if delay + 2 < v6 then
			return
		end

		PlayImpact(character, p, p2)
		local isOwn2 = isOwn
		local v8

		if #effects < v2 then
			v8 = true
		else
			local evictableHitIndex = GetEvictableHitIndex(isOwn2) -- equivalent call inferred; original call site unknown
			v8 = evictableHitIndex ~= nil
		end

		if not v8 then
			return
		end

		local effect = Weapons.CreateEffect(character, p, "Hits", vfx, cframe, p2)

		if not effect then
			return
		end

		v[effect].IsOwn = isOwn
		table.insert(effects, effect)
		TrimHitEffects(isOwn)
	end)
end

function Weapons.Destroy()
	AnimationSync.Destroy()

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	for k in v do
		Weapons.RemoveEffect(k)
	end
end

function Weapons.Init()
	if heartbeatConnection then
		return
	end

	heartbeatConnection = module.Services.RunService.Heartbeat:Connect(function()
		local serverTimeNow = workspace:GetServerTimeNow()
		local hideEffects = module.Data.Settings["Hide Effects"] or module.Data.Settings["Low Mode"]

		for k, v3 in v do
			if hideEffects or not k.Parent or not v3.Character:IsDescendantOf(workspace) or v3.DestroyAt <= serverTimeNow then
				Weapons.RemoveEffect(k)
			elseif v3.DisableAt and v3.DisableAt <= serverTimeNow then
				module.Utils.Particles:DisableAll(k)
				v3.DisableAt = nil
			end
		end
	end)
end

return Weapons