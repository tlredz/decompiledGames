local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local localPlayer = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local GravityManager = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("GravityManager"))
local JumpHeightManager = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("JumpHeightManager"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local spaceZoneEnter = remotes:WaitForChild("SpaceZoneEnter")
local spaceZoneLeave = remotes:WaitForChild("SpaceZoneLeave")
local v = false

-- equivalent calls inferred from this helper; original call sites unknown
local function playSound(p)
	if not p then
		return
	end

	local sound = Instance.new("Sound")
	sound.SoundId = p.ID
	sound.Volume = p.Volume
	sound.Parent = workspace
	sound:Play()
	Debris:AddItem(sound, 6)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function spawnRing(humanoidRootPart, p, p2, duration, duration2)
	task.delay(duration2, function()
		if not (humanoidRootPart and humanoidRootPart.Parent) then
			return
		end

		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Size = UDim2.new(p, 0, p, 0)
		billboardGui.StudsOffset = createVector(0, 0, 0)
		billboardGui.AlwaysOnTop = true
		billboardGui.Adornee = humanoidRootPart
		billboardGui.Parent = humanoidRootPart
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Image = "rbxassetid://9509570418"
		imageLabel.BackgroundTransparency = 1
		imageLabel.Size = UDim2.new(1, 0, 1, 0)
		imageLabel.ImageTransparency = 0
		imageLabel.Parent = billboardGui
		local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(billboardGui, tweenInfo, {
			Size = UDim2.new(p2, 0, p2, 0)
		}):Play()
		local tween = TweenService:Create(imageLabel, tweenInfo, {
			ImageTransparency = 1
		})
		tween:Play()
		tween.Completed:Connect(function()
			billboardGui:Destroy()
		end)
	end)
end

local function playTransformEffect(p)
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	playSound(p) -- equivalent call inferred; original call site unknown
	spawnRing(humanoidRootPart, 8, 45, 0.5, 0) -- equivalent call inferred; original call site unknown
	spawnRing(humanoidRootPart, 6, 35, 0.6, 0.12) -- equivalent call inferred; original call site unknown
	spawnRing(humanoidRootPart, 4, 25, 0.7, 0.24) -- equivalent call inferred; original call site unknown
end

local function setSpaceGravity(value: number?)
	local v2 = typeof(value) ~= "number" and 78.48 or value
	v = true
	GravityManager.set("SpaceZone", v2, 20)
	JumpHeightManager.set("SpaceZone", 30, 20)
	playTransformEffect(Config.SOUNDS.EFFECT1)
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.JumpPower = 125
	end
end

local function restoreGravity()
	local v2 = v
	v = false
	GravityManager.release("SpaceZone")
	JumpHeightManager.release("SpaceZone")

	if v2 then
		playTransformEffect(Config.SOUNDS.EFFECT2)
	end

	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.JumpPower = 50
	end
end

spaceZoneEnter.OnClientEvent:Connect(setSpaceGravity)
spaceZoneLeave.OnClientEvent:Connect(restoreGravity)
localPlayer.CharacterAdded:Connect(function()
	v = false
	GravityManager.release("SpaceZone")
	JumpHeightManager.release("SpaceZone")
end)