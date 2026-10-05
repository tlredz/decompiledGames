local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Pool = require(ReplicatedStorage.Pool)
local FX = require(game.ReplicatedStorage.FX)
ReplicatedStorage:WaitForChild("Assets")
local dough = FX:WaitForChild("Dough")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local currentCamera = workspace.CurrentCamera
local _ = Util.Misc
local _ = Util.DistributedLoop
local tween = Util.Tween
local doughExplosionsDripScatter = Effect.new("Dough.Explosions.DripScatter")
local v = {
	{ createVector(0, -1, 0), 0.707 },
	{ createVector(0, 1, 0), 0.247 },
	{ createVector(0, 1, 0), 0.247 },
	{ createVector(0, 1, 0), 0.247 },
	{ createVector(0, 1, 0), 0.247 },
	{ createVector(0, 1, 0), 0.247 }
}

local function scaleRope(folder, scale: Vector2)
	local v2 = scale or Vector2.new(0.3, 1)
	local v3 = v2.Y / 2.164
	folder.Size = Vector3.new(v2.X, 2.164 * v3, v2.X)
	local count = 0

	for _, bone in pairs(folder:GetDescendants()) do
		if not bone:IsA("Bone") then
			continue
		end

		count += 1
		bone.Position = v[count][1] * v[count][2] * v3
	end
end

local v2 = Pool.new(string.format("Dough/%s/%s", script.Parent.Name, script.Name))
v2:setAction(function(object, _)
	local now = tick()

	for _, v3 in pairs(object.Pool) do
		if v3.Destroy then
			local v4 = math.min(1, (now - v3.Destroy) / v3.FadeOut)
			local quint = tween.ease["in"].quint(v4, 1, -1, 1)
			local v5 = v3.Scale.X * quint

			for _, rope in pairs(v3.Ropes) do
				rope.Size = Vector3.new(v5, 2.164 * (v3.Scale.Y / 2.164), v5)
			end

			if v3.Root and v3.Root:IsDescendantOf(workspace) and v3.Indicator and v3.Indicator:IsDescendantOf(workspace) then
				v3.Model:SetPrimaryPartCFrame(v3.GetCFrame())
			end

			if not v3.OnDestroyingdFired then
				v3.OnDestroyingdFired = true
				v3.OnDestroying:Fire()
			end

			if v4 == 1 then
				v3.Model:Destroy()
				object:remove(v3)
			end
		else
			if not v3.OnCreatedFired then
				v3.OnCreatedFired = true
				v3.OnCreated:Fire()
			end

			if v3.Root and v3.Root:IsDescendantOf(workspace) and v3.Indicator and v3.Indicator:IsDescendantOf(workspace) then
				v3.Model:SetPrimaryPartCFrame(v3.GetCFrame())
			elseif now - v3.Start > v3.FadeIn then
				v3.Destroy = now
			end
		end
	end
end)
return function(data)
	local root = data.Root
	local offset = data.Offset or CFrame.new()
	local indicator = data.Indicator
	local scale = data.Scale or Vector2.new(0.25, 2.164)
	local segments = data.Segments or 6
	local fadeIn = data.FadeIn or 0.5
	local fadeOut = data.FadeOut or 0.5

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fn()
		return data.Root:IsA("BasePart") and data.Root.CFrame or data.Root:IsA("Attachment") and data.Root.WorldCFrame
	end

	if ((fn()).p - currentCamera.CFrame.p).Magnitude > 175 + scale.Magnitude * 2 then
		return
	end

	local model = Instance.new("Model")
	model.Name = "RopeContainer"
	local clones = {}

	for i = 1, segments / 2 do
		local v3 = 6.283185307179586 * (i / (segments / 2))

		for i2 = 1, segments / 2 do
			Random.new()
			local v4 = 6.283185307179586 * (i2 / (segments / 2))
			local v5 = math.cos(v3) * math.cos(v4)
			local v6 = math.sin(v4)
			local v7 = math.sin(v3) * math.cos(v4)
			local v8 = math.random(2) == 1 and 1 or -1
			local v9 = v8 * Vector3.new(v5, v6, v7).Unit
			local clone = dough.Models.Tentacles.Rope:Clone()
			scaleRope(clone, scale)
			clone.CFrame = (CFrame.new() * offset):ToWorldSpace(CFrame.new(Vector3.new(), v9)) * CFrame.Angles(
				-v8 * 3.141592653589793 / 2,
				0,
				0
			)
			table.insert(clones, clone)
			clone.Parent = model
		end
	end

	local part = Instance.new("Part")
	part.CastShadow = false
	part.CanQuery = false
	part.CanTouch = false
	part.Anchored = true
	part.CanCollide = false
	part.TopSurface = 0
	part.BottomSurface = 0
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CFrame = CFrame.new()
	part.Parent = model
	model.PrimaryPart = part
	model:SetPrimaryPartCFrame(fn())
	model.Parent = _WorldOrigin
	local v3 = 1 / fadeIn
	local v4 = {}
	local signal = Util.Signal()
	signal.Event:Connect(function()
		for k, v5 in pairs(clones) do
			local v6 = k % 2 == 0 and 1 or 0
			local child = v5.AnimationController:FindFirstChild(string.format("Appear%d", v6))
			local track = v5.AnimationController.Animator:LoadAnimation(child)

			if not track then
				continue
			end

			v4[v5] = track
			track:Play(nil, nil, v3)
			local v7 = track
			task.delay(fadeIn - 0.13333333333333333, function()
				v7:AdjustSpeed(0)
			end)
		end

		signal:Destroy()
	end)
	local v5 = 1 / fadeOut
	local signal2 = Util.Signal()
	signal2.Event:Connect(function()
		for k, v6 in pairs(clones) do
			local v7 = k % 2 == 0 and 1 or 0
			local child = v6.AnimationController:FindFirstChild(string.format("Disappear%d", v7))
			local track = v6.AnimationController.Animator:LoadAnimation(child)

			if v4[v6] then
				v4[v6]:Stop()
				v4[v6] = nil
			end

			if track then
				track:Play(nil, nil, v5)
			end
		end

		doughExplosionsDripScatter:replicate({
			CFrame = fn(),
			Scale = scale.Magnitude / 1.5,
			Spread = Vector2.new(360, 360),
			Drag = 4,
			Distance = 2.5 + scale.Magnitude / 1.25 * 2,
			Rate = segments,
			Gravity = 0.5,
			Time = 0.15,
			Influence = { 0.5, 1.5 }
		})
		signal2:Destroy()
	end)
	v2:add({
		Root = root,
		Start = tick(),
		Indicator = indicator,
		Scale = scale,
		GetCFrame = fn,
		FadeIn = fadeIn,
		FadeOut = fadeOut,
		Model = model,
		Ropes = clones,
		OnCreated = signal,
		OnDestroying = signal2
	})
end