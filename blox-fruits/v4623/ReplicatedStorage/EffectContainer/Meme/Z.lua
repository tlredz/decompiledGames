local memeFakeFruits = script.MemeFakeFruits
local FX = require(game.ReplicatedStorage.FX)
local memeFakeFruits2 = FX:WaitForChild("Meme").Z.MemeFakeFruits
local Effect = require(game.ReplicatedStorage.Effect)
local _WorldOrigin = workspace._WorldOrigin

-- equivalent calls inferred from this helper; original call sites unknown
local function getFruitByName(fruitName)
	if not fruitName then
		return nil
	end

	local v = memeFakeFruits:FindFirstChild(fruitName) or memeFakeFruits2:FindFirstChild(fruitName)

	if v then
		return v:Clone()
	end

	return nil
end

local function playFruitAnimation(model)
	if not model:IsA("Model") then
		return
	end

	local animationController = model:FindFirstChildOfClass("AnimationController", true)

	if not animationController then
		return
	end

	local v = animationController:FindFirstChildOfClass("Animator")

	if not v then
		v = Instance.new("Animator")
		v.Parent = animationController
	end

	local idle = model:FindFirstChild("Idle", true) or model:FindFirstChild("Animation", true) or model:FindFirstChildWhichIsA(
		"Animation",
		true
	)

	if not (idle and idle:IsA("Animation")) then
		return
	end

	local success, result = pcall(function()
		return v:LoadAnimation(idle)
	end)

	if success and result then
		result.Looped = true
		result:Play()
	end
end

return function(p)
	local anchorPart = p.AnchorPart

	if not (anchorPart and anchorPart:IsDescendantOf(workspace)) then
		return
	end

	local fruitName = p.FruitName or anchorPart:GetAttribute("FruitName")
	local fruitByName = getFruitByName(fruitName) -- equivalent call inferred; original call site unknown

	if not fruitByName then
		return
	end

	local rootPart = fruitByName:FindFirstChild("RootPart", true)

	if not (rootPart and rootPart:IsA("BasePart")) then
		return
	end

	fruitByName.Parent = _WorldOrigin

	for _, part in ipairs(fruitByName:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = false
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
	end

	Effect.new("Chests.Despawn"):play({
		CFrame = CFrame.new(anchorPart.Position)
	})
	fruitByName:PivotTo(anchorPart.CFrame)
	local boundingBox, v = fruitByName:GetBoundingBox()
	local v2 = boundingBox.Position.Y - v.Y * 0.5
	local v3 = anchorPart.Position.Y - 0.15 - v2

	if math.abs(v3) > 0.001 then
		fruitByName:PivotTo(fruitByName:GetPivot() + Vector3.new(0, v3, 0))
	end

	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = rootPart
	weldConstraint.Part1 = anchorPart
	weldConstraint.Parent = rootPart
	playFruitAnimation(fruitByName)
	local ancestryChangedConnection = nil
	ancestryChangedConnection = anchorPart.AncestryChanged:Connect(function(_, parent)
		if parent then
			return
		end

		if ancestryChangedConnection then
			ancestryChangedConnection:Disconnect()
		end

		local _ = rootPart.Position
		Effect.new("Meme.Explosion"):play({
			Position = rootPart.Position,
			State = "End"
		})
		fruitByName:Destroy()
	end)
end