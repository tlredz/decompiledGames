local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local TaserConstants = require(ReplicatedStorage.Modules.Client.Components.Tools.SpecificTools.Taser.TaserConstants)
local v = Component.new({
	Tag = "Taser",
	Extensions = { OnlyRunOnPlayerHotbar }
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
	local raycastResult2 = workspace:Raycast(worldPosition, unit * TaserConstants.TAP_RANGE, raycastParams)

	if raycastResult2 then
		return raycastResult2.Position, raycastResult2
	end

	return worldPosition + unit * TaserConstants.TAP_RANGE, nil
end

local function createTaserBeam(worldPosition: Vector3, vector: Vector3, value: number?, value2: number?, value3: number?)
	local v2 = value or 6
	local v3 = value2 or 1.5
	local folder = Instance.new("Folder")
	folder.Name = "TempTaserBeam"
	folder.Parent = workspace

	if (vector - worldPosition).Magnitude < 0.01 then
		return folder
	end

	local unit = (vector - worldPosition).Unit
	local v5 = (vector - worldPosition).Magnitude / v2
	local v6 = { worldPosition }

	for i = 1, v2 - 1 do
		table.insert(
			v6,
			worldPosition + unit * (v5 * i) + unit:Cross(Vector3.new(
				math.random() - 0.5,
				math.random() - 0.5,
				math.random() - 0.5
			).Unit).Unit * (math.random() * v3 - v3 / 2)
		)
	end

	table.insert(v6, vector)

	for i = 1, #v6 - 1 do
		local v7 = v6[i]
		local v8 = v6[i + 1]
		local magnitude = (v8 - v7).Magnitude
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(255, 170, 0)
		part.Size = Vector3.new(0.15, 0.15, magnitude)
		part.CFrame = CFrame.lookAt((v7 + v8) / 2, v8)
		part.Parent = folder
	end

	Debris:AddItem(folder, value3 or 0.1)
	return folder
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isPressInput(pressInput)
	local userInputType = pressInput.UserInputType

	if userInputType == Enum.UserInputType.Touch then
		return true
	end

	return userInputType == Enum.UserInputType.MouseButton1 or pressInput.KeyCode == Enum.KeyCode.ButtonR2
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = self._Janitor:Add(Janitor.new())
	self._isEquipped = false
	self._isPressing = false
	self._isHolding = false
	self._pressInput = nil
	self._tapDebounce = false
	local handle = self.Instance:WaitForChild("Handle", 5)
	assert(handle, (`Handle not found in Taser: {self.Instance:GetFullName()}`))
	self._muzzle = handle:WaitForChild("Muzzle", 5)
	assert(self._muzzle, (`Muzzle attachment not found in Taser: {self.Instance:GetFullName()}`))
	local holder = handle:WaitForChild("Holder", 5)
	assert(holder, (`Holder not found in Taser: {self.Instance:GetFullName()}`))
	self._boltParticle = holder:WaitForChild("Bolt", 5)
	assert(self._boltParticle, (`Bolt ParticleEmitter not found in Taser: {self.Instance:GetFullName()}`))
	self._holdClickSound = holder:WaitForChild("HoldClickSound", 5)
	assert(self._holdClickSound, (`HoldClickSound not found in Taser: {self.Instance:GetFullName()}`))
	self._tapSound = holder:WaitForChild("TapSound", 5)
	assert(self._tapSound, (`TapSound not found in Taser: {self.Instance:GetFullName()}`))
end

function v:_tapClick(vector: Vector3)
	createTaserBeam(self._muzzle.WorldPosition, vector)
	self._tapSound:Play()
end

function v:_setHoldClickState(enabled: boolean)
	self._boltParticle.Enabled = enabled

	if enabled then
		self._holdClickSound:Play()
	else
		self._holdClickSound:Stop()
	end
end

function v:_beginPress()
	if self._isPressing then
		return
	end

	self._isPressing = true
	task.delay(0.1, function()
		if not (self._isPressing and self._isEquipped) then
			return
		end

		self._isHolding = true
		self:_setHoldClickState(true)
		Remotes.fireServerComponent(self.Instance, "HoldClickStart")
	end)
end

function v:_endPress()
	if not self._isPressing then
		return
	end

	self._isPressing = false

	if self._isHolding then
		self._isHolding = false
		self:_setHoldClickState(false)
		Remotes.fireServerComponent(self.Instance, "HoldClickStop")
	else
		if self._tapDebounce then
			return
		end

		self._tapDebounce = true
		task.delay(TaserConstants.TAP_COOLDOWN, function()
			self._tapDebounce = false
		end)
		local mouseHit = getMouseHit(self._muzzle.WorldPosition)
		self:_tapClick(mouseHit)
		Remotes.fireServerComponent(self.Instance, "TapClick", mouseHit)
	end
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
	self._equipJanitor:Add(UserInputService.InputBegan:Connect(function(pressInput, gameProcessed: boolean)
		if not isPressInput(pressInput) then
			return
		end

		if pressInput.UserInputType == Enum.UserInputType.Touch then
			if self._pressInput ~= nil and self._pressInput.UserInputType == Enum.UserInputType.MouseButton1 then
				self._pressInput = pressInput
				return
			end
		elseif pressInput.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService.PreferredInput == Enum.PreferredInput.Touch then
			return
		end

		if gameProcessed and pressInput.KeyCode ~= Enum.KeyCode.ButtonR2 or self._pressInput ~= nil then
			return
		end

		self._pressInput = pressInput
		self:_beginPress()
	end))

	local function onPressEnded(p)
		if p ~= self._pressInput then
			return
		end

		self._pressInput = nil
		self:_endPress()
	end

	self._equipJanitor:Add(UserInputService.InputEnded:Connect(onPressEnded))
	self._equipJanitor:Add(UserInputService.TouchEnded:Connect(onPressEnded))
end

function v:_onUnequipped()
	local _isHolding = self._isHolding
	self._isEquipped = false
	self._pressInput = nil
	self._isPressing = false
	self._isHolding = false
	self:_setHoldClickState(false)

	if _isHolding then
		Remotes.fireServerComponent(self.Instance, "HoldClickStop")
	end

	self._equipJanitor:Cleanup()
end

function v:Start()
	self._Janitor:Add(self.Instance.Equipped:Connect(function()
		self:_onEquipped()
	end))
	self._Janitor:Add(self.Instance.Unequipped:Connect(function()
		self:_onUnequipped()
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "TapClick", function(p)
		self:_tapClick(p)
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "HoldClickStart", function()
		self:_setHoldClickState(true)
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "HoldClickStop", function()
		self:_setHoldClickState(false)
	end))

	if localPlayer.Character and self.Instance.Parent == localPlayer.Character then
		self:_onEquipped()
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v