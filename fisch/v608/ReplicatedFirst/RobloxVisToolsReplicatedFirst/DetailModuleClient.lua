local CollectionService = game:GetService("CollectionService")
local DetailModuleClient = {
	quads = script.Parent:FindFirstChild("Quads"),
	allowDebug = script.Parent:GetAttribute("allowDebugInLive") or game.ReplicatedFirst:FindFirstChild("allowDebugInLive") ~= nil
}

if game["Run Service"]:IsStudio() == true then
	DetailModuleClient.allowDebug = true
end

DetailModuleClient.debugging = false
DetailModuleClient.drawDebugText = script.parent:GetAttribute("enableDebugOnStart") and DetailModuleClient.allowDebug
DetailModuleClient.override = false
DetailModuleClient.tagList = {
	{
		name = "Detail_Ultra",
		distance = 800,
		useGrid = false
	},
	{
		name = "Detail_Big",
		distance = 400,
		useGrid = true
	},
	{
		name = "Detail_Small",
		distance = 200,
		useGrid = true
	}
}
DetailModuleClient.imposterDistance = script.Parent:GetAttribute("Imposter") or 350
DetailModuleClient.imposterMaxDistance = script.Parent:GetAttribute("ImposterMax") or 4000
DetailModuleClient.teleportSize = script.Parent:GetAttribute("TeleportSize") or 40
DetailModuleClient.folder = game.ReplicatedFirst:FindFirstChild("Imposters")
DetailModuleClient.stepSize = 20
DetailModuleClient.debugGui = nil
DetailModuleClient.animSpeed = 4
DetailModuleClient.imposterAnimSpeed = 4
DetailModuleClient.imposterMsBudget = 0.5
DetailModuleClient.imposterUpdates = 0
DetailModuleClient.impostersUpdating = false
DetailModuleClient.imposterVerticalAngleTolerance = 0.75
DetailModuleClient.supressAnimationFrames = 0
DetailModuleClient.largestGridDistance = 0
DetailModuleClient.records = {}
DetailModuleClient.ultraRecords = {}
DetailModuleClient.movingRecords = {}
DetailModuleClient.debugSupression = false
DetailModuleClient.detailMsBudget = 4
DetailModuleClient.lastGrid = nil
DetailModuleClient.processing = false
DetailModuleClient.detailsDirty = false
DetailModuleClient.setup = false
DetailModuleClient.animating = {}
DetailModuleClient.animatingLights = {}
DetailModuleClient.debugTris = {}
DetailModuleClient.grid = {}
DetailModuleClient.oldSet = {}
DetailModuleClient.gridSize = vector.create(200, 2000, 200)
DetailModuleClient.newlyVisibleRecords = {}
DetailModuleClient.imposters = {}
DetailModuleClient.recordCount = 0
DetailModuleClient.visibleDetails = 0
DetailModuleClient.visibleMovingDetails = 0
DetailModuleClient.visibleImposterModels = 0
DetailModuleClient.visibleImposterQuads = 0
DetailModuleClient.detailsAnimating = 0
DetailModuleClient.tooMuchStuffAnimating = 200
DetailModuleClient.markParts = false

local function updateCenterOnPlayer()
	DetailModuleClient.centerOnPlayer = script.Parent:GetAttribute("centerOnPlayer") or true
end

DetailModuleClient.centerOnPlayer = script.Parent:GetAttribute("centerOnPlayer") or true
script.Parent:GetAttributeChangedSignal("centerOnPlayer"):Connect(updateCenterOnPlayer)
DetailModuleClient.pendingLoads = 0

function DetailModuleClient:ForceUpdateAllTags()
	local position = workspace.CurrentCamera.CFrame.Position

	for _, record in self.records do
		local v = record
		task.spawn(function()
			DetailModuleClient.pendingLoads += 1

			while v.loaded ~= true do
				wait()
			end

			DetailModuleClient.pendingLoads -= 1
			self:ConfigureRecordDistance(v.instance, v, v.tag.useGrid, v.tag.moves, v.tag.distance)
			self:UpdateVis(v, position)
		end)
	end
end

function DetailModuleClient.SupressAnimations(_, supressAnimationFrames: number)
	DetailModuleClient.supressAnimationFrames = supressAnimationFrames
end

function DetailModuleClient:AnimateRecord(data, p)
	if data.animate ~= true or DetailModuleClient.supressAnimationFrames > 0 then
		self:SnapAnimateRecord(data, p)
		return
	end

	if self.detailsAnimating > self.tooMuchStuffAnimating then
		p *= 4
	end

	if data.lodModel == nil then
		self:AnimatePart(data.instance, data.instance, p, 0, data.reparent)

		for _, descendant in data.instance:GetDescendants() do
			self:AnimatePart(data.instance, descendant, p, 0, data.reparent)
		end
	else
		local v, v2

		if p < 0 then
			v = 1
			v2 = 0
		else
			v = 0
			v2 = 1
		end

		if data.reparent == true then
			data.lodModel.Parent = data.parent
		end

		self:AnimatePart(data.lodModel, data.lodModel, -p * 2, v, data.reparent)

		for _, descendant in data.lodModel:GetDescendants() do
			self:AnimatePart(data.lodModel, descendant, -p * 2, v, data.reparent)
		end

		self:AnimatePart(data.instance, data.instance, p * 2, v2, data.reparent)

		for _, descendant in data.instance:GetDescendants() do
			self:AnimatePart(data.instance, descendant, p * 2, v2, data.reparent)
		end
	end
