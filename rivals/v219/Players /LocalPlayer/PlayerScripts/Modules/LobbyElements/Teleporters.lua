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

function object:_ModelAdded(instance)
	local from = instance:WaitForChild("From")
	local to = instance:WaitForChild("To")
	local v = 0
	from.Touched:Connect(function(otherPart)
		local now = tick()

		if v < now and otherPart and otherPart.AssemblyRootPart and otherPart.AssemblyRootPart.Parent and Players:GetPlayerFromCharacter(otherPart.AssemblyRootPart.Parent) == Players.LocalPlayer then
			v = tick() + 1
			otherPart.AssemblyRootPart.Parent.HumanoidRootPart.CFrame = CFrame.new(to.Position) * otherPart.AssemblyRootPart.Parent.HumanoidRootPart.CFrame.Rotation
		end
	end)
end

function object:_Init()
	CollectionService:GetInstanceAddedSignal("LobbyTeleporter"):Connect(function(p)
		self:_ModelAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("LobbyTeleporter")) do
		task.defer(self._ModelAdded, self, v)
	end
end

return object._new()