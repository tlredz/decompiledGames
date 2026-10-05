local createVector = vector.create
local v = {}
local success, result = pcall(function()
	return require(script.Parent:WaitForChild("Frames", 5))
end)
local v2 = success and result or nil

function v.new(game, model)
	local self = setmetatable({}, {
		__index = v
	})
	self.Model = model
	self.Game = game
	return self
end

function v:Destroy()
	self.Destroyed = true
	self.Model:Destroy()
end

function v:HasClearedFish(p2)
	local part = self.Game.Fish and self.Game.Fish.Part

	if not part then
		return p2.X < self.Game.GAME_CONFIG.SCREEN_WIDTH * -0.55
	end

	local v3 = self.Game.GAME_CONFIG.MIN_SIZE.X * 0.5
	return p2.X + v3 < part.Position.X - part.Size.X * 0.5 - 0.5
end

function v:tick(p)
	if self.Destroyed then
		return
	end

	if self.Anims then
		for _, anim in ipairs(self.Anims) do
			anim:Advance(p)
		end
	end

	local SCREEN_WIDTH = self.Game.GAME_CONFIG.SCREEN_WIDTH
	local v3 = self.Model:GetPivot() + Vector3.new(-p * SCREEN_WIDTH, 0, 0)
	self.Model:PivotTo(v3)

	if self._fadeDecals then
		local v4 = SCREEN_WIDTH * -0.5
		local v5 = SCREEN_WIDTH * -0.78
		local transparency = math.clamp((v3.X - v4) / (v5 - v4), 0, 1)

		for _, _fadeDecal in ipairs(self._fadeDecals) do
			_fadeDecal.Transparency = transparency
		end
	end

	local coin = self.Coin

	if coin and coin.Parent and not self.CoinCollected then
		local fish = self.Game.Fish
		local part = fish and fish.Part

		if part and part.Size.X * 0.5 + coin.Size.Y * 0.5 + 0.6 >= (coin.Position - part.Position).Magnitude then
			self.CoinCollected = true
			coin:Destroy()

			if self.Game.CollectCoin then
				self.Game:CollectCoin()
			end
		end
	end

	if not self.Scored and self:HasClearedFish(v3) then
		self.Scored = true
		self.Game:IncreaseScore(1)

		if self.Coin ~= nil and not self.CoinCollected and self.Game.MissedCoin then
			self.Game:MissedCoin()
		end
	end

	if v3.X < SCREEN_WIDTH * -0.78 then
		self:Destroy()
	end
end

