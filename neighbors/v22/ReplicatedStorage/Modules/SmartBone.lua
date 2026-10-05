local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local components = script:WaitForChild("Components")
local dependencies = script:WaitForChild("Dependencies")
local ImOverlay = require(dependencies:WaitForChild("Debug"):WaitForChild("ImOverlay"))
local Config = require(dependencies:WaitForChild("Config"))
local Frustum = require(dependencies:WaitForChild("Frustum"))
local Utilities = require(dependencies:WaitForChild("Utilities"))
local v = nil
local Bone = require(components:WaitForChild("Bone"))
local BoneTree = require(components:WaitForChild("BoneTree"))
local ColliderObject = require(components:WaitForChild("Collision"):WaitForChild("ColliderObject"))
local runtime = dependencies:WaitForChild("Runtime")

-- equivalent calls inferred from this helper; original call sites unknown
local function CopyPasteAttributes(parent, bone)
	for k, v2 in parent:GetAttributes() do
		bone:SetAttribute(k, v2)
	end
end

local SB_INDENT_LOG = Utilities.SB_INDENT_LOG
local SB_UNINDENT_LOG = Utilities.SB_UNINDENT_LOG
local SB_VERBOSE_LOG = Utilities.SB_VERBOSE_LOG
local SB_VERBOSE_WARN = Utilities.SB_VERBOSE_WARN
local SmartBone = {}
SmartBone.__index = SmartBone

function SmartBone.new()
	return (setmetatable({
		ID = HttpService:GenerateGUID(false),
		BoneTrees = {},
		ColliderObjects = {},
		ShouldDestroy = false
	}, SmartBone))
end

function SmartBone:m_AppendBone(data, p, parentIndex: number, heirarchyLength: number)
	local boneSettings = Utilities.GatherBoneSettings(p)
	local boneSettings2 = Bone.new(p, data.Root, data.RootPart)

	for k, boneSetting in boneSettings do
		if boneSetting == "¬" or not boneSetting then
			boneSetting = nil
		end

		boneSettings2[k] = boneSetting
	end

	local bone = data.Bones[parentIndex]

	if parentIndex > 0 then
		local magnitude = (bone.Position - boneSettings2.Position).Magnitude
		boneSettings2.FreeLength = magnitude
		boneSettings2.Weight = magnitude * 0.7
		boneSettings2.HeirarchyLength = heirarchyLength
		bone.HasChild = true
	end

	if heirarchyLength <= data.Settings.AnchorDepth then
		SB_VERBOSE_LOG("Anchoring bone")
		boneSettings2.Anchored = true
	end

	boneSettings2.ParentIndex = parentIndex
	table.insert(data.Bones, boneSettings2)
end

