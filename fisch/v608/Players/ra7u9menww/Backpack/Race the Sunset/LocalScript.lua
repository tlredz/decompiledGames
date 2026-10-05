local createVector = vector.create
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
UDim2.new(0, 30, 0, 30)
local _ = {
	JUMP_EFFECT = "http://www.roblox.com/asset/?id=73166882",
	STILL = "http://www.roblox.com/asset/?id=73014404",
	MOVING = "http://www.roblox.com/asset/?id=73014420",
	FALLING = "http://www.roblox.com/asset/?id=73014435",
	WALL_HIT = "http://www.roblox.com/asset/?id=73014892",
	WALL_HIT2 = "http://www.roblox.com/asset/?id=73014915",
	SPARKLE = "http://www.roblox.com/asset/?id=74274038",
	TRED_EFFECT = "http://www.roblox.com/asset/?id=74246393"
}
local v = {
	{
		Image = "http://www.roblox.com/asset/?id=72484181",
		Size = UDim2.new(0, 280, 0, 140)
	},
	{
		Image = "http://www.roblox.com/asset/?id=72484254",
		Size = UDim2.new(0, 280, 0, 140)
	},
	{
		Image = "http://www.roblox.com/asset/?id=72484283",
		Size = UDim2.new(0, 350, 0, 100)
	},
	{
		Image = "http://www.roblox.com/asset/?id=74213080",
		Size = UDim2.new(0, 120, 0, 80)
	}
}
local platformerGui = nil
local v2 = {
	speed = 100,
	bestDist = 0,
	bestLightCollected = 0,
	bestScore = 0,
	dist = 0,
	lightCollected = 0,
	score = 0,
	lastBonusDist = 0,
	chrPosition = createVector(0, 300, 0),
	chrVelocity = createVector(0, 0, 0),
	paused = false,
	equipped = false,
	running = false,
	grounded = false,
	airJumps = 0,
	chrHitWall = false,
	input = {
		w = false,
		a = false,
		s = false,
		d = false,
		space = false,
		wPressed = false
	}
}

while not platformerGui do
	wait()
	platformerGui = script.Parent:FindFirstChild("PlatformerGui")
end

local v3 = {
	pathlp1 = platformerGui.GameFrame.MoveFrame.Map.Land1,
	pathlp2 = platformerGui.GameFrame.MoveFrame.Map.Land1,
	pathlp3 = platformerGui.GameFrame.MoveFrame.Map.Land1
}

local function checkIntersection(p, p2, vector2, vector3)
	local v4 = p * createVector(1, 1, 0)
	local v5 = p2 * createVector(1, 1, 0)
	local v6 = vector2 * createVector(1, 1, 0)
	local v7 = vector3 * createVector(1, 1, 0)
	local v8 = (v4.x - v5.x) * (v6.y - v7.y) - (v4.y - v5.y) * (v6.x - v7.x)

	if v8 == 0 then
		return false
	end

	local v9 = ((v6.x - v7.x) * (v4.x * v5.y - v4.y * v5.x) - (v4.x - v5.x) * (v6.x * v7.y - v6.y * v7.x)) / v8
	local v10 = ((v6.y - v7.y) * (v4.x * v5.y - v4.y * v5.x) - (v4.y - v5.y) * (v6.x * v7.y - v6.y * v7.x)) / v8
	local vector4 = Vector3.new((v4.x + v5.x) / 2, (v4.y + v5.y) / 2, 0)
	local vector5 = Vector3.new((v6.x + v7.x) / 2, (v6.y + v7.y) / 2, 0)
	local vector6 = Vector3.new(v9 - vector4.x, v10 - vector4.y, 0)
	local vector7 = Vector3.new(v9 - vector5.x, v10 - vector5.y, 0)
	return vector6:Dot(vector6) <= (v5 - v4):Dot(v5 - v4) / 4 and vector7:Dot(vector7) <= (v7 - v6):Dot(v7 - v6) / 4
