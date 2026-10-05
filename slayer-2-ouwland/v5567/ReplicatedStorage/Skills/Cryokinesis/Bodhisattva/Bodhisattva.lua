local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local Utility = require(CAM.Global.Utility)
local Platform_Handler = require(CAM.Client.Controllers.Platform_Handler)
local Config = require(script.Parent.Config)
local bodhisattvaStartup = script.BodhisattvaStartup
local Bodhisattva = {}
Bodhisattva.Id = 0

function Bodhisattva.Hold(player)
	v:Clean()
	local humanoid = player.Character:FindFirstChild("Humanoid")
	local track = humanoid:FindFirstChild("Animator"):LoadAnimation(bodhisattvaStartup)
	v:Add(track)
	track:Play()
	local rootPart = humanoid.RootPart
	local mousepos = Platform_Handler.mousepos()
	local cframe = CFrame.lookAt(rootPart.Position, (Vector3.new(mousepos.X, rootPart.Position.Y, mousepos.Z)))
	local v2 = cframe - cframe.Position
	local alignOrientationWithAttachment, v3 = Utility.CreateAlignOrientationWithAttachment(rootPart, "skill_look_at", {
		Responsiveness = 70,
		MaxTorque = 500000,
		CFrame = v2 + rootPart.Position
	})
	v:Add(v3)
	v:Add(alignOrientationWithAttachment)
	v:Connect(RunService.PostSimulation, function(p: number)
		local mousepos2 = Platform_Handler.mousepos()
		local vector2 = Vector3.new(mousepos2.X - rootPart.Position.X, 0, mousepos2.Z - rootPart.Position.Z)

		if vector2.Magnitude > 0.1 then
			local cframe2 = CFrame.lookAt(createVector(0, 0, 0), vector2)
			v2 = v2:Lerp(cframe2, (math.clamp(p * 4, 0, 1)))
		end

		alignOrientationWithAttachment.CFrame = v2 + rootPart.Position
	end)
	task.wait(0.6666666666666666)
	track:AdjustSpeed(0.01)
	task.wait(0.5)
	track:AdjustSpeed(1)
	task.wait(Config.ANIMATION_DURATION - 1.1666666666666667)
	v:Clean()
end

function Bodhisattva.UnHold(_) end

function Bodhisattva.Cancel(_)
	v:Clean()
end

return Bodhisattva