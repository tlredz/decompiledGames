local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local hat = require(ReplicatedStorage:WaitForChild("FX")):WaitForChild("Creation").Hat
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage2:WaitForChild("Util"))
local v = {
	HitsGround = 4.9,
	PushOff = 5.22,
	PartsLanded = 6.05,
	PartsShake = 8.4,
	PartsFloat = 9.22,
	PartsFloatFinished = 10.42,
	Part3Finished = 12.15,
	Part1Finished = 12.52,
	Part2Finished = 13.2,
	FinalSlam = 13.8
}
local v2 = {
	{
		{ createVector(0.928, 0.1473, 0.8845), CFrame.new(-0.1585, 0.0214, 0.0001, 0, -1, 0, 0, 0, -1, 1, 0, 0) },
		{ createVector(0.928, 0.4043, 0.928), CFrame.new(0.0298, -0.0004, 0.0001, 0, -1, 0, 0, 0, -1, 1, 0, 0) }
	},
	{
		{ createVector(0.464, 0.0485, 0.8743), CFrame.new(-0.2076, -0.0268, -0.2323, 0, 1, 0, 0, 0, -1, -1, 0, 0) },
		{ createVector(0.464, 0.4299, 0.9139), CFrame.new(0.0172, -0.007, -0.2323, 0, 1, 0, 0, 0, -1, -1, 0, 0) },
		{ createVector(0.464, 0.4362, 0.4499), CFrame.new(0.014, 0.225, 0.2317, 0, 1, 0, 0, 0, -1, -1, 0, 0) },
		{ createVector(0.464, 0.0409, 0.4337), CFrame.new(-0.2114, 0.2168, 0.2317, 0, 1, 0, 0, 0, -1, -1, 0, 0) }
	},
	{
		{ createVector(0.928, 0.4205, 0.464), CFrame.new(-0.0218, -0.2323, 0.2321, 0, -1, 0, 0, 0, 1, -1, 0, 0) },
		{ createVector(0.928, 0.0911, 0.4173), CFrame.new(0.1863, -0.2089, 0.2321, 0, -1, 0, 0, 0, 1, -1, 0, 0) },
		{ createVector(0.928, 0.464, 0.464), CFrame.new(-0.0001, 0.2317, -0.2319, 0, -1, 0, 0, 0, 1, -1, 0, 0) }
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v3 = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v3 = math.max(v3, emitter.Lifetime.Max)
			end
		end

		task.wait(v3)
		folder:Destroy()
	end)
end

local function ThrownHatImpact(position, flag: boolean?)
	if typeof(position) == "CFrame" then
		position = position.Position
	end

	local clone

	if flag then
		clone = hat.EndImpact2:Clone()
	else
		clone = hat.EndImpact:Clone()
	end

	Util.ResizeModel(clone, flag and 0.45 or 0.3)
	clone.Position = position
	clone.Parent = workspace._WorldOrigin
	Util.Debris:AddItem(clone, 15)

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v3 = emitter
		task.spawn(function()
			if v3:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v3:GetAttribute("EmitDelay"))
			end

			v3:Emit(v3:GetAttribute("EmitCount"))
		end)
	end

	DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
end

local v3 = {}

local function BindToRenderStepped(fruit, fn)
	if next(v3) == nil then
		local RunService = game:GetService("RunService")
		RunService:BindToRenderStep("CreationPhysicalFruit", Enum.RenderPriority.Last.Value + 1, function()
			for _, callback in pairs(v3) do
				task.spawn(callback)
			end
		end)
	end

	v3[fruit] = fn
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UnbindFromRenderStepped(fruit)
	v3[fruit] = nil

	if not next(v3) then
		pcall(function()
			local RunService = game:GetService("RunService")
			RunService:UnbindFromRenderStep("CreationPhysicalFruit")
		end)
	end
end

