game:GetService("Players")
game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local modules = CAM.Client.Modules
local _ = workspace.Debree
script:FindFirstChild("Assets")
script:FindFirstChild("Sounds")
require(CAM.DebrisModule)
require(modules.Effects.Cam_Shaker)
require(modules.Effects.Craters.CraterHandler)
require(modules.Effects.BoatTween)
require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local _ = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include
return function(instance, p)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart
	instance:FindFirstChild("UpperTorso")

	if p == "Cancel" or not ((humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > 250) then
	end
end