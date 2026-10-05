local TreeRootGen = {}
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local v = 8

function range(object, p, p2)
	return p + (p2 - p) * object:NextNumber()
end

function TreeRootGen.RootComplete(instance)
	task.spawn(function()
		task.wait(3)

		if isServer then
			task.wait(8)

			for _, part in pairs(instance:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				part.Transparency = 0

				if part.Name ~= "Tip" then
					part.Color = Color3.fromRGB(185, 150, 148)
				end
			end
		else
			local localPlayer = game.Players.LocalPlayer
			local Client = require(localPlayer.PlayerScripts.Client)

			for _, part in pairs(instance:GetChildren()) do
				if part:IsA("BasePart") and part.Name == "ClientRoot" then
					part:Destroy()
				end
			end

			local v2 = {}

			for _, part in pairs(instance:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				local sortOrder = tonumber((string.sub(part.Name, 11)))

				if sortOrder then
					table.insert(v2, {
						Part = part,
						SortOrder = sortOrder
					})
				end
			end

			table.sort(v2, function(a, b)
				return a.SortOrder > b.SortOrder
			end)

			for _, v3 in pairs(v2) do
				Client.FairyTreeClient.TweenColour(v3.Part, Color3.fromRGB(185, 150, 148), 0.4)
				task.wait(0.1)
			end
		end
	end)
end

function TreeRootGen.GenerateRoot(p, p2, p3, p4, instance)
	if isServer then
		local Server = require(game.ServerScriptService.Server)
		Server.Events.GenerateTreeRoot:FireAllClients(p, p2, p3, p4, instance)
	end

	local random = Random.new(p3)
	local magnitude = (p2 - p).Magnitude
	local v2 = math.floor(magnitude / 8)
	local v3 = v2 < 1 and 1 or v2
	task.spawn(function()
		if isServer then
			task.wait(1)
		else
			local localPlayer = game.Players.LocalPlayer
			local Client = require(localPlayer.PlayerScripts.Client)
			Client.Sound.Play("TreeRoot", {
				Position = (p + p2) / 2
			})
		end

		local v4 = magnitude / v3
		local v5 = {}

		for i = 1, v3 do
			local position = p2

			if i < v3 then
				local _ = (p2 - p).Unit
				position = (CFrame.lookAt(p, p2) * CFrame.new(0, 0, -v4) * CFrame.new(
					range(random, -6, 6),
					range(random, -0.4, 2),
					range(random, -2, 2)
				)).Position
			end

			local v6 = position - p
			local v7 = range(random, 2, 4)
			local part = Instance.new("Part")
			part.Size = Vector3.new(v7, v7, v6.Magnitude + 0.5)
			part.Anchored = true
			local v8 = CFrame.lookAt(p, position) * CFrame.Angles(0, 0, 6.283185307179586 * random:NextNumber())
			local v9 = v6.Magnitude / 2 + 0.25
			part.TopSurface = Enum.SurfaceType.Smooth
			part.BottomSurface = Enum.SurfaceType.Smooth
			part.Color = Color3.fromRGB(220, 207, 207)
			part.Material = Enum.Material.Wood

			if isServer then
				part.Name = "ServerRoot" .. v
			else
				part.Name = "ClientRoot"
			end

			v += 1

			if isServer then
				part.CFrame = v8 * CFrame.new(0, 0, -v9)

				if instance and i == v3 then
					instance:PivotTo(part.CFrame * CFrame.new(0, 0, -part.Size.Z / 2))
				end

				part.Parent = p4 or workspace.Particles
			else
				table.insert(v5, part)
				local v10 = part.Size.Z + 0.01
				local localPlayer = game.Players.LocalPlayer
				local Client = require(localPlayer.PlayerScripts.Client)
				local v11 = v7 + 0.01
				local v12 = part
				local v14 = v8
				local v15 = v9
				Client.TweenModule.new(function(p5)
					local v16 = 0.4 + p5 * 0.6
					v12.Size = Vector3.new(v11 * v16, v11 * v16, v10 * p5)
					v12.CFrame = v14 * CFrame.new(0, 0, -v15 * p5)
					v12.Parent = p4 or workspace.Particles
				end, 0.15):Play()
				task.wait(0.15)
			end

			p = position

			if instance and i == v3 then
				instance:PivotTo(part.CFrame * CFrame.new(0, 0, -part.Size.Z / 2))
			end
		end

		if not isServer then
			task.wait(30)

			for _, v6 in pairs(v5) do
				v6:Destroy()
			end
		end
	end)
	return v3 * 0.15
end

return TreeRootGen