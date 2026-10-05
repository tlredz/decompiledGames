local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local StringUtils = require(ReplicatedStorage.Utils.StringUtils)
return {
	Start = function(_)
		Observers.observeTag("ClientLoadAnimation", function(animator)
			return Observers.observeAttribute(animator, "Animation", function(p: string)
				local animation = StringUtils:ReadPath(ReplicatedStorage, p)

				if typeof(animation) ~= "Instance" or not animation:IsA("Animation") then
					return nil
				end

				local track = animator:LoadAnimation(animation)
				track.Looped = true
				track:Play()
				return function()
					track:Stop(0)
					track:Destroy()
				end
			end)
		end)
		Observers.observeTag("ClientFloat", function(part)
			if not part:IsA("BasePart") then
				return nil
			end

			local function numAttr(attributeName: string, p: number)
				local attribute = part:GetAttribute(attributeName)

				if typeof(attribute) == "number" then
					return attribute
				end

				return p
			end

			local v = part:FindFirstChildWhichIsA("Motor6D")
			local flag

			if v then
				flag = false
			else
				local weld = part:FindFirstChildWhichIsA("Weld")

				if not (weld and weld.Part0 and weld.Part1) then
					return nil
				end

				v = Instance.new("Motor6D")
				v.Name = "ClientFloatMotor"
				v.Part0 = weld.Part0
				v.Part1 = weld.Part1
				v.C0 = weld.C0
				v.C1 = weld.C1
				v.Parent = part
				weld:Destroy()
				flag = true
			end

			local floatBobAmplitude = part:GetAttribute("FloatBobAmplitude")
			local v2 = typeof(floatBobAmplitude) ~= "number" and 0.35 or floatBobAmplitude
			local floatBobSpeed = part:GetAttribute("FloatBobSpeed")
			local v3 = typeof(floatBobSpeed) ~= "number" and 1.75 or floatBobSpeed
			local floatNodAmplitude = part:GetAttribute("FloatNodAmplitude")
			local v4 = typeof(floatNodAmplitude) ~= "number" and 0.12 or floatNodAmplitude
			local floatNodSpeed = part:GetAttribute("FloatNodSpeed")
			local v5 = typeof(floatNodSpeed) ~= "number" and 1.2 or floatNodSpeed
			local preRenderConnection = RunService.PreRender:Connect(function()
				local now = os.clock()
				v.Transform = CFrame.new(0, math.sin(now * v3) * v2, 0) * CFrame.Angles(math.sin(now * v5) * v4, 0, 0)
			end)
			return function()
				preRenderConnection:Disconnect()

				if v.Parent then
					if flag then
						v:Destroy()
					else
						v.Transform = CFrame.identity
					end
				end
			end
		end)
	end
}