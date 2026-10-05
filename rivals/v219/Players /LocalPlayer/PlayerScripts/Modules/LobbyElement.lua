local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Modules.Signal)
local LobbyElement = {}
LobbyElement.__index = LobbyElement

function LobbyElement.new()
	local self = setmetatable({}, LobbyElement)
	self.EnabledChanged = Signal.new()
	self.IsEnabled = false
	self._original_pivots = {}
	self:_Init()
	return self
end

function LobbyElement:SetEnabled(isEnabled)
	if isEnabled == self.IsEnabled then
		return
	end

	self.IsEnabled = isEnabled
	self.EnabledChanged:Fire(self.IsEnabled)
end

function LobbyElement.Update(_, _) end

function LobbyElement:_GetOriginalPivot(instance)
	self._original_pivots[instance] = self._original_pivots[instance] or instance:GetPivot()
	return self._original_pivots[instance]
end

function LobbyElement:_Init() end

return LobbyElement