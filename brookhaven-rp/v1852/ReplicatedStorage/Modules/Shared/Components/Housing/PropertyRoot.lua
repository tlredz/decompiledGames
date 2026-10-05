local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local LotRoot = require(ReplicatedStorage.Modules.Shared.Components.Housing.LotRoot)
local v = Component.new({
	Tag = "PropertyRoot"
})
local isServer = RunService:IsServer()

local function resolveCameraIndex(p)
	local name = tonumber(p.Name)

	if name ~= nil then
		return name
	end

	if string.sub(p.Name, 1, 5) == "House" then
		return (tonumber((string.sub(p.Name, 6))))
	end

	return nil
end

local function collectCameraParts(folder)
	local partsByName = {}

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part:HasTag("PropertyCamera")) then
			continue
		end

		local name = tonumber(part.Name)

		if name == nil then
			if string.sub(part.Name, 1, 5) == "House" then
				name = tonumber((string.sub(part.Name, 6)))
			else
				name = nil
			end
		end

		if name ~= nil then
			partsByName[name] = part
		end
	end

	local _001_HouseCams = folder:FindFirstChild("001_HouseCams", true)

	if _001_HouseCams == nil then
		return partsByName
	end

	for _, part in _001_HouseCams:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		local name = tonumber(part.Name)

		if name == nil then
			if string.sub(part.Name, 1, 5) == "House" then
				name = tonumber((string.sub(part.Name, 6)))
			else
				name = nil
			end
		end

		if name ~= nil then
			partsByName[name] = part
		end
	end

	return partsByName
end

function v.CaptureCamerasOnto(instance, p)
	for k, v2 in collectCameraParts(p) do
		instance:SetAttribute("HouseCam_" .. k, v2.CFrame)
	end
end

function v:GeneratePropBlockingPart()
	local boundingBox, v2 = self.Instance:GetBoundingBox()
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Size = v2 + createVector(3, 3, 3)
	part.Transparency = 1
	part.CFrame = boundingBox
	part.Name = "PropertyPropBlocking"
	part.Parent = self.Instance
	part:AddTag("PropertyPropBlocking")
end

function v:EnableDisastersScriptInLegacyHouses()
	local mainHouseScript = self.Instance:FindFirstChild("MainHouseScript")

	if not mainHouseScript then
		return
	end

	local disasters = mainHouseScript:FindFirstChild("Disasters")

	if not disasters then
		return
	end

	disasters.Disabled = false
end

function v:Construct()
	self.lotRoot = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "LotRoot", LotRoot)
	self:RegisterSignals()
	self._name = ""
	self.cameras = {}
	self._camerasResolved = false
	self._animationPermissions = false
end

function v:Start()
	self.ownerValue = self.Instance:WaitForChild("Owner")
	self.ownerObjValue = self.Instance:WaitForChild("OwnerOBJ")

	if isServer then
		self.nameValue = Instance.new("StringValue", self.Instance)
		self.nameValue.Name = "PropertyName"
		self:GeneratePropBlockingPart()
		self:EnableDisastersScriptInLegacyHouses()
		self:_loadCamerasFromAttributes()
		self:CaptureCameras()
	else
		self.nameValue = self.Instance:WaitForChild("PropertyName")

		if self.Instance:GetAttribute("PropertyChangeable") == true then
			self:_ListenForChangeableAnimationPermissions()
		end
	end
end

function v:RegisterSignals()
	self.OnOwnerChanged = Signal.new()
end

function v:GetName()
	return self._name
end

function v.GetDisplayName(p)
	return p.nameValue.Value
end

function v:SetName(name: string)
	self._name = name
end

function v.SetDisplayName(p, p2: string)
	p.nameValue.Value = p2
end

function v.GetOwner(p)
	return p.ownerObjValue.Value
end

function v.SetOwner(data, p)
	if p == nil then
		data.ownerValue.Value = ""
		data.ownerObjValue.Value = nil
		data.OnOwnerChanged:Fire()
	else
		data.ownerValue.Value = p.Name
		data.ownerObjValue.Value = p
		data.OnOwnerChanged:Fire(p)

		if data.lotRoot ~= nil then
			Remotes.fireClient("Property:Permissions", p, data.lotRoot:GetId(), true)
		end
	end
end

function v.IsResettable(p)
	return p.Instance:HasTag("PropertyResettable")
end

function v:SetPropertyBusinessSignComponent(propertyBusinessSign)
	self.propertyBusinessSign = propertyBusinessSign
end

function v.GetPropertyBusinessSignComponent(p)
	return p.propertyBusinessSign
end

