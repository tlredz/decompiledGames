local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local WrapController = require(Players.LocalPlayer.PlayerScripts.Controllers.WrapController)
local StaticModel = require(Players.LocalPlayer.PlayerScripts.Modules.StaticModel)
local Charm = require(Players.LocalPlayer.PlayerScripts.Modules.Charm)
local charms = Players.LocalPlayer.PlayerScripts.Modules.Charms
local viewModels = Players.LocalPlayer.PlayerScripts.Assets.ViewModels
local object = setmetatable({}, StaticModel)
object.__index = object

function object.new(name, _)
	local self = setmetatable(StaticModel.new(Utility:LookThrough(viewModels, name):Clone()), object)
	self.Name = name
	local itemName = CosmeticLibrary.Cosmetics[self.Name] and CosmeticLibrary.Cosmetics[self.Name].ItemName

	if not itemName then
		if ItemLibrary.Items[self.Name] then
			itemName = self.Name or nil
		else
			itemName = nil
		end
	end

	self.WeaponName = itemName
	self.Charm = nil
	self.Wrap = nil
	self._submodel_to_grip_attachment = {}
	self._grip_attachment_to_limb = {}
	self._charm_scale_multiplier = 1
	self._charm_attachment_model = self.Model:FindFirstChild("_charm_attachment_model", true)
	self._charm_attachment_model_parent = self._charm_attachment_model and self._charm_attachment_model.Parent
	self._charm_pivot_attachment = self._charm_attachment_model and self._charm_attachment_model:FindFirstChild(
		"_charm_pivot_attachment",
		true
	) or self.Model:FindFirstChild("_charm_pivot_attachment", true)
	self._original_wrap_properties = {}
	self._wrapped_only_objects = {}
	self._is_locked = false
	self._locked_original_properties = {}
	self._weld_data = {}
	self._fake_model = self.Model:FindFirstChild("_fake")
	self:_Init()
	return self
end

function object:GetCharmPivotAttachment()
	return self._charm_pivot_attachment
end

function object:GetPivot()
	return self.Model:GetPivot()
end

function object:GetBoundingBox()
	return self.Model:GetBoundingBox()
end

function object:IsLocked()
	return self._is_locked
end

function object.HasGripAttachment(p)
	return p.Model:FindFirstChild("_grip", true)
end

function object:DeleteAnimationContextSubModels(attributeName)
	local v = {}

	for k in pairs(self._submodel_to_grip_attachment) do
		if not k:GetAttribute("AnimationContexts") or attributeName and k:GetAttribute(attributeName) then
			continue
		end

		k:Destroy()
		table.insert(v, k)
	end

	for _, v2 in pairs(v) do
		self._submodel_to_grip_attachment[v2] = nil
	end
end

function object:ForceCharmAttachmentModelVisible(is_charm_attachment_model_forced_visible)
	self._is_charm_attachment_model_forced_visible = is_charm_attachment_model_forced_visible
	self:_UpdateCharmAttachmentModelVisibility()
end

function object:SetParent(parent)
	self.Model.Parent = parent

	if self.Charm then
		self.Charm:SetParent(parent)
	end
end

function object:SetLocked(is_locked)
	if is_locked == self._is_locked then
		return
	end

	self._is_locked = is_locked

	if self._is_locked then
		self:_Lock()
	else
		self:_Unlock()
	end

	self:_UpdateWrap()
end

function object:SetCharm(p)
	if self.Charm then
		self.Charm:Destroy()
		self.Charm = nil
	end

	if not (p and self._charm_pivot_attachment) then
		self:_UpdateCharmAttachmentModelVisibility()
		return
	end

	local child = charms:FindFirstChild(p.Name, true)
	self.Charm = (child and require(child) or Charm).new(nil, p, self._charm_pivot_attachment)
	self.Charm:ScaleTo(self.Model:GetScale() / self._original_scale * self._charm_scale_multiplier)
	self.Charm:SetParent(self.Model.Parent)
	self:_UpdateCharmAttachmentModelVisibility()
end

function object:SetWrap(wrap)
	self.Wrap = wrap
	self:_UpdateWrap()
end

function object:BreakWeld()
	for k, _ in pairs(self._weld_data) do
		k.Anchored = true
	end

	for _, v in pairs(self._weld_data) do
		v:Destroy()
	end

	self._weld_data = {}
end

function object:WeldTo(part)
	self:BreakWeld()
	local model = self.Model
	local v2

	if self.Charm then
		v2 = self.Charm.Model or nil
	end

	for _, folder in pairs({ model, v2 }) do
		for _, part2 in pairs(folder:GetDescendants()) do
			if not part2:IsA("BasePart") then
				continue
			end

			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part1 = part
			weldConstraint.Part0 = part2
			weldConstraint.Parent = part2
			self._weld_data[part2] = weldConstraint
		end
	end

	for k in pairs(self._weld_data) do
		k.Massless = true
		k.Anchored = false
	end
