local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local OnlyRunLocalPlayer = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunLocalPlayer)
local Input = require(ReplicatedStorage.Packages.Input)
local BulletsController = require(ReplicatedStorage.Modules.Client.Bullets.BulletsController)
local GunHitReceiver = require(ReplicatedStorage.Modules.Shared.Components.Triggers.GunHitReceiver)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local LinearAnimationSequence = require(ReplicatedStorage.Modules.Client.Components.Tools.Animation.LinearAnimationSequence)
local WeaponUI = require(ReplicatedStorage.Modules.Client.Components.Tools.UI.WeaponUI)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local mouse = Input.Mouse
local gamepad = Input.Gamepad
local touch = Input.Touch
local localPlayer = Players.LocalPlayer
local random = Random.new()
local v = Component.new({
	Tag = "GunTool",
	Extensions = { OnlyRunOnPlayerHotbar, OnlyRunLocalPlayer }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._equippedJanitor = self._Janitor:AddObject(Janitor, "Destroy")
	self._maxAmmo = self.Instance:GetAttribute("Ammo") or 10
	self._fireRate = self.Instance:GetAttribute("FireRate") or 0.1
	self._scopeAnimIndex = self.Instance:GetAttribute("ScopeAnimIndex")
	self._pierceAmount = self.Instance:GetAttribute("PierceAmount") or 0
	self._spreadAmount = self.Instance:GetAttribute("SpreadAmount") or 0
	self._spreadReduction = self.Instance:GetAttribute("SpreadReduction") or 1
	self._clipInReloadSpeed = self.Instance:GetAttribute("ClipInReloadSpeed") or 0.5
	self._reloadSpeed = self.Instance:GetAttribute("ReloadSpeed") or 3
	self._fullAuto = self.Instance:GetAttribute("FullAuto") or false
	self._ammo = self._maxAmmo
	self._lastFireTime = 0
	self._handle = self.Instance:WaitForChild("Handle")
	self._barrelAttachment = self._handle:WaitForChild("Barrel")
	self._silencerAttachment = self._handle:WaitForChild("SilencedBarrel")
	self._isAiming = false
	self._reloading = false
	self._equipped = false
	self._mouse = self._Janitor:Add(mouse.new())
	self._touch = self._Janitor:Add(touch.new())
	self._gamepad = self._Janitor:Add(gamepad.new())
	self._mouseDown = false
	self._raycastParams = RaycastParams.new()
	self._raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	self._animations = {}
end

function v:Start()
	self._Janitor:Add(self.Instance.Equipped:Connect(function()
		self:Equipped()
	end))
	self._Janitor:Add(self.Instance.Unequipped:Connect(function()
		self:Unequipped()
	end))
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		self:FireRequested()
	end))
	self._Janitor:Add(self._mouse.LeftDown:Connect(function()
		self._mouseDown = true
	end))
	self._Janitor:Add(self._mouse.LeftUp:Connect(function()
		self._mouseDown = false
	end))
	self._Janitor:AddPromise(WeaponUI:WaitForInstance(self.Instance:WaitForChild("ToolGui")):andThen(function(weaponUI)
		self._weaponUI = weaponUI
		self._Janitor:Add(weaponUI.MobileFired:Connect(function()
			self:FireRequested()
		end))
	end))
	self:SetupScope()
end

function v:SetupAnimations()
	local gunAnimations = self.Instance:FindFirstChild("GunAnimations")

	if not gunAnimations then
		warn("GunTool:SetupAnimations() - Animations folder not found")
	end

	local humanoid = self.Instance.Parent:FindFirstChild("Humanoid")

	if not humanoid then
		warn("GunTool:SetupAnimations() - Humanoid not found")
		return
	end

	local animator = humanoid:FindFirstChild("Animator")

	if not animator then
		warn("GunTool:SetupAnimations() - Animator not found")
		return
	end

	for _, animation in gunAnimations:GetChildren() do
		if not animation:IsA("Animation") then
			continue
		end

		local v2 = self._equippedJanitor:Add(animator:LoadAnimation(animation))
		self._animations[animation.Name] = v2
	end
end

function v:Equipped()
	self:SetupAnimations()

	if self._scopeUI then
		self._scopeUI.Parent = localPlayer.PlayerGui
	end

	self._equipped = true
end

function v:Unequipped()
	for _, _animation in self._animations do
		_animation:Stop()
	end

	self._equippedJanitor:Cleanup()
	self:DeactivateScope()

	if self._scopeUI then
		self._scopeUI.Parent = self.Instance
	end

	self._equipped = false
	PanelController.Close("NoResetGUIHandler", "GunWeaponMenu")
end

function v:RenderSteppedUpdate()
	if not (self._fullAuto and self._equipped) then
		return
	end

	local v2 = self._gamepad:IsConnected() and self._gamepad:IsButtonDown(Enum.KeyCode.ButtonR2)
	local isMobileFireDown = self._weaponUI:IsMobileFireDown()

	if self._mouseDown or v2 or isMobileFireDown then
		self:FireRequested()
	end