end

local function resizeCharacter(character, p, p2)
	if character.Size ~= UDim2.new(0, p, 0, p2) then
		v2.chrPosition += Vector3.new(character.Size.X.Offset - p, character.Size.Y.Offset - p2, 0)
		character.Size = UDim2.new(0, p, 0, p2)
	end
end

local function createSparkle(p)
	local imageLabel = Instance.new("ImageLabel")
	local vector3Value = Instance.new("Vector3Value")
	vector3Value.Name = "Velocity"
	vector3Value.Value = Vector3.new(math.random(), math.random() * 2 - 1, 0) * 200
	vector3Value.Parent = imageLabel
	imageLabel.Name = "Light"
	imageLabel.Image = "http://www.roblox.com/asset/?id=74274038"
	imageLabel.BackgroundTransparency = 1
	imageLabel.ZIndex = 5
	imageLabel.Size = UDim2.new(0, 15, 0, 15)
	imageLabel.Position = p + UDim2.new(
		0,
		vector3Value.Value.x * 0.03333333333333333,
		0,
		vector3Value.Value.y * 0.03333333333333333
	)
	imageLabel.Parent = platformerGui.GameFrame.MoveFrame.Effects
end

local function startGame()
	local character = platformerGui.GameFrame.MoveFrame.Character
	v2.running = false

	for i = 1, 30 do
		platformerGui.GameFrame.WhiteFrame.BackgroundTransparency = 1 - i / 30
		wait(0.03333333333333333)
	end

	platformerGui.GameFrame.TitlePage.Visible = false
	platformerGui.GameFrame.ScorePage.Visible = false
	resizeCharacter(character, 30, 30)
	v2.chrVelocity = createVector(0, 0, 0)
	v2.chrPosition = createVector(0, 300, 0)
	v2.chrHitWall = false
	platformerGui.GameFrame.BlackFade.Position = UDim2.new(0, -10, 1.5, -10)
	character.Position = UDim2.new(0, v2.chrPosition.x, 0, v2.chrPosition.y)
	platformerGui.GameFrame.MoveFrame.Position = UDim2.new(0.5, -100, 0.5, 0) - (character.Position + character.Size)
	local v4 = 1 - math.clamp((character.Position.Y.Offset + character.Size.Y.Offset * 0.5 + 50) / 1050, 0, 1)
	local v5 = -(character.Position.X.Offset + character.Size.X.Offset * 0.5)
	platformerGui.GameFrame.Mountians1.Position = UDim2.new(0, v5 * 0.15 % 600 - 600, 0.5 * v4, 0)
	platformerGui.GameFrame.Mountians2.Position = UDim2.new(0, v5 * 0.1 % 600 - 600, 0.075 + 0.35 * v4, 0)
	platformerGui.GameFrame.Mountians3.Position = UDim2.new(0, v5 * 0.05 % 600 - 600, 0.15 + 0.2 * v4, 0)
	character.Image = "http://www.roblox.com/asset/?id=73014404"
	platformerGui.GameFrame.Score.Text = "Score: 0"
	v2.speed = 100
	v2.lastBonusDist = 0
	v2.dist = 0
	v2.score = 0
	v2.lightCollected = 0

	for _, child in ipairs(platformerGui.GameFrame.MoveFrame.Map:GetChildren()) do
		if child.Name == "Generated" then
			child:Destroy()
		end
	end

	v3.pathlp1 = platformerGui.GameFrame.MoveFrame.Map.Land1
	v3.pathlp2 = platformerGui.GameFrame.MoveFrame.Map.Land1
	v3.pathlp3 = platformerGui.GameFrame.MoveFrame.Map.Land1

	for i = 1, 60 do
		platformerGui.GameFrame.WhiteFrame.BackgroundTransparency = i / 60
		wait(0.03333333333333333)
	end

	v2.running = true
end

