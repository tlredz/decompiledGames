local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))

local function RecolorControlColor(player, color: Color3)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return Util.WrapColor3Constructor(color, player, "ControlFruitVFXColor")
	end

	return color
end

local function MapRay(vector2: Vector3, vector3: Vector3)
	return workspace:FindPartOnRayWithWhitelist(Ray.new(vector2, vector3), { workspace.Map })
end

local function LerpNumber(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

local function CalculateCurve(vector2: Vector3, vector3: Vector3)
	return 0.6666666666666666 * (vector3 - vector2).Magnitude
end

function CalculateRadius(p: number, p2: number)
	return p * math.sin(3.141592653589793 * p2) ^ 0.3
end

local v = {}

local function ScaleParticle(dust, p: number)
	if not v[dust] then
		v[dust] = { dust.Size.Keypoints, dust.Speed }
	end

	local v2 = v[dust][1]
	local v3 = v[dust][2]
	local numberSequenceKeypoints = {}

	for _, v4 in ipairs(v2) do
		local v5 = math.abs(v4.Value * p)
		local v6 = math.abs(v5 < v4.Envelope and v5 or v4.Envelope)
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v4.Time, v5, v6))
	end

	dust.Speed = NumberRange.new(v3.Min * p, v3.Max * p)
	return NumberSequence.new(numberSequenceKeypoints)
end

local v2 = {
	Brightness = 0.1,
	Contrast = 0.25,
	TintColor = Color3.fromRGB(164, 189, 255),
	Saturation = 0
}
local _ = {
	DustCloud = createVector(0.121, 0.125, 0.18),
	SpikyWind = createVector(0.00375, 0.0075, 0.00375),
	WindFlare = createVector(0.005, 0.01, 0.005)
}
local lighting = game.Lighting
local currentCamera = workspace.CurrentCamera
local _WorldOrigin = workspace._WorldOrigin
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage2:WaitForChild("FX"))
local controlRework = FX:WaitForChild("ControlRework")
local Effect = require(ReplicatedStorage2.Effect)
local Tween = require(ReplicatedStorage2.Util.Tween)
local Sound = require(ReplicatedStorage2.Util.Sound)
local Spring = require(ReplicatedStorage2.Util.Spring)
local v3 = {}

local function FindNodeByPlayer(p)
	local v4 = {}

	for _, v5 in ipairs(v3) do
		if v5.Player == p then
			table.insert(v4, v5)
		end
	end

	return #v4 > 0 and v4 or nil
end

