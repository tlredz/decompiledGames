local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local CameraLazyLoadUtil = require(ReplicatedStorage.Modules.Shared.World.CameraLazyLoadUtil)
local LazyLoadModelController = require(ReplicatedStorage.Modules.Client.LazyLoad.LazyLoadModelController)
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local v = Component.new({
	Tag = "CityCams"
})
v.SeatStatusChanged = Signal.new()

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:_focusCamera(cameraSubject)
	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.CameraSubject = cameraSubject
	currentCamera.CFrame = cameraSubject.CFrame
end

function v:_updateForcedLazyLoadWindow(p, p2: number)
	if p[p2] == nil then
		LazyLoadModelController.ClearForcedCameraWindow()
	else
		LazyLoadModelController.SetForcedCameraWindow(CameraLazyLoadUtil.SOURCE_CITY, p2)
	end
end

function v:Start()
	local v2 = {}
	local v3 = 1
	local v4 = 1
	self._Janitor:Add(v.SeatStatusChanged:Connect(function(instance)
		if instance then
			local cityCamsFolderFromSeat = CameraLazyLoadUtil.getCityCamsFolderFromSeat(instance)

			if cityCamsFolderFromSeat == nil then
				cityCamsFolderFromSeat = workspace:WaitForChild("WorkspaceCom"):WaitForChild(CameraLazyLoadUtil.DEFAULT_CITY_CAMS_FOLDER_NAME)
			end

			local v5

			if cityCamsFolderFromSeat == nil then
				v5 = false
			else
				v5 = cityCamsFolderFromSeat:IsA("Folder")
			end

			assert(v5, "CityCamsSeat CamerasFolder must reference a Folder")
			local cameraText = instance:GetAttribute("CameraText")
			self.Instance.HouseCamsUI.Picks.TextLabel.Text = cameraText or "Police Cams"
			v2 = CameraLazyLoadUtil.collectSortedCityCamParts(cityCamsFolderFromSeat)
			v4 = CameraLazyLoadUtil.getMinCityCamIndex(instance)
			v3 = v4
			self.Instance.Visible = true

			if v2[v3] then
				self:_focusCamera(v2[v3])
			end

			self:_updateForcedLazyLoadWindow(v2, v3)
		else
			self.Instance.Visible = false
			LazyLoadModelController.ClearForcedCameraWindow()
			v2 = {}
			local character = localPlayer.Character

			if not character then
				return
			end

			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if not humanoid then
				return
			end

			currentCamera.CameraSubject = humanoid
			currentCamera.CameraType = Enum.CameraType.Custom
		end
	end))
	self._Janitor:Add(self.Instance.HouseCamsUI.Picks.Frame.Left.MouseButton1Click:Connect(function()
		local count = #v2

		if count == 0 then
			return
		end

		local v5

		if v3 == count then
			v5 = v4
		else
			v5 = v3 + 1
		end

		v3 = v5

		if v2[v3] then
			self:_focusCamera(v2[v3])
		end

		self:_updateForcedLazyLoadWindow(v2, v3)
	end))
	self._Janitor:Add(self.Instance.HouseCamsUI.Picks.Frame.Right.MouseButton1Click:Connect(function()
		local count = #v2

		if count == 0 then
			return
		end

		if v3 ~= v4 then
			count = v3 - 1
		end

		v3 = count

		if v2[v3] then
			self:_focusCamera(v2[v3])
		end

		self:_updateForcedLazyLoadWindow(v2, v3)
	end))
	self._Janitor:Add(self.Instance.Exit.MouseButton1Click:Connect(function()
		local character = localPlayer.Character

		if not character then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if not humanoid then
			return
		end

		humanoid.Sit = false
	end))
end

function v:Stop()
	LazyLoadModelController.ClearForcedCameraWindow()
	self._Janitor:Destroy()
end

return v