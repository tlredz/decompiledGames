local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local step = FX:WaitForChild("DracoRace").Step
local debris = Util.Debris
local _ = Util.Sound
local rock2 = Util.Rock2

local function charInRange(vector2: Vector3, p: number)
	local character = game.Players.LocalPlayer.Character
	local humanoidRootPart = character ~= nil and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local magnitude = (humanoidRootPart.Position - vector2).magnitude

		if magnitude <= p then
			return magnitude
		end
	end

	return false
end

return function(player)
	local ID = player.ID
	local cFrame = player.CFrame
	local v = 1

	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local hrpSizeScale = player.Character:FindFirstChild("HumanoidRootPart"):GetAttribute("HrpSizeScale")
		v *= player.Character.HumanoidRootPart.Size.Z * (hrpSizeScale and hrpSizeScale.Y or 1)
	end

	local player2 = player.player

	if ID == 1 then
		Util.Sound:Play("ElectricShot", cFrame.Position, nil, 2, 0.5)
		Util.Sound:Play("Soru", cFrame.Position, nil, 1.6, 0.3)
		local ray, _, _ = Util.Ray(
			cFrame.p + createVector(0, 1, 0),
			createVector(-0, -10, -0) * v,
			{ workspace.Characters, workspace.Enemies },
			false
		)
		local clone = step.MeteorRise:Clone()
		Util.ResizeModel(clone, v, clone.Position)
		debris:AddItem(clone, 4)
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player2, "DracoRaceVFXColors", true)
		Util.SyncColorsOnChange(clone, player2, "DracoRaceVFXColors")
		local descendants = clone:GetDescendants()

		for _, emitter in ipairs(descendants) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter:Emit(emitter:GetAttribute("EmitCount"))

			if emitter.Name == "Flames" and ray then
				emitter.Enabled = true
			end
		end

		if ray then
			task.delay(1, function()
				local flames = clone:FindFirstChild("Flames")

				if flames and flames:IsDescendantOf(workspace) then
					flames.Enabled = false
				end
			end)
		end
	elseif ID == 2 then
		local ray, v2, v3 = Util.Ray(
			cFrame.p + createVector(0, 1, 0),
			createVector(-0, -10, -0) * v,
			{ workspace.Characters, workspace.Enemies },
			false
		)
		local v4 = v3 == Vector3.new() and createVector(0, 1, 0) or v3
		local clone = step.Impact:Clone()
		Util.ResizeModel(clone, v, clone.Position)
		debris:AddItem(clone, 5)
		clone.CFrame = CFrame.new(v2, v2 + v4) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
			0,
			math.rad((math.random(0, 360))),
			0
		)
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player2, "DracoRaceVFXColors", true)
		Util.SyncColorsOnChange(clone, player2, "DracoRaceVFXColors")

		for _, emitter in pairs(clone.General:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		for _, emitter in pairs(clone.RaisedAttach:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		if ray then
			Util.Sound:Play("GroundExplosion", v2, nil, 1.3, 0.5)

			for _, emitter in pairs(clone.FloorAttach:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local v5 = v * 10
			local v6 = math.floor(math.random(8, 10) * ((v - 1) / 3 + 1))
			local v7 = v2 + createVector(0, 1, 0)

			for i = 1, v6 do
				local v8 = 360 / v6 * i
				local v9 = CFrame.new(v7, v7 + v4 * 2) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
					0,
					math.rad(v8),
					0
				) * CFrame.new(0, 0, -v5)
				local ray2, v10, v11 = Util.Ray(
					v9.Position,
					v9.upVector.Unit * -30,
					{ workspace.Characters, workspace.Enemies },
					false
				)

				if not ray2 then
					continue
				end

				local v12 = rock2.new({
					FadeIn = { 0.2, 0.3 },
					Lifetime = math.random(5, 8) / 10,
					FadeOut = { 0.3, 0.5 },
					Size = Vector3.new(math.random(2, 3), 2, math.random(2, 3)) * v,
					Scale = { 1, 1.5 }
				})
				v12:Spawn(CFrame.new(v10, v10 + v11) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(0, 0, 0))

				if not (math.random(1, 100) <= 25) then
					continue
				end

				v12.Type = "Flying"
				v12:Eject({
					Velocity = v9.UpVector * (workspace.Gravity / 2 + math.random(-10, 20)) + v12.Part.CFrame.lookVector * math.random(
						5,
						10
					),
					RotVelocity = createVector(3.1415927, 3.1415927, 3.1415927)
				})
			end
		end
	end
end