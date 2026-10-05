local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
game:GetService("TweenService")
game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local _ = FX:WaitForChild("ControlRework").M1
local f_Katsuo = FX:WaitForChild("ControlRework").F_Katsuo
local z_Katsuo = FX:WaitForChild("ControlRework").Z_Katsuo
local x_Katsuo = FX:WaitForChild("ControlRework").X_Katsuo
local shared = script.Parent.Parent.Shared
local utility = shared.Utility
local VisualHelper = require(utility.VisualHelper)
require(utility.MathHelper)
require(shared.Textures)
require(shared.Rocks)
require(shared:WaitForChild("ObjectClass"))
local random = Random.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

local function DarkSlash(cFrame: CFrame, player, value: number?, flag: boolean?, value2: number?)
	local model = Instance.new("Model", workspace._WorldOrigin)
	Util.Debris:AddItem(model, 5)
	local clone = f_Katsuo.DarkSlash:Clone()
	clone:ScaleTo(value2 or 1.65)
	local slash = clone.Slash
	slash.CFrame = cFrame
	Util.SetParentOverrideWithColor(slash, model, player, "ControlFruitVFXColor")
	VisualHelper:Tween(slash.Winds, TweenInfo.new(0.17, Enum.EasingStyle.Sine), {
		Orientation = createVector(0, 360, 0)
	})

	for _, child in slash.Winds:GetChildren() do
		child.Beam.Enabled = true
		VisualHelper:Tween(child.Beam, TweenInfo.new(0.17, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		})
	end

	for _, emitter in slash.Slash:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Rotation = NumberRange.new(value or 0)
		VisualHelper:Emit(emitter)
	end

	VisualHelper:EmitAll(slash, true)
	local slashBeam = slash.SlashBeam
	slashBeam.Orientation = createVector(0, 180, 0)

	if flag then
		local beamsFlipBook = VisualHelper.BeamsFlipBook.new(8, 60)
		beamsFlipBook:Insert(slashBeam.BeamThunder)
		beamsFlipBook:Play()
		task.delay(1, beamsFlipBook.Destroy, beamsFlipBook)
	end

	VisualHelper:Tween(slashBeam, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
		Orientation = slashBeam.Orientation + createVector(0, 180, 0)
	})

	for _, child in slashBeam.Beams:GetChildren() do
		child.Enabled = true
		child.Width0 *= 2
		child.Width1 *= 2
		VisualHelper:Tween(child, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		})
	end

	VisualHelper:Tween(slash.PointLight, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
		Brightness = 0
	})
	Util.Debris:AddItem(slash, 2)
	local staticSlash = slash.StaticSlash
	staticSlash.Beam.Enabled = true
	task.delay(0.025, function()
		staticSlash:Destroy()
	end)
	return slash
end

local function SliceLine(cframe: CFrame, player, _: number, value: number?)
	local model = Instance.new("Model", workspace._WorldOrigin)
	Util.Debris:AddItem(model, 5)
	local clone = z_Katsuo.Rush:Clone()
	clone:ScaleTo(0.5)
	clone:PivotTo(cframe)
	Util.SetParentOverrideWithColor(clone, model, player, "ControlFruitVFXColor")
	VisualHelper:EmitAll(clone)
	Util.Debris:AddItem(clone, 1)
	local v = value or 1

	for i, child in clone.Main.Beams.Beams:GetChildren() do
		child.Enabled = true

		if child.Name == "Air" then
			VisualHelper:Tween(child, TweenInfo.new(0.35 * v, Enum.EasingStyle.Sine), {
				Brightness = 0
			})
		else
			local v2 = child.Name == "Fade"
			VisualHelper:Tween(child, TweenInfo.new((v2 and 0.35 or 0.07 + i * 0.01) * v, Enum.EasingStyle.Sine), {
				Width0 = 0,
				Width1 = 0
			})
		end
	end

	if v == 1 then
		return
	end

	for _, emitter in clone:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Lifetime = NumberRange.new(emitter.Lifetime.Min * v, emitter.Lifetime.Max * v)
		VisualHelper:Emit(emitter)
	end
