local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
require(game.ReplicatedStorage.Util.RocksModule)
local FX = require(ReplicatedStorage.FX)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local mammoth = FX:WaitForChild("Mammoth")

local function run(character, rootPart, holdValue)
	local mammoth2 = character:FindFirstChild("Mammoth").Mammoth
	local children = mammoth2:GetChildren()

	local function lightup()
		for _, part in pairs(children) do
			if not (part:IsA("MeshPart") and (part.Name == "Plane.010" or part.Name:find("Crystal") or part.Name:find("ArmorBlue"))) then
				continue
			end

			local tween = TweenService:Create(
				part,
				TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					Color = Color3.fromRGB(255, 255, 255)
				}
			)
			tween:Play()
			local v2 = part
			task.spawn(function()
				task.wait(0.05)

				if tween.PlaybackState == Enum.PlaybackState.Cancelled then
					return
				end

				local tween2 = TweenService:Create(
					v2,
					TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						Color = Color3.fromRGB(255, 57, 57)
					}
				)
				tween2:Play()
				task.wait(0.1)

				if tween2.PlaybackState == Enum.PlaybackState.Cancelled then
					return
				end

				TweenService:Create(v2, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					Color = Color3.fromRGB(112, 22, 22)
				}):Play()
			end)
		end
	end

	local function lightoff()
		for _, part in pairs(children) do
			if not (part:IsA("MeshPart") and (part.Name == "Plane.010" or part.Name:find("Crystal") or part.Name:find("ArmorBlue"))) then
				continue
			end

			TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Color = Color3.fromRGB(13, 105, 172)
			}):Play()
		end
	end

	lightup()
	Util.Sound:Play("MammothRunStart", rootPart.Position, nil, 1 + math.random(-5, 5) / 100, 1.5)
	local v = Util.Sound:Play("MammothRun", rootPart, 15, 1, 1.5)
	local body4002 = character:FindFirstChild("Mammoth").Mammoth["body4.002"]
	task.spawn(function()
		local children2 = body4002.runemitstart:GetChildren()
		local v2 = {}

		for k, v3 in pairs(children2) do
			v2[k] = {
				count = v3:GetAttribute("EmitCount") or 0,
				delay = v3:GetAttribute("EmitDelay") or 0
			}
		end

		for k, v3 in pairs(children2) do
			if not v2[k] then
				continue
			end

			if v2[k].delay > 0 then
				local v4 = k
				local v5 = v3
				task.spawn(function()
					task.wait(v2[v4].delay)
					v5:Emit(v2[v4].count)
				end)
			else
				v3:Emit(v2[k].count)
			end
		end
	end)
	body4002.Parent.exp.Size = createVector(66.202, 7.679, 61.044)
	task.wait(0.15)
	task.spawn(function()
		task.wait(0.07)

		while holdValue.Value and holdValue:IsDescendantOf(workspace) do
			for _, child in pairs(body4002.runemit:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			for _, child in pairs(body4002.runemit2:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			for _, child in pairs(body4002.runemit3:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			for _, child in pairs(body4002.runemit3:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			task.wait(0.208)
		end
	end)
	task.spawn(function()
		local children2 = body4002.Dust:GetChildren()

		while holdValue.Value and holdValue:IsDescendantOf(workspace) do
			local lookVector = rootPart.CFrame.LookVector
			local v2 = rootPart.Position + lookVector * 1
			local rayMap, _, _ = Util.RayMap(v2, createVector(0, -15, 0))

			if rayMap then
				for _, v3 in pairs(children2) do
					v3:Emit(v3:GetAttribute("EmitCount"))
				end
			end

			task.wait(0.208)
		end
	end)

	local function stomp(p)
		local clone = mammoth.footstep:Clone()

		if character == game.Players.LocalPlayer.Character then
			Util.CameraShaker:ShakeOnce(0.7, 6, 0.1, 0.3, createVector(2, 3, 2), createVector(3, 2, 3))
		end

		Util.Debris:AddItem(clone, 2)
		local rightVector = character.PrimaryPart.CFrame.RightVector
		local v2 = rootPart.Position + rightVector * p
		local rayMap, v3, v4 = Util.RayMap(v2, createVector(0, -15, 0))

		if rayMap then
			local v5 = v3 + createVector(0, 0.1, 0)
			clone.CFrame = CFrame.new(v5, v5 + v4) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone.Parent = _WorldOrigin

			local function groundEffects(_, rayMap2)
				if rayMap2 then
					body4002.Dust.Dust1.Color = ColorSequence.new(rayMap2.Color)
					body4002.Dust.Rocks.Color = ColorSequence.new(rayMap2.Color)
					clone.drop.Smoke.Color = ColorSequence.new(rayMap2.Color)

					for _, child in pairs(clone.drop:GetChildren()) do
						child:Emit((child:GetAttribute("EmitCount") or 1) * 0.55)
					end
				end
			end

			groundEffects(v5, rayMap)
		end
	end

	body4002.aura1.Rate = 110
	body4002.aura2.Rate = 110
	body4002.aura.aura3.Enabled = true
	body4002.aura1.Enabled = true
	body4002.aura2.Enabled = true
	body4002.Parent.exp.FR2.Enabled = true
	body4002.Parent.exp.FR3.Enabled = true

	for _, child in pairs(body4002.Parent.exp.beams3:GetChildren()) do
		child.Enabled = true
		TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Width1 = 13.799,
			Width0 = 3.067
		}):Play()
	end

	for _, child in pairs(body4002.Parent.exp.beams2:GetChildren()) do
		child.Enabled = true
		TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Width1 = 22.999,
			Width0 = 3.067
		}):Play()
	end

	for _, child in pairs(body4002.Parent.exp.beams1:GetChildren()) do
		child.Enabled = true
		TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Width1 = 0,
			Width0 = 18.399
		}):Play()
	end

	task.wait(0.07)

	while holdValue.Value and holdValue:IsDescendantOf(workspace) do
		stomp(-7)
		task.wait(0.148)

		if holdValue.Value and holdValue:IsDescendantOf(workspace) then
			stomp(7)
			task.wait(0.108)
		else
			break
		end
	end

	Util.Sound:FadeOut(v, 0.3)
	Util.Sound:Play("MammothDebris", rootPart.Position, nil, 1 + math.random(-5, 5) / 100, 1.5)
	Util.Sound:Play("MammothRunEnd", rootPart.Position, 15, 1 + math.random(-5, 5) / 100, 1.5)
	local lookVector = rootPart.CFrame.LookVector
	local v2 = rootPart.Position + lookVector * 1
	local rayMap, _, _ = Util.RayMap(v2, createVector(0, -80, 40))

	if rayMap then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function groundEffects(_, rayMap2)
			if rayMap2 then
				task.wait(0.12)
				body4002.SmokeFront.Smoke.Color = ColorSequence.new(rayMap2.Color)
				body4002.SmokeFront.Smoke:Emit(60)
			end
		end

		groundEffects(nil, rayMap) -- equivalent call inferred; original call site unknown
	end

	task.wait(0.12)
	lightoff()

	for _, child in pairs(mammoth2.exp.beams3:GetChildren()) do
		TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Width1 = 0,
			Width0 = 0
		}):Play()
	end

	for _, child in pairs(mammoth2.exp.beams2:GetChildren()) do
		TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Width1 = 0,
			Width0 = 0
		}):Play()
	end

	for _, child in pairs(mammoth2.exp.beams1:GetChildren()) do
		TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			Width1 = 0,
			Width0 = 0
		}):Play()
	end

	body4002.aura.aura3.Enabled = false
	body4002.aura1.Enabled = false
	body4002.aura2.Enabled = false
	body4002.Parent.exp.FR2.Enabled = false
	body4002.Parent.exp.FR3.Enabled = false
	body4002.Dust.Dust1.Enabled = false
	body4002.Dust.Rocks.Enabled = false
end

return function(player)
	local rootPart = player.RootPart or nil
	local character = player.Character or nil
	local holdValue = player.HoldValue

	if (rootPart.Position - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
		return
	end

	run(character, rootPart, holdValue)
end