end

function object:ScaleTo(p, value)
	local cFrames = {}

	for _, v in pairs(self._submodel_to_grip_attachment) do
		cFrames[v] = v.CFrame
	end

	StaticModel.ScaleTo(self, p)

	for _, v in pairs(self._submodel_to_grip_attachment) do
		v.CFrame = cFrames[v]
	end

	self._charm_scale_multiplier = value or 1

	if self.Charm then
		self.Charm:ScaleTo(p * self._charm_scale_multiplier)
	end
end

function object:PivotTo(p, childName)
	local child = childName and self.Model:FindFirstChild(childName, true)
	local worldCFrame = child and child.WorldCFrame
	self:_ParentWrappedOnlyObjects(true)
	StaticModel.PivotTo(self, p, worldCFrame)
	self:_ParentWrappedOnlyObjects(self:_WrapExists())
end

function object:InitializeGrip()
	if self._fake_model then
		task.defer(self._fake_model.Destroy, self._fake_model)
		self._fake_model = nil
	end

	for _, child in pairs(self.Model:GetChildren()) do
		child.WorldPivot = self._submodel_to_grip_attachment[child].WorldCFrame
	end
end

function object:GripPivotTo(p)
	for _, child in pairs(self.Model:GetChildren()) do
		local v = self._submodel_to_grip_attachment[child]
		child:PivotTo(p[self._grip_attachment_to_limb[v]].CFrame)
	end

	self:Update(0)
end

function object.Update(p, p2)
	StaticModel.Update(p, p2)

	if p.Charm then
		p.Charm:Update(p2)
	end
end

function object.Destroy(p)
	if p.Charm then
		p.Charm:Destroy()
	end

	StaticModel.Destroy(p)
end

function object:_GetWrappedOnlyObjectByName(p2)
	for k in pairs(self._wrapped_only_objects) do
		if k.Name == p2 then
			return k
		end
	end
end

function object:_WrapExists()
	return self.Wrap and self.Wrap.Name ~= "RANDOM_COSMETIC"
end

function object:_ParentWrappedOnlyObjects(p2)
	for k, _wrapped_only_object in pairs(self._wrapped_only_objects) do
		k.Parent = p2 and _wrapped_only_object or nil
	end
end

function object:_UpdateWrap()
	if self._is_locked then
		return
	end

	WrapController:ApplyWrap(self._original_wrap_properties, self.Wrap)
	self:_UpdateCharmAttachmentModelVisibility()

	if self._fake_model then
		local _WrapExists = self:_WrapExists()
		local v = _WrapExists and self:_GetWrappedOnlyObjectByName("LeftArmWrapped")
		local v2 = _WrapExists and self:_GetWrappedOnlyObjectByName("RightArmWrapped")

		if self._fake_model:FindFirstChild("LeftArm") then
			self._fake_model.LeftArm.Transparency = v and 1 or 0
			self._fake_model.LeftArm.ShirtTexture.Transparency = v and 1 or 0
		end

		if self._fake_model:FindFirstChild("RightArm") then
			self._fake_model.RightArm.Transparency = v2 and 1 or 0
			self._fake_model.RightArm.ShirtTexture.Transparency = v2 and 1 or 0
		end

		self:_ParentWrappedOnlyObjects(_WrapExists)
	end
end

function object:_UpdateCharmAttachmentModelVisibility()
	local localTransparencyModifier = (self.Charm or self._is_charm_attachment_model_forced_visible) and 0 or 1

	for _, instance in pairs(self._charm_attachment_model and self._charm_attachment_model:GetDescendants() or {}) do
		if instance:IsA("BasePart") or instance:IsA("Texture") then
			instance.LocalTransparencyModifier = localTransparencyModifier
		end
	end
end

function object:_Unlock()
	for k, _locked_original_property in pairs(self._locked_original_properties) do
		for k2, v in pairs(_locked_original_property) do
			k[k2] = v
		end
	end

	self._locked_original_properties = {}
end

