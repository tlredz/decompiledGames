local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local t = require(ReplicatedStorage.Packages.t)
local intersection = t.intersection(t.numberMinExclusive(-1e999), t.numberMaxExclusive(1e999))
local ModelBounds = require(ReplicatedStorage.Shared.Utils.ModelBounds)
local EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
local EggRenderer = require(script.Parent.EggRenderer)
local EggScaling = require(ReplicatedStorage.Shared.Util.EggScaling)
require(ReplicatedStorage.Shared.Types.Eggs)
local Log = require(ReplicatedStorage.Packages.Log)
local Player = require(ReplicatedStorage.Shared.Player)
local v = Log.new()
local PlacedEggGrowthPresentationPolicy = {
	GetGrowthAlpha = function(p, p2: number?)
		return EggRecords.GrowthAlpha(p, Workspace:GetServerTimeNow(), p.GrowthSpeedMultiplier, p2)
	end,
	GetDirectGrowthTweenRemainingSeconds = function(p, p2: number)
		local placement = p.Placement

		if placement == nil or placement.ReadyAt ~= nil or EggRecords.GrowthDuration(p) >= 10 then
			return 0
		end

		return EggRecords.WallSecondsRemaining(p, p2, p.GrowthSpeedMultiplier)
	end,
	GetStartScale = function(p)
		return EggScaling.PlacedStart(EggRenderer.GetAuthoredScale(p), p.AssetScale, p.AssetCategory)
	end,
	GetTargetScale = function(p)
		return EggScaling.PlacedTarget(EggRenderer.GetAuthoredScale(p), p.AssetScale, p.AssetCategory)
	end
}

function PlacedEggGrowthPresentationPolicy.GetVisualScale(p, p2: number, p3: number)
	return p2 + PlacedEggGrowthPresentationPolicy.GetGrowthAlpha(p, nil) * (p3 - p2)
end

function PlacedEggGrowthPresentationPolicy.IsReady(p, p2: number?)
	return PlacedEggGrowthPresentationPolicy.GetGrowthAlpha(p, p2) >= 1
end

function PlacedEggGrowthPresentationPolicy.GetRemainingGrowthSeconds(p, p2: number?)
	return EggRecords.GrowthSecondsRemaining(p, Workspace:GetServerTimeNow(), p.GrowthSpeedMultiplier, p2)
end

function PlacedEggGrowthPresentationPolicy.GetSkipReason(p)
	t.strict(t.instanceIsA("Model"))(p)
	local rootPart = Player.FindRootPart(Players.LocalPlayer)

	if rootPart == nil then
		return "local player root is unavailable"
	end

	local currentCamera = Workspace.CurrentCamera

	if currentCamera == nil then
		return "current camera is unavailable"
	end

	local modelBounds = ModelBounds(p)
	local magnitude = (rootPart.Position - modelBounds.Position).Magnitude

	if magnitude > 300 then
		return (`distance {math.round(magnitude)} studs exceeds {300}`)
	end

	local _, v3 = currentCamera:WorldToViewportPoint(modelBounds.Position)

	if v3 then
		return nil
	end

	return "visible bounds center is off-screen"
end

function PlacedEggGrowthPresentationPolicy.GetGrowthScaleDeltaSkipReason(p: number, p2: number)
	t.strict(intersection)(p)
	t.strict(intersection)(p2)
	local v2 = math.abs(p2 - p)

	if v2 <= 0.15 then
		return (`scale delta {math.round(v2 * 1000) / 1000} does not exceed {0.15} presentation threshold`)
	end

	local v3 = v2 / math.max(math.abs(p), 0.001)

	if v3 <= 0.03 then
		return (`relative scale delta {math.round(v3 * 10000) / 100}% does not exceed {3}% presentation threshold`)
	end

	return nil
end

function PlacedEggGrowthPresentationPolicy.GetNaturalGrowthSkipReason(object, p: number)
	t.strict(t.instanceIsA("Model"))(object)
	t.strict(intersection)(p)
	local growthScaleDeltaSkipReason = PlacedEggGrowthPresentationPolicy.GetGrowthScaleDeltaSkipReason(
		object:GetScale(),
		p
	)

	if growthScaleDeltaSkipReason == nil then
		return PlacedEggGrowthPresentationPolicy.GetSkipReason(object)
	end

	return growthScaleDeltaSkipReason
end

function PlacedEggGrowthPresentationPolicy.LogSkipped(p: string, p2: string, p3: string)
	t.strict(t.string)(p)
	t.strict(t.string)(p2)
	t.strict(t.string)(p3)
	v:AtInfo():Log((`Skipped placed egg {p2} for {p}: {p3}`))
end

return PlacedEggGrowthPresentationPolicy