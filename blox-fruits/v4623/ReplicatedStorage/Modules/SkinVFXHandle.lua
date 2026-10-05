local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
require(game.ReplicatedStorage.Modules.Util.Signal)
local Appearance = require(game.ReplicatedStorage.Definitions.Skin.Appearance)
local Modification = require(game.ReplicatedStorage.Util.Modification)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local SkinVFX = require(game.ReplicatedStorage.Util.SkinVFX)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("Modifications"):tag("SkinVFX"):display():traceback():build()

local function getOrCreateSubFolder(parent, name: string)
	local folder = parent:FindFirstChild(name)

	if folder and folder:IsA("Folder") then
		return folder
	end

	if folder then
		folder:Destroy()
	end

	local folder2 = Instance.new("Folder")
	folder2.Name = name
	folder2.Parent = parent
	return folder2
end

local function clearPaletteAttributes(instance, p: string)
	for k in instance:GetAttributes() do
		if not (k:match((`^{p}_Color%d+$`)) or k:match((`^{p}_Color%d+_StaticTime$`))) then
			continue
		end

		instance:SetAttribute(k, nil)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPaletteAttribute(instance, attributeName: string, p, p2: string)
	if p2 == "Overwrite" or instance:GetAttribute(attributeName) == nil then
		instance:SetAttribute(attributeName, p)
	end
end

local function getPaletteAttributeName(p: string, value)
	if type(value) == "number" then
		return (`{p}_Color{value}`)
	end

	if type(value) ~= "string" then
		return nil
	end

	local v2 = tonumber(value)

	if v2 then
		return (`{p}_Color{v2}`)
	end

	local v3 = value:match("_Color(%d+)$") or value:match("^Color(%d+)$")

	if v3 then
		return (`{p}_Color{v3}`)
	end

	return nil
end

local function applyPaletteColors(instance, p: string, items, p2: string)
	for k, item in items do
		if not (typeof(item) == "Color3" or p == "Shifted" and typeof(item) == "ColorSequence") then
			continue
		end

		local paletteAttributeName = getPaletteAttributeName(p, k)

		if paletteAttributeName and (p2 == "Overwrite" or instance:GetAttribute(paletteAttributeName) == nil) then
			instance:SetAttribute(paletteAttributeName, item)
		end
	end
end

local function applyPaletteConfig(parent, data, p: string)
	if not data then
		return
	end

	local default = data.Default or data.DefaultColors
	local shifted = data.Shifted or data.ShiftedColors

	if not (default or shifted) then
		return
	end

	local v2 = parent:FindFirstChild("Default")

	if not (v2 and v2:IsA("Folder")) then
		if v2 then
			v2:Destroy()
		end

		v2 = Instance.new("Folder")
		v2.Name = "Default"
		v2.Parent = parent
	end

	local v3 = parent:FindFirstChild("Shifted")

	if not (v3 and v3:IsA("Folder")) then
		if v3 then
			v3:Destroy()
		end

		v3 = Instance.new("Folder")
		v3.Name = "Shifted"
		v3.Parent = parent
	end

	if default then
		if p == "Overwrite" then
			clearPaletteAttributes(v2, "Default")
		end

		applyPaletteColors(v2, "Default", default, p)
	end

	if shifted then
		if p == "Overwrite" then
			clearPaletteAttributes(v3, "Shifted")
		end

		applyPaletteColors(v3, "Shifted", shifted, p)
	elseif default and p == "Overwrite" then
		clearPaletteAttributes(v3, "Shifted")
	end

	if data.StaticTimes then
		for k, staticTime in data.StaticTimes do
			if not (type(k) == "number" and type(staticTime) == "number") then
				continue
			end

			setPaletteAttribute(v3, `Shifted_Color{k}_StaticTime`, math.clamp(staticTime, 0, 1), p) -- equivalent call inferred; original call site unknown
		end
	end

	if default then
		applyPaletteColors(v3, "Shifted", default, "FillBlanks")
	end
