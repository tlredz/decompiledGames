local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local m1Swipe = FX:WaitForChild("LeopardEffects").M1Swipe
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
return function(p)
	local leopardPos = p.leopardPos
	local enemyHrp = p.enemyHrp

	if enemyHrp == nil or enemyHrp.Parent == nil then
		return
	end

	local currentCamera = Workspace.CurrentCamera

	if (enemyHrp.Position - currentCamera.CFrame.Position).Magnitude > 400 then
		return
	end

	if (enemyHrp.Position - currentCamera.CFrame.Position).Magnitude < 70 then
		Util.CameraShaker:ShakeOnce(20, 20, 0.1, 0.4)

		if currentCamera:GetAttribute("FOVInterpActive") ~= true then
			currentCamera:SetAttribute("FOVInterpActive", true)
			local fieldOfView = currentCamera.FieldOfView
			heartbeatLoopFor2(0.04, function(_, _, p2)
				currentCamera.FieldOfView = fieldOfView + (80 - fieldOfView) * p2
			end, function()
				currentCamera.FieldOfView = 80
			end)
			task.delay(0.25, function()
				heartbeatLoopFor2(0.1, function(_, _, p2)
					currentCamera.FieldOfView = 80 + (fieldOfView - 80) * p2
				end, function()
					currentCamera.FieldOfView = fieldOfView
					currentCamera:SetAttribute("FOVInterpActive", false)
				end)
			end)
		end
	end

	local clone = m1Swipe:Clone()
	clone.Parent = _WorldOrigin
	clone.M1Swipe.WorldCFrame = CFrame.lookAt(
		createVector(0, 0, 0),
		(enemyHrp.Position - leopardPos) * createVector(1, 0, 1)
	) + enemyHrp.Position
	destroyAfter(clone, 1.4)

	if random:NextInteger(1, 2) == 1 then
		clone.M1Swipe.Hit.RotSpeed = NumberRange.new(-140, -100)
		clone.M1Swipe.Hit2.RotSpeed = NumberRange.new(-140, -100)
	else
		clone.M1Swipe.Hit.RotSpeed = NumberRange.new(100, 140)
		clone.M1Swipe.Hit2.RotSpeed = NumberRange.new(100, 140)
	end

	for _, child in ipairs(clone.M1Swipe:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end

	Util.UtilSoundWrapper.Play(FX:WaitForChild("LeopardEffects").M1HitEnemy:Clone(), enemyHrp.Position)
end