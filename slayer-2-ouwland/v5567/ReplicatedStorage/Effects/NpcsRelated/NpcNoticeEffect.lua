local currentCamera = workspace.CurrentCamera
local vfxUtility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("vfxUtility"))
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
return function(instance)
	if instance ~= nil then
		local head = instance:FindFirstChild("Head")

		if head == nil or (currentCamera.CFrame.Position - head.Position).Magnitude >= 150 then
			return
		end

		local clone = script.Part:Clone()
		clone.CFrame = head.CFrame * CFrame.new(0, 2.2, 0)
		clone.Parent = workspace.Debree
		clone.Sound:Play()
		vfxUtility.EmitAll(clone)
		DebrisModule:AddItem(clone, 2.25)
	end
end