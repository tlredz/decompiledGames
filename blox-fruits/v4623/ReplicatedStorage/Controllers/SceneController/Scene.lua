local createVector = vector.create
local class = {}
class.__index = class
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local Signal = require(game.ReplicatedStorage.Modules.Util.Signal)
require(script.SceneTypes)
require(game.ReplicatedStorage.Controllers.CameraController.Types)
local count = 0
local folder = Instance.new("Folder")
folder.Name = "Scenes"
folder.Parent = workspace._WorldOrigin
local fieldOfView = workspace.CurrentCamera.FieldOfView
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local scenes = ReplicatedStorage:FindFirstChild("Scenes")
assert(scenes, "ScenesInstance is nil")
local v = {
	HalloweenScene = scenes:FindFirstChild("HalloweenScene"),
	WinterScene = scenes:FindFirstChild("WinterScene"),
	ValentinesScene = scenes:FindFirstChild("ValentinesScene")
}
local v2 = nil

function class.ScaleTo(_, _: number) end

function class:SetCamera(camera)
	if self.Camera == nil or self.Camera._uid ~= camera._uid then
		if self.Camera then
			self.Camera:Destroy()
		end

		self.Camera = camera
	end
end

function class:Init()
	if self._Initiated then
		return
	end

	self._Initiated = true
	local flag = false
	local position = createVector(0, 0, 0)
	local v3 = 0
	local rotateAxis = Enum.DragDetectorDragStyle.RotateAxis
	self._Maid:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or not self._DragEnabled then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonL2 or input.KeyCode == Enum.KeyCode.ButtonR2 then
			position = input.Position
			flag = true

			if input.KeyCode == Enum.KeyCode.ButtonL2 or input.KeyCode == Enum.KeyCode.ButtonR2 then
				local v4 = input.KeyCode == Enum.KeyCode.ButtonL2 and -1 or 1

				while flag and not self._Destroyed do
					local v5 = v3 + v4
					local v6 = v3 - v5
					v3 = v5
					self._Yaw = -v6 * 0.1
					task.wait()
				end
			end
		end
	end))
	self._Maid:Add(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.ButtonL2 or input.KeyCode == Enum.KeyCode.ButtonR2 then
			flag = false
		end
	end))
	self._Maid:Add(function()
		flag = false
	end)
	self._Maid:Add(UserInputService.InputChanged:Connect(function(input)
		if flag and table.find(
			{ Enum.UserInputType.Touch.Name, Enum.UserInputType.MouseMovement.Name },
			input.UserInputType.Name
		) then
			local v4 = position - input.Position
			position = input.Position

			if rotateAxis == Enum.DragDetectorDragStyle.RotateTrackball then
				self._Pitch = -math.clamp(self._Pitch - v4.Y * 0.0025, -1.0471975511965976, 0.7853981633974483)
			end

			if rotateAxis == Enum.DragDetectorDragStyle.RotateAxis or rotateAxis == Enum.DragDetectorDragStyle.RotateTrackball then
				self._Yaw = -v4.X * (LastInput:Get() == "Touch" and 0.01 or 0.0025)
			end
		end
	end))
	local _Rig = self._Rig
	local _Maid = self._Maid
	local RunService = game:GetService("RunService")
	self._RenderStepped = _Maid:Add(RunService.RenderStepped:Connect(function(_: number)
		debug.profilebegin("Scene.UpdateRigRot")

		if _Rig ~= self._Rig then
			self._InitialRotationFinished = false
		end

		_Rig = self._Rig
		local _Rig2

		if self._Rig and self._Rig.Parent then
			_Rig2 = self._Rig
		end

		if self._InitialRotationFinished and _Rig2 then
			if self._DragEnabled then
				self._Yaw *= 0.9
				self._Pitch *= 0.9

				if self._Pitch ~= 0 or self._Yaw ~= 0 then
					_Rig2:PivotTo(_Rig2:GetPivot() * CFrame.Angles(self._Pitch, self._Yaw, 0))
				end
			end
		elseif not self._InitialRotationFinished and _Rig2 then
			self._InitialRotationFinished = true
		end

		debug.profileend()
	end))
