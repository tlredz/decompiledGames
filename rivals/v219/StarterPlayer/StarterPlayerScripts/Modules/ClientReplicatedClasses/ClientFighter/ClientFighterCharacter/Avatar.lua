local Players = game:GetService("Players")
local DebugState = require(Players.LocalPlayer.PlayerScripts.Controllers.DebugController.DebugState)
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local defaultHeadMesh = Players.LocalPlayer.PlayerScripts.Assets.Misc.DefaultHeadMesh
local v = { "rbxassetid://6686307858", "https://assetdelivery.roblox.com/v1/asset/?id=16673245747" }
local Avatar = {}
Avatar.__index = Avatar

function Avatar.new(clientFighterCharacter)
	local self = setmetatable({}, Avatar)
	self.ClientFighterCharacter = clientFighterCharacter
	self._neck_rig_attachment = nil
	self._hat_attachment = nil
	self._is_head_too_big = nil
	self._is_custom_head_blacklisted = nil
	self._default_head_mesh = defaultHeadMesh:Clone()
	self._default_head_face = self._default_head_mesh.Decal
	self._default_head_weld = nil
	self._accessory_meshes = {}
	self._already_checked_accessory = {}
	self._deleted_face_controls = false
	self:_Init()
	return self
end

function Avatar.Update(_, _, _) end

function Avatar:Destroy()
	self._default_head_mesh:Destroy()
end

function Avatar:_IsLocalPlayer()
	return self.ClientFighterCharacter.ClientFighter.IsLocalPlayer
end

function Avatar:_IsInTransparencyContext()
	return not self:_IsLocalPlayer() and self.ClientFighterCharacter.ClientFighter:Get("IsInDuel") and not DebugState:Get("DisableTransparentHats")
end

function Avatar:_IsHeadSizeDimensionTooBig(p2)
	return math.abs(p2 / (self.ClientFighterCharacter:Get("Scale") or 1) - 1) > 0.25
end

function Avatar:_DeleteFaceControls()
	if self._deleted_face_controls or not self.ClientFighterCharacter.ClientFighter:Get("IsInDuel") then
		return
	end

	self._deleted_face_controls = true
	task.spawn(function()
		local faceControls

		while true do
			faceControls = self.ClientFighterCharacter.Head:FindFirstChildOfClass("FaceControls")

			if faceControls then
				break
			end

			self.ClientFighterCharacter.Head.ChildAdded:Wait()
		end

		task.defer(faceControls.Destroy, faceControls)
	end)
end

function Avatar:_UpdateDefaultHead()
	if not self.ClientFighterCharacter:IsAlive() then
		return
	end

	if self.ClientFighterCharacter.ClientFighter:Get("IsHiddenByEmotes") or self.ClientFighterCharacter.ClientFighter:Get("IsHiddenByCutscene") then
		self._default_head_mesh.Transparency = 1
		self._default_head_face.Transparency = 1
	else
		local _is_custom_head_blacklisted = self:_IsInTransparencyContext() and (self._is_custom_head_blacklisted or self:_IsHeadSizeDimensionTooBig(self.ClientFighterCharacter.Head.Size.X) or self:_IsHeadSizeDimensionTooBig(self.ClientFighterCharacter.Head.Size.Y) or self:_IsHeadSizeDimensionTooBig(self.ClientFighterCharacter.Head.Size.Z) or self:_IsHeadSizeDimensionTooBig((math.abs(self._hat_attachment.WorldPosition.Y - self._neck_rig_attachment.WorldPosition.Y))))
		local v2 = _is_custom_head_blacklisted == self._is_head_too_big
		self._is_head_too_big = _is_custom_head_blacklisted
		local isActuallyFirstPerson = self.ClientFighterCharacter.ClientFighter:IsActuallyFirstPerson()
		self.ClientFighterCharacter.Head.LocalTransparencyModifier = isActuallyFirstPerson and 1 or self._is_head_too_big and 1 or 0
		self._default_head_mesh.Transparency = isActuallyFirstPerson and 1 or self._is_head_too_big and 0 or 1
		self._default_head_face.Transparency = self._default_head_mesh.Transparency
		self._default_head_weld.Enabled = false
		self._default_head_mesh.Size = defaultHeadMesh.Size * (self.ClientFighterCharacter:Get("Scale") or 1)
		self._default_head_mesh.CFrame = self._neck_rig_attachment.WorldCFrame * CFrame.new(
			0,
			self._default_head_mesh.Size.Y / 2,
			0
		)
		self._default_head_weld.Enabled = true

		if not v2 then
			self:_BulkUpdateAccessoryMeshes()
		end
	end
end

function Avatar:_BulkUpdateAccessoryMeshes()
	for k in pairs(self._accessory_meshes) do
		self:_UpdateAccessoryMesh(k)
	end
end