return function(p, p2, instance, p3, p4)
	local GAME_CONFIG = p.GAME_CONFIG
	local MIN_SIZE = GAME_CONFIG.MIN_SIZE
	local SCREEN_HEIGHT = GAME_CONFIG.SCREEN_HEIGHT
	local v3 = p4 or GAME_CONFIG.GAP_HEIGHT
	local v4 = SCREEN_HEIGHT * -0.5
	local v5 = SCREEN_HEIGHT * 0.5
	local v6 = SCREEN_HEIGHT - MIN_SIZE.Y * 2 - v3
	local model = Instance.new("Model")
	model.Name = "ObstacleSet"
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.CFrame = CFrame.new(0, 0, 0)
	part.Parent = model
	model.PrimaryPart = part
	local part2 = Instance.new("Part")
	part2.Anchored = true
	part2.CanCollide = false
	part2.TopSurface = "Smooth"
	part2.BottomSurface = "Smooth"
	part2.Transparency = 1
	part2.Color = Color3.new(0.113725, 0.796078, 0.137255)
	part2.Size = MIN_SIZE + Vector3.new(0, v6 * p2, 0)
	part2.CFrame = CFrame.new(0, v4 + part2.Size.Y * 0.5, 0)
	part2.Parent = model
	local clone = part2:Clone()
	clone.Size = MIN_SIZE + Vector3.new(0, v6 * (1 - p2), 0)
	clone.CFrame = CFrame.new(0, v5 + clone.Size.Y * -0.5, 0)
	clone.Parent = model
	local v7 = v.new(p, model)

	if v2 and v2.Seaweed and #v2.Seaweed > 0 then
		v7.Anims = {}
		local seaweedWidthScale = v2.SeaweedWidthScale or 1
		local seaweedEdgeOvershoot = v2.SeaweedEdgeOvershoot or 6
		local plane = v2.buildPlane(
			Vector3.new(part2.Size.X * seaweedWidthScale, part2.Size.Y + seaweedEdgeOvershoot, 0),
			v2.Seaweed
		)
		plane.CFrame = CFrame.new(part2.CFrame.Position - Vector3.new(0, seaweedEdgeOvershoot * 0.5, 0))
		plane.Parent = part2
		table.insert(v7.Anims, v2.newAnimator(plane, v2.Seaweed, v2.SeaweedFPS))
		local plane2 = v2.buildPlane(
			Vector3.new(clone.Size.X * seaweedWidthScale, clone.Size.Y + seaweedEdgeOvershoot, 0),
			v2.Seaweed
		)
		plane2.CFrame = CFrame.new(clone.CFrame.Position + Vector3.new(0, seaweedEdgeOvershoot * 0.5, 0)) * CFrame.Angles(
			0,
			0,
			3.141592653589793
		)
		plane2.Parent = clone
		table.insert(v7.Anims, v2.newAnimator(plane2, v2.Seaweed, v2.SeaweedFPS))
		v7._fadeDecals = {}

		for _, v8 in ipairs({ plane, plane2 }) do
			for _, decal in ipairs(v8:GetChildren()) do
				if decal:IsA("Decal") then
					table.insert(v7._fadeDecals, decal)
				end
			end
		end
	else
		local clone2 = instance:Clone()
		clone2.Size = part2.Size / createVector(0.5, 1, 5) + createVector(0, 6, 0)
		clone2:PivotTo(part2:GetPivot() * CFrame.new(0, -2, 0))
		clone2.Parent = part2
		clone2:AddTag("BendySeaweed")
		local clone3 = instance:Clone()
		clone3.Size = clone.Size / createVector(0.5, 1, 5) + createVector(0, 6, 0)
		clone3:PivotTo(clone:GetPivot() * CFrame.Angles(3.141592653589793, 0, 0) * CFrame.new(0, -2, 0))
		clone3.Parent = clone
		clone3:AddTag("BendySeaweed")
	end

	if not p3 then
		return v7
	end

	local v8 = v4 + part2.Size.Y + v3 * 0.5
	local v9 = (math.random() < 0.5 and -1 or 1) * (v3 * 0.28)
	local cframe = CFrame.new(0, v8 + v9, 0)

	if v2 and v2.Coin and #v2.Coin > 0 then
		local part3 = Instance.new("Part")
		part3.Name = "BarnabyCoin"
		part3.Anchored = true
		part3.CanCollide = false
		part3.CanQuery = false
		part3.CastShadow = false
		part3.Transparency = 1
		part3.Size = createVector(2, 2, 0.05)
		part3.CFrame = cframe
		part3.Parent = model
		local info = workspace:FindFirstChild("Info")
		local v10 = info and info:GetAttribute("BarnabyCoinRotate") == true
		local v11 = v10 and { v2.Coin[1] } or v2.Coin
		local plane = v2.buildPlane(part3.Size * (v2.CoinScale or 2), v11)
		plane.CFrame = part3.CFrame
		plane.Parent = part3

		if v2.CoinTint then
			for _, decal in ipairs(plane:GetChildren()) do
				if decal:IsA("Decal") then
					decal.Color3 = v2.CoinTint
				end
			end
		end

		v7.Anims = v7.Anims or {}

		if v10 then
			table.insert(v7.Anims, v2.newRocker(plane, part3, v2.CoinRotateAmp, v2.CoinRotateSpeed))
		else
			table.insert(v7.Anims, v2.newAnimator(plane, v2.Coin, v2.CoinFPS))
		end

		v7.Coin = part3
		return v7
	else
		local part3 = Instance.new("Part")
		part3.Name = "BarnabyCoin"
		part3.Shape = Enum.PartType.Cylinder
		part3.Anchored = true
		part3.CanCollide = false
		part3.CanQuery = false
		part3.CastShadow = false
		part3.Material = Enum.Material.Neon
		part3.Color = Color3.fromRGB(255, 211, 64)
		part3.Size = createVector(0.35, 2, 2)
		part3.CFrame = cframe * CFrame.Angles(0, 1.5707963267948966, 0)
		part3.Parent = model
		v7.Coin = part3
	end

	return v7
end