local createVector = vector.create
local CataloguePreviewHelper = {}
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer

local function _isGuiObject(guiObject)
	return typeof(guiObject) == "Instance" and guiObject:IsA("GuiObject")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _styleTextButton(textButton, color, color2)
	textButton.AutoButtonColor = true
	textButton.BackgroundColor3 = color
	textButton.BorderSizePixel = 0
	textButton.Font = Enum.Font.GothamBold
	textButton.TextColor3 = color2
	textButton.TextSize = 16
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 8)
	uICorner.Parent = textButton
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _findRootPart(model)
	if typeof(model) == "Instance" and model:IsA("Model") and model.Parent then
		return model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _getCFrameFromProps(p)
	local position = p.Position or createVector(0, 0, 0)
	local rotation = p.Rotation or createVector(0, 0, 0)
	return CFrame.new(position) * CFrame.fromEulerAnglesYXZ(
		math.rad(rotation.X),
		math.rad(rotation.Y),
		(math.rad(rotation.Z))
	)
end

local function _lerp(p, p2, p3)
	local success, result = pcall(function()
		return TweenService:GetValue(p3, p, p2)
	end)

	if success then
		p3 = result or p3
	end

	return p3
end

local function _parsePoseData(poseData)
	if type(poseData) == "table" then
		return poseData
	end

	if type(poseData) ~= "string" or poseData == "" then
		return {}
	end

	local success, result = pcall(HttpService.JSONDecode, HttpService, poseData)

	if not success or type(result) ~= "table" then
		warn("[CataloguePreview] pose decode failed: " .. tostring(result))
		return {}
	end

	local result2 = {}

	for _, v in ipairs(result) do
		local position = v.Position or { 0, 0, 0 }
		local rotation = v.Rotation or { 0, 0, 0 }
		table.insert(result2, {
			Time = tonumber(v.Time) or 0,
			TargetName = tostring(v.TargetName or ""),
			Position = Vector3.new(position[1] or 0, position[2] or 0, position[3] or 0),
			Rotation = Vector3.new(rotation[1] or 0, rotation[2] or 0, rotation[3] or 0),
			EasingStyle = Enum.EasingStyle[tostring(v.EasingStyle or "Quad")] or Enum.EasingStyle.Quad,
			EasingDirection = Enum.EasingDirection[tostring(v.EasingDirection or "Out")] or Enum.EasingDirection.Out
		})
	end

	return result2
end

local function _groupPosesByTarget(list)
	local v = {}
	local result = {}
	local targetNames = {}

	for _, v2 in ipairs(list) do
		local targetName = tostring(v2.TargetName or "")

		if targetName == "" then
			continue
		end

		if not v[targetName] then
			v[targetName] = true
			result[targetName] = {}
			table.insert(targetNames, targetName)
		end

		table.insert(result[targetName], v2)
	end

	for _, list2 in pairs(result) do
		table.sort(list2, function(a, b)
			return (tonumber(a.Time) or 0) < (tonumber(b.Time) or 0)
		end)
	end

	return result, targetNames
end

local function _ensureDummyClone(state)
	if state.dummy and state.dummy.Parent == state.worldModel then
		return state.dummy
	end

	if state.dummy then
		state.dummy:Destroy()
		state.dummy = nil
	end

	local assetTemplates = ReplicatedStorage:FindFirstChild("AssetTemplates")
	local characters = assetTemplates and assetTemplates:FindFirstChild("Characters")
	local dummy = characters and characters:FindFirstChild("Dummy")

	if not (dummy and dummy:IsA("Model")) then
		return nil
	end

	local clone = dummy:Clone()
	clone.Name = "CataloguePreviewDummy"
	clone.Parent = state.worldModel
	clone:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, 3.141592653589793, 0))
	state.dummy = clone
	state.motorCache = nil
	return clone
end

local function _getMotorForTarget(state, p)
	local dummy = state.dummy

	if not (dummy and dummy.Parent) then
		return nil
	end

	state.motorCache = state.motorCache or {}

	if state.motorCache[p] and state.motorCache[p].Parent then
		return state.motorCache[p]
	end

	for _, motor6D in ipairs(dummy:GetDescendants()) do
		if not (motor6D:IsA("Motor6D") and motor6D.Part1 and motor6D.Part1.Name == p) then
			continue
		end

		state.motorCache[p] = motor6D
		return motor6D
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _applyTransform(p, p2, transform)
	local v = _getMotorForTarget(p, p2)

	if v then
		v.Transform = transform
	end
end

local function _resetTransforms(state)
	local dummy = state.dummy

	if not dummy then
		return
	end

	for _, motor6D in ipairs(dummy:GetDescendants()) do
		if motor6D:IsA("Motor6D") then
			motor6D.Transform = CFrame.identity
		end
	end
end