end

local function SetFullyTransparent(instance)
	if instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("Texture") then
		instance.LocalTransparencyModifier = 1
	elseif instance:IsA("SurfaceGui") then
		instance.Enabled = false
	end

	if instance:IsA("Light") then
		if instance:GetAttribute("Brightness") == nil then
			instance:SetAttribute("Brightness", instance.Brightness)
		end

		instance.Brightness = 0
	end
end

function DetailModuleClient:SnapRecordToTransparent(p)
	SetFullyTransparent(p.instance)

	for _, descendant in p.instance:GetDescendants() do
		SetFullyTransparent(descendant)
	end
end

function DetailModuleClient:SnapRecordLODModelToTransparent(p)
	SetFullyTransparent(p.lodModel)

	for _, descendant in p.lodModel:GetDescendants() do
		SetFullyTransparent(descendant)
	end
end

function DetailModuleClient:SnapAnimateRecord(state, p)
	self:ClearAnimations(state)

	if state.lodModel == nil then
		if p > 0 then
			if state.reparent ~= true then
				self:SnapRecordToTransparent(state)
				return
			end

			state.parentReason = "InternalDeparent"
			state.instance.Parent = nil
		elseif state.reparent == true then
			state.parentReason = "AnimatingSnap"
			state.instance.Parent = state.parent
		end
	elseif p > 0 then
		if state.reparent == true then
			state.parentReason = "InternalDeparent"
			state.instance.Parent = nil
		else
			self:SnapRecordToTransparent(state)
		end

		if state.reparent == true then
			state.lodModel.Parent = state.parent
		end
	else
		if state.reparent ~= true then
			self:SnapRecordLODModelToTransparent(state)
			return
		end

		state.lodModel.Parent = nil
		state.parentReason = "AnimatingSnap"
		state.instance.Parent = state.parent
	end
end

function DetailModuleClient:ClearAnimations(data)
	if data.animate == false and data.reparent == true then
		return
	end

	if data.lodModel ~= nil then
		DetailModuleClient:ClearAnimation(data.lodModel)

		for _, descendant in data.lodModel:GetDescendants() do
			self:ClearAnimation(descendant)
		end
	end

	self:ClearAnimation(data.instance)

	for _, descendant in data.instance:GetDescendants() do
		self:ClearAnimation(descendant)
	end
end

function DetailModuleClient:ClearAnimation(instance)
	if instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("Texture") then
		instance.LocalTransparencyModifier = 0
		local _ = self.animating[instance]
		self.animating[instance] = nil
	elseif instance:IsA("SurfaceGui") then
		instance.Enabled = true
	end

	if instance:IsA("Light") then
		local brightness = instance:GetAttribute("Brightness")

		if brightness ~= nil then
			instance.Brightness = brightness
		end

		self.animatingLights[instance] = nil
	end
end

function DetailModuleClient:AnimatePart(parentInstance, instance, dir, delayTime, reparent)
	if instance:IsA("BasePart") or instance:IsA("Decal") or instance:IsA("Texture") then
		local v = {
			part = instance,
			delayTime = delayTime * 0.5,
			parentRecord = self.records[parentInstance]
		}

		if dir < 0 then
			v.transparency = 1
		else
			v.transparency = 0
		end

		v.dir = dir
		local v2 = self.animating[instance]

		if v2 ~= nil then
			v.transparency = v2.transparency
		end

		v.parentInstance = parentInstance
		v.reparent = reparent
		instance.LocalTransparencyModifier = v.transparency
		self.animating[instance] = v
	elseif instance:IsA("SurfaceGui") then
		if dir < 0 then
			instance.Enabled = true
		else
			instance.Enabled = false
		end
	else
		if not instance:IsA("Light") then
			return
		end

		local brightness = instance:GetAttribute("Brightness")

		if brightness == nil then
			brightness = instance.Brightness
			instance:SetAttribute("Brightness", brightness)
		end

		local v = {
			delayTime = delayTime,
			part = instance,
			brightness = brightness,
			parentRecord = self.records[parentInstance],
			reparent = reparent
		}

		if dir < 0 then
			v.transparency = 1
		else
			v.transparency = 0
		end

		v.dir = dir
		local animatingLight = self.animatingLights[instance]

		if animatingLight ~= nil then
			v.transparency = animatingLight.transparency
		end

		v.parentInstance = parentInstance
		instance.Brightness = v.brightness * (1 - v.transparency)
		self.animatingLights[instance] = v
	end
end

