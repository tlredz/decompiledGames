local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Observers = require(packages.Observers)
local Trove = require(packages.Trove)
local DeepConfig = require(ReplicatedStorage.shared.modules.DeepConfig)
local module = require("../../DeepController")
local maid = Trove.new()

local function setupTower(folder)
	local sector = folder:GetAttribute("Sector")

	if typeof(sector) ~= "string" then
		return
	end

	local maid2 = maid:Extend()
	local v = {}
	local v2 = false

	local function applyToPart(state)
		if not v[state] then
			v[state] = {
				Color = state.Color,
				Material = state.Material
			}
		end

		if v2 then
			state.Material = Enum.Material.Neon
			state.Color = DeepConfig.BeaconActiveColor
		else
			state.Material = v[state].Material
			state.Color = v[state].Color
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyToPrompt(p)
		p.Enabled = not v2
	end

	local function applyAll()
		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("BasePart") and descendant.Name == "ColorPart" then
				applyToPart(descendant)
			elseif descendant:IsA("ProximityPrompt") then
				applyToPrompt(descendant) -- equivalent call inferred; original call site unknown
			end
		end
	end

	maid2:Connect(folder.DescendantAdded, function(instance)
		if instance:IsA("BasePart") and instance.Name == "ColorPart" then
			applyToPart(instance)
		elseif instance:IsA("ProximityPrompt") then
			applyToPrompt(instance) -- equivalent call inferred; original call site unknown
		end
	end)
	maid2:Add(module:ObserveSector(sector, function(p)
		v2 = p

		if not (p and workspace:GetAttribute("ClientCutsceneRunning")) then
			applyAll()
			return
		end

		for _, proximityPrompt in folder:GetDescendants() do
			if not proximityPrompt:IsA("ProximityPrompt") then
				continue
			end

			applyToPrompt(proximityPrompt) -- equivalent call inferred; original call site unknown
		end
	end))
	return function()
		maid2:Destroy()
	end
end

return {
	Start = function(_)
		maid:Add(Observers.observeTag("DeepBeaconTower", setupTower))
	end
}