local function resetGame()
	v2.running = false
	local _ = platformerGui.GameFrame.MoveFrame.Character
	platformerGui.GameFrame.BlackFade.Position = UDim2.new(0, -10, 1.5, -10)
	platformerGui.GameFrame.BlackFade.Frame.BackgroundTransparency = 0

	for i = 1, 60 do
		platformerGui.GameFrame.BlackFade.Position = UDim2.new(0, -10, 1.5 - i / 60 * 2, -10)
		wait(0.03333333333333333)
	end

	platformerGui.GameFrame.BlackFade.Position = UDim2.new(0, -10, -1.5, -10)
	v2.dist = math.floor(v2.dist / 4)
	v2.score = math.floor(v2.score)

	if v2.score >= v2.bestScore then
		v2.bestScore = v2.score
		platformerGui.GameFrame.ScorePage.LastScore.TextStrokeTransparency = 0.65
		platformerGui.GameFrame.ScorePage.BestScore.Text = "Best Score: " .. tostring(v2.bestScore)
	else
		platformerGui.GameFrame.ScorePage.LastScore.TextStrokeTransparency = 1
	end

	if v2.dist >= v2.bestDist then
		v2.bestDist = v2.dist
		platformerGui.GameFrame.ScorePage.LastDist.TextStrokeTransparency = 0.65
		platformerGui.GameFrame.ScorePage.BestDist.Text = "Best Distance: " .. tostring(v2.bestDist)
	else
		platformerGui.GameFrame.ScorePage.LastDist.TextStrokeTransparency = 1
	end

	if v2.lightCollected > v2.bestLightCollected then
		v2.bestLightCollected = v2.lightCollected
		platformerGui.GameFrame.ScorePage.LastLight.TextStrokeTransparency = 0.65
		platformerGui.GameFrame.ScorePage.BestLight.Text = "Max orbs collected: " .. tostring(v2.bestLightCollected)
	else
		platformerGui.GameFrame.ScorePage.LastLight.TextStrokeTransparency = 1
	end

	platformerGui.GameFrame.ScorePage.LastScore.Text = "Score: " .. tostring(v2.score)
	platformerGui.GameFrame.ScorePage.LastDist.Text = "Distance: " .. tostring(v2.dist)
	platformerGui.GameFrame.ScorePage.LastLight.Text = "Orbs Collected: " .. tostring(v2.lightCollected)
	platformerGui.GameFrame.ScorePage.Visible = true
	v2.paused = false
	platformerGui.GameFrame.Paused.Visible = false
	platformerGui.GameFrame.BlackFade.Position = UDim2.new(0, -10, 1.5, -10)
	platformerGui.GameFrame.BlackFade.Frame.BackgroundTransparency = 1
end

