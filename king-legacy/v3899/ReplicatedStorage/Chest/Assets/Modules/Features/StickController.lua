local createVector = vector.create
local RunService = game:GetService("RunService")
local replication = script:WaitForChild("Replication")
script:WaitForChild("GetRegistry")
local StickController = {}
local v = {}
local v2 = {}
local total = 0
local flag = nil

function StickController.CanStick(_, instance)
	local primaryPart = nil

	if instance:IsA("Model") and instance.PrimaryPart then
		primaryPart = instance.PrimaryPart
	elseif instance:IsA("BasePart") then
		primaryPart = instance
	end

	if not primaryPart then
		return
	end

	if primaryPart.Anchored then
		return
	else
		return true
	end
end

function StickController:UpdateObjectReplication(p, p2, player)
	local v3 = p2 and ({
		_Target = p2._Target or nil,
		_Offset = p2._Offset or nil
	} or nil) or nil

	if RunService:IsServer() then
		if player then
			replication:FireClient(player, p, v3)
		else
			replication:FireAllClients(p, v3)
		end
	else
		if not RunService:IsClient() then
			return
		end

		v2[p] = p2
		StickController:ExecuteReplication()
	end
end

function StickController:Destroy(p)
	local v3 = v[p]

	if v3 then
		return v3:Destroy()
	end
end

function StickController.new(p)
	if v[p] then
		return
	end

	local v3 = {}

	function v3.SetTarget(p2, target)
		v3._Target = target
		StickController:UpdateObjectReplication(p, v3)
		return p2
	end

	function v3.SetOffset(p2, offset: Vector3)
		v3._Offset = offset
		StickController:UpdateObjectReplication(p, v3)
		return p2
	end

	function v3:Destroy()
		if v3._Destroyed then
			return
		end

		v3._Destroyed = true
		StickController:UpdateObjectReplication(p, nil)
		return self
	end

	v[p] = v3
	return v3
end

function StickController:Update(instance, data)
	if not data._Target or data._Destroyed then
		return
	end

	local _Offset = data._Offset or createVector(0, 0, 0)
	local worldCFrame

	if data._Target:IsA("Attachment") then
		worldCFrame = data._Target.WorldCFrame
	else
		worldCFrame = data._Target:GetPivot()
	end

	if not worldCFrame then
		return
	end

	instance:PivotTo(worldCFrame * CFrame.new(_Offset))
	return true
end

function StickController.Step(_, p)
	total += p

	if total < 0.03333333333333333 then
		return
	end

	total = 0

	for k, v3 in pairs(v) do
		if v3._Destroyed then
			v[k] = nil
		elseif StickController:Update(k, v3) then
		end
	end
end

function StickController:ExecuteReplication()
	if not RunService:IsClient() or flag then
		return
	end

	flag = true
	RunService:BindToRenderStep("StickReplication", Enum.RenderPriority.Camera.Value - 1, function(_)
		debug.profilebegin("StickReplication")
		local v3 = nil

		for k, v4 in pairs(v2) do
			if StickController:Update(k, v4) then
				v3 = true
			end
		end

		if not v3 and flag then
			flag = nil
			RunService:UnbindFromRenderStep("StickReplication")
		end

		debug.profileend()
	end)
end

if RunService:IsServer() then
	replication.OnServerEvent:Connect(function(p)
		for k, v3 in pairs(v) do
			StickController:UpdateObjectReplication(k, v3, p)
		end
	end)
end

if RunService:IsClient() then
	replication.OnClientEvent:Connect(function(p, p2)
		v2[p] = p2
		StickController:ExecuteReplication()
	end)
	replication:FireServer()
end

return StickController