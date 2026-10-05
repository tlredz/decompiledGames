local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(ReplicatedStorage.NPCManager.NPC.Config)
local Expressions = require(ReplicatedStorage.NPCManager.NPC.Expressions)
local Graphics = require(ReplicatedStorage.Util.Graphics)
local NPCInteractionConfig = require(ReplicatedStorage.NPCManager.NPCInteractionConfig)
local LimbFlicker = require(ReplicatedStorage.Util.LimbFlicker)
local Maid = require(ReplicatedStorage.Util.Maid)
local Signal = require(ReplicatedStorage.Modules.Util.Signal)
local State = require(ReplicatedStorage.NPCManager.State)
require(ReplicatedStorage.NPCManager.Types)
local localPlayer = Players.LocalPlayer
local nPCs = workspace:WaitForChild("NPCs")
local smartScale = Graphics.SmartScale
local v = {}
local NPC = {}
NPC.__index = NPC

function v:interactionDisabled()
	local _instance = self._modelState._instance
	return (self._npcInfo._name or _instance.Name) == "Shady Zioles"
end

function v.getInteractionReach(object)
	return object:getModelSize().Magnitude / 2 + NPCInteractionConfig.getLocalCharacterReach()
end

function v.getFaceDecal(instance, flag: boolean)
	local head = instance:FindFirstChild("Head")

	if not head then
		return nil
	end

	local face = head:FindFirstChild("face")

	if face and face:IsA("Decal") then
		return face
	end

	if flag then
		return (head:FindFirstChildWhichIsA("Decal"))
	end

	return nil
end

function v.setFaceId(instance, faceId: string?)
	instance:SetAttribute("FaceId", faceId)
	local v2 = v.getFaceDecal(instance, true)

	if not v2 and faceId then
		local head = instance:FindFirstChild("Head")

		if not head then
			return
		end

		v2 = Instance.new("Decal")
		v2.Name = "face"
		v2.Face = Enum.NormalId.Front
		v2.Parent = head
	end

	if v2 then
		v2.Texture = not faceId and "" or smartScale(faceId)
	end
end

function v.clearClassicClothingTemplate(instance, childName: string, className: string, p: string)
	if not instance:FindFirstChild(childName) then
		return
	end

	local firstChildWhichIsA = instance:FindFirstChildWhichIsA(className)

	if firstChildWhichIsA then
		firstChildWhichIsA[p] = ""
	end
end

function v.renderClassicClothing(instance, childName: string, className: string, attributeName: string)
	local stringValue = instance:FindFirstChild(childName)
	local firstChildWhichIsA = instance:FindFirstChildWhichIsA(className)

	if not (stringValue and stringValue:IsA("StringValue") and firstChildWhichIsA) then
		return
	end

	local attribute = stringValue:GetAttribute(attributeName)
	local color3 = stringValue:GetAttribute("Color3")

	if typeof(attribute) == "string" then
		firstChildWhichIsA[attributeName] = smartScale(attribute)
	end

	if typeof(color3) == "Color3" then
		firstChildWhichIsA.Color3 = color3
	end
end

function v.forEachProxyMesh(instance, callback)
	for _, child in instance:GetChildren() do
		if not (child:IsA("Accessory") or child:IsA("Hat")) then
			continue
		end

		for _, descendant in child:GetDescendants() do
			if descendant.Name ~= "Proxy_SpecialMesh" then
				continue
			end

			local specialMesh = descendant.Parent and descendant.Parent:FindFirstChildWhichIsA("SpecialMesh")

			if specialMesh then
				callback(descendant, specialMesh)
			end
		end
	end
end

function v.forEachNpcLimb(instance, callback)
	for _, part in instance:GetChildren() do
		if not (part:IsA("MeshPart") and table.find(Config.NPC_LIMB_PARTS, part.Name)) then
			continue
		end

		callback(part)
	end
end

function v.derenderClothing(instance)
	v.clearClassicClothingTemplate(instance, "Proxy_Shirt", "Shirt", "ShirtTemplate")
	v.clearClassicClothingTemplate(instance, "Proxy_Pants", "Pants", "PantsTemplate")
	local v2 = instance:GetAttribute("FaceId") and v.getFaceDecal(instance, true)

	if v2 then
		v2.Texture = ""
	end

	v.forEachProxyMesh(instance, function(instance2, p)
		if instance2:GetAttribute("MeshId") then
			p.MeshId = ""
		end

		if instance2:GetAttribute("TextureId") then
			p.TextureId = ""
		end
	end)
	v.forEachNpcLimb(instance, function(p)
		p.TextureID = ""
	end)
end

