local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "Minions2026_BananaPeel",
	Extensions = { OnlyRunOnPlayerHotbar }
})

local function getNumberAttribute(instance, attributeName: string, p: number)
	local attribute = instance:GetAttribute(attributeName)

	if typeof(attribute) == "number" then
		return attribute
	end

	return p
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = Janitor.new()
	self._Janitor:Add(self._equipJanitor)
	self._lastPlaceClock = 0
end

function v:_IsLocallyOwned()
	local parent = self.Instance.Parent
	return parent ~= nil and Players:GetPlayerFromCharacter(parent) == Players.LocalPlayer
end

function v:_TryPlaceBananaPeel()
	local now = os.clock()

	if now - self._lastPlaceClock < 0.25 then
		return
	end

	local character = Players.LocalPlayer.Character

	if character == nil then
		return
	end

	local maxPlaceDistance = self.Instance:GetAttribute("MaxPlaceDistance")
	local v2 = typeof(maxPlaceDistance) ~= "number" and 35 or maxPlaceDistance
	local mouse = Players.LocalPlayer:GetMouse()
	local characters = { self.Instance, character }

	for _, v3 in Players:GetPlayers() do
		local character2 = v3.Character

		if character2 ~= nil and character2 ~= character then
			table.insert(characters, character2)
		end
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = characters
	raycastParams.RespectCanCollide = true
	local origin = mouse.UnitRay.Origin
	local v3 = mouse.UnitRay.Direction * (v2 + 5)
	local raycastResult = workspace:Raycast(origin, v3, raycastParams)

	if raycastResult == nil then
		return
	end

	self._lastPlaceClock = now
	Remotes.fireServerComponent(self.Instance, "PlaceBananaPeel", raycastResult.Position)
end

function v:_OnEquipped()
	self._equipJanitor:Cleanup()

	if not self:_IsLocallyOwned() then
		return
	end

	self._equipJanitor:Add(self.Instance.Activated:Connect(function()
		self:_TryPlaceBananaPeel()
	end))
end

function v:_OnUnequipped()
	self._equipJanitor:Cleanup()
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(instance.Equipped:Connect(function()
		self:_OnEquipped()
	end))
	self._Janitor:Add(instance.Unequipped:Connect(function()
		self:_OnUnequipped()
	end))

	if instance.Parent ~= nil and Players:GetPlayerFromCharacter(instance.Parent) == Players.LocalPlayer then
		self:_OnEquipped()
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v