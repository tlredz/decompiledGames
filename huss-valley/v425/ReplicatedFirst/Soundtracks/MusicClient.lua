local parent = script.Parent
local MusicController = require(parent.MusicController)
local v = MusicController.new(parent.JoiningGameMusic, require(parent.MusicConfig))
script.Destroying:Connect(function()
	v:destroy()
end)