local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StunCore = require(ReplicatedStorage.Modules.Gameplay.StunCore)
local StunFx = require(ReplicatedStorage.Modules.Gameplay.StunFx)
local v = { "Twisted", StunCore.TAG }
local v2 = {}
local flag = false

local function refresh(model)
	local attribute = model:GetAttribute(StunCore.ATTRIBUTE)

	if typeof(attribute) == "number" and StunCore.isActive(attribute, workspace:GetServerTimeNow()) then
		StunFx.show(model, attribute)
	else
		StunFx.hide(model)
	end
end

local function watch(model)
	if v2[model] or not model:IsA("Model") then
		return
	end

	v2[model] = model:GetAttributeChangedSignal(StunCore.ATTRIBUTE):Connect(function()
		refresh(model)
	end)
	refresh(model)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unwatch(instance)
	local connection = v2[instance]

	if connection then
		connection:Disconnect()
		v2[instance] = nil
	end

	StunFx.hide(instance)
end

return {
	setupAll = function()
		if flag then
			return
		end

		flag = true

		for _, tag in ipairs(v) do
			for _, v3 in ipairs(CollectionService:GetTagged(tag)) do
				watch(v3)
			end

			CollectionService:GetInstanceAddedSignal(tag):Connect(watch)
			CollectionService:GetInstanceRemovedSignal(tag):Connect(function(instance)
				for _, tag2 in ipairs(v) do
					if CollectionService:HasTag(instance, tag2) then
						return
					end
				end

				unwatch(instance) -- equivalent call inferred; original call site unknown
			end)
		end
	end
}