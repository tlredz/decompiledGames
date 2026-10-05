local Stdfunctions = {}

local function log(p)
	print(p)
end

function Stdfunctions.GetType(instance)
	if typeof(instance) == "Instance" then
		if instance:IsA("Player") then
			return "Player"
		end

		if instance:IsA("GuiBase") then
			return "GUI"
		end

		if instance:IsA("BasePart") then
			return "Part"
		end

		if instance:IsA("Model") then
			return "Model"
		end

		if instance:IsA("ValueBase") then
			return "Value"
		end

		if instance:IsA("BaseScript") then
			return "Script"
		end
	end

	if typeof(instance) ~= "table" then
		return (typeof(instance))
	end

	if getmetatable(instance) == nil then
		return "table"
	end

	return "metatable"
end

function Stdfunctions.Teleport(player, position, p: number)
	local type = Stdfunctions.GetType(player)
	local type2 = Stdfunctions.GetType(position)
	local cFrame = nil
	local primaryPart

	if type == "Player" then
		primaryPart = player.Character.PrimaryPart
	end

	if type == "Model" then
		primaryPart = player.PrimaryPart
	end

	if primaryPart == nil then
		error("Failed!")
		return false
	end

	if type2 == "Model" then
		cFrame = position.PrimaryPart.CFrame
	end

	if type2 == "Part" then
		cFrame = position.CFrame
	end

	if type2 == "Vector3" then
		cFrame = CFrame.new(position)
	end

	if type2 == "CFrame" then
		cFrame = position
	end

	if cFrame == nil then
		error("Failed!")
		return false
	end

	primaryPart.CFrame = CFrame.new(cFrame.X, cFrame.Y + p, cFrame.Z)
	return true
end

function Stdfunctions.Animate(instance, p: number, flag: boolean)
	local humanoid = instance.Humanoid
	local parent = humanoid:FindFirstChild("Animator")

	if not parent then
		parent = Instance.new("Animator")
		parent.Parent = humanoid
	end

	local animationId = "rbxassetid://" .. tostring(p)
	local animation = Instance.new("Animation")
	animation.Parent = parent
	animation.AnimationId = animationId
	local track = parent:LoadAnimation(animation)

	if flag then
		track:Play()
		track.Ended:Wait()
	end

	if not flag or flag == nil then
		track:Play()
	end
end

return Stdfunctions