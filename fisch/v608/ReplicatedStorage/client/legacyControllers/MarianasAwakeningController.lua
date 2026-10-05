local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Net = require(ReplicatedStorage.packages.Net)
local anno_localthought = ReplicatedStorage:WaitForChild("events"):WaitForChild("anno_localthought")
local remoteEvent = Net:RemoteEvent("MarianasAwakening/ScyllaEcho")

local function playEchoSound()
	local creepyCave = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("world"):FindFirstChild("creepyCave")

	if not (creepyCave and creepyCave:IsA("Sound")) then
		return
	end

	local clone = creepyCave:Clone()
	clone.Looped = false
	clone.Parent = SoundService
	clone:Play()
	Debris:AddItem(clone, clone.TimeLength > 0 and clone.TimeLength + 1 or 10)
end

local function shakeCamera()
	local lastTime = os.clock()
	local v = math.random() * 100
	RunService:UnbindFromRenderStep("MarianasEchoShake")
	RunService:BindToRenderStep("MarianasEchoShake", Enum.RenderPriority.Camera.Value + 1, function()
		local v2 = os.clock() - lastTime

		if v2 >= 1.6 then
			RunService:UnbindFromRenderStep("MarianasEchoShake")
			return
		end

		local v3 = 0.020943951023931952 * (1 - v2 / 1.6) ^ 2
		local v4 = v2 * 12
		workspace.CurrentCamera.CFrame *= CFrame.Angles(
			math.noise(v4, v) * v3,
			math.noise(v4, v + 10) * v3,
			math.noise(v4, v + 20) * v3 * 0.5
		)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isCutsceneRunning()
	return workspace:GetAttribute("ClientCutsceneRunning") == true
end

local function playEchoCue()
	local total = 0

	while workspace:GetAttribute("ClientCutsceneRunning") ~= true and total < 2 do
		total += task.wait()
	end

	while isCutsceneRunning() do
		task.wait()
	end

	task.wait(1)
	playEchoSound()
	shakeCamera()
	anno_localthought:Fire("Something stirs far below... the dark is calling you down.")
end

return {
	Start = function(self)
		local controllers = script:FindFirstChild("Controllers")

		if controllers then
			for _, moduleScript in controllers:GetChildren() do
				if not moduleScript:IsA("ModuleScript") then
					continue
				end

				local v = moduleScript
				task.spawn(function()
					local module = require(v)

					if module.Start then
						module:Start()
					end
				end)
			end
		end

		remoteEvent.OnClientEvent:Connect(function()
			task.spawn(playEchoCue)
		end)
	end
}