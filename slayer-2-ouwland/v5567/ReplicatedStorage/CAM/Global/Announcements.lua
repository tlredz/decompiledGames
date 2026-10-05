return {
	KEY = "Announcements",
	normalize = function(items)
		local result = {}

		if typeof(items) ~= "table" then
			return result
		end

		for _, item in items do
			if not (typeof(item) == "table" and type(item.Title) == "string" and item.Title ~= "" and type(item.Text) == "string") then
				continue
			end

			if item.Text == "" then
				continue
			end

			local v = {
				Title = item.Title,
				Text = item.Text,
				Urgent = item.Urgent == true,
				posted = type(item.posted) ~= "number" and 0 or item.posted,
				expires = type(item.expires) ~= "number" and 0 or item.expires,
				Thumbnail = 0,
				Countdown = 0,
				EventId = 0
			}
			local thumbnail

			if type(item.Thumbnail) == "string" and item.Thumbnail ~= "" then
				thumbnail = item.Thumbnail
			elseif type(item.Thumbnail) == "number" then
				thumbnail = `rbxassetid://{item.Thumbnail}`
			end

			v.Thumbnail = thumbnail
			local countdown

			if type(item.Countdown) == "number" then
				countdown = item.Countdown
			end

			v.Countdown = countdown
			local eventId

			if type(item.EventId) == "string" and item.EventId ~= "" then
				eventId = item.EventId
			elseif type(item.EventId) == "number" then
				eventId = tostring(item.EventId)
			end

			v.EventId = eventId
			table.insert(result, v)
		end

		return result
	end
}