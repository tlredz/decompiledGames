local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = Players.LocalPlayer.PlayerScripts
local currentCamera = workspace.CurrentCamera
local CharacterController = require(ReplicatedStorage.Controllers.CharacterController)
local controls = CharacterController.Controls
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local burst = ReplicatedStorage.Assets.Tools["Flying Bee"].Burst
local buzzing = script.Buzzing
local remoteEvent = Net:RemoteEvent("UseItem")
local originalMoveFunction = CharacterController.originalMoveFunction
remoteEvent.OnClientEvent:Connect(function(p, part, value: number?, value2: number?)
	if p == "Flying Bee Burst" then
		if typeof(part) ~= "Instance" or not part:IsA("BasePart") then
			return
		end

		local clone = burst:Clone()
		clone.Anchored = false
		clone.CFrame = part.CFrame
		clone.Parent = part.Parent
		local weld = Instance.new("Weld")
		weld.Part0 = clone
		weld.Part1 = part
		weld.Parent = clone
		VFX.emit(clone)
		task.delay(5, clone.Destroy, clone)
	else
		if p ~= "Bee Attack" then
			return
		end

		local v = typeof(part) ~= "number" and 5 or part
		currentCamera.FieldOfView = value or 20
		buzzing:Play()

		function controls.moveFunction(p2, p3, p4)
			CharacterController:RequestMove(p2, -p3, p4)
		end

		local clone = script.ColorCorrection:Clone()
		clone.Parent = Lighting
		local blurEffect = Instance.new("BlurEffect")
		blurEffect.Size = value2 or 10
		blurEffect.Name = "BeeBlur"
		blurEffect.Parent = Lighting
		task.delay(v, function()
			controls.moveFunction = originalMoveFunction
			currentCamera.FieldOfView = 70
			clone:Destroy()
			blurEffect:Destroy()
		end)
	end
end)
return {}