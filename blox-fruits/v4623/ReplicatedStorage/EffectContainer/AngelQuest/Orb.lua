local createVector = vector.create
local FX = require(game.ReplicatedStorage.FX)
local angelStyleQuest = FX:WaitForChild("AngelStyleQuest")
local Util = require(game.ReplicatedStorage.Util)
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
NumberSequence.new(1)
NumberSequence.new(0)

local function Particles(folder)
	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if emitter:GetAttribute("EmitDelay") then
			local v = emitter
			task.delay(emitter:GetAttribute("EmitDelay"), function()
				v:Emit(v:GetAttribute("EmitCount"))
			end)
		elseif emitter:GetAttribute("EmitCount") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end
end

local class = {}

function class:Create(obj, tweeninfo, properties)
	local RunService = game:GetService("RunService")

	if not RunService:IsRunning() or GlobalUtil.FFlags.IsUnitTest ~= false then
		return (setmetatable({
			obj = obj,
			tweeninfo = tweeninfo,
			properties = properties
		}, {
			__index = class
		}))
	end

	local TweenService = game:GetService("TweenService")
	return TweenService:Create(obj, tweeninfo, properties)
end

function class:Play(duration)
	task.spawn(function()
		if duration then
			task.wait(duration)
		end

		local v = {}
		local v2 = -1

		for k in pairs(self.properties) do
			v[k] = self.obj[k]
		end

		while v2 < self.tweeninfo.RepeatCount do
			if self.tweeninfo.DelayTime and self.tweeninfo.DelayTime > 0 then
				task.wait(self.tweeninfo.DelayTime)
			end

			local v3 = 0

			while v3 < 1 do
				v3 = math.min(1, v3 + task.wait() / self.tweeninfo.Time)
				local TweenService = game:GetService("TweenService")
				local value = TweenService:GetValue(v3, self.tweeninfo.EasingStyle, self.tweeninfo.EasingDirection)

				for k, property in pairs(self.properties) do
					local v4

					if typeof(property) == "number" then
						v4 = (property - v[k]) * value + v[k]
					else
						v4 = v[k]:lerp(property, value)
					end

					self.obj[k] = v4
				end
			end

			if self.tweeninfo.Reverses then
				local v4 = 1

				while v4 > 0 do
					v4 = math.max(0, v4 - task.wait() / self.tweeninfo.Time)
					local TweenService = game:GetService("TweenService")
					local value = TweenService:GetValue(v4, self.tweeninfo.EasingStyle, self.tweeninfo.EasingDirection)

					for k, property in pairs(self.properties) do
						local v5

						if typeof(property) == "number" then
							v5 = (property - v[k]) * value + v[k]
						else
							v5 = v[k]:lerp(property, value)
						end

						self.obj[k] = v5
					end
				end
			end

			v2 += 1
		end
	end)
end

local v = {}

function eff(data)
	if data.Phase == 1 then
		local clone = angelStyleQuest.Orb:Clone()
		v[data.Orb] = clone
		clone:SetPrimaryPartCFrame(data.Goal * CFrame.new(0, 3, 0))
		clone.Parent = workspace._WorldOrigin

		if typeof(data.Orb) == "number" then
			workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
			workspace.CurrentCamera.CFrame = data.Goal * CFrame.new(0, 5, -15) * CFrame.Angles(0, 3.141592653589793, 0)
			task.delay(0.7, function()
				_G.Dialogue("AngelQuest" .. data.Orb + 1)
			end)
			local lastTime = os.clock()
			task.spawn(function()
				repeat
					task.wait()
				until _G.DialogueController.Active

				lastTime = os.clock()

				repeat
					task.wait()
				until not _G.DialogueController.Active

				local v2 = 5 - (os.clock() - lastTime)

				if v2 > 0 then
					task.wait(v2)
				end

				task.spawn(function()
					eff({
						Orb = data.Orb,
						Phase = 2
					})
				end)
				task.wait(2)
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			end)
		end

		for _, emitter in pairs(clone.SphereHold:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		class:Create(clone.SphereHold.PointLight, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Range = 16
		}):Play()
		local _ = clone.Orb.Position.Y + 15

		for _, beam in pairs(clone.Orb:GetChildren()) do
			if not beam:IsA("Beam") then
				continue
			end

			local worldCFrame = beam.Attachment1.WorldCFrame
			local curveSize1 = beam.CurveSize1
			local width0 = beam.Width0
			local curveSize0 = beam.CurveSize0
			local textureLength = beam.TextureLength
			local worldCFrame2 = beam.Attachment0.WorldCFrame
			beam.Attachment1.WorldCFrame = beam.Attachment1.WorldCFrame + createVector(0, 15, 0)
			beam.CurveSize1 = 3
			beam.Width0 = 0
			beam.CurveSize0 = 0
			beam.TextureLength = 3
			beam.Attachment0.WorldCFrame = beam.Attachment0.WorldCFrame + createVector(0, 6, 0)
			class:Create(beam.Attachment0, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				WorldCFrame = worldCFrame2
			}):Play()
			class:Create(beam.Attachment1, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
				WorldCFrame = beam.Attachment1.WorldCFrame + createVector(0, 15, 0)
			}):Play()
			class:Create(beam, TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0.1), {
				Width0 = width0,
				CurveSize0 = curveSize0,
				TextureLength = textureLength
			}):Play()
			class:Create(beam, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 1.1), {
				CurveSize1 = curveSize1
			}):Play()
			class:Create(
				beam.Attachment1,
				TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.9),
				{
					WorldCFrame = worldCFrame
				}
			):Play()
		end

		task.delay(1.6, function()
			if v[data.Orb] then
				for _, emitter in pairs(clone.SphereHold:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end
		end)
	elseif data.Phase == 2 then
		local v2 = v[data.Orb]

		if not v2 then
			return
		end

		v[data.Orb] = nil
		Util.Debris:AddItem(v2, 5)

		for _, emitter in pairs(v2.SphereHold:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		class:Create(v2.SphereHold.PointLight, TweenInfo.new(2), {
			Range = 0
		}):Play()
		local _ = v2.Orb.Position.Y + 15

		for _, beam in pairs(v2.Orb:GetChildren()) do
			if not beam:IsA("Beam") then
				continue
			end

			class:Create(beam.Attachment1, TweenInfo.new(3, Enum.EasingStyle.Sine), {
				WorldCFrame = beam.Attachment1.WorldCFrame + createVector(0, 15, 0)
			}):Play()
			class:Create(beam, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true), {
				CurveSize1 = 3
			}):Play()
			class:Create(beam, TweenInfo.new(1.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 1), {
				Width0 = 0,
				CurveSize0 = 0,
				TextureLength = 3
			}):Play()
			class:Create(
				beam.Attachment0,
				TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 1.1),
				{
					WorldCFrame = beam.Attachment0.WorldCFrame + createVector(0, 6, 0)
				}
			):Play()
		end
	end
end

return eff