end

local function createVFXContainer(instance, name: string, p)
	local vFXColor = instance:FindFirstChild("VFXColor")

	if vFXColor then
		local clone = vFXColor:Clone()
		clone.Name = name
		return clone, true
	else
		local folder = Instance.new("Folder")
		folder.Name = name
		local folder2 = Instance.new("Folder")
		folder2.Name = "Default"
		folder2.Parent = folder
		local folder3 = Instance.new("Folder")
		folder3.Name = "Shifted"
		folder3.Parent = folder
		applyPaletteConfig(folder, p, "Overwrite")
		return folder, false
	end
end

local class = {}
class.__index = class

function class:Destroy()
	local extended = v.extend((`.<{self._VFXContainer and self._VFXContainer.Name}>:Destroy`))
	extended.info("calling fn ()")
	extended.trace(function()
		return "self", self
	end)

	if not self._IsAlive then
		return
	end

	self._IsAlive = false

	for k, _CleanUpCallback in self._CleanUpCallbacks do
		local v2 = _CleanUpCallback
		local success, result = pcall(function()
			v2()
		end)

		if not success then
			extended.warn((`clean-up #{k} failed: {result}`))
		end
	end

	if self._CurrentVFXContainer then
		self._CurrentVFXContainer:Destroy()
	end

	if self._VFXContainer ~= self._CurrentVFXContainer then
		self._VFXContainer:Destroy()
	end

	table.clear(self)
	setmetatable(self, {})
end

function class:ConnectUpdateLoop(callback)
	local GUID = HttpService:GenerateGUID(false)
	self._UpdateCallbacks[GUID] = callback
	task.spawn(function()
		callback(self:GetEquippedSkin())
	end)
	return function()
		if self._UpdateCallbacks[GUID] then
			self._UpdateCallbacks[GUID] = nil
		end
	end
end

function class:BindToHandle(instance2)
	local extended = v.extend((`.<{self._VFXContainer and self._VFXContainer.Name}>:BindToHandle`))
	extended.info((`calling fn (instToCleanUp={instance2})`))
	extended.trace(function()
		return "inst", instance2:GetFullName()
	end)
	local connection = CollectionService:GetInstanceRemovedSignal(self._UID):Connect(function()
		self:Destroy()
	end)
	CollectionService:AddTag(instance2, self._UID)
	table.insert(self._CleanUpCallbacks, function()
		extended.trace("cleaning up connection")
		connection:Disconnect()
	end)
end

function class:GetEquippedSkin()
	local extended = v.extend((`:<{self._VFXContainer}>GetEquippedSkin`))
	extended.info("calling fn ()")
	local modification = Modification.Data.Modification.fromItemReplication(self._Player)
	extended.trace(function()
		return "modificationData", Modification.Data.Modification.debug(modification)
	end)
	local adornee = Modification.Data.Adornee.fromItemReplication(self._Player)
	extended.trace(function()
		return "adorneeData", Modification.Data.Adornee.debug(adornee)
	end)
	local preferredModification = Modification.getPreferredModification(self._AdorneeId, "Skin", modification, adornee)
	extended.trace(function()
		local v2 = "equippedItem"

		if preferredModification then
			return v2, ItemConfig.match(preferredModification):unwrap().Index.DebugLabel
		end

		return v2, nil
	end)
	local nullable = Modification.matchDefaultSkin(self._AdorneeId):asNullable()
	extended.trace(function()
		local v2 = "defaultItem"

		if nullable then
			return v2, ItemConfig.match(nullable):unwrap().Index.DebugLabel
		end

		return v2, nil
	end)
	return preferredModification or nullable
end

