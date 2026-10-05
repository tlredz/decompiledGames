local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local domain_Katsuo = FX:WaitForChild("ControlRework").Domain_Katsuo
local utility = script.Parent.Shared.Utility
local VisualHelper = require(utility.VisualHelper)
require(utility.MathHelper)
require(ReplicatedStorage.Effect)

local function RecolorControlColor(player, color: Color3)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return Util.WrapColor3Constructor(color, player, "ControlFruitVFXColor")
	end

	return color
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ColorBrightness(color: Color3, value: number?)
	local HSV, v, v2 = color:ToHSV()
	return Color3.fromHSV(HSV, v, v2 * (value or 1))
end

local function ApplyColor(items, color: Color3)
	for _, instance in items do
		if instance:GetAttribute("Uncolor") then
			continue
		end

		if instance:IsA("BasePart") then
			instance.Color = color
		elseif instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam") and (instance.Name == "NeonBeam" or instance.Name == "NeonBeamMove") then
			instance.Color = ColorSequence.new(color)
		elseif instance:IsA("Decal") then
			instance.Color3 = ColorBrightness(color, instance.Name == "TopGlow" and 2.5 or false)
		elseif instance:IsA("ImageLabel") then
			instance.ImageColor3 = color
			instance.BackgroundColor3 = color
		elseif instance:IsA("Light") then
			instance.Color = color
		end
	end
end

Random.new()
return function(player)
	if typeof(player.Player) == "Instance" and player.Player:IsA("Player") and not player.Player:FindFirstChild("PlayerGui") and player.Player ~= game.Players.LocalPlayer then
		local folder = Instance.new("Folder", player.Player)
		folder.Name = "PlayerGui"
	end

	local origin = player.Origin or player.Root and player.Root.Position or player.hrp and player.hrp.Position or player.Player and player.Player.Character.PrimaryPart.Position or player.player and player.player.Character.PrimaryPart.Position
	assert(origin, "Origin Vector3 missing in: ", script:GetFullName())

	if (currentCamera.CFrame.Position - origin).Magnitude > 1200 then
		return
	end

	local tag = player.Tag
	local storage = player.Storage
	local root = player.Root
	local _ = player.Character
	local _ = player.MaxObjects or 12
	local cframe = CFrame.new(0, 5, 1.15)
	local model = Instance.new("Model", workspace._WorldOrigin)
	local lastTime = tick()
	local clones = {}
	local player2 = player.Player
	local color = Color3.fromRGB(35, 94, 255)

	if typeof(player2) == "Instance" and player2:IsA("Player") and player2.Parent then
		color = Util.WrapColor3Constructor(color, player2, "ControlFruitVFXColor")
	end

	local function AdjustObjectColors(color2: Color3)
		for _, v in clones do
			ApplyColor(v.Particles:GetChildren(), color2)
			ApplyColor({ v.PointLight }, color2)

			for _, child in v.Shader:GetChildren() do
				local imageLabel = child.ImageLabel
				local player3 = player.Player
				local color3 = Color3.fromRGB(158, 189, 255)

				if typeof(player3) == "Instance" and player3:IsA("Player") and player3.Parent then
					color3 = Util.WrapColor3Constructor(color3, player3, "ControlFruitVFXColor")
				end

				imageLabel.ImageColor3 = color3
				local imageLabel2 = child.ImageLabel
				local player4 = player.Player
				local color4 = Color3.fromRGB(79, 112, 189)

				if typeof(player4) == "Instance" and player4:IsA("Player") and player4.Parent then
					color4 = Util.WrapColor3Constructor(color4, player4, "ControlFruitVFXColor")
				end

				imageLabel2.BackgroundColor3 = color4
			end
		end
	end

	local heartbeatConnection = RunService.Heartbeat:Connect(function(_)
		local v = tick() - lastTime
		local v2 = math.floor(#storage:GetChildren() / 2)
		local count = #clones

		if count < v2 then
			local clone = domain_Katsuo.SingleCube:Clone()
			local size = clone.Size * (1 + math.random() * 0.25)
			clone.Size = createVector(0, 0, 0)
			Util.SetParentOverrideWithColor(clone, workspace.Terrain, player.Player, "ControlFruitVFXColor")
			VisualHelper:Tween(clone, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
				Size = size
			})
			table.insert(clones, clone)
			AdjustObjectColors(color)
			count += 1
		else
			local v3 = v2 < count and table.remove(clones, 1)

			if v3 then
				local clone = domain_Katsuo.Vault.EndCube:Clone()
				Util.SetParentOverrideWithColor(clone, workspace.Terrain, player.Player, "ControlFruitVFXColor")
				clone.WorldCFrame = v3.CFrame
				ApplyColor(clone:GetDescendants(), color)
				VisualHelper:EmitAll(clone)
				Util.Debris:AddItem(clone, 1.5)
				v3:Destroy()
				count -= 1
			end
		end

		local v3 = clones
		local count2 = #v3

		if count2 == 0 then
			return
		end

		local _, v4 = root.CFrame:ToEulerAnglesYXZ()
		local v5 = math.rad(v * 90)
		local v6 = count2 >= 2 and 4 or 1

		for k, v7 in v3 do
			local v8 = k / count2
			local v9 = root.CFrame * CFrame.Angles(0, 0, v8 * -3.141592653589793 + 1.5707963267948966) * cframe.Position
			v7.CFrame = v7.CFrame:Lerp(
				CFrame.new(v9 + v9.Unit * math.sin((v + k) * v6) * 1.75) * CFrame.Angles(v5, v4, -v5),
				v7.Position == domain_Katsuo.SingleCube.Position and 1 or 0.1
			)
		end
	end)
	tag.Destroying:Once(function()
		pcall(function()
			heartbeatConnection:Disconnect()
		end)

		for _, v in pairs(clones) do
			local clone = domain_Katsuo.Vault.EndCube:Clone()
			Util.SetParentOverrideWithColor(clone, workspace.Terrain, player.Player, "ControlFruitVFXColor")
			clone.WorldCFrame = v.CFrame
			ApplyColor(clone:GetDescendants(), color)
			VisualHelper:EmitAll(clone)
			Util.Debris:AddItem(clone, 1.5)
			v:Destroy()
		end

		Util.Debris:AddItem(model, 5)
	end)
end