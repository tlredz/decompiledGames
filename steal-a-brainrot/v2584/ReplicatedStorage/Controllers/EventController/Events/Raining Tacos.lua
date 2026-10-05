local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local MapInformation = require(ReplicatedStorage.Shared.MapInformation)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local MathUtils = require(ReplicatedStorage.Utils.MathUtils)
local Spring = require(ReplicatedStorage.Packages.Spring)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local remoteEvent = Net:RemoteEvent("EventService/RainingTacos/Shoot")
local name = script.Name
local maid = Trove.new()
local _ = workspace.CurrentCamera
local RainingTacos = {}

function RainingTacos.OnStart(_)
	local isTsunamiServer = ServerData.IsTsunamiServer()
	assert((EventController:GetActiveEventData(name)))
	ReplicatedStorage:SetAttribute("RainingTacosEvent", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("RainingTacosEvent", nil)
		SoundController:UpdateOST()
		CycleController:Update()
	end)
	SoundController:UpdateOST()
	CycleController:Update()

	if ServerData.IsJumpLTMServer() then
		local clone = script.TacoAmbient:Clone()
		maid:Add(function()
			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.wait(5)
			clone:Destroy()
		end)
		clone:PivotTo(MapInformation.MapCenter.CFrame + createVector(0, 40, 0))
		clone.Parent = workspace
		maid:Add(remoteEvent.OnClientEvent:Connect(function(vector2: Vector3, p: number, value: number?)
			if typeof(vector2) ~= "Vector3" then
				return
			end

			local clone2 = script.Taco:Clone()
			clone2.Parent = workspace
			local v = vector2 + createVector(0, 250, 0)
			local v2 = value or 2.5
			local preRenderConnection = nil
			preRenderConnection = RunService.PreRender:Connect(function()
				debug.profilebegin("Raining Tacos")
				local v3 = math.clamp(1 - (p + v2 - workspace:GetServerTimeNow()) / v2, 0, 1)
				local lerped = v:Lerp(vector2, v3)
				local lerped2 = v:Lerp(vector2, v3 + 0.1)
				clone2.CFrame = CFrame.lookAt(lerped, lerped2)

				if v3 >= 1 then
					preRenderConnection:Disconnect()
					clone2:Destroy()
					ClientEventUtils.playBurst(
						script.StruckVFX,
						vector2,
						{ ReplicatedStorage.Sounds.Events["Raining Tacos"].Hit }
					)
				end

				debug.profileend()
			end)
		end))
	else
		local clone = maid:Clone(script.Cannon)
		local pivot = clone:GetPivot()

		local function updateCannonPosition()
			local v = pivot

			if isTsunamiServer then
				v = CFrame.new(-411.413, 55.718, 262.401) * CFrame.fromOrientation(0, 1.5707963267948966, 0)
			elseif ServerData.IsBiggerServer() then
				v = CFrame.new(-410.091, 24.718, -393.962) * CFrame.fromOrientation(0, -1.5707963267948966, 0)
			end

			if not isTsunamiServer and ReplicatedStorage:GetAttribute("DivineStairsEnabled") == true then
				v -= createVector(0, 11, 0)
			end

			clone:PivotTo(v)
		end

		if not isTsunamiServer then
			maid:Add(ReplicatedStorage:GetAttributeChangedSignal("DivineStairsEnabled"):Connect(updateCannonPosition))
		end

		updateCannonPosition()
		maid:Add(Observers.observeTag("HideInRainingTacos", function(p)
			local parent = p.Parent
			p.Parent = script
			return function()
				pcall(function()
					p.Parent = parent
				end)
			end
		end, { workspace, script }))
		clone.Parent = workspace
		local clone2

		if ServerData.IsBiggerServer() then
			clone2 = script.TacoAmbientBigger:Clone()
		else
			clone2 = script.TacoAmbient:Clone()
		end

		maid:Add(function()
			for _, emitter in clone2:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.wait(5)
			clone2:Destroy()
		end)
		clone2:PivotTo(MapInformation.MapCenter.CFrame + createVector(0, 40, 0))
		clone2.Parent = workspace
		local meshestacolauncher_Cube003 = clone.Top["Meshes/tacolauncher_Cube.004"]["Meshes/tacolauncher_Cube.003"]
		local meshestacolauncher_Cube004 = clone.Bottom.RootPart["Meshes/tacolauncher_Cube.004"]
		local v = Spring.new(0)
		v.Speed = 6.5
		v.Damper = 0.85
		local v2 = Spring.new(0)
		v2.Speed = 9
		v2.Damper = 0.6
		maid:Add(RunService.PostSimulation:Connect(function(_)
			debug.profilebegin("Raining Tacos Cannon Spring")
			meshestacolauncher_Cube003.C1 = CFrame.new(v.Position, 0, 0)
			meshestacolauncher_Cube004.C1 = CFrame.Angles(0, 0, -math.rad(v2.Position))
			debug.profileend()
		end))
		maid:Add(remoteEvent.OnClientEvent:Connect(function(p: string, p2: number, value: number?)
			local clone3 = script.Taco:Clone()
			clone3.Parent = workspace
			task.spawn(function()
				SoundController:PlaySound(
					ReplicatedStorage.Sounds.Events["Raining Tacos"].Shoot,
					clone:GetPivot().Position
				)
			end)
			task.spawn(function()
				v2:Impulse(650)
				task.wait(0.05)
				v:Impulse(35)
			end)
			local position = clone.ShootPart.CFrame.Position
			local v3 = value or 2.5
			local preRenderConnection = nil
			preRenderConnection = RunService.PreRender:Connect(function()
				debug.profilebegin("Raining Tacos")
				local animalPosition = ClientEventUtils.getAnimalPosition(p)

				if not animalPosition then
					return
				end

				local v5 = position + (animalPosition - position) * 0.5 + Vector3.new(
					0,
					isTsunamiServer and 120 or 60,
					0
				)
				local v6 = math.clamp(1 - (p2 + v3 - workspace:GetServerTimeNow()) / v3, 0, 1)
				local quadBezier = MathUtils.quadBezier(v6, position, v5, animalPosition)
				local quadBezier2 = MathUtils.quadBezier(v6 + 0.1, position, v5, animalPosition)
				clone3.CFrame = CFrame.lookAt(quadBezier, quadBezier2)

				if v6 >= 1 then
					preRenderConnection:Disconnect()
					clone3:Destroy()
					ClientEventUtils.playBurst(
						script.StruckVFX,
						p,
						{ ReplicatedStorage.Sounds.Events["Raining Tacos"].Hit }
					)
				end

				debug.profileend()
			end)
		end))
	end
end

function RainingTacos.OnStop(_)
	maid:Destroy()
end

function RainingTacos.OnLoad(_) end

return RainingTacos