function DetailModuleClient:AddToGrid(p)
	local v = self.grid[p.key]

	if v == nil then
		v = {}
		self.grid[p.key] = v
	end

	v[p.instance] = p
	p.instance:SetAttribute("pos", self:GetPosition(p))
end

function DetailModuleClient:RemoveFromGrid(p2)
	local v = self.grid[p2.key]

	if v then
		v[p2.instance] = nil
	end
end

function DetailModuleClient:UpdateVis(state, p)
	if state.parent == nil then
		return
	end

	local magnitude = (self:GetPosition(state) - p).magnitude

	if ((self.debugSupression == true or self.forceDisabled) and 0 or magnitude) > state.distance then
		if state.visible == true then
			if self.debugging == true then
				print("Detail hiding", state.instance.Name)
			end

			state.visible = false

			if state.lodModel and state.reparent == true then
				state.lodModel.Parent = state.parent
			end

			self:AnimateRecord(state, 1)
		end
	elseif state.visible == false then
		if self.debugging == true then
			print("Detail showing", state.instance.Name)
		end

		state.visible = true

		if state.reparent == true then
			state.parentReason = "Animating"
			state.instance.Parent = state.parent
		end

		self:AnimateRecord(state, -1)
	end
end

function DetailModuleClient:PrintPathForInstance(parent)
	local name = ""

	while parent ~= nil do
		if name == "" then
			name = parent.Name
		else
			name = parent.Name .. "." .. name
		end

		parent = parent.Parent
	end

	return name
end

function DetailModuleClient:CalculateKey(data)
	return (Vector3.new(
		math.floor(data.x / self.gridSize.x),
		math.floor(data.y / self.gridSize.y),
		(math.floor(data.z / self.gridSize.z))
	))
end

function DetailModuleClient:GetPosition(data)
	if data.isDecalOrTexture then
		return data.parent.Position
	end

	if data.isModel ~= true then
		return data.instance.Position
	end

	if data.instance.PrimaryPart == nil then
		return data.instance:GetModelCFrame().Position
	end

	return data.instance.PrimaryPart.Position
end

function DetailModuleClient:CalculateRadius(instance)
	local size

	if instance:IsA("Decal") or instance:IsA("Texture") then
		size = instance.Parent.Size
	elseif instance:IsA("BasePart") then
		size = instance.Size
	else
		local boundingBox
		boundingBox, size = instance:GetBoundingBox()
	end

	return math.max(math.max(size.x, size.y), size.z) / 2
end

function DetailModuleClient:ConfigureRecordDistance(instance, state, useGrid, moves, p)
	state.useGrid = useGrid
	state.moves = moves
	local distance = instance:GetAttribute("distance")

	if distance ~= nil then
		p = distance
	end

	state.distance = p + self:CalculateRadius(state.instance)

	if useGrid and state.distance > self.largestGridDistance then
		state.distance = self.largestGridDistance
	end
end

function DetailModuleClient:CleanupDetailRecord(state)
	if self.debugging == true then
		print("Detail destroyed", state.instance.Name)
	end

	if state.instanceSignal then
		state.instanceSignal:Disconnect()
		state.instanceSignal = nil
	end

	if state.destroySignal then
		state.destroySignal:Disconnect()
		state.destroySignal = nil
	end

	if state.ancestoryChangedSignal then
		state.ancestoryChangedSignal:Disconnect()
		state.ancestoryChangedSignal = nil
	end

	if state.transformChangedSignal then
		state.transformChangedSignal:Disconnect()
		state.transformChangedSignal = nil
	end

	if state.primaryPartChangedSignal then
		state.primaryPartChangedSignal:Disconnect()
		state.primaryPartChangedSignal = nil
	end

	self:ClearAnimations(state)

	if state.instance ~= nil then
		self:RemoveFromGrid(state)
		self.records[state.instance] = nil
		self.ultraRecords[state.instance] = nil
		self.movingRecords[state.instance] = nil
		self.oldSet[state.instance] = nil
	end

	self.recordCount -= 1
end