RunService:BindToRenderStep(script.Parent.Name .. "-" .. script.Name, Enum.RenderPriority.Last.Value - 1000, function(p)
	local now = tick()
	local v4 = 6.283185307179586 * (now % 1)
	local flag = false
	local player = nil

	for i = #v3, 1, -1 do
		local v5 = v3[i]
		local lifetime = now - v5.Start

		if not (v5.Tag and v5.Tag:IsDescendantOf(workspace)) then
			v5.DestroyOpePls = true
		end

		local p2 = v5.PlayerSession.Room.CFrame.p
		local radius = v5.PlayerSession.Room.Radius
		local maxRadius = v5.PlayerSession.Room.MaxRadius

		if (v5.DestroyOpePls or not (v5.PlayerSession and v5.Character and v5.Character:GetAttribute("ControlRoomActive"))) and not v5.Destroy then
			Sound:Play("CTRLFRT_Z_Disable_Room_0" .. tostring(math.random(1, 4)), p2, v5.Radius / 6, 1)
			v5.Destroy = now
			v5.Lifetime = lifetime

			if v5.SoundInit then
				Util.Sound:FadeOut(v5.SoundInit, 0.5)
			end
		end

		if v5.Destroy and now - v5.Destroy > v5.FadeOut then
			v5.Globe:Destroy()

			if v5.Spiky2 then
				v5.Spiky2:Destroy()
			end

			if v5.Spiky then
				v5.Spiky:Destroy()

				for _, v7 in ipairs(v5.Cache) do
					if not v7.Part.Parent then
						continue
					end

					v[v7.Part.Dust] = nil
					v7.Part:Destroy()
				end
			end

			table.remove(v3, i)
		else
			v5.Spring:SetGoal(radius)
			v5.Spring:Update(p)
			local position = v5.Spring:GetPosition()
			v5.Spring2:SetGoal(p2)
			v5.Spring2:Update(p)
			local position2 = v5.Spring2:GetPosition()
			local v7 = v5.Destroy ~= nil
			local _ = position / maxRadius
			local v8 = position * 2 * (math.sin(os.clock() * 2.0943951023931953) * 0.01 + 1)
			local transparency = v7 and Tween.ease["in"].sine(math.min(now - v5.Destroy, v5.FadeOut), 0, 1, v5.FadeOut) or Tween.ease.outin.circ(
				math.min(lifetime, 0.5),
				1,
				-1,
				0.5
			)

			if v7 then
				v8 *= 1 - transparency * 0.1
			end

			local v10 = 0.5 - math.sqrt((v5.Origin.Y - v5.DustOrigin.Y) ^ 2) / v8
			local v11 = CalculateRadius(v8 * 1.1, v10)
			local v12 = #v5.Cache

			for _, v13 in ipairs(v5.Cache) do
				v13.Scale = createVector(0.121, 0.125, 0.18) * v8 / (v12 - 2) * (v10 + 0.5)
			end

			local v13 = v8 / 4 * (v10 + 0.5)
			v5.Radius = v8

			if v5.SoundInit and v5.Sound and not v5.PlayerSession.Room.Active then
				local volume = math.clamp(1 - (position2 - currentCamera.CFrame.p).Magnitude / (v8 * 1.25), 0.1, 1)

				if volume > 0 then
					if v5.SoundInit:GetAttribute("Ready") then
						v5.SoundInit.Volume = volume * 0.5
					end

					v5.Sound.Volume = volume
				end
			end

			if not v5.PlayerSession.Room.Active and now - v5.LastShake > 0.2 then
				local v14 = 1 - (position2 - currentCamera.CFrame.p).Magnitude / (v8 * 1.25)

				if v14 > 0 then
					Effect.new("ShakeCam"):replicate({
						10 * v14,
						10 * v14,
						0,
						0.9,
						createVector(0.25, 0.25, 0),
						createVector(0, 0, 1)
					})
				end

				v5.LastShake = now
			end

			v5.Globe.A.CFrame = CFrame.new(0, 0, v8 * -0.5)
			v5.Globe.B.CFrame = CFrame.new(0, 0, v8 * 0.5)
			local position3 = v5.Globe.A.Position
			local curveSize = 0.6666666666666666 * (v5.Globe.B.Position - position3).Magnitude
			v5.Globe.AB.CurveSize0 = curveSize
			v5.Globe.BB.CurveSize0 = -curveSize
			v5.Globe.AB.CurveSize1 = -curveSize
			v5.Globe.BB.CurveSize1 = curveSize
			local v15 = v5.Radius / 10
			v5.Globe.AB.Width0 = v15 * (not v7 and 1 or 1 - transparency or 1)
			v5.Globe.BB.Width0 = v15 * (not v7 and 1 or 1 - transparency or 1)
			v5.Globe.AB.Width1 = v15 * (not v7 and 1 or 1 - transparency or 1)
			v5.Globe.BB.Width1 = v15 * (not v7 and 1 or 1 - transparency or 1)
			local lastBeamTransparency = transparency + 0.35

			if not v5.LastBeamTransparency or math.abs(lastBeamTransparency - v5.LastBeamTransparency) > 0.004 then
				local numberSequence = NumberSequence.new(lastBeamTransparency)
				v5.Globe.AB.Transparency = numberSequence
				v5.Globe.BB.Transparency = numberSequence
				v5.LastBeamTransparency = lastBeamTransparency
			end

			local v17 = math.clamp(math.floor(v8 + 0.5), 24, 100)

			if v17 ~= v5.LastSegments then
				v5.Globe.AB.Segments = v17
				v5.Globe.BB.Segments = v17
				v5.LastSegments = v17
			end

			v5.Globe.Transparency = not v7 and 0.25 or v5.Globe.Transparency + transparency or 0.25
			v5.Globe.Mesh.Scale = createVector(1, 1, 1) * v8 / 40
			v5.Globe.CFrame = CFrame.new(position2)
			v5.Globe.Mesh.Offset = (currentCamera.CFrame.Position - position2).Unit * 0.1
			v5.AnimatedRadius = v8

			if v5.Spiky and v5.Spiky.Parent then
				local v18 = v11 * 1.2
				local v19 = math.sin(v4) ^ 2
				v5.Spiky.CFrame = v5.DustOrigin * CFrame.new(0, (math.abs(v19) * 0.5 + 0.25) * 1, 0) * CFrame.Angles(
					3.141592653589793,
					1 * v4,
					0
				)
				v5.Spiky.Mesh.Scale = createVector(0.00375, 0.0075, 0.00375) * Vector3.new(
					1,
					math.abs(v19) * 0.5 + 0.25,
					1
				) * v18
			end

			if v5.Spiky2 and v5.Spiky2.Parent then
				local v18 = v8 * 1.2
				local v19 = math.sin(v4) ^ 2
				v5.Spiky2.CFrame = v5.Origin * CFrame.new(0, v18 * 0.05 * (math.abs(v19) * 0.5 + 0.25), 0) * CFrame.Angles(
					3.141592653589793,
					2 * v4,
					0
				)
				v5.Spiky2.Mesh.Scale = createVector(0.005, 0.01, 0.005) * Vector3.new(1, math.abs(v19) * 0.5 + 0.1, 1) * v18
			end

			if v5.SpikeFadeTime and now - v5.SpikeFadeTime > v5.FadeOut then
				if v5.Spiky then
					v5.Spiky:Destroy()

					for _, v18 in ipairs(v5.Cache) do
						if not v18.Part.Parent then
							continue
						end

						v[v18.Part.Dust] = nil
						v18.Part:Destroy()
					end
				end

				if v5.Spiky2 then
					v5.Spiky2:Destroy()
				end
			else
				if v5.PlayerSession.Room.Active and not v5.SpikeFadeTime then
					v5.SpikeFadeTime = now
				end

				if v5.SpikeFadeTime then
					transparency = Tween.ease["in"].quad(math.min(now - v5.SpikeFadeTime, v5.FadeOut), 0, 1, v5.FadeOut) or transparency
				end

				if v5.Spiky then
					v5.Spiky.Transparency = transparency
				end

				if v5.Spiky2 then
					v5.Spiky2.Transparency = transparency
				end

				for i2, v18 in ipairs(v5.Cache) do
					v18.Angle = v18.Angle % 6.283185307179586 + v18.Frequency * p
					local v19 = 6.283185307179586 * (i2 / v5.Segments)
					v18.Part.Dust.Enabled = not v5.PlayerSession.Room.Active
					v18.Part.Dust.Size = ScaleParticle(v18.Part.Dust, v13)
					v18.Part.Transparency = transparency
					v18.Part.CFrame = v5.DustOrigin * CFrame.Angles(0, v19 + v4, 0) * CFrame.new(
						0,
						0,
						v11 * 0.05 + v11 / 2
					) * CFrame.Angles(1.0471975511965976, 1.5707963267948966, 0)
					local v20 = math.abs(math.sin(v18.Angle) ^ 2)
					local v21 = math.abs(math.cos(v18.Angle) ^ 3)
					v18.Mesh.Scale = (v18.Scale or Vector3.new()) + (v18.Scale or Vector3.new()) * 0.75 * Vector3.new(
						v20,
						v21,
						1.1
					)
				end
			end

			if v5.AnimatedRadius and (currentCamera.CFrame.p - position2).Magnitude < v5.AnimatedRadius / 2 then
				player = v5.Player
				flag = true
			end

			if v5.WasInCutscene ~= _G.InCutscene then
				if _G.InCutscene then
					if v5.SoundInit then
						Util.Sound:FadeOut(v5.SoundInit, 0.1)
						v5.SoundInit = nil
					end
				elseif v5.SoundInit == nil then
					v5.SoundInit = Sound:Play("CTRLFRT_Z_Room_Idle_Loop_01", v5.Globe, v5.MaxRadius / 6)
				end

				v5.WasInCutscene = _G.InCutscene
			end
		end
	end

	if flag then
		local v5 = lighting:FindFirstChild("OpeGlobe")

		if not v5 then
			v5 = Instance.new("ColorCorrectionEffect")
			v5.Name = "OpeGlobe"
			v5.TintColor = Color3.new(1, 1, 1)
			v5.Brightness = 0
			v5.Contrast = 0
			v5.Saturation = 0
			v5.Parent = lighting
		end

		v5.Enabled = not _G.InCutscene

		if not v2.Start then
			v2.Start = now
			v2.End = nil
		end

		local v6 = math.min(0.25, now - v2.Start) / 0.25

		for k, v7 in pairs(v2) do
			if not (k ~= "Start" and k ~= "End") then
				continue
			end

			if type(v7) == "number" then
				v5[k] = (v7 - 0) * v6 + 0
			elseif typeof(v7) == "Color3" then
				local color = Color3.new(1, 1, 1)

				if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
					v7 = Util.WrapColor3Constructor(v7, player, "ControlFruitVFXColor")
				end

				v5[k] = color:Lerp(v7, v6)
			end
		end
	else
		local opeGlobe = lighting:FindFirstChild("OpeGlobe")

		if opeGlobe then
			opeGlobe.Enabled = not _G.InCutscene

			if not v2.End then
				v2.End = now
				v2.Start = nil
			end

			local v5 = math.min(0.25, now - v2.End) / 0.25

			for k, v6 in pairs(v2) do
				if not (k ~= "Start" and k ~= "End") then
					continue
				end

				if type(v6) == "number" then
					local v7 = opeGlobe[k]
					opeGlobe[k] = v7 + (0 - v7) * v5
				elseif typeof(v6) == "Color3" then
					opeGlobe[k] = opeGlobe[k]:Lerp(Color3.new(1, 1, 1), v5)
				end
			end
		end
	end
end)
local Dome = require(script.Dome)