script.Parent.Equipped:Connect(function(data)
	v2.equipped = true
	platformerGui.Parent = localPlayer.PlayerGui
	platformerGui.Background.Transparency = 0

	if data then
		data.Button1Down:Connect(function()
			v2.paused = not v2.paused
			platformerGui.GameFrame.Paused.Visible = v2.running and v2.paused
		end)
		data.KeyDown:Connect(function(value)
			local v4 = string.byte(value)

			if v4 == 119 or v4 == 17 then
				v2.input.w = true
				v2.input.wPressed = true
			elseif v4 == 97 or v4 == 20 then
				v2.input.a = true
			elseif v4 == 115 or v4 == 18 then
				v2.input.s = true
			elseif v4 == 100 or v4 == 19 then
				v2.input.d = true
			elseif v4 == 32 then
				v2.input.space = true
				v2.paused = not v2.paused
				platformerGui.GameFrame.Paused.Visible = v2.running and v2.paused
			end
		end)
		data.KeyUp:Connect(function(value)
			local v4 = string.byte(value)

			if v4 == 119 or v4 == 17 then
				v2.input.w = false
			elseif v4 == 97 or v4 == 20 then
				v2.input.a = false
			elseif v4 == 115 or v4 == 18 then
				v2.input.s = false
			elseif v4 == 100 or v4 == 19 then
				v2.input.d = false
			elseif v4 == 32 then
				v2.input.space = false
			end
		end)
	end
end)
script.Parent.Unequipped:Connect(function()
	v2.equipped = false
	platformerGui.Parent = script.Parent

	if v2.running then
		v2.paused = true
		platformerGui.GameFrame.Paused.Visible = true
	end
end)
platformerGui.GameFrame.TitlePage.Play.MouseButton1Click:Connect(startGame)
platformerGui.GameFrame.TitlePage.Controls.MouseButton1Click:Connect(function()
	for i = 1, 30 do
		platformerGui.GameFrame.BlackFrame.BackgroundTransparency = 1 - i / 30
		wait(0.03333333333333333)
	end

	platformerGui.GameFrame.TitlePage.Visible = false
	platformerGui.GameFrame.Controls.Visible = true

	for i = 1, 30 do
		platformerGui.GameFrame.BlackFrame.BackgroundTransparency = i / 30
		wait(0.03333333333333333)
	end
end)
platformerGui.GameFrame.Controls.Back.MouseButton1Click:Connect(function()
	for i = 1, 30 do
		platformerGui.GameFrame.BlackFrame.BackgroundTransparency = 1 - i / 30
		wait(0.03333333333333333)
	end

	platformerGui.GameFrame.TitlePage.Visible = true
	platformerGui.GameFrame.Controls.Visible = false

	for i = 1, 30 do
		platformerGui.GameFrame.BlackFrame.BackgroundTransparency = i / 30
		wait(0.03333333333333333)
	end
end)
platformerGui.GameFrame.ScorePage.Okay.MouseButton1Click:Connect(function()
	for i = 1, 30 do
		platformerGui.GameFrame.BlackFrame.BackgroundTransparency = 1 - i / 30
		wait(0.03333333333333333)
	end

	platformerGui.GameFrame.TitlePage.Visible = true
	platformerGui.GameFrame.ScorePage.Visible = false

	for i = 1, 30 do
		platformerGui.GameFrame.BlackFrame.BackgroundTransparency = i / 30
		wait(0.03333333333333333)
	end
end)

