local createVector = vector.create
local parent = script.Parent
local Warn = require(script.Parent.Warn)
local Holder = require(parent.Holder)
require(parent.Config)
require(parent.Types)
local count = 0

local function CreateTempModel()
	local model = Instance.new("Model")
	model.Name = "TempModel"
	local part = Instance.new("Part")
	part.Name = "Failed To Get Model"
	part.Size = createVector(3, 5, 3)
	part.Anchored = true
	part.Parent = model
	model.PrimaryPart = part
	model.Parent = workspace
	return model, "CUSTOM"
end

local ModelHelper = {}
ModelHelper.TAG = "CHRONO_MODEL_REPLICATOR"
ModelHelper.CHRONO_META_NAME = "__CHRONO_MODEL_META_ID"

function ModelHelper.ReadyModelFromRep(data, p)
	local model = data.model
	local modelString = data.modelString
	local modelReplicationMode = data.modelReplicationMode or "NATIVE"

	if modelReplicationMode == "NATIVE" and model then
		if data.entityConfig.ATTACH_MODEL_META_DATA == false then
			return model
		end

		local __CHRONO_MODEL_META_INSTANCE = model:FindFirstChild("__CHRONO_MODEL_META_INSTANCE") or Instance.new("Configuration")
		__CHRONO_MODEL_META_INSTANCE.Name = "__CHRONO_MODEL_META_INSTANCE"
		__CHRONO_MODEL_META_INSTANCE.Archivable = false
		__CHRONO_MODEL_META_INSTANCE.Parent = model
		local __CHRONO_MODEL_META_ID = __CHRONO_MODEL_META_INSTANCE:GetAttribute("__CHRONO_MODEL_META_ID")

		if __CHRONO_MODEL_META_ID then
			return model, __CHRONO_MODEL_META_ID
		end

		__CHRONO_MODEL_META_ID = "CHRONO_" .. tostring(count)
		__CHRONO_MODEL_META_INSTANCE:SetAttribute("__CHRONO_MODEL_META_ID", __CHRONO_MODEL_META_ID)
		__CHRONO_MODEL_META_INSTANCE:AddTag("CHRONO_MODEL_REPLICATOR")
		count += 1
		return model, __CHRONO_MODEL_META_ID
	else
		if modelReplicationMode == "CUSTOM" then
			if modelString then
				return modelString
			end

			local parent2 = script.Parent.Parent.Shared._CUSTOM_MODEL_REP

			if p then
				local playerGui = p.PlayerGui
				parent2 = playerGui:FindFirstChild("_ChronoClientModels")

				if not playerGui:FindFirstChild("_ChronoClientModels") then
					parent2 = Instance.new("ScreenGui")
					parent2.ResetOnSpawn = false
					parent2.Name = "_ChronoClientModels"
					parent2.Parent = playerGui
				end
			end

			if model then
				model.Archivable = true
				local clone = model:Clone()
				clone.Parent = parent2
				task.delay(2, function()
					clone:Destroy()
				end)
				return clone
			end
		elseif modelString then
			Warn.medium((`{modelString} is not a valid model string for entity {data.id}`))
		end

		return nil, nil
	end
end

function ModelHelper.CreateModelFromData(p)
	if not p then
		return
	end

	if type(p) == "string" then
		return p, "CUSTOM"
	end

	if p.Parent ~= parent._CUSTOM_MODEL_REP and (not p.Parent or p.Parent.Name ~= "_ChronoClientModels" or not (p.Parent.Parent and p.Parent.Parent:IsA("PlayerGui"))) then
		return p, "NATIVE"
	end

	local clone = p:Clone()

	if not clone then
		return CreateTempModel()
	end

	clone.Parent = Holder.GetEntityStorageInstance()
	return clone, "CUSTOM"
end

return ModelHelper