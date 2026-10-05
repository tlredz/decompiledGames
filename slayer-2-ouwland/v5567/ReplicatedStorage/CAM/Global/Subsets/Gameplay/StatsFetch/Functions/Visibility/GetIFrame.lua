local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local VisibilityHelpers = require(script.Parent.Parent.Parent.Modules.VisibilityHelpers)
return {
	GetIFrame = function(p, p2)
		if p == nil then
			return nil
		end

		local holdTiming, v = VisibilityHelpers.GetHoldTiming(p, "iframe")

		if holdTiming ~= nil or v ~= nil then
			return VisibilityHelpers.NormalizeTiming(holdTiming, v)
		end

		local getvaluesfolder = Utility.getvaluesfolder(p)

		if getvaluesfolder == nil then
			return VisibilityHelpers.NormalizeTiming(holdTiming, v)
		end

		local iframe = getvaluesfolder:FindFirstChild("iframe")
		local escapeiframe = getvaluesfolder:FindFirstChild("escapeiframe")

		if iframe or escapeiframe then
			local flag = true

			if p2 ~= nil then
				local name = p2.Name

				if iframe and iframe.Value == name or escapeiframe and escapeiframe.Value == name then
					flag = false
				else
					for _, child in getvaluesfolder:GetChildren() do
						if not ((child.Name == "iframe" or child.Name == "escapeiframe") and child.Value == name) then
							continue
						end

						flag = false
						break
					end
				end
			end

			if flag then
				v = 1
			end
		end

		return VisibilityHelpers.NormalizeTiming(holdTiming, v)
	end
}