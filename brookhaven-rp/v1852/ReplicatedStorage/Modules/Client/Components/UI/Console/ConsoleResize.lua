local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "ConsoleResize"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._originalSize = self.Instance.Size
	local consoleSize = GuiService:IsTenFootInterface() and self.Instance:GetAttribute("ConsoleSize")

	if consoleSize then
		self.Instance.Size = consoleSize
	end
end

function v:Stop()
	self.Instance.Size = self._originalSize
	self._Janitor:Destroy()
end

return v