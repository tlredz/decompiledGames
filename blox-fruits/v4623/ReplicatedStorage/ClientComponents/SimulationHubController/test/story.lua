return function(_)
	local Maid = require(game.ReplicatedStorage.Util.Maid)
	local maid = Maid.new()
	task.spawn(function()
		task.wait()
		local folder = Instance.new("Folder", workspace)
		folder.Name = "Test"
		maid:GiveTask(folder)
		local clone = workspace.Map["Simulation Hub"]:Clone()
		maid:GiveTask(clone)
		clone.Parent = folder
		clone:PivotTo(workspace.CurrentCamera.CFrame * CFrame.new(0, -100, 0))
		workspace.CurrentCamera.FieldOfView = 90
		local parentModule = require(script.Parent)
		parentModule:Construct()
		parentModule:Start()
		task.wait(1)
		clone:SetAttribute("LabEnergyOutputModifier", 10)
		task.wait(10)
		clone:SetAttribute("LabEnergyOutputModifier", 1)
		warn("fin")
	end)
	return function()
		maid:Destroy()
	end
end