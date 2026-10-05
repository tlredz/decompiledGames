local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.packages.Component)
local Trove = require(ReplicatedStorage.packages.Trove)
local assets = require(ReplicatedStorage.shared.utils.assets)
local cframe = CFrame.Angles(0, 1.5707963267948966, 0)
local v = CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(0, 3.141592653589793, 0)
local v2 = Component.new({
	Tag = "MegamouthRender",
	Ancestors = { workspace }
})

function v2:Construct()
	self.trove = Trove.new()
	self.plankton = {}
	self.shark = nil
	self.currentRotation = nil
	self.loaded = false
	self.lastInRange = 0
end

function v2:loadShark()
	local megamouthShark = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("general"):FindFirstChild("Megamouth Shark")

	if not megamouthShark then
		warn("[MegamouthRender] Shark model \"Megamouth Shark\" not found")
		return
	end

	local clone = megamouthShark:Clone()

	for _, part in ipairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Anchored = true
	end

	clone.Parent = workspace
	local animationController = clone:FindFirstChildOfClass("AnimationController") or self.trove:Add(Instance.new(
		"AnimationController",
		clone
	))
	local animator = animationController:FindFirstChildOfClass("Animator") or self.trove:Add(Instance.new(
		"Animator",
		animationController
	))
	local v3 = self.trove:Add(Instance.new("Animation", clone))
	v3.AnimationId = `rbxassetid://{73754114242677}`
	animator:LoadAnimation(v3):Play()
	self.trove:Add(clone)
	self.shark = clone
end

function v2:loadPlankton()
	local async = assets.getAsync("bait", "Krill")

	if not async then
		warn("[MegamouthRender] Krill model not found")
		return
	end

	for _ = 1, 15 do
		local clone = async:Clone()
		clone:ScaleTo(clone:GetScale() * 3)

		for _, part in ipairs(clone:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Anchored = true
		end

		clone.Parent = workspace
		local vector2 = Vector3.new((math.random() - 0.5) * 12, 0.5, -32 + (math.random() - 0.5) * 12)
		self.trove:Add(clone)
		table.insert(self.plankton, {
			model = clone,
			baseOffset = vector2,
			currentOffset = vector2,
			worldPosition = nil,
			idlePhase = Vector3.new(
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2
			),
			idleSpeed = 2 * (0.7 + math.random() * 0.6),
			yawOffset = (math.random() - 0.5) * 2 * 0.4363323129985824
		})
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scatterOffset(baseOffset: Vector3)
	local v3 = baseOffset.X > 0 and 1 or -1
	return (Vector3.new(baseOffset.X + v3 * 18, baseOffset.Y, baseOffset.Z - 4))
end

function v2:updatePlankton(cframe2: CFrame, p2: number, p3: number)
	local v3 = p2 < -25
	local now = os.clock()
	local v4 = createVector(0, 0, 0)
	local count = 0

	for _, v5 in ipairs(self.plankton) do
		if not v5.model.PrimaryPart then
			continue
		end

		local baseOffset

		if v3 then
			baseOffset = scatterOffset(v5.baseOffset)
		else
			baseOffset = v5.baseOffset
		end

		v5.currentOffset = v5.currentOffset:Lerp(baseOffset, (math.clamp(p3 * 4, 0, 1)))
		local vector2 = Vector3.new(
			math.sin(now * v5.idleSpeed + v5.idlePhase.X) * 0.6,
			math.sin(now * v5.idleSpeed * 0.7 + v5.idlePhase.Y) * 0.6 * 0.5,
			math.sin(now * v5.idleSpeed + v5.idlePhase.Z) * 0.6
		)
		local position = (cframe2 * CFrame.new(v5.currentOffset + vector2)).Position

		if v5.worldPosition then
			v5.worldPosition = v5.worldPosition:Lerp(position, (math.clamp(p3 * 1.5, 0, 1)))
		else
			v5.worldPosition = position
		end

		local worldPosition = v5.worldPosition
		v4 += worldPosition
		count += 1
		v5.model:SetPrimaryPartCFrame(CFrame.lookAt(worldPosition, worldPosition + cframe2.LookVector) * CFrame.Angles(
			0,
			v5.yawOffset,
			0
		) * v)
	end

	return v4, count
end

function v2:updateShark(cframe2: CFrame, p: number, vector2: Vector3, p2: number, p3: number)
	if not (self.shark and self.shark.PrimaryPart) then
		return
	end

	local v3 = cframe2.Position + Vector3.new(0, p, 0)
	local vector3

	if p2 > 0 then
		local v4 = vector2 / p2

		if Vector3.new(v4.X - v3.X, 0, v4.Z - v3.Z).Magnitude < 1 then
			vector3 = v3 + cframe2.LookVector
		else
			vector3 = Vector3.new(v4.X, v3.Y, v4.Z)
		end
	else
		vector3 = v3 + cframe2.LookVector
	end

	local currentRotation = CFrame.lookAt(v3, vector3) - v3

	if self.currentRotation then
		self.currentRotation = self.currentRotation:Lerp(currentRotation, (math.clamp(p3 * 2, 0, 1)))
	else
		self.currentRotation = currentRotation
	end

	self.shark:SetPrimaryPartCFrame(CFrame.new(v3) * self.currentRotation * cframe)
end

function v2:CheckDistance()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	if (self.Instance:GetAttribute("MaxRenderDistance") or 1024) > (currentCamera.CFrame.Position - self.Instance.Position).Magnitude then
		self.lastInRange = tick()

		if not self.loaded then
			self:Load()
		end
	elseif self.loaded and tick() - self.lastInRange >= 3 then
		self:Unload()
	end
end

function v2:Load()
	self.loaded = true
	self:loadShark()
	self:loadPlankton()
	self.trove:Add(RunService.RenderStepped:Connect(function(dt)
		self:Update(dt)
	end))
end

function v2:Unload()
	self.loaded = false
	self.shark = nil
	table.clear(self.plankton)
	self.trove:Clean()
end

function v2:Update(p: number)
	local instance = self.Instance

	if not (instance and instance.Parent) then
		return
	end

	local cFrame = instance.CFrame
	local fishYOffset = instance:GetAttribute("FishYOffset") or 0
	local v3, v4 = self:updatePlankton(cFrame, fishYOffset, p)
	self:updateShark(cFrame, fishYOffset, v3, v4, p)
end

function v2:Start()
	self:CheckDistance()
end

function v2:Stop()
	self:Unload()
end

local now = 0
RunService.Heartbeat:Connect(function()
	if tick() - now < 0.5 then
		return
	end

	now = tick()

	for _, v3 in v2:GetAll() do
		task.spawn(v2.CheckDistance, v3)
	end

	now = tick()
end)
return v2