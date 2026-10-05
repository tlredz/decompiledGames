local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.Tool)
local Network = require(ReplicatedStorage.Modules.Network)
local UI = require(ReplicatedStorage.Modules.UI)
require(ReplicatedStorage.Modules.Filter)
local House = require(ReplicatedStorage.Modules.Neighbors.House)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local mouse = localPlayer:GetMouse()
task.wait(1)
local stickyNote = playerGui:WaitForChild("StickyNote")
local events = stickyNote:WaitForChild("Events")
local v = {
	StickyNoteOffset = CFrame.Angles(0, -1.5707963267948966, 0) * CFrame.new(-0.95, 0, 0),
	MaxRange = 10
}
local StickyNote = {}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace.Terrain }

local function getClosestNormalId(normal)
	local vector2 = Vector3.new(math.abs(normal.X), math.abs(normal.Y), (math.abs(normal.Z)))

	if vector2.X > vector2.Y and vector2.X > vector2.Z then
		return normal.X > 0 and Enum.NormalId.Right or Enum.NormalId.Left
	end

	if vector2.Y > vector2.X and vector2.Y > vector2.Z then
		return normal.Y > 0 and Enum.NormalId.Top or Enum.NormalId.Bottom
	end

	return normal.Z > 0 and Enum.NormalId.Back or Enum.NormalId.Front
end

local function computeSurfaceCFrame(data)
	local humanoidRootPart = data.HumanoidRootPart
	local currentCamera = workspace.CurrentCamera

	if not (humanoidRootPart and currentCamera) then
		return nil, false
	end

	local v2 = currentCamera.CFrame.Position + createVector(0, -0.75, 0)
	local v3 = CFrame.lookAt(currentCamera.CFrame.Position, mouse.Hit.Position).LookVector * 500

	if UI:GetDeviceType() ~= "PC" then
		v3 = currentCamera.CFrame.LookVector * 500
	end

	local raycastResult = workspace:Raycast(v2, v3, data.Params)
	local normal = raycastResult and raycastResult.Normal

	if not raycastResult then
		return nil, false
	end

	local closestNormalId = getClosestNormalId(normal)
	local partBoundsInRadius = workspace:GetPartBoundsInRadius(raycastResult.Position, 1, data.OverlapParam)
	local unit = (math.abs((normal:Dot(createVector(0, 1, 0)))) >= 1 and createVector(1, 0, 0) or createVector(0, 1, 0)):Cross(normal).Unit
	local cross = normal:Cross(unit)
	local v4 = false

	for _, v6 in partBoundsInRadius do
		if not v6:GetAttribute("StickyNote") then
			continue
		end

		v4 = true
		break
	end

	return
		CFrame.fromMatrix(raycastResult.Position + normal, unit, cross),
		(humanoidRootPart.Position - raycastResult.Position).Magnitude <= v.MaxRange and closestNormalId ~= Enum.NormalId.Top and closestNormalId ~= Enum.NormalId.Bottom and not v4
end

function StickyNote:Initialize()
	self.Mouse = self.Player:GetMouse()
	self.PreviewModel = nil
	self.SetText = false
	self.Params = raycastParams
	self.OverlapParam = overlapParams
	self.ScreenGui = stickyNote
	self.Events = events
	self._Connections = {}
	table.insert(self._Connections, Network:listen("Tool/Event", function(p, p2: string, ...)
		local v2 = p2 == "PlaceStickyNote" and p == self.Tool and ...

		if v2 then
			v2.Enabled = true
		end
	end, true))
	table.insert(self._Connections, events.TextUpdated.Event:Connect(function(p: string)
		self:FireEvent("ConfirmText", p)
	end))
	table.insert(self._Connections, localPlayer.CharacterAdded:Connect(function(character)
		self.Character = character
		self.Humanoid = character:WaitForChild("Humanoid")
		self.HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
	end))
end

local function updatePreviewModel(player, flag: boolean)
	if not player.PreviewModel then
		player.PreviewModel = player.Tool.Handle:Clone()
		local highlight = Instance.new("Highlight")
		highlight.FillTransparency = 0
		highlight.OutlineTransparency = 0
		highlight.Parent = player.PreviewModel
		player.PreviewModel.Anchored = true
		player.PreviewModel.Parent = workspace.Terrain
	end

	player.PreviewModel.Color = flag and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

	if player.PreviewModel:FindFirstChild("Adhesive") then
		player.PreviewModel.Adhesive.Color = flag and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
	end

	if player.PreviewModel:FindFirstChild("Highlight") then
		player.PreviewModel.Highlight.FillColor = flag and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
		player.PreviewModel.Highlight.OutlineColor = flag and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
	end
end

function StickyNote.Activated(object)
	local target = object.Mouse.Target
	local targetModel = target and target:FindFirstAncestorOfClass("Model")
	local playerFromCharacter = targetModel and targetModel:FindFirstChildOfClass("Humanoid") and Players:GetPlayerFromCharacter(targetModel)

	if House:GetHouseFromPlayer(object.Player) then
		if playerFromCharacter then
			object:FireEvent("PlaceStickyNote", playerFromCharacter)
			object.ScreenGui.ImageLabel.TextBox.Text = ""
		else
			local v2, v3 = computeSurfaceCFrame(object)

			if v2 and v3 then
				object:FireEvent("PlaceStickyNote", v2 * v.StickyNoteOffset)
				object.ScreenGui.ImageLabel.TextBox.Text = ""
			end
		end
	end
end

function StickyNote:Equipped()
	self.ScreenGui.Edit.Visible = true

	if not self.SetText then
		self.SetText = true
		self.ScreenGui.ImageLabel.TextBox.Text = `{self.Player.DisplayName} was here!`
		self.Events.TextUpdated:Fire(self.ScreenGui.ImageLabel.TextBox.Text)
	end

	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if self.Tool and self.Tool.Parent == self.Character then
			local v2, v3 = computeSurfaceCFrame(self)
			local houseFromPlayer = House:GetHouseFromPlayer(self.Player)
			updatePreviewModel(self, v3)

			if self.PreviewModel then
				if houseFromPlayer then
					self.Params.FilterDescendantsInstances = {
						House:GetCurrentPrefab().Model,
						House:GetCurrentHouse().Model
					}
				end

				if v2 then
					self.PreviewModel.CFrame = v2 * v.StickyNoteOffset

					if self.PreviewModel:FindFirstChild("SurfaceGui") and self.Tool.Handle:FindFirstChild("SurfaceGui") then
						self.PreviewModel.SurfaceGui.TextLabel.Text = self.Tool.Handle.SurfaceGui.TextLabel.Text
					end
				elseif self.PreviewModel then
					self.PreviewModel:Destroy()
					self.PreviewModel = nil
				end
			end
		else
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end)
	table.insert(self._Connections, heartbeatConnection)
end

function StickyNote:Unequipped()
	if self.Events:FindFirstChild("Visibility") then
		self.ScreenGui.ImageLabel.Visible = false
		self.Events.Visibility:Fire(false)
	end

	if self.ScreenGui:FindFirstChild("Edit") then
		self.ScreenGui.Edit.Visible = false
	end

	if self.PreviewModel then
		self.PreviewModel:Destroy()
		self.PreviewModel = nil
	end
end

function StickyNote:Destroyed()
	self:Unequipped()

	if self._Connections then
		for _, _Connection in self._Connections do
			if typeof(_Connection) == "RBXScriptConnection" then
				_Connection:Disconnect()
			end
		end

		self._Connections = {}
	end
end

return StickyNote