function DetailModuleClient:OnDetailAdded(folder, p, useGrid, moves, animate2, reparent, tag)
	if not (folder.Parent ~= nil and self.newlyVisibleRecords[folder] == nil) then
		return
	end

	local record = self.records[folder]

	if record == nil then
		if folder:IsA("Model") == false and folder:IsA("BasePart") == false and folder:IsA("Decal") == false and folder:IsA("Texture") == false then
			warn("Only models, baseparts, decals, and textures allowed: ", self:PrintPathForInstance(folder))
			return
		end

		local thread = nil
		thread = task.spawn(function()
			if self.debugging == true then
				print("Detail Adding ", folder.Name, " moves:", moves)
			end

			local v = {
				tag = tag,
				instance = folder,
				visible = true,
				animate = animate2,
				reparent = reparent,
				loaded = false,
				useGrid = useGrid,
				moves = moves
			}
			self:ConfigureRecordDistance(folder, v, useGrid, moves, p)
			self.records[folder] = v

			if game.Workspace:IsAncestorOf(folder) == false then
				local ancestryChangedConnection = folder.AncestryChanged:Connect(function(_, _)
					if game.Workspace:IsAncestorOf(folder) == true then
						coroutine.resume(thread)
					end
				end)
				coroutine.yield(thread)
				ancestryChangedConnection:Disconnect()
			end

			local hasLodModel = folder:GetAttribute("HasLodModel")

			if hasLodModel ~= nil then
				DetailModuleClient.pendingLoads += 1
				local count = #folder:GetDescendants()

				while count < hasLodModel do
					wait()
					count = #folder:GetDescendants() or 0
				end

				local LOD

				while true do
					LOD = folder:FindFirstChild("LOD")

					if LOD then
						break
					end

					wait()
				end

				LOD.Name = folder.Name .. "_LOD"
				v.lodModel = LOD
				DetailModuleClient.pendingLoads -= 1
			end

			if folder.Parent == nil then
				DetailModuleClient.pendingLoads += 1

				while folder.Parent == nil do
					wait()
				end

				DetailModuleClient.pendingLoads -= 1
			end

			local animate = folder:GetAttribute("animate")

			if animate ~= nil then
				v.animate = animate
			end

			v.isDecalOrTexture = false
			v.isModel = false

			if folder:IsA("Decal") or folder:IsA("Texture") then
				v.isDecalOrTexture = true
			elseif folder:IsA("Model") then
				v.isModel = true
			end

			if self.markParts == true then
				local selectionBox = Instance.new("SelectionBox")
				selectionBox.Adornee = folder
				selectionBox.Parent = folder
				selectionBox.Color3 = Color3.new(0.3, 1, 0.3)
				selectionBox.SurfaceColor3 = Color3.new(0.3, 1, 0.3)
				selectionBox.SurfaceTransparency = 0.85
			end

			v.parent = folder.Parent
			v.instanceSignal = v.instance:GetPropertyChangedSignal("Name"):Connect(function() end)
			v.destroySignal = v.instance.Destroying:Once(function()
				self:CleanupDetailRecord(v)
			end)

			if v.useGrid == true then
				v.key = self:CalculateKey(self:GetPosition(v))
				self:AddToGrid(v)
				self.oldSet[v.instance] = v

				if v.isModel == false then
					local _ = v.instance

					if v.isDecalOrTexture then
						local _ = v.instance.Parent
					end
				else
					v.primaryPartChangedSignal = v.instance:GetPropertyChangedSignal("PrimaryPart"):Connect(function()
						if v.primaryPartChangedSignal then
							v.primaryPartChangedSignal:Disconnect()
						end

						local key = self:CalculateKey(self:GetPosition(v))

						if key ~= v.key then
							self:RemoveFromGrid(v)
							v.key = key
							self:AddToGrid(v)
						end
					end)
				end
			elseif v.moves == true then
				self.movingRecords[folder] = v
			else
				self.ultraRecords[folder] = v
			end

			self.newlyVisibleRecords[folder] = v
			v.loaded = true
			self.recordCount += 1
		end)
	else
		if record.parentReason == nil then
			self.newlyVisibleRecords[folder] = self.records[folder]
		end

		record.parentReason = nil
	end
end

function DetailModuleClient:ConfigureTags()
	for _, child in script.Parent:GetChildren() do
		local name = child.Name

		if string.sub(name, 1, 7) ~= "Detail_" then
			continue
		end

		local v = nil

		for _, v3 in self.tagList do
			if v3.name ~= name then
				continue
			end

			v = v3
			break
		end

		if v == nil then
			v = {
				moves = false,
				useGrid = true,
				name = name,
				distance = 50
			}

			if self.debugging == true then
				print("New Detail tag registered:", name, " distance:", v.distance, " moves:", v.moves)
			end

			table.insert(self.tagList, v)
		end

		v.reparent = true
		v.animate = true
		v.moves = false

		if child:GetAttribute("distance") ~= nil then
			v.distance = child:GetAttribute("distance")
		end

		if child:GetAttribute("usegrid") == false then
			v.useGrid = false
		end

		if child:GetAttribute("animate") == false then
			v.animate = false
		end

		if child:GetAttribute("deparent") == false then
			v.reparent = false
		end

		if child:GetAttribute("moves") == true then
			v.useGrid = false
			v.moves = true
			v.reparent = false
		end

		v.configurationDistance = v.distance
	end

	self.largestGridDistance = 0

	for _, v in self.tagList do
		if v.useGrid == true and v.distance > self.largestGridDistance then
			self.largestGridDistance = v.distance
		end
	end
end

