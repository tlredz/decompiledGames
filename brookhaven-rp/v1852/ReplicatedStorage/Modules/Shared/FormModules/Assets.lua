local ContentProvider = game:GetService("ContentProvider")
task.spawn(function()
	ContentProvider:PreloadAsync({
		"http://www.roblox.com/asset/?id=6031068421",
		"http://www.roblox.com/asset/?id=6031068420",
		"http://www.roblox.com/asset/?id=6031068426",
		"http://www.roblox.com/asset/?id=6031068433"
	})
end)
return {
	Checkbox = {
		Checked = "http://www.roblox.com/asset/?id=6031068421",
		Unchecked = "http://www.roblox.com/asset/?id=6031068420"
	},
	RadioButton = {
		Checked = "http://www.roblox.com/asset/?id=6031068426",
		Unchecked = "http://www.roblox.com/asset/?id=6031068433"
	}
}