local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EmoteMountService = require(ReplicatedStorage.Engine.Service.EmoteMountService)
local v = nil
local flag = false
local bindableEvent = Instance.new("BindableEvent")
local color = Color3.fromRGB(128, 128, 128)
local v2 = {
	createVector(1, 1, 1),
	createVector(1, 1, -1),
	createVector(1, -1, 1),
	createVector(1, -1, -1),
	createVector(-1, 1, 1),
	createVector(-1, 1, -1),
	createVector(-1, -1, 1),
	createVector(-1, -1, -1)
}

local function prepareAvatar(folder)
	local humanoid = folder:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

	if not (humanoid and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		folder:Destroy()
		return nil
	end

	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.NameDisplayDistance = 0
	humanoid.HealthDisplayDistance = 0

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BaseScript") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = descendant == humanoidRootPart
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.Massless = true
		end
	end

	folder.Archivable = true
	folder:PivotTo(CFrame.new())
	return folder
end

local function createDefaultR15()
	local humanoidDescription = Instance.new("HumanoidDescription")
	humanoidDescription.HeadColor = color
	humanoidDescription.TorsoColor = color
	humanoidDescription.LeftArmColor = color
	humanoidDescription.RightArmColor = color
	humanoidDescription.LeftLegColor = color
	humanoidDescription.RightLegColor = color
	local success, result = pcall(function()
		return Players:CreateHumanoidModelFromDescriptionAsync(humanoidDescription, Enum.HumanoidRigType.R15)
	end)
	humanoidDescription:Destroy()

	if success and result then
		return (prepareAvatar(result))
	end

	warn("[EmoteWheel PreviewRenderer] 创建官方默认 R15 Rig 失败: " .. tostring(result))
	return nil
end

local function getAvatarTemplate()
	if v then
		return v
	end

	if flag then
		bindableEvent.Event:Wait()
		return v
	end

	flag = true
	v = createDefaultR15()
	flag = false
	bindableEvent:Fire()
	return v
end

local function computeVisibleBounds(folder)
	local vector2 = nil
	local vector3 = nil

	for _, part in ipairs(folder:GetDescendants()) do
		if not (part:IsA("BasePart") and part.Transparency < 1) then
			continue
		end

		local v3 = part.Size * 0.5

		for _, v4 in ipairs(v2) do
			local pointToWorldSpace = part.CFrame:PointToWorldSpace((Vector3.new(v3.X * v4.X, v3.Y * v4.Y, v3.Z * v4.Z)))

			if vector2 == nil then
				vector3 = pointToWorldSpace
				vector2 = vector3
				vector3 = vector2
			else
				vector2 = Vector3.new(
					math.min(vector2.X, pointToWorldSpace.X),
					math.min(vector2.Y, pointToWorldSpace.Y),
					(math.min(vector2.Z, pointToWorldSpace.Z))
				)
				vector3 = Vector3.new(
					math.max(vector3.X, pointToWorldSpace.X),
					math.max(vector3.Y, pointToWorldSpace.Y),
					(math.max(vector3.Z, pointToWorldSpace.Z))
				)
			end
		end
	end

	if vector2 == nil or vector3 == nil then
		return createVector(0, 0, 0), createVector(4, 6, 2)
	end

	return (vector2 + vector3) * 0.5, vector3 - vector2
end

local function setupCamera(parent, clone)
	local v3, v4 = computeVisibleBounds(clone)
	local v5 = math.max(v4.Magnitude * 0.5, 1) / 0.3420201433256687 * 1.35
	local camera = Instance.new("Camera")
	camera.Name = "预览相机"
	camera.FieldOfView = 40
	camera.CFrame = CFrame.lookAt(v3 + Vector3.new(0, v4.Y * 0.12, -v5), v3 + Vector3.new(0, v4.Y * 0.05, 0))
	camera.Parent = parent
	parent.CurrentCamera = camera
	return camera
end

local function loadFreeEmote(clone, animation: string)
	local humanoid = clone:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return nil
	end

	local v3 = humanoid:FindFirstChildOfClass("Animator")

	if not v3 then
		v3 = Instance.new("Animator")
		v3.Parent = humanoid
	end

	local animation2 = Instance.new("Animation")
	animation2.Name = "预览动作"
	animation2.AnimationId = animation
	animation2.Parent = clone
	local success, result = pcall(function()
		return v3:LoadAnimation(animation2)
	end)

	if not success then
		warn("[EmoteWheel PreviewRenderer] 加载免费动作失败: " .. tostring(result))
		return nil
	end

	result.Priority = Enum.AnimationPriority.Action
	result.Looped = true
	result:Play()
	return result
end

return {
	render = function(self, data)
		if not v then
			if flag then
				bindableEvent.Event:Wait()
			else
				flag = true
				v = createDefaultR15()
				flag = false
				bindableEvent:Fire()
			end
		end

		local v3 = v

		if not v3 or self.Parent == nil then
			return nil
		end

		local worldModel = Instance.new("WorldModel")
		worldModel.Name = "动画预览"
		worldModel.Parent = self
		local clone = v3:Clone()
		clone.Name = "预览角色"
		clone.Parent = worldModel
		local v4 = nil
		local v5 = nil

		if data.kind == "freeEmote" and typeof(data.animation) == "string" then
			v5 = loadFreeEmote(clone, data.animation)
		elseif data.kind == "flyer" and typeof(data.assetName) == "string" then
			v4, v5 = EmoteMountService.client.mountLocal(clone, data.assetName)
		end

		local currentCamera = setupCamera(self, clone)
		local flag2 = false
		return function()
			if flag2 then
				return
			end

			flag2 = true

			if v4 then
				EmoteMountService.client.unmountLocal(v4, v5)
				v5 = nil
				v4 = nil
			elseif v5 then
				v5:Stop()
				v5:Destroy()
				v5 = nil
			end

			if self.CurrentCamera == currentCamera then
				self.CurrentCamera = nil
			end

			currentCamera:Destroy()
			worldModel:Destroy()
		end
	end
}