function class:ApplySkin(p)
	local extended = v.extend((`:<{self._VFXContainer}>ApplySkin`))
	extended.info((`calling fn (rigs={p})`))
	extended.trace(function()
		return "rigs", p
	end)

	if not Modification.matchDefaultSkin(self._AdorneeId):asNullable() then
		extended.trace("skipping apply due to a lack of a default skin")
		return
	end

	local equippedSkin = self:GetEquippedSkin()

	if equippedSkin then
		local nullable = Appearance.match(equippedSkin):asNullable()
		extended.trace(function()
			return "applying definition", nullable
		end)

		if self._CurrentVFXContainer then
			self._CurrentVFXContainer.Parent = nil
			self._CurrentVFXContainer:Destroy()
		end

		local child = self._Player:FindFirstChild(self._VFXContainerName)

		if child then
			child:Destroy()
		end

		local vFXContainer, v2 = createVFXContainer(self._Instance, self._VFXContainerName, nil)

		if v2 then
			local vFXColor = self._Instance:FindFirstChild("VFXColor")
			extended.trace(function()
				local v4

				if vFXColor then
					v4 = vFXColor:GetFullName()
				end

				return (`found vfxTemplate: {v4}`)
			end)
		end

		vFXContainer:SetAttribute("UID", self._UID)
		vFXContainer:SetAttribute("ItemId", equippedSkin)
		pcall(function()
			vFXContainer:SetAttribute("SkinStorageKey", ItemConfig.match(equippedSkin):unwrap().Index.StorageKey)
		end)
		vFXContainer.Parent = self._Player
		self._CurrentVFXContainer = vFXContainer

		if nullable then
			SkinVFX.applyStackedDefinitions(vFXContainer, nullable)
		end

		if not v2 then
			applyPaletteConfig(vFXContainer, self._PaletteConfig, "FillBlanks")
		end
	end

	if p then
		SkinVFX.applySkin(equippedSkin, p)
	end
end

return {
	new = function(instance, adorneeId: number, instance2, vFXContainerName: string, paletteConfig)
		local extended = v.extend((`.<{vFXContainerName}>new`))
		extended.info("calling fn (config)")
		local RunService = game:GetService("RunService")
		assert(RunService:IsServer())
		local vFXContainer = createVFXContainer(instance2, vFXContainerName, paletteConfig)
		local userId = instance.UserId
		local name = instance2.Name
		local HttpService2 = game:GetService("HttpService")
		local v2 = {
			_UID = `{userId}_{name}_{HttpService2:GenerateGUID(false):sub(1, 4)}`,
			_AdorneeId = adorneeId,
			_CleanUpCallbacks = {},
			_UpdateCallbacks = {},
			_VFXContainerName = vFXContainerName,
			_PaletteConfig = paletteConfig,
			_Player = instance,
			_Instance = instance2,
			_VFXContainer = vFXContainer,
			_IsAlive = true
		}
		local object = setmetatable(v2, class)
		table.insert(object._CleanUpCallbacks, function()
			object._VFXContainer:Destroy()
		end)

		for _, child in instance:GetChildren() do
			if child.Name == vFXContainerName then
				child:Destroy()
			end
		end

		object._VFXContainer.Parent = instance
		task.spawn(function()
			object:ApplySkin()
		end)
		table.insert(
			object._CleanUpCallbacks,
			Modification.connectOnModificationEquippedForEquippedAdornee(
				object._Player,
				object._AdorneeId,
				function(p: number?)
					local trace = extended.trace
					local v4

					if p then
						v4 = ItemConfig.match(p):unwrap().Index.DebugLabel or nil
					end

					trace((`changed to {v4}`))

					if Modification.matchAdornee(p):asNullable() ~= object._AdorneeId then
						return
					end

					for _, _UpdateCallback in object._UpdateCallbacks do
						local v5 = _UpdateCallback
						task.spawn(function()
							v5(p)
						end)
					end

					object:ApplySkin({
						[object._Instance] = "InstRoot"
					})
				end,
				nil,
				"Skin"
			)
		)
		local destroyingConnection = object._Instance.Destroying:Connect(function()
			object:Destroy()
		end)
		table.insert(object._CleanUpCallbacks, function()
			destroyingConnection:Disconnect()
		end)
		return object
	end
}