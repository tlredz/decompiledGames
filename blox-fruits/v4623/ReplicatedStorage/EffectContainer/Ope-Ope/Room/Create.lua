local createVector = vector.create

local function MapRay(p, p2)
	return workspace:FindPartOnRayWithWhitelist(Ray.new(p, p2), { workspace.Map })
end

local function LerpNumber(p, p2, p3)
	return p + (p2 - p) * p3
end

local function CalculateCurve(p, p2)
	return 0.6666666666666666 * (p2 - p).Magnitude
end

function CalculateRadius(p, p2)
	return p * math.sin(3.141592653589793 * p2) ^ 0.3
end

local v = {}

local function ScaleParticle(dust, p)
	if not v[dust] then
		v[dust] = { dust.Size.Keypoints, dust.Speed }
	end

	local numberSequenceKeypoints = {}

	for _, v2 in next, v[dust][1], nil do
		local v3 = math.abs(v2.Value * p)
		local v4 = math.abs(v3 < v2.Envelope and v3 or v2.Envelope)
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v2.Time, v3, v4))
	end

	dust.Speed = NumberRange.new(v[dust][2].Min * p, v[dust][2].Max * p)
	return NumberSequence.new(numberSequenceKeypoints)
end

local v2 = {
	Brightness = 0.1,
	Contrast = 0.25,
	TintColor = Color3.fromRGB(164, 189, 255),
	Saturation = 0
}
local lighting = game.Lighting
local currentCamera = workspace.CurrentCamera
local _WorldOrigin = workspace._WorldOrigin
local RunService = game:GetService("RunService")
local replicatedStorage = game.ReplicatedStorage
local opeOpe = replicatedStorage["Ope-Ope"]
local Session = require(opeOpe.Modules.Session)
local Effect = require(replicatedStorage.Effect)
local Tween = require(replicatedStorage.Util.Tween)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local Spring = require(game.ReplicatedStorage.Util.Spring)
local _ = {
	DustCloud = createVector(0.121, 0.125, 0.18),
	SpikyWind = createVector(0.00375, 0.0075, 0.00375),
	WindFlare = createVector(0.005, 0.01, 0.005)
}
local dustCloud = opeOpe.Effects.DustCloud
local v3 = {}

