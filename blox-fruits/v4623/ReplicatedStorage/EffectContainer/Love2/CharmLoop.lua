local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local loveCharm = FX:WaitForChild("LoveEffects").LoveCharm
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor

local function emitWithDelay(instance)
	local emitDelay = instance:GetAttribute("EmitDelay")

	if emitDelay then
		task.delay(emitDelay, function()
			instance:Emit(instance:GetAttribute("EmitCount"))
		end)
	else
		instance:Emit(instance:GetAttribute("EmitCount"))
	end
end

local vignetteService = Util.VignetteService
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { Workspace.Characters, Workspace.Enemies, _WorldOrigin }
return function(data)
	local root = data.root
	local charmFor = data.charmFor
	local victimPlayer = data.victimPlayer
	local _ = data.casterHrp
	local _ = data.pullPower
	local currentCamera = Workspace.CurrentCamera

	if root == nil or root.Parent == nil or (root.Position - currentCamera.CFrame.Position).Magnitude > 1200 then
		return
	end

	local clone = loveCharm.Parent.CharmedParticles:Clone()
	clone.Parent = root
	destroyAfter(clone, charmFor + 2)
	task.delay(charmFor, function()
		if clone == nil or clone.Parent == nil then
			return
		end

		clone.Enabled = false
	end)

	if localPlayer == victimPlayer then
		local vignette = vignetteService:CreateVignette({ loveCharm.Parent.CharmedVignette })
		vignette:UpdateEnabled(true)
		vignette:Enabled(true)
		task.delay(charmFor, function()
			vignette:UpdateEnabled(false)
			vignette:Enabled(false)
			task.wait(0.8)
			vignette:Destroy()
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function endHeartbeat()
			currentCamera.FieldOfView = 70
		end

		local v = 0

		local function fn()
			Util.Sound:Play("LoveV2SingleHeartbeat", root)
		end

		local connection = nil
		connection = heartbeatLoopFor2(charmFor, function(_)
			if root == nil or root.Parent == nil then
				connection:Disconnect()
				connection = nil
				endHeartbeat() -- equivalent call inferred; original call site unknown
			else
				if v > time() % 0.5 then
					task.spawn(fn)
				end

				v = time() % 0.5
				local v2 = 2 * time() - 0.2
				currentCamera.FieldOfView = 70 - math.sin(v2 * 2 * 3.141592653589793 + math.sin(v2 * 2 * 3.141592653589793) * 2) ^ 2 * 10
			end
		end, endHeartbeat)
	end
end