end

function class:SetDragEnabled(flag: boolean)
	self._DragEnabled = flag == true
end

function class:SpawnRig(rig, _: number?)
	if self._Rig ~= rig then
		self._Maid:Add(rig.Destroying:Connect(function()
			self._Rig = nil
		end))
	end

	if self._Rig and self._Rig ~= rig then
		self._Rig:Destroy()
	end

	self._Rig = rig
	return rig
end

function class:Destroy()
	if not self._Destroyed then
		v2 = nil
		self._Destroyed = true
		self._Maid:Destroy()
		self._Storage:Destroy()

		if self.Camera then
			self.Camera:Destroy()
		end

		if self._Rig then
			self._Rig:Destroy()
		end

		local pivot = self._Model:GetPivot()
		self._Model:PivotTo(CFrame.new(
			pivot.X,
			workspace.FallenPartsDestroyHeight + self._Model:GetExtentsSize().Y,
			pivot.Z
		))
		self._Rig = nil
		task.defer(function()
			local character = Players.LocalPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				workspace.CurrentCamera.CameraSubject = humanoid
			end

			workspace.CurrentCamera.FieldOfView = fieldOfView
			local count2 = 0

			while count2 ~= 5 do
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

				if workspace.CurrentCamera.CameraType == Enum.CameraType.Custom then
					break
				end

				count2 += 1
				task.wait(0.1)
			end
		end)
		self.Destroying:Fire()
		self.Destroying:Destroy()
		task.spawn(function()
			local Net = require(game.ReplicatedStorage.Modules.Net)
			Net:RemoteFunction("SceneNetwork"):InvokeServer({
				Context = "Cleanup"
			})
		end)
	end
end

return function(p)
	assert(v2 == nil, "how are we creating another scene??")
	local folder2 = v[p]

	if folder2 == nil then
		warn((`{p} is nil, using any other scene`))

		for _, v4 in pairs(v) do
			folder2 = v4
			break
		end
	end

	assert(folder2, (`no scene available from {p}`))
	count += 1
	local folder3 = Instance.new("Folder", workspace)
	folder3.Name = `Scene_{Players.LocalPlayer.UserId}_{count}`
	folder3.Parent = workspace._WorldOrigin
	folder2:SetAttribute("_OriginalScale", folder2:GetScale())

	if not folder2:GetAttribute("Initialized") then
		local Net = require(game.ReplicatedStorage.Modules.Net)
		local cframe = Net:RemoteFunction("SceneNetwork"):InvokeServer({
			Context = "GetSceneLocation"
		})
		folder2:SetAttribute("Initialized", true)
		folder2:SetAttribute("SceneCFrame", cframe)
		local attach = folder2:WaitForChild("Attach")
		local coneHandleAdornment = attach:FindFirstChildOfClass("ConeHandleAdornment")

		if attach:IsA("BasePart") then
			attach.Transparency = 1
		end

		if coneHandleAdornment then
			coneHandleAdornment.Visible = false
		end
	end

	folder2:PivotTo((folder2:GetAttribute("SceneCFrame")))

	if folder2.Parent ~= folder then
		folder2.Parent = folder
	end

	local floorAttachment = assert(folder2:FindFirstChild("AttachmentPoint", true), "backdrop requires AttachmentPoint")

	if folder2:FindFirstChild("Model") then
		for _, part in pairs(folder2:GetDescendants()) do
			if part:IsA("MeshPart") and part.Name ~= "Cylinder.015" then
				part:Destroy()
			end
		end
	end

	v2 = setmetatable({
		Destroying = Signal.new(),
		_UID = count,
		_Storage = folder3,
		_Model = folder2,
		_Maid = Trove.new(),
		_Destroyed = false,
		_Initiated = false,
		_FloorAttachment = floorAttachment,
		_InitialRotationFinished = false,
		_Yaw = 0,
		_Pitch = 0,
		_DragEnabled = true
	}, class)
	return v2
end