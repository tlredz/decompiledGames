local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "MouseAlternateText"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(p)
	local mouseAlternateText_Text = p.Instance:GetAttribute("MouseAlternateText_Text")
	assert(typeof(mouseAlternateText_Text) == "string")

	if UserInputService.MouseEnabled then
		p.Instance.Text = mouseAlternateText_Text
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v