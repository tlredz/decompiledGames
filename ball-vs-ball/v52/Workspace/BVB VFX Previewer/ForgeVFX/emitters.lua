local module = require("./effects/beam")
local module2 = require("./effects/spin")
local module3 = require("./effects/mesh")
local module4 = require("./effects/sound")
local module5 = require("./effects/bezier")
local module6 = require("./effects/screen")
local module7 = require("./effects/particle")
local module8 = require("./effects/lightning")
local module9 = require("./effects/camera_shake")
local module10 = require("./effects/tweener")
local module11 = require("./effects/randomizer")
local module12 = require("./effects/shockwave_ring")
local module13 = require("./effects/shockwave_line")
local module14 = require("./effects/shockwave_debris")
local module15 = require("./mod/attributes")
require("./types")
local module16 = require("./mod/utility")
local module17 = require("./pkg/Promise")
local Emitters = {}

local function processRandomizers(rayValue, p)
	local rayValues = rayValue:QueryDescendants((`> RayValue.{module16.PROPERTY_RANDOMIZER_TAG}`))
	local rayValues2 = rayValue:QueryDescendants((`> RayValue.{module16.ATTRIBUTE_RANDOMIZER_TAG}`))

	if rayValue:IsA("RayValue") then
		if rayValue:HasTag(module16.PROPERTY_RANDOMIZER_TAG) then
			table.insert(rayValues, rayValue)
		elseif rayValue:HasTag(module16.ATTRIBUTE_RANDOMIZER_TAG) then
			table.insert(rayValues2, rayValue)
		end
	end

	for _, descendant in rayValues do
		module16.try("failed to emit property randomizer with error: %s", module11.emit, descendant, p, false)
	end

	for _, descendant in rayValues2 do
		module16.try("failed to emit attribute randomizer with error: %s", module11.emit, descendant, p, true)
	end
end

function Emitters.particle(instance, list, p, p2, p3: number)
	local emitCount = module15.get(instance, "EmitCount", module16.PLUGIN_CONTEXT and 1 or nil)
	local emitDuration = module15.get(instance, "EmitDuration", 0, true)

	if not emitCount or emitCount <= 0 and emitDuration <= 0 then
		return
	end

	if instance:IsDescendantOf(workspace) then
		module16.try("failed to emit particle with error: %s", module7.emit, instance, instance, list, p3)
		return
	end

	local particleAncestry, v = module16.cloneParticleAncestry(instance, p2)

	if not particleAncestry then
		return
	end

	local clone = instance:Clone()
	clone.Archivable = false
	clone.Parent = particleAncestry

	if p[v] then
		p[v] += 1
	else
		v.Parent = workspace.Terrain
		p[v] = 1
	end

	table.insert(list, function()
		p[v] -= 1

		if p[v] <= 0 then
			v:Destroy()
		end
	end)
	module16.try("failed to emit particle with error: %s", module7.emit, instance, clone, list, p3)
end

function Emitters.beam(instance, clones, p: number)
	local attachment0 = instance.Attachment0
	local attachment1 = instance.Attachment1

	if not (attachment0 and attachment1) then
		return
	end

	local clone = instance:Clone()
	clone.Archivable = false
	clone.Parent = workspace.Terrain
	local numberRange = NumberRange.new(1, 1)

	if module15.get(instance, "Length_Scale_Start", numberRange, true) ~= numberRange or module15.get(
		instance,
		"Length_Scale_End",
		numberRange,
		true
	) ~= numberRange then
		local clone2 = attachment0:Clone()
		local clone3 = attachment1:Clone()
		table.insert(clones, clone2)
		table.insert(clones, clone3)
		clone2.Name = "_ForgeTempAttachment"
		clone3.Name = "_ForgeTempAttachment"
		clone2:AddTag(module16.EMIT_EXCLUDE_TAG)
		clone3:AddTag(module16.EMIT_EXCLUDE_TAG)
		clone.Attachment0 = clone2
		clone.Attachment1 = clone3
		clone2.Parent = attachment0.Parent
		clone3.Parent = attachment1.Parent
	end

	table.insert(clones, clone)
	module16.try("failed to emit beam with error: %s", module.emit, instance, clone, clones, p)
end

function Emitters:trail()
	self.Enabled = true
end

function Emitters.bezier(instance, clones, flag: boolean?)
	local part = instance:FindFirstChildOfClass("Part")

	if not part then
		return
	end

	if not flag and instance:GetAttribute("Enabled") then
		instance:SetAttribute("Enabled", false)
	end

	local clone = part:Clone()
	clone.Locked = true
	table.insert(clones, clone)
	module16.try("failed to emit bezier with error: %s", module5.emit, instance, clone, clones, flag)
end

function Emitters.lightning(instance, clones, flag: boolean?)
	local part = instance:FindFirstChildOfClass("Part")

	if not part then
		return
	end

	if not flag and instance:GetAttribute("Enabled") then
		instance:SetAttribute("Enabled", false)
	end

	local clone = part:Clone()
	clone.Locked = true
	table.insert(clones, clone)
	module16.try("failed to emit lightning with error: %s", module8.emit, instance, clone, clones, flag)
end

