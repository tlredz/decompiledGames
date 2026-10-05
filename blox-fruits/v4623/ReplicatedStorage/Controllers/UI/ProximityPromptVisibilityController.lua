local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local AttributeCounter = require(game.ReplicatedStorage.Util.AttributeCounter)
local v = {}
local v2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function applyState(p, state)
	local enabled

	if state.active and v2 then
		enabled = false
	else
		enabled = state.enabled
	end

	if p.Enabled == enabled then
		return
	end

	state.applying = true
	p.Enabled = enabled
	state.applying = false
end

local function registerPrompt(proximityPrompt)
	if not proximityPrompt:IsA("ProximityPrompt") or v[proximityPrompt] then
		return
	end

	local v3 = {
		enabled = proximityPrompt.Enabled,
		applying = false,
		active = proximityPrompt:IsDescendantOf(workspace),
		enabledConnection = nil,
		ancestryConnection = nil
	}
	v[proximityPrompt] = v3
	v3.enabledConnection = proximityPrompt:GetPropertyChangedSignal("Enabled"):Connect(function()
		if v3.applying then
			return
		end

		v3.enabled = proximityPrompt.Enabled

		if v2 then
			applyState(proximityPrompt, v3) -- equivalent call inferred; original call site unknown
		end
	end)
	v3.ancestryConnection = proximityPrompt.AncestryChanged:Connect(function()
		local isDescendant = proximityPrompt:IsDescendantOf(workspace)

		if v3.active == isDescendant then
			return
		end

		v3.active = isDescendant
		applyState(proximityPrompt, v3) -- equivalent call inferred; original call site unknown
	end)
	applyState(proximityPrompt, v3) -- equivalent call inferred; original call site unknown
end

local function unregisterPrompt(proximityPrompt)
	if not proximityPrompt:IsA("ProximityPrompt") then
		return
	end

	local v3 = v[proximityPrompt]

	if not v3 then
		return
	end

	v[proximityPrompt] = nil

	if v3.enabledConnection then
		v3.enabledConnection:Disconnect()
	end

	if v3.ancestryConnection then
		v3.ancestryConnection:Disconnect()
	end

	if v3.active and v2 then
		proximityPrompt.Enabled = v3.enabled
	end
end

local function updateMenuHidden(p: number)
	local v3 = p > 0

	if v2 == v3 then
		return
	end

	v2 = v3

	for k, v4 in v do
		applyState(k, v4) -- equivalent call inferred; original call site unknown
	end
end

return {
	init = function()
		CollectionService:GetInstanceAddedSignal("ProximityPrompt"):Connect(registerPrompt)
		CollectionService:GetInstanceRemovedSignal("ProximityPrompt"):Connect(unregisterPrompt)

		for _, v3 in CollectionService:GetTagged("ProximityPrompt") do
			registerPrompt(v3)
		end

		AttributeCounter.connect(Players.LocalPlayer, "MenuHidden", updateMenuHidden, true)
	end
}