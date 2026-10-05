local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
game:GetService("CollectionService")
local CAM = ReplicatedStorage2.CAM
local client = CAM.Client
local global = CAM.Global
local Platform_Handler = require(client.Controllers.Platform_Handler)
local cleanit = require(game.ReplicatedStorage.Packages.cleanit)
cleanit.new()
local Utility = require(global.Utility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
require(global.Checker)
require(CAM.DebrisModule)
local Config = require(script.Parent.Config)
Utility.getvaluesfolder(Players.LocalPlayer)
local KoketsuArrow = {}
KoketsuArrow.Id = 0

function KoketsuArrow.Hold(player)
	local humanoid = player.Character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	humanoid:FindFirstChild("Animator"):LoadAnimation(script.StartUp):Play()
	task.spawn(function()
		local child = game.Workspace.Debree.Projectiles:WaitForChild(`{player.Name} - {script.Parent.Name}`, 0.2)

		if child ~= nil then
			while child ~= nil and child.Parent ~= nil do
				local maximizeRayClient = RaycastHelper.MaximizeRayClient(
					rootPart.Position,
					Platform_Handler.mousepos(),
					Config.AIM_RANGE,
					nil,
					5
				)
				local cframe = CFrame.lookAt(child.Position, maximizeRayClient)
				child.Rotator.CFrame = cframe
				child.Mover.VectorVelocity = cframe.LookVector * Config.PROJECTILE_SPEED
				task.wait()
			end
		end
	end)
end

function KoketsuArrow.UnHold(_) end

function KoketsuArrow.Cancel(_) end

return KoketsuArrow