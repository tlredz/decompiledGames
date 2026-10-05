local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "ConsoleOffset"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._originalPosition = self.Instance.Position
	local consoleOffset = GuiService:IsTenFootInterface() and self.Instance:GetAttribute("ConsoleOffset")

	if consoleOffset then
		self.Instance.Position = self._originalPosition + consoleOffset
	end
end

function v:Stop()
	self.Instance.Position = self._originalPosition
	self._Janitor:Destroy()
end

return v