local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
local inverse = CFrame.lookAt(Vector3.new(), createVector(-1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor

local function RandomVectorOffsetBetween(p, p2, p3)
	return (CFrame.lookAt(Vector3.new(), p) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p3), (math.cos(p2))))),
		0,
		0
	)).LookVector
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { Workspace.Map }
local CreatePortal = require(script.Parent:WaitForChild("CreatePortal"))

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

local function ScaleModel(folder, modelScale, p)
	local modelScale2 = folder:GetAttribute("ModelScale")
	local v = modelScale2 == nil and 1 or modelScale2
	local v2 = p or folder:GetPivot().Position
	local v3 = modelScale / v

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Size *= Vector3.new(v3, v3, v3)
		part.CFrame = part.CFrame.Rotation + v2 + (part.Position - v2) * v3
	end

	folder:SetAttribute("ModelScale", modelScale)
end

return function(data)
	local player = data.player
	local origin = data.origin
	local impactPos = data.impactPos
	local fireDir = data.fireDir
	local enemyRoot = data.enemyRoot
	local syncedEndTime = data.syncedEndTime
	local portalLoopTime = data.portalLoopTime
	local timeUntilImpactAfterFinalPortal = data.timeUntilImpactAfterFinalPortal

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 900 or enemyRoot == nil or enemyRoot.Parent == nil or syncedEndTime - Workspace:GetServerTimeNow() - 0.05 <= 0 then
		return
	end

	local cFrame = enemyRoot.CFrame
	local v = {}
	table.insert(v, RunService.Heartbeat:Connect(function()
		if not (syncedEndTime < Workspace:GetServerTimeNow()) and enemyRoot.Parent ~= nil then
			enemyRoot.CFrame = cFrame
			return
		end

		for _, connection in v do
			connection:Disconnect()
		end
	end))
	local origin2 = origin + fireDir * 37 + createVector(0, 3, 0)
	CreatePortal({
		player = player,
		origin = origin2,
		lookDir = -fireDir,
		lastsFor = 0.5
	})
	table.insert(v, heartbeatLoopFor2(0.2, function(_, _, p)
		cFrame = cFrame.Rotation + origin + (origin2 - origin) * p
	end))
	local clone = FX:WaitForChild("PortalEffects").ZPunchHit:Clone()
	clone.CFrame = CFrame.new(origin)
	Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "PortalFruitVFXColor")
	destroyAfter(clone, 1.5)

	for _, child in ipairs(clone.Attachment:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end

	heartbeatLoopFor2(0.45, function(_, _, p)
		clone.LightAttachment.PointLight.Brightness = (1 - math.abs(1 - 2 * p)) * 14
	end, function()
		clone.LightAttachment.PointLight.Enabled = false
	end)
	Util.Sound:Play("ZPortalPunch", origin)
	task.wait(0.2)
	local v3 = (syncedEndTime - Workspace:GetServerTimeNow()) * portalLoopTime / (portalLoopTime + timeUntilImpactAfterFinalPortal)
	local v4 = impactPos + createVector(0, 30, 0)
	local lookVector = RandomVectorOffsetBetween(createVector(0, 1, 0), 0.5235987755982988, 2.6179938779914944)
	local origin3 = v4 + lookVector * random:NextNumber(18, 30.5)
	local origin4 = v4 - lookVector * random:NextNumber(18, 30.5)
	CreatePortal({
		player = player,
		origin = origin3,
		lookDir = (origin4 - origin3).Unit,
		lastsFor = 0.5,
		emitLightShockwave = true
	})
	local total = 0.16666666666666666
	local v8 = 0
	local v9 = false
	table.insert(v, heartbeatLoopFor2(v3, function(_, _, p)
		if not (v8 <= p and p < total) then
			v8 = total
			total += 0.16666666666666666

			if v9 == false then
				CreatePortal({
					player = player,
					origin = origin4,
					lookDir = -(origin4 - origin3).Unit,
					lastsFor = 0.5
				})
				v9 = true
			else
				local lookVector2 = RandomVectorOffsetBetween(
					createVector(0, 1, 0),
					0.5235987755982988,
					2.6179938779914944
				)
				local v11 = v4 + lookVector2 * random:NextNumber(18, 30.5)
				local v12 = v4 - lookVector2 * random:NextNumber(18, 30.5)
				origin3 = v11
				origin4 = v12
				CreatePortal({
					player = player,
					origin = origin3,
					lookDir = (origin4 - origin3).Unit,
					lastsFor = 0.5,
					emitLightShockwave = true
				})
				v9 = false
			end
		end

		local v10 = 0.5 * ((p - v8) / (total - v8)) + (v9 and 0.5 or 0)
		cFrame = CFrame.lookAt(createVector(0, 0, 0), (origin4 - origin3).Unit) + origin3 + (origin4 - origin3) * v10
	end))
	task.wait(v3)
	local v10 = syncedEndTime - Workspace:GetServerTimeNow()
	local origin5 = impactPos + createVector(0, 42, 0)
	CreatePortal({
		player = player,
		origin = origin5,
		lookDir = CFrame.Angles(-1.5707963267948966, 0, 0).LookVector,
		lastsFor = 0.5,
		emitDarkShockwave = true
	})
	local v12 = impactPos + createVector(0, 2, 0)
	table.insert(v, heartbeatLoopFor2(v10, function(_, _, p)
		cFrame = CFrame.Angles(-1.5676547341413067, 0, 0) + origin5 + (v12 - origin5) * p
	end))
	local clone2 = FX:WaitForChild("PortalEffects").DashAura:Clone()
	local magnitude = (v12 - origin5).Magnitude
	local objectSpace = clone2:GetAttribute("ObjectSpace")
	local cframe = CFrame.lookAt(origin5, origin5 + createVector(-0, -1, -0))
	clone2:PivotTo(CFrame.lookAt(createVector(0, 0, 0), createVector(-0, -1, -0)) * inverse + cframe:PointToWorldSpace(objectSpace))
	Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "PortalFruitVFXColor")
	destroyAfter(clone2, v10 + 1)
	heartbeatLoopFor2(v10, function(_, _, p)
		local cframe2 = CFrame.lookAt(origin5, origin5 + createVector(-0, -1, -0)) * CFrame.new(0, 0, -p * magnitude)
		clone2:PivotTo(CFrame.lookAt(createVector(0, 0, 0), createVector(-0, -1, -0)) * inverse + cframe2:PointToWorldSpace(objectSpace))
	end, function()
		clone2.BeamInner.Beams:Destroy()
		clone2.BeamInnerDark.Beams:Destroy()
	end)
	task.wait(v10)
	local ray = Util.Ray
	local v13 = v12
	local v14 = { Workspace.Characters, Workspace.Enemies, _WorldOrigin }
	local v15, v16, v17 = ray(v13, createVector(-0, -5, -0), v14, false)

	if v15 == nil then
		v12 -= createVector(0, 2, 0)
		v17 = createVector(0, 1, 0)
	else
		v12 = v16
	end

	if (v12 - Workspace.CurrentCamera.CFrame.Position).Magnitude < 100 then
		local v18 = 1 - (v12 - Workspace.CurrentCamera.CFrame.Position).Magnitude / 100
		Util.CameraShaker:ShakeOnce(18.5 * v18, 10 * v18, 0, 1.6)
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "PortalZColorInvert"
		colorCorrectionEffect.Contrast = 2
		colorCorrectionEffect.TintColor = Util.WrapColor3ConstructorForTintColor(
			Color3.fromRGB(41, 73, 255),
			player,
			"PortalFruitVFXColor"
		)
		Util.SetParentOverrideWithColor(colorCorrectionEffect, Lighting, player, "PortalFruitVFXColor")
		local bloomEffect = Instance.new("BloomEffect")
		bloomEffect.Name = "PortalZBloom"
		bloomEffect.Intensity = 1.5
		bloomEffect.Threshold = 1
		bloomEffect.Size = 36
		Util.SetParentOverrideWithColor(bloomEffect, Lighting, player, "PortalFruitVFXColor")
		heartbeatLoopFor2(0.4, function(_, _, p)
			bloomEffect.Intensity = 1.5 - 0.5 * p
			bloomEffect.Threshold = 1 + p
			bloomEffect.Size = 36 - 12 * p
		end, function()
			bloomEffect:Destroy()
		end)
		task.delay(0.1, function()
			colorCorrectionEffect.Contrast = 1.5
			colorCorrectionEffect.Saturation = -1 - Lighting.GlobalColorCorrection.Saturation
			colorCorrectionEffect.TintColor = Util.WrapColor3ConstructorForTintColor(
				Color3.new(1, 1, 1),
				player,
				"PortalFruitVFXColor"
			)
			task.wait(0.1)
			colorCorrectionEffect:Destroy()
		end)
	end

	Util.Sound:Play("PortalDashImpact", v12)
	local clone3 = FX:WaitForChild("PortalEffects").ZImpact:Clone()
	clone3.CFrame = CFrame.lookAt(createVector(0, 0, 0), v17) * inverse + v12
	Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player, "PortalFruitVFXColor")
	destroyAfter(clone3, 3.5)

	for _, child in ipairs(clone3.Attachment:GetChildren()) do
		emitWithDelay(child)
	end

	emitWithDelay(clone3.Lightning)
	emitWithDelay(clone3.ParticleEmitter)

	if v15 ~= nil then
		for _, child in ipairs(clone3.GroundAttachment:GetChildren()) do
			emitWithDelay(child)
		end
	end

	heartbeatLoopFor2(0.9, function(_, _, p)
		clone3.PointLight.Brightness = (1 - math.abs(1 - 2 * p)) * 10
	end, function()
		clone3.PointLight.Enabled = false
	end)

	if v15 ~= nil then
		local clone4 = FX:WaitForChild("PortalEffects").Rocks:Clone()
		clone4:PivotTo(clone3.CFrame:ToWorldSpace(clone4:GetAttribute("ObjectSpace")))
		ScaleModel(clone4, 0.5)
		Util.SetParentOverrideWithColor(clone4, _WorldOrigin, player, "PortalFruitVFXColor")
		destroyAfter(clone4, 3.5)
		heartbeatLoopFor2(0.4, function(_, _, p)
			ScaleModel(clone4, 0.5 + 1.5 * p ^ 0.3)
		end, function()
			ScaleModel(clone4, 2)
		end)
		task.delay(2, function()
			local rocksOuter = clone4.RocksOuter
			local pivot = rocksOuter:GetPivot()
			heartbeatLoopFor2(0.25, function(_, _, p)
				rocksOuter:PivotTo(pivot - v17 * 8.4 * p)
			end, function()
				rocksOuter:PivotTo(pivot - v17 * 8.4)
			end)
		end)
		task.delay(2.1, function()
			local rocksInner = clone4.RocksInner
			local pivot = rocksInner:GetPivot()
			heartbeatLoopFor2(0.25, function(_, _, p)
				rocksInner:PivotTo(pivot - v17 * 4.4 * p)
			end, function()
				rocksInner:PivotTo(pivot - v17 * 4.4)
			end)
		end)
	end
end