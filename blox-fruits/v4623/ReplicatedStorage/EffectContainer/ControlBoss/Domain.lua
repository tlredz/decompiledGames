local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))

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
	local v5 = false

	for i = #v3, 1, -1 do
		local v6 = v3[i]
		local lifetime = now - v6.Start

		if not (v6.Tag and v6.Tag:IsDescendantOf(workspace)) then
			v6.DestroyOpePls = true
		end

		local p2 = v6.PlayerSession.Room.CFrame.p
		local radius = v6.PlayerSession.Room.Radius
		local maxRadius = v6.PlayerSession.Room.MaxRadius

		if (v6.DestroyOpePls or not (v6.PlayerSession and v6.Character and v6.Character:GetAttribute("ControlRoomActive"))) and not v6.Destroy then
			local v8 = 1 / v6.FadeOut
			print(v8, p2, v6.Radius)
			Sound:Play("CTRLFRT_Z_Disable_Room_0" .. tostring(math.random(1, 4)), p2, v6.Radius / 6, 1)
			v6.Destroy = now
			v6.Lifetime = lifetime

			if v6.SoundInit then
				Util.Sound:FadeOut(v6.SoundInit, 0.5)
			end
		end

		if v6.Destroy and now - v6.Destroy > v6.FadeOut then
			v6.Globe:Destroy()

			if v6.Spiky2 then
				v6.Spiky2:Destroy()
			end

			if v6.Spiky then
				v6.Spiky:Destroy()

				for _, v8 in ipairs(v6.Cache) do
					if not v8.Part.Parent then
						continue
					end

					v[v8.Part.Dust] = nil
					v8.Part:Destroy()
				end
			end

			table.remove(v3, i)
		else
			v6.Spring:SetGoal(radius)
			v6.Spring:Update(p)
			local position = v6.Spring:GetPosition()
			v6.Spring2:SetGoal(p2)
			v6.Spring2:Update(p)
			local position2 = v6.Spring2:GetPosition()
			local v8 = v6.Destroy ~= nil
			local _ = position / maxRadius
			local v9 = position * 2 * (math.sin(os.clock() * 2.0943951023931953) * 0.01 + 1)
			local transparency = v8 and Tween.ease["in"].sine(math.min(now - v6.Destroy, v6.FadeOut), 0, 1, v6.FadeOut) or Tween.ease.outin.circ(
				math.min(lifetime, 0.5),
				1,
				-1,
				0.5
			)

			if v8 then
				v9 *= 1 - transparency * 0.1
			end

			local v11 = 0.5 - math.sqrt((v6.Origin.Y - v6.DustOrigin.Y) ^ 2) / v9
			local v12 = CalculateRadius(v9 * 1.1, v11)
			local v13 = #v6.Cache

			for _, v14 in ipairs(v6.Cache) do
				v14.Scale = createVector(0.121, 0.125, 0.18) * v9 / (v13 - 2) * (v11 + 0.5)
			end

			local v14 = v9 / 4 * (v11 + 0.5)
			v6.Radius = v9

			if v6.SoundInit and v6.Sound and not v6.PlayerSession.Room.Active then
				local volume = math.clamp(1 - (position2 - currentCamera.CFrame.p).Magnitude / (v9 * 1.25), 0.1, 1)

				if volume > 0 then
					if v6.SoundInit:GetAttribute("Ready") then
						v6.SoundInit.Volume = volume * 0.5
					end

					v6.Sound.Volume = volume
				end
			end

			if not v6.PlayerSession.Room.Active and now - v6.LastShake > 0.2 then
				local v15 = 1 - (position2 - currentCamera.CFrame.p).Magnitude / (v9 * 1.25)

				if v15 > 0 then
					Effect.new("ShakeCam"):replicate({
						10 * v15,
						10 * v15,
						0,
						0.9,
						createVector(0.25, 0.25, 0),
						createVector(0, 0, 1)
					})
				end

				v6.LastShake = now
			end

			v6.Globe.A.CFrame = CFrame.new(0, 0, v9 * -0.5)
			v6.Globe.B.CFrame = CFrame.new(0, 0, v9 * 0.5)
			local position3 = v6.Globe.A.Position
			local curveSize = 0.6666666666666666 * (v6.Globe.B.Position - position3).Magnitude
			v6.Globe.AB.CurveSize0 = curveSize
			v6.Globe.BB.CurveSize0 = -curveSize
			v6.Globe.AB.CurveSize1 = -curveSize
			v6.Globe.BB.CurveSize1 = curveSize
			local v16 = v6.Radius / 10
			v6.Globe.AB.Width0 = v16 * (not v8 and 1 or 1 - transparency or 1)
			v6.Globe.BB.Width0 = v16 * (not v8 and 1 or 1 - transparency or 1)
			v6.Globe.AB.Width1 = v16 * (not v8 and 1 or 1 - transparency or 1)
			v6.Globe.BB.Width1 = v16 * (not v8 and 1 or 1 - transparency or 1)
			v6.Globe.AB.Transparency = NumberSequence.new(transparency + 0.35)
			v6.Globe.BB.Transparency = NumberSequence.new(transparency + 0.35)
			v6.Globe.AB.Segments = v9
			v6.Globe.BB.Segments = v9
			v6.Globe.Transparency = not v8 and 0.25 or v6.Globe.Transparency + transparency or 0.25
			v6.Globe.Mesh.Scale = createVector(1, 1, 1) * v9 / 40
			v6.Globe.CFrame = CFrame.new(position2)
			v6.Globe.Mesh.Offset = (currentCamera.CFrame.Position - position2).Unit * 0.1
			v6.AnimatedRadius = v9

			if v6.Spiky and v6.Spiky.Parent then
				local v17 = v12 * 1.2
				local v18 = math.sin(v4) ^ 2
				v6.Spiky.CFrame = v6.DustOrigin * CFrame.new(0, (math.abs(v18) * 0.5 + 0.25) * 1, 0) * CFrame.Angles(
					3.141592653589793,
					1 * v4,
					0
				)
				v6.Spiky.Mesh.Scale = createVector(0.00375, 0.0075, 0.00375) * Vector3.new(
					1,
					math.abs(v18) * 0.5 + 0.25,
					1
				) * v17
			end

			if v6.Spiky2 and v6.Spiky2.Parent then
				local v17 = v9 * 1.2
				local v18 = math.sin(v4) ^ 2
				v6.Spiky2.CFrame = v6.Origin * CFrame.new(0, v17 * 0.05 * (math.abs(v18) * 0.5 + 0.25), 0) * CFrame.Angles(
					3.141592653589793,
					2 * v4,
					0
				)
				v6.Spiky2.Mesh.Scale = createVector(0.005, 0.01, 0.005) * Vector3.new(1, math.abs(v18) * 0.5 + 0.1, 1) * v17
			end

			if v6.SpikeFadeTime and now - v6.SpikeFadeTime > v6.FadeOut then
				if v6.Spiky then
					v6.Spiky:Destroy()

					for _, v17 in ipairs(v6.Cache) do
						if not v17.Part.Parent then
							continue
						end

						v[v17.Part.Dust] = nil
						v17.Part:Destroy()
					end
				end

				if v6.Spiky2 then
					v6.Spiky2:Destroy()
				end
			else
				if v6.PlayerSession.Room.Active and not v6.SpikeFadeTime then
					v6.SpikeFadeTime = now
				end

				if v6.SpikeFadeTime then
					transparency = Tween.ease["in"].quad(math.min(now - v6.SpikeFadeTime, v6.FadeOut), 0, 1, v6.FadeOut) or transparency
				end

				if v6.Spiky then
					v6.Spiky.Transparency = transparency
				end

				if v6.Spiky2 then
					v6.Spiky2.Transparency = transparency
				end

				for i2, v17 in ipairs(v6.Cache) do
					v17.Angle = v17.Angle % 6.283185307179586 + v17.Frequency * p
					local v18 = 6.283185307179586 * (i2 / v6.Segments)
					v17.Part.Dust.Enabled = not v6.PlayerSession.Room.Active
					v17.Part.Dust.Size = ScaleParticle(v17.Part.Dust, v14)
					v17.Part.Transparency = transparency
					v17.Part.CFrame = v6.DustOrigin * CFrame.Angles(0, v18 + v4, 0) * CFrame.new(
						0,
						0,
						v12 * 0.05 + v12 / 2
					) * CFrame.Angles(1.0471975511965976, 1.5707963267948966, 0)
					local v19 = math.abs(math.sin(v17.Angle) ^ 2)
					local v20 = math.abs(math.cos(v17.Angle) ^ 3)
					v17.Mesh.Scale = (v17.Scale or Vector3.new()) + (v17.Scale or Vector3.new()) * 0.75 * Vector3.new(
						v19,
						v20,
						1.1
					)
				end
			end

			v5 = v6.AnimatedRadius and (currentCamera.CFrame.p - position2).Magnitude < v6.AnimatedRadius / 2 and true or v5

			if v6.WasInCutscene ~= _G.InCutscene then
				if _G.InCutscene then
					if v6.SoundInit then
						Util.Sound:FadeOut(v6.SoundInit, 0.1)
						v6.SoundInit = nil
					end
				elseif v6.SoundInit == nil then
					v6.SoundInit = Sound:Play("CTRLFRT_Z_Room_Idle_Loop_01", v6.Globe, v6.MaxRadius / 6)
				end

				v6.WasInCutscene = _G.InCutscene
			end
		end
	end

	if v5 then
		local v6 = lighting:FindFirstChild("OpeGlobe")

		if not v6 then
			v6 = Instance.new("ColorCorrectionEffect")
			v6.Name = "OpeGlobe"
			v6.TintColor = Color3.new(1, 1, 1)
			v6.Brightness = 0
			v6.Contrast = 0
			v6.Saturation = 0
			v6.Parent = lighting
		end

		v6.Enabled = not _G.InCutscene

		if not v2.Start then
			v2.Start = now
			v2.End = nil
		end

		local v7 = math.min(0.25, now - v2.Start) / 0.25

		for k, v8 in pairs(v2) do
			if not (k ~= "Start" and k ~= "End") then
				continue
			end

			if type(v8) == "number" then
				v6[k] = (v8 - 0) * v7 + 0
			elseif typeof(v8) == "Color3" then
				v6[k] = Color3.new(1, 1, 1):Lerp(v8, v7)
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

			local v6 = math.min(0.25, now - v2.End) / 0.25

			for k, v7 in pairs(v2) do
				if not (k ~= "Start" and k ~= "End") then
					continue
				end

				if type(v7) == "number" then
					local v8 = opeGlobe[k]
					opeGlobe[k] = v8 + (0 - v8) * v6
				elseif typeof(v7) == "Color3" then
					opeGlobe[k] = opeGlobe[k]:Lerp(Color3.new(1, 1, 1), v6)
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

	clone.CFrame = cFrame
	clone.Transparency = 1
	clone.AB.Transparency = NumberSequence.new(1)
	clone.BB.Transparency = NumberSequence.new(1)
	clone.AB.Segments = math.max(36, radius * 2)
	clone.BB.Segments = math.max(36, radius * 2)
	clone.Parent = _WorldOrigin
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
	clone2.Color = Color3.new(1, 1, 1)
	clone2.CFrame = cFrame
	clone2.Mesh.Scale = Vector3.new()
	clone2.Parent = _WorldOrigin
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