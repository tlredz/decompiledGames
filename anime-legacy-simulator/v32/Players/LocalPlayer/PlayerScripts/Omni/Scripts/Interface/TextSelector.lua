local module = require("@game/ReplicatedStorage/Omni")
local textSelector = module.Interface:WaitForChild("Frames"):WaitForChild("TextSelector")
local main = textSelector:WaitForChild("Main")
local title = main:WaitForChild("Title")
local search = main:WaitForChild("Search")
local buttons = main:WaitForChild("Buttons")
local v = nil
local TextSelector = {
	Start = function(data)
		if v then
			return
		end

		v = {
			Callback = data.Callback,
			MaxLength = data.MaxLength
		}
		title.Text = data.Title
		search.PlaceholderText = data.Placeholder or ""
		search.Text = data.Start or ""
		module.Frame:Open(textSelector)
	end,
	Stop = function()
		v = nil
		module.Frame:Close(textSelector)
	end
}
search:GetPropertyChangedSignal("Text"):Connect(function()
	if not (v and v.MaxLength) or #search.Text <= v.MaxLength then
		return
	end

	search.Text = search.Text:sub(1, v.MaxLength)
end)
module.Button:Create(buttons.Cancel, "Small"):BindFunction("Click", function()
	TextSelector.Stop()
end)
module.Button:Create(buttons.Confirm, "Small"):BindFunction("Click", function()
	if not v then
		return
	end

	local callback = v.Callback
	local text = search.Text
	TextSelector.Stop()
	callback(text)
end)
module.Frame:OnFrameClosed(textSelector, function()
	v = nil
end)
return TextSelector