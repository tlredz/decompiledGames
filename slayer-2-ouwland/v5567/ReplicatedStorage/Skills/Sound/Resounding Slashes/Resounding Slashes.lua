local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local client = CAM:WaitForChild("Client")
local global = CAM:WaitForChild("Global")
local Platform_Handler = require(client:WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Utility = require(global:WaitForChild("Utility"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require(ReplicatedStorage2.Packages.cleanit).new()
local DebrisModule = require(CAM:FindFirstChild("DebrisModule"))
local ResoundingSlashes = {
	Id = 0
}
local localPlayer = game.Players.LocalPlayer
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local v2 = nil
local v3 = nil
local clone = nil
local track = nil

function ResoundingSlashes.Hold(player)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local _ = ResoundingSlashes.Id
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	local humanoid = character:FindFirstChild("Humanoid")

	if not (humanoidRootPart and humanoid) then
		return
	end

	clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	local mousepos = Platform_Handler.mousepos(500)
	local safeLookAt = Utility.SafeLookAt
	local position = humanoidRootPart.Position
	local X = mousepos.X
	humanoidRootPart.CFrame = safeLookAt(
		position,
		Vector3.new(X, humanoidRootPart.Position.Y, mousepos.Z),
		humanoidRootPart.CFrame
	)
	local createAlignOrientationWithAttachment = Utility.CreateAlignOrientationWithAttachment
	local v4 = {
		AlignType = Enum.AlignType.AllAxes,
		Responsiveness = 10,
		MaxTorque = 500000,
		CFrame = 0
	}
	local safeLookAt2 = Utility.SafeLookAt
	local position2 = humanoidRootPart.Position
	local X2 = mousepos.X
	v4.CFrame = safeLookAt2(
		position2,
		Vector3.new(X2, humanoidRootPart.Position.Y, mousepos.Z),
		humanoidRootPart.CFrame
	)
	v2, v3 = createAlignOrientationWithAttachment(humanoidRootPart, "skill_look_at", v4)
	DebrisModule:AddItem(v3, 6)
	v:Connect(RunService.Heartbeat, function(_: number)
		mousepos = Platform_Handler.mousepos(500)
		v2.CFrame = Utility.SafeLookAt(
			humanoidRootPart.Position,
			Vector3.new(mousepos.X, humanoidRootPart.Position.Y, mousepos.Z),
			v2.CFrame
		)
	end)
	track = humanoid:FindFirstChild("Animator"):LoadAnimation(script.Anim)
	track:Play()
end

function ResoundingSlashes.UnHold(player)
	if not player then
		return
	end

	local character = player.Character

	if not (character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)) then
		return
	end

	if track then
		track:Stop()
		track = nil
	end

	character.Humanoid.Animator:LoadAnimation(script.Final):Play()
	Utility.AddValue(getvaluesfolder, "NR", 0.35)
	v:Clean()

	if v2 ~= nil then
		v2:Destroy()
		v2 = nil
	end

	if v3 ~= nil then
		v3:Destroy()
		v3 = nil
	end

	local id = ResoundingSlashes.Id
	task.wait(0.35)

	if id ~= ResoundingSlashes.Id then
		return
	end

	if clone ~= nil then
		clone:Destroy()
		clone = nil
	end
end

function ResoundingSlashes.Cancel(player)
	v:Clean()

	if track then
		track:Stop()
		track = nil
	end

	if v2 ~= nil then
		v2:Destroy()
		v2 = nil
	end

	if v3 ~= nil then
		v3:Destroy()
		v3 = nil
	end

	if clone ~= nil then
		clone:Destroy()
		clone = nil
	end

	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart

	if not humanoidRootPart then
		return
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
end

return ResoundingSlashes