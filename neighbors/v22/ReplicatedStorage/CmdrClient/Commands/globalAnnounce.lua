return {
	Name = "globalannouncement",
	Description = "Posts a global announcement across all servers that lasts for 10 minutes",
	Group = "StudioDeveloper",
	Args = {
		{
			Type = "string",
			Name = "Announcement",
			Description = "Announcement to post"
		}
	}
}