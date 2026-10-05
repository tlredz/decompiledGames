local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local EggActionMovement = require(script.Parent.EggActionMovement)
local Trove = require(ReplicatedStorage.Packages.Trove)
local t = require(ReplicatedStorage.Packages.t)
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
local tweenInfo4 = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo5 = TweenInfo.new(0.12, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
local tweenInfo6 = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo7 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local tweenInfo8 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v = {
	Color3.fromRGB(101, 67, 33),
	Color3.fromRGB(92, 60, 28),
	Color3.fromRGB(110, 75, 40),
	Color3.fromRGB(85, 55, 25)
}
local EggPlaceAnimation = {
	CreateDirtChunk = function(parent, vector2: Vector3, p: number)
		t.strict(t.Instance)(parent)
		t.strict(t.Vector3)(vector2)
		t.strict(t.number)(p)
		local part = Instance.new("Part")
		local v2 = math.random(25, 45) / 100 * p
		part.Size = Vector3.new(v2, v2 * 0.7, v2)
		part.Color = v[math.random(1, #v)]
		part.Material = Enum.Material.SmoothPlastic
		part.Anchored = true
		part.CanCollide = false
		part.CastShadow = false
		part.Transparency = 0
		part.Position = vector2 + createVector(0, 0.05, 0)
		part.Orientation = Vector3.new(math.random(-30, 30), math.random(-180, 180), math.random(-30, 30))
		part.Parent = parent
		local v3 = math.rad((math.random(0, 360)))
		local v4 = math.random(30, 60) / 100 * p
		local v5 = math.cos(v3) * v4
		local v6 = math.sin(v3) * v4
		local position = vector2 + Vector3.new(v5 * 0.6, math.random(50, 90) / 100 * p, v6 * 0.6)
		local position2 = vector2 + Vector3.new(v5, p * 0.02, v6)
		local position3 = position2 + Vector3.new(0, p * -0.01, 0)
		local tween = TweenService:Create(part, tweenInfo4, {
			Position = position,
			Orientation = part.Orientation + Vector3.new(
				math.random(-45, 45),
				math.random(-90, 90),
				math.random(-45, 45)
			)
		})
		tween:Play()
		tween.Completed:Once(function()
			local tween2 = TweenService:Create(part, tweenInfo5, {
				Position = position2,
				Size = Vector3.new(v2 * 1.1, v2 * 0.5, v2 * 1.1)
			})
			tween2:Play()
			tween2.Completed:Once(function()
				local tween3 = TweenService:Create(part, tweenInfo6, {
					Position = position3,
					Size = Vector3.new(v2, v2 * 0.65, v2)
				})
				tween3:Play()
				tween3.Completed:Once(function()
					task.delay(0.15, function()
						TweenService:Create(part, tweenInfo7, {
							Transparency = 1
						}):Play()
						Debris:AddItem(part, tweenInfo7.Time)
					end)
				end)
			end)
		end)
	end,
	PlaySfx = function(parent)
		t.strict(t.Instance)(parent)
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://74146265484496"
		sound.PlaybackSpeed = 1 + math.random(-10, 10) / 100
		sound.Parent = parent
		sound:Play()
		sound.Ended:Once(function()
			sound:Destroy()
		end)
		Debris:AddItem(sound, 5)
	end
}

function EggPlaceAnimation.SpawnDirtChunks(p, vector2: Vector3, p2: number)
	t.strict(t.Instance)(p)
	t.strict(t.Vector3)(vector2)
	t.strict(t.number)(p2)
	local v2 = math.random(6, 10)
	EggPlaceAnimation.CreateDirtChunk(p, vector2, p2)

	for i = 2, v2 do
		task.delay((i - 1) * 0.015, function()
			EggPlaceAnimation.CreateDirtChunk(p, vector2, p2)
		end)
	end
end

function EggPlaceAnimation.CreateDirtDecal(parent, vector2: Vector3, p: number)
	t.strict(t.Instance)(parent)
	t.strict(t.Vector3)(vector2)
	t.strict(t.number)(p)
	local v2 = p * 0.1
	local v3 = p * 0.8
	local v4 = p * 1.6
	local v5 = p * 1.4000000000000001
	local part = Instance.new("Part")
	part.Name = "EggPlaceDirtDecal"
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(v2, v3, v3)
	part.Color = Color3.fromRGB(101, 67, 33)
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CastShadow = false
	part.Transparency = 1
	part.Position = vector2 - createVector(0, 0.01, 0)
	part.Orientation = Vector3.new(0, math.random(-180, 180), 90)
	part.Parent = parent
	TweenService:Create(part, tweenInfo, {
		Size = Vector3.new(v2, v4, v4),
		Transparency = 0
	}):Play()
	task.delay(math.random(7, 11), function()
		TweenService:Create(part, tweenInfo2, {
			Size = Vector3.new(v2, v5, v5),
			Transparency = 1
		}):Play()
		Debris:AddItem(part, tweenInfo2.Time)
	end)
end

function EggPlaceAnimation.CreateImpactRing(parent, vector2: Vector3, p: number)
	t.strict(t.Instance)(parent)
	t.strict(t.Vector3)(vector2)
	t.strict(t.number)(p)
	local part = Instance.new("Part")
	part.Name = "EggPlaceImpactRing"
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(p * 0.05, p * 0.3, p * 0.3)
	part.Color = Color3.fromRGB(139, 90, 43)
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CastShadow = false
	part.Transparency = 0.3
	part.Position = vector2 + createVector(0, 0.02, 0)
	part.Orientation = createVector(0, 0, 90)
	part.Parent = parent
	TweenService:Create(part, tweenInfo8, {
		Size = Vector3.new(p * 0.05, p * 1.8, p * 1.8),
		Transparency = 1
	}):Play()
	Debris:AddItem(part, 0.35)
end

function EggPlaceAnimation:Play(cframe: CFrame, p)
	t.strict(t.instanceIsA("Model"))(self)
	t.strict(t.CFrame)(cframe)
	t.strict(t.Instance)(p)
	local primaryPart = self.PrimaryPart
	t.strict(t.instanceIsA("BasePart"))(primaryPart)
	local v2 = math.max(math.min(primaryPart.Size.X, primaryPart.Size.Y, primaryPart.Size.Z), 0.1)
	local position = cframe.Position
	local v3 = cframe.Position.Y + primaryPart.Size.Y * 0.1
	local flag = false
	local v4 = cframe + Vector3.new(0, primaryPart.Size.Y * 2, 0)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = v4
	EggActionMovement.SetPivot(self, v4)
	local maid = Trove.new()
	maid:Add(cFrameValue)

	local function startImpactEffects()
		if flag then
			return
		end

		flag = true
		EggPlaceAnimation.PlaySfx(p)
		EggPlaceAnimation.SpawnDirtChunks(p, position, v2)
		EggPlaceAnimation.CreateDirtDecal(p, position, v2)
		EggPlaceAnimation.CreateImpactRing(p, position, v2)
	end

	maid:Add(cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
		EggActionMovement.SetPivot(self, cFrameValue.Value)

		if cFrameValue.Value.Position.Y <= v3 then
			startImpactEffects()
		end
	end))
	local tween = TweenService:Create(cFrameValue, tweenInfo3, {
		Value = cframe
	})
	tween:Play()
	tween.Completed:Once(function()
		EggActionMovement.SetPivot(self, cframe)
		startImpactEffects()
		maid:Destroy()
	end)
end

return EggPlaceAnimation