local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local NyanCats = {}
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
require(ReplicatedStorage.Controllers.AnimalController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local MapInformation = require(ReplicatedStorage.Shared.MapInformation)
require(ReplicatedStorage.Packages.Synchronizer)
local ShakePresets = require(ReplicatedStorage.Shared.ShakePresets)
require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Shared.TweenPivot)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local MathUtils = require(ReplicatedStorage.Utils.MathUtils)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Shake)
local Net = require(ReplicatedStorage.Packages.Net)
local remoteEvent = Net:RemoteEvent("EventService/NyanCats/Struck")
local name = script.Name
local maid = Trove.new()
local currentCamera = workspace.CurrentCamera

local function getIslandExtents(terrain)
	local v = nil
	local v2 = nil

	for _, v3 in terrain:QueryDescendants("BasePart"), nil, nil do
		local cFrame = v3.CFrame
		local halfSize = v3.Size / 2
		local v5 = cFrame.RightVector:Abs() * halfSize.X + cFrame.UpVector:Abs() * halfSize.Y + cFrame.LookVector:Abs() * halfSize.Z
		local position = cFrame.Position

		if v then
			v = v:Min(position - v5)
		else
			v = position - v5
		end

		if v2 then
			v2 = v2:Max(position + v5)
		else
			v2 = position + v5
		end
	end

	return v, v2
end

