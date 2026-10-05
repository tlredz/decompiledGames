local createVector = vector.create
local BeeFlowerEffectClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local CollectionService = game:GetService("CollectionService")
local random = Random.new()
local v = {}

function landingTween(value)
	return (math.exp(5 * math.clamp(value, 0, 1)) - 1) / 147.4131591025766
end

function RunBeeAnimation(instance, instance2)
	local clone = game.ReplicatedStorage.Assets.NpcAssets.VisualBee:Clone()
	local visualBeehive = instance:FindFirstChild("VisualBeehive")

	if not visualBeehive then
		return
	end

	local children = {}

	for _, child in pairs(visualBeehive:GetChildren()) do
		if child.Name == "BeeSpawnCF" then
			table.insert(children, child)
		end
	end

	if #children == 0 then
		return
	end

	local v2 = children[random:NextInteger(1, #children)]
	local animator = clone:WaitForChild("AnimationController"):WaitForChild("Animator")
	local pivot = v2:GetPivot()
	local pivot2 = instance2:GetPivot()
	local cframe = pivot - pivot.Position
	local position = pivot.Position
	local position2 = (pivot2 + createVector(0, 2, 0)).Position
	clone:PivotTo(cframe)
	clone.Parent = workspace.Particles
	local track = animator:LoadAnimation(clone.Animations.Walk)
	animator:LoadAnimation(clone.Animations.FlowerSit)
	track:Play()
	local v3 = ((position - position2) * createVector(1, 1, 1)).Magnitude / 4
	local v4 = position
	local v5 = position
	local v6 = v4
	task.spawn(function()
		while true do
			local v7 = task.wait()

			if not clone.Parent then
				break
			end

			local vector2 = Vector3.new(v4.X, v5.Y, v4.Z)

			if (vector2 - v6).Magnitude > 0 then
				local unit = ((vector2 - v6) * createVector(1, 0, 1)).Unit
				local angleBetweenVectors, v8 = Client.Utility.GetAngleBetweenVectors(cframe.LookVector, unit)
				local v9 = 6.981317007977318 * v7

				if angleBetweenVectors < v9 then
					cframe = CFrame.lookAlong(Vector3.new(), unit)
				else
					cframe *= CFrame.Angles(0, v9 * v8, 0)
				end
			end

			clone:PivotTo(cframe + vector2)
			v6 = vector2
		end
	end)
	CFrame.lookAlong(Vector3.new(), (position2 - position).Unit)
	local _ = random:NextNumber() * random:NextInteger(1, 1000)
	Client.TweenModule.new(function(p)
		v4 = position:Lerp(position2, p)
		v5 = position:Lerp(position2, landingTween(p))
	end, v3, "Quad"):Play()
	task.wait(v3)
	track:Stop()
	task.wait(4)
	track:Play()
	Client.TweenModule.new(function(p)
		v4 = position2:Lerp(position, p)
		v5 = position2:Lerp(position, landingTween(p))
	end, v3, "Quad"):Play()
	task.wait(v3)
	clone:Destroy()
end

function BeehiveAdded(instance)
	if not instance:IsDescendantOf(workspace) then
		return
	end

	local position = instance:GetPivot().Position
	local connections = {}
	v[instance] = connections
	local v2 = {}

	for _, v3 in pairs(CollectionService:GetTagged("BeehiveFlower")) do
		if ((v3:GetPivot().Position - position) * createVector(1, 0, 1)).Magnitude <= 20 then
			table.insert(v2, v3)
		end
	end

	table.insert(connections, CollectionService:GetInstanceRemovedSignal("BeehiveFlower"):Connect(function(p)
		local index = table.find(v2, p)

		if index then
			table.remove(v2, index)
		end
	end))
	table.insert(connections, CollectionService:GetInstanceAddedSignal("BeehiveFlower"):Connect(function(instance2)
		if ((instance2:GetPivot().Position - position) * createVector(1, 0, 1)).Magnitude <= 20 then
			table.insert(v2, instance2)
		end
	end))

	while instance.Parent do
		task.wait(5)

		if ((localPlayer.Character and localPlayer.Character:GetPivot().Position or workspace.CurrentCamera.Focus.Position) - position).Magnitude > 150 or #v2 == 0 then
			continue
		end

		if workspace:GetAttribute("State") ~= "Day" then
			continue
		end

		local v4 = v2[random:NextInteger(1, #v2)]
		task.spawn(function()
			RunBeeAnimation(instance, v4)
		end)
	end
end

function BeehiveRemoved(p)
	local v2 = v[p]

	if v2 then
		for _, connection in pairs(v2) do
			connection:Disconnect()
		end
	end

	v[p] = nil
end

function BeeFlowerEffectClient.Init()
	task.spawn(function()
		Client.Utility.ForAllTagged("Beehive", BeehiveAdded, BeehiveRemoved)
		Client.Utility.ForAllTagged("BeeBox", BeehiveAdded, BeehiveRemoved)
	end)
end

return BeeFlowerEffectClient