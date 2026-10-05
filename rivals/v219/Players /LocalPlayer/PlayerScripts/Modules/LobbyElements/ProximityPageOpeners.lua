local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local LobbyElement = require(Players.LocalPlayer.PlayerScripts.Modules.LobbyElement)
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)
local object = setmetatable({}, LobbyElement)
object.__index = object

function object._new(...)
	local self = setmetatable(LobbyElement.new(...), object)
	self:_Init()
	return self
end

function object:_PartAdded(instance)
	local pageName = instance:GetAttribute("PageName")
	local v = false
	instance.Touched:Connect(function(otherPart)
		if v or Pages.PageSystem.CurrentPage or not otherPart.AssemblyRootPart or not otherPart.AssemblyRootPart.Parent or Players:GetPlayerFromCharacter(otherPart.AssemblyRootPart.Parent) ~= Players.LocalPlayer then
			return
		end

		v = true
		Pages.PageSystem:OpenPage(pageName, true)

		while otherPart:IsDescendantOf(workspace) and Utility:IsWithinPart(
			instance,
			otherPart.Position,
			createVector(1, 1, 1) * math.max(otherPart.Size.X, otherPart.Size.Y, otherPart.Size.Z) * 5
		) do
			wait(0.1)
		end

		v = false

		if Pages.PageSystem.CurrentPage and Pages.PageSystem.CurrentPage.Name == pageName then
			Pages.PageSystem:CloseCurrentPage()
		end
	end)
end

function object:_Init()
	CollectionService:GetInstanceAddedSignal("ProximityPageOpener"):Connect(function(p)
		self:_PartAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("ProximityPageOpener")) do
		task.defer(self._PartAdded, self, v)
	end
end

return object._new()