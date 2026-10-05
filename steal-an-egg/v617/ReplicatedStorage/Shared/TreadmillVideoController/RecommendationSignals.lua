local RecommendationService = game:GetService("RecommendationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Log = require(ReplicatedStorage.Packages.Log)
require(script.Parent.RecommendationFeedSource)
local RecommendationFlags = require(script.Parent.RecommendationFlags)
local v = Log.new()
local v2 = nil
local RecommendationSignals = {}

local function resolveDepartureIntent(p, p2: number, p3: number?)
	if p.Ended or p.Engaged or p3 ~= nil and p3 >= 0.8 then
		return Enum.RecommendationDepartureIntent.Positive
	end

	if p2 < 3 then
		return Enum.RecommendationDepartureIntent.Negative
	end

	if p3 == nil or not (p3 < 0.25) then
		return Enum.RecommendationDepartureIntent.Neutral
	end

	return Enum.RecommendationDepartureIntent.Negative
end

local function logAction(item, p, p2)
	if not RecommendationFlags.Enabled:Get() then
		return
	end

	local success, result = pcall(function()
		RecommendationService:LogActionEvent(p, item.ItemId, item.TracingId, p2)
	end)

	if not success then
		v:AtWarning():Log((`Failed to log treadmill recommendation action: {result}`))
	end
end

function RecommendationSignals.HasActiveView()
	return v2 ~= nil
end

function RecommendationSignals.EndView(p: number?)
	local v3 = v2
	v2 = nil

	if not (v3 ~= nil and RecommendationFlags.Enabled:Get()) then
		return
	end

	local duration = os.clock() - v3.StartedAt
	local departureIntent = resolveDepartureIntent(v3, duration, p)
	local success, result = pcall(function()
		RecommendationService:LogImpressionEvent(
			Enum.RecommendationImpressionType.View,
			v3.Item.ItemId,
			v3.Item.TracingId,
			{
				Duration = duration,
				Weight = 1,
				ItemPosition = v3.Item.ItemPosition,
				DepartureIntent = departureIntent
			}
		)
	end)

	if not success then
		v:AtWarning():Log((`Failed to log treadmill recommendation impression: {result}`))
	end
end

function RecommendationSignals.BeginView(p)
	RecommendationSignals.EndView(nil)
	v2 = {
		Item = p,
		StartedAt = os.clock(),
		Ended = false,
		Engaged = false
	}
end

function RecommendationSignals.MarkEnded()
	local v3 = v2

	if v3 ~= nil then
		v3.Ended = true
	end
end

function RecommendationSignals.NotifyLikeResult(p: string, flag: boolean)
	local v3 = v2

	if v3 == nil or v3.Item.MediaKey ~= p then
		return
	end

	if flag then
		v3.Engaged = true
	end

	local item = v3.Item
	local v5

	if flag then
		v5 = Enum.RecommendationActionType.AddReaction
	else
		v5 = Enum.RecommendationActionType.RemoveReaction
	end

	logAction(item, v5, {
		ReactionType = "Like"
	})
end

function RecommendationSignals.NotifyCommentPosted(p: string)
	local v3 = v2

	if v3 == nil or v3.Item.MediaKey ~= p then
		return
	end

	v3.Engaged = true
	logAction(v3.Item, Enum.RecommendationActionType.Comment, nil)
end

function RecommendationSignals.NotifyShared()
	local v3 = v2

	if v3 == nil then
		return
	end

	v3.Engaged = true
	logAction(v3.Item, Enum.RecommendationActionType.Share, nil)
end

return RecommendationSignals