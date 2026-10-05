local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local diamondV = FX:WaitForChild("Diamond").DiamondV
local _WorldOrigin = workspace._WorldOrigin
local random = Random.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

local function ParticleState(folder, enabled, p)
	for _, effect in pairs(folder:GetDescendants()) do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if p and effect:GetAttribute("Color") == true then
			effect.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			effect:Emit(effect:GetAttribute("EmitCount"))
		else
			effect.Enabled = enabled
		end
	end
end

local function Sin(p)
	return (math.sin((math.rad(p))))
end

local function Cos(p)
	return (math.cos((math.rad(p))))
end

return function(data)
	local origin = data.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 700 then
		return
	end

	local stage = data.Stage
	local player = data.Player

	if stage == 1 then
		local hitbox = data.Hitbox
		local fireRate = data.FireRate
		local mirrorCount = data.MirrorCount
		local beamSpeed = data.BeamSpeed
		local maxHoldTime = data.MaxHoldTime
		local HRP = data.HRP
		local folder = Instance.new("Folder")
		folder.Name = data.ProxyName
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "DiamondFruitVFXColor")
		folder:SetAttribute("CurrentIndex", 0)
		Util.Debris:AddItem(folder, maxHoldTime + 4)
		local clone = diamondV.Light:Clone()
		clone.Position = HRP.Position
		Util.SetParentOverrideWithColor(clone, folder, player, "DiamondFruitVFXColor")
		local _ = data.StartCFrame
		sound:Play("DIAMOND_Prismatic_Activation_01", origin)
		local clones = {}

		for i = 1, mirrorCount do
			local clone2 = diamondV.Shard:Clone()
			clone2.Position = HRP.Position
			clone2.Orientation = Vector3.new(
				random:NextNumber(0, 360),
				random:NextNumber(0, 360),
				random:NextNumber(0, 360)
			)
			clone2.Name = "Mirror_" .. tostring(i)
			local size = clone2.Size * random:NextNumber(0.8, 1.4)
			clone2.Size = createVector(0, 0, 0)
			TweenService:Create(
				clone2,
				TweenInfo.new(random:NextNumber(0.2, 1), Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{
					Size = size
				}
			):Play()
			Util.SetParentOverrideWithColor(clone2, folder, player, "DiamondFruitVFXColor")
			local number = random:NextNumber(0, 360)
			local number2 = random:NextNumber(-15, 15)
			local number3 = random:NextNumber(0, 360)
			local number4 = random:NextNumber(40, 70)
			local number5 = random:NextNumber(5, 12)
			local number6 = random:NextNumber(0, hitbox.Y)
			local number7 = random:NextNumber(hitbox.X / 4, hitbox.X / 2)
			local number8 = random:NextNumber(0.2, 2)
			local tweenInfo = TweenInfo.new(number8, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			local position = clone.Position
			local v4 = math.sin((math.rad(number))) * number7
			local v5 = number6 + math.sin((math.rad(number3))) ^ 2 * number5
			TweenService:Create(clone2, tweenInfo, {
				CFrame = CFrame.lookAt(
					position + Vector3.new(v4, v5, math.cos((math.rad(number))) * number7),
					clone.Position
				)
			}):Play()
			task.delay(number8, function()
				local heartbeatConnection = nil
				heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					if clone2.Transparency == 1 then
						heartbeatConnection:Disconnect()
					end

					number += number2 * dt
					number3 += number4 * dt
					clone2.CFrame = CFrame.lookAt(
						clone.Position + Vector3.new(
							math.sin((math.rad(number))) * number7,
							number6 + math.sin((math.rad(number3))) ^ 2 * number5,
							math.cos((math.rad(number))) * number7
						),
						clone.Position
					)
				end)
			end)
			table.insert(clones, clone2)
		end

		local started = data.Started
		local started2 = data.Started
		sound:Play("DIAMOND_PrismaticAttack_01_V2", origin)

		while true do
			local cFrame = clones[random:NextInteger(1, #clones)].CFrame

			if maxHoldTime <= Util.MasterClock:GetTime() - started2 then
				break
			end

			if not (fireRate < Util.MasterClock:GetTime() - started) then
				continue
			end

			started = Util.MasterClock:GetTime()
			local integer = random:NextInteger(3, 7)
			local integer2 = random:NextInteger(1, #clones)
			folder:SetAttribute("CurrentIndex", integer2)
			local v = integer2

			for i = 1, integer do
				while integer2 == v do
					v = random:NextInteger(1, #clones)
				end

				local clone2 = diamondV.Start:Clone()
				local clone3 = diamondV.End:Clone()
				clone2.CFrame = i == 1 and cFrame or clones[integer2].CFrame
				clone3.CFrame = clone2.CFrame
				Util.SetParentOverrideWithColor(clone2, folder, player, "DiamondFruitVFXColor")
				Util.SetParentOverrideWithColor(clone3, folder, player, "DiamondFruitVFXColor")

				for _, beam in clone2:GetDescendants() do
					if not beam:IsA("Beam") then
						continue
					end

					beam.Attachment0 = clone2.beam1
					beam.Attachment1 = clone3.beam2
				end

				local position = clones[v].Position
				local magnitude = (position - clone2.Position).Magnitude
				TweenService:Create(clone3, TweenInfo.new(magnitude / beamSpeed, Enum.EasingStyle.Linear), {
					Position = position
				}):Play()
				task.wait(magnitude / beamSpeed)
				local folder2 = clone2
				task.delay(random:NextNumber(0.05, 0.15), function()
					for i2, beam in folder2:GetDescendants() do
						if not beam:IsA("Beam") then
							continue
						end

						TweenService:Create(
							beam,
							TweenInfo.new(random:NextNumber(0.07, 0.2), Enum.EasingStyle.Linear),
							{
								Width0 = 0,
								Width1 = 0
							}
						):Play()
						task.delay(0.3, beam.Destroy, beam)
					end
				end)
				local clone4 = diamondV.LazarModel:Clone()
				local lazerHit = clone4.LazerHit
				clone4:ScaleTo(random:NextNumber(0.3, 1.5))
				lazerHit.Position = clone3.Position
				Util.SetParentOverrideWithColor(clone4, folder, player, "DiamondFruitVFXColor")
				ParticleState(lazerHit)
				folder:SetAttribute("CurrentIndex", v)
				integer2 = v
			end
		end

		task.spawn(function()
			for _, v in clones do
				v.Transparency = 1
				v.CanCollide = false
				v.Anchored = false
				local clone2 = diamondV.Break:Clone()
				clone2.Position = v.Position
				Util.SetParentOverrideWithColor(clone2, folder, player, "DiamondFruitVFXColor")
				ParticleState(clone2)
				task.wait(random:NextNumber(0.015, 0.03))
			end
		end)
	elseif stage == 2 then
		local child = _WorldOrigin:FindFirstChild(data.ProxyName)

		if not child then
			return
		end

		local target = data.Target
		local child2 = child:FindFirstChild("Mirror_" .. tostring(child:GetAttribute("CurrentIndex")))
		local clone = diamondV.Explosion:Clone()
		clone.Position = target.HumanoidRootPart.Position
		Util.SetParentOverrideWithColor(clone, child, player, "DiamondFruitVFXColor")
		ParticleState(clone)
		local clone2 = diamondV.Start:Clone()
		local clone3 = diamondV.End:Clone()
		clone3.Anchored = false

		for _, beam in clone2:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Attachment0 = clone2.beam1
			beam.Attachment1 = clone3.beam2
		end

		clone2.Position = child2.Position
		clone3.Weld.Part0 = target.HumanoidRootPart
		Util.SetParentOverrideWithColor(clone2, child, player, "DiamondFruitVFXColor")
		Util.SetParentOverrideWithColor(clone3, child, player, "DiamondFruitVFXColor")
		sound:Play("DIAMOND_PrismaticHit_0" .. tostring(math.random(1, 7)), clone.Position)

		for _, beam in clone2:GetDescendants() do
			if not beam:IsA("Beam") then
				continue
			end

			TweenService:Create(beam, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
				Width0 = 0,
				Width1 = 0
			}):Play()
			task.delay(0.1, beam.Destroy, beam)
		end
	end
end