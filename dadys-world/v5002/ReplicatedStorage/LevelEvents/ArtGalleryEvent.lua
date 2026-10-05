game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local _ = {
	ScrapsArtRoom = {
		{
			character = "Scraps",
			dialogue = "Ugh! -I miss doing craft time here!"
		},
		{
			character = "Goob",
			dialogue = "Wowie! The paint I spilled is still here!"
		}
	},
	TishaPainting = {
		{
			character = "Tisha",
			dialogue = "…Wow."
		},
		{
			character = "Brusha",
			dialogue = "The last art piece I decided to display here- A shame."
		}
	}
}
local ArtGalleryEvent = {}
ArtGalleryEvent.properties = {
	HasDialogueTriggers = true,
	UsesStoryKey = true,
	DefaultTriggerDuration = 3
}

function ArtGalleryEvent.onRoomLoad(_, _) end

function ArtGalleryEvent.setupBehaviors(_, _) end

return ArtGalleryEvent