local function Create(list)
	local character, v4, fadeOut, _ = unpack(list)
	local __Room = v4:FindFirstChild("__Room")

	if not __Room then
		warn("roomTag not found")
		return
	end

	local playerSession = {
		Room = setmetatable({}, {
			__index = function(_, attributeName)
				return __Room:GetAttribute(attributeName)
			end
		})
	}
	local cFrame = playerSession.Room.CFrame
	local radius = playerSession.Room.Radius
	local maxRadius = playerSession.Room.MaxRadius
	local holdDuration = playerSession.Room.HoldDuration
	v4:FindFirstChild("RightHand")
	local clone = controlRework.Domain.Globe:Clone()
	clone.Mesh.VertexColor = createVector(0, 0.55, 1)

	if v4:GetAttribute("ControlVertexColor") then
		clone.Mesh.VertexColor = v4:GetAttribute("ControlVertexColor")
	end

	local vertexColor = clone.Mesh.VertexColor
	local color = Color3.new(vertexColor.X, vertexColor.Y, vertexColor.Z)

	if typeof(character) == "Instance" and character:IsA("Player") and character.Parent then
		color = Util.WrapColor3Constructor(color, character, "ControlFruitVFXColor")
	end

	clone.Mesh.VertexColor = Vector3.new(color.R, color.G, color.B)
	clone.CanQuery = false
	clone.CanTouch = false
	clone.CFrame = cFrame
	clone.Transparency = 1
	clone.AB.Transparency = NumberSequence.new(1)
	clone.BB.Transparency = NumberSequence.new(1)
	clone.AB.Segments = math.max(36, radius * 2)
	clone.BB.Segments = math.max(36, radius * 2)
	Util.SetParentOverrideWithColor(clone, _WorldOrigin, character, "ControlFruitVFXColor")
	local v7 = 0
	Dome({
		Stage = "Start",
		Domain = __Room,
		GetSize = function()
			if not clone:FindFirstChild("Mesh") then
				return v7
			end

			v7 = clone.Mesh.Scale.Y * 40
			return v7
		end,
		GetCFrame = function()
			return CFrame.new(clone.Position)
		end,
		GetGlobe = function()
			if clone.Parent then
				return clone
			end

			return nil
		end,
		Player = character
	})
	local clone2 = controlRework.Domain.WindFlare:Clone()
	clone2.CanQuery = false
	clone2.CanTouch = false
	clone2.Color = Color3.new(1, 1, 1)
	clone2.CFrame = cFrame
	clone2.Mesh.Scale = Vector3.new()
	Util.SetParentOverrideWithColor(clone2, _WorldOrigin, character, "ControlFruitVFXColor")
	local v9 = cFrame.Position + createVector(0, 1, 0)
	local vector2 = Vector3.new(0, -radius / 2 - 1, 0)
	local part, v10, v11 = workspace:FindPartOnRayWithWhitelist(Ray.new(v9, vector2), { workspace.Map })
	local dustOrigin

	if part and part.Transparency < 0.1 then
		dustOrigin = CFrame.new(v10, v10 + v11) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(
			0,
			radius * 0.025,
			0
		)
		local v13 = 0.5 - math.sqrt((cFrame.Y - v10.Y) ^ 2) / radius
		radius = CalculateRadius(radius * 1.1, v13)
		local _ = part.Color
	else
		dustOrigin = cFrame
	end

	local soundInit = Sound:Play("CTRLFRT_Z_Room_Idle_Loop_01", clone, maxRadius / 6)
	local soundDuration = 4 / (1 / (holdDuration * 0.5))
	local sound = Sound:Play("CTRLFRT_Z_Activate_DistantBubbleGrow_02", clone, maxRadius / 6, 1)
	task.delay(1, function()
		if soundInit then
			soundInit:SetAttribute("Ready", true)
		end
	end)
	local v17 = {
		Player = character,
		Character = 0,
		LastShake = 0,
		SoundInit = 0,
		MaxRadius = 0,
		WasInCutscene = 0,
		Sound = 0,
		SoundDuration = 0,
		Spring = 0,
		Spring2 = 0,
		Segments = 12,
		Origin = 0,
		DustOrigin = 0,
		Radius = 0,
		Globe = 0,
		Spiky = nil,
		Spiky2 = 0,
		Cache = 0,
		FadeIn = 0,
		FadeOut = 0,
		PlayerSession = 0,
		Tag = 0,
		Lifetime = 1e999,
		Start = 0
	}

	if character:IsA("Player") then
		character = character.Character or character
	end

	v17.Character = character
	v17.SoundInit = soundInit
	v17.MaxRadius = maxRadius
	v17.WasInCutscene = _G.InCutscene
	v17.Sound = sound
	v17.SoundDuration = soundDuration
	v17.Spring = Spring.new(1.5, 0.75, 0)
	v17.Spring2 = Spring.new(0.8, 4, cFrame.Position)
	v17.Origin = cFrame
	v17.DustOrigin = dustOrigin
	v17.Radius = radius
	v17.Globe = clone
	v17.Spiky2 = clone2
	v17.Cache = {}
	v17.FadeIn = holdDuration
	v17.FadeOut = fadeOut
	v17.PlayerSession = playerSession
	v17.Tag = __Room
	v17.Start = tick()
	table.insert(v3, v17)
end

return Create