local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
localPlayer:WaitForChild("PlayerScripts")
local eggOpenInfo = playerGui:WaitForChild("EggOpenInfo")
local resources = ReplicatedStorage:WaitForChild("resources")
local events = ReplicatedStorage:WaitForChild("events")
local crackParticles = resources:WaitForChild("models"):WaitForChild("CrackParticles")
require(ReplicatedStorage.packages.Net)
local SkinCrates = require(ReplicatedStorage.shared.modules.SkinCrates)
local vessels = require(ReplicatedStorage.shared.modules.vessels)
local bait = require(ReplicatedStorage.shared.modules.library.bait)
local titles = require(ReplicatedStorage.shared.modules.character.titles)
local module = require("../PlayerController")
local eggs = resources:WaitForChild("eggs")
local openEgg = events:WaitForChild("Open Egg")

local function sineOut(p: number)
	return (math.sin(p * 1.5707963267948966))
end

local function renderStepped(p, fn)
	fn(0)
	local total = 0

	while true do
		total += RunService.RenderStepped:Wait() / p

		if total >= 1 then
			break
		end

		fn(total)
	end

	fn(1)
end

local function fitBoundingBoxToCamera(vector2: Vector3, p: number, p2: number)
	local v = math.sqrt(vector2.x ^ 2 + vector2.y ^ 2 + vector2.z ^ 2) / 2
	local v2 = math.rad(p) * 0.5

	if p2 < 1 then
		v2 = math.atan(p2 * math.tan(v2))
	end

	return v / math.sin(v2)
end

local function flipModel(model)
	local pivot = model:GetPivot()
	local lastTime = os.clock()

	while model and model.Parent do
		local v = math.clamp((os.clock() - lastTime) / 0.3, 0, 1)
		model:PivotTo(pivot * CFrame.Angles(0, math.rad(math.sin(v * 1.5707963267948966) * 360), 0))
		RunService.Heartbeat:Wait()

		if v >= 1 then
			break
		end
	end

	model:PivotTo(pivot)
end

local EggsController = {}

function EggsController.DropEgg(_, childName: string, cframe: CFrame, cframe2: CFrame, height: number)
	local child = eggs:FindFirstChild(childName)

	if not child then
		warn((`Egg model "{childName}" not found.`))
		return
	end

	local clone = child:Clone()
	clone.PrimaryPart.Anchored = true
	clone.Parent = workspace
	local v = {
		Model = clone,
		startCFrame = cframe,
		endCFrame = cframe2,
		height = height
	}
	renderStepped(0.75, function(p2)
		v.CFrame = CFrame.new(v.startCFrame:Lerp(v.endCFrame, p2).Position + Vector3.new(
			0,
			math.sin(p2 * 3.141592653589793) * (v.height * 0.75),
			0
		))
		v.Model:PivotTo(v.CFrame * CFrame.fromAxisAngle(createVector(0, 1, 0), (tick() * 2 - 0.25) % 6.283185307179586))
	end)
	return v
end

function EggsController:ShowReward(data)
	local clone = self._template:Clone()
	clone.Frame.Item.Text = data.Item
	clone.Frame.Chance.Text = data.Chance .. "%"

	if data.Category == "Coins" then
		clone.Frame.Item.Text = data.Amount .. " C$"
		clone.Frame.ImageLabel.Image = "rbxassetid://81392339912198"
	elseif data.Category == "Embercoins" then
		clone.Frame.Item.Text = data.Amount .. " E$"
		clone.Frame.ImageLabel.Image = "rbxassetid://94187778368840"
	elseif data.Category == "Title" then
		clone.Frame.ImageLabel.Image = "rbxassetid://139603177427404"
		clone.Frame.Item.TextColor3 = titles[data.Item].TextColor
		clone.Frame.Item.UIStroke.Color = titles[data.Item].StrokeColor
	elseif data.Category == "Cosmetic Case" then
		clone.Frame.ImageLabel.Image = SkinCrates.List[data.Item].Icon
	elseif data.Category == "Bait" then
		clone.Frame.ImageLabel.Image = bait[data.Item].Icon
	else
		local v = vessels.library[data.Item]

		if v and v.Icon then
			clone.Frame.ImageLabel.Image = v.Icon
		end
	end

	clone.Parent = eggOpenInfo
	clone.Size = UDim2.fromScale(0.35, 0.35)
	clone.Frame.Size = UDim2.fromScale(1, 0)
	clone.Frame.Rotation = 15
	TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(0.5, 0.5)
	}):Play()
	TweenService:Create(clone.Frame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(0.75, 0.75),
		Rotation = 0
	}):Play()
	task.wait(1.9)
	clone:Destroy()
end