function DetailModuleClient:Setup()
	if self.setup == true then
		return
	end

	self.setup = true
	self:ConfigureTags()

	for _, v in self.tagList do
		for _, v2 in CollectionService:GetTagged(v.name) do
			DetailModuleClient:OnDetailAdded(v2, v.distance, v.useGrid, v.moves, v.animate, v.reparent, v)
		end

		local v2 = v
		CollectionService:GetInstanceAddedSignal(v.name):Connect(function(p)
			DetailModuleClient:OnDetailAdded(p, v2.distance, v2.useGrid, v2.moves, v2.animate, v2.reparent, v2)
		end)
		CollectionService:GetInstanceRemovedSignal(v.name):Connect(function(p)
			local record = self.records[p]

			if not record then
				return
			end

			if not record.parentReason then
				DetailModuleClient:CleanupDetailRecord(record)
			end
		end)
	end

	for _, v in CollectionService:GetTagged("Imposter") do
		self:ImposterSetup(v)
	end

	CollectionService:GetInstanceAddedSignal("Imposter"):Connect(function(p)
		self:ImposterSetup(p)
	end)
	self.cameraPreviousCFrame = workspace.CurrentCamera.CFrame
end

function DetailModuleClient:DrawUIText(p2, text, textColor, textSize)
	local textLabel = Instance.new("TextLabel")
	textLabel.AutoLocalize = false
	textLabel.Text = text
	textLabel.BackgroundTransparency = 1
	textLabel.TextSize = textSize
	textLabel.TextColor3 = textColor
	textLabel.Position = UDim2.new(0, p2.x, 0, p2.y)
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Bottom
	textLabel.Parent = self.debugGui
	table.insert(self.debugTris, textLabel)
	return textLabel
end

function DetailModuleClient:ProcessDetailObject(data, p)
	if data.loaded == false then
		return
	end

	if data.instanceSignal == nil or data.instanceSignal.Connected == false then
		self:CleanupDetailRecord(data)
		return
	end

	self:UpdateVis(data, p)

	if data.visible then
		if data.moves then
			self.visibleMovingDetails += 1
		else
			self.visibleDetails += 1
		end
	end
end

function DetailModuleClient:UpdateAnimations(p)
	debug.profilebegin("Update Animations")
	self.detailsAnimating = 0

	for _, v in self.animating do
		self.detailsAnimating += 1

		if v.delayTime > 0 then
			v.delayTime -= p * self.animSpeed
		else
			v.transparency += v.dir * p * self.animSpeed

			if v.transparency < 0 then
				v.transparency = 0
				self.animating[v.part] = nil
			end

			if v.transparency > 1 then
				v.transparency = 1
				self.animating[v.part] = nil

				if v.reparent then
					if v.parentRecord then
						v.parentRecord.parentReason = "InternalDeparent"
					end

					v.parentInstance.Parent = nil
				end
			end
		end

		v.part.LocalTransparencyModifier = v.transparency
	end

	for _, animatingLight in self.animatingLights do
		self.detailsAnimating += 1

		if animatingLight.delayTime > 0 then
			animatingLight.delayTime -= p * self.animSpeed
		else
			animatingLight.transparency += animatingLight.dir * p * self.animSpeed

			if animatingLight.transparency < 0 then
				animatingLight.transparency = 0
				self.animatingLights[animatingLight.part] = nil
			end

			if animatingLight.transparency > 1 then
				animatingLight.transparency = 1
				self.animatingLights[animatingLight.part] = nil

				if animatingLight.reparent == true then
					if animatingLight.parentRecord then
						animatingLight.parentRecord.parentReason = "InternalDeparent"
					end

					animatingLight.parentInstance.Parent = nil
				end
			end
		end

		animatingLight.part.Brightness = animatingLight.brightness * (1 - animatingLight.transparency)
	end

	debug.profileend()
end

function DetailModuleClient:UpdateDetails(data, _)
	if not (self.detailsDirty ~= false and self.processing ~= true) then
		return
	end

	self.detailsDirty = false
	self.processing = true
	local v = tick() + 0.001 * self.detailMsBudget
	task.spawn(function()
		debug.profilebegin("Update Details")
		self.visibleDetails = 0
		local v2 = math.ceil(self.largestGridDistance / self.gridSize.x)
		local v3 = math.ceil(self.largestGridDistance / self.gridSize.y)
		local v4 = math.ceil(self.largestGridDistance / self.gridSize.z)
		local v5 = math.floor(data.x / self.gridSize.x) - v2
		local v6 = math.floor(data.y / self.gridSize.y) - v3
		local v7 = math.floor(data.z / self.gridSize.z) - v4
		local v8 = math.floor(data.x / self.gridSize.x) + v2
		local v9 = math.floor(data.y / self.gridSize.y) + v3
		local v10 = math.floor(data.z / self.gridSize.z) + v4
		debug.profilebegin("Update Grid")
		local oldSet = {}

		for i = v5, v8 do
			for i2 = v6, v9 do
				for i3 = v7, v10 do
					local v12 = self.grid[Vector3.new(i, i2, i3)]

					if not v12 then
						continue
					end

					for _, v13 in v12 do
						oldSet[v13.instance] = v13
						self.oldSet[v13.instance] = v13
					end
				end
			end
		end

		debug.profileend()
		local count = 0

		for _, v12 in self.oldSet do
			self:ProcessDetailObject(v12, data)
			count += 1

			if not (count > 100) then
				continue
			end

			count = 0
			local now = tick()

			if not (v < now) then
				continue
			end

			debug.profileend()
			task.wait()
			debug.profilebegin("Update Details")
			v = tick() + 0.001 * self.detailMsBudget
		end

		self.oldSet = oldSet
		self.processing = false
		local count2 = 0

		for _, ultraRecord in self.ultraRecords do
			self:ProcessDetailObject(ultraRecord, data)
			count2 += 1

			if not (count2 > 100) then
				continue
			end

			count2 = 0
			local now = tick()

			if not (v < now) then
				continue
			end

			debug.profileend()
			task.wait()
			debug.profilebegin("Update Details")
			v = tick() + 0.001 * self.detailMsBudget
		end

		debug.profileend()
	end)
