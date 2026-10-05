local createVector = vector.create
local TweenService = game:GetService("TweenService")
local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
local FX = require(game.ReplicatedStorage.FX)
local bonusMoment = FX:WaitForChild("BonusMoment")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local v = {
	ShootDuration = 0.05,
	HoverDuration = 1.5,
	ArcDuration = 1.25,
	ShootHeight = 12,
	HoverBobHeight = 0.75,
	HoverBobs = 1.5,
	ArcHeight = 8,
	SpinTurns = 3,
	MaxRenderDistance = 1000,
	Star = {
		Size = createVector(2, 2, 0.5),
		LightRange = 4.5
	},
	Highlight = {
		SourceFadeDuration = 0.4,
		PlayerHoldDuration = 0.5,
		PlayerFadeDuration = 0.75,
		Color = Color3.fromRGB(255, 214, 82)
	},
	Camera = {
		BlendInDuration = 0.35,
		ZoomOutDistance = 8,
		FadeOutDuration = 0.65
	}
}

local function getOrigin(p)
	if typeof(p) == "CFrame" then
		return p.Position
	end

	return p
end

local function getTargetRoot(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")
end

local function flashGold(adornee, duration: number, duration2: number)
	if not (adornee and adornee.Parent) then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.Adornee = adornee
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = v.Highlight.Color
	highlight.FillTransparency = 0.15
	highlight.OutlineColor = v.Highlight.Color
	highlight.OutlineTransparency = 0
	highlight.Enabled = true
	highlight.Parent = _WorldOrigin

	local function fadeHighlight()
		if not highlight.Parent then
			return
		end

		local tween = TweenService:Create(highlight, TweenInfo.new(duration2), {
			FillTransparency = 1,
			OutlineTransparency = 1
		})
		tween.Completed:Once(function()
			highlight:Destroy()
		end)
		tween:Play()
	end

	if duration > 0 then
		task.delay(duration, fadeHighlight)
	else
		fadeHighlight()
	end
end

local function quadraticBezier(vector2: Vector3, vector3: Vector3, vector4: Vector3, p: number)
	local v2 = 1 - p
	return vector2 * v2 * v2 + vector3 * 2 * v2 * p + vector4 * p * p
end

local function tweenProgress(tweenInfo, onChanged)
	local numberValue = Instance.new("NumberValue")
	local changedConnection = numberValue.Changed:Connect(onChanged)
	local tween = TweenService:Create(numberValue, tweenInfo, {
		Value = 1
	})
	onChanged(0)
	tween:Play()
	tween.Completed:Wait()
	onChanged(1)
	changedConnection:Disconnect()
	numberValue:Destroy()
end

return function(p)
	local origin = p.Origin

	if typeof(origin) == "CFrame" then
		origin = origin.Position
	end

	local nPCs = workspace:FindFirstChild("NPCs")
	local child

	if p.OriginNpcName and nPCs then
		child = nPCs:FindFirstChild(p.OriginNpcName)
	end

	local Players = game:GetService("Players")
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = character.PrimaryPart or character:FindFirstChildWhichIsA("BasePart")
	end

	if not humanoidRootPart then
		return
	end

	local position = workspace.CurrentCamera.CFrame.Position

	if (position - origin).Magnitude > v.MaxRenderDistance and (position - humanoidRootPart.Position).Magnitude > v.MaxRenderDistance then
		return
	end

	local clone = bonusMoment.StarMesh:Clone()
	local model = Instance.new("Model")
	local v2 = origin + createVector(0, 1, 0) * v.ShootHeight
	local v3 = 6.283185307179586 * v.SpinTurns
	local position2 = humanoidRootPart.Position
	model.Name = "BonusMomentStar"
	model.Parent = _WorldOrigin
	clone.Parent = model
	model.PrimaryPart = clone
	clone.Material = Enum.Material.Neon
	model:PivotTo(CFrame.new(origin))
	clone.Size = v.Star.Size

	for _, light in clone:GetDescendants() do
		if light:IsA("PointLight") then
			light.Range = v.Star.LightRange
		end
	end

	local currentCamera = workspace.CurrentCamera
	local v4 = CameraController.new(currentCamera, 1, v.Camera.BlendInDuration)
	v4:SetCameraTarget(clone):Zoom((currentCamera.CFrame.Position - clone.Position).Magnitude + v.Camera.ZoomOutDistance)
	flashGold(child, 0, v.Highlight.SourceFadeDuration)
	tweenProgress(TweenInfo.new(v.ShootDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), function(p2)
		model:PivotTo(CFrame.new(origin:Lerp(v2, p2)) * CFrame.Angles(0, 0, v3 * p2 * 0.25))
	end)
	tweenProgress(TweenInfo.new(v.HoverDuration, Enum.EasingStyle.Linear), function(p2)
		local v5 = math.sin(p2 * 3.141592653589793 * 2 * v.HoverBobs) * v.HoverBobHeight
		local v6 = v3 * (0.25 + p2 * 0.25)
		model:PivotTo(CFrame.new(v2 + createVector(0, 1, 0) * v5) * CFrame.Angles(0, 0, v6))
	end)
	local v5 = v2 + createVector(0, 1, 0) * v.ArcHeight
	tweenProgress(TweenInfo.new(v.ArcDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), function(p2)
		if humanoidRootPart.Parent then
			position2 = humanoidRootPart.Position
		end

		local v8 = position2
		local v9 = 1 - p2
		local v10 = v2 * v9 * v9 + v5 * 2 * v9 * p2 + v8 * p2 * p2
		local v11 = v3 * (0.5 + p2 * 0.5)
		model:PivotTo(CFrame.new(v10) * CFrame.Angles(0, 0, v11))
	end)
	flashGold(character, v.Highlight.PlayerHoldDuration, v.Highlight.PlayerFadeDuration)
	model:Destroy()
	v4:FadeOut(v.Camera.FadeOutDuration)
end