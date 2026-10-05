game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local packages = ReplicatedStorage.packages
local Signal = require(packages.Signal)
local State = require(packages.State)
local legacy = ReplicatedStorage.client.legacy
local legacyUiLoader = require(legacy.legacyUiLoader)
local legacyControllers = ReplicatedStorage.client.legacyControllers
local PersonalAquariumController = require(legacyControllers.PersonalAquariumController)
require(legacyControllers.HudController)
local sharedData = ReplicatedStorage.shared.modules.SharedPersonalAquarium.SharedData
local UnlockFeatureData = require(sharedData.UnlockFeatureData)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
require("@self/Types")
local module = require("@self/HandleButton")
local v = {
	Component = {
		Signals = {
			ForceClose = Signal.new(),
			VisitAquarium = Signal.new()
		},
		Upvalues = {
			PersonalAquariumController = PersonalAquariumController,
			HandleButtonFn = module,
			CurrentFishType = State.new("Profit")
		}
	}
}
local v2 = {
	Component = {}
}
local personalAquarium = legacyUiLoader.PlayerGui.hud.safezone.PersonalAquarium
local personalAquarium2 = legacyUiLoader.PlayerGui.hud.safezone.topbar.PersonalAquarium

-- equivalent calls inferred from this helper; original call sites unknown
local function enableTopbarButton(_)
	personalAquarium2.Visible = true
	personalAquarium2.Active = true
end

local PersonalAquarium = {}

function PersonalAquarium.init()
	local _GetLevelObjectValue = PersonalAquarium._GetLevelObjectValue()

	if _GetLevelObjectValue.Value < UnlockFeatureData.UnlockLevel then
		PersonalAquarium._SubscribeFeatureUnlock(_GetLevelObjectValue)
	else
		local _ = PersonalAquarium._Close
		enableTopbarButton() -- equivalent call inferred; original call site unknown
	end

	PersonalAquarium._SetGeneralConnections()
	PersonalAquarium._LoadComponents()
end

function PersonalAquarium._LoadComponents()
	local children = script.Components:GetChildren()
	local modules = {}

	for _, v3 in children do
		local v4 = v3
		task.spawn(function()
			local module2 = require(v4)
			local v5 = {
				Instance = personalAquarium[v4.Name],
				Signals = v.Component.Signals,
				Shared = v.Component.Upvalues,
				Personal = 0
			}
			local personal

			if v2[v4.Name] then
				personal = v2[v4.Name]
			end

			v5.Personal = personal
			module2:Start(v5)
			table.insert(modules, module2)
		end)
	end

	personalAquarium:GetPropertyChangedSignal("Visible"):Connect(function()
		if personalAquarium.Visible then
			for _, v3 in modules do
				if v3.Opened then
					v3.Opened()
				end
			end
		else
			for _, v3 in modules do
				if v3.Closed then
					v3.Closed()
				end
			end
		end
	end)
end

function PersonalAquarium._Close()
	personalAquarium.Visible = false
end

function PersonalAquarium._SetGeneralConnections()
	module(personalAquarium.Close, PersonalAquarium._Close, false)
	v.Component.Signals.ForceClose:Connect(PersonalAquarium._Close)
end

function PersonalAquarium._SubscribeFeatureUnlock(instance)
	local connection = nil
	connection = instance:GetPropertyChangedSignal("Value"):Connect(function()
		if instance.Value >= UnlockFeatureData.UnlockLevel then
			local _ = PersonalAquarium._Close
			enableTopbarButton() -- equivalent call inferred; original call site unknown
			connection:Disconnect()
		end
	end)
end

function PersonalAquarium._GetLevelObjectValue()
	return (legacyLocalPlayerData.fetch():WaitForChild("Stats"):WaitForChild("level"))
end

return PersonalAquarium