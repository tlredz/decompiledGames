local Players = game:GetService("Players")
local Charm = require(Players.LocalPlayer.PlayerScripts.Modules.Charm)
local object = setmetatable({}, Charm)
object.__index = object

function object.new(...)
	local self = setmetatable(Charm.new(...), object)
	self._textlabel = self.Model:WaitForChild("Extra"):WaitForChild("Part"):WaitForChild("SurfaceGui"):WaitForChild("TextLabel")
	self._textlabel2 = self.Model:WaitForChild("Extra"):WaitForChild("Part"):WaitForChild("SurfaceGui2"):WaitForChild("TextLabel")
	self:_Init()
	return self
end

function object:_Setup()
	local text = not (self.EquippedData.Metadata and self.EquippedData.Metadata.BeforeSeason0ELOResetLeaderboardRank) and "" or "RANK #" .. self.EquippedData.Metadata.BeforeSeason0ELOResetLeaderboardRank or ""
	self._textlabel.Text = text
	self._textlabel2.Text = text
end

function object:_Init()
	self:_Setup()
end

return object