end

function DetailModuleClient:UpdateMovingDetails(p, _)
	task.spawn(function()
		debug.profilebegin("Update Moving Details")
		self.visibleMovingDetails = 0
		local v = tick() + 0.001 * self.detailMsBudget
		local count = 0

		for _, movingRecord in self.movingRecords do
			self:ProcessDetailObject(movingRecord, p)
			count += 1

			if not (count > 100) then
				continue
			end

			count = 0

			if not (v < tick()) then
				continue
			end

			debug.profileend()
			task.wait()
			debug.profilebegin("Update Moving Details")
			v = tick() + 0.001 * self.detailMsBudget
		end
	end)
end

function DetailModuleClient:Update(p)
	debug.profilebegin("Update Detail Module")
	self:Setup()
	local lastTime = tick()

	for _, v in self.debugTris do
		v:Destroy()
	end

	self.debugTris = {}
	local position

	if self.centerOnPlayer == true and game.Players.LocalPlayer.Character ~= nil and game.Players.LocalPlayer.Character.PrimaryPart ~= nil then
		position = game.Players.LocalPlayer.Character.PrimaryPart.Position
	else
		position = game.Workspace.CurrentCamera.CFrame.Position
	end

	if self.cameraPreviousPos == nil then
		self.cameraPreviousPos = position
	end

	local magnitude = (position - self.cameraPreviousPos).Magnitude
	self.cameraPreviousPos = position

	if DetailModuleClient.teleportSize < magnitude then
		if self.debugging == true then
			print("Camera teleported!")
		end

		self.detailsDirty = true
		self.supressAnimationFrames += 1
	end

	if self.gridPreviousPos == nil then
		self.gridPreviousPos = position
	end

	local v = position - self.gridPreviousPos

	if self.detailsDirty == false and v.Magnitude > self.stepSize then
		self.gridPreviousPos = position
		self.detailsDirty = true
	end

	self.lastCameraPos = position
	self:UpdateNewlyVisibleDetails(position)
	self:UpdateDetails(position, p)
	self:UpdateMovingDetails(position, p)
	self:UpdateImposters(position)
	self:UpdateAnimations(p)

	if self.processing == false and self.supressAnimationFrames > 0 then
		self.supressAnimationFrames -= 1
	end

	self:DrawDebugText((math.floor((tick() - lastTime) * 10000)))
	debug.profileend()
end

function DetailModuleClient:UpdateNewlyVisibleDetails(p)
	for _, newlyVisibleRecord in self.newlyVisibleRecords do
		if newlyVisibleRecord.isModel == nil then
			continue
		end

		self:ClearAnimations(newlyVisibleRecord)

		if (self:GetPosition(newlyVisibleRecord) - p).magnitude > newlyVisibleRecord.distance then
			newlyVisibleRecord.visible = false

			if newlyVisibleRecord.lodModel ~= nil then
				newlyVisibleRecord.lodModel.Parent = newlyVisibleRecord.parent
			end

			if newlyVisibleRecord.reparent == true then
				newlyVisibleRecord.parentReason = "InternalDeparent"
				newlyVisibleRecord.instance.Parent = nil
			else
				self:SnapRecordToTransparent(newlyVisibleRecord)
			end
		else
			newlyVisibleRecord.visible = true

			if newlyVisibleRecord.lodModel ~= nil then
				if newlyVisibleRecord.reparent == true then
					newlyVisibleRecord.lodModel.Parent = nil
				else
					newlyVisibleRecord.lodModel.Parent = newlyVisibleRecord.parent
					self:SnapRecordLODModelToTransparent(newlyVisibleRecord)
				end
			end

			newlyVisibleRecord.instance.Parent = newlyVisibleRecord.parent
		end
	end

	self.newlyVisibleRecords = {}
end

