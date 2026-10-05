local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local frame = nil
local vector = Vector2.new(0, 1200)
local v = {
	Color3.fromRGB(255, 88, 88),
	Color3.fromRGB(255, 196, 0),
	Color3.fromRGB(86, 145, 255),
	Color3.fromRGB(112, 255, 167),
	Color3.fromRGB(200, 112, 255),
	Color3.fromRGB(255, 138, 230)
}
local confettiParticles = {}

local function vectorToUDim2(point: Vector2)
	return UDim2.fromOffset(math.floor(point.X), (math.floor(point.Y)))
end

local function createConfettiParticle(point: Vector2, config)
	local EXACT_SIZE = config.EXACT_SIZE or math.random(config.CONFETTI_MIN_SIZE, config.CONFETTI_MAX_SIZE)
	local textLabel = Instance.new("TextLabel")
	textLabel.Text = ""
	textLabel.Name = "ConfettiParticle"
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	local v2

	if config.EXACT_SIZE then
		v2 = EXACT_SIZE
	else
		v2 = EXACT_SIZE * 0.6
	end

	textLabel.Size = UDim2.fromOffset(EXACT_SIZE, v2)
	textLabel.Position = UDim2.fromOffset(math.floor(point.X), (math.floor(point.Y)))
	textLabel.BackgroundColor3 = config.CONFETTI_COLORS[math.random(1, #config.CONFETTI_COLORS)]
	textLabel.BackgroundTransparency = 0
	textLabel.BorderSizePixel = 0
	textLabel.Parent = frame
	textLabel.ZIndex = 60

	if config.TEXT then
		local integer = Random.new():NextInteger(1, #config.TEXT)
		textLabel.Text = config.TEXT[integer]
		textLabel.BackgroundTransparency = 1
	else
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(0, (math.clamp(EXACT_SIZE * 0.15, 1, 6)))
		uICorner.Parent = textLabel
	end

	local v3 = math.rad((math.random(25, 155)))
	local v4 = math.random(320, 880)
	local v5 = math.random() < 0.5 and -1 or 1
	local v6 = math.cos(v3) * v4 * v5
	local v7 = -math.abs(math.sin(v3) * v4)
	local rotation = math.random(-180, 180)
	local rotationVelocity = math.random(-720, 720)
	return {
		Config = config,
		Instance = textLabel,
		Position = point,
		Velocity = Vector2.new(v6, v7),
		Rotation = rotation,
		RotationVelocity = rotationVelocity,
		Age = 0,
		Lifetime = config.CONFETTI_LIFETIME
	}
end

local function spawnAt(point: Vector2, data)
	local config = {
		CONFETTI_COUNT = not data and 28 or data.CONFETTI_COUNT or 28,
		CONFETTI_MIN_SIZE = not data and 8 or data.CONFETTI_MIN_SIZE or 8,
		CONFETTI_MAX_SIZE = not data and 18 or data.CONFETTI_MAX_SIZE or 18,
		CONFETTI_LIFETIME = not data and 2 or data.CONFETTI_LIFETIME or 2,
		CONFETTI_GRAVITY = data and data.CONFETTI_GRAVITY or vector,
		CONFETTI_AIR_DRAG = not data and 0.98 or data.CONFETTI_AIR_DRAG or 0.98,
		CONFETTI_ROTATION_DRAG = not data and 0.98 or data.CONFETTI_ROTATION_DRAG or 0.98,
		CONFETTI_COLORS = data and data.CONFETTI_COLORS or v,
		SOUND_ENABLED = "GiftOpen",
		TEXT = 0,
		EXACT_SIZE = 0
	}
	local TEXT

	if data then
		TEXT = data.TEXT or nil
	end

	config.TEXT = TEXT
	local v4

	if data then
		v4 = data.EXACT_SIZE or nil
	end

	config.EXACT_SIZE = v4

	if data then
		if data.SOUND_ENABLED == false then
			config.SOUND_ENABLED = nil
		elseif typeof(data.SOUND_ENABLED) == "string" then
			config.SOUND_ENABLED = data.SOUND_ENABLED
		end
	end

	if config.SOUND_ENABLED then
		local Sound = require(game.ReplicatedStorage.Util.Sound)
		Sound:Play(config.SOUND_ENABLED)
	end

	for _ = 1, config.CONFETTI_COUNT do
		local confettiParticle = createConfettiParticle(point, config)
		table.insert(confettiParticles, confettiParticle)
	end
end

local function spawnAtGuiCenter(p, p2)
	local absolutePosition = p.AbsolutePosition
	local absoluteSize = p.AbsoluteSize
	spawnAt(Vector2.new(absolutePosition.X + absoluteSize.X * 0.5, absolutePosition.Y + absoluteSize.Y * 0.5), p2)
end

local v2 = nil
return function()
	local UserInputService = game:GetService("UserInputService")
	local mouseLocation = UserInputService:GetMouseLocation()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local v3 = playerGui:FindFirstChild("PartyPopperGui")

	if not playerGui:FindFirstChild("PartyPopperGui") then
		v3 = Instance.new("ScreenGui")
		v3.IgnoreGuiInset = true
		v3.Name = "PartyPopperGui"
		v3.Enabled = false
		v3.Parent = playerGui
		frame = Instance.new("Frame")
		frame.Name = "ConfettiContainer"
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.fromScale(1, 1)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Parent = v3
		frame.ZIndex = 50
	end

	local now = tick()
	local v4 = tick() + 2
	v2 = v2 or RunService.RenderStepped:Connect(function()
		if #confettiParticles == 0 then
			if not (v4 - tick() < 0) then
				now = tick()
				return
			end

			assert(v2):Disconnect()
			v2 = nil
			v3.Enabled = false
		else
			local now2 = tick()
			local v5 = math.clamp(now2 - now, 0, 0.05)
			now = now2

			for i = #confettiParticles, 1, -1 do
				local v6 = confettiParticles[i]
				v6.Age += v5

				if v6.Age >= v6.Lifetime then
					if v6.Instance and v6.Instance.Parent then
						local tween = TweenService:Create(v6.Instance, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
							TextTransparency = 1,
							BackgroundTransparency = 1
						})
						tween:Play()
						local v7 = v6
						tween.Completed:Connect(function()
							if v7.Instance and v7.Instance.Parent then
								v7.Instance:Destroy()
							end
						end)
					end

					table.remove(confettiParticles, i)
				else
					v6.Velocity += v6.Config.CONFETTI_GRAVITY * v5
					v6.Velocity *= v6.Config.CONFETTI_AIR_DRAG ^ v5
					v6.RotationVelocity *= v6.Config.CONFETTI_ROTATION_DRAG ^ v5
					v6.Position += v6.Velocity * v5
					v6.Rotation += v6.RotationVelocity * v5

					if v6.Instance and v6.Instance.Parent then
						local instance = v6.Instance
						local position = v6.Position
						instance.Position = UDim2.fromOffset(math.floor(position.X), (math.floor(position.Y)))
						v6.Instance.Rotation = v6.Rotation
						local v7 = math.clamp(1 - v6.Age / v6.Lifetime, 0, 1)

						if v6.Config.TEXT then
							v6.Instance.TextTransparency = 1 - v7 * 0.95
						else
							v6.Instance.BackgroundTransparency = 1 - v7 * 0.95
						end
					end
				end
			end
		end
	end)
	v3.DisplayOrder = 100
	v3.Enabled = true
	return {
		spawnAtGuiCenter = spawnAtGuiCenter,
		spawnAtMouse = function(p)
			spawnAt(mouseLocation, p)
		end,
		spawnAt = spawnAt,
		screen = {
			ScreenGui = v3,
			Container = frame
		}
	}
end