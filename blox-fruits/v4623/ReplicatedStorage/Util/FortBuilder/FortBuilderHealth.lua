local RunService = game:GetService("RunService")
local FortBuilderHealth = {}
local HeartbeatLoopFor = require(script.Parent.Parent:WaitForChild("HeartbeatLoopFor"))
local heartbeatLoopFor = HeartbeatLoopFor.HeartbeatLoopFor
local v

if RunService:IsServer() then
	v = Instance.new("UnreliableRemoteEvent")
	v.Name = "FortBuilderHealthDamageVFX"
	v.Parent = game:GetService("ReplicatedStorage")
else
	repeat
		task.wait()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
	until ReplicatedStorage:FindFirstChild("FortBuilderHealthDamageVFX")

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	v = ReplicatedStorage:FindFirstChild("FortBuilderHealthDamageVFX")
	v.OnClientEvent:Connect(function(p)
		FortBuilderHealth.playSurfaceDamageAnimationClient(p)
	end)
end

function FortBuilderHealth.checkHasHealthComponent(instance)
	local fortBuilderHP = instance:GetAttribute("FortBuilderHP")
	local fortBuilderMaxHP = instance:GetAttribute("FortBuilderMaxHP")
	return fortBuilderHP ~= nil and fortBuilderMaxHP ~= nil
end

function FortBuilderHealth.insertHealthComponent(instance, value: number?)
	if not RunService:IsServer() then
		error("FortBuilderHealth.damageSurface can only be invoked on the server!")
	end

	local v2 = value or 100

	if instance:GetAttribute("FortBuilderHP") == nil then
		instance:SetAttribute("FortBuilderHP", v2)
	end

	if instance:GetAttribute("FortBuilderMaxHP") == nil then
		instance:SetAttribute("FortBuilderMaxHP", 100)
	end
end

local random = Random.new()

function FortBuilderHealth.playSurfaceDamageAnimationClient(instance)
	if RunService:IsServer() then
		error("FortBuilderHealth.playSurfaceDamageAnimationClient can only be invoked on the client!")
	end

	if instance == nil or instance.Parent == nil then
		return
	end

	local Global = require(game.ReplicatedStorage.Global)
	local clientFortBuilder = Global.ClientFortBuilder

	if not clientFortBuilder then
		error("Client FortBuilder not found")
		return
	end

	game:GetService("TweenService")
	local matchingClientPart = clientFortBuilder:getMatchingClientPart(
		instance:GetAttribute("BuildMode"),
		instance:GetAttribute("VoxelCellCoordinates"),
		instance:GetAttribute("VoxelDirectionFromNormalId")
	)

	if matchingClientPart == nil then
		return
	end

	local model = matchingClientPart:FindFirstChild("Model")

	if model == nil then
		return
	end

	local collisionModel = matchingClientPart:FindFirstChild("CollisionModel")

	if matchingClientPart:GetAttribute("DamageAnimationActive") == true then
		return
	end

	matchingClientPart:SetAttribute("DamageAnimationActive", true)
	local cFrame = matchingClientPart.CFrame
	local pivot = model:GetPivot()
	local pivot2

	if collisionModel then
		pivot2 = collisionModel:GetPivot()
	else
		pivot2 = nil
	end

	local vector3Value = Instance.new("Vector3Value")
	vector3Value.Value = random:NextUnitVector() * 4
	local valueChangedConnection = vector3Value:GetPropertyChangedSignal("Value"):Connect(function()
		local value = vector3Value.Value
		matchingClientPart.CFrame = cFrame + value
		model:PivotTo(pivot + value)

		if collisionModel then
			collisionModel:PivotTo(pivot2 + value)
		end
	end)
	local value = vector3Value.Value
	heartbeatLoopFor(0.4, function(_, _, p)
		vector3Value.Value = value * (1 - p ^ 2) * math.cos(21.991148575128552 * p)
	end, function()
		valueChangedConnection:Disconnect()
		matchingClientPart.CFrame = cFrame
		model:PivotTo(pivot)

		if collisionModel then
			collisionModel:PivotTo(pivot2)
		end

		matchingClientPart:SetAttribute("DamageAnimationActive", false)

		if vector3Value and vector3Value.Parent ~= nil then
			vector3Value:Destroy()
		end
	end)
end

function FortBuilderHealth.playSurfaceDamageAnimationServer(p)
	if not RunService:IsServer() then
		error("FortBuilderHealth.playSurfaceDamageAnimationServer can only be invoked on the server!")
	end

	v:FireAllClients(p)
end

function FortBuilderHealth.damageSurface(instance, p: number, p2)
	if not RunService:IsServer() then
		error("FortBuilderHealth.damageSurface can only be invoked on the server!")
	end

	local Global = require(game.ReplicatedStorage.Global)
	local serverFortBuilder = Global.ServerFortBuilder

	if not serverFortBuilder then
		error("Server FortBuilder not found")
		return
	end

	if p2 ~= nil and serverFortBuilder:isPlayerAllowedToDelete(p2, instance) then
		return
	end

	assert(serverFortBuilder, "No valid FortBuilder passed to damageSurface()")
	assert(instance, "No surface given to damageSurface()")
	FortBuilderHealth.insertHealthComponent(instance, 100)
	local fortBuilderHP = instance:GetAttribute("FortBuilderHP")
	local fortBuilderMaxHP = instance:GetAttribute("FortBuilderMaxHP")
	local v2 = math.clamp(fortBuilderHP - p, 0, fortBuilderMaxHP)
	instance:SetAttribute("FortBuilderHP", v2)

	if v2 <= 0 then
		local voxelCellCoordinates = instance:GetAttribute("VoxelCellCoordinates")
		local voxelDirectionFromNormalId = instance:GetAttribute("VoxelDirectionFromNormalId")

		if voxelCellCoordinates and voxelDirectionFromNormalId then
			serverFortBuilder:deleteSurface(
				instance,
				serverFortBuilder.voxelGrid:CellToWorldCenter(voxelCellCoordinates),
				voxelDirectionFromNormalId,
				true
			)
		end
	elseif p > 0 then
		FortBuilderHealth.playSurfaceDamageAnimationServer(instance)
	end
end

return FortBuilderHealth