function NyanCats.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	ReplicatedStorage:SetAttribute("NyanCatsEvent", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("NyanCatsEvent", nil)
	end)
	EffectController:Run(name, "Space")
	EffectController:Activate("Blink")
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	SoundController:UpdateOST()
	CycleController:Update()
	maid:Add(function()
		EffectController:Stop(name, "Space")
	end)
	local v = 30
	local v2 = 3
	local v3 = 35
	local v4 = 270
	local v5 = ServerData.IsBiggerServer() and 924 or 420
	local v6 = {}

	if ServerData.IsJumpLTMServer() then
		local track = workspace.Map:FindFirstChild("Track")

		if track then
			for i = 1, 7 do
				local child = track:FindFirstChild((tostring(i)))
				local island = child and child:FindFirstChild("Island")
				local terrain = island and island:FindFirstChild("Terrain")

				if not terrain then
					continue
				end

				local islandExtents, v7 = getIslandExtents(terrain)

				if not (islandExtents and v7) then
					continue
				end

				local v8 = #v6 + 1
				local v9 = v7.Y + 15 + (v8 - 1) % 3 * 12.5
				v6[v8] = {
					center = Vector3.new((islandExtents.X + v7.X) / 2, v9, (islandExtents.Z + v7.Z) / 2),
					radiusX = math.max((v7.X - islandExtents.X) / 2 + 45, 70),
					radiusZ = math.max((v7.Z - islandExtents.Z) / 2 + 45, 70)
				}
			end
		end

		if #v6 > 0 then
			v2 = #v6
			v = #v6 * 3
		else
			local mapVolume = workspace.Map:FindFirstChild("MapVolume")

			if mapVolume then
				v4 = mapVolume.Size.X * 0.8
				v5 = mapVolume.Size.Z * 0.8
				v3 = mapVolume.Size.Y / (v2 + 1)
			end
		end
	elseif ServerData.IsTsunamiServer() then
		v *= 2
		v4 *= 2
		v3 = 80
		v5 = 2804
	end

	local v7 = v / v2
	local isTsunamiServer = ServerData.IsTsunamiServer()

	local function getCatPosition(p: number, value: number?, p2: number?)
		local v8 = math.ceil(p / v7)
		local v9 = v6[v8]
		local v10 = (p % v7 + 1) / v7
		local v11

		if v9 then
			v11 = (value or 0) + p * 2.3999632297
		else
			v11 = (value or 0) + v8 + v10 * 3.141592653589793 * 2
		end

		local center

		if v9 then
			center = v9.center
		else
			center = MapInformation.MapCenter.Position + vector.create(0, v3 * v8 + 35, 0)
		end

		local radiusX

		if v9 then
			radiusX = v9.radiusX
		else
			radiusX = v4 * 0.5
		end

		local v12

		if v9 then
			v12 = v9.radiusZ
		else
			v12 = v5 * 0.5
		end

		local vector2 = vector.create(
			math.cos(v11) * radiusX,
			p2 or math.sin(os.clock() * 6) * 1.5,
			math.sin(v11) * v12
		)

		if not isTsunamiServer then
			return CFrame.lookAt(center + vector2, center)
		end

		local unit = Vector3.new(-math.sin(v11), 0, (math.cos(v11))).Unit
		local unit2 = (createVector(0, 1, 0)):Cross(unit).Unit
		local cross = unit:Cross(unit2)
		return CFrame.fromMatrix(center + vector2, unit2, cross) * CFrame.Angles(0, 1.5707963267948966, 0)
	end

	local v8 = table.create(v)

	for i = 1, v do
		local clone = maid:Clone(script.NyanCat)
		clone.Parent = workspace
		local track = clone.AnimationController.Animator:LoadAnimation(script.Animation)
		track.Looped = true
		track:Play()
		maid:Add(function()
			track:Stop(0)
			track:Destroy()
		end)
		local catPosition = getCatPosition(i)
		local motor6D = Instance.new("Motor6D")
		motor6D.Part0 = workspace.Terrain
		motor6D.Part1 = clone.RootPart
		motor6D.Transform = catPosition
		motor6D.Parent = clone.RootPart
		clone.RootPart.Anchored = false
		v8[i] = {
			model = clone,
			scale = clone:GetScale(),
			rootPart = clone.RootPart,
			motor = motor6D,
			state = {
				type = "hovering"
			},
			visualState = {
				cframe = catPosition
			}
		}
	end

	local rootParts = table.create(v)
	table.create(v)
	maid:Add(RunService.Stepped:Connect(function(_, dt: number)
		debug.profilebegin("Nyan Cats")
		local serverTimeNow = workspace:GetServerTimeNow()
		local v9 = math.rad((serverTimeNow - activeEventData.startedAt) * (#v6 > 0 and 20 or 10))
		local v10 = math.sin(serverTimeNow * 6) * 1.5

		for k, v11 in v8 do
			local v12 = nil

			if v11.state.type == "hovering" then
				v11.visualState.startCFrame = nil
				v12 = getCatPosition(k, v9, v10)
			elseif v11.state.type == "follow" or v11.state.type == "restore" then
				local v13 = v11.state.type == "restore"

				if v11.visualState.lastState ~= v11.state.type or not v11.visualState.startCFrame then
					v11.visualState.timer = 0
					v11.visualState.startCFrame = v11.visualState.cframe
					v11.visualState.lastState = v11.state.type
					local visualState = v11.visualState
					local cframe = v11.visualState.cframe
					local v14

					if v13 then
						v14 = CFrame.new(0, 100, 0)
					else
						v14 = CFrame.new(0, 40, -100)
					end

					visualState.p1 = cframe * v14
				end

				v11.visualState.timer += dt
				local lerpTime = v11.state.lerpTime or 3
				local position

				if v13 then
					position = getCatPosition(k, v9, v10).Position
				else
					position = v11.state.value
				end

				local v14 = math.clamp(v11.visualState.timer / lerpTime, 0, 1)
				local quadBezier = MathUtils.quadBezier(
					v14,
					v11.visualState.startCFrame.Position,
					v11.visualState.p1.Position,
					position
				)
				v12 = CFrame.lookAt(quadBezier, position + createVector(1e-6, 1e-6, 1e-6)) * CFrame.Angles(
					0,
					-1.5707963267948966 * math.clamp(v11.visualState.timer / (lerpTime * 0.5), 0, 1),
					0
				)
				local v15

				if v13 then
					v15 = math.lerp(0.5, v11.scale, v14)
				else
					v15 = math.lerp(v11.scale, 0.5, v14)
				end

				v11.model:ScaleTo(v15)

				if v13 and v14 >= 1 then
					v11.state = {
						type = "hovering"
					}
				end
			end

			v11.visualState.cframe = v12
			v11.motor.Transform = v12
			rootParts[k] = v11.rootPart
		end

		debug.profileend()
	end))
	maid:Add(remoteEvent.OnClientEvent:Connect(function(p: number, p2: string, p3: number, vector2: Vector3?)
		local lerpTime = p3 + 3 - workspace:GetServerTimeNow()
		local preRenderConnection = RunService.PreRender:Connect(function()
			debug.profilebegin("Update Nycan Cat Follow Target")
			v8[p].state = {
				type = "follow",
				value = vector2 or ClientEventUtils.getAnimalPosition(p2),
				lerpTime = lerpTime
			}
			debug.profileend()
		end)
		task.wait(lerpTime)
		preRenderConnection:Disconnect()
		v8[p].state = {
			type = "restore"
		}
		ClientEventUtils.playBurst(
			script.StruckVFX,
			vector2 or p2,
			{ ReplicatedStorage.Sounds.Events["Nyan Cats"].Hit }
		)

		if (currentCamera.CFrame.Position - (vector2 or ClientEventUtils.getAnimalPosition(p2))).Magnitude <= 70 then
			local clone = ShakePresets.Bump:Clone()
			maid:Add(clone)
			clone.Sustain = true
			maid:Add(ShakePresets.BindShakeToCamera(clone, currentCamera))
			clone:Start()
			maid:Add(task.delay(0.3, function()
				clone:StopSustain()
			end))
		end
	end))
end

function NyanCats.OnStop(_)
	maid:Destroy()
end

function NyanCats.OnLoad(_) end

return NyanCats