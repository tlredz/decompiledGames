local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Net = require(ReplicatedStorage.packages.Net)
local Signal = require(ReplicatedStorage.packages.Signal)
local Trove = require(ReplicatedStorage.packages.Trove)
local modules = ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules")
local SharedCrabCage = require(modules:WaitForChild("SharedCrabCage"))
local crabcages = require(modules.library.crabcages)
local fx = require(ReplicatedStorage.shared.modules.fx)
local rarities = require(modules.library.rarities)
local bait = require(modules.library.bait)
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local module = require("./DataController")
local playerDataReplicator = module.PlayerDataReplicator
local module2 = require("./InventoryController")
local module3 = require("./SettingsController")
local module4 = require("./HudController")
local crabcages2 = ReplicatedStorage:WaitForChild("resources"):WaitForChild("crabcages")
local sfx = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx")
local crabCagePlacing = ReplicatedStorage.client.inputs.CrabCagePlacing
local remoteFunction = Net:RemoteFunction("CrabCage/Claim")
local remoteFunction2 = Net:RemoteFunction("CrabCage/Place")
local constants = SharedCrabCage.Constants
local CrabCageController = {
	_Chunks = {},
	_ActiveChunks = {},
	ActiveCages = {},
	_Placing = false,
	_PlacingFinished = Signal.new(),
	_LastUpdate = 0,
	_ActiveModelCount = 0,
	_HeldCage = nil,
	_PreviewModel = nil,
	_PreviewTrove = Trove.new(),
	_PlaceButtonHeld = nil,
	_CurrentError = nil,
	_PlaceFinished = 0,
	_IsHoldingPrompt = false,
	_CurrentPrompt = nil,
	_BobWaiting = false,
	_ActualOldValue = nil,
	_Rotation = 0,
	CageAdded = Signal.new(),
	CageRemoved = Signal.new(),
	CageStateChanged = Signal.new(),
	CreateModel = function(self, childName: string, cframe: CFrame)
		local crabCage = crabcages2:FindFirstChild(childName)

		if not crabCage then
			warn((`No crab cage model found for "{childName}"`))
			crabCage = crabcages2:FindFirstChild("Crab Cage")
		end

		local clone = crabCage:Clone()
		clone:PivotTo(cframe)
		local clone2 = script.Prompt:Clone()
		clone2.Enabled = false
		clone2.Parent = clone
		return clone, clone2
	end
}

function CrabCageController:SetupPrompt(state, parent, prompt)
	prompt.ObjectText = crabcages.byId[state.data.i].Name
	prompt:SetAttribute("TargetCage", state.id)
	prompt:SetAttribute("HighlightModel", true)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CFrame = state.pos
	part.Name = "PromptHolder"
	part.Parent = parent
	prompt.Parent = part
	state.prompt = prompt
	CrabCageController:UpdatePromptState(state)
end

function CrabCageController:AddModel(state)
	if state.model then
		return state.model
	end

	local model, v2 = CrabCageController:CreateModel(crabcages.byId[state.data.i].Name, state.pos)
	model.Name = state.id
	state.model = model

	if state.data.s == SharedCrabCage.CageState.Claimable then
		local primaryPart = model.PrimaryPart
		local v3 = state.data.r and rarities.Rarities[state.data.r]

		if v3 and primaryPart:FindFirstChild("done") then
			primaryPart.done.Color = v3.ColorGradient or ColorSequence.new(v3.Color)
			primaryPart.done.Enabled = state.data.s == SharedCrabCage.CageState.Claimable
		end
	end

	CrabCageController:SetupPrompt(state, model, v2)
	model.Parent = workspace.active.crabcages
	CrabCageController._ActiveModelCount += 1
	return model
end

function CrabCageController:RemoveModel(p)
	if not p.model then
		return
	end

	p.model:Destroy()
	p.model = nil
	p.prompt = nil
	CrabCageController._ActiveModelCount -= 1
end

