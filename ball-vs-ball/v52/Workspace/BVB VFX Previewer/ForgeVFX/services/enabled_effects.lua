local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local module = require("../mod/attributes")
require("../types")
local module2 = require("../mod/utility")
local module3 = require("../emitters")
return {
	init = function(list, p, effects)
		local v = {}
		local v2 = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function removeEnabledEffect(p3)
			local v3 = v[p3]

			if v3 then
				module2.cleanupScope(v3)
			end

			v[p3] = nil
		end

		local function removeEnabledEffectFull(p3)
			removeEnabledEffect(p3) -- equivalent call inferred; original call site unknown
			local connection = v2[p3]

			if connection then
				connection:Disconnect()
				v2[p3] = nil
			end
		end

		local addEnabledEffect

		addEnabledEffect = function(instance)
			local v3 = nil

			for _, v5 in module3.enabled_registry do
				if not v5.check(instance) then
					continue
				end

				v3 = v5
				break
			end

			if not v3 then
				return
			end

			local connections = {}
			local v5 = {}
			table.insert(v5, connections)
			v[instance] = v5

			if not v2[instance] then
				v2[instance] = instance.AncestryChanged:Connect(function()
					if instance:IsDescendantOf(workspace) or instance.Parent and instance.Parent:HasTag("AllowEmitting") then
						if not v[instance] then
							addEnabledEffect(instance)
						end
					else
						removeEnabledEffect(instance) -- equivalent call inferred; original call site unknown
					end
				end)
			end

			local function onEnabled(enabled: boolean?)
				if enabled == nil then
					enabled = module.get(instance, "Enabled", true)
				end

				local v6 = module2.isForceEmitting(instance) or instance:IsDescendantOf(workspace) or instance.Parent and instance.Parent:HasTag("AllowEmitting")

				if enabled and not v6 then
					return
				end

				if not enabled then
					module2.cleanupScope(connections)
					return
				end

				module2.cleanupScope(connections)
				local now = 0
				local context = {
					_promises = {},
					_scopes = {}
				}
				module2.setEnabledCancelToken(instance, context)
				table.insert(connections, RunService.RenderStepped:Connect(function()
					local rate = module.get(instance, "Rate", 5)
					local state = module.getState(instance, "SpeedOverride", 1)

					if state == 0 or os.clock() - now <= 1 / rate / state then
						return
					end

					now = os.clock()
					local v8 = {
						depth = 0,
						effects = effects,
						_context = context
					}
					table.insert(context._scopes, v8)
					v3.emit(instance, v8, p)
					local index = table.find(context._scopes, v8)

					if index then
						table.remove(context._scopes, index)
					end

					module2.cleanupScope(v8)
				end))
			end

			table.insert(v5, module.hook(instance, "Enabled", onEnabled))
			onEnabled()
		end

		for _, v3 in CollectionService:GetTagged(module2.ENABLED_VFX_TAG) do
			addEnabledEffect(v3)
		end

		CollectionService:GetInstanceAddedSignal(module2.ENABLED_VFX_TAG):Connect(addEnabledEffect)
		CollectionService:GetInstanceRemovedSignal(module2.ENABLED_VFX_TAG):Connect(removeEnabledEffectFull)
		table.insert(list, function()
			for _, v3 in v do
				module2.cleanupScope(v3)
			end

			for _, connection in v2 do
				connection:Disconnect()
			end

			table.clear(v2)
		end)
	end
}