function Emitters.mesh(instance, p, p2, p3: number, flag: boolean?)
	local start = instance:FindFirstChild("Start")

	if not start then
		return
	end

	if not flag and instance:GetAttribute("Enabled") then
		instance:SetAttribute("Enabled", false)
	end

	local _context = p._context
	local v = {}

	for _ = 1, instance:HasTag(module16.ENABLED_VFX_TAG) and module15.get(instance, "EmitDuration", 0) > 0 and not flag and 1 or module15.get(
		instance,
		"EmitCount",
		1
	) do
		local v2 = module17.new(function(callback)
			module16.try(
				"failed to emit mesh with error: %s",
				module3.emit,
				instance,
				module16.assembleMeshVFX(start, p, p2),
				p,
				p3,
				flag
			)
			callback()
		end)
		table.insert(v, v2)

		if _context then
			table.insert(_context._promises, v2)
		end
	end

	module17.all(v):await()
end

function Emitters.spin(p, p2)
	if module16.lock(p) then
		return
	end

	module16.try("failed to emit spinning model with error: %s", module2.emit, p, p2)
	module16.unlock(p)
end

function Emitters.camera_shake(p, p2)
	module16.try("failed to emit camera shake with error: %s", module9.emit, p, p2)
end

function Emitters.property_tweener(p, p2)
	if p.Parent and not module16.lock(p) then
		module16.try("failed to emit property tweener with error: %s", module10.emit, p, p2, false)
		module16.unlock(p)
	end
end

function Emitters.attribute_tweener(p, p2)
	if p.Parent and not module16.lock(p) then
		module16.try("failed to emit attribute tweener with error: %s", module10.emit, p.Parent, p, p2, true)
		module16.unlock(p)
	end
end

function Emitters.screen(p, p2)
	local v, v2 = module16.try("failed to emit screen effect with error: %s", module6.emit, p, p2)

	if v then
		return v2
	end

	return false
end

function Emitters.shockwave_ring(p, p2, p3)
	module16.try("failed to emit shockwave ring with error: %s", module12.emit, p, p2, p3)
end

function Emitters.shockwave_debris(p, p2, p3)
	module16.try("failed to emit shockwave debris with error: %s", module14.emit, p, p2, p3)
end

function Emitters.shockwave_line(p, p2, p3)
	module16.try("failed to emit shockwave line with error: %s", module13.emit, p, p2, p3)
end

function Emitters.sound(p, p2)
	if module15.get(p, "EmitCount", 1, true) <= 0 then
		return
	end

	module16.try("failed to emit sound with error: %s", module4.emit, p, p2)
end

function Emitters.dispatch(instance, p, p2, p3, p4, p5: number)
	local className = instance.ClassName
	processRandomizers(instance, p)

	if className == "ParticleEmitter" then
		Emitters.particle(instance, p, p2, p3, p5)
	elseif className == "Beam" then
		Emitters.beam(instance, p, p5)
	elseif className == "Trail" then
		Emitters.trail(instance)
	elseif className == "Sound" then
		Emitters.sound(instance, p)
	elseif className == "RayValue" then
		if instance:HasTag(module16.SCREENSHAKE_TAG) then
			Emitters.camera_shake(instance, p)
		elseif instance:HasTag(module16.ATTRIBUTE_TWEENER_TAG) then
			Emitters.attribute_tweener(instance, p)
		elseif not instance:HasTag(module16.PROPERTY_RANDOMIZER_TAG) then
			if instance:HasTag(module16.ATTRIBUTE_RANDOMIZER_TAG) then
				return
			else
				Emitters.property_tweener(instance, p)
			end
		end
	elseif instance:HasTag(module16.BEZIER_TAG) then
		Emitters.bezier(instance, p)
	elseif instance:HasTag(module16.LIGHTNING_TAG) then
		Emitters.lightning(instance, p)
	elseif className == "Model" then
		if module16.isMeshVFX(instance) then
			Emitters.mesh(instance, p, p4, p5)
		else
			Emitters.spin(instance, p)
		end
	else
		local v = className == "Part" and module16.findFirstClassWithTag(instance, "Attachment", module16.SHOCKWAVE_TAG)

		if v then
			local v2 = not instance.Parent and "" or instance.Parent.Name or ""

			if v2 == "Rings" then
				Emitters.shockwave_ring(v, instance, p)
			elseif v2 == "Debris" then
				Emitters.shockwave_debris(v, instance, p)
			elseif v2 == "Lines" then
				Emitters.shockwave_line(v, instance, p)
			end
		end
	end
end

Emitters.enabled_registry = {
	mesh = {
		check = function(p)
			return module16.isMeshVFX(p)
		end,
		emit = function(p, p2, p3)
			Emitters.mesh(p, p2, p3, 1, true)
		end
	},
	bezier = {
		check = function(instance)
			return instance:HasTag(module16.BEZIER_TAG)
		end,
		emit = function(p, p2, _)
			Emitters.bezier(p, p2, true)
		end
	},
	lightning = {
		check = function(instance)
			return instance:HasTag(module16.LIGHTNING_TAG)
		end,
		emit = function(p, p2, _)
			Emitters.lightning(p, p2, true)
		end
	}
}
return Emitters