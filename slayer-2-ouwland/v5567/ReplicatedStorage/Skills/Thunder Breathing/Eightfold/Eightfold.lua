local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local CAM = ReplicatedStorage:WaitForChild("CAM")
local client = CAM:WaitForChild("Client")
local global = CAM:WaitForChild("Global")
require(client:WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
require(global:WaitForChild("Utility"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require(ReplicatedStorage2.Packages.cleanit).new()
require(CAM:FindFirstChild("DebrisModule"))
local Eightfold = {
	Id = 0
}
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = { workspace.Map }
raycastParams.FilterType = Enum.RaycastFilterType.Include

function Eightfold.Hold(player)
	if not player then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	local humanoid = character:FindFirstChild("Humanoid")

	if not (humanoidRootPart and humanoid) then
		return
	end

	humanoid:FindFirstChild("Animator")
	local clone = script.Parent.Parent.Parent.holder.skill_stand_still:Clone()
	clone.Parent = humanoidRootPart
	v:Add(clone)
end

function Eightfold.UnHold(_)
	v:Clean()
end

function Eightfold.Cancel()
	v:Clean()
end

return Eightfold