local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local wrapTextures = CONSTANTS.IS_CLIENT and CONSTANTS.IS_RUNNING and Players.LocalPlayer.PlayerScripts.Assets:WaitForChild("WrapTextures")
local wrapGroupObjects = Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("WrapGroupObjects")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._wrap_group_callbacks = {}
	self._wrap_group_classes = {}
	self._wrap_group_objects = {}
	self._wrap_group_objects_count = {}
	self._preloaded_wrap_group_objects = {}
	self._preload_screen_gui = Instance.new("ScreenGui")
	self:_Init()
	return self
end

function class:RecordOriginalWrapProperties(folder)
	local result = {}
	local descendants

	if typeof(folder) == "table" then
		descendants = folder
	else
		descendants = folder:GetDescendants()
		table.insert(descendants, folder)
	end

	for _, instance in pairs(descendants) do
		if not instance:HasTag("Wrappable") then
			continue
		end

		local v = nil
		local originalProperties

		if instance:IsA("BasePart") then
			originalProperties = {
				Material = instance.Material,
				MaterialVariant = instance.MaterialVariant,
				Color = instance.Color,
				Transparency = instance.Transparency,
				Reflectance = instance.Reflectance
			}

			if instance:IsA("MeshPart") then
				originalProperties.TextureID = instance.TextureID
			end
		elseif instance:IsA("Decal") or instance:IsA("Texture") then
			originalProperties = {
				Color3 = instance.Color3,
				Transparency = instance.Transparency
			}
		elseif instance:IsA("Beam") or instance:IsA("Trail") or instance:IsA("ParticleEmitter") then
			originalProperties = {
				Color = instance.Color,
				Transparency = instance.Transparency,
				LightEmission = instance.LightEmission
			}
		elseif instance:IsA("Frame") then
			originalProperties = {
				BackgroundColor3 = instance.BackgroundColor3,
				BackgroundTransparency = instance.BackgroundTransparency
			}
		elseif instance:IsA("ImageLabel") then
			originalProperties = {
				ImageColor3 = instance.ImageColor3,
				ImageTransparency = instance.ImageTransparency
			}
		elseif instance:IsA("Light") then
			originalProperties = {
				Color = instance.Color,
				Brightness = instance.Brightness
			}
		else
			originalProperties = (instance:IsA("RopeConstraint") or instance:IsA("SpringConstraint")) and {
				Color = instance.Color
			} or v
		end

		if not originalProperties then
			continue
		end

		result[instance] = {
			WrapGroup = instance:GetAttribute("WrapGroup"),
			IgnoreTransparency = instance:GetAttribute("IgnoreTransparency"),
			IgnoreMaterial = instance:GetAttribute("IgnoreMaterial"),
			IgnoreObject = instance:GetAttribute("IgnoreObject"),
			OriginalProperties = originalProperties,
			OriginalChildren = {},
			Cleanup = {}
		}

		for _, surfaceAppearance in pairs(instance:GetChildren()) do
			if surfaceAppearance:IsA("SurfaceAppearance") then
				table.insert(result[instance].OriginalChildren, surfaceAppearance)
			end
		end

		assert(result[instance].WrapGroup and typeof(result[instance].WrapGroup) == "number", instance:GetFullName())
	end

	return result
end

function class:ResetWrap(items)
	if not items then
		return
	end

	for originalProperties, item in pairs(items) do
		for k, originalProperty in pairs(item.OriginalProperties) do
			originalProperties[k] = originalProperty
		end

		for _, v in pairs(item.OriginalChildren) do
			local v2 = v
			local parent = originalProperties
			pcall(function()
				v2.Parent = parent
			end)
		end

		for _, v in pairs(item.Cleanup) do
			v:Destroy()
		end

		item.Cleanup = {}
	end
end

