local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local Schema = {
	MediaKey = t.string,
	CountsByMediaLikeKey = t.map(t.string, t.number),
	LikerUserIds = t.array(t.integer)
}
Schema.LikerUserIdsByMediaLikeKey = t.map(t.string, Schema.LikerUserIds)
Schema.MemberUserIdSet = t.map(t.string, t.boolean)
Schema.MembersByMediaLikeKey = t.map(t.string, Schema.MemberUserIdSet)
Schema.MemberBucketsByMediaLikeKey = t.map(t.string, t.map(t.string, Schema.MemberUserIdSet))
Schema.MemberCountsByMediaLikeKey = t.map(t.string, t.number)
Schema.OldestMemberBucketByMediaLikeKey = t.map(t.string, t.number)
Schema.LikedTreadmillMedia = t.map(t.string, t.boolean)
Schema.LikeSnapshot = t.strictInterface({
	CountsByMediaLikeKey = Schema.CountsByMediaLikeKey,
	LikedTreadmillMedia = Schema.LikedTreadmillMedia
})
Schema.FriendLikeSnapshot = t.strictInterface({
	FriendLikeUserIdsByMediaLikeKey = Schema.LikerUserIdsByMediaLikeKey
})
Schema.FriendLikeSnapshotRequest = t.strictInterface({
	MediaKeys = t.optional(t.array(Schema.MediaKey))
})
Schema.LikeToggleResult = t.strictInterface({
	Ok = t.boolean,
	Liked = t.optional(t.boolean),
	Delta = t.optional(t.number),
	Count = t.optional(t.number),
	Error = t.optional(t.string)
})
Schema.LikeToggleRequest = t.strictInterface({
	MediaKey = Schema.MediaKey,
	Liked = t.boolean
})
Schema.AggregateShardPayload = t.strictInterface({
	Version = t.number,
	UpdatedAt = t.number,
	Counts = Schema.CountsByMediaLikeKey
})
Schema.MemberShardPayload = t.strictInterface({
	Version = t.number,
	UpdatedAt = t.number,
	MembersByMediaLikeKey = t.optional(Schema.MembersByMediaLikeKey),
	MemberBucketsByMediaLikeKey = t.optional(Schema.MemberBucketsByMediaLikeKey),
	MemberCountsByMediaLikeKey = t.optional(Schema.MemberCountsByMediaLikeKey),
	OldestMemberBucketByMediaLikeKey = t.optional(Schema.OldestMemberBucketByMediaLikeKey)
})
return Schema