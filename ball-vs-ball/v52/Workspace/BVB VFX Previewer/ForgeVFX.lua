local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("@self/mod/logger")
local module2 = require("@self/mod/utility")
local module3 = require("@self/mod/attributes")
local module4 = require("@self/effects/sound")
local module5 = require("@self/effects/bezier")
local module6 = require("@self/effects/lightning")
local module7 = require("@self/effects/camera_shake")
local module8 = require("@self/effects/shockwave_ring")
local module9 = require("@self/effects/shockwave_line")
local module10 = require("@self/effects/shockwave_debris")
local module11 = require("@self/services/caches")
local module12 = require("@self/services/effects")
local module13 = require("@self/services/texture_loader")
local module14 = require("@self/services/enabled_effects")
local PLUGIN_CONTEXT = module2.PLUGIN_CONTEXT
local SERVER_CONTEXT = module2.SERVER_CONTEXT
local ForgeVFX = {
	scope = {},
	setup = false
}

function ForgeVFX.init(_)
	if ForgeVFX.setup then
		return
	end

	if SERVER_CONTEXT then
		task.spawn(function()
			local count = 0

			while true do
				count += 1
				local success, result = pcall(module2.setCollisionGroups, module2.COLLISION_GROUPS)

				if not success then
					task.wait(count)
				end

				if not (success or count >= 5) then
					continue
				end

				if not success then
					module.warn((`couldn't register necessary collision groups after {count} tries with the last error being: {result}`))
				end

				break
			end
		end)
	end

	ForgeVFX.setup = true

	if RunService:IsServer() and not PLUGIN_CONTEXT then
		return
	end

	ForgeVFX.caches = module11.init(ForgeVFX.scope)
	shared.vfx = ForgeVFX
	module12.init(ForgeVFX)
	module13.init(ForgeVFX.scope)
	module14.init(ForgeVFX.scope, ForgeVFX.caches.shared_part, module12)
	module4.init()
	module7.init()
	module5.init(ForgeVFX.caches.shared_part)
	module6.init(ForgeVFX.caches.shared_part)
	module8.init(ForgeVFX.caches.shared_part)
	module9.init(ForgeVFX.caches.shared_part)
	module10.init(ForgeVFX.caches.shared_part)
end

function ForgeVFX.deinit()
	if not ForgeVFX.setup then
		return
	end

	ForgeVFX.setup = false
	shared.vfx = nil

	if RunService:IsServer() and not PLUGIN_CONTEXT then
		return
	end

	module2.cleanupScope(ForgeVFX.scope)
	module12.deinit()
	module4.deinit()
	module5.deinit()
	module6.deinit()
	module7.deinit()
	module8.deinit()
	module9.deinit()
	module10.deinit()
	local tagged = CollectionService:GetTagged(module2.CLEANUP_TAG)

	for _, v in tagged do
		v:Destroy()
	end
end

local function fullEmit(_: number, p: number, ...)
	if not ForgeVFX.setup then
		module.error("not initialized")
	end

	return module12.emit(p, ...)
end

function ForgeVFX.emit(value, ...)
	if typeof(value) == "number" then
		return fullEmit(value, 0, ...)
	end

	return fullEmit(1, 0, value, ...)
end

function ForgeVFX.emitWithDepth(p: number, ...)
	return fullEmit(1, p, ...)
end

function ForgeVFX.cacheAttributes(folder, flag: boolean)
	if module2.SERVER_CONTEXT then
		module.error("attributes can only be cached in a client-side context")
	end

	if not folder:IsDescendantOf(ReplicatedStorage) then
		module.error("attributes can only be cached for VFX inside ReplicatedStorage")
	end

	module3.cache(folder)

	if flag then
		return
	end

	for _, descendant in folder:GetDescendants() do
		module3.cache(descendant)
	end
end

function ForgeVFX.restoreAttributes(folder, flag: boolean?)
	if module2.SERVER_CONTEXT then
		module.error("attributes can only be restored in a client-side context")
	end

	module3.restore(folder)

	if flag then
		return
	end

	for _, descendant in folder:GetDescendants() do
		module3.restore(descendant)
	end
end

local function setEnabled(effect, enabled: boolean)
	if effect:IsA("ParticleEmitter") then
		effect.Enabled = enabled
	elseif effect:IsA("Beam") then
		effect.Enabled = enabled
	elseif module3.isCached(effect) then
		module3.trigger(effect, "Enabled", enabled)
	else
		effect:SetAttribute("Enabled", enabled)
	end
end

function ForgeVFX.enable(folder)
	setEnabled(folder, true)

	for _, descendant in folder:GetDescendants() do
		setEnabled(descendant, true)
	end
end

function ForgeVFX.disable(folder)
	setEnabled(folder, false)

	for _, descendant in folder:GetDescendants() do
		setEnabled(descendant, false)
	end
end

local module15 = require("@self/mod/retime")
ForgeVFX.retime = module15.batch
local module16 = require("@self/mod/resize")
ForgeVFX.resize = module16.batch
ForgeVFX.recolor = require("@self/mod/recolor")
return ForgeVFX