return function(p)
	local fruit = p.Fruit

	if fruit:GetAttribute("ClientEffectLoaded") then
		return
	end

	fruit:SetAttribute("ClientEffectLoaded", true)
	local _ = fruit.RootPart
	local v4 = { fruit["Cube outside.002"], fruit["Cube outside.003"], fruit["Cube outside.005"] }
	local v5 = {
		fruit:FindFirstChild("Bone.016", true),
		fruit:FindFirstChild("Bone.009", true),
		fruit:FindFirstChild("Bone.006", true)
	}
	local animator = fruit.AnimationController.Animator
	local _ = fruit.Idle
	local v6 = animator:GetPlayingAnimationTracks()[1]

	while not v6 and task.wait() do
		v6 = animator:GetPlayingAnimationTracks()[1]
	end

	local clones = {}

	for k, v7 in pairs(v4) do
		local objectSpace = v7.CFrame:ToObjectSpace(v5[k].TransformedWorldCFrame)
		local clone = v7:Clone()
		clone:ClearAllChildren()
		clone.Anchored = true
		clone.CanCollide = false
		clone.Transparency = 1
		clone.CanQuery = false
		clone.CanTouch = false
		clone.Name = "FakePart"
		clone.Parent = workspace._WorldOrigin.PersistentParts
		clone:SetAttribute("Offset", objectSpace)
		local connection = clone:GetPropertyChangedSignal("Transparency"):Connect(function()
			for i, part in pairs(clone:GetChildren()) do
				if part:IsA("BasePart") then
					part.Transparency = clone.Transparency
				end
			end
		end)
		clone.Destroying:Once(function()
			connection:Disconnect()
		end)

		for _, v9 in pairs(v2[k]) do
			local part = Instance.new("Part", clone)
			part.Color = Color3.fromRGB(27, 42, 53)
			part.Material = Enum.Material.Neon
			part.Size = v9[1]
			part.Transparency = 1
			local weld = Instance.new("Weld", part)
			weld.Part0 = clone
			weld.Part1 = part
			weld.C0 = v9[2]
		end

		table.insert(clones, clone)
	end

	local parentChangedConnection = fruit.Parent:GetPropertyChangedSignal("Parent"):Connect(function()
		local persistentParts

		if fruit:IsDescendantOf(workspace) then
			persistentParts = workspace._WorldOrigin.PersistentParts
		else
			persistentParts = fruit
		end

		for _, v7 in pairs(clones) do
			local v8 = v7
			pcall(function()
				v8.Parent = persistentParts
			end)
		end
	end)

	local function CreateMirrorParts()
		for k, v7 in pairs(clones) do
			v7.Transparency = 0
			v7.Anchored = false
			v7.CanCollide = true
			v7.CFrame = v4[k].CFrame
			v7.Velocity = CFrame.new(fruit.RootPart.Position, v7.Position).LookVector * createVector(10, 0, 10)
			v4[k].Transparency = 1
		end

		BindToRenderStepped(fruit, function()
			for k, _ in pairs(clones) do
				local v7 = v5[k]

				for _, bone in pairs(v7:GetChildren()) do
					if bone:IsA("Bone") then
						bone.Transform = bone.CFrame:Inverse()
					end
				end

				v7.Transform = v7.CFrame:Inverse()
			end
		end)
	end

	local v7 = nil

	local function KeyframeReached(value: string)
		if value == "HitsGround" then
			CreateMirrorParts()
		elseif value == "PartsShake" then
			for _, v8 in pairs(clones) do
				v8.Anchored = true
				v8.CanCollide = false
				local cFrame = v8.CFrame
				local heartbeatConnection = nil
				local RunService = game:GetService("RunService")
				local v9 = v8
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					if v7 ~= "PartsShake" then
						return heartbeatConnection:Disconnect()
					end

					v9.CFrame = cFrame + Vector3.new(
						(math.random() * 2 - 1) * 0.05,
						(math.random() * 2 - 1) * 0.05,
						(math.random() * 2 - 1) * 0.05
					)
				end)
			end
		elseif value == "PartsFloat" then
			local total = 0

			while total < 3 do
				total += task.wait()

				for k, v8 in pairs(clones) do
					v8.CFrame = v8.CFrame:Lerp(
						v5[k].TransformedWorldCFrame * v8:GetAttribute("Offset"):Inverse(),
						(math.min((total / 3) ^ 2, 1))
					)
				end
			end

			UnbindFromRenderStepped(fruit) -- equivalent call inferred; original call site unknown

			for k, v8 in pairs(clones) do
				v8.Transparency = 1
				v4[k].Transparency = 0
			end
		elseif value:match("Part%dFinished") then
			local v8 = tonumber(value:match("Part(%d)Finished"))
			ThrownHatImpact(v5[v8].TransformedWorldCFrame * clones[v8]:GetAttribute("Offset"):Inverse())
		elseif value == "FinalSlam" then
			for _, part in pairs(fruit:GetChildren()) do
				if not (part.Name:match("Cube outside") and part:IsA("BasePart") and part.Material == Enum.Material.Neon) then
					continue
				end

				local TweenService = game:GetService("TweenService")
				TweenService:Create(
					part,
					TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
					{
						Color = Color3.fromRGB(225, 169, 0)
					}
				):Play()
			end

			ThrownHatImpact(fruit.RootPart.CFrame * CFrame.new(0, 0.25, 0.25), true)
		end
	end

	local v8 = true
	fruit.Parent.Destroying:Connect(function()
		for _, v9 in pairs(clones) do
			local v10 = v9
			pcall(function()
				v10:Destroy()
			end)
		end

		pcall(function()
			parentChangedConnection:Disconnect()
		end)
		v8 = false
		v6:Stop()
		UnbindFromRenderStepped(fruit) -- equivalent call inferred; original call site unknown
	end)
	task.spawn(function()
		local timePosition = v6.TimePosition

		while v8 and v6.IsPlaying and task.wait() do
			for k, v9 in pairs(v) do
				if not (timePosition < v9 and v9 <= v6.TimePosition) then
					continue
				end

				v7 = k
				task.spawn(KeyframeReached, k)
			end

			timePosition = v6.TimePosition

			for _, v9 in pairs(clones) do
				if v9.Position.Y < 0 then
					v9.Anchored = true
				end
			end
		end
	end)
end