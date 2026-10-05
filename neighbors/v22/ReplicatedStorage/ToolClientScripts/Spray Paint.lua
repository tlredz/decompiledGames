local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
require(ReplicatedStorage.Modules.Tool)
local Network = require(ReplicatedStorage.Modules.Network)
local Graffiti = require(ReplicatedStorage.Assets.Tools.Graffiti)
local currentCamera = workspace.CurrentCamera
local _ = {
	MaxAngleDifference = 0.3490658503988659,
	UpdateRate = 0.016666666666666666,
	ReplicationFrequency = 1
}

-- equivalent calls inferred from this helper; original call sites unknown
local function removeExistingLineVisual(state)
	if state.LineVisual then
		state.LineVisual:Destroy()
		state.LineVisual = nil
	end
end

local function drawLine(state, cframe: CFrame, cframe2: CFrame, currentSize: number, currentColor: Color3, currentLayer: number)
	local GUID = HttpService:GenerateGUID(false)

	if Graffiti:DrawLine(state.Player, GUID, cframe, cframe2, currentSize, currentColor, currentLayer) then
		local v = string.format("%s/%s/%s", currentSize, Graffiti:EncodeColor3(currentColor), currentLayer)
		local v2 = { cframe, cframe2, GUID }

		if not Graffiti.DrawPacket[v] then
			Graffiti.DrawPacket[v] = {}
		end

		Graffiti:AddDrawnLineToHistory(v, v2)
		table.insert(Graffiti.DrawPacket[v], v2)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearSignals(p)
	for _, signal in p.Signals do
		signal:Disconnect()
	end

	table.clear(p.Signals)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createMobileGraffitiCam(state)
	local humanoidRootPart = state.HumanoidRootPart

	if not humanoidRootPart then
		return
	end

	RunService:BindToRenderStep("Graffiti_MobileCam", Enum.RenderPriority.Camera.Value - 2, function(_)
		if humanoidRootPart.AssemblyLinearVelocity.Magnitude < 0.5 then
			currentCamera.CameraType = Enum.CameraType.Scriptable
			currentCamera.CFrame = CFrame.new(currentCamera.CFrame.Position) * (state.LastCameraCFrame - state.LastCameraCFrame.Position)
		else
			currentCamera.CameraType = Enum.CameraType.Custom
		end

		state.LastCameraCFrame = currentCamera.CFrame
	end)
end

local SprayPaint = {}

function SprayPaint:Initialize()
	self.Mouse = self.Player:GetMouse()
	self.IsMouseDown = false
	self.IsCharacterMoving = false
	self.LastCFrame = nil
	self.LastCameraCFrame = nil
	self.Epoch = 0
	self.LastPacketSentTime = os.clock()
	self.Signals = {}
	self.LineStartCFrame = nil
	self.LineEndCFrame = nil
	self.LineVisual = Graffiti.Directory:FindFirstChild("LineVisual")
	self.GraffitiUI = game.ReplicatedStorage.Assets.UI.Graffiti
	self.HeartbeatConnection = nil

	if workspace.CurrentCamera:FindFirstChild("Erase") then
		workspace.CurrentCamera.Erase:Destroy()
	end
end

function SprayPaint:Equipped()
	clearSignals(self) -- equivalent call inferred; original call site unknown
	self.IsMouseDown = false
	local clone = self.GraffitiUI:Clone()
	clone.Parent = self.PlayerGui
	Network:fire("SetGraffitiColor", Graffiti.CurrentColor)
	self.LastCameraCFrame = currentCamera.CFrame

	if UserInputService.TouchEnabled then
		createMobileGraffitiCam(self) -- equivalent call inferred; original call site unknown
		table.insert(self.Signals, self.Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
			if not self.IsMouseDown then
				self.IsCharacterMoving = false
			elseif self.Humanoid.MoveDirection.magnitude > 0 then
				self:FireEvent("EnableGraffiti", false)
				self.IsCharacterMoving = true
			else
				self:FireEvent("EnableGraffiti", true)
				self.IsCharacterMoving = false
			end
		end))
	end

	table.insert(self.Signals, self.Mouse.Button1Down:Connect(function()
		if not UserInputService.VREnabled and UserInputService.TouchEnabled and task.wait() and self.Humanoid.MoveDirection.magnitude > 0 and Graffiti.CurrentMode ~= Graffiti.Modes.Eyedropper then
			return
		end

		self.LastCFrame = nil
		self.Epoch = 10
		self.IsMouseDown = true

		if Graffiti.CurrentMode == Graffiti.Modes.Draw then
			self:FireEvent("EnableGraffiti", true)
		end
	end))
	table.insert(self.Signals, self.Mouse.Button1Up:Connect(function()
		self.IsMouseDown = false
		self:FireEvent("EnableGraffiti", false)
	end))

	if UserInputService.TouchEnabled then
		table.insert(self.Signals, self.Player:GetAttributeChangedSignal("State"):Connect(function()
			local state = self.Player:GetAttribute("State")

			if state == 1 or state == 2 then
				RunService:UnbindFromRenderStep("Graffiti_MobileCam")
				return
			end

			createMobileGraffitiCam(self) -- equivalent call inferred; original call site unknown
		end))
	end

	Graffiti:UpdateLayerTransparency()
	self.HeartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		self:OnHeartbeat(dt)
	end)
