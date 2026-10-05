local RunService = game:GetService("RunService")
local Janitor = require(game.ReplicatedStorage.Modules.Janitor)
return {
	Directory = game.ServerStorage.Assets.ToolAssets.Jetpack,
	AnimatedModel = false,
	SetWeldOffset = function(instance, folder)
		instance:WaitForChild("UpperTorso")
		local weld = folder.PrimaryPart:FindFirstChildOfClass("Weld")
		local seat = folder:FindFirstChild("Seat")

		if not weld then
			local weld2 = Instance.new("Weld")
			weld2.Parent = folder.PrimaryPart
			weld2.Part0 = folder.PrimaryPart
			weld2.Part1 = instance:WaitForChild("LowerTorso")
		end

		if seat then
			local maid = Janitor.new()
			local propertyChangedSignal = seat:GetPropertyChangedSignal("Occupant")
			maid:Add(propertyChangedSignal:Connect(function()
				local pivot = folder:GetPivot()

				for _ = 1, 2 do
					folder:PivotTo(pivot)

					for _, part in folder:GetDescendants() do
						if part:IsA("BasePart") and part:CanSetNetworkOwnership() then
							part:SetNetworkOwner(game.Players:GetPlayerFromCharacter(instance))
						end
					end

					RunService.Heartbeat:Wait()
				end
			end))
			local ancestryChanged = seat.AncestryChanged
			maid:Add(ancestryChanged:Connect(function(_, p)
				if not p then
					maid:Destroy()
					maid = nil
				end
			end))
		end
	end
}