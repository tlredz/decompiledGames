return {
	Roles = {
		Name = {
			property = "Text",
			candidates = {
				"CharacterName",
				"DisplayName",
				"Title",
				"NameLabel",
				"StatLabel"
			}
		},
		Description = {
			property = "Text",
			candidates = { "Description", "Desc", "Label" }
		},
		Value = {
			property = "Text",
			candidates = { "Value", "Amount", "StatValue" }
		},
		Image = {
			property = "Image",
			candidates = {
				"CharacterImage",
				"ItemImage",
				"Render",
				"Icon",
				"ImageLabel"
			},
			descend = true
		},
		Shadow = {
			property = "Image",
			candidates = { "ImageShadow", "ProgressShadow" }
		},
		Button = {
			property = nil,
			candidates = { "Button", "TextButton", "ImageButton" }
		}
	},
	RoleOrder = {
		"Name",
		"Description",
		"Value",
		"Image",
		"Shadow",
		"Button"
	},
	OptionalRoles = {
		Description = true,
		Value = true,
		Shadow = true,
		Button = true
	}
}