function class:ApplyWrap(items, p, p2, p3)
	self:ResetWrap(items)

	if not p or p.Name == "RANDOM_COSMETIC" then
		return
	end

	local cosmetic = CosmeticLibrary.Cosmetics[p.Name]
	local inverted = p.Inverted

	for instance, item in pairs(items) do
		if p3 and p3[instance] then
			continue
		end

		local v

		if inverted then
			v = item.WrapGroup == 1 and 2 or item.WrapGroup == 2 and 1 or item.WrapGroup
		else
			v = item.WrapGroup
		end

		local v2 = cosmetic.WrapGroups[v] or {}
		local v3 = p2 or item.IgnoreTransparency
		local ignoreMaterial = item.IgnoreMaterial
		local ignoreObject = item.IgnoreObject
		local clones = {}

		if instance:IsA("BasePart") then
			instance.Color = v2.Color or instance.Color
			instance.Transparency = not v3 and v2.Transparency or instance.Transparency
			instance.Reflectance = v2.Reflectance or instance.Reflectance
			instance.Material = not ignoreMaterial and (not v3 or v2.Material ~= Enum.Material.ForceField) and v2.Material or instance.Material
			instance.MaterialVariant = not ignoreMaterial and v2.MaterialVariant or instance.MaterialVariant

			if instance:IsA("MeshPart") then
				instance.TextureID = ""
			end

			if not ignoreMaterial then
				for _, v4 in pairs(not v2.Textures and {} or wrapTextures[v2.Textures]:GetChildren() or {}) do
					local clone = v4:Clone()
					clone.LocalTransparencyModifier = instance.LocalTransparencyModifier
					clone.Parent = instance
					table.insert(item.Cleanup, clone)
					table.insert(clones, clone)
				end
			end
		elseif instance:IsA("Decal") or instance:IsA("Texture") then
			instance.Color3 = v2.Color3 or instance.Color3
			instance.Transparency = not v3 and v2.Transparency or instance.Transparency
		elseif instance:IsA("Beam") or instance:IsA("Trail") or instance:IsA("ParticleEmitter") then
			instance.Color = v2.Color and ColorSequence.new(v2.Color) or instance.Color
		elseif instance:IsA("Frame") then
			instance.BackgroundColor3 = v2.Color or instance.BackgroundColor3
			instance.BackgroundTransparency = not v3 and v2.Transparency or instance.BackgroundTransparency
		elseif instance:IsA("ImageLabel") then
			instance.ImageColor3 = v2.Color or instance.ImageColor3
			instance.ImageTransparency = not v3 and v2.Transparency or instance.ImageTransparency
		elseif instance:IsA("Light") then
			instance.Color = v2.Color or instance.Color
			instance.Brightness += (0 - instance.Brightness) * (v3 and 0 or v2.Transparency or 0)
		elseif instance:IsA("RopeConstraint") or instance:IsA("SpringConstraint") then
			instance.Color = v2.Color and BrickColor.new(v2.Color) or instance.Color
		end

		for _, v4 in pairs(item.OriginalChildren) do
			local v5 = v4
			pcall(function()
				v5.Parent = nil
			end)
		end

		if ignoreObject then
			continue
		end

		local _GetWrapGroupObject = self:_GetWrapGroupObject(v2)

		if not _GetWrapGroupObject then
			continue
		end

		local v4 = _GetWrapGroupObject.new(v2.ObjectName, instance, clones)
		table.insert(self._wrap_group_objects, v4)
		table.insert(item.Cleanup, v4)
		self:_IncrementWrapGroupObjectsCount(v4.Name, 1, v4)
	end
end

function class:Update(p)
	for i = #self._wrap_group_objects, 1, -1 do
		local _wrap_group_object = self._wrap_group_objects[i]

		if _wrap_group_object.IsDestroyed then
			table.remove(self._wrap_group_objects, i)
			self:_IncrementWrapGroupObjectsCount(_wrap_group_object.Name, -1, _wrap_group_object)
		elseif _wrap_group_object.Update and _wrap_group_object:IsActive() then
			if CONSTANTS.IS_STUDIO then
				_wrap_group_object:Update(p)
			else
				pcall(_wrap_group_object.Update, _wrap_group_object, p)
			end
		end
	end
end

function class:_IncrementWrapGroupObjectsCount(p, p2, object)
	local v = (self._wrap_group_objects_count[p] or 0) + p2
	local _wrap_group_objects_count = self._wrap_group_objects_count
	local v2

	if not (v <= 0) then
		v2 = v
	end

	_wrap_group_objects_count[p] = v2

	if v == 1 then
		local preloadedImageIDs = object.GetPreloadedImageIDs and object:GetPreloadedImageIDs()

		if not preloadedImageIDs or #preloadedImageIDs == 0 then
			return
		end

		self._preloaded_wrap_group_objects[p] = self._preloaded_wrap_group_objects[p] or {}
		self._preloaded_wrap_group_objects[p].Textures = self._preloaded_wrap_group_objects[p].Textures or {}

		for k, preloadedImageID in pairs(preloadedImageIDs) do
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.BackgroundTransparency = 1
			imageLabel.Active = false
			imageLabel.Size = UDim2.new(0, 1, 0, 1)
			imageLabel.ImageTransparency = 0.99
			imageLabel.Image = preloadedImageID
			imageLabel.Name = p .. " - " .. k
			imageLabel.Parent = self._preload_screen_gui
			table.insert(self._preloaded_wrap_group_objects[p].Textures, imageLabel)
		end
	elseif not v then
		for _, v3 in pairs(not self._preloaded_wrap_group_objects[p] and {} or self._preloaded_wrap_group_objects[p].Textures or {}) do
			task.defer(v3.Destroy, v3)
		end

		self._preloaded_wrap_group_objects[p] = nil
	end
end

function class:_GetWrapGroupObject(p2)
	if not p2.ObjectName then
		return
	end

	if self._wrap_group_classes[p2.ObjectName] then
		return self._wrap_group_classes[p2.ObjectName]
	end

	local _wrap_group_classes = self._wrap_group_classes
	local objectName = p2.ObjectName
	local module = require(wrapGroupObjects:WaitForChild(p2.ObjectName))
	_wrap_group_classes[objectName] = module
	return self._wrap_group_classes[p2.ObjectName]
end

function class:_WrapThis(instance)
	self:ApplyWrap(self:RecordOriginalWrapProperties(instance), {
		Name = instance:GetAttribute("WrapName")
	})
end

function class:_Setup()
	self._preload_screen_gui.Name = "PreloadedWrapTextures"
	self._preload_screen_gui.ResetOnSpawn = false
	self._preload_screen_gui.Parent = Players.LocalPlayer.PlayerGui
end

function class:_Init()
	RunService:BindToRenderStep("WrapController", Enum.RenderPriority.Camera.Value + 1, function(p)
		self:Update(p)
	end)
	CollectionService:GetInstanceAddedSignal("WrapThis"):Connect(function(p)
		self:_WrapThis(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("WrapThis")) do
		task.defer(self._WrapThis, self, v)
	end

	self:_Setup()
end

return class._new()