local parent = script.Parent
local RemoteType = require(parent.RemoteType)
local ResponseType = require(parent.ResponseType)
return {
	FormId = "1FAIpQLSdEa533Vc6N0G-jUEWR3OonXkJ4-u6mnuQ9VAxl3aCS_8CxRQ",
	CacheForm = false,
	FilterText = false,
	DisableTouchInputs = true,
	AllowMultipleResponses = true,
	DataStoreName = "FormResponses",
	Icon = "http://www.roblox.com/asset/?id=6023426957",
	Notifications = {
		[ResponseType.Success] = {
			Icon = "http://www.roblox.com/asset/?id=6023426957",
			Title = "Form Submitted",
			Text = "Thank you 💖 Your feedback is appreciated!",
			Duration = 5
		},
		[ResponseType.Error] = {
			Icon = "http://www.roblox.com/asset/?id=6023426957",
			Title = "Feedback Form Unavailable",
			Text = "Please try again later or contact the developer.",
			Duration = 5
		},
		[ResponseType.RateLimit] = {
			Icon = "http://www.roblox.com/asset/?id=6023426957",
			Title = "Slow Down",
			Text = "Please wait before trying again.",
			Duration = 3
		},
		[ResponseType.NotAllowed] = {
			Icon = "http://www.roblox.com/asset/?id=6023426957",
			Title = "Not Allowed",
			Text = "You have already submitted this form.",
			Duration = 3
		}
	},
	RateLimits = {
		[RemoteType.FetchFormData] = 1,
		[RemoteType.SubmitFormData] = 5,
		[RemoteType.FilterText] = 0.5
	},
	Metadata = {
		Username = "__username__",
		UserId = "__userid__",
		DisplayName = "__displayname__",
		PlaceId = "__placeid__",
		PlaceVersion = "__placeversion__",
		ClientVersion = "__clientversion__",
		Time = "__time__",
		ElapsedTime = "__elapsedtime__",
		GcInfo = "__gcinfo__",
		ServerSize = "__serversize__",
		Device = "__device__",
		Logs = "__logs__"
	}
}