end

function v:FireRequested()
	if self._reloading then
		return
	end

	local now = os.clock()

	if 1 / self._fireRate > now - self._lastFireTime then
		return
	end

	self._lastFireTime = now
	self._ammo -= 1
	self:GenerateBullet()

	if self._ammo <= 0 then
		self:Reload()
	end
end

function v:Reload()
	self._reloading = true
	local reloadSpeedMultiplier = self.Instance:GetAttribute("ReloadSpeedMultiplier") or 1
	local clipInReloadSpeedMultiplier = self.Instance:GetAttribute("ClipInReloadSpeedMultiplier") or 1

	if self.Instance:GetAttribute("ReloadBulletsAmount") then
		for _ = 1, self.Instance:GetAttribute("ReloadBulletsAmount") do
			if self._equipped then
				BulletsController.PlaySound(self._handle:FindFirstChild("ClipInReload"))
				Remotes.fireServer("GunPlaySound", "ClipInReload")
				self._animations.Reload:Play(nil, nil, 0.5 / clipInReloadSpeedMultiplier)
			end

			task.wait(self._clipInReloadSpeed)
		end

		BulletsController.PlaySound(self._handle:FindFirstChild("Reload"))
		Remotes.fireServer("GunPlaySound", "Reload")
	else
		if self._equipped then
			BulletsController.PlaySound(self._handle:FindFirstChild("Reload"))
			Remotes.fireServer("GunPlaySound", "Reload")
			self._animations.Reload:Play(nil, nil, 0.5 / reloadSpeedMultiplier)
		end

		task.wait(self._reloadSpeed * reloadSpeedMultiplier)
	end

	self._ammo = self._maxAmmo
	self._reloading = false
end

function v:GenerateBullet()
	local character = localPlayer.Character

	if not character then
		warn("GunTool:GenerateBullet() - Character not found")
		return
	end

	self._raycastParams.FilterDescendantsInstances = { character }
	local _pierceAmount = self._pierceAmount
	local raycastResult = self._mouse:Raycast(self._raycastParams, 1000)
	local position

	if raycastResult then
		position = raycastResult.Position
	else
		position = self._mouse:Project(1000)
	end

	local worldPosition = self._barrelAttachment.WorldPosition
	local v2 = self._spreadAmount * (not self._isAiming and 1 or 1 - self._spreadReduction or 1)
	local cframe = CFrame.Angles(math.rad((random:NextNumber(-v2, v2))), math.rad((random:NextNumber(-v2, v2))), 0)
	local lookVector = (CFrame.new(worldPosition, position) * cframe).LookVector

	while _pierceAmount >= 0 do
		local raycastResult2 = workspace:Raycast(worldPosition, lookVector * 1000, self._raycastParams)
		_pierceAmount = raycastResult2 and _pierceAmount - 1 or -1

		if raycastResult2 then
			position = raycastResult2.Position or position
		end

		local instance

		if raycastResult2 then
			instance = raycastResult2.Instance or nil
		end

		BulletsController.VisualizeBullet(position, instance, self.Instance)
		Remotes.fireServer("GunPlaySound", "Shoot")
		Remotes.fireServer("Bullet", position, instance)

		if not (raycastResult2 and raycastResult2.Instance:HasTag("GunHitReceiver")) then
			continue
		end

		local v3 = GunHitReceiver:FromInstance(raycastResult2.Instance)

		if v3 then
			GunHitReceiver.OnPlayerShot(v3, localPlayer, position)
		end
	end
end

function v:ActivateScope()
	if self._isAiming then
		return
	end

	self._isAiming = true
	localPlayer.CameraMode = Enum.CameraMode.LockFirstPerson

	if self._scopeUI then
		self._scopeUI.Enabled = true
	end

	task.wait(0.25)
	workspace.CurrentCamera.FieldOfView = 10
end

function v:DeactivateScope()
	if not self._isAiming then
		return
	end

	task.wait(0.5)

	if self._scopeUI then
		self._scopeUI.Enabled = false
	end

	localPlayer.CameraMode = Enum.CameraMode.Classic
	localPlayer.CameraMinZoomDistance = 10
	localPlayer.CameraMaxZoomDistance = 10
	localPlayer.CameraMinZoomDistance = 0.5
	localPlayer.CameraMaxZoomDistance = 128
	workspace.CurrentCamera.FieldOfView = 70
	self._isAiming = false
end

function v:SetupScope()
	if not self._scopeAnimIndex then
		return
	end

	local component = self:GetComponent(LinearAnimationSequence)
	self._Janitor:Add(component.OnAnimationNumberUpdated:Connect(function(p: number)
		if p == self._scopeAnimIndex then
			self:ActivateScope()
		else
			self:DeactivateScope()
		end
	end))
	local scope = self.Instance:FindFirstChild("Scope")

	if not scope then
		return
	end

	self._scopeUI = scope
end

function v:Stop()
	self._Janitor:Destroy()
end

return v