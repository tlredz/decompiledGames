local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local _4thOfJuly = {}
require(ReplicatedStorage.Controllers.AnimalController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local SharedEventUtils = require(ReplicatedStorage.Shared.SharedEventUtils)
require(ReplicatedStorage.Packages.Synchronizer)
local ShakePresets = require(ReplicatedStorage.Shared.ShakePresets)
require(ReplicatedStorage.Packages.Observers)
local MathUtils = require(ReplicatedStorage.Utils.MathUtils)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local remoteEvent = Net:RemoteEvent("EventService/4th of July/CreateFirework")
local remoteEvent2 = Net:RemoteEvent("EventService/4th of July/ExplodeTraitEffect")
local name = script.Name
local maid = Trove.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace:WaitForChild("Map"), workspace:WaitForChild("Plots") }

function _4thOfJuly.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	ReplicatedStorage:SetAttribute("4thOfJulyEvent", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("4thOfJulyEvent", nil)
	end)
	SoundController:UpdateOST()
	CycleController:Update()
	local clone = ReplicatedStorage.Models.Events["4th of July"].Fireworks:Clone()
	clone.Parent = workspace
	local children = clone:GetChildren()
	table.sort(children, function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)
	local cFrames = {}

	for _, v in children do
		cFrames[v] = v.CFrame
	end

	local clone2 = ShakePresets.BumpS:Clone()
	maid:Add(clone2)
	clone2.Sustain = true
	maid:Add(ShakePresets.BindShakeToCamera(clone2, workspace.CurrentCamera))
	clone2:Start()
	maid:Add(task.delay(activeEventData.startedAt + 4 - workspace:GetServerTimeNow(), function()
		clone2:StopSustain()
	end))
	maid:Add(function()
		for _, v in children do
			TweenService:Create(
				v,
				TweenInfo.new(1 + math.random() + math.random(), Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					CFrame = cFrames[v] - Vector3.new(0, v.Size.Y * 1.1, 0)
				}
			):Play()
		end

		task.wait(3)
		clone:Destroy()
	end)
	maid:Add(remoteEvent.OnClientEvent:Connect(function(items)
		for _, item in items do
			local v = children[item.Chosen]
			local clone3 = script.Firework:Clone()
			clone3.CFrame = cFrames[v]
			clone3.Parent = workspace
			local clone4 = script.FireworkStartup:Clone()
			clone4.CFrame = cFrames[v] + Vector3.new(0, v.Size.Y * 0.5 - clone4.Size.Y * 0.5, 0)
			clone4.Parent = workspace
			VFX.emit(clone4)
			local clone5 = ReplicatedStorage.Sounds.Events["4th of July"]["Trail Sound Ball"]:Clone()
			clone5.Parent = clone3
			SoundController:PlaySound(clone5)
			local clone6 = ReplicatedStorage.Sounds.Events["4th of July"].Shot:Clone()
			clone6.Parent = clone4
			SoundController:PlaySound(clone6)
			task.delay(2, function()
				clone4:Destroy()
			end)
			local v3 = cFrames[v] - Vector3.new(0, v.Size.Y, 0)
			local cFrame = cFrames[v] + Vector3.new(0, item.Height, 0)
			local v5 = item.Height / 20
			local tween = TweenService:Create(
				clone3,
				TweenInfo.new(v5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					CFrame = cFrame
				}
			)
			tween:Play()
			local v8 = item
			task.delay(v5 * 0.8, function()
				tween:Destroy()
				SoundController:PlaySound(
					ReplicatedStorage.Sounds.Events["4th of July"]["Firework Explosion"],
					cFrame.Position
				)
				local clone7 = script.Effects[tostring(v8.FireworkEffect)]:Clone()
				clone7.CFrame = cFrame
				clone7.Parent = workspace
				VFX.emit(clone7)
				clone3:Destroy()
				task.delay(4, function()
					clone7:Destroy()
				end)

				for k, falloff in v8.Falloffs do
					local cframe

					if typeof(falloff) == "Vector3" then
						cframe = v3 + falloff
						local raycastResult = workspace:Raycast(
							(cFrame + falloff).Position,
							createVector(-0, -200, -0),
							raycastParams
						)

						if raycastResult then
							cframe = CFrame.new(raycastResult.Position)
						end
					else
						cframe = nil
					end

					local clone8 = script.Falloff:Clone()
					clone8.CFrame = cFrame
					clone8.Parent = workspace
					local total = 0
					local postSimulationConnection = nil
					local v11 = falloff
					postSimulationConnection = RunService.PostSimulation:Connect(function(dt: number)
						debug.profilebegin("4th of July:Falloff")
						total += dt
						local cframe2 = cframe

						if not cframe2 and type(v11) == "string" then
							cframe2 = CFrame.new(ClientEventUtils.getAnimalPosition(v11))
						end

						local v13 = cframe2 or CFrame.identity
						local v14 = total / 2.3
						SharedEventUtils.pushPartCFrame(
							clone8,
							CFrame.new(MathUtils.quadBezier(
								v14,
								cFrame.Position,
								cFrame.Position + Vector3.new(0, v8.Height, 0) + (v13.Position - cFrame.Position) * createVector(
									1,
									0,
									1
								) * 0.7,
								v13.Position
							))
						)

						if v14 >= 1 and type(v11) ~= "string" then
							local clone9 = script.GroundImpact:Clone()
							clone9.CFrame = v13 + Vector3.new(0, clone9.Size.Y * 0.5, 0)
							clone9.Parent = workspace
							VFX.emit(clone9)
							VFX.disable(clone8)
							task.delay(3, function()
								clone8:Destroy()
								clone9:Destroy()
							end)
							postSimulationConnection:Disconnect()
						end

						debug.profileend()
					end)
				end
			end)
		end
	end))
	local random = Random.new()

	for _, v in children do
		v.CFrame = cFrames[v] - Vector3.new(0, v.Size.Y * 1.1, 0)
		local tween = TweenService:Create(
			v,
			TweenInfo.new(random:NextNumber(3, 7), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				CFrame = cFrames[v]
			}
		)
		local v4 = maid:Add(function()
			tween:Cancel()
			tween:Destroy()
		end)
		tween.Completed:Once(function()
			maid:Remove(v4)
		end)
		tween:Play()
	end
end

function _4thOfJuly.OnStop(_)
	maid:Destroy()
end

function _4thOfJuly.OnLoad(_)
	remoteEvent2.OnClientEvent:Connect(function(p)
		ClientEventUtils.playBurst(
			script.FireworkBurst,
			p,
			{ ReplicatedStorage.Sounds.Events["4th of July"]["Brainrot Hit"] }
		)
	end)
end

return _4thOfJuly