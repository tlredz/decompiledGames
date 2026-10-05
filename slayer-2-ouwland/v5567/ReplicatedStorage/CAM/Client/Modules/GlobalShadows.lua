local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local globalShadowsChangedConnection = nil

local function set(flag: boolean)
	if flag then
		if globalShadowsChangedConnection ~= nil then
			globalShadowsChangedConnection:Disconnect()
			globalShadowsChangedConnection = nil
		end

		if not Lighting.GlobalShadows then
			Lighting.GlobalShadows = true
		end
	else
		if Lighting.GlobalShadows then
			Lighting.GlobalShadows = false
		end

		if globalShadowsChangedConnection == nil then
			globalShadowsChangedConnection = Lighting:GetPropertyChangedSignal("GlobalShadows"):Connect(function()
				if Lighting.GlobalShadows then
					Lighting.GlobalShadows = false
				end
			end)
		end
	end
end

return {
	Start = function()
		if not RunService:IsClient() then
			return
		end

		local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
		local v = DataValue.new(SettingsKeys.Shadows.Path, SettingsKeys.Shadows.Default, SettingsKeys.Scope)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function push()
			set(v:Get() ~= false)
		end

		v.Changed:Connect(push)
		push() -- equivalent call inferred; original call site unknown
	end
}