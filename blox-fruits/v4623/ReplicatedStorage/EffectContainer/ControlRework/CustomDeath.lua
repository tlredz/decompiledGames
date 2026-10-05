local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local color = Color3.fromRGB(128, 187, 219)

local function RecolorControlColor(player, color2: Color3)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return Util.WrapColor3Constructor(color2, player, "ControlFruitVFXColor")
	end

	return color2
end

local function makeSlicePlate(instance, p: string, color2: Color3?)
	local clone = instance:Clone()
	clone.Name = "_MagicSlice" .. "_" .. p
	clone:ClearAllChildren()
	clone.Material = Enum.Material.Neon
	clone.Color = color2 or color
	clone.Transparency = 0
	clone.Reflectance = 0
	clone.CastShadow = false
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	clone.Anchored = false
	clone.Massless = true
	local X = instance.Size.X
	local _ = instance.Size.Y
	clone.Size = Vector3.new(X, 0.1, instance.Size.Z)
	local v = instance.Size.Y * 0.5 - 0.05 + 0.02

	if p == "UpperBottom" then
		clone.CFrame = instance.CFrame * CFrame.new(0, -v, 0)
	else
		clone.CFrame = instance.CFrame * CFrame.new(0, v, 0)
	end

	local pointLight = Instance.new("PointLight")
	pointLight.Name = "_SliceGlow"
	pointLight.Color = color2 or color
	pointLight.Brightness = 2
	pointLight.Range = 8
	pointLight.Parent = clone
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function weldCapToTorso(slicePlate, part)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Name = "_SliceWeld"
	weldConstraint.Part0 = part
	weldConstraint.Part1 = slicePlate
	weldConstraint.Parent = slicePlate
	slicePlate.Parent = part.Parent
end

local function addMagicSlice(upperTorso, lowerTorso, color2: Color3?)
	for _, part in ipairs(upperTorso.Parent:GetDescendants()) do
		if not (part:IsA("BasePart") and part.Name:find("_MagicSlice", 1, true)) then
			continue
		end

		part:Destroy()
	end

	local slicePlate = makeSlicePlate(upperTorso, "UpperBottom", color2)
	local slicePlate2 = makeSlicePlate(lowerTorso, "LowerTop", color2)
	weldCapToTorso(slicePlate, upperTorso) -- equivalent call inferred; original call site unknown
	weldCapToTorso(slicePlate2, lowerTorso) -- equivalent call inferred; original call site unknown
end

return function(player)
	local character = player.Character
	local player2 = player.Player
	local color2 = player.Color or color

	if typeof(player2) == "Instance" and player2:IsA("Player") and player2.Parent then
		color2 = Util.WrapColor3Constructor(color2, player2, "ControlFruitVFXColor")
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R15 then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local upperTorso = character:FindFirstChild("UpperTorso")
	local lowerTorso = character:FindFirstChild("LowerTorso")

	if not (humanoidRootPart and upperTorso and lowerTorso) or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 1500 then
		return
	end

	addMagicSlice(upperTorso, lowerTorso, color2)

	if character == game.Players.LocalPlayer.Character then
		workspace.CurrentCamera.CameraSubject = character:FindFirstChild("Head") or upperTorso
	end
end