local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
return function(instance, p)
	if instance == nil or p == nil then
		return
	end

	local head = instance:FindFirstChild("Head")

	if head == nil then
		return
	end

	if head:FindFirstChild("Spin_P") ~= nil then
		local spin_P = head.Spin_P
		spin_P.Name = "--"
		DebrisModule:AddItem(spin_P, 2)
		TweenService:Create(spin_P.Sound, tweenInfo, {
			Volume = 0
		}):Play()
		Ouwmit.Enable(spin_P, false)
	end

	if p == true then
		local clone = script.Spin_P:Clone()
		local weld = Instance.new("Weld")
		weld.Part0 = head
		weld.Part1 = clone
		weld.C0 = CFrame.new(0, 0.85, 0)
		weld.Parent = clone
		clone.Parent = head
		Ouwmit.Enable(clone, true, Ouwmit.Owned(instance))
		DebrisModule:AddItem(clone, 10)

		while clone ~= nil and weld ~= nil and head ~= nil and head.Parent == instance and instance:IsDescendantOf(workspace) == true and clone.Parent == head and clone.Name == "Spin_P" do
			local v = task.wait()
			weld.C0 *= CFrame.Angles(0, 3.141592653589793 * v * 3.8, 0)
		end
	end
end