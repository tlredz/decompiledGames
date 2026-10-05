local RunService = game:GetService("RunService")
local Net = require(game.ReplicatedStorage.Modules.Net)
require(game.ReplicatedStorage.Modules.CombatUtil)
local _ = game.Players.LocalPlayer

local function getOtherPlayers(shooter)
	local result = {}

	for _, v in game.Players:GetPlayers() do
		if v ~= shooter then
			table.insert(result, v)
		end
	end

	return result
end

return function(data, data2)
	local Util = require(game.ReplicatedStorage.Util)
	local Effect = require(game.ReplicatedStorage.Effect)
	local shooter = data.Shooter
	local targetPosition = data.TargetPosition
	task.spawn(function()
		if RunService:IsClient() then
			task.wait()
			Net:RemoteEvent("ShootGunEvent"):FireServer(targetPosition)
		end

		local clone = script.ProjectileProxy:Clone()

		if RunService:IsServer() then
			clone.Name = "__UnidentifiedProjectile" .. data.Type .. shooter.Name
		end

		clone.BrickColor = BrickColor.new("Bright red")
		clone.Transparency = 1
		clone.Size = data2.ProjectileSize
		clone.CFrame = CFrame.lookAt(data.origin, targetPosition)
		clone.Anchored = false
		clone.BodyVelocity.Velocity = data.Velocity
		clone.BodyGyro.CFrame = CFrame.lookAt(clone.Position, targetPosition)
		clone:SetAttribute("Exploding", false)
		local mapProxy = clone.MapProxy
		mapProxy.CFrame = clone.CFrame
		local deep = Util.CopyTable.Deep(data)

		local function explode(_)
			if clone:GetAttribute("Exploding") then
				return
			end

			clone:SetAttribute("Exploding", true)
			local position = clone.Position
			local rayMap, explodePos, normal = Util.RayMap(
				position - clone.CFrame.LookVector * 5,
				clone.CFrame.LookVector * 20
			)

			if rayMap then
				deep.Normal = normal
				deep.ExplodePos = explodePos
				position = explodePos
			end

			task.delay(0.5, function()
				clone:Destroy()
			end)
			local Global = require(game.ReplicatedStorage.Global)
			local enemy = Global.enemies[shooter]
			local v3 = not enemy
			local summoner = (v3 and shooter.Character or shooter):FindFirstChild("Summoner")
			local value = summoner and summoner.Value
			local v4, Global2

			if enemy then
				local Global3 = require(game.ReplicatedStorage.Global)
				v4 = Global3.npcPlayers(value)

				if not v4 then
					Global2 = require(game.ReplicatedStorage.Global)
					v4 = Global2.victims(shooter)
				end
			else
				Global2 = require(game.ReplicatedStorage.Global)
				v4 = Global2.victims(shooter)
			end

			for _, v5 in v4 do
				if not (v5:inRange(position, data2.SplashDamageRadius) and v5:damage(data2.Damage, shooter, "Gun")) then
					continue
				end

				local root = v5:getRoot()

				if root then
					Util.BodyMover.new(root.Parent):Create("BodyVelocity", {
						Velocity = (root.Position - position).Unit * 100,
						Duration = 0.25
					})
				end
			end

			if rayMap and v3 then
				local Global3 = require(game.ReplicatedStorage.Global)
				Global3.destroyRadiusWithPlayer(shooter, position, data2.SplashDamageRadius, rayMap.Parent)
			end

			deep.Stage = 2
			deep.origin = position
			Effect.new("Gun_M1.RequestM1"):play(deep)
		end

		local v = {}
		local flag = false

		local function onTouch(otherPart, p)
			if flag then
				return
			end

			flag = true
			local Global = require(game.ReplicatedStorage.Global)
			local enemy = Global.enemies[shooter]

			if otherPart:IsDescendantOf(workspace._WorldOrigin) or otherPart:IsDescendantOf(enemy and shooter or shooter.Character) then
				flag = false
				return
			end

			if p and otherPart:IsDescendantOf(workspace.Map) then
				flag = false
				return
			end

			local flag2 = false

			for ancestor in v do
				if not otherPart:IsDescendantOf(ancestor) then
					continue
				end

				flag2 = true
				flag = false
				break
			end

			if flag2 then
				return
			end

			local Global2 = require(game.ReplicatedStorage.Global)
			local enemy2 = Global2.enemies[shooter]
			local summoner = (not enemy2 and shooter.Character or shooter):FindFirstChild("Summoner")
			local value = summoner and summoner.Value
			local v3, Global3

			if enemy2 then
				local Global4 = require(game.ReplicatedStorage.Global)
				v3 = Global4.npcPlayers(value)

				if not v3 then
					Global3 = require(game.ReplicatedStorage.Global)
					v3 = Global3.victims(shooter)
				end
			else
				Global3 = require(game.ReplicatedStorage.Global)
				v3 = Global3.victims(shooter)
			end

			for _, v5 in v3 do
				if not (v5.callDodge and v5:getRoot() and otherPart:IsDescendantOf(v5:getRoot().Parent) and v5:callDodge()) then
					continue
				end

				v[v5:getRoot().Parent] = true
				flag = false
				flag2 = true
				break
			end

			if flag2 then
				return
			end

			explode(otherPart)
		end

		if RunService:IsServer() then
			clone.Touched:Connect(function(otherPart)
				onTouch(otherPart, true)
			end)
			mapProxy.Touched:Connect(function(otherPart)
				onTouch(otherPart, false)
			end)
		end

		if RunService:IsServer() then
			clone.Parent = workspace._WorldOrigin.PersistentParts
		else
			clone.Parent = workspace._WorldOrigin
		end

		deep.Proxy = clone
		deep.Timestamp = workspace:GetServerTimeNow()

		if RunService:IsClient() then
			Effect.new("Gun_M1.RequestM1"):play(deep)
		else
			Effect.new("Gun_M1.RequestM1"):play(deep, (getOtherPlayers(shooter)))
		end

		if RunService:IsServer() then
			clone:SetAttribute("ServerTimestamp", workspace:GetServerTimeNow())
			task.delay(3, function()
				if clone and clone.Parent then
					explode()
				end
			end)
			clone:SetNetworkOwner()
		else
			task.delay(3, function()
				if clone and clone.Parent then
					clone:Destroy()
				end
			end)
		end
	end)
end