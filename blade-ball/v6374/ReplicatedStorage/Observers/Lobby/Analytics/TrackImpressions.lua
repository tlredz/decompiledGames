local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local AnalyticsController = require(ReplicatedStorage.Controllers.AnalyticsController)
local ImpressionTrackingData = require(ReplicatedStorage.Shared.Analytics.ImpressionTrackingData)
local Thread = require(ReplicatedStorage.Common.Utils.Utilities.Thread)
local _ = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
return Observers.observeTagNoAncestry("TrackImpressions", function(pVInstance)
	local impressionType = pVInstance:GetAttribute("ImpressionType")

	if not impressionType then
		warn((`TrackImpressions Observer is missing ImpressionType attribute on {pVInstance:GetFullName()}`))
		return nil
	end

	local impression = ImpressionTrackingData.Impressions[impressionType]

	if not impression or impression.Type ~= "Model" or not pVInstance:IsA("PVInstance") then
		return nil
	end

	local maid = Trove.new()
	local pivot = pVInstance:GetPivot()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isInRange()
		return (currentCamera.CFrame.Position - pivot.Position).Magnitude <= impression.MaximumViewDistance
	end

	local function isVisible()
		local _, v = currentCamera:WorldToScreenPoint(pivot.Position)
		return v
	end

	local v = 0
	local v2 = 0
	local v3 = false
	local v4 = false
	local isDescendant = pVInstance:IsDescendantOf(workspace)
	maid:Add(Thread.Every(0.1, function()
		if not isDescendant then
			return
		end

		local now = os.clock()

		if now - v2 <= impression.ImpressionCooldown then
			return
		end

		local inRange = isInRange() -- equivalent call inferred; original call site unknown

		if inRange then
			local v5
			v5, inRange = currentCamera:WorldToScreenPoint(pivot.Position)
		end

		if inRange == v3 then
			if inRange and not v4 and now - v >= impression.MinimumExposureTime then
				v4 = true
				v2 = now
				AnalyticsController:TrackImpression(impressionType)
			end
		else
			if inRange then
				v = now
			else
				v4 = false
			end

			v3 = inRange
		end
	end))
	maid:Add(pVInstance.AncestryChanged:Connect(function()
		isDescendant = pVInstance:IsDescendantOf(workspace)
	end))
	return function()
		maid:Destroy()
	end
end)