function Avatar:_UpdateAccessoryMesh(p)
	local _accessory_mesh = self._accessory_meshes[p]

	if not _accessory_mesh then
		return
	end

	local v2 = 3 * (self.ClientFighterCharacter:Get("Scale") or 1)
	local v3 = v2 < p.Size.X or v2 < p.Size.Y or v2 < p.Size.Z
	local v4 = self._is_head_too_big and not self._is_custom_head_blacklisted and 0.875 or v3 and self:_IsInTransparencyContext() and 0.875 or 0
	p.Transparency = _accessory_mesh.OriginalTransparency + (1 - _accessory_mesh.OriginalTransparency) * v4
end

function Avatar:_AccessoryMeshAdded(part)
	if not part:IsA("BasePart") then
		return
	end

	self._accessory_meshes[part] = self._accessory_meshes[part] or {
		OriginalTransparency = part.Transparency
	}
	part:GetPropertyChangedSignal("Size"):Connect(function()
		self:_UpdateAccessoryMesh(part)
	end)
	self:_UpdateAccessoryMesh(part)
end

function Avatar:_AccessoryAdded(accessory)
	if not accessory:IsA("Accessory") or self._already_checked_accessory[accessory] or self:_IsLocalPlayer() then
		return
	end

	self._already_checked_accessory[accessory] = true
	accessory.ChildAdded:Connect(function(child)
		self:_AccessoryMeshAdded(child)
	end)

	for _, child in pairs(accessory:GetChildren()) do
		self:_AccessoryMeshAdded(child)
	end
end

function Avatar:_SetupAsync()
	self.ClientFighterCharacter:WaitUntilIsInWorld()
	self._neck_rig_attachment = self.ClientFighterCharacter.Head:WaitForChild("NeckRigAttachment")
	self._hat_attachment = self.ClientFighterCharacter.Head:WaitForChild("HatAttachment")
	self._is_custom_head_blacklisted = table.find(v, self.ClientFighterCharacter.Head.MeshId)
	self._default_head_mesh.Color = self.ClientFighterCharacter.Head.Color
	self._default_head_mesh.Parent = self.ClientFighterCharacter.Head
	self._default_head_weld = Instance.new("WeldConstraint")
	self._default_head_weld.Part0 = self.ClientFighterCharacter.Head
	self._default_head_weld.Part1 = self._default_head_mesh
	self._default_head_weld.Parent = self._default_head_mesh
	self.ClientFighterCharacter:GetDataChangedSignal("Scale"):Connect(function()
		self:_UpdateDefaultHead()
	end)
	self.ClientFighterCharacter.Head:GetPropertyChangedSignal("Size"):Connect(function()
		self:_UpdateDefaultHead()
	end)
	self.ClientFighterCharacter.Head:GetPropertyChangedSignal("Transparency"):Connect(function()
		self:_UpdateDefaultHead()
	end)
	self.ClientFighterCharacter.Head:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
		self:_UpdateDefaultHead()
	end)
	self._default_head_mesh:GetPropertyChangedSignal("Transparency"):Connect(function()
		self:_UpdateDefaultHead()
	end)
	self._default_head_mesh:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
		self:_UpdateDefaultHead()
	end)
	self.ClientFighterCharacter.Model.ChildAdded:Connect(function(child)
		if not self.ClientFighterCharacter:IsAlive() then
			return
		end

		self:_AccessoryAdded(child)
	end)
	self.ClientFighterCharacter:AddConnection(DebugState:GetDataChangedSignal("DisableTransparentHats"):Connect(function()
		self:_BulkUpdateAccessoryMeshes()
		self:_UpdateDefaultHead()
	end))
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter:GetDataChangedSignal("IsInDuel"):Connect(function()
		self:_BulkUpdateAccessoryMeshes()
		self:_UpdateDefaultHead()
		self:_DeleteFaceControls()
	end))
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter:GetDataChangedSignal("IsSpectating"):Connect(function()
		self:_UpdateDefaultHead()
	end))
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter:GetDataChangedSignal("IsHiddenByEmotes"):Connect(function()
		self:_UpdateDefaultHead()
	end))
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter:GetDataChangedSignal("IsHiddenByCutscenes"):Connect(function()
		self:_UpdateDefaultHead()
	end))
	self.ClientFighterCharacter:AddConnection(CameraController.StateChanged:Connect(function()
		self:_UpdateDefaultHead()
	end))
	self.ClientFighterCharacter:AddConnection(SpectateController.SubjectEmoteStatusChanged:Connect(function()
		self:_UpdateDefaultHead()
	end))

	for _, child in pairs(self.ClientFighterCharacter.Model:GetChildren()) do
		self:_AccessoryAdded(child)
	end

	self:_UpdateDefaultHead()
	self:_DeleteFaceControls()
end

function Avatar:_Init()
	task.spawn(self._SetupAsync, self)
end

return Avatar