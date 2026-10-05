local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Shake = require(ReplicatedStorage2.packages.Shake)
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage3.packages.Net)
require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local localPlayer = game.Players.LocalPlayer

-- equivalent calls inferred from this helper; original call sites unknown
local function fastTween(p, tweenInfo, p2)
	local tween = TweenService:Create(p, tweenInfo, p2)
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	tween:Play()
	return tween
end

local WaterTrapsController = {}

function WaterTrapsController.BarrelsShakeCamera()
	if not SettingsController:GetSettingValue("cameraShake") then
		return
	end

	local currentCamera = workspace.CurrentCamera
	local value = Enum.RenderPriority.Last.Value
	local v = Shake.new()
	v.FadeInTime = 0.05
	v.FadeOutTime = 0.25
	v.Frequency = 0.1
	v.Amplitude = 1.5
	v.SustainTime = 0.7
	v.Sustain = true
	v.RotationInfluence = createVector(0.1, 0.1, 0.1)
	v:Start()
	v:BindToRenderStep(Shake.NextRenderName(), value, function(position, data, _)
		currentCamera.CFrame *= CFrame.new(position) * CFrame.Angles(data.X, data.Y, data.Z)
	end)
	task.delay(1, function()
		v:Stop()
		task.wait(1)
		v:Destroy()
	end)
end

function WaterTrapsController:SetWaterTrapZoneFOV(p)
	if p then
		local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
		ReplicatedStorage4.resources.sounds.music.WaterTrapZone.Volume = 0
		local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
		ReplicatedStorage5.resources.sounds.music.WaterTrapZone:Play()
		local ReplicatedStorage6 = game:GetService("ReplicatedStorage")
		fastTween(ReplicatedStorage6.resources.sounds.music.WaterTrapZone, TweenInfo.new(1), {
			Volume = 0.35
		}) -- equivalent call inferred; original call site unknown
		localPlayer:SetAttribute("InWaterTrapZone", true)
		fastTween(game.Workspace.CurrentCamera, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			FieldOfView = 60
		}) -- equivalent call inferred; original call site unknown
	else
		local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
		fastTween(ReplicatedStorage4.resources.sounds.music.WaterTrapZone, TweenInfo.new(1), {
			Volume = 0
		}) -- equivalent call inferred; original call site unknown
		localPlayer:SetAttribute("InWaterTrapZone", false)
		fastTween(game.Workspace.CurrentCamera, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			FieldOfView = 70
		}) -- equivalent call inferred; original call site unknown
	end
end

function WaterTrapsController:Start()
	Net:RemoteEvent("WaterTrapsZone/CameraFOV", -1).OnClientEvent:Connect(function(p)
		self:SetWaterTrapZoneFOV(p)
	end)
	Net:RemoteEvent("WaterTrapsZone/BarrelsShaker").OnClientEvent:Connect(function(p)
		if (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude <= 90 then
			self.BarrelsShakeCamera()
		end
	end)
end

return WaterTrapsController