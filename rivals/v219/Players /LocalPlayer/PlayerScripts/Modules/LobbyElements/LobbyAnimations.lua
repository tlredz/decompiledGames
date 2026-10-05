local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local LobbyElement = require(Players.LocalPlayer.PlayerScripts.Modules.LobbyElement)
local object = setmetatable({}, LobbyElement)
object.__index = object

function object._new(...)
	local self = setmetatable(LobbyElement.new(...), object)
	self:_Init()
	return self
end

function object:_ObjectAdded(instance)
	while true do
		local animation = Instance.new("Animation")
		animation.AnimationId = instance:GetAttribute("IdleAnimation")
		local success, result = pcall(instance.LoadAnimation, instance, animation)

		if success and pcall(result.Play, result) then
			break
		end

		wait(1)
	end
end

function object:_Init()
	CollectionService:GetInstanceAddedSignal("LobbyAnimation"):Connect(function(p)
		self:_ObjectAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("LobbyAnimation")) do
		task.defer(self._ObjectAdded, self, v)
	end
end

return object._new()