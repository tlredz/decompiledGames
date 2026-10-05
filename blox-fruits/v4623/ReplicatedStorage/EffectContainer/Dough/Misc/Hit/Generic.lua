local createVector = vector.create
local currentCamera = workspace.CurrentCamera
local terrain = workspace.Terrain
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local misc = Util.Misc
local deltaTime = Util.DeltaTime
local FX = require(game.ReplicatedStorage.FX)
local dough = FX:WaitForChild("Dough")
local now = 0
return function(instance)
	local root = instance.Root or instance.Anchor
	local cFrame = instance.CFrame or instance.Position or createVector(0, 0, 0)
	local color = instance.Color
	local scale = instance.Scale or 1
	local duration = instance.Duration or 1
	local identity = CFrame.identity

	if root then
		if typeof(root) == "table" then
			return
		end

		if root:IsA("BasePart") then
			identity = root.CFrame + root.Velocity * deltaTime()
		elseif root:IsA("Attachment") then
			identity = root.WorldCFrame
		end
	end

	if typeof(cFrame) == "Vector3" then
		cFrame = CFrame.new(cFrame) or cFrame
	end

	local cFrame2 = identity * cFrame
	local magnitude = (currentCamera.CFrame.p - cFrame2.p).Magnitude

	if 150 + 15 * scale < magnitude then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.CFrame = cFrame2
	local v2 = 0

	for _, child in pairs(dough.Misc.Hit.Generic.Reference:GetChildren()) do
		local clone = child:Clone()
		misc.ScaleParticle(clone, scale * 0.2)
		clone.Lifetime = NumberRange.new(clone.Lifetime.Min * duration, clone.Lifetime.Max * duration)
		v2 = math.max(clone.Lifetime.Max, v2)

		if color then
			if clone.Name == "Mark" then
				clone.Color = misc.SwapColors(clone, {
					{ Color3.fromRGB(255, 85, 0), color }
				})
			elseif clone.Name == "Hit2" then
				clone.Color = misc.SwapColors(clone, {
					{ Color3.new(1, 0, 0), color }
				})
			end
		end

		clone.Parent = attachment
	end

	attachment.Parent = terrain

	for _, child in pairs(attachment:GetChildren()) do
		local emitCount = child:GetAttribute("EmitCount")

		if emitCount then
			child:Emit(emitCount)
		end
	end

	local random = Random.new()

	if tick() - now > 0.1 then
		Util.Sound:Play("Dough.DoughHit", attachment, nil, 0.9 / (v2 * random:NextNumber(1.5, 3)))
		now = tick()
	end

	Util.Debris:AddItem(attachment, v2 * 3)
end