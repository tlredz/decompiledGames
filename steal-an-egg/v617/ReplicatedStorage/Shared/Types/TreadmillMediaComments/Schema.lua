local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local Schema = {
	MediaKey = t.string,
	CommentId = t.string
}
Schema.ClientCommentRecord = t.strictInterface({
	Id = Schema.CommentId,
	UserId = t.number,
	CreatedAt = t.number,
	Message = t.string,
	ImageAssetId = t.optional(t.number),
	LikeCount = t.number,
	LikedByViewer = t.boolean
})
Schema.PersistedCommentRecord = t.strictInterface({
	I = Schema.CommentId,
	U = t.number,
	T = t.number,
	M = t.string,
	A = t.optional(t.number),
	L = t.number
})
Schema.PersistedCommentPayload = t.strictInterface({
	V = t.number,
	U = t.number,
	N = t.number,
	C = t.array(Schema.PersistedCommentRecord)
})
Schema.CommentCountPayload = t.strictInterface({
	V = t.number,
	U = t.number,
	C = t.map(Schema.MediaKey, t.number)
})
Schema.CommentCountEnvelope = t.interface({
	V = t.number,
	U = t.number,
	C = t.table
})
Schema.CommentPageRequest = t.strictInterface({
	MediaKey = Schema.MediaKey,
	Cursor = t.optional(t.number),
	PageSize = t.optional(t.number)
})
Schema.CommentPageResult = t.strictInterface({
	Ok = t.boolean,
	TotalCreatedCount = t.optional(t.number),
	Comments = t.optional(t.array(Schema.ClientCommentRecord)),
	NextCursor = t.optional(t.number),
	Error = t.optional(t.string)
})
Schema.CommentCountsRequest = t.strictInterface({
	MediaKeys = t.array(Schema.MediaKey)
})
Schema.CommentCountsResult = t.strictInterface({
	Ok = t.boolean,
	CountsByMediaKey = t.optional(t.map(Schema.MediaKey, t.number)),
	Loaded = t.optional(t.boolean),
	Stale = t.optional(t.boolean),
	Error = t.optional(t.string)
})
Schema.PostCommentRequest = t.strictInterface({
	MediaKey = Schema.MediaKey,
	Message = t.optional(t.string),
	ImageAssetId = t.optional(t.number)
})
Schema.PostCommentResult = t.strictInterface({
	Ok = t.boolean,
	Comment = t.optional(Schema.ClientCommentRecord),
	Pending = t.optional(t.boolean),
	Error = t.optional(t.string)
})
Schema.SetCommentLikeRequest = t.strictInterface({
	MediaKey = Schema.MediaKey,
	CommentId = Schema.CommentId,
	Liked = t.boolean
})
Schema.SetCommentLikeResult = t.strictInterface({
	Ok = t.boolean,
	CommentId = t.optional(Schema.CommentId),
	LikeCount = t.optional(t.number),
	Liked = t.optional(t.boolean),
	Delta = t.optional(t.number),
	Error = t.optional(t.string)
})
return Schema