function v.renderProxyMesh(instance, p)
	local meshId = instance:GetAttribute("MeshId")
	local meshType = instance:GetAttribute("MeshType")
	local offset = instance:GetAttribute("Offset")
	local scale = instance:GetAttribute("Scale")
	local textureId = instance:GetAttribute("TextureId")
	local vertexColor = instance:GetAttribute("VertexColor")

	if typeof(meshId) == "string" then
		p.MeshId = meshId
	end

	if typeof(meshType) == "EnumItem" then
		p.MeshType = meshType
	end

	if typeof(offset) == "Vector3" then
		p.Offset = offset
	end

	if typeof(scale) == "Vector3" then
		p.Scale = scale
	end

	if typeof(textureId) == "string" then
		p.TextureId = smartScale(textureId)
	end

	if typeof(vertexColor) == "Vector3" then
		p.VertexColor = vertexColor
	end
end

function v.renderClothing(instance)
	v.renderClassicClothing(instance, "Proxy_Shirt", "Shirt", "ShirtTemplate")
	v.renderClassicClothing(instance, "Proxy_Pants", "Pants", "PantsTemplate")
	local faceId = instance:GetAttribute("FaceId")
	local faceDecal = v.getFaceDecal(instance, false)

	if typeof(faceId) == "string" and faceDecal then
		faceDecal.Texture = smartScale(faceId)
	end

	v.forEachProxyMesh(instance, v.renderProxyMesh)
	local compositeTextureId = instance:GetAttribute("CompositeTextureId") or ""

	if typeof(compositeTextureId) == "string" then
		v.forEachNpcLimb(instance, function(p)
			p.TextureID = compositeTextureId
		end)
	end
end

function v.fixLimbFlicker(p)
	LimbFlicker.fix(p)
end

function v:setHumanoidHidden(flag: boolean)
	local _currentHumanoid = self._modelState._currentHumanoid

	if not _currentHumanoid then
		return
	end

	local parent

	if flag then
		parent = self._modelState._rootPart
	else
		parent = self._modelState._instance
	end

	_currentHumanoid.Parent = parent
end

function NPC:getIfLoadedInWorld()
	return self:getModel().Parent == nPCs
end

function NPC:getIfInitialized()
	return self._isInitialized
end

function NPC:getModel()
	return self._modelState._instance
end

function NPC:getAnimator()
	if self:getModel():GetAttribute(Config.ANIMATIONS_DISABLED_ATTRIBUTE) == true then
		return nil
	end

	local _currentAnimator = self._modelState._currentAnimator

	if _currentAnimator then
		return _currentAnimator
	end

	local _currentHumanoid = self._modelState._currentHumanoid

	if not _currentHumanoid then
		return nil
	end

	local animator = _currentHumanoid:FindFirstChildOfClass("Animator")

	if animator then
		self._modelState._currentAnimator = animator
		return animator
	end

	local animator2 = Instance.new("Animator")
	animator2.Parent = _currentHumanoid
	self._modelState._currentAnimator = animator2
	return animator2
end

function NPC:getModelSize()
	local _modelState = self._modelState

	if _modelState._modelSize then
		return _modelState._modelSize
	end

	local extentsSize = _modelState._instance:GetExtentsSize()
	local modelSize = extentsSize.Magnitude > 100 and createVector(5, 5, 5) or extentsSize
	_modelState._modelSize = modelSize
	return modelSize
end

function NPC:setCullingState(flag: boolean)
	assert(RunService:IsClient())
	local _instance = self._modelState._instance

	if flag then
		_instance.Parent = nil
		v.setHumanoidHidden(self, true)
		v.derenderClothing(_instance)
	else
		_instance.Parent = nPCs
		v.setHumanoidHidden(self, false)
		v.fixLimbFlicker(_instance)
		v.renderClothing(_instance)
	end
end

function NPC:setExpression(p2)
	local faceId = Expressions.getFaceId(p2, self._defaultFaceId)
	v.setFaceId(self._modelState._instance, faceId)
end

function NPC:setWatching(watching: boolean)
	self._modelState._watching = watching
	self._interactionController:updateWatching(watching)
end

