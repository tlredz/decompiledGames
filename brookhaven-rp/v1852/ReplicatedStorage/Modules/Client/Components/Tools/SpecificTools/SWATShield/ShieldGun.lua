local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local OnlyRunInCharacter = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunInCharacter)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "ShieldGun",
	Extensions = { OnlyRunInCharacter }
})
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function getMouseHit(worldPosition: Vector3)
	local mouseLocation = UserInputService:GetMouseLocation()
	local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	raycastParams.FilterDescendantsInstances = { localPlayer.Character }
	local raycastResult = workspace:Raycast(
		viewportPointToRay.Origin,
		viewportPointToRay.Direction * 500,
		raycastParams
	)
	local unit = ((raycastResult and raycastResult.Position or viewportPointToRay.Origin + viewportPointToRay.Direction * 500) - worldPosition).Unit
	local raycastResult2 = workspace:Raycast(worldPosition, unit * 40, raycastParams)

	if raycastResult2 then
		return raycastResult2.Position, raycastResult2
	end

	return worldPosition + unit * 40, nil
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._muzzle = self.Instance:WaitForChild("Attachment")
end

function v:Shoot()
	local mouseHit, v2 = getMouseHit(self._muzzle.WorldPosition)
	Remotes.fireServerComponent(self.Instance, "GunShoot", v2 and mouseHit)
end

function v.Start(_) end

function v:Stop()
	self._Janitor:Destroy()
end

return v