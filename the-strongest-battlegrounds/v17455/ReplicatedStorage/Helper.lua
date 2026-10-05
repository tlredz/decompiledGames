local Helper = {}
local Players = game:GetService("Players")
game:GetService("ServerStorage")
game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
game:GetService("HttpService")
local RunService = game:GetService("RunService")
RunService:IsClient()
RunService:IsServer()
local currentCamera = workspace.CurrentCamera
Helper.bodyParts = {
	"Head",
	"Torso",
	"Left Arm",
	"Right Arm",
	"Left Leg",
	"Right Leg",
	"HumanoidRootPart"
}

function Helper.Debris(_, instance, duration: number)
	task.delay(duration, function()
		if instance then
			instance:Destroy()
		end
	end)
end

function Helper:Emit(folder, flag: boolean)
	local v

	if flag then
		v = folder:GetDescendants()
	else
		v = folder:GetChildren()
	end

	for _, emitter in v do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v2 = emitter
		task.spawn(function()
			if v2:GetAttribute("EmitDelay") then
				task.wait(v2:GetAttribute("EmitDelay"))
			end

			v2:Emit(v2:GetAttribute("EmitCount") or 5)
		end)
	end
end

function Helper.setCollision(_, instance, collisionGroup: string)
	local children = instance:GetChildren()

	for _, v in children do
		if table.find(Helper.bodyParts, v.Name) then
			v.CollisionGroup = collisionGroup
		end
	end
end

function Helper.attachPart(_, instance, instance2)
	local clone = instance:Clone()

	if instance2.Massless then
		clone.Massless = true
		clone.CanCollide = false
		clone.CanTouch = false
		clone.CanQuery = false
		clone.Anchored = false
		clone.RootPriority = -127
	end

	if instance2.CFrame then
		clone.CFrame = instance2.CFrame
	else
		local instance3 = Instance.new(instance2.Motor6D and "Motor6D" or "Weld")
		instance3.Part0 = instance2.AttachTo
		instance3.Part1 = clone
		instance3.C0 = instance2.C0 or CFrame.new()
		instance3.C1 = instance2.C1 or CFrame.new()
		instance3.Parent = clone
	end

	clone.Parent = instance2.Parent or workspace.Thrown

	if instance2.Emit then
		Helper:Emit(clone, true)
	end

	if instance2.Behavior then
		instance2.Behavior(clone)
	end

	if instance2.Debris then
		Functions.Debris(clone, instance2.Debris)
		game.Debris:AddItem(clone, instance2.Debris + 5)
	end

	return clone
end

function Helper.Cutscene(_, p, p2, value, p3, instance)
	if not p2 then
		return error("helper:Cutscene requires a reference object.")
	end

	if Players.LocalPlayer:GetAttribute("Cutscene") then
		return
	end

	Players.LocalPlayer:SetAttribute("Cutscene", true)
	local v = value or 0
	local cFrame = currentCamera.CFrame
	local renderSteppedConnection = nil
	currentCamera.CameraType = Enum.CameraType.Scriptable

	local function endCutscene()
		if renderSteppedConnection.Connected then
			renderSteppedConnection:Disconnect()
		end

		currentCamera.CameraType = Enum.CameraType.Custom
		currentCamera.CFrame = cFrame
		currentCamera.FieldOfView = game.Players.LocalPlayer:GetAttribute("S_FOV") or 70
		Players.LocalPlayer:SetAttribute("Cutscene", nil)
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
		v += dt * 60
		local v2 = tonumber((math.ceil(v)))

		if v2 >= 980 then
			v2 += 49
		end

		local child = p.Frames:FindFirstChild(v2)
		local child2 = p.FOV:FindFirstChild(v2)

		if child2 and not instance:FindFirstChild("Distorting") then
			currentCamera.FieldOfView = child2.Value
		end

		if p3 and p3 <= v then
			endCutscene()
		end

		if child then
			if not instance:FindFirstChild("Distorting") then
				return
			end
		else
			endCutscene()
		end
	end)
	return endCutscene
end

return Helper