function DetailModuleClient:DrawDebugText(p)
	debug.profilebegin("DrawDebugText")

	if self.drawDebugText == true then
		local v = p / 10
		local v2 = tostring(v)
		local v3 = v < 0.1 and "0.0" or v2

		if self.debugGui == nil then
			local screenGui = Instance.new("ScreenGui")
			screenGui.Parent = game.Players.LocalPlayer.PlayerGui
			screenGui.ResetOnSpawn = false
			screenGui.IgnoreGuiInset = true
			screenGui.Name = "DebugGui"
			self.debugGui = screenGui
		end

		self.visibleImposterQuads = 0
		self.visibleImposterModels = 0
		local count = 0

		for _, imposter in self.imposters do
			count += 1

			if imposter.showModel == false then
				self.visibleImposterQuads += 1
			else
				self.visibleImposterModels += 1
			end
		end

		local v4 = 76
		self:DrawUIText(
			Vector3.new(10, v4, 0),
			"Num Details: (" .. self.visibleDetails + self.visibleMovingDetails .. "/" .. self.recordCount .. ") (" .. DetailModuleClient.pendingLoads .. ")",
			Color3.new(0, 1, 0),
			8
		)
		local v5 = v4 + 14
		self:DrawUIText(Vector3.new(10, v5, 0), "Animating: " .. self.detailsAnimating, Color3.new(0, 1, 0), 8)
		local v6 = v5 + 14
		self:DrawUIText(
			Vector3.new(10, v6, 0),
			"Imposter Models vs Quads: (" .. self.visibleImposterModels .. " vs " .. self.visibleImposterQuads .. ")",
			Color3.new(0, 1, 0),
			8
		)
		local v7 = v6 + 14
		self:DrawUIText(Vector3.new(10, v7, 0), "Imposter Updates: " .. self.imposterUpdates, Color3.new(0, 1, 0), 8)
		local v8 = v7 + 14
		self:DrawUIText(Vector3.new(10, v8, 0), "Detail CPU: " .. v3 .. "ms.", Color3.new(0, 1, 0), 8)
		local v9 = v8 + 14

		if self.forceDisabled then
			self:DrawUIText(Vector3.new(10, v9, 0), "FORCE DISABLED", Color3.new(1, 0, 0), 8)
		end

		v9 += 14
	end

	self.imposterUpdates = 0
	debug.profileend()
end

function DetailModuleClient:UpdateImposters(p)
	if self.impostersUpdating ~= true then
		self.impostersUpdating = true
		coroutine.wrap(function()
			local v = tick() + 0.001 * self.imposterMsBudget
			local count = 0

			for _, imposter in self.imposters do
				count += 1

				if count > 100 and v < tick() then
					v = tick() + 0.001 * self.imposterMsBudget
					task.wait()
					count = 0
				end

				self:UpdateImposter(imposter, p)
			end

			self.impostersUpdating = false
		end)()
	end
end

function DetailModuleClient:ImposterSetup(instance)
	if self.imposters[instance] ~= nil then
		return
	end

	local v = {
		instance = instance,
		parent = instance.Parent,
		animate = true
	}
	local animate = instance:GetAttribute("animate")

	if animate ~= nil then
		v.animate = animate
	end

	v.showModel = true
	v.reparent = true
	v.distanceCulled = false
	v.imposterDistance = instance:GetAttribute("distance") or DetailModuleClient.imposterDistance
	v.imposterMaxDistance = instance:GetAttribute("maxdistance") or DetailModuleClient.imposterMaxDistance

	if v.imposterMaxDistance < v.imposterDistance then
		v.imposterMaxDistance = v.imposterDistance + 100
	end

	DetailModuleClient.imposters[instance] = v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CompareAngle(p, p2)
	return math.abs(p - p2) > 0.5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CompareInt(p, p2)
	return math.abs(p - p2) > 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CompareVector(data, data2)
	return math.abs(data.x - data2.x) > 0.1 or math.abs(data.y - data2.y) > 0.1 or math.abs(data.z - data2.z) > 0.1
end

local function CompareRotation(p, p2)
	return CompareVector(p.LookVector, p2.LookVector)
end

function DetailModuleClient:UpdateImposterSize(state)
	local boundingBox, storedBounds = state.instance:GetBoundingBox()
	local largest = math.max(math.max(storedBounds.x, storedBounds.z) * 1.414213, storedBounds.y) * state.scale

	for _, part in state.parts do
		local clone = state.surface:Clone()
		clone.Parent = part
		part.Size = Vector3.new(0.00001, largest, largest)
		part.Position = boundingBox.Position
		part.Parent = state.lodModel
		part.Transparency = 1
	end

	state.offset = boundingBox.Position - state.instance:GetModelCFrame().Position
	state.storedBounds = storedBounds
	state.pivot = state.instance:GetPivot()
	state.quadPivot = state.pivot + state.pivot.YVector * state.pivot.YVector:Dot(boundingBox.Position - state.pivot.Position)
	state.largest = largest
	return boundingBox, storedBounds
end

