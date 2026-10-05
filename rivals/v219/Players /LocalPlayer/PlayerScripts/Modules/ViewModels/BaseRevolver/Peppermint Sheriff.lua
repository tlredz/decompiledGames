local Players = game:GetService("Players")
local BaseRevolver = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels.BaseRevolver)
local object = setmetatable({}, BaseRevolver)
object.__index = object

function object.new(...)
	local self = setmetatable(BaseRevolver.new(...), object)
	self:_Init()
	return self
end

function object:_Setup()
	for _, childName in pairs({ "ReloadBullets", "Bullets" }) do
		local child = self.ItemModel:WaitForChild(childName)

		for i = 1, 6 do
			local child2 = child:WaitForChild(i)
			self:_RegisterAmmoVisual(childName, child2:WaitForChild("Red"))
			self:_RegisterAmmoVisual(childName, child2:WaitForChild("White"))
		end
	end
end

function object:_Init()
	self:_Setup()
end

return object