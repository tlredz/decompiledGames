local Players = game:GetService("Players")
local Gun = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Gun)
local object = setmetatable({}, Gun)
object.__index = object

function object.new(...)
	local self = setmetatable(Gun.new(...), object)
	self:_Init()
	return self
end

function object:_Init()
	function self._on_reload_callback()
		local _reload_hash = self._reload_hash
		task.delay(0.5, function()
			if _reload_hash ~= self._reload_hash then
				return
			end

			self.ViewModel:PlayReloadParticles()
		end)
	end
end

return object