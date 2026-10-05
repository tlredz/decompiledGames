local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
return function(parent, p, _)
	if parent ~= nil and (parent.Position - workspace.CurrentCamera.CFrame.Position).Magnitude <= 150 and p ~= nil and parent.Parent:FindFirstChild("RightHand") ~= nil and parent.Parent:FindFirstChild("LeftHand") and parent.Parent:FindFirstChild("LeftFoot") ~= nil and parent.Parent:FindFirstChild("RightFoot") then
		local _ = parent.CFrame * CFrame.new(0, 2, 0).Position
		local clone = script.Dash_Sound:Clone()
		clone.Parent = parent
		clone:Play()
		DebrisModule:AddItem(clone, clone.TimeLength)
		local clone2 = script.PartT:Clone()
		clone2.Weld.Part1 = parent.Parent.RightHand
		clone2.Parent = parent.Parent.RightHand
		DebrisModule:AddItem(clone2, 0.8)
		local clone3 = script.PartT:Clone()
		clone3.Weld.Part1 = parent.Parent.LeftHand
		clone3.Parent = parent.Parent.LeftHand
		DebrisModule:AddItem(clone3, 0.8)
		local clone4 = script.PartT:Clone()
		clone4.Weld.Part1 = parent.Parent.RightFoot
		clone4.Parent = parent.Parent.RightFoot
		DebrisModule:AddItem(clone4, 0.8)
		local clone5 = script.PartT:Clone()
		clone5.Weld.Part1 = parent.Parent.LeftFoot
		clone5.Parent = parent.Parent.LeftFoot
		DebrisModule:AddItem(clone5, 0.8)
		task.spawn(function()
			for _ = 1, 2 do
				local cFrame = parent.CFrame
				local clone6 = script.Ring:Clone()
				clone6.CFrame = CFrame.new(cFrame.Position, cFrame.Position + p * 3) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
				clone6.Parent = workspace.Debree
				local v = clone6.Size * 2
				TweenService:Create(clone6, tweenInfo, {
					Size = Vector3.new(v.X, 0, v.Z),
					Transparency = 1
				}):Play()
				DebrisModule:AddItem(clone6, 0.3)
				task.wait(0.08)
			end

			wait(0.18999999999999997)
			clone2.Trail.Enabled = false
			clone3.Trail.Enabled = false
			clone4.Trail.Enabled = false
			clone5.Trail.Enabled = false
		end)
	end
end