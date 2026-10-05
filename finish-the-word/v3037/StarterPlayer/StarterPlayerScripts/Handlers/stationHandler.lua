_G.import("event")
local import = _G.import("stationCollection")
local import2 = _G.import("modelUtil")
local CollectionService = game:GetService("CollectionService")

local function initStation(child)
	local v = import:get(child.Name)

	if not v then
		return
	end

	local trigger = child:FindFirstChild("Trigger")

	if not trigger then
		return
	end

	if v.Client then
		v.Client(child)
	end

	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.Parent = trigger
	proximityPrompt.ActionText = v.ActionText
	proximityPrompt.ObjectText = v.ObjectText
	proximityPrompt.HoldDuration = v.HoldDuration or 0.5
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.MaxActivationDistance = 10
	proximityPrompt.Triggered:Connect(v.OnTriggered)
	CollectionService:AddTag(proximityPrompt, "StationPrompt")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function initStations()
	for _, child in pairs(workspace.Meta.Stations:GetChildren()) do
		initStation(child)
	end
end

return {
	Priority = 1,
	Run = function()
		import2.getAttribute(workspace, "Mode"):andThen(function(p)
			if p == "RANKED" then
				return
			end

			initStations() -- equivalent call inferred; original call site unknown
		end)
	end
}