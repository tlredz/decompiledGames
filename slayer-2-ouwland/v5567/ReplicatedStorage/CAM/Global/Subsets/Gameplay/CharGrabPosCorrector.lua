local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)

local function liftAboveFloor(instance, humanoidRootPart, cframe: CFrame, cFrame: CFrame)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoid == nil then
		return cframe
	end

	local v = humanoid.HipHeight + humanoidRootPart.Size.Y / 2
	local v2 = math.max(cframe.Position.Y, cFrame.Position.Y) + v
	local vector2 = vector.create(cframe.Position.X, v2, cframe.Position.Z)
	local raycastResult = workspace:Raycast(
		vector2,
		vector.create(0, -(v2 - cframe.Position.Y + v), 0),
		RaycastHelper.Ground
	)

	if raycastResult == nil then
		return cframe
	end

	local v3 = raycastResult.Position.Y + v

	if v3 <= cframe.Position.Y then
		return cframe
	end

	return cframe + vector.create(0, v3 - cframe.Position.Y, 0)
end

return {
	Do = function(instance, object, p: number?, instance2, flag: boolean?, cframe: CFrame?)
		if instance == nil or object == nil then
			return
		end

		if instance2 == nil then
			warn((`CharGrabPosCorrector.Do: no caster provided for {not instance and "?" or instance.Name or "?"}; rig correction will fall back to the default LowerTorso path`))
		end

		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
		local lowerTorso = instance:FindFirstChild("LowerTorso")

		if humanoidRootPart == nil or lowerTorso == nil then
			return
		end

		local v = (p or object.Length) - 0.1
		local v2 = humanoidRootPart.Position.Y - lowerTorso.Position.Y
		local cFrame = humanoidRootPart.CFrame
		local position = lowerTorso.Position
		local v3

		if instance2 == nil or instance2 == instance then
			v3 = false
		else
			v3 = Utility.IsMeshRig(instance)
		end

		local rootPart, rootPart2

		if v > 0 and Utility.IsMeshRig(instance) then
			rootPart = humanoidRootPart:FindFirstChild("RootPart")
			rootPart2 = lowerTorso:FindFirstChild("RootPart")

			if rootPart then
				rootPart.Enabled = false
			end

			if rootPart2 then
				rootPart2.Enabled = true
			end
		else
			rootPart = nil
			rootPart2 = nil
		end

		local flag2 = false
		local lastTime = nil
		local connections = {}

		local function resolve(isPlaying: boolean)
			if flag2 then
				return
			end

			flag2 = true

			for _, connection in connections do
				connection:Disconnect()
			end

			if isPlaying and instance.Parent ~= nil then
				local humanoidRootPart2 = v3 and instance2:FindFirstChild("HumanoidRootPart")
				local lowerTorso2 = v3 and instance2:FindFirstChild("LowerTorso")
				local v4

				if v3 and humanoidRootPart2 and lowerTorso2 then
					local objectSpace = humanoidRootPart2.CFrame:ToObjectSpace(humanoidRootPart.CFrame)
					v4 = lowerTorso2.CFrame * objectSpace
				else
					local position2 = lowerTorso.Position
					local v5 = position2 - position

					if vector.magnitude(v5) > 0.1 then
						local raycastResult = workspace:Raycast(humanoidRootPart.Position, v5, RaycastHelper.Crater)

						if raycastResult then
							position2 = raycastResult.Position + raycastResult.Normal * 2.5
						end
					end

					v4 = CFrame.new(position2 + vector.create(0, v2, 0)) * cFrame.Rotation
				end

				if cframe ~= nil then
					v4 = CFrame.new(v4.Position) * cframe
				end

				local v5 = liftAboveFloor(instance, humanoidRootPart, v4, cFrame)

				if flag == true then
					for _, weld in ipairs(humanoidRootPart:GetJoints()) do
						if not weld:IsA("Weld") then
							continue
						end

						local part1 = weld.Part0 == humanoidRootPart and weld.Part1 or weld.Part0

						if part1 ~= nil and part1.Anchored and part1.Parent == workspace.Debree then
							weld:Destroy()
						end
					end
				end

				object:Stop(0)
				instance:PivotTo(v5)
			end

			for _, v4 in instance:QueryDescendants("Motor6D") do
				v4.Transform = CFrame.identity
			end

			if rootPart and rootPart.Parent then
				rootPart.Enabled = true
			end

			if rootPart2 and rootPart2.Parent then
				rootPart2.Enabled = false
			end
		end

		local getvaluesfolder = Utility.getvaluesfolder(instance)

		if getvaluesfolder ~= nil then
			table.insert(connections, getvaluesfolder.ChildAdded:Connect(function(child)
				if child.Name ~= "RagDoll" or getvaluesfolder:FindFirstChild("noragdoll") ~= nil then
					return
				end

				local isPlaying = object.IsPlaying

				if not isPlaying then
					if lastTime == nil then
						isPlaying = false
					else
						isPlaying = os.clock() - lastTime <= 0.2
					end
				end

				resolve(isPlaying)
			end))
		end

		table.insert(connections, object.Stopped:Connect(function()
			lastTime = os.clock()
		end))
		table.insert(connections, object.Ended:Connect(function()
			task.delay(0.2, resolve, false)
		end))

		if v > 0 then
			task.delay(v, function()
				if instance == nil or instance.Parent == nil then
					return
				end

				resolve(object.IsPlaying)
			end)
		end
	end
}