function EggsController:NewCrack(childName: string, p)
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	local child = eggs:FindFirstChild(childName)

	if not child then
		warn((`Egg model "{childName}" not found.`))
		return
	end

	local clone = child:Clone()
	clone.PrimaryPart.Anchored = true
	clone.Parent = workspace
	module:ToggleControls(false)
	humanoid:UnequipTools()
	clone:PivotTo((humanoidRootPart.CFrame + createVector(0, -3, 0)) * CFrame.Angles(0, 3.141592653589793, 0))
	local track = clone:WaitForChild("AnimationController"):LoadAnimation(script.EggAnimation)
	track.Looped = false
	track.Priority = Enum.AnimationPriority.Action
	track:Play()
	local track2 = humanoid:LoadAnimation(script.PlayerAnimation)
	track2.Looped = false
	track2.Priority = Enum.AnimationPriority.Action
	track2:Play()
	task.delay(1.5, function()
		local child2 = script.Sounds:FindFirstChild("Egg Crack 0" .. math.random(1, 5))

		if child2 then
			local clone2 = child2:Clone()
			clone2.Parent = clone.PrimaryPart
			clone2:Play()
			task.defer(function()
				clone2.Stopped:Wait()
				clone2:Destroy()
			end)
		end

		local common

		if p.Category == "Coins" or p.Category == "Bait" or p.Category == "Title" then
			common = crackParticles:WaitForChild("Common")
		elseif p.Category == "Cosmetic Case" then
			common = crackParticles:WaitForChild("Epic")
		else
			common = crackParticles:WaitForChild("Rainbow")
		end

		for _, attachment in ipairs(common:GetChildren()) do
			if not attachment:IsA("Attachment") then
				continue
			end

			local clone2 = attachment:Clone()
			clone2.Parent = clone.PrimaryPart

			for _, child3 in ipairs(clone2:GetChildren()) do
				child3:Emit(child3:GetAttribute("EmitCount") or 1)
			end
		end

		task.wait(1.5)
		track:AdjustSpeed(0)

		for _, part in ipairs(clone:GetDescendants()) do
			if part:IsA("BasePart") then
				TweenService:Create(part, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Transparency = 1
				}):Play()
			end
		end
	end)
	task.wait(3)
	module:ToggleControls(true)
end

function EggsController.CrackEgg(_, data)
	local position = data.startCFrame.Position
	local position2 = data.endCFrame.Position
	data.Model:PivotTo(CFrame.new(position2, (Vector3.new(position.X, position2.Y, position.Z))))
	local cFrame = data.Model.PrimaryPart.CFrame
	local v = 0.25
	local v2 = 0
	local v3 = 30

	repeat
		task.wait(v)
		local v4 = v2 + 1
		v2 = v4 == 3 and 1 or v4
		local cFrame2 = cFrame * CFrame.Angles(0, 0, (math.rad(v3 * (v2 == 1 and 1 or -1))))
		TweenService:Create(data.Model.PrimaryPart, TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			CFrame = cFrame2
		}):Play()
		v /= 1.15
		v3 /= 1.025
	until v <= 0.015

	data.Model.PrimaryPart.CFrame = cFrame
	task.defer(function()
		flipModel(data.Model)
	end)
	local child = script.Sounds:FindFirstChild("Egg Crack 0" .. math.random(1, 5))

	if child then
		local clone = child:Clone()
		clone.Parent = data.Model.PrimaryPart
		clone:Play()
		task.defer(function()
			clone.Stopped:Wait()
			clone:Destroy()
		end)
	end

	local common

	if data.Category == "Coins" or data.Category == "Bait" or data.Category == "Title" then
		common = crackParticles:WaitForChild("Common")
	elseif data.Category == "Cosmetic Case" then
		common = crackParticles:WaitForChild("Epic")
	else
		common = crackParticles:WaitForChild("Rainbow")
	end

	for _, child2 in ipairs(common:GetChildren()) do
		for _, child3 in ipairs(child2:GetChildren()) do
			local clone = child3:Clone()
			clone.Parent = data.Model.PrimaryPart
			clone:Emit(clone:GetAttribute("EmitCount") or 1)
		end
	end

	local track = data.Model:WaitForChild("AnimationController"):LoadAnimation(script.Animation)
	track:Play()
	track.Ended:Connect(function()
		for _, part in ipairs(data.Model:GetDescendants()) do
			if part:IsA("BasePart") then
				TweenService:Create(part, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Transparency = 1
				}):Play()
			end
		end

		flipModel(data.Model)
		data.Model:Destroy()
		track:Destroy()
	end)
end

function EggsController:Open(p: string, p2, _: CFrame, _: CFrame, _: number)
	task.delay(1.65, function()
		self:ShowReward(p2)
	end)
	self:NewCrack(p, p2)
end

function EggsController:Start()
	self._template = eggOpenInfo:WaitForChild("Template")
	self._template.Parent = nil
	self._template.Visible = true
	openEgg.OnClientEvent:Connect(function(...)
		self:Open(...)
	end)
end

return EggsController