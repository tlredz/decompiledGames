local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Promise = require(packages:WaitForChild("Promise"))
local Trove = require(packages:WaitForChild("Trove"))
local legacyControllers = ReplicatedStorage.client.legacyControllers
local CutsceneController = require(legacyControllers:WaitForChild("CutsceneController"))
local PlayerController = require(legacyControllers:WaitForChild("PlayerController"))
local LightingController = require(legacyControllers:WaitForChild("LightingController"))
local DeepConfig = require(ReplicatedStorage.shared.modules.DeepConfig)
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera

local function getTower(p: string)
	for _, v in CollectionService:GetTagged("DeepBeaconTower") do
		if v:GetAttribute("Sector") == p then
			return v
		end
	end

	return nil
end

local function igniteColorParts(folder)
	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part.Name == "ColorPart") then
			continue
		end

		part.Material = Enum.Material.Neon
		part.Color = Color3.new(1, 1, 1)
		TweenService:Create(part, TweenInfo.new(1.8, Enum.EasingStyle.Quad), {
			Color = DeepConfig.BeaconActiveColor
		}):Play()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function lookAt(pointToWorldSpace: Vector3, position: Vector3)
	return CFrame.lookAt(pointToWorldSpace, position)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPlayerState(flag: boolean, anchored: boolean)
	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	humanoidRootPart.Anchored = anchored
	PlayerController:ToggleControls(not flag)
	ProximityPromptService.Enabled = not flag
end

local function panCamera(object, cframe: CFrame, cframe2: CFrame, duration: number, p)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = cframe
	object:Add(cFrameValue)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		currentCamera.CFrame = cFrameValue.Value
		currentCamera.Focus = currentCamera.CFrame
	end)
	TweenService:Create(cFrameValue, TweenInfo.new(duration, p, Enum.EasingDirection.InOut), {
		Value = cframe2
	}):Play()
	task.wait(duration)
	renderSteppedConnection:Disconnect()
end

return {
	Start = function(_, p, p2: string)
		return Promise.new(function(callback)
			if p ~= localPlayer then
				return callback()
			end

			local tower = getTower(p2)

			if tower then
				local pivot = tower:GetPivot()
				local position = pivot.Position
				local maid = Trove.new()
				setPlayerState(true, true) -- equivalent call inferred; original call site unknown
				maid:Add(function()
					local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

					if not humanoidRootPart then
						return
					end

					humanoidRootPart.Anchored = false
					PlayerController:ToggleControls(true)
					ProximityPromptService.Enabled = true
				end)
				CutsceneController:DisableAllScreens(11.7)
				task.spawn(function()
					CutsceneController:FadeWithSaneFuckingArgumentsFuckThisShit(1.2, 0)
				end)
				task.wait(0.6)
				local cFrame = currentCamera.CFrame
				currentCamera.CameraType = Enum.CameraType.Scriptable
				local v = currentCamera
				local pointToWorldSpace = pivot:PointToWorldSpace(createVector(0, 110, 78))
				v.CFrame = CFrame.lookAt(pointToWorldSpace, position)
				currentCamera.Focus = currentCamera.CFrame
				maid:Add(function()
					currentCamera.CFrame = cFrame
					currentCamera.CameraType = Enum.CameraType.Custom
				end)
				task.wait(0.6)
				task.spawn(function()
					CutsceneController:ShowBars(9, 0.05, 0.1)
				end)
				local v3 = lookAt(pivot:PointToWorldSpace(createVector(0, 110, 78)), position) -- equivalent call inferred; original call site unknown
				local pointToWorldSpace3 = pivot:PointToWorldSpace(createVector(0, 70, 80))
				panCamera(maid, v3, CFrame.lookAt(pointToWorldSpace3, position), 4.5, Enum.EasingStyle.Quad)
				igniteColorParts(tower)
				LightingController.UpdateLighting(2.5)
				task.delay(3, function()
					CutsceneController:FadeWithSaneFuckingArgumentsFuckThisShit(1.5, 1.5)
				end)
				local v5 = lookAt(pivot:PointToWorldSpace(createVector(0, 70, 80)), position) -- equivalent call inferred; original call site unknown
				local pointToWorldSpace5 = pivot:PointToWorldSpace(createVector(0, -50, 40))
				panCamera(maid, v5, CFrame.lookAt(pointToWorldSpace5, position), 3, Enum.EasingStyle.Quint)
				task.wait(1.5)
				maid:Destroy()
				task.wait(1.5)
				callback()
			else
				warn((`[DeepBeaconActivation] No tower found for sector: {p2}`))
				LightingController.UpdateLighting(2.5)
				return callback()
			end
		end)
	end
}