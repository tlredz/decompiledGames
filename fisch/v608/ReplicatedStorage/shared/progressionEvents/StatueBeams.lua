local CollectionService = game:GetService("CollectionService")
local _utils = require(script.Parent:WaitForChild("_utils"))
local v = {
	[3] = "Wednesday",
	[2] = "Thursday",
	[1] = "Friday",
	[0] = "Saturday"
}

local function syncFolders(p: string, object)
	for _, v2 in CollectionService:GetTagged("StatueBeams") do
		for k, childName in v do
			local child = v2:FindFirstChild(childName)

			if child then
				_utils.SetParticlesVisibility(child, object:IsStepActive(p, k))
			end
		end
	end

	for _, v2 in CollectionService:GetTagged("StatueCave") do
		for k, childName in v do
			local child = v2:FindFirstChild(childName)

			if not child then
				continue
			end

			for _, v3 in child:QueryDescendants("BasePart") do
				if not v3:GetAttribute("OriginalTransparency") then
					v3:SetAttribute("OriginalTransparency", v3.Transparency)
				end

				local isStepActive = object:IsStepActive(p, k)
				v3.CanCollide = not isStepActive
				v3.Transparency = isStepActive and 1 or v3:GetAttribute("OriginalTransparency")
			end

			_utils.SetParticlesVisibility(child, not object:IsStepActive(p, k))
		end
	end
end

return {
	Name = "StatueBeams",
	Event = {
		TargetDate = _utils.UTCEpoch(2026, 5, 9, 16, 0),
		Tag = "StatueBeams",
		OnRefresh = syncFolders
	},
	Features = {
		[3] = {
			Hour = 0
		},
		[2] = {
			Hour = 0
		},
		[1] = {
			Hour = 0
		},
		[0] = {
			Hour = 0
		}
	}
}