function DetailModuleClient:UpdateImposter(state, p)
	if state.surface == nil then
		if #state.instance:GetChildren() == 0 then
			return
		end

		local hasImposter = state.instance:GetAttribute("HasImposter")

		if hasImposter ~= nil and hasImposter == true and state.instance:FindFirstChild("Imposter", true) == nil then
			return
		end

		local imposter = state.instance:FindFirstChild("Imposter", true)

		if imposter == nil then
			if self.folder == nil then
				return
			end

			local child = self.folder:FindFirstChild(state.instance.Name)

			if not child then
				return
			end

			imposter = child:Clone()
			imposter.Parent = state.instance
		end

		state.surface = imposter:FindFirstChildWhichIsA("SurfaceAppearance")

		if state.surface ~= nil then
			state.parts = {}

			for i = 1, 16 do
				local clone = DetailModuleClient.quads:FindFirstChild("Quad" .. i):Clone()
				state.parts[i] = clone
				clone.Position = state.instance:GetModelCFrame().Position
				clone.CastShadow = imposter.CastShadow
			end

			state.scale = 1
			local scale = imposter:GetAttribute("scale")

			if scale ~= nil and tonumber(scale) ~= nil and scale > 0 then
				state.scale = scale
			end

			imposter:Destroy()
			local model = Instance.new("Model")
			model.Name = state.instance.Name .. "_Imp"
			model.Parent = state.parent
			state.lodModel = model
			state.descendantAddedSignal = state.instance.DescendantAdded:Connect(function()
				if state.storedBounds ~= nil then
					local _, v = state.instance:GetBoundingBox()

					if (state.storedBounds - v).magnitude > 0 then
						state.storedBounds = nil
					end
				end
			end)
			state.ang = 0
		end
	end

	if state.surface == nil then
		return
	end

	if state.storedBounds == nil then
		self:UpdateImposterSize(state)
	end

	local position = state.pivot.Position
	local v = p - position
	local showModel = state.showModel
	state.showModel = false
	local magnitude = v.Magnitude
	local v2 = (self.debugSupression == true or self.forceDisabled) and 0 or magnitude

	if state.imposterMaxDistance < v2 then
		if state.lodModel.Parent ~= nil then
			state.lodModel.Parent = nil
			state.distanceCulled = true
		end
	elseif state.distanceCulled == true then
		state.distanceCulled = false

		if state.lodModel.Parent == nil then
			state.lodModel.Parent = state.instance.Parent
			state.showModel = true
		end
	end

	if v2 < state.imposterDistance then
		state.showModel = true
	end

	if state.showModel == false and math.abs(v.Unit.y) > self.imposterVerticalAngleTolerance then
		state.showModel = true
	end

	if state.showModel ~= showModel then
		if state.showModel == false then
			self:AnimateRecord(state, 1 * self.imposterAnimSpeed)
		end

		if state.showModel == true then
			state.instance.Parent = state.parent
			self:AnimateRecord(state, -1 * self.imposterAnimSpeed)
		end
	end

	if state.showModel == false then
		local pointToObjectSpace = state.pivot:PointToObjectSpace(p)
		local prevAngle = math.atan2(pointToObjectSpace.X, pointToObjectSpace.Z)
		local prevPartIndex = math.floor(prevAngle / 0.39269908169872414 + 0.5) % 16 + 1
		local v5

		if state.prevPartIndex == nil or CompareInt(state.prevPartIndex, prevPartIndex) == true or CompareAngle(
			state.prevAngle,
			prevAngle
		) == true then
			self.imposterUpdates += 1
			v5 = state.parts[prevPartIndex]

			for i = 1, 16 do
				if i == prevPartIndex then
					state.parts[i].Transparency = 0
				else
					state.parts[i].Transparency = 1
				end
			end

			v5.CFrame = state.quadPivot * CFrame.fromOrientation(1.5707963267948966, prevAngle + 1.5707963267948966, 0)
		elseif CompareVector(state.prevModelPosition, position) == true then
			self.imposterUpdates += 1
			v5 = state.parts[prevPartIndex]

			for i = 1, 16 do
				if i == prevPartIndex then
					state.parts[i].Transparency = 0
				else
					state.parts[i].Transparency = 1
				end
			end

			v5.CFrame = state.quadPivot * CFrame.fromOrientation(1.5707963267948966, prevAngle + 1.5707963267948966, 0)
		end

		state.prevPartIndex = prevPartIndex
		state.prevAngle = prevAngle
		state.prevModelPosition = position
		state.prevBaseRotation = state.baseRotation
	end
end

function DetailModuleClient:Start()
	local UserInputService = game:GetService("UserInputService")

	if self.allowDebug then
		UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.F8 then
					self.drawDebugText = not self.drawDebugText
				end

				if input.KeyCode == Enum.KeyCode.F7 then
					self.debugSupression = true
					local position = workspace.CurrentCamera.CFrame.Position

					for _, record in self.records do
						self:UpdateVis(record, position)
					end
				end
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.F7 then
				self.debugSupression = false
				local position = workspace.CurrentCamera.CFrame.Position

				for _, record in self.records do
					self:UpdateVis(record, position)
				end
			end
		end)
	end

	local RunService = game:GetService("RunService")
	RunService.Heartbeat:Connect(function(dt)
		DetailModuleClient:Update(dt)
	end)
end

DetailModuleClient:Start()
return DetailModuleClient