local clientEffects = game.ReplicatedStorage:WaitForChild("Communication"):WaitForChild("CnC"):WaitForChild("ClientEffects")
local localPlayer = game.Players.LocalPlayer
local child = game.ReplicatedStorage:WaitForChild("Player_Service"):WaitForChild("Values"):WaitForChild(localPlayer.Name)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }

function upd_char(instance)
	if instance ~= nil then
		local humanoid = instance:WaitForChild("Humanoid")
		local position = instance:WaitForChild("HumanoidRootPart").Position
		local v = nil

		while instance ~= nil and instance:IsDescendantOf(workspace) == true and instance:FindFirstChild("HumanoidRootPart") do
			local position2 = instance.HumanoidRootPart.Position
			local v2 = position2 - position
			local state = humanoid:GetState()
			local v3 = v2.Magnitude > 2.25 and child:FindFirstChild("AIRDASHASD123") == nil and child:FindFirstChild("NOMouvementlines") == nil and workspace.Debree:FindFirstChild(localPlayer.Name .. localPlayer.UserId .. "'s gamatundeasd12-12") == nil and state ~= Enum.HumanoidStateType.Dead and state ~= Enum.HumanoidStateType.Physics

			if v3 == true then
				local position3 = instance.HumanoidRootPart.Position
				local v4 = v2.Unit * 6
				local raycastResult = workspace:Raycast(position3, v4, raycastParams)

				if raycastResult ~= nil and raycastResult.Instance ~= nil then
					v3 = false
				end
			end

			if v3 ~= v then
				if v3 == true then
					task.spawn(function()
						clientEffects:Fire("Mouvement_Trail_Thing", instance.HumanoidRootPart, "preset1", "Front", true)
					end)
				else
					task.spawn(function()
						clientEffects:Fire(
							"Mouvement_Trail_Thing",
							instance.HumanoidRootPart,
							"preset1",
							"Front",
							false
						)
					end)
				end

				v = v3
			end

			wait()
			position = position2
		end
	end
end

upd_char(localPlayer.Character)