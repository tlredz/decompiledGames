local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local masterClock = Util.MasterClock
local debris = Util.Debris
local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
return function(data)
	local subID = data.SubID or 1

	if subID ~= 1 then
		return
	end

	local cFrame = data.CFrame
	local lifetime = data.Lifetime
	local timestamp = data.Timestamp

	if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > 600 then
		return
	end

	local v = math.max(0.1, lifetime - (masterClock:GetTime() - timestamp))
	local clone = script.Tornado:Clone()
	debris:AddItem(clone, v + 2)
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	Util.Sound:Play("SandCWind", clone.Position)
	local v2 = Util.Sound:Play("SandFlightLoop2", clone.Position)
	local position = cFrame * createVector(0, 10, 0)
	TweenService:Create(clone, tweenInfo, {
		Size = createVector(23.248, 30.994, 23.022),
		Position = position
	}):Play()

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local lastTime = os.clock()
	local v4 = 0.016666666666666666
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		if v < os.clock() - lastTime or clone == nil then
			renderSteppedConnection:Disconnect()
		end

		clone.CFrame *= CFrame.fromEulerAnglesXYZ(0, 0.3, 0)
		v4 = RunService.RenderStepped:Wait()
	end)
	task.wait(v - 0.4)

	if clone then
		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		TweenService:Create(clone, tweenInfo, {
			Size = createVector(0.001, 30.994, 0.001),
			Position = position
		}):Play()

		if v2 then
			TweenService:Create(v2, tweenInfo, {
				Volume = 0
			}):Play()
		end
	end
end