function v:_setCamera(p2: number, cFrame: CFrame, instance)
	local camera = self.cameras[p2]

	if camera == nil then
		self.cameras[p2] = {
			CFrame = cFrame,
			Instance = instance
		}
	else
		camera.CFrame = cFrame
		camera.Instance = instance
	end

	if isServer then
		self.Instance:SetAttribute("HouseCam_" .. p2, cFrame)
	end
end

function v:_loadCamerasFromAttributes()
	for k, cFrame in self.Instance:GetAttributes() do
		local v3 = string.match(k, "^HouseCam_(%d+)$")

		if not (v3 ~= nil and typeof(cFrame) == "CFrame") then
			continue
		end

		local v4 = tonumber(v3)

		if v4 == nil then
			continue
		end

		local camera = self.cameras[v4]

		if camera == nil then
			self.cameras[v4] = {
				CFrame = cFrame,
				Instance = nil
			}
		else
			camera.CFrame = cFrame
		end
	end
end

function v:RegisterCamera(part)
	if not part:IsA("BasePart") then
		return
	end

	local name = tonumber(part.Name)

	if name == nil then
		if string.sub(part.Name, 1, 5) == "House" then
			name = tonumber((string.sub(part.Name, 6)))
		else
			name = nil
		end
	end

	if name == nil then
		return
	end

	self:_setCamera(name, part.CFrame, part)
	self._camerasResolved = true
end

function v:CaptureCameras(p)
	for k, v3 in collectCameraParts(p or self.Instance) do
		local v4

		if v3:IsDescendantOf(self.Instance) then
			v4 = v3
		end

		self:_setCamera(k, v3.CFrame, v4)
	end

	if next(self.cameras) ~= nil then
		self._camerasResolved = true
	end
end

function v.GetHouseModel(p)
	return p.Instance
end

function v.ToggleActiveTheme(p, flag: boolean)
	Remotes.invokeServerComponent(p.Instance, "PropertyRoot:ToggleActiveTheme", flag)
end

function v:GetCameras()
	if not self._camerasResolved then
		self:_loadCamerasFromAttributes()
		self:CaptureCameras()
		self._camerasResolved = true
	end

	local v2 = next(self.cameras) == nil

	if v2 ~= true then
		for _, camera in self.cameras do
			if not (camera.Instance == nil or camera.Instance.Parent == nil) then
				continue
			end

			v2 = true
			break
		end
	end

	if v2 == true then
		self:CaptureCameras()
	end

	for _, camera in self.cameras do
		local instance = camera.Instance

		if instance == nil or instance.Parent == nil then
			camera.Instance = nil
		else
			camera.CFrame = instance.CFrame
		end
	end

	return self.cameras
end

function v:_FindAnimationPermissionFolder()
	local _001_AnimationPermission = self.Instance:FindFirstChild("001_AnimationPermission")

	if _001_AnimationPermission ~= nil then
		return _001_AnimationPermission
	end

	local _001_ChangeRoom = self.Instance:FindFirstChild("001_ChangeRoom")

	if _001_ChangeRoom == nil then
		return nil
	end

	local _001_HoldRooms = _001_ChangeRoom:FindFirstChild("001_HoldRooms")

	if _001_HoldRooms == nil then
		return nil
	end

	local room = _001_HoldRooms:FindFirstChild("Room")

	if room == nil then
		return nil
	end

	return room:FindFirstChild("001_AnimationPermission")
end

function v:_ListenForChangeableAnimationPermissions()
	local _001_ChangeRoom = self.Instance:FindFirstChild("001_ChangeRoom")

	if _001_ChangeRoom == nil then
		return
	end

	local _001_HoldRooms = _001_ChangeRoom:FindFirstChild("001_HoldRooms")

	if _001_HoldRooms == nil then
		return
	end

	local function onRoom(room)
		if room.Name ~= "Room" then
			return
		end

		if room:FindFirstChild("001_AnimationPermission") ~= nil then
			self:SetAnimationPermissions(self._animationPermissions)
		end

		room.ChildAdded:Connect(function(child)
			if child.Name == "001_AnimationPermission" then
				self:SetAnimationPermissions(self._animationPermissions)
			end
		end)
	end

	local room = _001_HoldRooms:FindFirstChild("Room")

	if room ~= nil then
		onRoom(room)
	end

	_001_HoldRooms.ChildAdded:Connect(onRoom)
end

function v:SetAnimationPermissions(animationPermissions: boolean)
	self._animationPermissions = animationPermissions
	local _FindAnimationPermissionFolder = self:_FindAnimationPermissionFolder()

	if _FindAnimationPermissionFolder == nil then
		return
	end

	for _, child in _FindAnimationPermissionFolder:GetChildren() do
		local TF = child:FindFirstChild("TF")

		if TF ~= nil then
			TF.Value = animationPermissions
		end
	end
end

return v