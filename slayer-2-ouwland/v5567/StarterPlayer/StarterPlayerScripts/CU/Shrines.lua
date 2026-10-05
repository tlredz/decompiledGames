local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Archives = require(ReplicatedStorage.CAM.Client.Modules.Archives)
local ShrineUnlock = require(ReplicatedStorage.CAM.Client.Modules.ShrineUnlock)

local function watch(proximityPrompt)
	if not proximityPrompt:IsA("ProximityPrompt") then
		return
	end

	local objectText = proximityPrompt.ObjectText

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refresh()
		proximityPrompt.Enabled = not Archives.IsUnlocked("Shrines", objectText)
	end

	refresh() -- equivalent call inferred; original call site unknown
	local connection = Archives.Connect("Shrines", function(list)
		if table.find(list, objectText) ~= nil then
			refresh() -- equivalent call inferred; original call site unknown
		end
	end)
	proximityPrompt.Triggered:Connect(function()
		ShrineUnlock.Ask(objectText)
	end)
	proximityPrompt.Destroying:Connect(function()
		connection:Disconnect()
	end)
end

Archives.WaitLoaded()

for _, v in CollectionService:GetTagged("ShrineProximityPrompt") do
	watch(v)
end

CollectionService:GetInstanceAddedSignal("ShrineProximityPrompt"):Connect(watch)