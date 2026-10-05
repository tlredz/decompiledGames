local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Trove = require(ReplicatedStorage.packages.Trove)
math.randomseed(os.clock())
local random = Random.new()
math.random()
workspace:WaitForChild("VFXDebris")
local rock = script.VFXUtil.rock
local GroundCrater = {}
GroundCrater.__index = GroundCrater

function GroundCrater.new(rayResult: RaycastResult, rayParams)
	local self = setmetatable({}, GroundCrater)
	self.Trove = Trove.new()
	self.RayResult = rayResult
	self.RayParams = rayParams
	self.FadeIn = 0.12
	self.FadeOut = 1.5
	self.Force = 2
	self.Size = 1
	self.Amount = 10
	self.Lifetime = 1
	self.Rad = 2
	self.Waves = 4
	self.BaseSize = createVector(1.4, 0.5, 0.85)
	self.Offset = createVector(0, -0.25, 0)
	self.SizeInverse = 1.2
	self.WaveSeparationConst = 2
	self.TimeBetweenWaves = 0
	self.Collisions = true
	self.Material = false
	self.PartCache = {}
	return self
end

function GroundCrater:Play()
	local position = (CFrame.new(self.RayResult.Position, self.RayResult.Position + self.RayResult.Normal) * CFrame.Angles(
		-1.5707963267948966,
		0,
		0
	) * CFrame.new(0, -self.Force, 0)).Position

	for i = 1, self.Waves do
		self.Rad = self.WaveSeparationConst + self.Rad * random:NextNumber(0.9, 1.2)

		for i2 = 1, self.Amount do
			local v = math.rad(360 / self.Amount) * i2 * random:NextNumber(0.8, 1.2)
			local clone = rock:Clone()
			self.Trove:Add(clone)
			Debris:AddItem(clone, self.Lifetime + self.FadeOut + 1)
			clone.Size = self.BaseSize
			clone.Size *= self.Size * i / self.SizeInverse
			table.insert(self.PartCache, clone)
			local v2 = (CFrame.new(self.RayResult.Position, self.RayResult.Position + self.RayResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				v,
				0
			) * CFrame.new(self.Rad, clone.Size.Y * 3, 0)).Position + self.RayResult.Normal * clone.Size.Y * 3
			local v3 = -self.RayResult.Normal * clone.Size.Y * 7.5
			local raycastResult = workspace:Raycast(v2, v3, self.RayParams)

			if not raycastResult then
				continue
			end

			local material

			if self.Material then
				material = self.Material
			else
				material = raycastResult.Material
			end

			clone.Material = material

			if raycastResult.Instance:IsA("BasePart") then
				local materialVariant = raycastResult.Instance:GetAttribute("MaterialVariant") or raycastResult.Instance.MaterialVariant

				if materialVariant and typeof(materialVariant) == "string" then
					local parent = clone
					local materialVariant2 = materialVariant
					pcall(function()
						parent.MaterialVariant = materialVariant2
					end)
				end
			end

			for _, texture in ipairs(raycastResult.Instance:GetChildren()) do
				if not texture:IsA("Texture") then
					continue
				end

				local clone_2 = texture:Clone()
				clone_2.Parent = clone
			end

			clone.CanCollide = self.Collisions
			clone.Color = raycastResult.Instance.Color
			clone.Parent = workspace.VFXDebris
			clone.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			) * CFrame.new(self.Offset)
			local unit = (position - clone.Position).Unit
			local normal = raycastResult.Normal
			local _ = normal:Cross(unit).Unit
			clone.CFrame = CFrame.lookAt(clone.Position, clone.Position + unit, normal)

			if self.FadeIn > 0 then
				TweenService:Create(clone, TweenInfo.new(self.FadeIn), {
					CFrame = clone.CFrame
				}):Play()
				clone.CFrame *= CFrame.new(0, -clone.Size.Y * 1.2, 0)
			end

			local parent2 = clone
			task.delay(self.Lifetime, function()
				TweenService:Create(parent2, TweenInfo.new(self.FadeOut), {
					CFrame = parent2.CFrame * CFrame.new(0, -parent2.Size.Y * 2, 0),
					Transparency = 1
				}):Play()
			end)
		end

		task.wait(self.TimeBetweenWaves)
	end
end

function GroundCrater:Clean()
	self.Trove:Clean()
	self.PartCache = nil
	setmetatable(self, nil)
end

return GroundCrater