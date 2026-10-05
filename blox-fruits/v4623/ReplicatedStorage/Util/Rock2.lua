local createVector = vector.create
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local CustomCollisions = require(game.ReplicatedStorage:WaitForChild("CustomCollisions"))
local rocks = nil
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Tween = require(game.ReplicatedStorage.Util.Tween)
require(game.ReplicatedStorage.Util.Misc)
local RayMap = require(game.ReplicatedStorage.Util.RayMap)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local Signal2 = require(game.ReplicatedStorage.Util.Signal2)
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()
local RunService2 = game:GetService("RunService")
local part

if RunService2:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	part = Instance.new("Part")
	part.TopSurface = 0
	part.BottomSurface = 0
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Size = createVector(1, 1, 1)
	local specialMesh = Instance.new("SpecialMesh", part)
	specialMesh.MeshType = Enum.MeshType.Brick
else
	part = nil
end

local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function Return(part2)
	v[#v + 1] = part2
	part2.Parent = nil
end

local function Grab()
	local v2 = v[#v]

	if not v2 then
		return part:Clone()
	end

	v[#v] = nil
	return v2
end

local class = {}

local function fn() end

if isClient then
	local RunService3 = game:GetService("RunService")

	if RunService3:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
		rocks = CustomCollisions.new("Rocks")
		local flag = false

		fn = function()
			if flag then
				return
			end

			flag = true
			local quad = Tween.ease.out.quad
			local Pool = require(game.ReplicatedStorage:WaitForChild("Pool"))
			class = Pool.new(string.format("%s/%s", script.Parent.Name, script.Name))
			class:setAction(function(object, _)
				local now = tick()
				local parts = {}
				local shifts = {}

				for _, v2 in pairs(object.Pool) do
					local part2 = v2.Object.Part
					local _ = v2.Object.Mesh

					if part2 and part2.Parent then
						if v2.Mode == "Flying" then
							if part2.Parent then
								local velocity = part2.Velocity

								if (velocity.Magnitude >= 100 and velocity.Unit or createVector(0, 0, 0)):Dot(createVector(
									0,
									1,
									0
								)) <= 0.01 then
									rocks:ApplyCollision(part2, nil, true)
									object:remove(v2)
								end
							else
								object:remove(v2)
							end
						else
							local v3 = now - v2.Start

							if part2.Parent and not (v2.Duration < v3) then
								local v4 = v3 / v2.Duration

								if v4 >= 1 or tick() - v2.LastUpdate > v2.UpdateRate - 0.00001 then
									v2.LastUpdate = tick()
									local v5 = quad(v4, 0, 1, 1)
									local shift = v2:Shift((v2.CurrentDirection:Lerp(v2.Direction, v5)))

									if shift then
										table.insert(parts, part2)
										table.insert(shifts, shift)
									end
								end
							else
								object:remove(v2)
							end
						end
					else
						object:remove(v2)
					end
				end

				workspace:BulkMoveTo(parts, shifts)
			end)
		end
	end
end

local Rock2 = {}
Rock2.__index = Rock2

function Rock2.new(options)
	fn()
	local v2 = {
		Type = "Ground",
		Size = createVector(1, 1, 1),
		Scale = 1,
		Lifetime = 0,
		FadeIn = 0.5,
		FadeOut = 0.5,
		RotVelocity = Vector3.new(),
		Velocity = Vector3.new(),
		UpdateRate = 0.016666666666666666,
		LastUpdate = 0
	}

	for k, v3 in pairs(options or {}) do
		v2[k] = v3
	end

	return setmetatable(v2, Rock2):__build()
end

function Rock2:__build()
	local clone = v[#v]

	if clone then
		v[#v] = nil
	else
		clone = part:Clone()
	end

	self.Part = clone
	self.Mesh = self.Part.Mesh
	self.Scale = type(self.Scale) == "table" and Random.new():NextNumber(self.Scale[1], self.Scale[2]) or self.Scale
	self.Lifetime = type(self.Lifetime) == "table" and Random.new():NextNumber(self.Lifetime[1], self.Lifetime[2]) or self.Lifetime
	self.FadeIn = type(self.FadeIn) == "table" and Random.new():NextNumber(self.FadeIn[1], self.FadeIn[2]) or self.FadeIn
	self.FadeOut = type(self.FadeOut) == "table" and Random.new():NextNumber(self.FadeOut[1], self.FadeOut[2]) or self.FadeOut
	self.AngleOffset = self.AngleOffset or CFrame.Angles(
		Random.new():NextNumber(-3.141592653589793, 3.141592653589793),
		Random.new():NextNumber(-3.141592653589793, 3.141592653589793),
		Random.new():NextNumber(-3.141592653589793, 3.141592653589793)
	)
	self.Offset = self.Offset or CFrame.new()
	self.CurrentDirectionOffset = Vector3.new()
	return self
end

function Rock2:SetLifetime(list)
	self.Lifetime = type(list) == "table" and Random.new():NextNumber(list[1], list[2]) or list or self.Lifetime
end

function Rock2:Destroy()
	if self.Destroyed then
		return
	end

	if self.OnDestroy then
		self.OnDestroy(self)
	end

	self.Destroyed = true
	Return(self.Part) -- equivalent call inferred; original call site unknown
end

function Rock2:Spawn(cFrame, burntLevel)
	if self.Destroyed then
		return
	end

	self.CFrame = cFrame
	self.BurntLevel = burntLevel
	Color3.fromRGB(125, 85, 50)
	local _ = Enum.Material.Grass
	local vector2 = Vector3.new()
	local v2, v3, _ = RayMap(
		cFrame.p + cFrame.UpVector,
		-cFrame.UpVector * (self.Size.Y + self.Scale) * 2 - cFrame.UpVector * 2
	)

	if not v2 then
		self:Destroy()
		return
	end

	local color = v2.Color
	local material = v2.Material
	self.Rotation = self.CFrame - self.CFrame.p
	local part2 = self.Part

	if burntLevel then
		color = color:Lerp(Color3.new(), burntLevel) or color
	end

	part2.Color = color
	self.Part.Material = material
	self.Mesh.Scale = vector2
	self.Part.Size = self.Size * self.Scale
	self.Part.Anchored = true
	self.Part.CanCollide = false
	self.Part.CollisionGroupId = 0
	self.Part.CFrame = CFrame.new(v3) * self.Offset * self.Rotation * self.AngleOffset
	rocks:ApplyCollision(self.Part, nil, true)

	if self.Type == "Flying" then
		self.Part.CanCollide = false
	end

	self.Part.Parent = _WorldOrigin
	self.SpawnTime = tick()
	local tweenInfo = TweenInfo.new(self.FadeIn, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(self.Mesh, tweenInfo, {
		Scale = createVector(1, 1, 1)
	})
	local v4 = nil
	tween.Completed:Connect(function()
		if self.Lifetime == 1e999 then
			local maid = Maid.new()
			self.ReleaseEvent = Signal2.new("3DRocks_Release")
			maid:GiveTask(self.ReleaseEvent)
			self.ReleaseEvent:Wait()
			maid:Destroy()
		else
			task.wait(self.Lifetime)
		end

		if self.FadeOutSteps then
			task.spawn(function()
				local size = self.Part.Size

				for i = 0, self.FadeOut, self.FadeOutSteps do
					self.Part.Size = size * (1 - i / self.FadeOut)
					task.wait(self.FadeOutSteps)
				end

				self:Destroy()
			end)
			return
		end

		local tweenInfo2 = TweenInfo.new(self.FadeOut, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		local v5 = {
			Size = createVector(0, 0, 0)
		}

		if self.Type == "Ground" then
			local cFrame2 = self.Part.CFrame
			v5.CFrame = CFrame.new(cFrame2.p) * self.Offset:inverse() * self.Rotation * self.AngleOffset
		end

		v4 = TweenService:Create(self.Part, tweenInfo2, v5)
		v4.Completed:Connect(function()
			self:Destroy()
		end)
		v4:Play()
	end)
	tween:Play()
end

function Rock2:Release(duration)
	coroutine.resume(coroutine.create(function()
		if not self.ReleaseEvent then
			if self.Lifetime ~= 1e999 then
				return warn(string.format("[ROCKS-3D]: Please refrain from calling Release method if lifetime is not infinite"))
			end

			local lastTime = tick()
			local flag = false

			while not self.ReleaseEvent do
				if tick() - lastTime > self.FadeIn * 2 then
					flag = true
					break
				else
					task.wait(0.05)
				end
			end

			if flag then
				self:Destroy()
				return
			end
		end

		if typeof(duration) == "number" and duration > 0 then
			task.wait(duration)
		end

		self.ReleaseEvent:Fire()
	end))
end

function Rock2.ShiftScale(data, p)
	if data.Destroyed then
		return
	end

	if typeof(p) == "Vector3" then
		data.Part.Size = data.Size * data.Scale + p
	else
		data.Part.Size = data.Size * (data.Scale + p)
	end
end

function Rock2.TweenShiftScale(data, p, value)
	if data.Destroyed then
		return
	end

	task.spawn(function()
		local v2 = data.FadeIn - (tick() - data.SpawnTime)

		if v2 > 0 then
			task.wait(v2)
		end

		local tweenInfo = TweenInfo.new(value or 1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		if typeof(p) == "Vector3" then
			TweenService:Create(data.Part, tweenInfo, {
				Size = data.Size * data.Scale + p
			}):Play()
		else
			TweenService:Create(data.Part, tweenInfo, {
				Size = data.Size * (data.Scale + p)
			}):Play()
		end
	end)
end

function Rock2:Shift(currentDirectionOffset)
	if self.Destroyed then
		return
	end

	self.CurrentDirectionOffset = currentDirectionOffset
	local v3, v4, _ = RayMap(
		(self.CFrame + self.CurrentDirectionOffset).p + self.CFrame.UpVector * 0.1,
		-self.CFrame.UpVector * (self.Size.Y + self.Scale)
	)

	if v3 then
		self.Part.Color = self.BurntLevel and v3.Color:Lerp(Color3.new(), self.BurntLevel) or v3.Color
		self.Part.Material = v3.Material
		return CFrame.new(v4) * self.Offset * self.Rotation * self.AngleOffset
	else
		class:remove(self.Directory)
		self.Directory = nil
	end
end

function Rock2:TweenShift(direction, value)
	if self.Destroyed or isServer then
		return
	end

	if class:find(self.Directory) and self.Directory.Object.Type == "Ground" then
		self.Directory.Start = tick()
		self.Directory.Duration = value or 1
		self.Directory.CurrentDirection = self.CurrentDirectionOffset
		self.Directory.Direction = direction
	else
		if class:find(self.Directory) then
			class:remove(self.Directory)
			self.Directory = nil
		end

		self.Directory = {
			Mode = "Shifting",
			Object = self,
			Scale = self.Scale,
			CurrentDirection = self.CurrentDirectionOffset,
			Shift = function(_, p)
				return self:Shift(p)
			end,
			Direction = direction,
			Duration = value or 1,
			Start = tick(),
			UpdateRate = self.UpdateRate,
			LastUpdate = self.LastUpdate
		}
		class:add(self.Directory)
	end
end

function Rock2:Eject(p)
	if self.Type ~= "Flying" or self.Destroyed then
		return
	end

	local velocity = p.Velocity or self.Velocity
	local rotVelocity = p.RotVelocity or self.RotVelocity

	if class:find(self.Directory) then
		class:remove(self.Directory)
		self.Directory = nil
	end

	self.Part.Anchored = false
	self.Part.CanCollide = false
	self.Part.Velocity = velocity
	self.Part.RotVelocity = rotVelocity
	self.Directory = {
		Mode = "Flying",
		Object = self,
		Start = tick()
	}
	class:add(self.Directory)
end

function Rock2:SetOnDestroy(onDestroy)
	if self.OnDestroy or typeof(onDestroy) ~= "function" then
		return
	end

	self.OnDestroy = onDestroy
end

return Rock2