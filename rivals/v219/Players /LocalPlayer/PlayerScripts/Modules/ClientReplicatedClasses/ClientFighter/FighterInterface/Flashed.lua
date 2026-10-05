local createVector = vector.create
game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local GameplayUtility = require(ReplicatedStorage.Modules.GameplayUtility)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local flashbangGui = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("FlashbangGui")
local _ = {
	"",
	"rbxassetid://18983794775",
	"rbxassetid://18983794942",
	"rbxassetid://18983795108"
}
local Flashed = {}
Flashed.__index = Flashed

function Flashed.new(fighterInterface)
	local self = setmetatable({}, Flashed)
	self.FighterInterface = fighterInterface
	self._default_flash_sound_callback = nil
	self._default_ringing_sound_callback = nil
	self._flash_objects = {}
	self:_Init()
	return self
end

function Flashed:AttemptToFlash(p, p2, p3, p4, p5, p6)
	if self:_IsOccluded(p, p2) then
		return
	end

	self:Flash(p2, p3, p4, p5, p6)
end

function Flashed:Flash(p, p2, p3, p4, p5)
	local worldToScreenPoint, v = workspace.CurrentCamera:WorldToScreenPoint(p)
	local screenPointToPosition = UILibrary:ScreenPointToPosition(
		Vector2.new(worldToScreenPoint.X, worldToScreenPoint.Y),
		self.FighterInterface.Frame.AbsolutePosition
	)
	local uDim = UDim2.new(
		0,
		math.clamp(
			screenPointToPosition.X,
			-self.FighterInterface.Frame.AbsoluteSize.X * 0.5,
			self.FighterInterface.Frame.AbsoluteSize.X * 1.5
		),
		0,
		(math.clamp(
			screenPointToPosition.Y,
			-self.FighterInterface.Frame.AbsoluteSize.Y * 0.5,
			self.FighterInterface.Frame.AbsoluteSize.Y * 1.5
		))
	)
	local setting = PlayerDataController:GetSetting("Accessible Flashes")
	local v2 = setting and -2 or 2
	local color = setting and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
	local color2 = p4 == "Shining Star" and Color3.fromRGB(255, 215, 0) or p4 == "Sol" and Color3.fromRGB(255, 251, 133) or setting and Color3.fromRGB(
		60,
		60,
		60
	) or Color3.fromRGB(220, 215, 204)
	local image = p4 == "Pixel Flashbang" and "rbxassetid://123806439184095" or "rbxassetid://14796588510"
	local v4 = p4 == "Pixel Flashbang" and 0.75 or 1
	local pixelated = p4 == "Pixel Flashbang" and Enum.ResamplerMode.Pixelated or Enum.ResamplerMode.Default
	local clone = flashbangGui:Clone()
	clone.Background.BackgroundColor3 = color
	clone.Center.Skullbang.Visible = false
	clone.Center.Position = uDim
	clone.Rays1.Position = uDim + UDim2.new(0, math.random(-30, 30), 0, math.random(-30, 30))
	clone.Rays2.Position = uDim + UDim2.new(0, math.random(-30, 30), 0, math.random(-30, 30))
	clone.Rays3.Position = uDim + UDim2.new(0, math.random(-30, 30), 0, math.random(-30, 30))
	clone.Rays1.ResampleMode = pixelated
	clone.Rays2.ResampleMode = pixelated
	clone.Rays3.ResampleMode = pixelated
	clone.Rays1.Image = image
	clone.Rays2.Image = image
	clone.Rays3.Image = image
	clone.Rays1.Size = UDim2.new(
		clone.Rays1.Size.X.Scale * v4,
		clone.Rays1.Size.X.Offset * v4,
		clone.Rays1.Size.Y.Scale * v4,
		clone.Rays1.Size.Y.Offset * v4
	)
	clone.Rays2.Size = UDim2.new(
		clone.Rays2.Size.X.Scale * v4,
		clone.Rays2.Size.X.Offset * v4,
		clone.Rays2.Size.Y.Scale * v4,
		clone.Rays2.Size.Y.Offset * v4
	)
	clone.Rays3.Size = UDim2.new(
		clone.Rays3.Size.X.Scale * v4,
		clone.Rays3.Size.X.Offset * v4,
		clone.Rays3.Size.Y.Scale * v4,
		clone.Rays3.Size.Y.Offset * v4
	)
	clone.Parent = Players.LocalPlayer.PlayerGui
	BetterDebris:AddItem(clone, 10)
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Name = "Flashbang"
	colorCorrectionEffect.Parent = Lighting
	BetterDebris:AddItem(colorCorrectionEffect, 10)
	local part = Instance.new("Part")
	part.Size = createVector(10, 10, 0)
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Color = color
	part.Material = Enum.Material.Neon
	part.Parent = v and workspace or nil
	BetterDebris:AddItem(part, 10)
	local v5 = (p5 or self._default_ringing_sound_callback)()
	local v6 = p2 * (v and 1 or worldToScreenPoint.Z > 0 and 0.125 or 0)
	local v7 = math.max(0.5, v6)
	local lastTime = tick()
	local v8 = 0

	if v6 > 0 then
		ReplicatedStorage.Remotes.Replication.Fighter.BlindedEffect:FireServer(p3, v6)
	end

	local _RegisterFlashObjects = self:_RegisterFlashObjects(v6, clone, colorCorrectionEffect, part, v5)

	if p4 == "Camera" and v then
		local success, result = pcall(self._CameraSnapshot, self, p, uDim, clone, _RegisterFlashObjects)

		if not success then
			warn("Camera Flashbang snapshot failed, error:", result)
		end
	end

	self:_UpdateVisibility()

	while tick() < lastTime + v7 do
		local v9 = math.min(1, (tick() - lastTime) / v7)
		local v10 = v6 > 0 and v9 or v9 * 0.25 + 0.75
		local imageTransparency = 0.5 + 0.5 * v10
		local v12

		if p4 == "Disco Ball" then
			v12 = Color3.fromHSV(tick() * 0.5 % 1, 0.75, 1)
		else
			v12 = color2
		end

		local lerped = v12:Lerp(color, v10)

		if v5 then
			v5.Volume = 1 - v10
		end

		colorCorrectionEffect.Brightness = v2 + (0 - v2) * v10
		clone.Rays1.ImageTransparency = imageTransparency
		clone.Rays2.ImageTransparency = imageTransparency
		clone.Rays3.ImageTransparency = imageTransparency
		clone.Rays1.ImageColor3 = lerped
		clone.Rays2.ImageColor3 = lerped
		clone.Rays3.ImageColor3 = lerped
		clone.Background.Transparency = not v and 1 or v10 ^ 5
		clone.Polaroid.GroupTransparency = 0.25 + 0.75 * v10 ^ 2
		part.Transparency = math.max(0, v10 - 0.25) / 0.75
		part.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -1)

		if p4 == "Pixel Flashbang" then
			clone.Rays1.Position = uDim + UDim2.new(0, math.random(-30, 30) * v4, 0, math.random(-30, 30) * v4)
			clone.Rays2.Position = uDim + UDim2.new(0, math.random(-30, 30) * v4, 0, math.random(-30, 30) * v4)
			clone.Rays3.Position = uDim + UDim2.new(0, math.random(-30, 30) * v4, 0, math.random(-30, 30) * v4)
		else
			clone.Rays1.Rotation += v8 * 0.5 * 60
			clone.Rays2.Rotation -= v8 * 0.25 * 60
			clone.Rays3.Rotation += v8 * 0.37237 * 60
		end

		v8 = RunService.RenderStepped:Wait()
	end

	part:Destroy()
	colorCorrectionEffect:Destroy()
	clone:Destroy()
