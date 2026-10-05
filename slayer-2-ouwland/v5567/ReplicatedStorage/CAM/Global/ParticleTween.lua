local BoatTween = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("BoatTween"))
local ParticleTween = {}

function ParticleTween.ResizeParticles(_, folder, p: number, time: number, easingStyle: string, easingDirection: string)
	local v = {
		ParticleEmitter = {
			Size = "Size",
			Speed = "Speed",
			Acceleration = "Acceleration"
		},
		Beam = {
			Width0 = "Width0",
			Width1 = "Width1",
			CurveSize0 = "CurveSize0",
			CurveSize1 = "CurveSize1"
		},
		Trail = {}
	}
	local v2 = {
		NumberSequence = function(sequence, p5: number)
			local numberSequenceKeypoints = {}

			for k, keypoint in sequence.Keypoints do
				numberSequenceKeypoints[k] = NumberSequenceKeypoint.new(
					keypoint.Time,
					keypoint.Value * p5,
					keypoint.Envelope
				)
			end

			return NumberSequence.new(numberSequenceKeypoints)
		end,
		NumberRange = function(range: NumberRange, p5: number)
			return NumberRange.new(range.Min * p5, range.Max * p5)
		end,
		number = function(p5: number, p6: number)
			return p5 * p6
		end,
		Vector3 = function(vector: Vector3, p5: number)
			return (Vector3.new(vector.X * p5, vector.Y * p5, vector.Z * p5))
		end
	}

	for _, descendant in pairs(folder:GetDescendants()) do
		local v3 = v[descendant.ClassName]

		if not v3 then
			continue
		end

		for k, _ in pairs(v3) do
			local v4 = descendant[k]
			local v5 = v2[typeof(v4)](v4, p)

			if not v5 then
				continue
			end

			local v6 = BoatTween:Create(descendant, {
				Time = time,
				Goal = {
					[k] = v5
				},
				EasingStyle = easingStyle,
				EasingDirection = easingDirection
			})
			v6:Play()
			task.defer(function()
				v6.Completed:Wait()
				v6:Destroy()
			end)
		end
	end
end

function ParticleTween.ResizeParticlesNoTween(_, folder, p: number)
	local v = {
		ParticleEmitter = {
			Size = "Size",
			Speed = "Speed",
			Acceleration = "Acceleration"
		},
		Beam = {
			Width0 = "Width0",
			Width1 = "Width1",
			CurveSize0 = "CurveSize0",
			CurveSize1 = "CurveSize1"
		},
		Trail = {}
	}
	local v2 = {
		NumberSequence = function(sequence, p2: number)
			local numberSequenceKeypoints = {}

			for k, keypoint in sequence.Keypoints do
				numberSequenceKeypoints[k] = NumberSequenceKeypoint.new(
					keypoint.Time,
					keypoint.Value + keypoint.Value * p2,
					keypoint.Envelope
				)
			end

			return NumberSequence.new(numberSequenceKeypoints)
		end,
		NumberRange = function(range: NumberRange, p2: number)
			return NumberRange.new(range.Min + range.Min * p2, range.Max + range.Max * p2)
		end,
		number = function(p2: number, p3: number)
			return p2 + p2 * p3
		end,
		Vector3 = function(vector: Vector3, p2: number)
			return (Vector3.new(vector.X + vector.X * p2, vector.Y + vector.Y * p2, vector.Z + vector.Z * p2))
		end
	}

	for _, descendant in pairs(folder:GetDescendants()) do
		local v3 = v[descendant.ClassName]

		if not v3 then
			continue
		end

		for k, _ in pairs(v3) do
			local v4 = descendant[k]
			local v5 = v2[typeof(v4)](v4, p)

			if v5 then
				descendant[k] = v5
			end
		end
	end
end

return ParticleTween