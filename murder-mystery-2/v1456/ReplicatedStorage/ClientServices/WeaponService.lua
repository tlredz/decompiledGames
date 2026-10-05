local WeaponService = {}
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
WeaponService.KnifeThrown = Instance.new("BindableEvent")
WeaponService.GunFired = script:WaitForChild("GunFired")

function WeaponService.ThrowKnife(_)
	WeaponService.KnifeThrown:Fire()
end

local function GetWeaponIgnoreList()
	local result = { game.Players.LocalPlayer.Character }

	for _, v in CollectionService:GetTagged("WeaponPassthrough") do
		table.insert(result, v)
	end

	return result
end

local function WeaponRaycast(ray: Ray)
	local raycastParams = RaycastParams.new()
	local instances = GetWeaponIgnoreList()
	raycastParams.FilterDescendantsInstances = instances
	local raycastResult

	while true do
		raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)

		if not raycastResult then
			break
		end

		local instance = raycastResult.Instance

		if not instance or instance.Transparency ~= 1 then
			break
		end

		table.insert(instances, instance)
		raycastParams.FilterDescendantsInstances = instances
	end

	return raycastResult
end

function WeaponService.IsMouseLockEnabled(_)
	local mouseLock = game.Players.LocalPlayer.PlayerScripts:FindFirstChild("MouseLock")

	if mouseLock then
		return mouseLock:GetAttribute("Enabled") == true
	end

	return false
end

function WeaponService.GetTargetPosition(_, p, p2)
	local _ = game.Players.LocalPlayer
	local viewportPointToRay = workspace.CurrentCamera:ViewportPointToRay(p, p2)
	local ray = Ray.new(viewportPointToRay.Origin, viewportPointToRay.Direction * 300)
	local weaponRaycast = WeaponRaycast(ray)

	if weaponRaycast and weaponRaycast.Position then
		return (CFrame.new(weaponRaycast.Position))
	end

	return (CFrame.new(ray.Origin + ray.Direction))
end

function WeaponService.GetMouseTargetCFrame(_)
	local localPlayer = game.Players.LocalPlayer
	local mouseLocation = UserInputService:GetMouseLocation()
	local X = mouseLocation.X
	local Y = mouseLocation.Y
	local mouseLock = localPlayer.PlayerScripts:FindFirstChild("MouseLock")

	if mouseLock and mouseLock:GetAttribute("Enabled") == true and UserInputService.PreferredInput ~= Enum.PreferredInput.Gamepad then
		local viewportSize = workspace.CurrentCamera.ViewportSize
		X = viewportSize.X / 2
		Y = viewportSize.Y / 2
	end

	local viewportPointToRay = workspace.CurrentCamera:ViewportPointToRay(X, Y)
	local ray = Ray.new(viewportPointToRay.Origin, viewportPointToRay.Direction * 300)
	local weaponRaycast = WeaponRaycast(ray)

	if weaponRaycast and weaponRaycast.Position then
		return (CFrame.new(weaponRaycast.Position))
	end

	return (CFrame.new(ray.Origin + ray.Direction))
end

return WeaponService