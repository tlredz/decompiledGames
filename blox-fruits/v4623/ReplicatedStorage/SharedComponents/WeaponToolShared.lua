local createVector = vector.create
local RunService = game:GetService("RunService")
local Component = require(game.ReplicatedStorage.Modules.Component)
local GetPlayer = require(game.ReplicatedStorage.Modules.Player.GetPlayer)
local CombatUtil = require(game.ReplicatedStorage.Modules.CombatUtil)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local Net = require(game.ReplicatedStorage.Modules.Net)
local Flags = require(game.ReplicatedStorage.Modules.Flags)
local IsNewCombatSystemEnabled = require(game.ReplicatedStorage.Modules.Extensions.IsNewCombatSystemEnabled)
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local localPlayer = game.Players.LocalPlayer
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()
local mobBackpacks = game.ReplicatedStorage:WaitForChild("MobBackpacks")
local v7 = nil
local v8 = RunService:IsStudio() and false
local gatlingDebug = script.GatlingDebug
local v9 = {}
local v10 = {}
task.defer(function()
	if isServer then
		local CombatService = require(game.ServerScriptService.Services.CombatService)
		v2 = CombatService
		local RobloxAnalytics = require(game.ServerScriptService.Services.RobloxAnalytics)
		v4 = RobloxAnalytics
		local WeaponToolServer = require(game.ServerScriptService.ServerComponents.WeaponToolServer)
		v5 = WeaponToolServer
	else
		local CombatController = require(game.ReplicatedStorage.Controllers.CombatController)
		v = CombatController
		local CustomCursor = require(game.ReplicatedStorage.Controllers.UI.CustomCursor)
		v3 = CustomCursor
	end

	v10.VisualEquippedEvent = Net:RemoteEvent("VisualEquipped")
	v10.VisualUnequippedEvent = Net:RemoteEvent("VisualUnequipped")
	local Util = require(game.ReplicatedStorage.Util)
	v6 = Util
end)
local v11 = {
	ShouldConstruct = function(p)
		local instance = p.Instance

		if instance:IsDescendantOf(workspace.Enemies) then
			return false
		end

		return instance:GetAttribute("OwnerId") == localPlayer.UserId
	end
}
local extensions = { IsNewCombatSystemEnabled }

if isClient then
	table.insert(extensions, v11)
end

local v13 = Component.new({
	Tag = "WeaponTool",
	Ancestors = { workspace, game.Players, mobBackpacks },
	Extensions = extensions
})

