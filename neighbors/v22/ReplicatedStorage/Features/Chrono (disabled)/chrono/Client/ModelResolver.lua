local CollectionService = game:GetService("CollectionService")
local Warn = require(script.Parent.Parent.Shared.Warn)
require(script.Parent.Parent.Shared.Config)
require(script.Parent.Parent.Shared.Types)
local Entity = require(script.Parent.Parent.Shared.Entity)
local ModelHelper = require(script.Parent.Parent.Shared.ModelHelper)
local TAG = ModelHelper.TAG
local CHRONO_META_NAME = ModelHelper.CHRONO_META_NAME
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function OnInstanceAdded(instance)
	local attribute = instance:GetAttribute(CHRONO_META_NAME)

	if attribute then
		v[attribute] = instance.Parent
		Warn.low((`Model with meta {attribute} was added to the game. Entities using this model will now be able to resolve it.`))
	end
end

CollectionService:GetInstanceAddedSignal(TAG):Connect(OnInstanceAdded)
CollectionService:GetInstanceRemovedSignal(TAG):Connect(function(instance)
	local attribute = instance:GetAttribute(CHRONO_META_NAME)

	if attribute then
		v[attribute] = nil
		Warn.low((`Model with meta {attribute} was removed from the game. Entities using this model will no longer be able to resolve it.`))
	end
end)

for _, v2 in CollectionService:GetTagged(TAG) do
	OnInstanceAdded(v2) -- equivalent call inferred; original call site unknown
end

return function(data)
	local model = data.model

	if model and model.Parent then
		return
	end

	local _modelMetaData = data._modelMetaData

	if not _modelMetaData then
		return
	end

	local v2 = v[_modelMetaData]

	if v2 and v2 ~= model then
		Entity.SetModel(data, v2)
		Warn.low((`Model with meta {_modelMetaData} was resolved for entity {data.id}.`))
	end
end