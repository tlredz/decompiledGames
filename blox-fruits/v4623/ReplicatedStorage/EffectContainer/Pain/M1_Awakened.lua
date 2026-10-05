local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
game:GetService("TweenService")
local _ = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Pain").M1_Awakened.Assets
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

local function areShiftedColorsEqual(player, childName: string, color: Color3, color2: Color3, color3: Color3)
	local child = player:FindFirstChild(childName)

	if child == nil then
		return false
	end

	local shifted = child:FindFirstChild("Shifted")

	if shifted == nil then
		return false
	end

	local shifted_Color1 = shifted:GetAttribute("Shifted_Color1")
	local shifted_Color2 = shifted:GetAttribute("Shifted_Color2")
	local shifted_Color3 = shifted:GetAttribute("Shifted_Color3")

	if shifted_Color1 == nil or shifted_Color2 == nil or shifted_Color3 == nil then
		return false
	end

	return color == shifted_Color1 and color2 == shifted_Color2 and color3 == shifted_Color3
end

local function applyColorShiftHSV(color: Color3, p: number, p2: number, p3: number)
	local v = math.max(1, color.R, color.G, color.B)
	local v2 = math.floor(color.R / v * 255) % 256
	local v3 = math.floor(color.G / v * 255) % 256
	local v4 = math.floor(color.B / v * 255) % 256
	local HSV, v5, v6 = Color3.fromRGB(v2, v3, v4):ToHSV()
	local v7 = (HSV + p) % 1
	local v8 = math.clamp(v5 * p2, 0, 1)
	local v9 = math.clamp(v6 * p3, 0, 1)
	return Color3.fromHSV(v7, v8, v9 * v)
end

local function ParticleState(folder, enabled: boolean)
	local max = 0

	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if enabled == true or enabled == false then
			emitter.Enabled = enabled
		else
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end

		if not (emitter.Lifetime.Max <= max) then
			max = emitter.Lifetime.Max
		end
	end

	return max
end

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

Random.new()

local function Weld(parent, part, C0)
	local manualWeld = Instance.new("ManualWeld", parent)

	if C0 then
		manualWeld.C0 = C0
	else
		manualWeld.C0 = parent.CFrame:inverse() * part.CFrame
	end

	manualWeld.Part0 = parent
	manualWeld.Part1 = part
	manualWeld.Parent = parent
	return manualWeld
end

