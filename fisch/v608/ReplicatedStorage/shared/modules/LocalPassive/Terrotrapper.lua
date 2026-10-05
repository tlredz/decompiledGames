local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local module = require("./PassiveHandler")
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local rarities = require(ReplicatedStorage.shared.modules.library.rarities)
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local localPlayer = game.Players.LocalPlayer
local Terrotrapper = {
	GetBobberPosition = function(self)
		local character = localPlayer.Character

		if not character then
			return nil
		end

		local tool = character:FindFirstChildOfClass("Tool")

		if not tool then
			return nil
		end

		local bobber = tool:FindFirstChild("bobber")

		if bobber then
			return bobber.Position
		end

		return nil
	end,
	GetFishFactor = function(self)
		local v = fish[self.current.fish.Name]

		if not v then
			return 0
		end

		local commonRarityThreshold = self.config.CommonRarityThreshold
		local rarity = rarities.Rarities[commonRarityThreshold]
		local rarity2 = rarities.Rarities[v.Rarity]
		local v2

		if rarity and rarity2 then
			local rarityFalloff = self.config.RarityFalloff
			v2 = math.clamp(1 - (rarity2.Order - rarity.Order) / rarityFalloff, 0, 1)
		else
			v2 = 1
		end

		local weightPool = v.WeightPool
		return (v2 + (not weightPool and 1 or math.clamp(
			1 - (weightPool[1] + weightPool[2]) / 2 / self.config.SmallWeightThreshold,
			0,
			1
		))) / 2
	end,
	RollInterval = function(self)
		local minInterval = self.config.MinInterval
		local maxInterval = self.config.MaxInterval
		local fastIntervalScale = self.config.FastIntervalScale
		return self.random:NextNumber(minInterval, maxInterval) * (1 + (fastIntervalScale - 1) * self.factor)
	end,
	Morph = function(self, p, object2)
		self.random = object2:GetRandom(11)
		self.factor = self:GetFishFactor()
		self.attackProgress = self.config.BaseProgress + self.config.MaxProgressBonus * self.factor
		local clone = script.Terroscuttler:Clone()
		task.spawn(ContentProvider.PreloadAsync, ContentProvider, { clone })
		clone.Parent = workspace.active.debrisfx
		self.model = clone
		self.angle = self.random:NextNumber(0, 6.283185307179586)
		self.attackTimer = self:RollInterval()
		self.jumping = false
		self.jumpElapsed = 0
		self.jumpStart = createVector(0, 0, 0)
		self.progressGranted = false
		self.time = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function orbitPoint(bobberPosition: Vector3, p2: number, time: number)
			local v = math.sin(time * 1.7) * 1 + 4
			local v2 = math.sin(time * 1.7 * 1.6 + 1.3) * 0.6 + -0.5
			return bobberPosition + Vector3.new(math.cos(p2) * v, v2, math.sin(p2) * v)
		end

		local function quadBezier(vector2: Vector3, vector3: Vector3, vector4: Vector3, p2: number)
			local v = 1 - p2
			return v * v * vector2 + v * 2 * p2 * vector3 + p2 * p2 * vector4
		end

		local function smoothPivot(model, position: Vector3, vector2: Vector3, p2: number)
			local pivot = model:GetPivot()
			local rotation = pivot.Rotation

			if (vector2 - position).Magnitude > 0.001 then
				rotation = CFrame.lookAt(position, vector2).Rotation
			end

			model:PivotTo(CFrame.new(position) * pivot.Rotation:Lerp(rotation, p2))
		end

		self.reelTrove:Add(RunService.RenderStepped:Connect(function(dt: number)
			if object2.isPaused then
				return
			end

			local bobberPosition = self:GetBobberPosition()

			if not bobberPosition then
				return
			end

			self.time += dt
			local v2 = 1 - math.exp(dt * -8)

			if self.jumping then
				self.jumpElapsed += dt
				local v4 = math.min(self.jumpElapsed / 0.6, 1)
				local v5 = v4 * v4 * (3 - v4 * 2)
				local v6 = orbitPoint(bobberPosition, self.jumpEndAngle, self.time) -- equivalent call inferred; original call site unknown
				local v7 = bobberPosition + createVector(0, 1, 0)
				local jumpStart = self.jumpStart
				local v8 = 1 - v5
				local v9 = v8 * v8 * jumpStart + v8 * 2 * v5 * v7 + v5 * v5 * v6 + Vector3.new(0, v5 * 12 * (1 - v5), 0)

				if not self.progressGranted and v4 >= 0.5 then
					self.progressGranted = true
					object2:AddProgress(self.attackProgress)
					script.chomp:Play()
					local backgroundColor3 = p.progress.bar.BackgroundColor3
					p.progress.bar.BackgroundColor3 = Color3.fromRGB(255, 226, 157)
					GeneralUtils.fastTween(p.progress.bar, TweenInfo.new(1), {
						BackgroundColor3 = backgroundColor3
					})
				end

				local vector2

				if v4 < 0.5 then
					vector2 = Vector3.new(bobberPosition.X, v9.Y, bobberPosition.Z)
				else
					vector2 = orbitPoint(bobberPosition, self.jumpEndAngle + 0.1, self.time)
				end

				smoothPivot(self.model, v9, vector2, v2)

				if v4 >= 1 then
					self.jumping = false
					self.angle = self.jumpEndAngle
					self.attackTimer = self:RollInterval()
				end
			else
				self.angle += dt * 1.5707963267948966
				self.attackTimer -= dt

				if self.attackTimer <= 0 then
					self.jumping = true
					self.jumpElapsed = 0
					self.progressGranted = false
					self.jumpStart = orbitPoint(bobberPosition, self.angle, self.time)
					self.jumpEndAngle = self.angle + 0.9424777960769379
				end

				local v5 = orbitPoint(bobberPosition, self.angle, self.time) -- equivalent call inferred; original call site unknown
				local v7 = orbitPoint(bobberPosition, self.angle + 0.1, self.time) -- equivalent call inferred; original call site unknown
				smoothPivot(self.model, v5, v7, v2)
			end
		end))
		self.reelTrove:Add(object2.OnMinigameEnd:Connect(function()
			for _, part in clone:GetDescendants() do
				if part:IsA("BasePart") then
					GeneralUtils.fastTween(part, TweenInfo.new(1), {
						Transparency = 1
					})
				end
			end

			task.delay(1.5, function()
				clone:Destroy()
			end)
		end))
	end
}
setmetatable(Terrotrapper, module)
return Terrotrapper