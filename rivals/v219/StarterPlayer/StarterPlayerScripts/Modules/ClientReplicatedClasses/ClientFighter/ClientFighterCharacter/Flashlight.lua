local createVector = vector.create
local Flashlight = {}
Flashlight.__index = Flashlight

function Flashlight.new(clientFighterCharacter)
	local self = setmetatable({}, Flashlight)
	self.ClientFighterCharacter = clientFighterCharacter
	self._destroyed = false
	self._part = nil
	self:_Init()
	return self
end

function Flashlight:Update(_, p2)
	if not self._part then
		return
	end

	local _part = self._part
	local cFrame

	if p2.IsActuallyFirstPerson then
		cFrame = workspace.CurrentCamera.CFrame
	elseif self.ClientFighterCharacter.Head then
		cFrame = self.ClientFighterCharacter.Head.CFrame
	elseif self.ClientFighterCharacter.RootPart then
		cFrame = self.ClientFighterCharacter.RootPart.CFrame
	else
		cFrame = self._part.CFrame
	end

	_part.CFrame = cFrame
end

function Flashlight:Destroy()
	self._destroyed = true

	if self._part then
		self._part:Destroy()
	end
end

function Flashlight:_Verify()
	if self._destroyed or not self.ClientFighterCharacter:IsInWorld() then
		return
	end

	local cameraFlashlightEnabled = self.ClientFighterCharacter:Get("CameraFlashlightEnabled")

	if cameraFlashlightEnabled and not self._part then
		self._part = Instance.new("Part")
		self._part.Size = createVector(0, 0, 0)
		self._part.Transparency = 1
		self._part.CanCollide = false
		self._part.CanTouch = false
		self._part.CanQuery = false
		self._part.Anchored = true
		self._part.Name = "CameraFlashlight"
		self._part.Parent = workspace
		local spotLight = Instance.new("SpotLight")
		spotLight.Range = 48
		spotLight.Brightness = 3
		spotLight.Shadows = true
		spotLight.Parent = self._part
		self:Update(nil, nil)
	elseif not cameraFlashlightEnabled and self._part then
		self._part:Destroy()
		self._part = nil
	end
end

function Flashlight:_Init()
	self.ClientFighterCharacter:GetDataChangedSignal("CameraFlashlightEnabled"):Connect(function()
		self:_Verify()
	end)
	self.ClientFighterCharacter.EnteredWorld:Connect(function()
		self:_Verify()
	end)
	self:_Verify()
end

return Flashlight