function CrabCageController:Claim(state)
	if state.pending then
		return
	end

	state.pending = "claim"
	CrabCageController:RemoveModel(state)
	local v, v2 = remoteFunction:InvokeServer(state.id)

	if not v then
		state.pending = nil
		CrabCageController:AddModel(state)
	end

	if v2 then
		ReplicatedStorage.events.anno_localthought:Fire(v2)
	end
end

function CrabCageController:UpdatePromptState(data)
	local prompt = data.prompt

	if prompt then
		if CrabCageController._HeldCage and data.id ~= string.format("%x", 1) then
			prompt.ActionText = "Retrieve"
			prompt.Enabled = data.data.s ~= SharedCrabCage.CageState.Claimable and not (data.pending or CrabCageController._PlaceButtonHeld)
			prompt.ClickablePrompt = UserInputService.PreferredInput == Enum.PreferredInput.Touch
		else
			prompt.ActionText = "Claim"
			prompt.Enabled = data.data.s == SharedCrabCage.CageState.Claimable and not data.pending
			prompt.ClickablePrompt = true
		end
	end
end

function CrabCageController:UpdateAllPromptStates()
	for _, activeCage in CrabCageController.ActiveCages do
		if activeCage.prompt then
			CrabCageController:UpdatePromptState(activeCage)
		end
	end
end

function CrabCageController:Place(p: string, cframe: CFrame)
	local folder, prompt = CrabCageController:CreateModel(p, cframe)

	if module3:GetSettingValue("shownVfx") == "HideAll" then
		folder.Parent = workspace.active.crabcages
	else
		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.LocalTransparencyModifier = 1
			TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
				LocalTransparencyModifier = 0
			}):Play()
		end

		folder.Parent = workspace.active.crabcages;
		(folder.PrimaryPart or folder):PivotTo(folder:GetPivot() + createVector(0, 5, 0))
	end

	fx:PlaySound(sfx.item.cageDeploy, folder.PrimaryPart, true, "FishingSound", localPlayer)
	fx:PlaySound(sfx.item.cageDeploy2, folder.PrimaryPart, true, "FishingSound", localPlayer)
	CrabCageController._Placing = true
	local v2, v3 = remoteFunction2:InvokeServer(cframe, crabcages.byName[p].Id)
	CrabCageController._Placing = false
	CrabCageController._PlaceFinished = tick()
	CrabCageController._PlacingFinished:FireDeferred()

	if v3 then
		ReplicatedStorage.events.anno_localthought:Fire(v3)
	end

	if not v2 then
		folder:Destroy()
		return
	end

	local v4

	repeat
		v4 = CrabCageController.CageAdded:Wait()
	until v4 and v4.id == v2

	CrabCageController:SetupPrompt(v4, folder, prompt)
	v4.model = folder
	v4.prompt = prompt
	v4.pending = nil
	CrabCageController._ActiveModelCount += 1
end

function CrabCageController:OnCatch(data)
	if data.prompt then
		CrabCageController:UpdatePromptState(data)
	end

	local primaryPart = data.model and data.model.PrimaryPart

	if primaryPart then
		fx:PlaySound(sfx.item.cageCatch, primaryPart, true, "FishingSound", localPlayer)
		local v = data.data.r and rarities.Rarities[data.data.r]

		if v then
			if v.BiteSoundName then
				fx:PlaySound(sfx.fishing:WaitForChild(v.BiteSoundName), primaryPart, false, "FishingSound", localPlayer)
			end

			primaryPart.notif.suprise.Color = v.ColorGradient or ColorSequence.new(v.Color)
			primaryPart.done.Color = v.ColorGradient or ColorSequence.new(v.Color)
		end

		primaryPart.notif.suprise:Emit(1)
		primaryPart.done.Enabled = true
	end
end

