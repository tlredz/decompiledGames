local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local random = Random.new()

local function getRandomChild(instance)
	local children = instance:GetChildren()

	if #children == 0 then
		return nil
	end

	return children[math.random(1, #children)]
end

local flags = ReplicatedStorage:FindFirstChild("Flags")
local soundVisualize = flags and flags:FindFirstChild("SoundVisualize")

local function createSoundVisualizer(clone, sound, volume: number)
	if not (soundVisualize and soundVisualize.Value) then
		return
	end

	local radius = math.max(sound.RollOffMaxDistance, 1)
	local sphereHandleAdornment = Instance.new("SphereHandleAdornment")
	sphereHandleAdornment.Name = "SoundRangeVisualizer"
	sphereHandleAdornment.Adornee = clone
	sphereHandleAdornment.AlwaysOnTop = true
	sphereHandleAdornment.Radius = radius
	sphereHandleAdornment.Color3 = Color3.fromRGB(255, 221, 0)
	sphereHandleAdornment.Transparency = 0.65
	sphereHandleAdornment.ZIndex = 5
	sphereHandleAdornment.Parent = clone
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "SoundVolumeBillboard"
	billboardGui.Adornee = clone
	billboardGui.Size = UDim2.fromOffset(180, 44)
	billboardGui.StudsOffset = createVector(0, 0, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = clone
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.BackgroundTransparency = 0.35
	textLabel.BorderSizePixel = 0
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextColor3 = Color3.fromRGB(255, 221, 0)
	textLabel.TextStrokeTransparency = 0
	textLabel.Text = string.format("Vol: %.2f", volume)
	textLabel.Parent = billboardGui
end

return function(data)
	local sound = data.sound

	if not sound:IsA("Sound") then
		local children = sound:GetChildren()

		if #children == 0 then
			sound = nil
		else
			sound = children[math.random(1, #children)]
		end
	end

	if data.playBackSpeed then
		if type(data.playBackSpeed) == "number" then
			sound.PlaybackSpeed = data.playBackSpeed
		else
			sound.PlaybackSpeed = random:NextNumber(unpack(data.playBackSpeed))
		end
	end

	if data.rollOff then
		local rollOffMinDistance, rollOffMaxDistance = unpack(data.rollOff)
		sound.RollOffMinDistance = rollOffMinDistance
		sound.RollOffMaxDistance = rollOffMaxDistance
	end

	if data.worldPos then
		local clone = script.soundPart:Clone()
		sound = sound:Clone()
		sound.Parent = clone
		clone.Position = data.worldPos
		clone.Parent = workspace
		local volume = data.volume or sound.Volume
		createSoundVisualizer(clone, sound, volume)
		Debris:AddItem(clone, sound.TimeLength * 2)
	end

	if data.volume then
		sound.Volume = data.volume
	end

	sound:Play()
end