end

function SprayPaint:Unequipped()
	clearSignals(self) -- equivalent call inferred; original call site unknown
	self.IsMouseDown = false

	if self.HeartbeatConnection then
		self.HeartbeatConnection:Disconnect()
		self.HeartbeatConnection = nil
	end

	if self.PlayerGui:FindFirstChild(self.GraffitiUI.Name) then
		self.PlayerGui[self.GraffitiUI.Name]:Destroy()
	end

	RunService:UnbindFromRenderStep("Graffiti_MobileCam")
	currentCamera.CameraType = Enum.CameraType.Custom

	if workspace.CurrentCamera:FindFirstChild("Erase") then
		workspace.CurrentCamera.Erase:Destroy()
	end

	Graffiti:UpdateLayerTransparency()
end

function SprayPaint:OnHeartbeat(p: number)
	if (next(Graffiti.DrawPacket) or #Graffiti.DeletePacket > 0) and os.clock() - self.LastPacketSentTime > 1 then
		self.LastPacketSentTime = os.clock()

		if next(Graffiti.DrawPacket) then
			Network:fire("DrawGraffiti", Graffiti.DrawPacket)
			Graffiti.DrawPacket = {}
		end

		if #Graffiti.DeletePacket > 0 then
			Network:fire("EraseGraffiti", Graffiti.DeletePacket)
			Graffiti.DeletePacket = {}
		end
	end

	Graffiti.IsPacketEmpty = next(Graffiti.DrawPacket) == nil and #Graffiti.DeletePacket == 0

	if not (self.IsMouseDown and self.Tool.Parent) then
		Graffiti.ShouldCreateNewHistoryCursor = true

		if self.LineVisual then
			drawLine(
				self,
				self.LineStartCFrame,
				self.LineEndCFrame,
				Graffiti.CurrentSize,
				Graffiti.CurrentColor,
				Graffiti.CurrentLayer
			)
			self.LineStartCFrame = nil
			self.LineEndCFrame = nil
			removeExistingLineVisual(self) -- equivalent call inferred; original call site unknown
		end
	end

	if not self.IsMouseDown or self.IsCharacterMoving or not self.Tool.Parent or os.clock() - Graffiti.LastHistoryTime < 0.2 then
		Graffiti.IsMouseDown = false
		return
	end

	Graffiti.IsMouseDown = true
	self.Epoch += p

	if self.Epoch < 0.016666666666666666 then
		return
	end

	self.Epoch = 0
	local raycastResult = workspace:Raycast(
		self.Mouse.UnitRay.Origin,
		self.Mouse.UnitRay.Direction * 200,
		Graffiti.Params
	)

	if raycastResult and (self.HumanoidRootPart.Position - raycastResult.Position).magnitude < Graffiti.MaxRange then
		if raycastResult.Instance.Anchored and (raycastResult.Instance.CanCollide or table.find(
			raycastResult.Instance:GetTags(),
			"GraffitiInclude"
		)) then
			local currentSize = Graffiti.CurrentSize
			local currentColor = Graffiti.CurrentColor
			local currentLayer = Graffiti.CurrentLayer

			if self.LastCFrame and (self.LastCFrame.Position - raycastResult.Position).magnitude < currentSize * 0.5 then
				return
			end

			local v3 = Graffiti:ConstructCFrame(raycastResult.Position, raycastResult.Normal)

			if self.LastCFrame and math.acos((v3.LookVector:Dot(self.LastCFrame.LookVector))) >= 0.3490658503988659 then
				self.LastCFrame = nil
				removeExistingLineVisual(self) -- equivalent call inferred; original call site unknown
			end

			local lastCFrame = self.LastCFrame or v3

			if Graffiti.CurrentMode ~= Graffiti.Modes.Line and self.LineVisual and self.LineVisual then
				self.LineVisual:Destroy()
				self.LineVisual = nil
			end

			if Graffiti.CurrentMode == Graffiti.Modes.Draw then
				drawLine(self, lastCFrame, v3, currentSize, currentColor, currentLayer)
			elseif Graffiti.CurrentMode == Graffiti.Modes.Line then
				if not self.LineStartCFrame then
					self.LineStartCFrame = v3
				end

				if not self.LineVisual or (self.LineEndCFrame.Position - raycastResult.Position).Magnitude > 0.02 then
					removeExistingLineVisual(self) -- equivalent call inferred; original call site unknown
					self.LineVisual = Graffiti:DrawLineBetween(
						self.Player,
						self.LineStartCFrame,
						v3,
						currentSize,
						currentColor,
						currentLayer
					)
					self.LineVisual.Name = "LineVisual"
					self.LineEndCFrame = v3
				end
			elseif Graffiti.CurrentMode == Graffiti.Modes.Erase then
				Graffiti:LocalErase(lastCFrame, currentSize, Graffiti.DeletePacket)
			end

			self.LastCFrame = v3
		else
			self.LastCFrame = nil
			removeExistingLineVisual(self) -- equivalent call inferred; original call site unknown
		end
	end
end

return SprayPaint