function CrabCageController.UpdateHotbar()
	local hotbar = module4:GetBackpackGui():FindFirstChild("hotbar")
	local hotbarFolder = hotbar and hotbar:FindFirstChild("Folder")
	local hotbarFolderFrame = hotbarFolder and hotbarFolder:FindFirstChild("Frame")

	if not hotbarFolderFrame then
		print("Cancelled UIUpdate: Could not find hotbar frame")
		return
	end

	local baitcrab = hotbarFolderFrame:FindFirstChild("baitcrab")

	if baitcrab then
		baitcrab:Destroy()
	end

	local bait2 = legacyLocalPlayerData.fetch():WaitForChild("Stats"):WaitForChild("bait")
	local value = bait2.Value

	if value:lower() == "none" then
		return
	end

	local child = bait2:WaitForChild("bait_" .. value)

	if bait2 and value and bait[value] and child then
		local clone = script.baittitle:Clone()
		clone.Name = "baitcrab"

		local function updateDisplay()
			if child.Value <= 0 then
				clone.Visible = false
				return
			end

			local v = bait[value]
			local v2 = v and rarities.Rarities[v.Rarity]

			if v2.ColorGradient then
				clone.Text = `Current Bait: <b>{FischUtils.GradientRichText(value, v2.ColorGradient)}</b> [×{NumberUtils:Comma(child.Value)}]`
			else
				clone.Text = `Current Bait: <b><font color="#{v2 and v2.Color:ToHex()}">{value}</font></b> [×{NumberUtils:Comma(child.Value)}]`
			end

			clone.Visible = true
		end

		updateDisplay()
		clone.Parent = hotbarFolderFrame
		CrabCageController._PreviewTrove:Add(clone)
		CrabCageController._PreviewTrove:Connect(child.Changed, updateDisplay)
	end
end

function CrabCageController:Heartbeat(_: number)
	debug.profilebegin("CrabCageController::Heartbeat")
	local currentCamera = workspace.CurrentCamera

	if tick() - CrabCageController._LastUpdate > constants.CHUNK_UPDATE_RATE and currentCamera then
		debug.profilebegin("chunk calculation")
		local activeChunks = table.create((constants.CHUNK_LOAD_RADIUS * 2 + 1) ^ 3)
		local v2 = currentCamera.Focus.Position // constants.CHUNK_SIZE

		for i = -constants.CHUNK_LOAD_RADIUS, constants.CHUNK_LOAD_RADIUS do
			for i2 = -constants.CHUNK_LOAD_RADIUS, constants.CHUNK_LOAD_RADIUS do
				for i3 = -constants.CHUNK_LOAD_RADIUS, constants.CHUNK_LOAD_RADIUS do
					table.insert(activeChunks, v2 + Vector3.new(i, i2, i3))
				end
			end
		end

		debug.profileend()
		local lastTime = os.clock()
		debug.profilebegin("unload")

		for _, _ActiveChunk in CrabCageController._ActiveChunks do
			if not CrabCageController._Chunks[_ActiveChunk] or table.find(activeChunks, _ActiveChunk) then
				continue
			end

			for _, v3 in CrabCageController._Chunks[_ActiveChunk] do
				if os.clock() - lastTime > constants.CHUNK_MAX_TIME then
					return
				else
					CrabCageController:RemoveModel(CrabCageController.ActiveCages[v3])
				end
			end
		end

		debug.profileend()
		CrabCageController._ActiveChunks = activeChunks
		debug.profilebegin("load")

		for _, v3 in activeChunks do
			if not CrabCageController._Chunks[v3] then
				continue
			end

			for _, v4 in CrabCageController._Chunks[v3] do
				if os.clock() - lastTime > constants.CHUNK_MAX_TIME then
					return
				end

				if not CrabCageController.ActiveCages[v4].pending then
					CrabCageController:AddModel(CrabCageController.ActiveCages[v4])
				end
			end
		end

		debug.profileend()
		CrabCageController._LastUpdate = tick()
	end

	debug.profileend()
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace:WaitForChild("zones"):WaitForChild("fishing") }

