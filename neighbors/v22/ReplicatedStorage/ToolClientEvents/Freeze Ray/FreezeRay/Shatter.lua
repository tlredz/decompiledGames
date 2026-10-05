local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Tool = require(ReplicatedStorage.Modules.Tool)
local freezeRay = ReplicatedStorage.Assets.Tools.FreezeRay
return Tool.Event(function(_, instance)
	local iceCube = instance:FindFirstChild("IceCube")

	if not iceCube then
		return
	end

	local clone = freezeRay.IceCubeShattered:Clone()
	clone:PivotTo(iceCube.CFrame)

	if iceCube:FindFirstChild("Break") and instance:FindFirstChild("HumanoidRootPart") then
		iceCube.Break.Parent = instance.HumanoidRootPart
		instance.HumanoidRootPart.Break:Play()
	end

	iceCube:Destroy()
	clone.Parent = workspace

	for _, child in clone:GetChildren() do
		TweenService:Create(child, TweenInfo.new(math.random(85, 380) / 100), {
			Transparency = 1
		}):Play()
	end

	Debris:AddItem(clone, 10)
end)