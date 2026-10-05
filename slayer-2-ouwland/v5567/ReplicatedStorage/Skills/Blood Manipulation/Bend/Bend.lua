local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local v = cleanit.new()
local Bend = {
	Id = 0
}
local currentCamera = workspace.CurrentCamera
local _ = Vector3.new
local track = nil
game:GetService("Debris")
local _ = table.insert
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local Config = require(script.Parent.Config)

function Bend.Hold(player)
	local id = Bend.Id
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")
	local attachment = Instance.new("Attachment", humanoidRootPart)
	attachment.Name = "skill_stand_still"
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.Name = "bv"
	linearVelocity.MaxForce = 40000
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.VectorVelocity = createVector(0, 0, 0)
	linearVelocity.Parent = attachment
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "NR"
	boolValue.Parent = getvaluesfolder
	v:Add(boolValue)
	v:Add(attachment)
	task.spawn(function()
		local child = workspace.Debree.Projectiles:WaitForChild("BendProjectile" .. character.Name, 1)

		if child == nil then
			return
		end

		local alignOrientation = child:WaitForChild("AlignOrientation")
		local linearVelocity2 = child:WaitForChild("LinearVelocity")

		while Bend.Id == id and child do
			task.wait()

			if not (child and child:FindFirstChild("VFX")) then
				continue
			end

			local position = child.Position
			alignOrientation.CFrame = CFrame.new(position, position + currentCamera.CFrame.LookVector)
			linearVelocity2.VectorVelocity = currentCamera.CFrame.LookVector * Config.FLIGHT_SPEED
		end
	end)
	track = humanoid.Animator:LoadAnimation(script:WaitForChild("BendCharge"))
	track:Play()
	task.wait(Config.CHARGE_DUR)
	track:Stop()

	if Bend.Id ~= id then
		return
	end

	track = humanoid.Animator:LoadAnimation(script:WaitForChild("BendLaunch"))
	track:Play()
	task.wait(Config.LAUNCH_FREEZE_AT)

	if Bend.Id ~= id then
		return
	end

	track:AdjustSpeed(0)
end

function Bend.UnHold(player, _)
	local _ = Bend.Id
	local character = player.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")

		if not (humanoidRootPart or humanoid) then
			return
		end

		v:CleanAfter(Config.UNHOLD_CLEAN_DELAY)

		for _, v2 in pairs(humanoid:GetPlayingAnimationTracks()) do
			if not table.find({ "BendCharge", "BendLaunch" }, v2.Name) then
				continue
			end

			v2:Stop()
			v2:Destroy()
		end
	end
end

function Bend.Cancel(player)
	local _ = Bend.Id
	local character = player.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")

		if not (humanoidRootPart or humanoid) then
			return
		end

		v:Clean()

		for _, v2 in pairs(humanoid:GetPlayingAnimationTracks()) do
			if not table.find({ "BendCharge", "BendLaunch" }, v2.Name) then
				continue
			end

			v2:Stop()
			v2:Destroy()
		end
	end
end

return Bend