function CrabCageController:RenderStepped(p: number)
	local _PreviewModel = CrabCageController._PreviewModel
	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildWhichIsA("Humanoid")
	local currentCamera = workspace.CurrentCamera

	if _PreviewModel and humanoidRootPart and humanoid and currentCamera then
		debug.profilebegin("CrabCageController: Placement Preview")
		local origin = localPlayer:GetMouse().Origin

		if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
			origin = currentCamera.CFrame
		end

		if not UserInputService:GetFocusedTextBox() and crabCagePlacing.RotateCrabCage:GetState() ~= 0 then
			CrabCageController._Rotation += p * 90 * crabCagePlacing.RotateCrabCage:GetState()
		end

		local raycastResult = workspace:Raycast(origin.Position, origin.LookVector * 256, raycastParams)

		if raycastResult and (humanoidRootPart.Position - raycastResult.Position).Magnitude <= constants.PLACE_RANGE and raycastResult.Normal.Y > 0.1 then
			if constants.ALLOWED_STATES[humanoid:GetState()] then
				local cframe = CFrame.lookAt(raycastResult.Position, humanoidRootPart.Position)
				local v = SharedCrabCage:RoundCFrame(raycastResult.Position, cframe) * CFrame.fromOrientation(
					0,
					math.rad((math.round(CrabCageController._Rotation))),
					0
				)
				_PreviewModel:PivotTo(v)
				local occupancyCheck, v2 = SharedCrabCage:OccupancyCheck(v)

				if occupancyCheck then
					occupancyCheck, v2 = SharedCrabCage:FindZone(v, crabcages.byName[CrabCageController._HeldCage].Id)
				end

				for _, part in _PreviewModel:GetDescendants() do
					if part:IsA("BasePart") then
						part.Color = occupancyCheck and Color3.fromRGB(125, 255, 105) or Color3.fromRGB(33, 33, 33)
					end
				end

				if occupancyCheck then
					CrabCageController._CurrentError = nil
				else
					CrabCageController._CurrentError = v2 or "You can't place a Crab Cage here."
				end
			else
				CrabCageController._CurrentError = "You must have steady footing to place a Crab Cage."
				_PreviewModel:PivotTo(CFrame.identity)
			end
		else
			CrabCageController._CurrentError = "You're too far away!"
			_PreviewModel:PivotTo(CFrame.identity)
		end

		debug.profileend()
	end

	if module3:GetSettingValue("shownVfx") ~= "HideAll" and not CrabCageController._BobWaiting then
		CrabCageController._BobWaiting = true
		local lastTime = os.clock()

		for _, activeCage in CrabCageController.ActiveCages do
			if os.clock() - lastTime > constants.CHUNK_MAX_TIME / 2 then
				RunService.RenderStepped:Wait()
				lastTime = os.clock()
			end

			local primaryPart = activeCage.model and activeCage.model.PrimaryPart

			if not primaryPart then
				continue
			end

			local v = activeCage.pos + Vector3.new(
				0,
				math.sin((tick() + activeCage.time_offset) / constants.BOBBING_TIME) * constants.BOBBING_HEIGHT,
				0
			)
			local smoothDamp, vel = TweenService:SmoothDamp(
				primaryPart:GetPivot(),
				v,
				activeCage.vel,
				0.25,
				nil,
				tick() - activeCage.last_update
			)
			primaryPart:PivotTo(smoothDamp)
			activeCage.vel = vel
			activeCage.last_update = tick()
		end

		CrabCageController._BobWaiting = false
	end
end

