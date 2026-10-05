local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local FlareConstants = require(ReplicatedStorage.Modules.Client.Components.Tools.SpecificTools.Flare.FlareConstants)
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local raycastParams = RaycastParams.new()
raycastParams.RespectCanCollide = true

local function getMouseHit(position: Vector3)
	local mouseLocation = UserInputService:GetMouseLocation()
	local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	raycastParams.FilterDescendantsInstances = { localPlayer.Character }
	local raycastResult = workspace:Raycast(
		viewportPointToRay.Origin,
		viewportPointToRay.Direction * 500,
		raycastParams
	)
	local v = (raycastResult and raycastResult.Position or viewportPointToRay.Origin + viewportPointToRay.Direction * 500) - position
	local unit

	if v.Magnitude > 0.001 then
		unit = v.Unit
	else
		unit = viewportPointToRay.Direction
	end

	local raycastResult2 = workspace:Raycast(position, unit * FlareConstants.THROW_RANGE, raycastParams)

	if raycastResult2 then
		return raycastResult2.Position, unit
	end

	return nil, unit
end

local v = Component.new({
	Tag = "Flare",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = self._Janitor:Add(Janitor.new())
	self._isEquipped = false
	self._handle = self.Instance:WaitForChild("Handle")
end

function v:_onEquipped()
	if self._isEquipped then
		return
	end

	local parent = self.Instance.Parent

	if localPlayer.Character ~= parent then
		return
	end

	self._isEquipped = true
	self._equipJanitor:Add(self.Instance.Activated:Connect(function()
		local mouseHit, v2 = getMouseHit(self._handle.Position)
		Remotes.fireServerComponent(self.Instance, "Throw", mouseHit, v2)
	end))
end

function v:_onUnequipped()
	self._isEquipped = false
	self._equipJanitor:Cleanup()
end

function v:Start()
	self._Janitor:Add(self.Instance.Equipped:Connect(function()
		self:_onEquipped()
	end))
	self._Janitor:Add(self.Instance.Unequipped:Connect(function()
		self:_onUnequipped()
	end))

	if localPlayer.Character and self.Instance.Parent == localPlayer.Character then
		self:_onEquipped()
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v