function SmartBone:m_CreateBoneTree(p, p2)
	local v2 = BoneTree.new(p2, p, Utilities.GatherObjectSettings(p))
	SB_VERBOSE_LOG((`Creating bone tree {p.Name}; {p2.Name}`))
	SB_INDENT_LOG()
	local AddChildren

	AddChildren = function(parent, p3, p4)
		SB_VERBOSE_LOG((`Adding bone: {parent.Name}; {p3}; {p4}`))
		SB_INDENT_LOG()
		local children = parent:GetChildren()
		local v3 = false

		for _, bone in children do
			if not bone:IsA("Bone") then
				continue
			end

			self:m_AppendBone(v2, bone, p3, p4)
			AddChildren(bone, #v2.Bones, p4 + 1)
			v3 = true
		end

		if string.sub(parent.Name, #parent.Name - 3, #parent.Name) ~= "_end" and string.sub(
			parent.Name,
			#parent.Name - 4,
			#parent.Name
		) ~= "_Tail" and not v3 then
			SB_VERBOSE_LOG("Adding tail bone")
			local parent2 = parent.Parent
			local worldPosition = parent2:IsA("Bone") and parent2.WorldPosition or parent2.Position
			local worldCFrame = parent.WorldCFrame + parent.WorldCFrame.UpVector.Unit * (parent.WorldPosition - worldPosition).Magnitude
			local bone = Instance.new("Bone")
			bone.Parent = parent
			bone.Name = parent.Name .. "_Tail"
			bone.WorldCFrame = worldCFrame
			CopyPasteAttributes(parent, bone) -- equivalent call inferred; original call site unknown
			self:m_AppendBone(v2, bone, #v2.Bones, p4)
		end

		SB_UNINDENT_LOG()
	end

	self:m_AppendBone(v2, p2, 0, 0)
	AddChildren(p2, 1, 1)
	table.insert(self.BoneTrees, v2)
	SB_UNINDENT_LOG()
end

function SmartBone:m_UpdateViewFrustum()
	if shared.FrameCounter % Config.FRUSTUM_FREQ ~= 0 then
		return
	end

	local cFrames, v2, v3, v4, v5, v6, v7, v8, v9 = Frustum.GetCFrames(workspace.CurrentCamera, Config.FAR_PLANE)

	for _, boneTree in self.BoneTrees do
		local v10 = {
			CFrame = boneTree.BoundingBoxCFrame,
			Size = boneTree.BoundingBoxSize
		}
		boneTree.InView = Frustum.ObjectInFrustum(v10, cFrames, v2, v3, v4, v5, v6, v7, v8, v9)
	end
end

function SmartBone:m_CleanColliders()
	if #self.ColliderObjects ~= 0 then
		for k, colliderObject in self.ColliderObjects do
			if not (#colliderObject.Colliders == 0 or colliderObject.Destroyed == true) then
				continue
			end

			SB_VERBOSE_WARN("Deleting Collider Object")
			SB_INDENT_LOG()
			colliderObject:Destroy()
			SB_UNINDENT_LOG()
			table.remove(self.ColliderObjects, k)
		end
	end
end

function SmartBone:m_UpdateBoneTree(instance, p2: number, p3: number)
	if instance.Destroyed then
		instance:Destroy()
		table.remove(self.BoneTrees, p2)
	else
		instance:PreUpdate(p3)

		if instance.InView and math.floor(instance.UpdateRate) ~= 0 and instance.InWorkspace then
			for _, colliderObject in self.ColliderObjects do
				colliderObject:Step()
			end

			local v2 = 1 / instance.UpdateRate
			instance.AccumulatedDelta += p3
			local flag = false

			while v2 < instance.AccumulatedDelta do
				instance.AccumulatedDelta -= v2
				instance:StepPhysics(v2)
				instance:Constrain(self.ColliderObjects, v2)
				instance:SolveTransform(v2)
				flag = true
			end

			if flag then
				task.synchronize()
				instance:ApplyTransform()
			end
		else
			local isSkippingUpdates = instance.IsSkippingUpdates
			instance:SkipUpdate()

			if not isSkippingUpdates then
				task.synchronize()
				instance:ApplyTransform()
				SB_VERBOSE_LOG((`Skipping BoneTree, InView: {instance.InView}, Update Rate == 0: {math.floor(instance.UpdateRate) == 0}, InWorkspace: {instance.InWorkspace}`))
			end
		end
	end
end

function SmartBone:m_CheckDestroy()
	self.ShouldDestroy = false

	if #self.BoneTrees ~= 0 then
		return false
	end

	self.ShouldDestroy = true
	return true
end

function SmartBone:LoadObject(folder)
	local roots = folder:GetAttribute("Roots")

	if not roots then
		warn((`[SmartBone2::LoadObject] Cannot load an object with no roots defined {folder.Name}`))
		return
	end

	local parts = roots:split(",")
	local bonesByName = {}

	for _, bone in folder:GetDescendants() do
		if not bone:IsA("Bone") then
			continue
		end

		if bonesByName[bone.Name] then
			warn((`[SmartBone2::LoadObject] Duplicate bones of name: {bone.Name} in RootPart: {folder.Name}`))
		else
			bonesByName[bone.Name] = bone
		end
	end

	for _, part in parts do
		local v2 = bonesByName[part]

		if v2 then
			self:m_CreateBoneTree(folder, v2)
		else
			pcall(function() end)
		end
	end
end

function SmartBone.LoadColliderModule(p, moduleScript, p2)
	assert(moduleScript, "[SmartBone2::LoadColliderModule] No collider module passed in")
	local module = require(moduleScript)
	local jSONDecode = HttpService:JSONDecode(module)
	local v2 = ColliderObject.new(jSONDecode, p2)
	table.insert(p.ColliderObjects, v2)
end

function SmartBone.LoadRawCollider(p, p2, p3)
	local v2 = ColliderObject.new(p2, p3)
	table.insert(p.ColliderObjects, v2)
end

function SmartBone:SkipUpdate()
	for _, boneTree in self.BoneTrees do
		boneTree:SkipUpdate()
	end
end

function SmartBone:StepBoneTrees(p: number)
	if self:m_CheckDestroy() then
		return
	end

	if p <= 0 then
		SB_VERBOSE_WARN("DeltaTime is zero or sub zero, not updating.")
		return
	end

	self:m_CleanColliders()
	self:m_UpdateViewFrustum()

	for k, boneTree in self.BoneTrees do
		self:m_UpdateBoneTree(boneTree, k, p)
	end
end

function SmartBone:DrawDebug(flag: boolean, flag2: boolean, flag3: boolean, flag4: boolean, flag5: boolean, flag6: boolean, flag7: boolean, flag8: boolean, flag9: boolean, flag10: boolean, flag11: boolean, flag12: boolean, flag13: boolean)
	for _, boneTree in self.BoneTrees do
		boneTree:DrawDebug(flag2, flag3, flag4, flag5, flag6, flag11, flag12, flag13)
	end

	if flag then
		for _, colliderObject in self.ColliderObjects do
			colliderObject:DrawDebug(flag7, flag8, flag9, flag10)
		end
	end
end

function SmartBone:DrawOverlay(data)
	if not Config.DEBUG_OVERLAY_ENABLED then
		return
	end

	local color = Color3.new(1, 0.431373, 0.713725)
	local color2 = Color3.new(1, 1, 1)
	local color3 = Color3.new(0.486275, 0.431373, 1)
	local color4 = Color3.new(1, 1, 1)
	data.Begin(`SmartBone Instance ID: {self.ID}`, color, color2)
	data.Text((`Frame Counter: {shared.FrameCounter}`))

	if Config.DEBUG_OVERLAY_TREE then
		for k, boneTree in self.BoneTrees do
			if Config.DEBUG_OVERLAY_MAX_TREES > 0 and Config.DEBUG_OVERLAY_TREE_OFFSET + Config.DEBUG_OVERLAY_MAX_TREES <= k then
				break
			end

			if k < Config.DEBUG_OVERLAY_TREE_OFFSET then
				continue
			end

			data.Begin(`Bone Tree {k}`, color3, color4)
			boneTree:DrawOverlay(data)
			data.End()
		end
	end

	data.End()
end

function SmartBone:Destroy()
	SB_VERBOSE_LOG("Deleting SmartBone Object")

	for _, boneTree in self.BoneTrees do
		boneTree:Destroy()
	end

	for _, colliderObject in self.ColliderObjects do
		colliderObject:Destroy()
	end

	setmetatable(self, nil)
end

function SmartBone.Start()
	if not RunService:IsClient() then
		warn("Smartbone.Start() can only be called in client context.")
		return
	end

	if SmartBone.Running then
		warn("Cannot call Smartbone.Start() multiple times")
		return
	end

	if Config.STARTUP_PRINT_ENABLED or Config.LOG_VERBOSE then
		print((`SmartBone2 v{Config.VERSION} Starting`))
	end

	SmartBone.Running = true
	local playerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts")
	local folder = Instance.new("Folder")
	folder.Name = "SmartBone-Actors"
	folder.Parent = playerScripts
	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Name = "OverlayEvent"
	bindableEvent.Parent = script
	bindableEvent.Event:Connect(function(p, ...)
		if not Config.DEBUG_OVERLAY_ENABLED then
			return
		end

		if p == "Text" then
			v:Text(...)
		elseif p == "Begin" then
			v:Begin(...)
		elseif p == "End" then
			v:End()
		end
	end)

	local function GatherColliders()
		local v2 = {
			Key = {},
			Raw = {}
		}

		for _, part in CollectionService:GetTagged("SmartCollider") do
			if not part:IsA("BasePart") then
				continue
			end

			local colliderKey = part:GetAttribute("ColliderKey")

			if colliderKey then
				colliderKey = tostring(colliderKey)

				if not v2.Key[colliderKey] then
					v2.Key[colliderKey] = {}
				end

				table.insert(v2.Key[colliderKey], part)
			end

			SB_VERBOSE_LOG((`Adding collider: {part.Name}, Collider Key: {colliderKey}`))
			table.insert(v2.Raw, part)

			if Config.YIELD_ON_COLLIDER_GATHER then
				task.wait()
			end
		end

		return v2
	end

	local function SetupObject(part)
		if not part:IsA("BasePart") then
			return
		end

		SB_VERBOSE_LOG((`Setup Object: {part.Name}`))
		SB_INDENT_LOG()
		local gatherColliders = GatherColliders()
		local colliderKey = part:GetAttribute("ColliderKey")
		local raw

		if colliderKey then
			raw = gatherColliders.Key[tostring(colliderKey)] or {}
		else
			raw = gatherColliders.Raw or {}
		end

		local v3 = {}

		for _, v4 in raw do
			table.insert(v3, { Utilities.GetCollider(v4), v4 })
		end

		local actor = Instance.new("Actor")
		local clone = runtime:Clone()
		clone.Parent = actor
		clone.Enabled = true
		actor.Parent = folder
		task.wait()
		actor:SendMessage("Setup", part, v3, script)
		SB_VERBOSE_LOG("Runtime Started")
		SB_UNINDENT_LOG()
	end

	connection = CollectionService:GetInstanceAddedSignal("SmartBone"):Connect(SetupObject)

	for _, v2 in CollectionService:GetTagged("SmartBone") do
		SetupObject(v2)
	end

	if Config.DEBUG_OVERLAY_ENABLED then
		v = ImOverlay.new()
		local playerGui = Players.LocalPlayer.PlayerGui
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "SmartBoneDebugOverlay"
		screenGui.IgnoreGuiInset = true
		screenGui.ResetOnSpawn = false
		screenGui.Parent = playerGui
		v.BackFrame.Parent = screenGui
		RunService.RenderStepped:Connect(function()
			v:Render()
		end)
	end

	return {
		Stop = function()
			SmartBone.Running = false

			if not Config.RESET_BONE_ON_DESTROY then
				folder:Destroy()
				return
			end

			for _, child in folder:GetChildren() do
				child:SendMessage("Destroy")
			end

			if connection then
				connection:Disconnect()
				connection = nil
			end
		end
	}
end

return SmartBone