function NPC:getDistanceFromPlayer()
	local _rootPart = self._modelState._rootPart

	if not _rootPart then
		return 1e999
	end

	local character = localPlayer.Character

	if character then
		return (_rootPart.Position - character:GetPivot().Position).Magnitude
	end

	return (_rootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
end

function NPC:onStateUpdate(flag: boolean, p: number)
	local _instance = self._modelState._instance
	local v2 = _instance.Parent ~= nPCs

	if flag ~= v2 then
		self:setCullingState(flag)

		if flag then
			self._signals.Derendered:Fire()
			self._loadedMaid = nil
			self._maid.LoadedMaid = nil
		else
			self._signals.Rendered:Fire()
			self._loadedMaid = Maid.new()
			self._maid.LoadedMaid = self._loadedMaid
		end

		v2 = flag
	end

	if v2 or not self._modelState._rootPart then
		return
	end

	local v3

	if p < 15 + v.getInteractionReach(self) then
		v3 = not _instance:GetAttribute("Stationary")
	else
		v3 = false
	end

	if not self._configAttributes.IgnoreWatch and self._modelState._watching ~= v3 then
		self:setWatching(v3)
	end

	local _currentHumanoid = self._modelState._currentHumanoid
	local interactable

	if _currentHumanoid == nil then
		interactable = false
	else
		interactable = _currentHumanoid:IsA("AnimationController") or _currentHumanoid.Health > 0
	end

	interactable = not v.interactionDisabled(self)

	if interactable then
		if p < self:getInteractionRange() then
			interactable = not _instance:GetAttribute("LockedInteraction")
		else
			interactable = false
		end
	end

	self._interactable = interactable

	if rawequal(State.ClosestNPC, self) then
		local Global = require(ReplicatedStorage.Global)
		Global.tapCooldown = os.clock() + 0.3333333333333333 + 0.016666666666666666
	end
end

function NPC:onInteractableStateChanged(flag: boolean)
	local _instance = self._modelState._instance
	local _interactionController = self._interactionController
	local GUI = _interactionController._entry.GUI
	local enabled = flag and not v.interactionDisabled(self)
	GUI.BG.Enabled = enabled

	if enabled then
		GUI.BusyLock:Unlock("_General")

		if GUI.InteractionLock:Get():IsLocked() or _instance:GetAttribute("NoAura") or self._npcInfo.NoAura then
			Config.Highlight.Adornee = nil
			return
		end

		local info = _interactionController._entry.Info

		if not info then
			Config.Highlight.Adornee = nil
			return
		end

		local lerped = info.Color:Lerp(Color3.new(1, 1, 1), 0.3333333333333333)
		Config.Highlight.Adornee = _instance
		Config.Highlight.FillColor = lerped
		Config.Highlight.OutlineColor = lerped
	else
		GUI.BusyLock:Lock("_General")

		if Config.Highlight.Adornee == _instance then
			Config.Highlight.Adornee = nil
		end
	end
end

function NPC:onLODUpdate(cframe: CFrame)
	local _instance = self._modelState._instance
	local magnitude = (cframe.Position - _instance:GetPivot().Position).Magnitude
	self:onStateUpdate(
		_instance:GetAttribute(Config.HIDDEN_ATTRIBUTE) == true or (self._npcInfo.CullingDistance or Config.CullingDistance) < magnitude,
		magnitude
	)
	return magnitude
end

function NPC:getIfInteractable()
	return self._interactable
end

function NPC:getInteractionRange()
	return 1 + v.getInteractionReach(self)
end

function NPC.getIfStagesOwnDialogue(_)
	return false
end

function NPC:onTick(cframe: CFrame)
	if self._isInitialized and not self._modelState._instance:GetAttribute("Destroyed") then
		return self:onLODUpdate(cframe)
	end

	return nil
end

function NPC:getDialogue()
	local dialogueCallback = self._npcInfo.DialogueCallback

	if dialogueCallback then
		return dialogueCallback()
	end

	return nil
end

function NPC:playAction(name)
	local animator = self:getAnimator()

	if not animator then
		return
	end

	local action = Config.Actions[name]

	if not action then
		warn((`No animation found for action: {name}`))
		return
	end

	local v2 = animator:FindFirstChild(name)

	if not (v2 and v2:IsA("Animation")) then
		v2 = Instance.new("Animation")
		v2.Name = name
		v2.AnimationId = `rbxassetid://{action}`
		v2.Parent = animator
	end

	animator:LoadAnimation(v2):Play()
end

function NPC.onDialogueStarted(_) end

function NPC.onDialogueLine(_, _, _) end

function NPC.onDialogueEnded(_) end

function NPC.extend(className: string)
	local self = setmetatable({}, {
		__index = NPC
	})
	self.__index = self
	self._className = className
	return self
end

NPC.initializeNPC = require(ReplicatedStorage.NPCManager.NPC.NPCInitialization)

function NPC.new(npcInfo, instance)
	local faceId = instance:GetAttribute("FaceId")
	local v2 = {
		_npcInfo = npcInfo,
		_loadedMaid = Maid.new(),
		_maid = Maid.new(),
		_interactable = false,
		_isInitialized = false,
		_interactionController = nil,
		_configAttributes = {},
		_defaultFaceId = 0,
		_modelState = 0,
		_signals = 0
	}

	if typeof(faceId) ~= "string" then
		faceId = nil
	end

	v2._defaultFaceId = faceId
	v2._modelState = {
		_instance = instance,
		_currentAnimator = nil,
		_currentHumanoid = nil,
		_targetLocation = instance:GetPivot(),
		_rootPart = nil,
		_watching = false,
		_modelSize = nil
	}
	v2._signals = {
		Rendered = Signal.new(),
		Derendered = Signal.new()
	}
	local nPCConfig = instance:FindFirstChild("NPCConfig")
	v2._configAttributes = not nPCConfig and {} or nPCConfig:GetAttributes()

	for k, v3 in npcInfo do
		v2._configAttributes[k] = v3
	end

	if npcInfo.DisplayName then
		instance:SetAttribute("DisplayName", npcInfo.DisplayName)
	end

	if npcInfo.DisableAnimations then
		instance:SetAttribute(Config.ANIMATIONS_DISABLED_ATTRIBUTE, true)
	end

	v2._maid.LoadedMaid = v2._loadedMaid
	return (setmetatable(v2, NPC))
end

return NPC