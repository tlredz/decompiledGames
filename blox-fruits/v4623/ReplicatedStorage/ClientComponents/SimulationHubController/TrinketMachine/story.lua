return function(_)
	local Maid = require(game.ReplicatedStorage.Util.Maid)
	local maid = Maid.new()
	task.spawn(function()
		task.wait()
		local TrinketMachine = require(script.Parent.TrinketMachine)
		TrinketMachine.TrinketMachine:PivotTo(workspace.CurrentCamera.CFrame * CFrame.new(0, -40, -80) * CFrame.Angles(
			0,
			0.17453292519943295,
			0
		))
		maid:GiveTask(TrinketMachine.TrinketMachine)
		TrinketMachine.TrinketMachine.Parent = workspace
		workspace.CurrentCamera.FieldOfView = 90
		warn("Trinket Machine Loaded")
	end)
	return function()
		maid:Destroy()
	end
end