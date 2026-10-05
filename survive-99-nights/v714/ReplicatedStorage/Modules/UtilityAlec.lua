local UtilityAlec = {}
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

function UtilityAlec.printTable(p)
	local Scan

	Scan = function(items, count)
		for k, item in pairs(items) do
			print("|--", string.rep("\t", count), k, " || ", item)

			if type(item) == "table" then
				Scan(item, count + 1)
			end
		end
	end

	Scan(p, 0)
end

function UtilityAlec.deepCopy(items)
	if type(items) ~= "table" then
		return items
	end

	local copiesByCopy = {}

	for k, item in next, items, nil do
		copiesByCopy[UtilityAlec.deepCopy(k)] = UtilityAlec.deepCopy(item)
	end

	setmetatable(copiesByCopy, UtilityAlec.deepCopy((getmetatable(items))))
	return copiesByCopy
end

function UtilityAlec.tweenModel(instance, cframe: CFrame, value: number, p, p2)
	local tweenInfo = TweenInfo.new(value or 0.5, p or Enum.EasingStyle.Linear, p2 or Enum.EasingDirection.In)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = instance:GetPivot()
	cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
		instance:PivotTo(cFrameValue.Value)
	end)
	local tween = TweenService:Create(cFrameValue, tweenInfo, {
		Value = cframe
	})
	tween:Play()
	tween.Completed:connect(function()
		cFrameValue:Destroy()
	end)
end

local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
game:GetService("Players")
game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("ServerScriptService")
local ContentProvider = game:GetService("ContentProvider")
game:GetService("StarterPlayer")
local v = {}

function UtilityAlec.GetAnimationLength(p)
	local animationId = p.AnimationId

	if v[animationId] then
		return v[animationId]
	end

	local keyframeSequenceAsync = KeyframeSequenceProvider:GetKeyframeSequenceAsync(animationId)
	local keyframes = keyframeSequenceAsync:GetKeyframes()
	local v2 = 0

	for i = 1, #keyframes do
		local time = keyframes[i].Time

		if v2 < time then
			v2 = time
		end
	end

	keyframeSequenceAsync:Destroy()
	v[animationId] = v2
	return v2
end

function UtilityAlec.drawRay(ray: Ray, p, p2)
	local part = Instance.new("Part")
	part.FormFactor = Enum.FormFactor.Custom
	part.Size = Vector3.new(0.2, ray.Direction.Magnitude, 0.2)
	local v3 = ray.Origin + ray.Direction / 2
	part.CFrame = CFrame.new(v3, ray.Origin + ray.Direction) * CFrame.Angles(1.5707963267948966, 0, 0)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Transparency = 0.5
	part.BrickColor = p or BrickColor.new("Bright red")
	part.Name = "DrawnRay"
	Instance.new("SpecialMesh", part)
	part.Parent = p2 or Workspace
	Debris:AddItem(part, 6)
	return part
end

function UtilityAlec.preload(items)
	local function checkFailed(_, p)
		local _ = p == Enum.AssetFetchStatus.Failure
	end

	task.spawn(function()
		ContentProvider:PreloadAsync(items, checkFailed)
	end)
	task.spawn(function()
		local animationController = Instance.new("AnimationController")
		local animator = Instance.new("Animator")
		animator.Parent = animationController
		animationController.Parent = workspace
		local v2 = {}

		for _, animation in pairs(items) do
			if not (typeof(animation) == "Instance" and animation:IsA("Animation")) then
				continue
			end

			local v3 = animation
			local success, result = pcall(function()
				return animator:LoadAnimation(v3)
			end)

			if not (success and result) then
				continue
			end

			result:Play(0)
			table.insert(v2, result)
		end

		task.wait()

		for _, v3 in pairs(v2) do
			v3:Stop(0)
			v3:Destroy()
		end

		animationController:Destroy()
	end)
	task.spawn(function()
		local localPlayer = game.Players.LocalPlayer

		if not localPlayer then
			return
		end

		local Client = require(localPlayer:WaitForChild("PlayerScripts"):WaitForChild("Client"))

		for _, item in pairs(items) do
			if typeof(item) ~= "string" then
				continue
			end

			local imageLabel = Instance.new("ImageLabel")
			imageLabel.ImageTransparency = 0.999
			imageLabel.BackgroundTransparency = 1
			imageLabel.BorderSizePixel = 0
			imageLabel.Parent = Client.Interface.PreloadImages
			imageLabel.Image = item
			imageLabel.Size = UDim2.new(0, 5, 0, 5)
			task.wait(0.4)
			imageLabel:Destroy()
		end
	end)
end

function UtilityAlec.findBigBuilding(parent)
	repeat
		parent = parent.Parent
	until not parent or parent == game or parent:HasTag("LargeBuilding") or parent:HasTag("EpicBuilding")

	if parent and parent ~= game then
		return parent, parent:HasTag("EpicBuilding") and "Epic" or "Large"
	end
end

return UtilityAlec