function object:_Lock()
	local function check(instance)
		if self._locked_original_properties[instance] then
			return
		end

		local v = {}

		if instance:IsA("BasePart") then
			v.Color = instance.Color
			instance.Color = Color3.fromRGB(31, 31, 31)
			v.Material = instance.Material
			instance.Material = Enum.Material.Neon

			if instance:IsA("MeshPart") then
				v.TextureID = instance.TextureID
				instance.TextureID = ""
			end
		elseif instance:IsA("Beam") or instance:IsA("Trail") or instance:IsA("ParticleEmitter") then
			v.Color = instance.Color
			instance.Color = ColorSequence.new(Color3.fromRGB(31, 31, 31))

			if instance:IsA("ParticleEmitter") or instance:IsA("Beam") then
				v.Brightness = instance.Brightness
				instance.Brightness = 1
				v.LightEmission = instance.LightEmission
				instance.LightEmission = 0
				v.LightInfluence = instance.LightInfluence
				instance.LightInfluence = 0
			end
		end

		self._locked_original_properties[instance] = v
	end

	for _, folder in pairs({ self.Model, self._charm_attachment_model }) do
		check(folder)

		for _, descendant in pairs(folder:GetDescendants()) do
			check(descendant)
		end
	end
end

function object:_Setup()
	if CosmeticLibrary.IGNORE_TRANSPARENCY_WHITELIST[self.WeaponName] then
		for _, part in pairs(self.Model:GetDescendants()) do
			if part:IsA("BasePart") then
				part:SetAttribute("IgnoreTransparency", true)
			end
		end
	end

	local v = nil

	for _, folder in pairs(self.Model:GetChildren()) do
		folder.PrimaryPart = nil

		for _, part in pairs(folder:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			part.CastShadow = true
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Massless = true
			part.Anchored = true
			part.AudioCanCollide = false
		end

		local _grip = folder:FindFirstChild("_grip", true)
		local gripTarget

		if _grip then
			gripTarget = _grip:GetAttribute("GripTarget") or "RightHand"
		end

		if not _grip then
			continue
		end

		_grip:SetAttribute("GripTarget", gripTarget)
		self._grip_attachment_to_limb[_grip] = gripTarget
		self._submodel_to_grip_attachment[folder] = _grip

		if gripTarget == "RightHand" then
			v = _grip
		end
	end

	for _, child in pairs(self.Model:GetChildren()) do
		self._submodel_to_grip_attachment[child] = self._submodel_to_grip_attachment[child] or v
	end

	self.Model.PrimaryPart = nil
	self.Model.WorldPivot = self.Model:FindFirstChild("_center", true).WorldCFrame
	self._original_wrap_properties = WrapController:RecordOriginalWrapProperties(self.Model)

	if self._fake_model then
		local rightArmWrapped = self._fake_model:FindFirstChild("RightArmWrapped")
		local leftArmWrapped = self._fake_model:FindFirstChild("LeftArmWrapped")
		local armsData, color, color2 = Utility:GetArmsData(Players.LocalPlayer.Character)

		if rightArmWrapped then
			self._wrapped_only_objects[rightArmWrapped] = self._fake_model
		end

		if leftArmWrapped then
			self._wrapped_only_objects[leftArmWrapped] = self._fake_model
		end

		if armsData and color and color2 then
			if self.Model._fake:FindFirstChild("LeftArm") then
				self._fake_model.LeftArm.ShirtTexture.Texture = armsData
				self._fake_model.LeftArm.Color = color
			end

			if self.Model._fake:FindFirstChild("RightArm") then
				self._fake_model.RightArm.ShirtTexture.Texture = armsData
				self._fake_model.RightArm.Color = color2
			end

			if rightArmWrapped then
				rightArmWrapped.Color = color2
			end

			if leftArmWrapped then
				leftArmWrapped.Color = color
			end

			for _, descendant in pairs(self.Model:GetDescendants()) do
				if descendant:GetAttribute("IsRightHand") then
					descendant.Color = color2
				elseif descendant:GetAttribute("IsLeftHand") then
					descendant.Color = color
				end
			end

			self._original_wrap_properties = WrapController:RecordOriginalWrapProperties(self.Model)
		end
	end

	if self.Name == "Chainsaw" or self.Name == "Blobsaw" then
		self.Model.Body.Spikes2:Destroy()
	elseif self.Name == "Handsaws" then
		self.Model.RightBlade.Spikes2:Destroy()
		self.Model.LeftBlade.Spikes2:Destroy()
	elseif self.Name == "Street Sign" then
		local v2 = math.random(1, 3)

		if v2 ~= 1 then
			self.Model.Body["Sign" .. 1]:Destroy()
		end

		if v2 ~= 2 then
			self.Model.Body["Sign" .. 2]:Destroy()
		end

		if v2 ~= 3 then
			self.Model.Body["Sign" .. 3]:Destroy()
		end
	end
end

function object:_Init()
	self:_Setup()
	self:SetLocked(false)
	self:SetCharm(nil)
	self:SetWrap(nil)
end

return object