return function(player)
	local origin = player.origin
	local player2 = player.player or player.Player

	if (currentCamera.CFrame.p - origin).Magnitude > 1300 then
		return
	end

	local combo = player.Combo
	local _ = player.Character
	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, player2, "PainFruitVFXColor")
	game.Debris:AddItem(folder, 5)
	local root = player.Root
	local cFrame = root.CFrame

	if combo == 1 then
		local clone = assets.Phase1.Slash:Clone()
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, folder, player2, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			player2,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 146, 220),
			Color3.fromRGB(128, 183, 255),
			Color3.fromRGB(85, 170, 255)
		) then
			Util.AdjustObjectDescendantsColors(clone, function(_, p)
				if math.random() > 0.5 then
					p = applyColorShiftHSV(p, 0.7076380848884583, 1.165137614678899, 1) or p
				end

				return p
			end)
		end

		if areShiftedColorsEqual(
			player2,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone, function(_, p)
				if math.random() > 0.5 then
					p = applyColorShiftHSV(p, 0.41666667, 1.165137614678899, 1) or p
				end

				return p
			end)
		end

		Util.Debris:AddItem(clone, 1)
		Util.Sound:Play("M1_SideSwipe_Awakened_01_V1", root)
		local manualWeld = Instance.new("ManualWeld", root)
		manualWeld.C0 = root.CFrame:inverse() * clone.CFrame
		manualWeld.Part0 = root
		manualWeld.Part1 = clone
		manualWeld.Parent = root

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end
	elseif combo == 2 then
		local clone = assets.Phase2.Slash:Clone()
		clone.CFrame = cFrame * CFrame.Angles(0, 0, 3.141592653589793)
		Util.SetParentOverrideWithColor(clone, folder, player2, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			player2,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 146, 220),
			Color3.fromRGB(128, 183, 255),
			Color3.fromRGB(85, 170, 255)
		) then
			Util.AdjustObjectDescendantsColors(clone, function(_, p)
				if math.random() > 0.5 then
					p = applyColorShiftHSV(p, 0.7076380848884583, 1.165137614678899, 1) or p
				end

				return p
			end)
		end

		if areShiftedColorsEqual(
			player2,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone, function(_, p)
				if math.random() > 0.5 then
					p = applyColorShiftHSV(p, 0.41666667, 1.165137614678899, 1) or p
				end

				return p
			end)
		end

		Util.Debris:AddItem(clone, 1)
		Util.Sound:Play("M1_SideSwipe_Awakened_02_V1", root)
		local manualWeld = Instance.new("ManualWeld", root)
		manualWeld.C0 = root.CFrame:inverse() * clone.CFrame
		manualWeld.Part0 = root
		manualWeld.Part1 = clone
		manualWeld.Parent = root

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end
	elseif combo == 3 then
		local clone = assets.Phase3.Slash:Clone()
		clone.CFrame = cFrame * CFrame.new(0, 1, -3) * CFrame.Angles(0, 0, -1.5707963267948966)
		Util.SetParentOverrideWithColor(clone, folder, player2, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			player2,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 146, 220),
			Color3.fromRGB(128, 183, 255),
			Color3.fromRGB(85, 170, 255)
		) then
			Util.AdjustObjectDescendantsColors(clone, function(_, p)
				if math.random() > 0.5 then
					p = applyColorShiftHSV(p, 0.7076380848884583, 1.165137614678899, 1) or p
				end

				return p
			end)
		end

		if areShiftedColorsEqual(
			player2,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone, function(_, p)
				if math.random() > 0.5 then
					p = applyColorShiftHSV(p, 0.41666667, 1.165137614678899, 1) or p
				end

				return p
			end)
		end

		Util.Debris:AddItem(clone, 1)
		Util.Sound:Play("M1_Uppercut_Awakened_0" .. tostring(math.random(1, 2)) .. "_V1", root)
		local manualWeld = Instance.new("ManualWeld", root)
		manualWeld.C0 = root.CFrame:inverse() * clone.CFrame
		manualWeld.Part0 = root
		manualWeld.Part1 = clone
		manualWeld.Parent = root

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end

		local clone2 = assets.Phase3.SpinTrail:Clone()
		clone2.CFrame = cFrame * CFrame.Angles(-1.3962634015954636, 0, 0)
		Util.SetParentOverrideWithColor(clone2, folder, player2, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			player2,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 146, 220),
			Color3.fromRGB(128, 183, 255),
			Color3.fromRGB(85, 170, 255)
		) then
			Util.AdjustObjectDescendantsColors(clone2, function(_, p)
				if math.random() > 0.5 then
					p = applyColorShiftHSV(p, 0.7076380848884583, 1.165137614678899, 1) or p
				end

				return p
			end)
		end

		if areShiftedColorsEqual(
			player2,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone2, function(_, p)
				if math.random() > 0.5 then
					p = applyColorShiftHSV(p, 0.41666667, 1.165137614678899, 1) or p
				end

				return p
			end)
		end

		clone2.Anchored = false
		clone2.Weld.Part1 = root
		clone2.Weld.C1 = CFrame.new(0, 0, 0) * CFrame.Angles(-1.3962634015954636, 0, 0)
		task.delay(0.2, function()
			clone2.Weld.Enabled = false
			clone2.Anchored = true

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
	elseif combo == 4 then
		local clone = assets.Phase4.Barrage:Clone()
		clone.CFrame = cFrame * CFrame.new(0, 1, -3)
		Util.SetParentOverrideWithColor(clone, folder, player2, "PainFruitVFXColor")

		if areShiftedColorsEqual(
			player2,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 146, 220),
			Color3.fromRGB(128, 183, 255),
			Color3.fromRGB(85, 170, 255)
		) then
			Util.AdjustObjectDescendantsColors(clone, function(_, p)
				if math.random() > 0.5 then
					p = applyColorShiftHSV(p, 0.7076380848884583, 1.165137614678899, 1) or p
				end

				return p
			end)
		end

		if areShiftedColorsEqual(
			player2,
			"PainFruitVFXColor",
			Color3.fromRGB(255, 252, 55),
			Color3.fromRGB(95, 95, 14),
			Color3.fromRGB(255, 255, 112)
		) then
			Util.AdjustObjectDescendantsColors(clone, function(_, p)
				if math.random() > 0.5 then
					p = applyColorShiftHSV(p, 0.41666667, 1.165137614678899, 1) or p
				end

				return p
			end)
		end

		Util.Debris:AddItem(clone, 1)
		Util.Sound:Play("M1_MidairBarrage_Awakened_06_V1", root)
		task.spawn(function()
			local v = tick() + 0.9

			while tick() < v and clone:IsDescendantOf(workspace) do
				clone.CFrame = root.CFrame * CFrame.new(math.random(-8, 8), math.random(-1, 1), -math.random(1, 8))
				task.wait()
			end
		end)
		local v = tick() + 0.65

		repeat
			for _ = 1, 2 do
				clone.CFrame = root.CFrame * CFrame.new(math.random(-10, 10), math.random(-1, 1), -math.random(1, 10)) * CFrame.Angles(
					0,
					0,
					-math.rad(70 + math.random(-70, 70))
				)
				clone.Attachment5.WorldPosition = root.CFrame * createVector(0, 0, -10)

				for _, emitter in pairs(clone:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v2 = emitter
					task.spawn(function()
						v2:Emit(v2:GetAttribute("EmitCount"))
					end)
				end

				task.wait(0.015)
			end

			task.wait(0.03)
		until v - tick() <= 0
	end
end