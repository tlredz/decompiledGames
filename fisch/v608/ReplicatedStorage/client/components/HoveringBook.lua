local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("Players")
game:GetService("CollectionService")
game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages.Component)
require(packages.Trove)
local v = Component.new({
	Tag = "HoveringBook"
})

local function GetCharacter(player)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		return character, humanoidRootPart
	end
end

function v:SteppedUpdate(p: number)
	local instance = self.Instance

	if not (instance and instance.Parent and instance.PrimaryPart) then
		return
	end

	instance:SetPrimaryPartCFrame(instance.PrimaryPart.CFrame:Lerp(
		self.BaseCF * CFrame.new(0, 0, self.RandomAltitudeSeed * math.sin((tick()))),
		p
	))
	self.PassedTime += p

	if self.PassedTime < self.CurrentRandomTimer then
		return
	end

	self.PassedTime = 0
	local child = instance:FindFirstChild(self.CurrentPage)
	child:SetAttribute("BaseCF", child:GetAttribute("BaseCF") or child.CFrame)
	child.HingeConstraint.TargetAngle = child:GetAttribute("Rotated") and 0 or -170
	child:SetAttribute("Rotated", not child:GetAttribute("Rotated"))
	self.CurrentPage = not instance:FindFirstChild(self.CurrentPage + 1) and 1 or self.CurrentPage + 1 or 1
	self.CurrentRandomTimer = Random.new():NextNumber(0.1, 0.5)
end

function v:Start()
	local instance = self.Instance
	self.CurrentPage = 1
	self.PassedTime = 0
	self.CurrentRandomTimer = 0.5

	repeat
		task.wait()
	until instance and instance.Parent and instance.PrimaryPart

	self.BaseCF = instance.PrimaryPart.CFrame
	self.RandomAltitudeSeed = Random.new():NextNumber(0.3, 0.8)
end

function v.Stop(_) end

return v