end

local function EmitAuraExplosion(cframe: CFrame, player, p: number)
	local model = Instance.new("Model", workspace._WorldOrigin)
	Util.Debris:AddItem(model, 5)
	local clone = z_Katsuo.AuraExplosion:Clone()
	clone:ScaleTo(p)
	clone:PivotTo(cframe)
	Util.SetParentOverrideWithColor(clone, model, player, "ControlFruitVFXColor")
	clone.Main.Layers.Orientation = createVector(0, 1, 0) * random:NextNumber(-360, 360)

	for i, child in clone.Main.Layers:GetChildren() do
		child.Orientation *= 1.5
		local beam = child.Beam
		beam.Enabled = true
		local number = random:NextNumber(0.17, 0.25)
		VisualHelper:Tween(child, TweenInfo.new(number, Enum.EasingStyle.Linear), {
			Orientation = child.Orientation + Vector3.new(0, 450 * (i % 2 == 0 and 1 or -1))
		})
		VisualHelper:Tween(beam, TweenInfo.new(number, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		})
	end

	for _, child in clone.Main.CircleWinds:GetChildren() do
		local beam = child.Beam
		beam.Enabled = true
		VisualHelper:Tween(beam, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		})
	end

	VisualHelper:EmitAll(clone)
	Util.Debris:AddItem(clone, 2)
end

local function EmitFloor(cFrame: CFrame, player)
	local model = Instance.new("Model", workspace._WorldOrigin)
	Util.Debris:AddItem(model, 5)
	local clone = x_Katsuo.FloorSpawnEnd:Clone()
	clone.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, model, player, "ControlFruitVFXColor")
	VisualHelper:EmitAll(clone)
	clone.PointLight.Enabled = true
	VisualHelper:Tween(clone.PointLight, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		Brightness = 0
	})
	Util.Debris:AddItem(clone, 2.15)
end

return function(data)
	if typeof(data.Player) == "Instance" and data.Player:IsA("Player") and not data.Player:FindFirstChild("PlayerGui") and data.Player ~= game.Players.LocalPlayer then
		local folder = Instance.new("Folder", data.Player)
		folder.Name = "PlayerGui"
	end

	local origin = data.Origin or data.Root and data.Root.Position or data.hrp and data.hrp.Position or data.Player and data.Player.Character.PrimaryPart.Position or data.player and data.player.Character.PrimaryPart.Position
	assert(origin, "Origin Vector3 missing in: ", script:GetFullName())

	if (currentCamera.CFrame.Position - origin).Magnitude > 1200 then
		return
	end

	local root = data.Root

	if data.Cast then
		local cFrame = root.CFrame * CFrame.new(0, -2.8, 0)
		EmitAuraExplosion(cFrame, data.Player, 3)
		task.wait(0.075)
		DarkSlash(
			root.CFrame * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(0, 0, 0),
			data.Player,
			180,
			true,
			6.15
		)
		task.wait(0.1)

		if data.Player == game.Players.LocalPlayer then
			VisualHelper:Tween(currentCamera, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
				FieldOfView = 80
			})
		end

		task.wait(0.05)
		EmitFloor(cFrame, data.Player)

		if data.Player == game.Players.LocalPlayer then
			VisualHelper:Tween(currentCamera, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
				FieldOfView = 70
			})
		end
	else
		local hitCF = data.HitCF
		local _ = data.PlaneCF
		local cframe = CFrame.Angles(
			math.random() * 3.141592653589793,
			math.random() * 3.141592653589793,
			math.random() * 3.141592653589793
		)
		SliceLine(hitCF * (cframe or CFrame.Angles(0, 1.5707963267948966, 0)), data.Player, 1.5, cframe and 1.5 or 1.25)
	end
end