local function getScale(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local hrpSizeScale = humanoidRootPart:GetAttribute("HrpSizeScale")
		return (math.max(
			humanoidRootPart.Size.Magnitude / (createVector(2, 2, 1)).Magnitude * (hrpSizeScale and hrpSizeScale.Y or 1),
			1
		))
	else
		return 1
	end
end

function v13:_waitToEquip()
	return task.defer(function()
		local char = self.char
		local weaponName = self.weaponName
		local v14 = true
		local total = 0

		while char:IsDescendantOf(workspace) and v14 do
			local attackingWeaponName = char:GetAttribute("AttackingWeaponName")
			v14 = attackingWeaponName and attackingWeaponName ~= weaponName
			total += task.wait()

			if not (total > 20) then
				continue
			end

			local Global = require(game.ReplicatedStorage.Global)
			Global.TestGameWarn("waiting really long time on _waitToEquip")
		end

		if char:IsDescendantOf(workspace) and self.Instance.Parent then
			self:_attachEquippedPose()
		end
	end)
end

function v13:_waitToUnequip()
	task.spawn(function()
		local char = self.char
		local weaponName = self.weaponName
		local v14 = true

		while char:IsDescendantOf(workspace) and v14 do
			v14 = char:GetAttribute("AttackingWeaponName") == weaponName
			task.wait()
		end

		if char:IsDescendantOf(workspace) and self.Instance.Parent then
			self:_attachUnequippedPose()
		end
	end)
end

function v13:_waitToEquipOrUnequip()
	task.spawn(function()
		self.waitingToEquipOrUnequip = true
		local char = self.char

		while char:IsDescendantOf(workspace) do
			local Global = require(game.ReplicatedStorage.Global)

			if not Global.busy then
				break
			end

			task.wait()
		end

		if char:IsDescendantOf(workspace) then
			self.equipEvent:FireServer(self.isEquipped)

			if self.isEquipped then
				self:_attachEquippedPose()
			else
				self:_attachUnequippedPose()
			end
		end

		self.waitingToEquipOrUnequip = false
	end)
end

function v13:_replicateEquipAnimation()
	local equipAnimation = self.weaponData.EquipAnimation

	if equipAnimation and equipAnimation.Equip then
		local _ = self.Instance
		local _ = self.char:GetPivot().Position
		local equippedModel = self.equippedModel

		if self.player and isServer then
			v2:RegisterEquipAnimation(self.player, equippedModel, equipAnimation.Equip)
		end
	end
end

function v13:_replicateUnequipAnimation() end

function v13:_clearModel(p)
	local v14 = p == "Equipped" and "equippedModel" or "unequippedModel"
	local v15 = self[v14]

	if v15 then
		v15:Destroy()

		for _, motor in self.motors do
			motor:Destroy()
		end

		self.motors = {}
		self[v14] = nil
		local v16 = (isClient and "Local" or "Server") .. (p == "Equipped" and "EquippedWeapon" or "UnequippedWeapon") .. "Pointer"
		local child = self.Instance:FindFirstChild(v16)

		if child then
			child.Value = nil
		end
	end
end

function v13:_rescaleTool(p)
	local char = self.char
	local equippedModel = p == "Equipped" and self.equippedModel or self.unequippedModel
	local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
	local v14

	if humanoidRootPart then
		local hrpSizeScale = humanoidRootPart:GetAttribute("HrpSizeScale")
		v14 = math.max(
			humanoidRootPart.Size.Magnitude / (createVector(2, 2, 1)).Magnitude * (hrpSizeScale and hrpSizeScale.Y or 1),
			1
		)
	else
		v14 = 1
	end

	for _, model in equippedModel:GetDescendants() do
		if not (model:IsA("Model") and typeof(model:GetAttribute("OriginalScale")) ~= "number") then
			continue
		end

		model:SetAttribute("OriginalScale", model:GetScale())
	end

	equippedModel:ScaleTo(v14)

	for _, model in equippedModel:GetDescendants() do
		if model:IsA("Model") then
			model:ScaleTo(model:GetAttribute("OriginalScale") * v14)
		end
	end

	if isClient then
		for _, part in equippedModel:GetDescendants() do
			if not (part:IsA("BasePart") and part:HasTag("SmartBone")) then
				continue
			end

			part:RemoveTag("SmartBone")
			local v15 = part
			task.defer(function()
				if v15.Parent then
					v15:AddTag("SmartBone")
				end
			end)
		end
	end

	for _, motor in self.motors do
		local parent = motor.Part1.Parent
		local v15 = v9[self.Instance.Name][p][parent.Name]
		motor.C0 = v15.Rotation + v15.Position * v14
	end

	local skullGuitar_WeaponWeldRightEquipped = (char:HasTag("TransformedAwakenedBuddha") or char:HasTag("TransformedBuddha")) and self.motors.SkullGuitar_WeaponWeldRightEquipped

	if skullGuitar_WeaponWeldRightEquipped then
		skullGuitar_WeaponWeldRightEquipped.C1 = char:HasTag("TransformedAwakenedBuddha") and CFrame.new(-10, 12, -4) or CFrame.new(
			-4.5,
			5.5,
			-1.8
		)
	end
end

function v13:_attachUnequippedPose()
	local instance = self.Instance
	local char = self.char

	if self.weaponType == "Melee" then
		for _, part in char:GetChildren() do
			if not part:IsA("BasePart") then
				continue
			end

			part:RemoveTag("WeaponHitbox")
			part:RemoveTag("Blade")
		end
	end

	self:_clearModel("Equipped")
	self:_clearModel("Unequipped")
	local model = Instance.new("Model")
	model.Name = "UnequippedWeapon"
	model:SetAttribute("WeaponName", self.weaponName)
	model:SetAttribute("IsWeapon", true)
	model:SetAttribute("Enchant", instance:GetAttribute("Enchant"))
	model:AddTag("WeaponBack")

	for _, descendant in model:GetDescendants() do
		descendant:RemoveTag("WeaponHitbox")
		descendant:RemoveTag("Blade")
	end

	if isClient then
		model:SetAttribute("IsLocal", true)
	elseif isServer then
		local modelStreamingMode

		if Flags.ATOMIC_ENEMIES then
			modelStreamingMode = Enum.ModelStreamingMode.Atomic
		else
			modelStreamingMode = Enum.ModelStreamingMode.Persistent
		end

		model.ModelStreamingMode = modelStreamingMode
	end

	model.Parent = char
	self.unequippedModel = model
	self:_attachToChar("Unequipped")

	if self.player then
		if isServer then
			v10.VisualUnequippedEvent:FireClient(self.player, instance)
		else
			v:Unequip(instance)
		end
	end

	if isServer then
		local v14 = v5:FromInstance(self.Instance)

		if self.weaponData.Name == "BizarreRevolver" and v14.ShotsLeft < v14.weaponData.MagSize then
			instance:SetAttribute("UnequipAutoReloading", true)
			task.delay(self.weaponData.ShootInterval, function()
				if instance.Parent then
					v14.ShotsLeft = v14.weaponData.MagSize
					instance:SetAttribute("UnequipAutoReloading", nil)
				end
			end)
		end
	end

	self:_replicateUnequipAnimation()
end

function v13:_attachEquippedPose()
	local instance = self.Instance

	if self.weaponType == "Melee" then
		for _, childName in self.weaponData.HitboxLimbs do
			local child = self.char:FindFirstChild(childName)

			if not child then
				continue
			end

			child:AddTag("WeaponHitbox")
			child:AddTag("Blade")
		end
	end

	self:_clearModel("Equipped")
	self:_clearModel("Unequipped")
	local model = Instance.new("Model")
	model.Name = "EquippedWeapon"
	model:SetAttribute("WeaponName", self.weaponName)
	model:SetAttribute("WeaponType", self.weaponType)
	model:SetAttribute("IsWeapon", true)
	model:SetAttribute("Enchant", instance:GetAttribute("Enchant"))
	model:SetAttribute("DisableBusoAura", instance:GetAttribute("DisableBusoAura"))
	model:AddTag("Weapon")

	if self.weaponType == "Gun" then
		if self.weaponData.ShootType == "HitscanBurst" then
			model:SetAttribute("CurrentShootAttachment", "ShootAttachment1")
		else
			model:SetAttribute("CurrentShootAttachment", "ShootAttachment")
		end
	end

	if isClient then
		model:SetAttribute("IsLocal", true)
	elseif isServer then
		local modelStreamingMode

		if Flags.ATOMIC_ENEMIES then
			modelStreamingMode = Enum.ModelStreamingMode.Atomic
		else
			modelStreamingMode = Enum.ModelStreamingMode.Persistent
		end

		model.ModelStreamingMode = modelStreamingMode
	end

	model.Parent = self.char
	self.equippedModel = model
	self:_attachToChar("Equipped")

	if self.player then
		if isServer then
			v10.VisualEquippedEvent:FireClient(self.player, self.Instance)
		else
			v:Equip(self.Instance)
		end
	end

	self:_replicateEquipAnimation()
end

function v13:_attachToChar(childName)
	local instance = self.Instance
	local char = self.char
	local v14 = childName == "Equipped"
	local equippedModel = v14 and self.equippedModel or self.unequippedModel
	instance[(isClient and "Local" or "Server") .. (v14 and "EquippedWeapon" or "UnequippedWeapon") .. "Pointer"].Value = equippedModel
	local objectValue = Instance.new("ObjectValue")
	objectValue.Name = "ToolPointer"
	objectValue.Value = instance
	objectValue.Parent = equippedModel

	if isClient then
		local configuration = Instance.new("Configuration")
		configuration.Name = "IsLocal"
		configuration.Parent = equippedModel
	end

	local weaponDummy = self.weaponDummy
	local child = weaponDummy and weaponDummy:FindFirstChild(childName)

	if not child then
		return
	end

	for _, motor in self.motors do
		motor:Destroy()
	end

	self.motors = {}
	local templateWeapon = self.templateWeapon
	local weaponModelOverride = instance:GetAttribute("WeaponModelOverride")

	if typeof(weaponModelOverride) == "string" and weaponModelOverride ~= "" and self.assetCache then
		local v15 = "TemplateWeapon_" .. weaponModelOverride
		local child2 = self.assetCache:FindFirstChild(v15)

		if not child2 and isClient then
			child2 = self.assetCache:WaitForChild(v15, 1)
		end

		if child2 then
			templateWeapon = child2
		else
			warn("[Weapon Skin] Missing cached override template:", v15, self.assetCache:GetFullName())
		end
	end

	local v15 = child:FindFirstChild(instance.Name) or child:FindFirstChild("Tool") or child:FindFirstChildWhichIsA("Model")

	for _, folder in templateWeapon:GetChildren() do
		if not (folder:IsA("Folder") and folder.Name ~= "InitialPoses") then
			continue
		end

		local weldTo = v15[folder.Name]:GetAttribute("WeldTo")

		if not weldTo then
			continue
		end

		local child2 = char:FindFirstChild(weldTo)

		if not child2 then
			continue
		end

		local clone = folder:Clone()
		local transparency = v14 and 1 or 0

		for _, part in clone:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			if part.Name == "Hidden" or part.Parent.Name == "Hidden" then
				part.Transparency = transparency
			end

			part:SetAttribute("OriginalTransparency", part.Transparency)
		end

		local handle = clone.Handle
		local equippedAttachmentName = self.weaponData.EquippedAttachmentName

		if typeof(equippedAttachmentName) == "table" then
			equippedAttachmentName = equippedAttachmentName[weldTo]
		end

		local motor6D = Instance.new("Motor6D")
		motor6D:SetAttribute("WeaponName", self.weaponName)
		motor6D:SetAttribute("IsLocal", isClient)
		motor6D.Name = equippedAttachmentName or string.format(
			"%s_WeaponWeld%s%s",
			self.weaponName,
			folder.Name,
			v14 and "Equipped" or "Unequipped"
		)
		motor6D.Part0 = child2

		if equippedAttachmentName then
			handle = clone:FindFirstChild(equippedAttachmentName) or handle
		end

		motor6D.Part1 = handle
		motor6D.Parent = motor6D.Part0
		motor6D:SetAttribute("IgnoreScale", true)
		self.motors[motor6D.Name] = motor6D
		clone.Parent = equippedModel
	end

	self:_rescaleTool(childName)
end

if isServer then
	Net:RemoteEvent("PrepareWeaponPreviewModel").OnServerEvent:Connect(function(p, name)
		assert(typeof(name) == "string")
		local parent = p.PlayerGui:FindFirstChild("PreviewWeaponAssetCache")

		if not parent then
			parent = Instance.new("Folder")
			parent.Name = "PreviewWeaponAssetCache"
			parent.Parent = p.PlayerGui
		end

		if not parent:FindFirstChild(name) then
			local clone = CombatUtil:GetWeaponModel(game.ServerStorage.WeaponsFolder, name):Clone()
			clone.Name = name
			clone.Parent = parent
		end
	end)
end

function v13:_cacheWeaponModelOverride()
	if not isServer then
		return
	end

	local weaponModelOverride = self.Instance:GetAttribute("WeaponModelOverride")

	if typeof(weaponModelOverride) ~= "string" or weaponModelOverride == "" or not self.assetCache then
		return
	end

	local name = "TemplateWeapon_" .. weaponModelOverride

	if self.assetCache:FindFirstChild(name) then
		return
	end

	local weaponModel = CombatUtil:GetWeaponModel(game.ServerStorage.WeaponsFolder, weaponModelOverride)

	if not weaponModel then
		warn("[Weapon Skin Cache] Missing weapon skin model:", weaponModelOverride, "for", self.weaponName)
		return
	end

	local clone = weaponModel:Clone()
	clone.Name = name
	clone.Parent = self.assetCache
	print("[Weapon Skin Cache] cached", weaponModelOverride, "for", self.weaponName)
end

function v13:Construct()
	self.trove = Trove.new()
	task.wait(0.1)
	local instance = self.Instance
	local player = GetPlayer(instance)

	if player then
		self.trove:Add(player:GetPropertyChangedSignal("Character"):Once(function()
			task.wait()
			self.char = player.Character
		end))
	end

	local character = player and player.Character or instance.Parent
	self.player = player
	self.char = character
	self.humanoid = character:FindFirstChildWhichIsA("Humanoid")
	character:IsDescendantOf(workspace.Enemies)
	local weaponName = CombatUtil:GetWeaponName(instance)
	self.weaponName = weaponName
	self.weaponData = CombatUtil:GetWeaponData(weaponName)
	self.weaponType = self.weaponData.WeaponType
	self.isGatling = self.weaponData.ShootStyle == "Gatling"
	self.motors = {}

	for _, v15 in { "EquippedWeaponPointer", "UnequippedWeaponPointer" } do
		local objectValue = Instance.new("ObjectValue")
		objectValue.Name = (isServer and "Server" or "Local") .. v15
		objectValue.Parent = instance
	end

	local weaponModel = isServer and CombatUtil:GetWeaponModel(game.ServerStorage.WeaponsFolder, weaponName)

	if self.player then
		local weaponAssetCache = self.player.PlayerGui:WaitForChild("WeaponAssetCache")

		if isServer then
			local remoteEvent = Instance.new("RemoteEvent")
			remoteEvent.Name = "EquipEvent"
			remoteEvent.Parent = instance
			self.equipEvent = remoteEvent
			self.trove:Add(remoteEvent)
			local folder = Instance.new("Folder")
			folder.Name = weaponName
			local clone = weaponModel:Clone()
			clone.Name = "TemplateWeapon"
			clone.Parent = folder
			self.templateWeapon = clone

			if self.weaponData.WeaponDummy then
				local clone2 = self.weaponData.WeaponDummy:Clone()
				clone2.Name = "WeaponDummy"
				clone2.Parent = folder
				self.weaponDummy = clone2
			else
				local folder2 = Instance.new("Folder")
				folder2.Name = "WeaponDummy"
				folder2.Parent = folder
				self.weaponDummy = folder2
			end

			folder.Parent = weaponAssetCache
			self.assetCache = folder
			self:_cacheWeaponModelOverride()
			self.trove:Add(folder)
		else
			self.assetCache = weaponAssetCache:WaitForChild(weaponName)
			self.templateWeapon = self.assetCache:WaitForChild("TemplateWeapon")
			self.weaponDummy = self.assetCache:WaitForChild("WeaponDummy")
			self.equipEvent = instance:WaitForChild("EquipEvent")
		end
	else
		self.weaponDummy = self.weaponData.WeaponDummy
		self.templateWeapon = weaponModel
	end

	if self.weaponDummy and not v9[instance.Name] then
		v9[instance.Name] = {
			Equipped = {},
			Unequipped = {}
		}

		for _, childName in { "Equipped", "Unequipped" } do
			local child = self.weaponDummy:FindFirstChild(childName)

			if not child then
				continue
			end

			local v15 = child:FindFirstChild(weaponName) or child:FindFirstChild("Tool") or child:FindFirstChildWhichIsA("Model")

			if not v15 then
				warn(string.format("WeaponDummy for %s.%s is missing the weapon model", weaponName, childName))
			end

			for _, folder in self.templateWeapon:GetChildren() do
				if not (folder:IsA("Folder") and folder.Name ~= "InitialPoses") then
					continue
				end

				local v16 = v15[folder.Name]
				local weldTo = v16:GetAttribute("WeldTo")

				if not (folder:IsA("Folder") and weldTo and weldTo ~= "" and child:FindFirstChild(weldTo)) then
					continue
				end

				local _ = folder.Handle
				local v17 = child[weldTo]
				local handle = v16.Handle
				local v18 = v17.CFrame:Inverse() * handle.CFrame
				v9[instance.Name][childName][folder.Name] = v18
			end

			local RunService2 = game:GetService("RunService")

			if not RunService2:IsClient() then
				continue
			end

			for _, folder in v15:GetChildren() do
				if not folder:IsA("Folder") then
					continue
				end

				for _, child2 in folder:GetChildren() do
					child2:Destroy()
				end
			end

			for _, child2 in child:GetChildren() do
				if child2 ~= v15 then
					child2:Destroy()
				end
			end
		end
	end
end

function v13:Start()
	local instance = self.Instance
	local isDescendant = instance:IsDescendantOf(workspace.Enemies)
	self.isEquipped = false
	self.trove:Add(instance:GetAttributeChangedSignal("WeaponModelOverride"):Connect(function()
		task.defer(function()
			if not (self.char and self.char.Parent) then
				return
			end

			if isServer then
				self:_cacheWeaponModelOverride()
			end

			if self.isEquipped then
				self:_attachEquippedPose()
			else
				self:_attachUnequippedPose()
			end
		end)
	end))

	local function sizeChanged()
		local v14 = self.isEquipped and "Equipped" or "Unequipped"

		if self.isEquipped and self.equippedModel or self.unequippedModel then
			self:_rescaleTool(v14)
		end
	end

	self.trove:Add(self.char:WaitForChild("HumanoidRootPart"):GetPropertyChangedSignal("Size"):Connect(sizeChanged))

	local function unequipAllTools()
		for _, tool in self.player.Backpack:GetChildren() do
			if not (tool:IsA("Tool") and (tool.ToolTip == "Melee" or tool.ToolTip == "Sword" or tool.ToolTip == "Gun" or tool.ToolTip == "Blox Fruit")) then
				continue
			end

			instance.Parent = self.player.Backpack
		end

		local tool = self.char:FindFirstChildWhichIsA("Tool")

		if tool then
			tool.Parent = self.player.Backpack
		end
	end

	if self.player then
		self.trove:Add(self.humanoid.Seated:Connect(function(seated, _)
			self._seated = seated

			if seated and isServer then
				v6.ServerWait()
				unequipAllTools()
			end
		end))
	end

	if isDescendant then
		local _ = self.weaponName .. "-idle"
		local moveset = self.weaponData.Moveset
		local idle = moveset.Idle or moveset.RelaxedIdle or moveset.Actions and moveset.Actions.Idle
		local v14

		if idle then
			v14 = v6.Anims:Get(self.char, idle.AnimationId)
			v14.Looped = true
			v14.Priority = Enum.AnimationPriority.Idle
			self.trove:Add(function()
				v14:Stop()
			end)
		else
			v14 = nil
		end

		local function reflectMobEquipped()
			if not instance.Parent then
				return
			end

			self.isEquipped = self.char:GetAttribute("Equipped")
			CombatUtil:ToggleLoadMovesetAnims(self.humanoid, self.weaponData, self.isEquipped)

			if self.isEquipped then
				instance.Parent = self.char

				if v14 then
					local v15 = 1 * (idle.SpeedMult or 1)
					v14:Play(0.100000001, 1, v15)
				end

				self:_attachEquippedPose()
			else
				instance.Parent = mobBackpacks

				if v14 then
					v14:Stop()
				end

				self:_attachUnequippedPose()
			end
		end

		reflectMobEquipped()
		self.trove:Add(self.char:GetAttributeChangedSignal("Equipped"):Connect(reflectMobEquipped))
		self.trove:Add(self.char.AncestryChanged:Connect(function(_, parent)
			if not parent and instance.Parent == mobBackpacks then
				instance:Destroy()
			end
		end))
	elseif isClient then
		local function reflectEquipped()
			if not instance.Parent then
				return
			end

			local isEquipped = false

			for _, tool in self.char:GetChildren() do
				if not (tool.Name == instance.Name and tool:IsA("Tool")) then
					continue
				end

				isEquipped = true
				break
			end

			self.isEquipped = isEquipped

			if self.isEquipped and self._seated then
				self.isEquipped = false
				task.wait()
				unequipAllTools()
			else
				local Global = require(game.ReplicatedStorage.Global)

				if Global.busy then
					if not self.waitingToEquipOrUnequip then
						self:_waitToEquipOrUnequip()
					end
				else
					if v7 then
						task.cancel(v7)
						v7 = nil
						local Global2 = require(game.ReplicatedStorage.Global)

						if Global2.busy then
							return
						end
					end

					self.equipEvent:FireServer(self.isEquipped)

					if self.isGatling and v8 then
						if self.isEquipped and self.weaponData.ShootStyle == "Gatling" then
							gatlingDebug.Parent = localPlayer.PlayerGui
						else
							gatlingDebug.Parent = script
						end
					end

					if self.isEquipped then
						local Global2 = require(game.ReplicatedStorage.Global)

						if Global2.busy then
							v7 = self:_waitToEquip()
						else
							self:_attachEquippedPose()
						end
					else
						local Global2 = require(game.ReplicatedStorage.Global)

						if Global2.busy then
							self:_waitToUnequip()
						else
							self:_attachUnequippedPose()
						end
					end
				end
			end
		end

		reflectEquipped()
		self.trove:Add(instance.Equipped:Connect(reflectEquipped))
		self.trove:Add(instance.Unequipped:Connect(reflectEquipped))

		if self.isGatling then
			local overheatLimit = self.weaponData.OverheatLimit

			-- equivalent calls inferred from this helper; original call sites unknown
			local function reflectOverheat()
				if instance:GetAttribute("LocalOverheat") then
					v3:UpdateOverheatBar(instance:GetAttribute("LocalOverheat") / overheatLimit)
				end
			end

			reflectOverheat() -- equivalent call inferred; original call site unknown
			self.trove:Add(instance:GetAttributeChangedSignal("LocalOverheat"):Connect(reflectOverheat))
			self.trove:Add(instance:GetAttributeChangedSignal("Overheat"):Connect(reflectOverheat))
		end
	elseif isServer then
		local function toggleEquip(p, isEquipped)
			if typeof(isEquipped) ~= "boolean" or p ~= self.player then
				return
			end

			self.isEquipped = isEquipped

			if self.isEquipped then
				if self.char.Busy.Value then
					v7 = self:_waitToEquip()
				else
					self:_attachEquippedPose()
				end
			elseif self.char.Busy.Value then
				self:_waitToUnequip()
			else
				self:_attachUnequippedPose()
			end
		end

		self.equipEvent.OnServerEvent:Connect(toggleEquip)
	end
end

function v13:Stop()
	local char = self.char
	local weaponName = self.weaponName
	self.trove:Destroy()
	self.trove = nil
	local Global = require(game.ReplicatedStorage.Global)
	Global.busy = nil
	local Global2 = require(game.ReplicatedStorage.Global)
	Global2.tapCooldown = os.clock()
	task.defer(function()
		local v14 = true

		while char:IsDescendantOf(workspace) and v14 do
			v14 = char:GetAttribute("AttackingWeaponName") == weaponName
			task.wait()
		end

		if char:IsDescendantOf(workspace) then
			self:_clearModel("Equipped")
			self:_clearModel("Unequipped")
		end

		if self.player and isServer then
			v10.VisualUnequippedEvent:FireClient(self.player, self.Instance)
		end
	end)
end

return v13