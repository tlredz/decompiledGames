local module = require("@game/ReplicatedStorage/Omni")
local Callback = require(script.Callback)
local interactable = workspace:WaitForChild("Server"):WaitForChild("Interactable")
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { interactable }
local v = {
	Interactable = nil,
	Debounce = false
}

local function HasZoneCallbacks()
	for _, v2 in Callback do
		if type(v2) == "table" and (v2.Join or v2.Leave) then
			return true
		end
	end

	return false
end

if HasZoneCallbacks() then
	module.Utils.Loop:Connect({
		Time = 0.1,
		Callback = function()
			if v.Debounce or not module.Loaded then
				return
			end

			local HRP = module:GetHRP()

			if not HRP then
				return
			end

			local partsInPart = game.Workspace:GetPartsInPart(HRP, overlapParams)
			local interactable2

			if partsInPart and #partsInPart == 1 then
				interactable2 = partsInPart[1]
			end

			if interactable2 and not v.Interactable then
				v.Debounce = true
				v.Interactable = interactable2
				local v3 = Callback[v.Interactable.Name]

				if v3 and v3.Join then
					task.defer(function()
						v3.Join(v.Interactable)
					end)
					task.delay(0.55, function()
						v.Debounce = false
					end)
				else
					v.Debounce = false
				end
			elseif not interactable2 and v.Interactable then
				v.Debounce = true
				local v3 = Callback[v.Interactable.Name]

				if v3 and v3.Leave then
					task.defer(function()
						v3.Leave(v.Interactable)
					end)
					v.Interactable = nil
					task.delay(0.55, function()
						v.Debounce = false
					end)
				else
					v.Interactable = nil
					v.Debounce = false
				end
			end
		end
	})
end

return {}