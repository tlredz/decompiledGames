local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local MachineEffects = {}
local color = Color3.fromRGB(46, 22, 54)

local function debuffChamberRack()
	if not RunService:IsServer() then
		return nil
	end

	local ServerStorage = game:GetService("ServerStorage")
	local parts = ServerStorage:FindFirstChild("Parts")
	local brushaDebuffChambers = parts and parts:FindFirstChild("BrushaDebuffChambers")

	if brushaDebuffChambers and #brushaDebuffChambers:GetChildren() > 0 then
		return brushaDebuffChambers
	end

	return nil
end

function MachineEffects.GetDebuffChamberRack()
	return (debuffChamberRack())
end

local function forEachGlassSurface(folder, fn)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant.Name ~= "ChamberPart" then
			continue
		end

		local surfaceAppearance = descendant:FindFirstChildOfClass("SurfaceAppearance")

		if surfaceAppearance then
			fn(surfaceAppearance)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tintGlass(p, color2)
	forEachGlassSurface(p, function(instance)
		if instance:GetAttribute("_PreArtColor") == nil then
			instance:SetAttribute("_PreArtColor", instance.Color)
		end

		instance.Color = color2
	end)
end

local cframe = CFrame.new(0, 0.005, -0.065)

local function applyChamberArt(folder, facingPos)
	local v = debuffChamberRack()

	if not v then
		return false
	end

	local children = v:GetChildren()

	for _, part in ipairs(folder:GetDescendants()) do
		if not (part.Name == "ChamberPart" and part:IsA("BasePart")) then
			continue
		end

		local clone = children[math.random(1, #children)]:Clone()
		clone.Name = "BrushaDebuffChamber"
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CanTouch = false
		clone.CFrame = part.CFrame * cframe
		clone.Parent = folder
		MachineEffects.EmitPaintFX(clone, facingPos, 3)
	end

	return true
end

local function boostArtRack()
	if not RunService:IsServer() then
		return nil
	end

	local ServerStorage = game:GetService("ServerStorage")
	local parts = ServerStorage:FindFirstChild("Parts")
	local brushaGraffiti = parts and parts:FindFirstChild("BrushaGraffiti")

	if brushaGraffiti and #brushaGraffiti:GetChildren() > 0 then
		return brushaGraffiti
	end

	return nil
end

local v = {}

local function boostArtTemplate(instance, childName)
	local child = childName and instance:FindFirstChild(childName)

	if child then
		return child
	end

	if childName and childName ~= "Default" and not v[childName] then
		v[childName] = true
		warn(string.format(
			"[MachineEffects] no %s art named %q - falling back to %s",
			"BrushaGraffiti",
			childName,
			"Default"
		))
	end

	return instance:FindFirstChild("Default")
end

local cframe2 = CFrame.new()

function MachineEffects.GetBoostArtTemplate(p)
	local v2 = boostArtRack()

	if v2 then
		return boostArtTemplate(v2, p)
	end

	return nil
end

local v2 = { "BuffParticle", "Glow" }

local function attachBoostParticles(part)
	if part:FindFirstChild("BrushaBoostParticle") then
		return
	end

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local parts = ReplicatedStorage:FindFirstChild("Parts")
	local buffParticles = parts and parts:FindFirstChild("BuffParticles")
	local skillCheck = buffParticles and buffParticles:FindFirstChild("SkillCheck")

	if not skillCheck then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "BrushaBoostParticle"

	for _, childName in ipairs(v2) do
		local child = skillCheck:FindFirstChild(childName)

		if not child then
			continue
		end

		local clone = child:Clone()
		clone.Enabled = true
		clone.Parent = attachment
	end

	attachment.Parent = part
end

local function applyBoostArt(folder, skin)
	local part = MachineEffects.GetBoostArtTemplate(skin)

	if not (part and part:IsA("BasePart")) then
		return false
	end

	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	for _, part2 in ipairs(folder:GetDescendants()) do
		if not (part2.Name == "ChamberPart" and part2:IsA("BasePart")) then
			continue
		end

		local clone = part:Clone()
		clone.Name = "BrushaBoostArt"
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CanTouch = false
		clone.Transparency = 1
		clone.CFrame = part2.CFrame * cframe2
		clone.Parent = folder
		TweenService:Create(clone, tweenInfo, {
			Transparency = 0
		}):Play()
		attachBoostParticles(part2)
	end

	return true
end

local function clearBoostArt(folder)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant.Name == "BrushaBoostArt" or descendant.Name == "BrushaBoostParticle" then
			descendant:Destroy()
		end
	end
end

local function clearChamberArt(folder)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant.Name == "BrushaDebuffChamber" then
			descendant:Destroy()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreGlass(p)
	forEachGlassSurface(p, function(instance)
		local _PreArtColor = instance:GetAttribute("_PreArtColor")

		if _PreArtColor ~= nil then
			instance.Color = _PreArtColor
			instance:SetAttribute("_PreArtColor", nil)
		end
	end)
end

function MachineEffects.EmitPaintFX(part, p, value)
	if not (RunService:IsServer() and (part and part:IsA("BasePart"))) then
		return
	end

	local ServerStorage = game:GetService("ServerStorage")
	local parts = ServerStorage:FindFirstChild("Parts")
	local brushaPaintFX = parts and parts:FindFirstChild("BrushaPaintFX")

	if not brushaPaintFX then
		return
	end

	local attachment = Instance.new("Attachment")

	if p and (p - part.Position).Magnitude > 0.1 then
		local unit = (p - part.Position).Unit
		local cross = unit:Cross(createVector(0, 1, 0))
		local unit2 = cross.Magnitude > 0.05 and cross.Unit or createVector(1, 0, 0)
		attachment.WorldCFrame = CFrame.fromMatrix(part.Position, unit2, unit)
	end

	attachment.Parent = part

	for _, emitter in ipairs(brushaPaintFX:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local clone = emitter:Clone()
		clone.Enabled = false
		clone.Parent = attachment
		clone:Emit((math.ceil((tonumber(emitter:GetAttribute("EmitCount")) or 12) * (value or 1))))
	end

	local Debris = game:GetService("Debris")
	Debris:AddItem(attachment, 4)
end

function MachineEffects.EmitPaintFXWhile(p, instance, value, callback)
	if not RunService:IsServer() then
		return
	end

	task.spawn(function()
		local v3 = tick() + (value or 0)

		while tick() < v3 do
			if not (p and p.Parent) or callback and not callback() then
				break
			end

			local position = instance and instance.Parent and instance.Position or nil
			MachineEffects.EmitPaintFX(p, position)
			task.wait(0.7)
		end
	end)
end

MachineEffects.Effects = {
	BrushaBoost = {
		attribute = "BrushaBoosted",
		tag = "TishaCleanable",
		multipliers = {},
		applyVisual = function(parent, p2)
			applyBoostArt(parent, p2 and p2.skin)
		end,
		clearVisual = function(p)
			clearBoostArt(p)
			restoreGlass(p) -- equivalent call inferred; original call site unknown
		end
	},
	BrushaGraffiti = {
		attribute = "BrushaDebuffed",
		tag = "TishaCleanable",
		additives = {},
		applyVisual = function(parent, p2)
			if not applyChamberArt(parent, p2 and p2.facingPos) then
				tintGlass(parent, color) -- equivalent call inferred; original call site unknown
			end
		end,
		clearVisual = function(p)
			clearChamberArt(p)
			restoreGlass(p) -- equivalent call inferred; original call site unknown
		end
	}
}
local effects = {}

for k, effect in pairs(MachineEffects.Effects) do
	effect.name = k
	table.insert(effects, effect)
end

table.sort(effects, function(a, b)
	return a.name < b.name
end)

function MachineEffects.ComputeMultiplier(p, p2)
	local v3 = 1

	for _, v4 in ipairs(effects) do
		local v5 = v4.multipliers and v4.multipliers[p2]

		if v5 and p[v4.attribute] then
			v3 *= v5
		end
	end

	return v3
end

local function foldMultiplier(instance, p)
	local v3 = 1

	for _, v4 in ipairs(effects) do
		local v5 = v4.multipliers and v4.multipliers[p]

		if v5 and instance:GetAttribute(v4.attribute) then
			v3 *= v5
		end
	end

	return v3
end

function MachineEffects.ComputeAdditive(p, p2)
	local total = 0

	for _, v3 in ipairs(effects) do
		local v4 = v3.additives and v3.additives[p2]

		if v4 and p[v3.attribute] then
			total += v4
		end
	end

	return total
end

local function foldAdditive(instance, p)
	local total = 0

	for _, v3 in ipairs(effects) do
		local v4 = v3.additives and v3.additives[p]

		if v4 and instance:GetAttribute(v3.attribute) then
			total += v4
		end
	end

	return total
end

function MachineEffects.GetSkillCheckChanceAdditive(p)
	return (foldAdditive(p, "SkillCheckChance"))
end

function MachineEffects.GetDecodeMultiplier(p)
	return (foldMultiplier(p, "DecodeSpeed"))
end

function MachineEffects.GetSkillCheckChanceMultiplier(p)
	return (foldMultiplier(p, "SkillCheckChance"))
end

local object = setmetatable({}, {
	__mode = "k"
})

function MachineEffects.GetArtAge(p)
	local v3 = p and object[p]

	if v3 then
		return tick() - v3
	end

	return nil
end

function MachineEffects.GetActiveArt(instance)
	for _, v3 in ipairs(effects) do
		if instance:GetAttribute(v3.attribute) then
			return v3.name
		end
	end

	return nil
end

function MachineEffects.GetModifierSnapshot(instance)
	local result = {}

	for _, v3 in ipairs(effects) do
		if instance:GetAttribute(v3.attribute) then
			result[v3.attribute] = true
		end
	end

	return result
end

function MachineEffects.ClearArt(instance)
	if not (instance and instance.Parent) then
		return false
	end

	object[instance] = nil
	local v3 = false

	for _, effect in pairs(MachineEffects.Effects) do
		if not instance:GetAttribute(effect.attribute) then
			continue
		end

		instance:SetAttribute(effect.attribute, nil)

		if effect.tag then
			CollectionService:RemoveTag(instance, effect.tag)
		end

		if effect.clearVisual then
			local success, result = pcall(effect.clearVisual, instance)

			if not success then
				warn("[MachineEffects] clearVisual failed:", result)
			end
		end

		v3 = true
	end

	return v3
end

function MachineEffects.ApplyArt(instance, p, p2)
	local effect = MachineEffects.Effects[p]

	if not effect then
		warn("[MachineEffects] unknown effect:", (tostring(p)))
		return false
	end

	if not (instance and instance:IsDescendantOf(workspace)) then
		return false
	end

	local activeArt = MachineEffects.GetActiveArt(instance)
	MachineEffects.ClearArt(instance)
	instance:SetAttribute(effect.attribute, true)
	object[instance] = tick()

	if effect.tag then
		CollectionService:AddTag(instance, effect.tag)
	end

	if activeArt and activeArt ~= p then
		print(string.format("[MachineEffects] %s overwrote %s on %s", p, activeArt, instance.Name))
	end

	if effect.applyVisual then
		local success, result = pcall(effect.applyVisual, instance, p2)

		if not success then
			warn("[MachineEffects] applyVisual failed:", result)
		end
	end

	return true
end

return MachineEffects