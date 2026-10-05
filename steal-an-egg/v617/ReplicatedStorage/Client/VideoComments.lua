local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TreadmillFlags = require(ReplicatedStorage.Shared.Flags.TreadmillFlags)
require(ReplicatedStorage.Shared.Globals.Constants)
local TreadmillMediaComments = require(ReplicatedStorage.Shared.Types.TreadmillMediaComments)
local Log = require(ReplicatedStorage.Packages.Log)
local RecommendationSignals = require(ReplicatedStorage.Shared.TreadmillVideoController.RecommendationSignals)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TreadmillMediaCommentsConfig = require(ReplicatedStorage.Shared.Modules.TreadmillMediaCommentsConfig)
local t = require(ReplicatedStorage.Packages.t)
local TryCall = require(ReplicatedStorage.Shared.Utils.TryCall)
local schema = TreadmillMediaComments.Schema
require(script.Types.Interface)
local v = Log.new()
local v2 = {}
local v3 = {}
local v4 = false
local flag = false
local v5 = {}
local VideoComments = {
	CommentCountChanged = Signal.new()
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getInvokeError(value)
	if typeof(value) == "string" then
		return value
	end

	return "RequestFailed"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCachedCommentCount(p: string, p2: number)
	local v6 = math.max(0, (math.floor(p2)))
	local v7 = v2[p]

	if v7 ~= nil then
		v6 = math.max(v7, v6)
	end

	if v7 == v6 then
		return
	end

	v2[p] = v6
	VideoComments.CommentCountChanged:Fire(p, v6)
end

local function refreshCommentCountCache()
	for _, v6 in v3 do
		local v7 = {}

		for _, v8 in v6 do
			v7[v8] = v5[v8] or 0
		end

		local commentCounts = VideoComments.RequestCommentCounts(v6)

		if not commentCounts.Ok then
			return "failed"
		end

		if not commentCounts.Loaded then
			return "unloaded"
		end

		for k, v8 in commentCounts.CountsByMediaKey do
			if (v5[k] or 0) ~= v7[k] then
				continue
			end

			setCachedCommentCount(k, v8) -- equivalent call inferred; original call site unknown
		end
	end

	return "loaded"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startCommentCountRefreshLoop()
	task.spawn(function()
		while flag do
			if TreadmillFlags.CommentsDisabled:Get() then
				task.wait(5)
			else
				if refreshCommentCountCache() == "loaded" then
					v4 = true
				end

				local v6 = v4 and 180 or 2
				task.wait(v6)
			end
		end
	end)
end

function VideoComments.StartCommentCountCache(items)
	t.strict(t.table)(items)

	if flag then
		return
	end

	flag = true
	local v6 = {}
	local v7 = {}

	for _, item in items do
		t.strict(t.string)(item)

		if v6[item] then
			continue
		end

		v6[item] = true
		table.insert(v7, item)

		if not (#v7 >= TreadmillMediaCommentsConfig.COMMENT_COUNT_KEYS_PER_REQUEST) then
			continue
		end

		table.insert(v3, v7)
		v7 = {}
	end

	if #v7 > 0 then
		table.insert(v3, v7)
	end

	startCommentCountRefreshLoop() -- equivalent call inferred; original call site unknown
end

function VideoComments.GetCachedCommentCount(p: string)
	t.strict(t.string)(p)
	return v2[p]
end

function VideoComments.ReconcileCommentCount(p: string, p2: number)
	t.strict(t.string)(p)
	t.strict(t.number)(p2)
	v5[p] = (v5[p] or 0) + 1
	setCachedCommentCount(p, p2) -- equivalent call inferred; original call site unknown
end

function VideoComments.RequestCommentPage(mediaKey: string, cursor: number?, pageSize: number?)
	if TreadmillFlags.CommentsDisabled:Get() then
		return {
			Ok = false,
			Error = "CommentsDisabled"
		}
	end

	t.strict(t.string)(mediaKey)
	t.strict(t.optional(t.number))(cursor)
	t.strict(t.optional(t.number))(pageSize)
	local v6, v7 = TryCall(function()
		return Remotes.Treadmill.AskReplyPage:InvokeServer({
			MediaKey = mediaKey,
			Cursor = cursor,
			PageSize = pageSize
		})
	end)

	if not v6 then
		v:AtWarning():Log((`Failed treadmill comment page request: {v7}`))
		return {
			Ok = false,
			Error = getInvokeError(v7)
		}
	end

	if not schema.CommentPageResult(v7) then
		v:AtWarning():Log("Rejected invalid treadmill comment page response")
		return {
			Ok = false,
			Error = "InvalidResponse"
		}
	end

	if v7.Ok then
		return {
			Ok = true,
			TotalCreatedCount = v7.TotalCreatedCount or 0,
			Comments = v7.Comments or {},
			NextCursor = v7.NextCursor
		}
	end

	return {
		Ok = false,
		Error = v7.Error or "RequestFailed"
	}
end

function VideoComments.RequestCommentCounts(mediaKeys)
	if TreadmillFlags.CommentsDisabled:Get() then
		return {
			Ok = false,
			Error = "CommentsDisabled",
			CountsByMediaKey = {},
			Loaded = false,
			Stale = true
		}
	end

	t.strict(t.table)(mediaKeys)
	local v6, v7 = TryCall(function()
		return Remotes.Treadmill.AskReplyCounts:InvokeServer({
			MediaKeys = mediaKeys
		})
	end)

	if not v6 then
		v:AtWarning():Log((`Failed treadmill comment counts request: {v7}`))
		return {
			Ok = false,
			CountsByMediaKey = {},
			Loaded = false,
			Stale = true,
			Error = getInvokeError(v7)
		}
	end

	if not schema.CommentCountsResult(v7) then
		v:AtWarning():Log("Rejected invalid treadmill comment counts response")
		return {
			Ok = false,
			CountsByMediaKey = {},
			Loaded = false,
			Stale = true,
			Error = "InvalidResponse"
		}
	end

	if v7.Ok then
		return {
			Ok = true,
			CountsByMediaKey = v7.CountsByMediaKey or {},
			Loaded = v7.Loaded == true,
			Stale = v7.Stale == true
		}
	end

	return {
		Ok = false,
		CountsByMediaKey = {},
		Loaded = v7.Loaded == true,
		Stale = v7.Stale ~= false,
		Error = v7.Error or "RequestFailed"
	}
end

function VideoComments.PostComment(mediaKey: string, message: string, imageAssetId: number?)
	if TreadmillFlags.CommentsDisabled:Get() then
		return {
			Ok = false,
			Error = "CommentsDisabled"
		}
	end

	t.strict(t.string)(mediaKey)
	t.strict(t.string)(message)
	t.strict(t.optional(t.number))(imageAssetId)
	local v6, v7 = TryCall(function()
		return Remotes.Treadmill.AskPostReply:InvokeServer({
			MediaKey = mediaKey,
			Message = message,
			ImageAssetId = imageAssetId
		})
	end)

	if not v6 then
		v:AtWarning():Log((`Failed treadmill post comment request: {v7}`))
		return {
			Ok = false,
			Error = getInvokeError(v7)
		}
	end

	if not schema.PostCommentResult(v7) then
		v:AtWarning():Log("Rejected invalid treadmill post comment response")
		return {
			Ok = false,
			Error = "InvalidResponse"
		}
	end

	if not v7.Ok or v7.Comment == nil then
		return {
			Ok = false,
			Error = v7.Error or "RequestFailed"
		}
	end

	RecommendationSignals.NotifyCommentPosted(mediaKey)
	return {
		Ok = true,
		Comment = v7.Comment,
		Pending = v7.Pending == true
	}
end

function VideoComments.SetCommentLike(mediaKey: string, commentId: string, flag2: boolean)
	if TreadmillFlags.CommentsDisabled:Get() then
		return {
			Ok = false,
			Error = "CommentsDisabled",
			CommentId = commentId
		}
	end

	t.strict(t.string)(mediaKey)
	t.strict(t.string)(commentId)
	t.strict(t.boolean)(flag2)
	local v6, v7 = TryCall(function()
		return Remotes.Treadmill.AskReplyFavour:InvokeServer({
			MediaKey = mediaKey,
			CommentId = commentId,
			Liked = flag2
		})
	end)

	if not v6 then
		v:AtWarning():Log((`Failed treadmill comment like request: {v7}`))
		return {
			Ok = false,
			Error = getInvokeError(v7),
			CommentId = commentId,
			LikeCount = nil
		}
	end

	if not schema.SetCommentLikeResult(v7) then
		v:AtWarning():Log("Rejected invalid treadmill comment like response")
		return {
			Ok = false,
			Error = "InvalidResponse",
			CommentId = commentId,
			LikeCount = nil
		}
	end

	if v7.Ok then
		return {
			Ok = true,
			CommentId = v7.CommentId or commentId,
			Liked = v7.Liked == true,
			Delta = v7.Delta or 0,
			LikeCount = v7.LikeCount or 0
		}
	end

	return {
		Ok = false,
		Error = v7.Error or "RequestFailed",
		CommentId = v7.CommentId or commentId,
		LikeCount = v7.LikeCount
	}
end

return VideoComments