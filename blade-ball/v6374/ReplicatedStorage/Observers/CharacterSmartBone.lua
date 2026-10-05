local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local v = {}
local gameSettings = UserSettings().GameSettings
local value = gameSettings.SavedQualityLevel.Value

-- equivalent calls inferred from this helper; original call sites unknown
local function apply_dt(instance, attributeName: string)
	local attribute = instance:GetAttribute(attributeName)

	if attribute then
		instance:SetAttribute(attributeName, attribute * 60)
	end
end

gameSettings.Changed:Connect(function()
	local value2 = gameSettings.SavedQualityLevel.Value
	local v2 = value >= 5
	local v3 = value2 >= 5

	if v2 == v3 then
		return
	end

	for k, v4 in v do
		if v3 then
			if not v4 then
				apply_dt(k, "Gravity") -- equivalent call inferred; original call site unknown
				apply_dt(k, "Force") -- equivalent call inferred; original call site unknown
				v[k] = true
			end

			k:AddTag("SmartBone")
		else
			k:RemoveTag("SmartBone")
		end
	end
end)
return Observers.observeTag("CharacterSmartBone", function(instance)
	local isDescendant = instance:IsDescendantOf(workspace.CurrentCamera)
	local v2

	if isDescendant then
		v2 = gameSettings.SavedQualityLevel.Value >= 5
		v[instance] = v2
	else
		v2 = true
	end

	if v2 then
		apply_dt(instance, "Gravity") -- equivalent call inferred; original call site unknown
		apply_dt(instance, "Force") -- equivalent call inferred; original call site unknown
		instance:AddTag("SmartBone")
	end

	return function()
		instance:RemoveTag("SmartBone")

		if isDescendant then
			v[instance] = nil
		end
	end
end, { workspace.Alive, workspace.Dead, workspace.CurrentCamera })