local function _scrubCreatedAnimation(state, activePreviewData, p)
	local _poseData = activePreviewData._poseData or {}
	local _poseGroups = activePreviewData._poseGroups or {}
	local _poseOrder = activePreviewData._poseOrder or {}

	if #_poseData == 0 then
		return
	end

	for _, v in ipairs(_poseOrder) do
		local _poseGroup = _poseGroups[v]

		if not (_poseGroup and #_poseGroup ~= 0) then
			continue
		end

		if p <= _poseGroup[1].Time then
			local transform = _getCFrameFromProps(_poseGroup[1]) -- equivalent call inferred; original call site unknown
			_applyTransform(state, v, transform) -- equivalent call inferred; original call site unknown
		elseif _poseGroup[#_poseGroup].Time <= p then
			local transform = _getCFrameFromProps(_poseGroup[#_poseGroup]) -- equivalent call inferred; original call site unknown
			_applyTransform(state, v, transform) -- equivalent call inferred; original call site unknown
		else
			for i = 1, #_poseGroup - 1 do
				local v2 = _poseGroup[i]
				local v3 = _poseGroup[i + 1]

				if not (v2.Time <= p and p < v3.Time) then
					continue
				end

				local v4 = v3.Time - v2.Time
				local v5 = not (v4 > 0) and 0 or (p - v2.Time) / v4
				local easingStyle = v3.EasingStyle or Enum.EasingStyle.Quad
				local easingDirection = v3.EasingDirection or Enum.EasingDirection.Out
				local v6 = v5
				local success, result = pcall(function()
					return TweenService:GetValue(v6, easingStyle, easingDirection)
				end)

				if success then
					v5 = result or v5
				end

				local v9 = _getCFrameFromProps(v2) -- equivalent call inferred; original call site unknown
				local lerped = v9:Lerp(_getCFrameFromProps(v3), v5)
				local v10 = _getMotorForTarget(state, v)

				if not v10 then
					break
				end

				v10.Transform = lerped
				break
			end
		end
	end
end

local function _setCamera(state)
	if not (state.camera and state.dummy) then
		return
	end

	local humanoidRootPart = state.dummy:FindFirstChild("HumanoidRootPart") or state.dummy.PrimaryPart

	if not humanoidRootPart then
		state.camera.CFrame = CFrame.new(createVector(0, 2.3, 7.5), createVector(0, 1.3, 0))
		return
	end

	local position = humanoidRootPart.Position
	state.camera.CFrame = CFrame.new(position + createVector(0, 2.3, 7.5), position + createVector(0, 1.3, 0))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _disconnectSceneRenderConn(p)
	if p and p.sceneRenderConn then
		p.sceneRenderConn:Disconnect()
		p.sceneRenderConn = nil
	end
end

local function _ensureSceneCamera(p)
	if not p then
		return nil
	end

	local sceneCamera = p.sceneCamera

	if sceneCamera and sceneCamera.Parent then
		return sceneCamera
	end

	local camera = Instance.new("Camera")
	camera.Name = "CataloguePreviewCamera"
	camera.Parent = Workspace
	p.sceneCamera = camera
	return camera
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _parkSceneCamera(p)
	if not p then
		return
	end

	local sceneCamera = p.sceneCamera

	if sceneCamera and sceneCamera.Parent then
		pcall(function()
			sceneCamera.Parent = Workspace.Terrain
		end)
	end
end

local function _clearScenePreviewFx()
	if type(_G.cancelMoveEditorEffectTweens) == "function" then
		pcall(_G.cancelMoveEditorEffectTweens, "catalogue_preview_exit")
		return
	end

	if type(_G.cancelMoveEditorFovEventTweens) == "function" then
		pcall(_G.cancelMoveEditorFovEventTweens, "catalogue_preview_exit")
	end

	if type(_G.cancelMoveEditorColorCorrectionEventTweens) == "function" then
		pcall(_G.cancelMoveEditorColorCorrectionEventTweens, "catalogue_preview_exit")
	end

	if type(_G.cancelMoveEditorCamshake) == "function" then
		pcall(_G.cancelMoveEditorCamshake)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _computePreviewStageCenter(userId)
	local v = math.max(1, tonumber(userId) or 1) % 36
	local v2 = math.floor(v / 6)
	return createVector(-16000, 650, 16000) + Vector3.new(v % 6 * 280, 0, v2 * 280)
end

local function _setSceneInputCapture(p, p2)
	if not p or UserInputService.TouchEnabled then
		return
	end

	if p2 == true then
		if p.sceneModalPrev == nil then
			p.sceneModalPrev = UserInputService.ModalEnabled
		end

		UserInputService.ModalEnabled = true
	elseif p.sceneModalPrev ~= nil then
		UserInputService.ModalEnabled = p.sceneModalPrev
		p.sceneModalPrev = nil
	end
end

function CataloguePreviewHelper:_getFreecamModule()
	if not self then
		return nil
	end

	if self.sceneFreecamChecked then
		return self.sceneFreecamModule
	end

	self.sceneFreecamChecked = true
	local moduleScripts = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function push(moduleScript)
		if moduleScript and moduleScript:IsA("ModuleScript") then
			table.insert(moduleScripts, moduleScript)
		end
	end

	local moveEditor = game:FindFirstChild("MoveEditor", true)
	local freecam = moveEditor and moveEditor:FindFirstChild("Freecam")
	push(freecam) -- equivalent call inferred; original call site unknown
	push(script:FindFirstChild("Freecam")) -- equivalent call inferred; original call site unknown
	local freecam3 = script.Parent and script.Parent:FindFirstChild("Freecam")
	push(freecam3) -- equivalent call inferred; original call site unknown
	push(game:FindFirstChild("Freecam", true)) -- equivalent call inferred; original call site unknown

	for _, v in ipairs(moduleScripts) do
		local success, result = pcall(require, v)

		if not (success and type(result) == "table" and type(result.StartFreecam) == "function" and type(result.StopFreecam) == "function") then
			continue
		end

		self.sceneFreecamModule = result
		warn("[CataloguePreview] freecam module=" .. tostring(v:GetFullName()))
		break
	end

	if not self.sceneFreecamModule then
		warn("[CataloguePreview] freecam module missing")
	end

	return self.sceneFreecamModule
end

function CataloguePreviewHelper:_startSceneFreecam(cFrame, position, p)
	if not self then
		return false
	end

	if p == true and self.sceneFreecamActive then
		CataloguePreviewHelper._stopSceneFreecam(self)
	end

	local v

	if self then
		v = self.sceneCamera

		if not (v and v.Parent) then
			v = Instance.new("Camera")
			v.Name = "CataloguePreviewCamera"
			v.Parent = Workspace
			self.sceneCamera = v
		end
	else
		v = nil
	end

	if not v then
		return false
	end

	pcall(function()
		v.Parent = Workspace
		v.CameraType = Enum.CameraType.Scriptable
		v.CameraSubject = nil

		if typeof(cFrame) == "CFrame" then
			v.CFrame = cFrame
		end

		if typeof(position) == "Vector3" then
			v.Focus = CFrame.new(position)
		end

		Workspace.CurrentCamera = v
	end)

	if self.sceneFreecamActive then
		return true
	end

	local _getFreecamModule = CataloguePreviewHelper._getFreecamModule(self)

	if not _getFreecamModule then
		return true
	end

	self.sceneFreecamStartToken = (self.sceneFreecamStartToken or 0) + 1
	local sceneFreecamStartToken = self.sceneFreecamStartToken
	task.defer(function()
		if not (CataloguePreviewHelper._state == self and self.sceneFreecamStartToken == sceneFreecamStartToken) then
			return
		end

		if Workspace.CurrentCamera ~= v then
			pcall(function()
				Workspace.CurrentCamera = v
			end)
		end

		task.wait()

		if not (CataloguePreviewHelper._state == self and self.sceneFreecamStartToken == sceneFreecamStartToken and Workspace.CurrentCamera == v) then
			return
		end

		local success, result = pcall(_getFreecamModule.StartFreecam)

		if not success then
			warn("[CataloguePreview] freecam start failed: " .. tostring(result))
			return
		end

		self.sceneFreecamActive = true
		warn(string.format(
			"[CataloguePreview] freecam start entry=%s token=%s",
			tostring(self.activeEntry and self.activeEntry.id or ""),
			(tostring(self.activeScene and self.activeScene.token or ""))
		))
	end)
	return true
end

function CataloguePreviewHelper:_stopSceneFreecam()
	if self and self.sceneFreecamActive then
		self.sceneFreecamStartToken = (self.sceneFreecamStartToken or 0) + 1
		local _getFreecamModule = CataloguePreviewHelper._getFreecamModule(self)

		if _getFreecamModule then
			local success, result = pcall(_getFreecamModule.StopFreecam)

			if not success then
				warn("[CataloguePreview] freecam stop failed: " .. tostring(result))
			end
		end

		self.sceneFreecamActive = false
	elseif self then
		self.sceneFreecamStartToken = (self.sceneFreecamStartToken or 0) + 1
	end
end

function CataloguePreviewHelper:_setScenePlayEnabled(p, text)
	if not (self and self.scenePlayBtn) then
		return
	end

	local v = p == true
	self.scenePlayBtn.Active = v
	self.scenePlayBtn.AutoButtonColor = v
	self.scenePlayBtn.TextTransparency = v and 0 or 0.2
	self.scenePlayBtn.BackgroundColor3 = v and Color3.fromRGB(52, 110, 79) or Color3.fromRGB(41, 63, 52)
	self.scenePlayReadyAt = v and 0 or os.clock() + 0.5

	if text and self.sceneMenuStatusLabel and self.sceneMenuPanel and self.sceneMenuPanel.Visible then
		self.sceneMenuStatusLabel.Text = text
	end
end

function CataloguePreviewHelper:_prepareSceneStage()
	if not self or type(self.requestFn) ~= "function" then
		return
	end

	local scenePendingEntry = self.scenePendingEntry or self.activeEntry

	if type(scenePendingEntry) ~= "table" then
		return
	end

	CataloguePreviewHelper._setScenePlayEnabled(self, false, "Preparing theater...")
	local scenePrepareToken = (self.scenePrepareToken or 0) + 1
	self.scenePrepareToken = scenePrepareToken
	task.spawn(function()
		local fn = self.requestFn("PrepareEntryPreviewScene", {
			entryId = tostring(scenePendingEntry.id or "")
		}, 1)

		if not (CataloguePreviewHelper._state == self and self.scenePrepareToken == scenePrepareToken) then
			return
		end

		if typeof(fn) == "table" and fn.ok ~= false then
			if type(fn.scene) == "table" then
				self.scenePrepared = fn.scene
			end

			warn(string.format(
				"[CataloguePreview] prepare scene ready entry=%s token=%s",
				tostring(scenePendingEntry.id or ""),
				(tostring(fn.scene and fn.scene.token or ""))
			))
			local scenePlayGateToken = (self.scenePlayGateToken or 0) + 1
			self.scenePlayGateToken = scenePlayGateToken
			task.delay(0.5, function()
				if not (CataloguePreviewHelper._state == self and self.scenePrepareToken == scenePrepareToken and self.scenePlayGateToken == scenePlayGateToken) then
					return
				end

				if not (self.sceneOverlay and self.sceneOverlay.Visible) then
					return
				end

				CataloguePreviewHelper._setScenePlayEnabled(self, true)

				if self.sceneMenuStatusLabel and self.sceneMenuPanel and self.sceneMenuPanel.Visible then
					if self.scenePendingSlotKey then
						self.sceneMenuStatusLabel.Text = "Press PLAY to preview the selected slot."
					else
						self.sceneMenuStatusLabel.Text = "Choose a slot, then press PLAY."
					end
				end
			end)
		else
			warn(string.format(
				"[CataloguePreview] prepare scene failed entry=%s err=%s",
				tostring(scenePendingEntry.id or ""),
				(tostring(fn and fn.error or "unknown"))
			))

			if CataloguePreviewHelper._state == self and self.scenePrepareToken == scenePrepareToken and self.sceneMenuStatusLabel and self.sceneMenuPanel and self.sceneMenuPanel.Visible then
				self.sceneMenuStatusLabel.Text = "Theater failed to prepare."
			end
		end
	end)
end

function CataloguePreviewHelper:_enterIdleSceneView(text)
	if not self then
		return
	end

	if self and not UserInputService.TouchEnabled then
		if self.sceneModalPrev == nil then
			self.sceneModalPrev = UserInputService.ModalEnabled
		end

		UserInputService.ModalEnabled = true
	end

	self.scenePlaybackAligned = false
	local currentCamera = Workspace.CurrentCamera

	if currentCamera and not self.prevCameraState then
		self.prevCameraState = {
			CameraObject = currentCamera,
			CameraType = currentCamera.CameraType,
			CameraSubject = currentCamera.CameraSubject,
			CFrame = currentCamera.CFrame
		}
	end

	local v = _computePreviewStageCenter(localPlayer and localPlayer.UserId or 0) + createVector(0, 2.2, 0)
	local cframe = CFrame.new(v + createVector(5.5, 6.4, 15.5), v)
	CataloguePreviewHelper._startSceneFreecam(self, cframe, v, true)

	if self.sceneSubtitleLabel and text then
		self.sceneSubtitleLabel.Text = text
	end
end

function CataloguePreviewHelper:_setSceneActionCooldown(p2)
	if not self then
		return
	end

	self.sceneActionCooldownUntil = os.clock() + math.max(0, tonumber(p2) or 0.5)
end

function CataloguePreviewHelper._sceneActionCoolingDown(p)
	return p and p.sceneActionCooldownUntil and os.clock() < p.sceneActionCooldownUntil
end

function CataloguePreviewHelper._refreshPreparedStage(data)
	if not data then
		return
	end

	CataloguePreviewHelper._setSceneActionCooldown(data, 0.5)
	CataloguePreviewHelper._prepareSceneStage(data)

	if data.sceneSubtitleLabel then
		data.sceneSubtitleLabel.Text = "Press PLAY to start the selected preview."
	end

	if data.sceneMenuStatusLabel and data.sceneMenuPanel and data.sceneMenuPanel.Visible then
		data.sceneMenuStatusLabel.Text = "Refreshing preview stage..."
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _refreshExternalHostChrome(data)
	if not data then
		return
	end

	local useExternalTheaterButton = data.useExternalTheaterButton == true

	if data.titleLabel then
		data.titleLabel.Visible = not useExternalTheaterButton
	end

	if data.statusLabel then
		data.statusLabel.Visible = not useExternalTheaterButton
	end
end

function CataloguePreviewHelper.init(data)
	local host = data and data.host
	local v

	if typeof(host) == "Instance" then
		v = host:IsA("GuiObject")
	else
		v = false
	end

	if not v then
		return nil
	end

	local _state = CataloguePreviewHelper._state

	if _state and _state.host == host then
		if type(data.requestFn) == "function" then
			_state.requestFn = data.requestFn
		end

		if type(data and data.suppressTargets) == "table" then
			_state.suppressTargets = data.suppressTargets
		end

		_state.useExternalTheaterButton = data and data.useExternalTheaterButton == true
		_refreshExternalHostChrome(_state) -- equivalent call inferred; original call site unknown
		return _state
	else
		local requestFn

		if type(data and data.requestFn) == "function" then
			requestFn = data.requestFn or nil
		end

		local suppressTargets

		if type(data and data.suppressTargets) == "table" then
			suppressTargets = data.suppressTargets or nil
		end

		local state = {
			host = host,
			requestFn = requestFn,
			suppressTargets = suppressTargets,
			useExternalTheaterButton = data and data.useExternalTheaterButton == true,
			token = 0,
			playToken = 0,
			panelMode = "none"
		}
		CataloguePreviewHelper._state = state
		local frame = Instance.new("Frame")
		frame.Name = "CataloguePreviewRoot"
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.Visible = false
		frame.ZIndex = 6
		frame.Parent = host
		state.root = frame
		local viewportFrame = Instance.new("ViewportFrame")
		viewportFrame.Name = "Viewport"
		viewportFrame.BackgroundColor3 = Color3.fromRGB(26, 27, 32)
		viewportFrame.BorderSizePixel = 0
		viewportFrame.Position = UDim2.new(0, 8, 0, 8)
		viewportFrame.Size = UDim2.new(1, -16, 1, -56)
		viewportFrame.ZIndex = 6
		viewportFrame.Ambient = Color3.fromRGB(210, 215, 230)
		viewportFrame.LightColor = Color3.fromRGB(255, 255, 255)
		viewportFrame.LightDirection = createVector(-0.4, -0.8, -0.2)
		viewportFrame.Parent = frame
		state.viewport = viewportFrame
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(0, 10)
		uICorner.Parent = viewportFrame
		local camera = Instance.new("Camera")
		camera.Parent = viewportFrame
		viewportFrame.CurrentCamera = camera
		state.camera = camera
		local worldModel = Instance.new("WorldModel")
		worldModel.Name = "PreviewWorld"
		worldModel.Parent = viewportFrame
		state.worldModel = worldModel
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "TitleLabel"
		textLabel.BackgroundTransparency = 1
		textLabel.Position = UDim2.new(0, 12, 0, 10)
		textLabel.Size = UDim2.new(1, -24, 0, 20)
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextColor3 = Color3.fromRGB(255, 179, 38)
		textLabel.TextSize = 17
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.ZIndex = 7
		textLabel.Text = "Preview Theater"
		textLabel.Parent = frame
		state.titleLabel = textLabel
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Name = "StatusLabel"
		textLabel2.BackgroundTransparency = 1
		textLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel2.Position = UDim2.new(0.5, 0, 0.5, -8)
		textLabel2.Size = UDim2.new(0.8, 0, 0, 48)
		textLabel2.Font = Enum.Font.GothamMedium
		textLabel2.TextColor3 = Color3.fromRGB(230, 232, 240)
		textLabel2.TextSize = 16
		textLabel2.TextWrapped = true
		textLabel2.ZIndex = 8
		textLabel2.Text = "Open a created animation to preview it here."
		textLabel2.Parent = frame
		state.statusLabel = textLabel2
		_refreshExternalHostChrome(state) -- equivalent call inferred; original call site unknown
		local scrollingFrame = Instance.new("ScrollingFrame")
		scrollingFrame.Name = "SlotScroll"
		scrollingFrame.BackgroundTransparency = 1
		scrollingFrame.BorderSizePixel = 0
		scrollingFrame.Position = UDim2.new(0, 12, 0, 40)
		scrollingFrame.Size = UDim2.new(1, -24, 1, -92)
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
		scrollingFrame.ScrollBarThickness = 6
		scrollingFrame.Visible = false
		scrollingFrame.ZIndex = 7
		scrollingFrame.Parent = frame
		state.slotScroll = scrollingFrame
		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.Padding = UDim.new(0, 6)
		uIListLayout.Parent = scrollingFrame
		state.slotLayout = uIListLayout
		local frame2 = Instance.new("Frame")
		frame2.Name = "Footer"
		frame2.BackgroundTransparency = 1
		frame2.Position = UDim2.new(0, 8, 1, -40)
		frame2.Size = UDim2.new(1, -16, 0, 32)
		frame2.ZIndex = 7
		frame2.Parent = frame
		local uIListLayout2 = Instance.new("UIListLayout")
		uIListLayout2.FillDirection = Enum.FillDirection.Horizontal
		uIListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Right
		uIListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
		uIListLayout2.Padding = UDim.new(0, 8)
		uIListLayout2.Parent = frame2
		local textButton = Instance.new("TextButton")
		textButton.Name = "ReplayButton"
		textButton.Size = UDim2.new(0, 96, 1, 0)
		textButton.Text = "REPLAY"
		textButton.Visible = false
		textButton.ZIndex = 7
		_styleTextButton(textButton, Color3.fromRGB(61, 78, 124), Color3.fromRGB(255, 255, 255)) -- equivalent call inferred; original call site unknown
		textButton.Parent = frame2
		state.replayBtn = textButton
		local textButton2 = Instance.new("TextButton")
		textButton2.Name = "StopButton"
		textButton2.Size = UDim2.new(0, 84, 1, 0)
		textButton2.Text = "STOP"
		textButton2.Visible = false
		textButton2.ZIndex = 7
		_styleTextButton(textButton2, Color3.fromRGB(97, 53, 53), Color3.fromRGB(255, 255, 255)) -- equivalent call inferred; original call site unknown
		textButton2.Parent = frame2
		state.stopBtn = textButton2
		local textButton3 = Instance.new("TextButton")
		textButton3.Name = "PrimaryActionButton"
		textButton3.Size = UDim2.new(0, 156, 1, 0)
		textButton3.Text = "OPEN THEATER"
		textButton3.Visible = false
		textButton3.ZIndex = 7
		_styleTextButton(textButton3, Color3.fromRGB(52, 110, 79), Color3.fromRGB(255, 255, 255)) -- equivalent call inferred; original call site unknown
		textButton3.Parent = frame2
		state.primaryActionBtn = textButton3
		local screenGui = host:FindFirstAncestorOfClass("ScreenGui")

		if screenGui then
			local frame3 = Instance.new("Frame")
			frame3.Name = "CatalogueSceneOverlay"
			frame3.BackgroundColor3 = Color3.fromRGB(5, 6, 8)
			frame3.BackgroundTransparency = 1
			frame3.Size = UDim2.fromScale(1, 1)
			frame3.Visible = false
			frame3.ZIndex = 40
			frame3.Parent = screenGui
			state.sceneOverlay = frame3
			local frame4 = Instance.new("Frame")
			frame4.Name = "Header"
			frame4.BackgroundTransparency = 1
			frame4.Position = UDim2.new(0, 24, 0, 20)
			frame4.Size = UDim2.new(1, -48, 0, 42)
			frame4.ZIndex = 41
			frame4.Parent = frame3
			local textLabel3 = Instance.new("TextLabel")
			textLabel3.Name = "Title"
			textLabel3.BackgroundTransparency = 1
			textLabel3.Size = UDim2.new(0.65, 0, 1, 0)
			textLabel3.Font = Enum.Font.GothamBold
			textLabel3.Text = "Move Theater"
			textLabel3.TextColor3 = Color3.fromRGB(255, 179, 38)
			textLabel3.TextSize = 24
			textLabel3.TextXAlignment = Enum.TextXAlignment.Left
			textLabel3.ZIndex = 41
			textLabel3.Parent = frame4
			state.sceneTitleLabel = textLabel3
			local textLabel4 = Instance.new("TextLabel")
			textLabel4.Name = "Subtitle"
			textLabel4.BackgroundTransparency = 1
			textLabel4.Position = UDim2.new(0, 0, 1, 2)
			textLabel4.Size = UDim2.new(0.7, 0, 0, 20)
			textLabel4.Font = Enum.Font.GothamMedium
			textLabel4.Text = "Previewing published move content"
			textLabel4.TextColor3 = Color3.fromRGB(220, 223, 231)
			textLabel4.TextSize = 14
			textLabel4.TextXAlignment = Enum.TextXAlignment.Left
			textLabel4.ZIndex = 41
			textLabel4.Parent = frame4
			state.sceneSubtitleLabel = textLabel4
			local frame5 = Instance.new("Frame")
			frame5.Name = "Actions"
			frame5.BackgroundTransparency = 1
			frame5.AnchorPoint = Vector2.new(0.5, 1)
			frame5.Position = UDim2.new(0.5, 0, 1, -150)
			frame5.Size = UDim2.new(0, 390, 0, 40)
			frame5.ZIndex = 41
			frame5.Parent = frame3
			local uIListLayout3 = Instance.new("UIListLayout")
			uIListLayout3.FillDirection = Enum.FillDirection.Horizontal
			uIListLayout3.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uIListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
			uIListLayout3.Padding = UDim.new(0, 10)
			uIListLayout3.Parent = frame5
			local textButton4 = Instance.new("TextButton")
			textButton4.Name = "Play"
			textButton4.LayoutOrder = 1
			textButton4.Size = UDim2.new(0, 110, 1, 0)
			textButton4.Text = "PLAY"
			textButton4.ZIndex = 41
			_styleTextButton(textButton4, Color3.fromRGB(52, 110, 79), Color3.fromRGB(255, 255, 255)) -- equivalent call inferred; original call site unknown
			textButton4.Parent = frame5
			state.scenePlayBtn = textButton4
			local textButton5 = Instance.new("TextButton")
			textButton5.Name = "Stop"
			textButton5.LayoutOrder = 2
			textButton5.Size = UDim2.new(0, 110, 1, 0)
			textButton5.Text = "STOP"
			textButton5.ZIndex = 41
			_styleTextButton(textButton5, Color3.fromRGB(61, 78, 124), Color3.fromRGB(255, 255, 255)) -- equivalent call inferred; original call site unknown
			textButton5.Parent = frame5
			state.sceneStopBtn = textButton5
			local textButton6 = Instance.new("TextButton")
			textButton6.Name = "Close"
			textButton6.LayoutOrder = 3
			textButton6.Size = UDim2.new(0, 110, 1, 0)
			textButton6.Text = "EXIT"
			textButton6.ZIndex = 41
			_styleTextButton(textButton6, Color3.fromRGB(125, 68, 55), Color3.fromRGB(255, 255, 255)) -- equivalent call inferred; original call site unknown
			textButton6.Parent = frame5
			state.sceneCloseBtn = textButton6
			local textLabel5 = Instance.new("TextLabel")
			textLabel5.Name = "Hint"
			textLabel5.BackgroundTransparency = 1
			textLabel5.AnchorPoint = Vector2.new(0.5, 1)
			textLabel5.Position = UDim2.new(0.5, 0, 1, -56)
			textLabel5.Size = UDim2.new(0.8, 0, 0, 20)
			textLabel5.Font = Enum.Font.GothamMedium
			textLabel5.Text = "This is a contained preview scene. It does not add or buy the item."
			textLabel5.TextColor3 = Color3.fromRGB(214, 218, 226)
			textLabel5.TextSize = 14
			textLabel5.ZIndex = 41
			textLabel5.Parent = frame3
			state.sceneHintLabel = textLabel5
			local frame6 = Instance.new("Frame")
			frame6.Name = "MenuPanel"
			frame6.BackgroundColor3 = Color3.fromRGB(17, 20, 26)
			frame6.BackgroundTransparency = 0.1
			frame6.Position = UDim2.new(0, 24, 0, 90)
			frame6.Size = UDim2.new(0, 340, 0, 420)
			frame6.Visible = false
			frame6.ZIndex = 41
			frame6.Parent = frame3
			state.sceneMenuPanel = frame6
			local uICorner2 = Instance.new("UICorner")
			uICorner2.CornerRadius = UDim.new(0, 12)
			uICorner2.Parent = frame6
			local uIStroke = Instance.new("UIStroke")
			uIStroke.Thickness = 1
			uIStroke.Transparency = 0.45
			uIStroke.Color = Color3.fromRGB(91, 111, 158)
			uIStroke.Parent = frame6
			local textLabel6 = Instance.new("TextLabel")
			textLabel6.Name = "MenuTitle"
			textLabel6.BackgroundTransparency = 1
			textLabel6.Position = UDim2.new(0, 14, 0, 12)
			textLabel6.Size = UDim2.new(1, -28, 0, 26)
			textLabel6.Font = Enum.Font.GothamBold
			textLabel6.Text = "Pick A Slot"
			textLabel6.TextColor3 = Color3.fromRGB(255, 179, 38)
			textLabel6.TextSize = 22
			textLabel6.TextXAlignment = Enum.TextXAlignment.Left
			textLabel6.ZIndex = 42
			textLabel6.Parent = frame6
			state.sceneMenuTitleLabel = textLabel6
			local textLabel7 = Instance.new("TextLabel")
			textLabel7.Name = "MenuStatus"
			textLabel7.BackgroundTransparency = 1
			textLabel7.Position = UDim2.new(0, 14, 0, 42)
			textLabel7.Size = UDim2.new(1, -28, 0, 40)
			textLabel7.Font = Enum.Font.GothamMedium
			textLabel7.Text = "Choose a slot to preview."
			textLabel7.TextColor3 = Color3.fromRGB(223, 227, 236)
			textLabel7.TextSize = 14
			textLabel7.TextWrapped = true
			textLabel7.TextXAlignment = Enum.TextXAlignment.Left
			textLabel7.TextYAlignment = Enum.TextYAlignment.Top
			textLabel7.ZIndex = 42
			textLabel7.Parent = frame6
			state.sceneMenuStatusLabel = textLabel7
			local scrollingFrame2 = Instance.new("ScrollingFrame")
			scrollingFrame2.Name = "MenuScroll"
			scrollingFrame2.BackgroundTransparency = 1
			scrollingFrame2.BorderSizePixel = 0
			scrollingFrame2.Position = UDim2.new(0, 14, 0, 92)
			scrollingFrame2.Size = UDim2.new(1, -28, 1, -106)
			scrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, 0)
			scrollingFrame2.ScrollBarThickness = 6
			scrollingFrame2.ZIndex = 42
			scrollingFrame2.Parent = frame6
			state.sceneMenuScroll = scrollingFrame2
			local uIListLayout4 = Instance.new("UIListLayout")
			uIListLayout4.Padding = UDim.new(0, 8)
			uIListLayout4.Parent = scrollingFrame2
			state.sceneMenuLayout = uIListLayout4
		end

		textButton.MouseButton1Click:Connect(function()
			local activePreviewData = state.activePreviewData

			if activePreviewData and activePreviewData.kind == "created_animation" then
				CataloguePreviewHelper._playCreatedAnimation(state, activePreviewData)
			end
		end)
		textButton2.MouseButton1Click:Connect(function()
			CataloguePreviewHelper.clear()
		end)
		textButton3.MouseButton1Click:Connect(function()
			local activePreviewData = state.activePreviewData

			if not activePreviewData then
				return
			end

			if activePreviewData.kind == "move_theater" or activePreviewData.kind == "created_animation_theater" then
				CataloguePreviewHelper._openMoveTheaterShell(state, activePreviewData)
			elseif activePreviewData.kind == "character_slots" then
				CataloguePreviewHelper._openCharacterSlotPicker(state, activePreviewData)
			end
		end)

		if state.scenePlayBtn then
			state.scenePlayBtn.MouseButton1Click:Connect(function()
				CataloguePreviewHelper._playSelectedScene(state)
			end)
		end

		if state.sceneStopBtn then
			state.sceneStopBtn.MouseButton1Click:Connect(function()
				CataloguePreviewHelper._stopActiveScene(state, true)
			end)
		end

		if state.sceneCloseBtn then
			state.sceneCloseBtn.MouseButton1Click:Connect(function()
				CataloguePreviewHelper._stopSceneOverlay(state, true)
			end)
		end

		return state
	end
end

function CataloguePreviewHelper._setStatus(p, value)
	if p and p.statusLabel then
		p.statusLabel.Text = tostring(value or "")
	end
end

function CataloguePreviewHelper:_setMainGuiSuppressed(p)
	if not self then
		return
	end

	local suppressTargets = self.suppressTargets

	if type(suppressTargets) ~= "table" then
		return
	end

	if p == true then
		self._suppressedVisibility = self._suppressedVisibility or {}

		for _, guiObject in ipairs(suppressTargets) do
			local v

			if typeof(guiObject) == "Instance" then
				v = guiObject:IsA("GuiObject")
			else
				v = false
			end

			if not v then
				continue
			end

			if self._suppressedVisibility[guiObject] == nil then
				self._suppressedVisibility[guiObject] = guiObject.Visible
			end

			guiObject.Visible = false
		end
	else
		if type(self._suppressedVisibility) ~= "table" then
			return
		end

		for guiObject, v in pairs(self._suppressedVisibility) do
			local v2

			if typeof(guiObject) == "Instance" then
				v2 = guiObject:IsA("GuiObject")
			else
				v2 = false
			end

			if v2 and guiObject.Parent then
				guiObject.Visible = v == true
			end
		end

		table.clear(self._suppressedVisibility)
	end
end

function CataloguePreviewHelper._setSceneMenuVisible(p, p2)
	if not p then
		return
	end

	if p.sceneMenuPanel then
		p.sceneMenuPanel.Visible = p2 == true
	end
end

function CataloguePreviewHelper:_setPendingSlotSelection(p, scenePendingSlotKey)
	if not self then
		return
	end

	self.scenePendingEntry = self.activeEntry
	self.scenePendingSlotKey = scenePendingSlotKey
	local text = "Choose a slot to preview."

	for _, v2 in ipairs(p and p.slots or {}) do
		local v3 = tostring(v2.key or "") == tostring(scenePendingSlotKey or "")
		local v4

		if type(self.sceneSlotButtons) == "table" then
			v4 = self.sceneSlotButtons[tostring(v2.key or "")] or nil
		end

		if v4 and v4.Parent then
			v4.BackgroundColor3 = v3 and Color3.fromRGB(52, 110, 79) or Color3.fromRGB(58, 77, 116)
		end

		if v3 then
			text = string.format(
				"Selected: %s | %s",
				tostring(v2.label or v2.key or "Slot"),
				(tostring(v2.moveName or "-"))
			)
		end
	end

	if self.sceneMenuStatusLabel then
		self.sceneMenuStatusLabel.Text = text
	end
end

function CataloguePreviewHelper:_populateSceneSlotMenu(p)
	if not (self and self.sceneMenuScroll and self.sceneMenuLayout) then
		return
	end

	self.sceneSlotButtons = {}
	self.scenePendingEntry = self.activeEntry
	self.scenePendingSlotKey = nil
	local key = nil

	for _, guiObject in ipairs(self.sceneMenuScroll:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	for _, v in ipairs(not p and {} or p.slots or {}) do
		if key == nil then
			key = v.key
		end

		local textButton = Instance.new("TextButton")
		textButton.Name = "TheaterSlot_" .. tostring(v.key or "")
		textButton.Size = UDim2.new(1, 0, 0, 42)
		textButton.Text = string.format(
			"%s  |  %s",
			tostring(v.label or v.key or "Slot"),
			(tostring(v.moveName or "-"))
		)
		textButton.ZIndex = 42
		_styleTextButton(textButton, Color3.fromRGB(58, 77, 116), Color3.fromRGB(255, 255, 255)) -- equivalent call inferred; original call site unknown
		textButton.Parent = self.sceneMenuScroll
		self.sceneSlotButtons[tostring(v.key or "")] = textButton
		local v2 = v
		textButton.MouseButton1Click:Connect(function()
			CataloguePreviewHelper._setPendingSlotSelection(self, p, v2.key)
		end)
	end

	if key ~= nil then
		CataloguePreviewHelper._setPendingSlotSelection(self, p, key)
	end

	task.defer(function()
		if self.sceneMenuScroll and self.sceneMenuLayout then
			self.sceneMenuScroll.CanvasSize = UDim2.new(0, 0, 0, self.sceneMenuLayout.AbsoluteContentSize.Y + 8)
		end
	end)
end

function CataloguePreviewHelper:_setPanelMode(value)
	if not self then
		return
	end

	self.panelMode = tostring(value or "none")
	_refreshExternalHostChrome(self) -- equivalent call inferred; original call site unknown
	local visible = self.panelMode == "created_animation"
	local visible2 = self.panelMode == "character_slots"
	local v3 = self.panelMode == "move_theater" or self.panelMode == "character_launcher"

	if self.viewport then
		self.viewport.Visible = visible
	end

	if self.slotScroll then
		self.slotScroll.Visible = visible2
	end

	if self.primaryActionBtn then
		self.primaryActionBtn.Visible = v3 and self.useExternalTheaterButton ~= true
	end

	if self.replayBtn then
		local replayBtn = self.replayBtn
		replayBtn.Visible = self.useExternalTheaterButton ~= true and visible and self.root and self.root.Visible == true
	end

	if self.stopBtn then
		local stopBtn = self.stopBtn
		stopBtn.Visible = self.useExternalTheaterButton ~= true and visible and self.root and self.root.Visible == true
	end
end

function CataloguePreviewHelper._setPreviewUiVisible(data, p, p2)
	if not data then
		return
	end

	if data.root then
		data.root.Visible = p == true
	end

	_refreshExternalHostChrome(data) -- equivalent call inferred; original call site unknown

	if data.panelMode == "created_animation" then
		if data.replayBtn then
			local replayBtn = data.replayBtn
			replayBtn.Visible = data.useExternalTheaterButton ~= true and p == true and p2 == true
		end

		if data.stopBtn then
			local stopBtn = data.stopBtn
			stopBtn.Visible = data.useExternalTheaterButton ~= true and p == true and p2 == true
		end
	else
		if data.replayBtn then
			data.replayBtn.Visible = false
		end

		if data.stopBtn then
			data.stopBtn.Visible = false
		end
	end
end

function CataloguePreviewHelper:_stopPlayback(p)
	if not self then
		return
	end

	self.playToken = (self.playToken or 0) + 1

	if self.renderConn then
		self.renderConn:Disconnect()
		self.renderConn = nil
	end

	_resetTransforms(self)
	self.activePreviewData = nil

	if p ~= true then
		CataloguePreviewHelper._setPreviewUiVisible(self, false, false)
	end
end

function CataloguePreviewHelper:_getStatusEvent()
	if self.statusEvent and self.statusEvent.Parent then
		return self.statusEvent
	end

	local cataloguePreviewStatus = ReplicatedStorage:FindFirstChild("CataloguePreviewStatus")

	if cataloguePreviewStatus and cataloguePreviewStatus:IsA("RemoteEvent") then
		self.statusEvent = cataloguePreviewStatus
	end

	return self.statusEvent
end

function CataloguePreviewHelper:_bindStatusEvent()
	if not self or self.statusConn then
		return
	end

	local _getStatusEvent = CataloguePreviewHelper._getStatusEvent(self)

	if not _getStatusEvent then
		return
	end

	self.statusConn = _getStatusEvent.OnClientEvent:Connect(function(p)
		if type(p) ~= "table" then
			return
		end

		if tostring(p.type or "") == "stopped" then
			local token = tostring(p.token or "")

			if type(self.scenePrepared) == "table" and tostring(self.scenePrepared.token or "") == token then
				self.scenePrepared = nil
			end

			local activeScene = self.activeScene

			if activeScene and tostring(activeScene.token or "") == token then
				CataloguePreviewHelper._stopActiveScene(self, false)
				CataloguePreviewHelper._setStatus(self, "Preview ended.")

				if self.sceneMenuStatusLabel and self.sceneMenuPanel and self.sceneMenuPanel.Visible then
					self.sceneMenuStatusLabel.Text = "Preview ended. Press PLAY to start again."
				end
			end
		end
	end)
end

function CataloguePreviewHelper:_restoreWorldCamera(p2)
	if not self then
		return
	end

	_disconnectSceneRenderConn(self) -- equivalent call inferred; original call site unknown
	CataloguePreviewHelper._stopSceneFreecam(self)
	local currentCamera = Workspace.CurrentCamera
	local prevCameraState = self.prevCameraState
	local cameraObject = prevCameraState and prevCameraState.CameraObject

	if cameraObject and cameraObject.Parent then
		pcall(function()
			Workspace.CurrentCamera = cameraObject
		end)
		currentCamera = cameraObject
	end

	if currentCamera and prevCameraState then
		pcall(function()
			currentCamera.CameraType = prevCameraState.CameraType or Enum.CameraType.Custom
		end)
		pcall(function()
			if prevCameraState.CameraSubject ~= nil then
				currentCamera.CameraSubject = prevCameraState.CameraSubject
			end
		end)
		pcall(function()
			if typeof(prevCameraState.CFrame) == "CFrame" then
				currentCamera.CFrame = prevCameraState.CFrame
			end
		end)
	end

	_parkSceneCamera(self) -- equivalent call inferred; original call site unknown

	if p2 ~= false then
		self.prevCameraState = nil
	end
end

function CataloguePreviewHelper:_stopActiveScene(p, p2)
	if not self then
		return
	end

	local scenePrepared

	if type(self.scenePrepared) == "table" then
		scenePrepared = self.scenePrepared or nil
	end

	local v

	if p == true and type(self.requestFn) == "function" then
		v = self.activeScene ~= nil or scenePrepared ~= nil
	else
		v = false
	end

	local v2 = type(p2) == "table" and p2 or nil
	local preserveFloor = v2 == nil or v2.preserveFloor == true
	local v4 = v and preserveFloor

	if v and v4 then
		CataloguePreviewHelper._setScenePlayEnabled(self, false, "Refreshing preview stage...")
		CataloguePreviewHelper._setSceneActionCooldown(self, 0.5)
		task.spawn(function()
			local fn = self.requestFn("StopEntryPreviewScene", {
				preserveFloor = preserveFloor,
				refreshDummies = v2 == nil or v2.refreshDummies ~= false
			}, 1)

			if CataloguePreviewHelper._state ~= self then
				return
			end

			if typeof(fn) == "table" and fn.ok ~= false then
				if type(fn.scene) == "table" then
					self.scenePrepared = fn.scene
				end

				local scenePlayGateToken = (self.scenePlayGateToken or 0) + 1
				self.scenePlayGateToken = scenePlayGateToken
				task.delay(0.5, function()
					if not (CataloguePreviewHelper._state == self and self.scenePlayGateToken == scenePlayGateToken and (self.sceneOverlay and self.sceneOverlay.Visible)) then
						return
					end

					CataloguePreviewHelper._setScenePlayEnabled(self, true)

					if self.sceneMenuStatusLabel and self.sceneMenuPanel and self.sceneMenuPanel.Visible then
						self.sceneMenuStatusLabel.Text = self.sceneRestartQueued and "Restarting preview..." or "Preview stopped. Press PLAY to start again."
					end

					local sceneRestartQueued = self.sceneRestartQueued

					if sceneRestartQueued and type(sceneRestartQueued.entry) == "table" and not self.activeScene then
						self.sceneRestartQueued = nil
						task.defer(function()
							if CataloguePreviewHelper._state ~= self or self.activeScene then
								return
							end

							CataloguePreviewHelper._setSceneActionCooldown(self, 0.5)
							CataloguePreviewHelper._requestStartScene(
								self,
								sceneRestartQueued.entry,
								sceneRestartQueued.slotKey
							)
						end)
					end
				end)
			else
				self.sceneRestartQueued = nil
				self.scenePrepared = nil

				if self.sceneMenuStatusLabel and self.sceneMenuPanel and self.sceneMenuPanel.Visible then
					self.sceneMenuStatusLabel.Text = "Preview stop failed."
				end
			end
		end)
	elseif v then
		task.spawn(function()
			self.requestFn("StopEntryPreviewScene", {
				preserveFloor = false,
				refreshDummies = false
			}, 1)
		end)
	end

	self.activeScene = nil
	self.sceneReplayEntry = nil
	self.sceneReplaySlotKey = nil

	if not preserveFloor then
		self.scenePrepared = nil
	end

	_clearScenePreviewFx()
	_disconnectSceneRenderConn(self) -- equivalent call inferred; original call site unknown

	if self.sceneSubtitleLabel then
		self.sceneSubtitleLabel.Text = v4 and "Refreshing preview stage..." or "Press PLAY to start the selected preview."
	end

	if self.sceneMenuStatusLabel and self.sceneMenuPanel and self.sceneMenuPanel.Visible then
		self.sceneMenuStatusLabel.Text = v4 and "Refreshing preview stage..." or "Preview stopped. Press PLAY to start again."
	end
end

function CataloguePreviewHelper:_playSelectedScene()
	if not self or CataloguePreviewHelper._sceneActionCoolingDown(self) then
		return
	end

	local activePreviewData = self.activePreviewData
	local scenePendingEntry = self.scenePendingEntry or self.activeEntry
	local scenePendingSlotKey = self.scenePendingSlotKey

	if type(scenePendingEntry) ~= "table" then
		return
	end

	if self.activeScene then
		if self.sceneMenuStatusLabel and self.sceneMenuPanel and self.sceneMenuPanel.Visible then
			self.sceneMenuStatusLabel.Text = "Restarting preview..."
		end

		self.sceneRestartQueued = {
			entry = scenePendingEntry,
			slotKey = scenePendingSlotKey
		}
		CataloguePreviewHelper._stopActiveScene(self, true, {
			preserveFloor = true,
			refreshDummies = true
		})
	elseif type(activePreviewData) == "table" and tostring(activePreviewData.kind or "") == "character_slots" and not scenePendingSlotKey then
		if self.sceneMenuStatusLabel then
			self.sceneMenuStatusLabel.Text = "Pick a slot first."
		end
	elseif self.scenePlayReadyAt and os.clock() < self.scenePlayReadyAt then
		if self.sceneMenuStatusLabel and self.sceneMenuPanel and self.sceneMenuPanel.Visible then
			self.sceneMenuStatusLabel.Text = "Theater is still preparing..."
		end
	else
		CataloguePreviewHelper._setSceneActionCooldown(self, 0.5)
		CataloguePreviewHelper._requestStartScene(self, scenePendingEntry, scenePendingSlotKey)
	end
end

function CataloguePreviewHelper._openCharacterSlotPicker(data, p)
	if not data or type(p) ~= "table" then
		return
	end

	CataloguePreviewHelper._setMainGuiSuppressed(data, true)

	if data.sceneOverlay then
		data.sceneOverlay.Visible = true
	end

	CataloguePreviewHelper._setSceneMenuVisible(data, true)
	CataloguePreviewHelper._populateSceneSlotMenu(data, p)
	CataloguePreviewHelper._enterIdleSceneView(data, "Pick a character slot to preview in the theater.")
	CataloguePreviewHelper._prepareSceneStage(data)

	if data.sceneTitleLabel then
		data.sceneTitleLabel.Text = tostring(p.name or "Character Theater")
	end

	if data.sceneSubtitleLabel then
		data.sceneSubtitleLabel.Text = "Pick a character slot to preview in the theater."
	end

	if data.sceneHintLabel then
		data.sceneHintLabel.Visible = true
		data.sceneHintLabel.Text = "Stay in the theater until EXIT. Picking another slot will replace the current preview."
	end

	if data.sceneMenuTitleLabel then
		data.sceneMenuTitleLabel.Text = tostring(p.name or "Character Theater")
	end

	if data.sceneMenuStatusLabel then
		data.sceneMenuStatusLabel.Text = "Choose a slot, then press PLAY."
	end
end

function CataloguePreviewHelper:_openMoveTheaterShell(p)
	if not self or type(p) ~= "table" then
		return
	end

	self.scenePendingEntry = self.activeEntry
	self.scenePendingSlotKey = nil
	CataloguePreviewHelper._setMainGuiSuppressed(self, true)

	if self.sceneOverlay then
		self.sceneOverlay.Visible = true
	end

	CataloguePreviewHelper._setSceneMenuVisible(self, false)
	CataloguePreviewHelper._enterIdleSceneView(self, "Press PLAY to start this move preview.")
	CataloguePreviewHelper._prepareSceneStage(self)

	if self.sceneTitleLabel then
		self.sceneTitleLabel.Text = tostring(p.name or "Move Theater")
	end

	if self.sceneSubtitleLabel then
		self.sceneSubtitleLabel.Text = "Press PLAY to start this move preview."
	end

	if self.sceneHintLabel then
		self.sceneHintLabel.Text = ""
		self.sceneHintLabel.Visible = false
	end
end

function CataloguePreviewHelper:_stopSceneOverlay(p)
	if not self then
		return
	end

	self.sceneAutoPlayToken = (self.sceneAutoPlayToken or 0) + 1
	CataloguePreviewHelper._stopActiveScene(self, p, {
		preserveFloor = false,
		refreshDummies = false
	})

	if self.sceneOverlay then
		self.sceneOverlay.Visible = false
	end

	self.scenePlayGateToken = (self.scenePlayGateToken or 0) + 1
	self.scenePrepareToken = (self.scenePrepareToken or 0) + 1
	self.sceneRestartQueued = nil
	self.scenePlayReadyAt = 0
	self.scenePlaybackAligned = false
	CataloguePreviewHelper._setSceneMenuVisible(self, false)
	CataloguePreviewHelper._setMainGuiSuppressed(self, false)

	if self and not UserInputService.TouchEnabled and self.sceneModalPrev ~= nil then
		UserInputService.ModalEnabled = self.sceneModalPrev
		self.sceneModalPrev = nil
	end

	CataloguePreviewHelper._restoreWorldCamera(self, true)
end

function CataloguePreviewHelper:_openSceneOverlay(data, sceneReplayEntry, sceneReplaySlotKey)
	if not self then
		return
	end

	_disconnectSceneRenderConn(self) -- equivalent call inferred; original call site unknown
	self.activeScene = data
	self.scenePrepared = data
	self.sceneReplayEntry = sceneReplayEntry
	self.sceneReplaySlotKey = sceneReplaySlotKey
	CataloguePreviewHelper._setMainGuiSuppressed(self, true)

	if self and not UserInputService.TouchEnabled then
		if self.sceneModalPrev == nil then
			self.sceneModalPrev = UserInputService.ModalEnabled
		end

		UserInputService.ModalEnabled = true
	end

	if self.sceneOverlay then
		self.sceneOverlay.Visible = true
	end

	local v

	if type(self.activePreviewData) == "table" then
		v = tostring(self.activePreviewData.kind or "") == "character_slots"
	else
		v = false
	end

	CataloguePreviewHelper._setSceneMenuVisible(self, v)

	if self.sceneTitleLabel then
		self.sceneTitleLabel.Text = tostring(data.label or not sceneReplayEntry and "Move Theater" or sceneReplayEntry.name or "Move Theater")
	end

	if self.sceneSubtitleLabel then
		self.sceneSubtitleLabel.Text = sceneReplaySlotKey and "Character slot preview" or "Previewing published move content"
	end

	CataloguePreviewHelper._bindStatusEvent(self)
	local currentCamera = Workspace.CurrentCamera

	if currentCamera and not self.prevCameraState then
		self.prevCameraState = {
			CameraObject = currentCamera,
			CameraType = currentCamera.CameraType,
			CameraSubject = currentCamera.CameraSubject,
			CFrame = currentCamera.CFrame
		}
	end

	warn(string.format(
		"[CataloguePreview] scene open token=%s entry=%s slot=%s attacker=%s victim=%s",
		tostring(data.token or ""),
		tostring(sceneReplayEntry and sceneReplayEntry.id or ""),
		tostring(sceneReplaySlotKey or ""),
		tostring(data.attackerName or ""),
		(tostring(data.victimName or ""))
	))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function findStageModel(childName)
		if type(childName) == "string" and childName ~= "" then
			return Workspace:FindFirstChild(childName, true)
		end

		return nil
	end

	local v2 = nil
	local v3 = nil
	local v4 = false
	local v5 = false
	local lastTime = os.clock()
	self.sceneRenderConn = RunService.RenderStepped:Connect(function(_)
		if not Workspace.CurrentCamera or not self.activeScene or tostring(self.activeScene.token or "") ~= tostring(data.token or "") then
			return
		end

		if not (v2 and v2.Parent) then
			v2 = findStageModel(data.attackerName) -- equivalent call inferred; original call site unknown
		end

		if not (v3 and v3.Parent) then
			v3 = findStageModel(data.victimName) -- equivalent call inferred; original call site unknown
		end

		local v7 = _findRootPart(v2) -- equivalent call inferred; original call site unknown
		local v9 = _findRootPart(v3) -- equivalent call inferred; original call site unknown

		if v7 then
			if not v5 then
				v5 = true
				warn(string.format(
					"[CataloguePreview] scene models_ready token=%s attacker=%s victim=%s",
					tostring(data.token or ""),
					tostring(v2 and v2.Name or ""),
					(tostring(v3 and v3.Name or ""))
				))
			end

			local v10 = v7.Position + createVector(0, 2.2, 0)

			if v9 then
				v10 = (v7.Position + v9.Position) * 0.5 + createVector(0, 2.1, 0)
			end

			if not self.scenePlaybackAligned then
				self.scenePlaybackAligned = true

				if not self.sceneFreecamActive then
					CataloguePreviewHelper._startSceneFreecam(self, nil, v10, false)
				end
			end

			_disconnectSceneRenderConn(self) -- equivalent call inferred; original call site unknown
		elseif not v4 and os.clock() - lastTime >= 0.8 then
			v4 = true
			warn(string.format(
				"[CataloguePreview] scene waiting_for_models token=%s attacker=%s victim=%s",
				tostring(data.token or ""),
				tostring(data.attackerName or ""),
				(tostring(data.victimName or ""))
			))
		end
	end)
end

function CataloguePreviewHelper:_requestStartScene(p, value)
	if not self or type(self.requestFn) ~= "function" or type(p) ~= "table" then
		return
	end

	if self.sceneMenuStatusLabel and self.sceneMenuPanel and self.sceneMenuPanel.Visible then
		self.sceneMenuStatusLabel.Text = "Loading preview..."
	end

	local v = {
		entryId = tostring(p.id or "")
	}

	if value then
		v.slotKey = tostring(value)
	end

	local fn = self.requestFn("StartEntryPreviewScene", v, 2)

	if typeof(fn) == "table" and fn.ok ~= false then
		if type(fn.scene) ~= "table" then
			CataloguePreviewHelper._setStatus(self, "Theater did not return a scene.")
			return
		end

		self.scenePrepared = fn.scene
		CataloguePreviewHelper._openSceneOverlay(self, fn.scene, p, value)

		if self.sceneMenuStatusLabel and self.sceneMenuPanel and self.sceneMenuPanel.Visible then
			self.sceneMenuStatusLabel.Text = "Preview running. Use STOP or pick another slot."
		end

		CataloguePreviewHelper._setScenePlayEnabled(self, true)
	else
		CataloguePreviewHelper._setPreviewUiVisible(self, true, false)
		CataloguePreviewHelper._setStatus(self, "Theater failed to start.")

		if self.sceneMenuStatusLabel and self.sceneMenuPanel and self.sceneMenuPanel.Visible then
			self.sceneMenuStatusLabel.Text = "Theater failed to start."
		end

		warn(string.format(
			"[CataloguePreview] start scene failed entry=%s slot=%s err=%s",
			tostring(p.id or ""),
			tostring(value or ""),
			(tostring(fn and fn.error or "unknown"))
		))
	end
end

function CataloguePreviewHelper._activatePrimaryAction(p)
	local activePreviewData = p and p.activePreviewData

	if not activePreviewData then
		return false, "preview-pending"
	end

	if activePreviewData.kind == "move_theater" or activePreviewData.kind == "created_animation_theater" then
		CataloguePreviewHelper._openMoveTheaterShell(p, activePreviewData)
		return true
	end

	if activePreviewData.kind ~= "character_slots" then
		return false, "unsupported"
	end

	CataloguePreviewHelper._openCharacterSlotPicker(p, activePreviewData)
	return true
end

function CataloguePreviewHelper:_flushPendingPrimaryAction()
	if not self or self.pendingPrimaryAction ~= true then
		return
	end

	self.pendingPrimaryAction = false
	task.defer(function()
		if CataloguePreviewHelper._state ~= self then
			return
		end

		CataloguePreviewHelper._activatePrimaryAction(self)
	end)
end

function CataloguePreviewHelper:_showMoveTheaterLauncher(activePreviewData)
	self.activePreviewData = activePreviewData
	CataloguePreviewHelper._setPanelMode(self, "move_theater")
	CataloguePreviewHelper._setPreviewUiVisible(self, true, false)

	if self.useExternalTheaterButton == true then
		CataloguePreviewHelper._setStatus(self, "Press THEATER to watch this move.")
	else
		CataloguePreviewHelper._setStatus(self, "Open the theater, then press PLAY to watch this move.")
	end

	if self.titleLabel then
		self.titleLabel.Text = "Preview Theater  |  " .. tostring(activePreviewData.name or "Move")
	end

	if self.primaryActionBtn then
		self.primaryActionBtn.Text = "OPEN THEATER"
	end

	CataloguePreviewHelper._flushPendingPrimaryAction(self)
end

function CataloguePreviewHelper:_showCharacterSlots(activePreviewData)
	self.activePreviewData = activePreviewData
	CataloguePreviewHelper._setPanelMode(self, "character_launcher")
	CataloguePreviewHelper._setPreviewUiVisible(self, true, false)

	if self.useExternalTheaterButton == true then
		CataloguePreviewHelper._setStatus(
			self,
			"Press THEATER to pick a slot and preview this character package in motion."
		)
	else
		CataloguePreviewHelper._setStatus(
			self,
			"Open the theater to pick a slot and preview how this character package looks in motion."
		)
	end

	if self.titleLabel then
		self.titleLabel.Text = "Preview Theater  |  " .. tostring(activePreviewData.name or "Character")
	end

	if self.primaryActionBtn then
		self.primaryActionBtn.Text = "OPEN THEATER"
	end

	CataloguePreviewHelper._flushPendingPrimaryAction(self)
end

function CataloguePreviewHelper.clear()
	local _state = CataloguePreviewHelper._state

	if not _state then
		return
	end

	_state.token = (_state.token or 0) + 1
	_state.sceneAutoPlayToken = (_state.sceneAutoPlayToken or 0) + 1
	CataloguePreviewHelper._stopSceneOverlay(_state, true)
	CataloguePreviewHelper._stopPlayback(_state, false)
	CataloguePreviewHelper._setPanelMode(_state, "none")
	_state.activeEntry = nil
	local swordIcon = _state.host and _state.host:FindFirstChild("SwordIcon")

	if swordIcon and swordIcon:IsA("GuiObject") then
		swordIcon.Visible = true
	end
end

function CataloguePreviewHelper:_playCreatedAnimation(activePreviewData)
	if not self then
		return
	end

	CataloguePreviewHelper._stopPlayback(self, true)

	if _ensureDummyClone(self) then
		local swordIcon = self.host and self.host:FindFirstChild("SwordIcon")

		if swordIcon and swordIcon:IsA("GuiObject") then
			swordIcon.Visible = false
		end

		local poseData = _parsePoseData(activePreviewData.poseData)
		local poseGroups, poseOrder = _groupPosesByTarget(poseData)
		activePreviewData._poseData = poseData
		activePreviewData._poseGroups = poseGroups
		activePreviewData._poseOrder = poseOrder
		self.activePreviewData = activePreviewData
		CataloguePreviewHelper._setPanelMode(self, "created_animation")
		CataloguePreviewHelper._setPreviewUiVisible(self, true, true)
		CataloguePreviewHelper._setStatus(self, "")

		if self.titleLabel then
			self.titleLabel.Text = "Preview Theater  |  " .. tostring(activePreviewData.name or "Created Animation")
		end

		_setCamera(self)
		_resetTransforms(self)
		_scrubCreatedAnimation(self, activePreviewData, 0)
		local v4 = math.max(0.05, tonumber(activePreviewData.duration) or 1)
		local playToken = self.playToken
		local total = 0
		self.renderConn = RunService.RenderStepped:Connect(function(dt)
			if self.playToken ~= playToken then
				return
			end

			total += dt
			_scrubCreatedAnimation(self, activePreviewData, total % v4)
		end)
	else
		CataloguePreviewHelper._setPreviewUiVisible(self, true, false)
		CataloguePreviewHelper._setStatus(self, "Preview dummy is unavailable.")
		warn("[CataloguePreview] dummy missing for created animation preview")
	end
end

function CataloguePreviewHelper:_queueAutoStartScene(p, p2)
	if not self or type(p) ~= "table" then
		return
	end

	local sceneAutoPlayToken = (self.sceneAutoPlayToken or 0) + 1
	self.sceneAutoPlayToken = sceneAutoPlayToken
	task.spawn(function()
		local v2 = os.clock() + 5

		while CataloguePreviewHelper._state == self and self.sceneAutoPlayToken == sceneAutoPlayToken do
			if v2 <= os.clock() then
				warn(string.format(
					"[CataloguePreview] auto-start timeout entry=%s kind=%s",
					tostring(p.id or ""),
					(tostring(p2 and p2.kind or ""))
				))
				break
			end

			if self.activeScene then
				break
			end

			local scenePlayReadyAt = tonumber(self.scenePlayReadyAt) or 0

			if type(self.scenePrepared) == "table" and (not self.sceneOverlay or self.sceneOverlay.Visible == true) and scenePlayReadyAt <= os.clock() then
				CataloguePreviewHelper._playSelectedScene(self)
				break
			else
				task.wait(0.05)
			end
		end
	end)
end

function CataloguePreviewHelper:_showCreatedAnimationTheater(activePreviewData)
	if not self or type(activePreviewData) ~= "table" then
		return
	end

	CataloguePreviewHelper._stopPlayback(self, false)
	self.activePreviewData = activePreviewData
	CataloguePreviewHelper._setPanelMode(self, "move_theater")
	CataloguePreviewHelper._setPreviewUiVisible(self, true, false)

	if self.useExternalTheaterButton == true then
		CataloguePreviewHelper._setStatus(self, "Press THEATER to watch this animation.")
	else
		CataloguePreviewHelper._setStatus(self, "Open the theater, then press PLAY to watch this animation.")
	end

	if self.titleLabel then
		self.titleLabel.Text = "Preview Theater  |  " .. tostring(activePreviewData.name or "Created Animation")
	end

	if self.primaryActionBtn then
		self.primaryActionBtn.Text = "OPEN THEATER"
	end

	CataloguePreviewHelper._flushPendingPrimaryAction(self)
end

function CataloguePreviewHelper.openTheater()
	local _state = CataloguePreviewHelper._state

	if not _state then
		return false, "state-missing"
	end

	local _activatePrimaryAction, v = CataloguePreviewHelper._activatePrimaryAction(_state)

	if _activatePrimaryAction then
		return true
	end

	if v ~= "preview-pending" or type(_state.activeEntry) ~= "table" then
		return false, v
	end

	_state.pendingPrimaryAction = true
	CataloguePreviewHelper.showEntry(_state.activeEntry)
	return true, "loading"
end

function CataloguePreviewHelper.showEntry(activeEntry)
	local _state = CataloguePreviewHelper._state

	if not _state then
		return
	end

	_state.token = (_state.token or 0) + 1
	local token = _state.token
	_state.activeEntry = activeEntry
	CataloguePreviewHelper._stopPlayback(_state, false)
	CataloguePreviewHelper._stopSceneOverlay(_state, true)

	if not activeEntry or type(activeEntry) ~= "table" then
		return
	end

	local requestFn = _state.requestFn

	if type(requestFn) ~= "function" then
		return
	end

	CataloguePreviewHelper._setPanelMode(_state, "none")
	CataloguePreviewHelper._setPreviewUiVisible(_state, true, false)
	CataloguePreviewHelper._setStatus(_state, "Loading preview...")

	if _state.titleLabel then
		_state.titleLabel.Text = "Preview Theater"
	end

	task.spawn(function()
		local v = requestFn("GetEntryPreview", {
			entryId = tostring(activeEntry.id or "")
		}, 2)

		if CataloguePreviewHelper._state ~= _state or _state.token ~= token then
			return
		end

		if typeof(v) == "table" and v.ok ~= false then
			local preview = v.preview

			if type(preview) == "table" and preview.supported ~= false then
				local kind = tostring(preview.kind or "")

				if kind == "created_animation" then
					CataloguePreviewHelper._playCreatedAnimation(_state, preview)
					return
				elseif kind == "created_animation_theater" then
					CataloguePreviewHelper._showCreatedAnimationTheater(_state, preview)
					return
				elseif kind == "move_theater" then
					CataloguePreviewHelper._showMoveTheaterLauncher(_state, preview)
					return
				elseif kind == "character_slots" then
					CataloguePreviewHelper._showCharacterSlots(_state, preview)
					return
				end

				CataloguePreviewHelper._setPreviewUiVisible(_state, true, false)
				CataloguePreviewHelper._setStatus(_state, "Preview is not available for this item yet.")
			else
				CataloguePreviewHelper._setPreviewUiVisible(_state, true, false)
				CataloguePreviewHelper._setStatus(
					_state,
					(tostring(preview and preview.message or "Preview is not available for this item yet."))
				)
			end
		else
			CataloguePreviewHelper._setPreviewUiVisible(_state, true, false)
			CataloguePreviewHelper._setStatus(_state, "Preview failed to load.")
			warn(string.format(
				"[CataloguePreview] request failed entry=%s err=%s",
				tostring(activeEntry.id or ""),
				(tostring(v and v.error or "unknown"))
			))
		end
	end)
end

return CataloguePreviewHelper