function CrabCageController.Start(_)
	if FischUtils.IsTradePlaza() then
		return
	end

	playerDataReplicator:WaitForLoaded()
	playerDataReplicator:Observe({ "CrabCages" }, function(items)
		if CrabCageController._Placing then
			CrabCageController._PlacingFinished:Wait()
		end

		local _ActualOldValue = CrabCageController._ActualOldValue
		CrabCageController._ActualOldValue = GeneralUtils.copy(items, true)
		local v = {}

		for k, item in items do
			v[k] = true

			if CrabCageController.ActiveCages[k] then
				local activeCage = CrabCageController.ActiveCages[k]
				activeCage.data = item

				if _ActualOldValue and _ActualOldValue[k] and _ActualOldValue[k].s ~= item.s then
					CrabCageController.CageStateChanged:Fire(activeCage, item.s, _ActualOldValue[k].s)
				end
			else
				local cFrameFromSerialized = SharedCrabCage:CFrameFromSerialized(item.p)
				local v2 = {
					id = k,
					data = item,
					pos = cFrameFromSerialized,
					model = nil,
					prompt = nil,
					pending = nil,
					vel = CFrame.identity,
					time_offset = (cFrameFromSerialized.X + cFrameFromSerialized.Z) * constants.BOBBING_TIME / 2,
					last_update = tick()
				}
				CrabCageController.ActiveCages[k] = v2
				local v3 = cFrameFromSerialized.Position // constants.CHUNK_SIZE

				if not CrabCageController._Chunks[v3] then
					CrabCageController._Chunks[v3] = {}
				end

				table.insert(CrabCageController._Chunks[v3], k)
				CrabCageController.CageAdded:Fire(v2)
			end
		end

		for k, v2 in table.clone(CrabCageController.ActiveCages) do
			if v[k] then
				continue
			end

			CrabCageController.ActiveCages[k] = nil
			local v3 = v2.pos.Position // constants.CHUNK_SIZE
			local _Chunk = CrabCageController._Chunks[v3]
			local index = _Chunk and table.find(_Chunk, k)

			if index then
				table.remove(_Chunk, index)
			end

			CrabCageController.CageRemoved:Fire(v2)
			local v4 = v2
			task.defer(function()
				if v4.model then
					v4.model:Destroy()
					v4.model = nil
					v4.prompt = nil
				end
			end)
		end
	end)
	local crabCageMobile = module4:GetPlayerGui():WaitForChild("CrabCageMobile")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateMobileGui()
		crabCageMobile.Enabled = UserInputService.PreferredInput == Enum.PreferredInput.Touch and CrabCageController._HeldCage ~= nil and not CrabCageController._CurrentError
	end

	RunService.Heartbeat:Connect(function(dt)
		CrabCageController:Heartbeat(dt)
	end)
	RunService.RenderStepped:Connect(function(dt)
		CrabCageController:RenderStepped(dt)

		if CrabCageController._HeldCage ~= nil then
			updateMobileGui() -- equivalent call inferred; original call site unknown
		end
	end)
	module2.EquippedToolChanged:Connect(function(data)
		CrabCageController._PreviewTrove:Clean()

		if data or not CrabCageController._HeldCage then
			if data and crabcages.byName[data.Name] then
				CrabCageController._HeldCage = data.Name
				CrabCageController:UpdateAllPromptStates()
				updateMobileGui() -- equivalent call inferred; original call site unknown
				CrabCageController._IsHoldingPrompt = false

				if CrabCageController._CurrentPrompt then
					CrabCageController._CurrentPrompt:InputHoldEnd()
				end

				task.spawn(CrabCageController.UpdateHotbar)
				local model = CrabCageController:CreateModel(data.Name, CFrame.identity)
				local cage = model:FindFirstChild("Cage") or model
				cage.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
				cage:ScaleTo(cage:GetScale() * 1.01)
				CrabCageController._PreviewModel = cage

				for _, part in cage:GetDescendants() do
					if not part:IsA("BasePart") then
						continue
					end

					part.Material = Enum.Material.SmoothPlastic
					part.Anchored = true
					part.CanCollide = false
					part.CanTouch = false
					part.CanQuery = false
				end

				cage.Parent = workspace.CurrentCamera
				model:Destroy()
				CrabCageController._PreviewTrove:Add(cage)
				CrabCageController._PreviewTrove:Add(function()
					CrabCageController._PlaceButtonHeld = nil
					CrabCageController._PreviewModel = nil
				end)
				CrabCageController._PreviewTrove:Connect(data.Activated, function()
					if CrabCageController._Placing or tick() - CrabCageController._PlaceFinished < constants.PLACE_INTERVAL or UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
						return
					end

					local now = tick()
					CrabCageController._PlaceButtonHeld = now
					CrabCageController:UpdateAllPromptStates()

					while CrabCageController._PlaceButtonHeld == now do
						if CrabCageController._CurrentError then
							ReplicatedStorage.events.anno_localthought:Fire(CrabCageController._CurrentError)
						else
							CrabCageController:Place(CrabCageController._HeldCage, cage:GetPivot())
						end

						task.wait(constants.PLACE_INTERVAL)
					end
				end)
				CrabCageController._PreviewTrove:Connect(data.Deactivated, function()
					if UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
						return
					end

					CrabCageController._PlaceButtonHeld = nil
					CrabCageController:UpdateAllPromptStates()
				end)
			end
		else
			CrabCageController._HeldCage = nil
			CrabCageController._Rotation = 0
			CrabCageController:UpdateAllPromptStates()
			updateMobileGui() -- equivalent call inferred; original call site unknown
		end
	end)
	CrabCageController.CageStateChanged:Connect(function(p, p2)
		if p2 == SharedCrabCage.CageState.Claimable then
			CrabCageController:OnCatch(p)
		end
	end)
	ProximityPromptService.PromptButtonHoldBegan:Connect(function(instance)
		if instance:GetAttribute("TargetCage") then
			CrabCageController._IsHoldingPrompt = true
		end
	end)
	ProximityPromptService.PromptTriggered:Connect(function(player)
		local targetCage = player:GetAttribute("TargetCage")

		if targetCage then
			CrabCageController:Claim(CrabCageController.ActiveCages[targetCage])
		end
	end)
	ProximityPromptService.PromptShown:Connect(function(currentPrompt)
		task.wait()

		if currentPrompt:GetAttribute("TargetCage") and CrabCageController._IsHoldingPrompt then
			currentPrompt:InputHoldBegin()
			CrabCageController._CurrentPrompt = currentPrompt
		end
	end)
	ProximityPromptService.PromptHidden:Connect(function(p)
		if p == CrabCageController._CurrentPrompt then
			CrabCageController._CurrentPrompt = nil
		end
	end)
	crabCageMobile.container.button.MouseButton1Down:Connect(function()
		if CrabCageController._Placing or tick() - CrabCageController._PlaceFinished < constants.PLACE_INTERVAL then
			return
		end

		local now = tick()
		CrabCageController._PlaceButtonHeld = now
		CrabCageController:UpdateAllPromptStates()

		while CrabCageController._PlaceButtonHeld == now and CrabCageController._PreviewModel do
			if CrabCageController._CurrentError then
				ReplicatedStorage.events.anno_localthought:Fire(CrabCageController._CurrentError)
			else
				CrabCageController:Place(CrabCageController._HeldCage, CrabCageController._PreviewModel:GetPivot())
			end

			task.wait(constants.PLACE_INTERVAL)
		end
	end)
	crabCageMobile.container.button.MouseButton1Up:Connect(function()
		CrabCageController._PlaceButtonHeld = nil
		CrabCageController:UpdateAllPromptStates()
	end)
	crabCageMobile:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not crabCageMobile.Enabled and CrabCageController._PlaceButtonHeld then
			CrabCageController._PlaceButtonHeld = nil
			CrabCageController:UpdateAllPromptStates()
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.ButtonX or input.KeyCode == Enum.KeyCode.ButtonA or input.UserInputType == Enum.UserInputType.MouseButton1 and not UserInputService:IsKeyDown(Enum.KeyCode.E) or input.UserInputType == Enum.UserInputType.Touch then
			CrabCageController._IsHoldingPrompt = false

			if CrabCageController._CurrentPrompt then
				CrabCageController._CurrentPrompt:InputHoldEnd()
			end
		end
	end)
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		CrabCageController:UpdateAllPromptStates()
	end)
end

return CrabCageController