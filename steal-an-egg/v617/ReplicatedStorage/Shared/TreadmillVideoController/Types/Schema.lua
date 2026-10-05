local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SchemaFields = require(ReplicatedStorage.Shared.Modules.ProfileDefaults.Types.SchemaFields)
local t = require(ReplicatedStorage.Packages.t)
local Schema = {
	TreadmillMediaBucketType = t.union(
		t.literal("Brainrot"),
		t.literal("Funny"),
		t.literal("Satisfying"),
		t.literal("WeirdOrHorror"),
		t.literal("Music")
	),
	VideoBackgroundMusic = t.strictInterface({
		SoundId = t.string,
		Volume = t.number
	})
}
Schema.VideoMediaEntry = t.strictInterface({
	Kind = t.literal("Video"),
	ReleaseVersion = t.number,
	BucketType = Schema.TreadmillMediaBucketType,
	Video = t.string,
	CoverImage = t.optional(t.string),
	Music = t.optional(Schema.VideoBackgroundMusic),
	Size = t.optional(t.UDim2),
	Volume = t.optional(t.number),
	Duration = t.optional(t.number),
	Disabled = t.optional(t.boolean)
})
Schema.MusicImageMediaEntry = t.strictInterface({
	Kind = t.literal("MusicImage"),
	ReleaseVersion = t.number,
	BucketType = Schema.TreadmillMediaBucketType,
	Image = t.string,
	SoundId = t.string,
	Volume = t.number,
	Duration = t.optional(t.number),
	Disabled = t.optional(t.boolean)
})
Schema.TreadmillMediaEntry = t.union(Schema.VideoMediaEntry, Schema.MusicImageMediaEntry)
Schema.TreadmillMediaEntries = t.array(Schema.TreadmillMediaEntry)
Schema.TreadmillMediaFeedState = SchemaFields.TreadmillMediaFeedState
return Schema