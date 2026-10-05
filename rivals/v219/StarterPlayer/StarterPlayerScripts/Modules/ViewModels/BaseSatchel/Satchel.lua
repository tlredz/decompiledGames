local Players = game:GetService("Players")
local BaseSatchel = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseSatchel)
local object = setmetatable({}, BaseSatchel)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseSatchel.new(...), object)
	self:_Init()
	return self
end

function object:_Init()
	task.defer(function()
		self.ClientItem.ProjectileThrown:Connect(function(_, instance)
			self:_PlayBeepAnimation(instance:WaitForChild("Beep"))
		end)
	end)
	self:_RegisterBeepPart(self.ItemModel:WaitForChild("Body"):WaitForChild("Beep"))
end

return object