local function FindNodeByPlayer(encoded)
	local result = {}

	for _, v4 in next, v3, nil do
		if v4.Player == encoded then
			table.insert(result, v4)
		end
	end

	if not (#result > 0) then
		result = false
	end

	return result
end

RunService:BindToRenderStep(script.Parent.Name .. "-" .. script.Name, Enum.RenderPriority.Last.Value - 1000, function(p)
	local now = tick()
	local v4 = 6.283185307179586 * (now % 1)

	for k, v5 in next, v3, nil do
		local lifetime = now - v5.Start

		if (v5.DestroyOpePls or not (v5.PlayerSession and v5.Character and v5.Character:GetAttribute("ControlRoomActive"))) and not v5.Destroy then
			local v7 = 1 / v5.FadeOut
			Sound:Play("Ope.Room.Swoosh", v5.Origin.p, v5.Radius, v7)
			v5.Destroy = now
			v5.Lifetime = lifetime
		end

		if v5.Destroy and now - v5.Destroy > v5.FadeOut then
			v5.Globe:Destroy()

			if v5.Spiky2 then
				v5.Spiky2:Destroy()
			end

			if v5.Spiky then
				v5.Spiky:Destroy()

				for _, v7 in next, v5.Cache, nil do
					v7.Part:Destroy()
				end
			end

			table.remove(v3, k)
		else
			local p2 = v5.PlayerSession.Room.CFrame.p
			local radius = v5.PlayerSession.Room.Radius
			local maxRadius = v5.PlayerSession.Room.MaxRadius
			v5.Spring:SetGoal(radius)
			v5.Spring:Update(p)
			v5.Spring2:SetGoal(p2)
			v5.Spring2:Update(p)
			local position = v5.Spring:GetPosition()
			local position2 = v5.Spring2:GetPosition()
			local v7 = v5.Destroy and 1.5 or 0.25
			local v8 = v5.Destroy and 2 or 1
			local _ = position / maxRadius
			local v9 = 2 * position
			local transparency = v5.Destroy and Tween.ease["in"].quint(
				math.min(now - v5.Destroy, v5.FadeOut),
				0,
				1,
				v5.FadeOut
			) or Tween.ease.outin.circ(math.min(lifetime, 0.5), 1, -1, 0.5)
			local v11 = 0.5 - math.sqrt((v5.Origin.Y - v5.DustOrigin.Y) ^ 2) / v9
			local v12 = CalculateRadius(v9 * 1.1, v11)
			local v13 = #v5.Cache

			for _, v14 in next, v5.Cache, nil do
				v14.Scale = createVector(0.121, 0.125, 0.18) * v9 / (v13 - 2) * (0.5 + v11)
			end

			local v14 = v9 / 4 * (0.5 + v11)
			v5.Radius = v9

			if v5.SoundInit and v5.Sound and not v5.PlayerSession.Room.Active then
				local p3 = currentCamera.CFrame.p
				local volume = math.clamp(1 - (v5.Origin.p - p3).Magnitude / (1.25 * v9), 0.1, 1)

				if volume > 0 then
					v5.SoundInit.Volume = volume
					v5.Sound.Volume = volume
				end
			end

			if not v5.PlayerSession.Room.Active and now - v5.LastShake > 0.2 then
				local p3 = currentCamera.CFrame.p
				local v15 = 1 - (v5.Origin.p - p3).Magnitude / (1.25 * v9)

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

				v5.LastShake = now
			end

			v5.Globe.A.CFrame = CFrame.new(0, 0, -0.5 * v9)
			v5.Globe.B.CFrame = CFrame.new(0, 0, 0.5 * v9)
			local position3 = v5.Globe.A.Position
			local curveSize = 0.6666666666666666 * (v5.Globe.B.Position - position3).Magnitude
			v5.Globe.AB.CurveSize0 = curveSize
			v5.Globe.BB.CurveSize0 = -curveSize
			v5.Globe.AB.CurveSize1 = -curveSize
			v5.Globe.BB.CurveSize1 = curveSize
			local width = v5.Radius / 10
			v5.Globe.AB.Width0 = width
			v5.Globe.BB.Width0 = width
			v5.Globe.AB.Width1 = width
			v5.Globe.BB.Width1 = width
			v5.Globe.AB.Transparency = NumberSequence.new(transparency + 0.35)
			v5.Globe.BB.Transparency = NumberSequence.new(transparency + 0.35)
			v5.Globe.AB.Segments = v9
			v5.Globe.BB.Segments = v9
			v5.Globe.Transparency = v5.Destroy and v5.Globe.Transparency + transparency or 0.25 + (1.25 - transparency) * 0.8 * v7 * math.abs(math.sin(v4) ^ (5 * v8))
			v5.Globe.Mesh.Scale = createVector(1, 1, 1) * v9
			v5.Globe.CFrame = CFrame.new(position2)
			v5.AnimatedRadius = v9

			if v5.Spiky and v5.Spiky.Parent then
				local v17 = v12 * 1.2
				local _ = math.sin(v4) ^ 2
				local v18 = math.sin(v4) ^ 2
				v5.Spiky.CFrame = v5.DustOrigin * CFrame.new(0, (math.abs(v18) * 0.5 + 0.25) * 1, 0) * CFrame.Angles(
					3.141592653589793,
					1 * v4,
					0
				)
				v5.Spiky.Mesh.Scale = createVector(0.00375, 0.0075, 0.00375) * Vector3.new(
					1,
					math.abs(v18) * 0.5 + 0.25,
					1
				) * v17
			end

			if v5.Spiky2 and v5.Spiky2.Parent then
				local v17 = v9 * 1.2
				local _ = math.sin(v4) ^ 2
				local v18 = math.sin(v4) ^ 2
				v5.Spiky2.CFrame = v5.Origin * CFrame.new(0, v17 * 0.05 * (math.abs(v18) * 0.5 + 0.25), 0) * CFrame.Angles(
					3.141592653589793,
					2 * v4,
					0
				)
				v5.Spiky2.Mesh.Scale = createVector(0.005, 0.01, 0.005) * Vector3.new(1, math.abs(v18) * 0.5 + 0.1, 1) * v17
			end

			if v5.SpikeFadeTime and now - v5.SpikeFadeTime > v5.FadeOut then
				if v5.Spiky then
					v5.Spiky:Destroy()

					for _, v17 in next, v5.Cache, nil do
						v17.Part:Destroy()
					end
				end

				if v5.Spiky2 then
					v5.Spiky2:Destroy()
				end
			else
				if v5.PlayerSession.Room.Active then
					if not v5.SpikeFadeTime then
						Sound:Play("Ope.Room.Activate", v5.Origin.p, v9, 0.5)
						Sound:FadeOut(v5.Sound, v5.SoundDuration * 0.25)
						v5.SpikeFadeTime = now
					end

					transparency = Tween.ease["in"].quad(math.min(now - v5.SpikeFadeTime, v5.FadeOut), 0, 1, v5.FadeOut)
				end

				if v5.Spiky then
					v5.Spiky.Transparency = transparency
				end

				if v5.Spiky2 then
					v5.Spiky2.Transparency = transparency
				end

				for k2, v17 in next, v5.Cache, nil do
					v17.Angle = v17.Angle % 6.283185307179586 + v17.Frequency * p
					local v18 = 6.283185307179586 * (k2 / v5.Segments)
					v17.Part.Dust.Enabled = not v5.PlayerSession.Room.Active
					v17.Part.Dust.Transparency = NumberSequence.new(transparency)
					v17.Part.Dust.Size = ScaleParticle(v17.Part.Dust, v14)
					v17.Part.Transparency = transparency
					v17.Part.CFrame = v5.DustOrigin * CFrame.Angles(0, v18 + v4, 0) * CFrame.new(
						0,
						0,
						v12 * 0.05 + v12 / 2
					) * CFrame.Angles(1.0471975511965976, 1.5707963267948966, 0)
					v17.Mesh.Scale = v17.Scale + v17.Scale * 0.75 * Vector3.new(
						math.abs(math.sin(v17.Angle) ^ 2),
						math.abs(math.cos(v17.Angle) ^ 3),
						1.1
					)
				end
			end
		end
	end

	local flag = false

	for _, v5 in next, v3, nil do
		if v5.AnimatedRadius and (currentCamera.CFrame.p - v5.Origin.p).Magnitude < v5.AnimatedRadius / 2 then
			flag = true
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

		if not v2.Start then
			v2.Start = now
			v2.End = nil
		end

		local v6 = math.min(0.25, now - v2.Start) / 0.25

		for k, v7 in next, v2, nil do
			if not (k ~= "Start" and k ~= "End") then
				continue
			end

			if type(v7) == "number" then
				v5[k] = 0 + (v7 - 0) * v6
			elseif typeof(v7) == "Color3" then
				v5[k] = Color3.new(1, 1, 1):Lerp(v7, v6)
			end
		end
	else
		local opeGlobe = lighting:FindFirstChild("OpeGlobe")

		if opeGlobe then
			if not v2.End then
				v2.End = now
				v2.Start = nil
			end

			local v5 = math.min(0.25, now - v2.End) / 0.25

			for k, v6 in next, v2, nil do
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

local function Create(list)
	local character, fadeOut = unpack(list)
	local playerSession = Session[character]
	local cFrame = playerSession.Room.CFrame
	local radius = playerSession.Room.Radius
	local maxRadius = playerSession.Room.MaxRadius
	local _ = playerSession.Room.HoldDuration
	local clone = opeOpe.Effects.Globe:Clone()
	clone.CFrame = cFrame
	clone.Transparency = 1
	clone.AB.Transparency = NumberSequence.new(1)
	clone.BB.Transparency = NumberSequence.new(1)
	clone.AB.Segments = math.max(36, 2 * radius)
	clone.BB.Segments = math.max(36, 2 * radius)
	clone.Parent = _WorldOrigin
	local clone2 = opeOpe.Effects.WindFlare:Clone()
	clone2.Color = Color3.new(1, 1, 1)
	clone2.CFrame = cFrame
	clone2.Mesh.Scale = Vector3.new()
	clone2.Parent = _WorldOrigin
	local cache = {}
	local v7 = cFrame.p + createVector(0, 1, 0)
	local vector2 = Vector3.new(0, -radius / 2 - 1, 0)
	local part, v8, v9 = workspace:FindPartOnRayWithWhitelist(Ray.new(v7, vector2), { workspace.Map })
	local v10, clone3

	if part and part.Transparency < 0.1 then
		v10 = CFrame.new(v8, v8 + v9) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(0, radius * 0.025, 0)
		local v11 = 0.5 - math.sqrt((cFrame.Y - v8.Y) ^ 2) / radius
		CalculateRadius(radius * 1.1, v11)
		local color = part.Color
		clone3 = opeOpe.Effects.SpikyWind:Clone()
		clone3.Color = Color3.new(1, 1, 1)
		clone3.CFrame = cFrame * CFrame.Angles(3.141592653589793, 0, 0)
		clone3.Mesh.Scale = Vector3.new()
		clone3.Parent = _WorldOrigin

		for i = 1, 12 do
			local _ = 6.283185307179586 * (i / 12)
			local clone4 = dustCloud:Clone()
			clone4.Color = color
			clone4.Dust.Color = ColorSequence.new(color)
			clone4.CFrame = v10
			clone4.Mesh.Scale = createVector(0.121, 0.125, 0.18) * radius / 10 * (0.5 + v11)
			clone4.Mesh.VertexColor = Vector3.new(color.r, color.g, color.b)
			clone4.Transparency = 1
			clone4.Dust.Transparency = NumberSequence.new(1)
			clone4.Parent = _WorldOrigin
			table.insert(cache, {
				Part = clone4,
				Mesh = clone4.Mesh,
				Angle = 6.283185307179586 * Random.new():NextNumber(),
				Frequency = Random.new():NextNumber(3.141592653589793, 6.283185307179586)
			})
		end
	else
		v10 = cFrame
	end

	local soundInit = Sound:Play("Ope.Room.Activate", cFrame.p, maxRadius, 1.5)
	local holdDuration = playerSession.Room.HoldDuration
	local v12 = 1 / (0.5 * holdDuration)
	local soundDuration = 4 / v12
	local sound = Sound:Play("Ope.Room.Create", cFrame.p, maxRadius, v12)
	local v16 = {
		Player = character,
		Character = 0,
		LastShake = 0,
		SoundInit = 0,
		Sound = 0,
		SoundDuration = 0,
		Spring = 0,
		Spring2 = 0,
		Segments = 12,
		Origin = 0,
		DustOrigin = 0,
		Radius = 0,
		Globe = 0,
		Spiky = 0,
		Spiky2 = 0,
		Cache = 0,
		FadeIn = 0,
		FadeOut = 0,
		PlayerSession = 0,
		Lifetime = 1e999,
		Start = 0
	}

	if character:IsA("Player") then
		character = character.Character
	end

	v16.Character = character
	v16.SoundInit = soundInit
	v16.Sound = sound
	v16.SoundDuration = soundDuration
	v16.Spring = Spring.new(1.5, 0.75, 0)
	v16.Spring2 = Spring.new(1.5, 0.75, cFrame.p)
	v16.Origin = cFrame
	v16.DustOrigin = v10
	v16.Radius = radius
	v16.Globe = clone
	v16.Spiky = clone3
	v16.Spiky2 = clone2
	v16.Cache = cache
	v16.FadeIn = holdDuration
	v16.FadeOut = fadeOut
	v16.PlayerSession = playerSession
	v16.Start = tick()
	table.insert(v3, v16)
end

require(game.ReplicatedStorage.Util)
game.ReplicatedStorage.Remotes.RoomManager.OnClientEvent:Connect(function(p, p2, value)
	local encoded = _G.Encode(p)
	local nodeByPlayer = FindNodeByPlayer(encoded)

	if p2 == "Create" then
		if not nodeByPlayer then
			print("created room for:", game.Players.LocalPlayer, "on behalf of:", encoded)
			Create({ encoded, value or 0.5 })
		end
	elseif p2 == "Destroy" and nodeByPlayer then
		for _, v5 in next, nodeByPlayer, nil do
			v5.DestroyOpePls = true
		end
	end
end)
return Create