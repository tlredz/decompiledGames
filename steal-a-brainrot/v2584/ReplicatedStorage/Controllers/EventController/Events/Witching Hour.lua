local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
require(ReplicatedStorage.Shared.EventTypes)
local WitchingHour = {}
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.AnimalController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local Observers = require(ReplicatedStorage.Packages.Observers)
local MathUtils = require(ReplicatedStorage.Utils.MathUtils)
require(ReplicatedStorage.Packages.FFlags)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local Spr = require(ReplicatedStorage.Packages.Spr)
require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/WitchingHour/Projectile")
local remoteEvent2 = Net:RemoteEvent("EventService/WitchingHour/Burst")
local maid = Trove.new()

function WitchingHour.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	local cartoon = Lighting:FindFirstChild("Cartoon")

	if cartoon then
		cartoon.Parent = script
		maid:Add(function()
			cartoon.Parent = Lighting
		end)
	end

	local clone = maid:Clone(script.PurpleSky)
	clone.Parent = Lighting
	EffectController:Run("WitchingHourEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("WitchingHourEvent", "GrassRecolor")
	end)
	EffectController:Run("WitchingHourEvent", "WallRecolor")
	maid:Add(function()
		EffectController:Stop("WitchingHourEvent", "WallRecolor")
	end)
	EffectController:Run("WitchingHourEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("WitchingHourEvent", "WallBottomRecolor")
	end)
	local clone_2 = maid:Clone(script.Map)
	clone_2.Parent = workspace
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	maid:Add(Observers.observeTag("HideInWitchingHour", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
	CycleController:Update()
	SoundController:UpdateOST()
	EffectController:Activate("Blink")
end

function WitchingHour.OnStop(_)
	maid:Destroy()
end

function WitchingHour.OnLoad(_)
	remoteEvent.OnClientEvent:Connect(function(p: string, p2: number, p3: number, p4: number, p5: number)
		local model = workspace.Events["Witching Hour"]:FindFirstChild("Model")
		local sammy = model and model:FindFirstChild("Sammy")

		if not sammy then
			return
		end

		local track = sammy.Humanoid.Animator:LoadAnimation(script.Shoot)
		track.Looped = false
		track:Play()
		track.Ended:Once(function()
			track:Stop()
			track:Destroy()
		end)
		local v = false
		local worldCFrame = sammy["Cylinder.001"].Attachment.WorldCFrame
		local clone = script.Projectile:Clone()
		local v2 = p2 + p4
		local v3 = v2 + p3
		local v4 = math.min(p5 * 0.5, 50)
		local v5 = Random.new():NextUnitVector() * (Random.new():NextInteger(0, 1) * 2 - 1) * v4 * 0.65
		local vector2 = Vector3.new(v5.X, Random.new():NextNumber(-2, 7) * (v4 / 50), v5.Z)
		local v6 = Random.new():NextUnitVector() * (Random.new():NextInteger(0, 1) * 2 - 1) * v4
		local vector3 = Vector3.new(v6.X, Random.new():NextNumber(-2, 7) * (v4 / 50), v6.Z)

		if p5 <= 15 then
			vector2 = createVector(0, 0, 0)
			vector3 = createVector(0, 0, 0)
		end

		local preRenderConnection = nil
		preRenderConnection = RunService.PreRender:Connect(function()
			local serverTimeNow = workspace:GetServerTimeNow()
			local v7 = math.max(v3 - serverTimeNow, 0)
			local v8 = serverTimeNow < v2 and 0 or 1 - v7 / p3

			if v8 >= 1 then
				preRenderConnection:Disconnect()
				clone:Destroy()
			else
				if v8 > 0 and not v then
					v = true
					worldCFrame = sammy["Cylinder.001"].Attachment.WorldCFrame
					clone.Parent = workspace
					task.spawn(function()
						SoundController:PlaySound(
							ReplicatedStorage.Sounds.Events["Witching Hour"].Shot,
							worldCFrame.Position
						)
					end)
				end

				local position = worldCFrame.Position
				local animalPosition = ClientEventUtils.getAnimalPosition(p)
				clone.CFrame = CFrame.new(MathUtils.cubicBezier(
					v8,
					position,
					position:Lerp(animalPosition, 0.4) + vector2,
					position:Lerp(animalPosition, 0.8) + vector3,
					animalPosition
				))
				local waist = sammy.UpperTorso.Waist
				local C0 = waist:GetAttribute("C0")

				if not C0 then
					C0 = waist.C0
					waist:SetAttribute("C0", C0)
				end

				if v8 >= 0.8 then
					Spr.target(waist, 1, 2, {
						C0 = C0
					})
					return
				end

				local cFrame = sammy.HumanoidRootPart.CFrame
				local vectorToObjectSpace = cFrame:VectorToObjectSpace((animalPosition - cFrame.Position).Unit)
				local v9 = math.clamp(
					math.atan2(-vectorToObjectSpace.X, -vectorToObjectSpace.Z),
					-1.0471975511965976,
					1.0471975511965976
				)
				local v10 = math.clamp(
					math.asin((math.clamp(vectorToObjectSpace.Y, -1, 1))),
					-0.2617993877991494,
					0.2617993877991494
				)
				Spr.target(waist, 1, 2, {
					C0 = C0 * CFrame.Angles(v10, v9, 0)
				})
			end
		end)
	end)
	remoteEvent2.OnClientEvent:Connect(function(p: string)
		ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events["Witching Hour"].Hit })
	end)
end

return WitchingHour