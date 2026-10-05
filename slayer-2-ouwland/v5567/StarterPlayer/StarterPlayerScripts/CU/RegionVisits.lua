local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AreaLocator = require(ReplicatedStorage.CAM.Global.Subsets.Areas.AreaLocator)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)

-- equivalent calls inferred from this helper; original call sites unknown
local function report(p: string, p2: string?)
	if p ~= nil and p ~= "" then
		SignalEvent.ToServer("VisitRegion", p)
	end

	if p2 ~= nil and p2 ~= "" and p2 ~= p then
		SignalEvent.ToServer("VisitRegion", p2)
	end
end

AreaLocator.AreaEquipped.Update:Connect(function(p: string, p2: string)
	report(p, p2) -- equivalent call inferred; original call site unknown
end)
report(AreaLocator.AreaEquipped.Parent, AreaLocator.AreaEquipped.Sub) -- equivalent call inferred; original call site unknown
Players.LocalPlayer.CharacterAdded:Connect(function(character)
	character:WaitForChild("HumanoidRootPart")
	report(AreaLocator.AreaEquipped.Parent, AreaLocator.AreaEquipped.Sub) -- equivalent call inferred; original call site unknown
end)