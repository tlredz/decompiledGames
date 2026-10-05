local Net = require(game.ReplicatedStorage.Modules.Net)
local CombatUtil = require(game.ReplicatedStorage.Modules.CombatUtil)
local Raycast = require(game.ReplicatedStorage:WaitForChild("Modules").World.Raycast)
local localPlayer = game.Players.LocalPlayer
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
return function(data, p)
	raycastParams.FilterDescendantsInstances = { localPlayer.Character, workspace.Boats, workspace._WorldOrigin }
	local cframe = CFrame.lookAt(data.origin, data.TargetPosition)
	local instances = {}
	local v = {}

	for i = 1, #data.Angles do
		local origin = cframe * data.Angles[i].Angle
		local raycast = Raycast({
			raycastParams = raycastParams,
			origin = origin,
			direction = (origin * CFrame.new(0, 0, -p.Range)).Position - origin.Position
		})
		local instance = raycast and raycast.Instance

		if not instance then
			continue
		end

		local rigOfHitPart = CombatUtil:GetRigOfHitPart(instance)
		local humanoid = rigOfHitPart and rigOfHitPart:FindFirstChild("Humanoid")
		local v5

		if humanoid then
			if humanoid:IsA("NumberValue") and humanoid.Value > 0 then
				v5 = true
			else
				v5 = humanoid:IsA("Humanoid")

				if v5 then
					if humanoid.Health > 0 then
						v5 = humanoid.RootPart ~= nil
					else
						v5 = false
					end
				end
			end
		else
			v5 = humanoid
		end

		if not rigOfHitPart or rigOfHitPart:FindFirstChild("ForceField") or not v5 then
			continue
		end

		table.insert(instances, instance)
		v[rigOfHitPart] = true
	end

	Net:RemoteEvent("ShootGunEvent"):FireServer(data.TargetPosition, instances, data.Seed)

	for k in v do
		CombatUtil:ApplyDamageHighlight(k, localPlayer.Character, p.Name, "Gun")
	end

	local Effect = require(game.ReplicatedStorage.Effect)
	task.spawn(function()
		Effect.new("Gun_M1.RequestM1"):play(data)
	end)
end