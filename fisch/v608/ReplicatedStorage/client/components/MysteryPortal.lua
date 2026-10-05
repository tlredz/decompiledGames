local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local FishModel = require(ReplicatedStorage.shared.modules.FishModel)
local remoteFunction = Net:RemoteFunction("MysteriousPortal/Request")
local module = require("../legacyControllers/HudController")
local module2 = require("../legacyControllers/PlayerController")
local module3 = require("../legacyControllers/DataController")
local playerDataReplicator = module3.PlayerDataReplicator
local v = Component.new({
	Tag = "MysteryPortal",
	Ancestors = { workspace }
})
local flag = false
local random = Random.new()

function v:Construct()
	self.Trove = Trove.new()
	self.FihTrove = self.Trove:Extend()
end

function v:UpdateVisual()
	local enabled = playerDataReplicator:TryIndex({ "MysteryPortal", "Active" })

	if enabled then
		self.FihTrove:Clean()
	end

	for _, v3 in self.Instance:QueryDescendants("ParticleEmitter") do
		v3.Enabled = enabled
	end
end

function v:AddFish(p2)
	if playerDataReplicator:TryIndex({ "MysteryPortal", "Active" }) then
		return
	end

	self.FihTrove:Add(task.spawn(function()
		local v2 = FishModel.Create({
			Name = p2.name,
			ItemData = p2.sub,
			ResizeArgs = {
				MaxSize = 10
			},
			RemoveScripts = true,
			CastShadow = false
		})

		if not v2 then
			return
		end

		self.FihTrove:Add(v2)
		v2:PivotTo(self.Instance.CFrame + Vector3.new(math.random(-50, 50), -25, math.random(-50, 50)))
		local center = v2:WaitForChild("Center")
		center.Anchored = true
		v2.Parent = self.Instance
		local v3 = random:NextUnitVector() * 10
		local v4 = (random:NextUnitVector() * createVector(1, 1, 0)).Unit * random:NextNumber(45, 70)
		local v5 = random:NextUnitVector() * random:NextNumber(45, 70)
		local identity = CFrame.identity
		local identity2 = CFrame.identity
		local identity3 = CFrame.identity
		self.FihTrove:Add(RunService.RenderStepped:Connect(function(dt)
			identity *= CFrame.fromOrientation(math.rad(v4.X * dt), math.rad(v4.Y * dt), (math.rad(v4.Z * dt)))
			identity2 *= CFrame.fromOrientation(math.rad(v5.X * dt), math.rad(v5.Y * dt), (math.rad(v5.Z * dt)))
			local v6 = center
			local smoothDamp, v7 = TweenService:SmoothDamp(
				center.CFrame,
				(self.Instance.CFrame + identity * v3) * identity2,
				identity3,
				1,
				nil,
				dt
			)
			v6.CFrame = smoothDamp
			identity3 = v7
		end))
	end))
end

function v:Start()
	self.Trove:Add(self.Instance.Touched:Connect(function(otherPart)
		if not localPlayer.Character or otherPart.Parent ~= localPlayer.Character or not playerDataReplicator:TryIndex({
			"MysteryPortal",
			"Active"
		}) then
			return
		end

		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

		if not humanoid or humanoid.Health <= 0 then
			return
		end

		local currentCamera = workspace.CurrentCamera

		if not currentCamera or flag then
			return
		end

		flag = true
		local screenGui = Instance.new("ScreenGui")
		screenGui.ClipToDeviceSafeArea = false
		screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
		screenGui.ScreenInsets = Enum.ScreenInsets.None
		screenGui.ResetOnSpawn = false
		screenGui.DisplayOrder = 999999999
		screenGui.Name = "fadeOverlay"
		local frame = Instance.new("Frame")
		frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.fromScale(1, 1)
		frame.Parent = screenGui
		screenGui.Parent = module:GetPlayerGui()
		TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
			BackgroundTransparency = 0
		}):Play()
		TweenService:Create(currentCamera, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			FieldOfView = 40
		}):Play()
		currentCamera.CameraType = Enum.CameraType.Scriptable
		local hud = module:GetHud()
		hud.Enabled = false
		local deviceInsetGui = module:GetDeviceInsetGui()
		deviceInsetGui.Enabled = false
		local backpackGui = module:GetBackpackGui()
		backpackGui.Enabled = false
		humanoid:UnequipTools()
		task.wait(2)
		GuiService:SetGameplayPausedNotificationEnabled(false)

		if remoteFunction:InvokeServer(self.Instance) then
			task.wait(1)
			currentCamera.CameraType = Enum.CameraType.Custom
			currentCamera.FieldOfView = 70
			TweenService:Create(frame, TweenInfo.new(3, Enum.EasingStyle.Linear), {
				BackgroundTransparency = 1
			}):Play()
			GuiService:SetGameplayPausedNotificationEnabled(true)
			task.wait(3)
			local hud_2 = module:GetHud()
			hud_2.Enabled = true
			local deviceInsetGui_2 = module:GetDeviceInsetGui()
			deviceInsetGui_2.Enabled = true
			local backpackGui_2 = module:GetBackpackGui()
			backpackGui_2.Enabled = true
			task.wait(2)
		else
			screenGui:Destroy()
			GuiService:SetGameplayPausedNotificationEnabled(true)
			currentCamera.CameraType = Enum.CameraType.Custom
			currentCamera.FieldOfView = 70
			module2:ToggleControls(true)
			local hud_3 = module:GetHud()
			hud_3.Enabled = true
			local deviceInsetGui_3 = module:GetDeviceInsetGui()
			deviceInsetGui_3.Enabled = true
			local backpackGui_3 = module:GetBackpackGui()
			backpackGui_3.Enabled = true
			task.wait(3)
		end

		flag = false
	end))
	self.Trove:Add(playerDataReplicator:Observe({ "MysteryPortal", "Active" }, function()
		self:UpdateVisual()
	end))
	self.Trove:Add(playerDataReplicator:ObserveKeys({ "MysteryPortal", "ModelData" }, function(_, p)
		self:AddFish(p)
	end))
end

function v.Stop(p)
	p.Trove:Clean()
end

return v