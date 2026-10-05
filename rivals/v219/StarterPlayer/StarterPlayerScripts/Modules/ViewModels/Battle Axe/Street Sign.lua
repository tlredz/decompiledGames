local Players = game:GetService("Players")
local BattleAxe = require(Players.LocalPlayer.PlayerScripts.Modules.ViewModels["Battle Axe"])
local object = setmetatable({}, BattleAxe)
object.__index = object

function object.new(...)
	local self = setmetatable(BattleAxe.new(...), object)
	self:_Init()
	return self
end

function object:_Setup()
	local v = math.random(1, 3)

	for i = 1, 3 do
		if i == v then
			continue
		end

		local v2 = self.ItemModel.Body["Sign" .. i]
		task.defer(v2.Destroy, v2)
	end
end

function object:_Init()
	self:_Setup()
end

return object