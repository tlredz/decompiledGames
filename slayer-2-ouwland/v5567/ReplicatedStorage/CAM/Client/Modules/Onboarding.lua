local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local v = {
	[3] = {
		Target = "MenuOpener",
		Content = "Open the <b>menu</b> from here",
		Side = "Bottom"
	},
	[4] = {
		Target = "Inventory",
		Content = "Open your <b>Inventory</b>",
		Side = "Right"
	},
	[5] = {
		Target = "Close",
		Content = "<b>Close</b> the menu when you are done",
		Side = "Right"
	}
}
local Onboarding = {
	Step = DataValue.new("Misc/Onboarding", 0),
	LAST = 6
}
local v2 = 0

function Onboarding.Done()
	return (math.max(Onboarding.Step:Get() or 0, v2))
end

local refresh

function Onboarding.Complete(p: number)
	if p <= Onboarding.Done() then
		return
	end

	v2 = p
	SignalEvent.ToServer("Onboarding", p)
	refresh()
end

local v3 = {}
local v4 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function stampGuided()
	localPlayer:SetAttribute("Guided", v4 ~= nil or nil)
end

local function show()
	local v5 = v[Onboarding.Done()]
	local focus

	if v5 ~= nil then
		focus = v3[v5.Target]
	end

	if v4 ~= nil and v4.Focus == focus then
		return
	end

	if v4 ~= nil then
		v4.Popup:Destroy()
		v4 = nil
	end

	if focus == nil then
		return
	end

	v4 = {
		Focus = focus,
		Popup = PopUpCreator.new({
			Type = "Checklist",
			Focus = focus,
			Content = v5.Content,
			Side = v5.Side
		})
	}
end

refresh = function()
	show()
	stampGuided() -- equivalent call inferred; original call site unknown
end

function Onboarding.Set(p: string, p2)
	if v3[p] == p2 then
		return
	end

	v3[p] = p2
	refresh()
end

local v5 = Onboarding.Step:Get() or 0
Onboarding.Step.Changed:Connect(function(value)
	local v6 = value or 0

	if v6 < v5 then
		v2 = 0
	end

	v5 = v6
	refresh()
end)
return Onboarding