end

function Flashed:Destroy()
	for _, _flash_object in pairs(self._flash_objects) do
		for _, v in pairs(_flash_object) do
			v[1]:Destroy()
		end
	end

	self._flash_objects = {}
end

function Flashed:_CameraSnapshot(p, p2, p3, p4)
	local folder = SpectateController.CurrentSubject and SpectateController.CurrentSubject.Entity and SpectateController.CurrentSubject:CloneFighterModel()

	if not folder then
		return
	end

	local face = folder:FindFirstChild("face", true)

	if face and face:IsA("Decal") then
		face.Texture = "rbxassetid://18983839334"
	end

	local camera = Instance.new("Camera")
	camera.CFrame = CFrame.new(folder.Head.Position + (p - folder.Head.Position).Unit * 8, folder.Head.Position)
	camera.FieldOfView = 35
	p3.Polaroid.Visible = true
	p3.Polaroid.Picture.BackgroundColor3 = Color3.fromHSV(math.random(), 0.756, 0.56)
	p3.Polaroid.Picture.ViewportFrame.LightDirection = camera.CFrame.LookVector
	p3.Polaroid.Picture.ViewportFrame.CurrentCamera = camera
	p3.Polaroid.Rotation = 180
	p3.Polaroid.Position = UDim2.new(math.random(), 0, 1.5, 0)
	p3.Polaroid:TweenPosition(p2, "Out", "Quint", 1, true)
	TweenService:Create(p3.Polaroid, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Rotation = 1080 + 45 * (math.random() - 0.5)
	}):Play()
	camera.Parent = p3.Polaroid.Picture.ViewportFrame
	folder.Parent = p3.Polaroid.Picture.ViewportFrame.WorldModel

	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end

	self:_RegisterFlashObject(p4, folder)
	self:_RegisterFlashObject(p4, camera)
	return folder, camera
end

function Flashed:_IsOccluded(options, p2)
	local v = options or {}

	if self.FighterInterface.ClientFighter.Entity then
		table.insert(v, self.FighterInterface.ClientFighter.Entity.Model)
	end

	local raycastResult

	while true do
		raycastResult = Utility:Raycast(
			workspace.CurrentCamera.CFrame.Position,
			p2,
			(workspace.CurrentCamera.CFrame.Position - p2).Magnitude,
			v,
			Enum.RaycastFilterType.Exclude
		)

		if not raycastResult.Instance or raycastResult.Instance.CanCollide or raycastResult.Instance:HasTag("SmokeCloud") then
			break
		end

		table.insert(v, raycastResult.Instance)
	end

	if raycastResult.Instance then
		return true
	end

	return #GameplayUtility:GetSmokeCloudsInSphere(p2) > 0
end

function Flashed:_RegisterFlashObject(list, p)
	table.insert(list, { p, p.Parent })
end

function Flashed:_RegisterFlashObjects(duration, ...)
	local v = {}

	for _, v2 in pairs({ ... }) do
		self:_RegisterFlashObject(v, v2)
	end

	table.insert(self._flash_objects, v)
	task.delay(duration, function()
		local index = table.find(self._flash_objects, v)

		if index then
			table.remove(self._flash_objects, index)
		end
	end)
	return v
end

function Flashed:_UpdateVisibility()
	for _, _flash_object in pairs(self._flash_objects) do
		for _, v in pairs(_flash_object) do
			local v2 = v
			pcall(function()
				v2[1].Parent = self.FighterInterface:IsActive() and v2[2] or nil
			end)
		end
	end
end

function Flashed:_Setup()
	function self._default_ringing_sound_callback()
		return Utility:CreateSound("rbxassetid://14778230632", 1, 1, script, true, 10)
	end
end

function Flashed:_Init()
	self.FighterInterface.ActiveChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	self:_Setup()
end

return Flashed