while true do
	if v2.equipped and v2.running and not v2.paused then
		local character = platformerGui.GameFrame.MoveFrame.Character
		local v4 = v2.input.w and not v2.grounded and v2.chrVelocity.y >= 80 and 3 or 1

		if v2.input.wPressed then
			v2.input.wPressed = false

			if v2.grounded then
				v2.airJumps = 1
				v4 = 2
			elseif v2.airJumps < 2 then
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.Name = "JumpEffect"
				imageLabel.Image = "http://www.roblox.com/asset/?id=73166882"
				imageLabel.BackgroundTransparency = 1
				imageLabel.ZIndex = character.ZIndex - 1
				imageLabel.Size = UDim2.new(0, 20, 0, 10)
				imageLabel.Position = UDim2.new(
					0,
					v2.chrPosition.x + character.Size.X.Offset / 2 - imageLabel.Size.X.Offset / 2,
					0,
					v2.chrPosition.y + character.Size.Y.Offset - imageLabel.Size.X.Offset / 2
				)
				imageLabel.Parent = platformerGui.GameFrame.MoveFrame.Effects
				v2.airJumps += 1
				v4 = 2
			end
		end

		local v5 = v2.input.s and 4 or v4

		if v5 == 1 then
			v2.chrVelocity += createVector(0, 26.666666, 0)
			resizeCharacter(character, 30, 30)
		elseif v5 == 2 then
			v2.chrVelocity = v2.chrVelocity * createVector(1, 0, 0) + createVector(0, -350, 0)
			resizeCharacter(character, 30, 30)
		elseif v5 == 3 then
			v2.chrVelocity = v2.chrVelocity * createVector(1, 0, 0) + createVector(0, 80, 0)
			resizeCharacter(character, 50, 10)
		elseif v5 == 4 then
			if v2.chrVelocity.y < 1600 and not v2.grounded then
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.Name = "SlamEffect"
				imageLabel.Image = "http://www.roblox.com/asset/?id=73166882"
				imageLabel.BackgroundTransparency = 1
				imageLabel.ZIndex = character.ZIndex - 1
				imageLabel.Size = UDim2.new(0, 16, 0, 10)
				imageLabel.Position = UDim2.new(
					0,
					v2.chrPosition.x + character.Size.X.Offset / 2 - imageLabel.Size.X.Offset / 2,
					0,
					v2.chrPosition.y - imageLabel.Size.X.Offset / 2
				)
				imageLabel.Parent = platformerGui.GameFrame.MoveFrame.Effects
			end

			v2.chrVelocity = v2.chrVelocity * createVector(1, 0, 0) + createVector(0, 1600, 0)
			resizeCharacter(character, 40, 15)
		end

		v2.speed += 0.15
		v2.chrVelocity = v2.chrVelocity * createVector(0, 1, 0) + Vector3.new(v2.speed, 0, 0)
		local _ = v2.chrPosition + Vector3.new(character.Size.X.Offset, 0, 0)
		local v6 = v2.chrPosition + Vector3.new(character.Size.X.Offset, character.Size.Y.Offset, 0)
		local v7 = v2.chrVelocity.y >= 0 and v2.chrPosition + Vector3.new(0, character.Size.Y.Offset, 0) or v2.chrPosition
		local offset = nil
		local v8 = nil

		for _, child in ipairs(platformerGui.GameFrame.MoveFrame.Map:GetChildren()) do
			if child.Name == "Generated" and child.Position.X.Offset + child.Size.X.Offset < character.Position.X.Offset - 200 then
				child:Destroy()
			end

			if not (child and v2.chrVelocity.y >= 0) then
				continue
			end

			local v9 = checkIntersection(
				v6,
				v6 + v2.chrVelocity * 0.03333333333333333,
				Vector3.new(child.Position.X.Offset, child.Position.Y.Offset, 0),
				Vector3.new(child.Position.X.Offset + child.Size.X.Offset, child.Position.Y.Offset, 0)
			)
			local v10 = checkIntersection(
				v7 + createVector(0, -5, 0),
				v7 + v2.chrVelocity * 0.03333333333333333,
				Vector3.new(child.Position.X.Offset, child.Position.Y.Offset, 0),
				Vector3.new(child.Position.X.Offset + child.Size.X.Offset, child.Position.Y.Offset, 0)
			)

			if (v9 or v10) and (not offset or child.Position.Y.Offset < offset) then
				offset = child.Position.Y.Offset
			end
		end

		if v2.chrVelocity.magnitude <= 26.666666666666668 and v2.grounded then
			character.Image = "http://www.roblox.com/asset/?id=73014404"
		elseif math.abs(v2.chrVelocity.x) > math.abs(v2.chrVelocity.y) then
			character.Image = "http://www.roblox.com/asset/?id=73014420"
		else
			character.Image = "http://www.roblox.com/asset/?id=73014435"
		end

		local chrPosition = v2.chrPosition
		v2.chrPosition += v2.chrVelocity * 0.03333333333333333
		v2.dist += (v2.chrVelocity * 0.03333333333333333).x
		v2.grounded = false

		if offset and v2.chrVelocity.y >= 0 then
			v2.grounded = true
			v2.airJumps = 0
			v2.chrPosition = Vector3.new(v2.chrPosition.x, offset - character.Size.Y.Offset - 0.01, 0)
			v2.chrVelocity *= createVector(1, 0, 0)
		end

		if v2.chrPosition.x >= 30000 then
			v2.chrPosition += createVector(-24000, 0, 0)

			for _, child in ipairs(platformerGui.GameFrame.MoveFrame.Map:GetChildren()) do
				if child.Name == "Generated" then
					child.Position += UDim2.new(0, -24000, 0, 0)
				end
			end

			for _, child in ipairs(platformerGui.GameFrame.MoveFrame.Effects:GetChildren()) do
				child.Position += UDim2.new(0, -24000, 0, 0)
			end

			for _, child in ipairs(platformerGui.GameFrame.MoveFrame.Bonus:GetChildren()) do
				child.Position += UDim2.new(0, -24000, 0, 0)
			end
		end

		character.Position = UDim2.new(0, v2.chrPosition.x, 0, v2.chrPosition.y)
		platformerGui.GameFrame.MoveFrame.Position = UDim2.new(0.5, -100, 0.5, 0) - (character.Position + character.Size)
		local v9 = 1 - math.clamp((character.Position.Y.Offset + character.Size.Y.Offset * 0.5 + 50) / 1050, 0, 1)
		local v10 = -(character.Position.X.Offset + character.Size.X.Offset * 0.5)
		platformerGui.GameFrame.Mountians1.Position = UDim2.new(0, v10 * 0.15 % 600 - 600, 0.5 * v9, 0)
		platformerGui.GameFrame.Mountians2.Position = UDim2.new(0, v10 * 0.1 % 600 - 600, 0.075 + 0.35 * v9, 0)
		platformerGui.GameFrame.Mountians3.Position = UDim2.new(0, v10 * 0.05 % 600 - 600, 0.15 + 0.2 * v9, 0)

		for k, v11 in pairs(v3) do
			if not (v11.Position.X.Offset < character.Position.X.Offset + 400) then
				continue
			end

			local v12 = v[math.random(1, #v)]
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Generated"
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = v12.Image
			imageLabel.Size = v12.Size
			imageLabel.ZIndex = 5
			imageLabel.Position = v11.Position + UDim2.new(
				0,
				v2.speed * (math.random() * 1.75) + v11.Size.X.Offset,
				0,
				100 * (math.random() * 2 - 1)
			)

			if imageLabel.Position.Y.Offset > 600 - imageLabel.Size.Y.Offset then
				imageLabel.Position = UDim2.new(0, imageLabel.Position.X.Offset, 0, 600 - imageLabel.Size.Y.Offset)
			elseif imageLabel.Position.Y.Offset < 0 then
				imageLabel.Position = UDim2.new(0, imageLabel.Position.X.Offset, 0, 0)
			end

			imageLabel.Parent = platformerGui.GameFrame.MoveFrame.Map
			v3[k] = imageLabel
		end

		for _, child in ipairs(platformerGui.GameFrame.MoveFrame.Effects:GetChildren()) do
			if child.Name == "JumpEffect" then
				if child.Size.X.Offset >= 76 then
					child:Destroy()
				else
					child.Size += UDim2.new(0, 4, 0, 2)
					child.Position -= UDim2.new(0, 2, 0, 1)
				end
			elseif child.Name == "SlamEffect" then
				if child.Size.X.Offset >= 54 then
					child:Destroy()
				else
					child.Size += UDim2.new(0, 6, 0, 4)
					child.Position -= UDim2.new(0, 3, 0, 2)
				end
			elseif child.Name == "TredEffect" or child.Name == "Light" then
				child.Velocity.Value = child.Velocity.Value + createVector(0, 26.666666, 0)
				child.Position += UDim2.new(
					0,
					child.Velocity.Value.x * 0.03333333333333333,
					0,
					child.Velocity.Value.y * 0.03333333333333333
				)

				if child.Velocity.Value.y > 800 * (child.Name == "TredEffect" and 0.25 or 3) then
					child:Destroy()
				end
			end
		end

		for _, child in ipairs(platformerGui.GameFrame.MoveFrame.Bonus:GetChildren()) do
			child.Position += UDim2.new(0, 0, 0, 1)

			if child.Position.X.Offset < v2.chrPosition.x - 450 then
				child:Destroy()
			else
				local v11 = {
					checkIntersection(
						chrPosition + createVector(30, 0, 0),
						v2.chrPosition + createVector(30, 0, 0),
						Vector3.new(child.Position.X.Offset, child.Position.Y.Offset, 0),
						Vector3.new(
							child.Position.X.Offset + child.Size.X.Offset,
							child.Position.Y.Offset + child.Size.Y.Offset,
							0
						)
					),
					checkIntersection(
						chrPosition + createVector(30, 30, 0),
						v2.chrPosition + createVector(30, 30, 0),
						Vector3.new(child.Position.X.Offset, child.Position.Y.Offset, 0),
						Vector3.new(
							child.Position.X.Offset + child.Size.X.Offset,
							child.Position.Y.Offset + child.Size.Y.Offset,
							0
						)
					),
					checkIntersection(
						chrPosition + createVector(30, 0, 0),
						v2.chrPosition + createVector(30, 0, 0),
						Vector3.new(child.Position.X.Offset + child.Size.X.Offset, child.Position.Y.Offset, 0),
						Vector3.new(child.Position.X.Offset, child.Position.Y.Offset + child.Size.Y.Offset, 0)
					),
					(checkIntersection(
						chrPosition + createVector(30, 30, 0),
						v2.chrPosition + createVector(30, 30, 0),
						Vector3.new(child.Position.X.Offset + child.Size.X.Offset, child.Position.Y.Offset, 0),
						Vector3.new(child.Position.X.Offset, child.Position.Y.Offset + child.Size.Y.Offset, 0)
					))
				}

				if table.find(v11, true) then
					child:Destroy()

					for _ = 1, 4 do
						createSparkle(child.Position + UDim2.new(0, child.Size.X.Offset / 2, 0, child.Size.Y.Offset / 2))
					end

					v2.lightCollected += 1
					v2.score = v2.score * 1.05 + 200
				end
			end
		end

		v2.score = v2.score + math.floor(v2.speed / 100) + 2
		platformerGui.GameFrame.Score.Text = "Score: " .. math.floor(v2.score)

		if v2.dist > v2.lastBonusDist + 1000 then
			v2.lastBonusDist = v2.dist
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Light"
			imageLabel.Image = "http://www.roblox.com/asset/?id=74274038"
			imageLabel.BackgroundTransparency = 1
			imageLabel.ZIndex = character.ZIndex - 1
			imageLabel.Size = UDim2.new(0, 30, 0, 30)
			imageLabel.Position = UDim2.new(0, v2.chrPosition.x + 430, 0, math.random(-50, 500))
			imageLabel.Parent = platformerGui.GameFrame.MoveFrame.Bonus
		end

		if v2.grounded and math.random() < 0.2 then
			local imageLabel = Instance.new("ImageLabel")
			local vector3Value = Instance.new("Vector3Value")
			vector3Value.Name = "Velocity"
			vector3Value.Value = createVector(0, -210, 0)
			vector3Value.Parent = imageLabel
			imageLabel.Name = "TredEffect"
			imageLabel.Image = "http://www.roblox.com/asset/?id=74246393"
			imageLabel.BackgroundTransparency = 1
			imageLabel.ZIndex = character.ZIndex - 1
			imageLabel.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
			imageLabel.Position = UDim2.new(
				0,
				v2.chrPosition.x - imageLabel.Size.X.Offset / 2,
				0,
				v2.chrPosition.y + character.Size.Y.Offset
			)
			imageLabel.Parent = platformerGui.GameFrame.MoveFrame.Effects
		end

		if v2.chrHitWall or v2.chrPosition.y > 1000 then
			if v2.chrHitWall then
				v2.chrPosition = Vector3.new(v8 - character.Size.X.Offset, v2.chrPosition.y, 0)
				character.Image = "http://www.roblox.com/asset/?id=73014892"
				wait(0.15)
				character.Image = "http://www.roblox.com/asset/?id=73014915"
				wait(0.15)
			end

			resetGame()
		end

		local _ = v2.chrPosition
	end

	wait(0.03333333333333333)
end