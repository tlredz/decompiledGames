local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local WinterHour = {}
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.AnimalController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local Observers = require(ReplicatedStorage.Packages.Observers)
local MathUtils = require(ReplicatedStorage.Utils.MathUtils)
require(ReplicatedStorage.Packages.FFlags)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Packages.Spr)
require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/Winter Hour/DestroyCandyCane")
local remoteEvent2 = Net:RemoteEvent("EventService/Winter Hour/SpawnCandyCane")
local remoteEvent3 = Net:RemoteEvent("EventService/Winter Hour/ClaimCandyCane")
local remoteEvent4 = Net:RemoteEvent("EventService/Winter Hour/Burst")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
local maid = Trove.new()

function WinterHour.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	local cartoon = Lighting:FindFirstChild("Cartoon")

	if cartoon then
		cartoon.Parent = script
		maid:Add(function()
			cartoon.Parent = Lighting
		end)
	end

	local clone = maid:Clone(script.CartoonSky)
	clone.Parent = Lighting
	EffectController:Run("WinterHourEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("WinterHourEvent", "GrassRecolor")
	end)
	EffectController:Run("WinterHourEvent", "WallRecolor")
	maid:Add(function()
		EffectController:Stop("WinterHourEvent", "WallRecolor")
	end)
	EffectController:Run("WinterHourEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("WinterHourEvent", "WallBottomRecolor")
	end)
	local clone_2 = maid:Clone(script.Map)
	clone_2.Parent = workspace
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	maid:Add(Observers.observeTag("HideInWinterHour", function(p)
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
	maid:Add(function()
		CycleController:Update()
		SoundController:UpdateOST()
	end)
end

function WinterHour.OnStop(_)
	maid:Destroy()
end

function WinterHour.OnLoad(_)
	remoteEvent4.OnClientEvent:Connect(function(p: string)
		ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events["Winter Hour"].Hit })
	end)
	local v = {}

	local function playCharacterAnimation(player, p)
		local character = player.Character

		if not character then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local clone = script.Reward:Clone()
		clone.CurrencyCandyCane.Text = `+{p}`
		clone.Parent = humanoidRootPart
		TweenService:Create(clone, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			StudsOffset = createVector(0, 2.5, 2.2)
		}):Play()
		TweenService:Create(
			clone.ImageLabel.ImageLabel,
			TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5),
			{
				ImageTransparency = 1
			}
		):Play()
		TweenService:Create(
			clone.CurrencyCandyCane,
			TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5),
			{
				TextTransparency = 1
			}
		):Play()
		TweenService:Create(
			clone.CurrencyCandyCane.UIStroke,
			TweenInfo.new(1.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 1.5),
			{
				Transparency = 1
			}
		):Play()
		task.delay(5, function()
			clone:Destroy()
		end)
	end

	local function playScreenCandyCaneAnimation(p)
		local random = Random.new()

		for _ = 1, math.min(p, 30) do
			local clone = script.Image:Clone()
			clone.Position = UDim2.fromScale(random:NextNumber(-0.25, 1.25), -(0.25 - random:NextNumber(0, 0.125)))
			clone.Rotation = random:NextNumber(-120, 120)
			local number = random:NextNumber(0.15, 0.2)
			clone.Size = UDim2.fromScale(number, number)
			clone.Parent = Players.LocalPlayer.PlayerGui:FindFirstChild("Effects")
			CreateTween(
				clone,
				TweenInfo.new(random:NextNumber(0.75, 1.3), Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					Position = clone.Position + UDim2.fromScale(0, 1.5),
					Rotation = clone.Rotation + random:NextInteger(-3, 3) * 10
				},
				true
			).Completed:Once(function()
				task.wait(1)
				clone:Destroy()
			end)
		end
	end

	remoteEvent3.OnClientEvent:Connect(function(p: string, player, p2: number)
		local v2 = v[p]

		if not v2 then
			return
		end

		local clone = v2:Clone()
		v2:Destroy()
		clone.Parent = workspace
		local position = clone:GetPivot().Position
		local total = 0
		local _ = clone.Size
		local v3 = nil
		v3 = maid:Add(RunService.PostSimulation:Connect(function(dt: number)
			debug.profilebegin("Winter Hour:UpdateCandyAnimation")
			total += dt
			local position2 = player.Character and player.Character:GetPivot().Position or createVector(0, 0, 0)
			local v4 = position + (position2 - position) * 0.25 + createVector(0, 10, 0)
			local value = TweenService:GetValue(total / 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
			clone:PivotTo(CFrame.new(MathUtils.quadBezier(value, position, v4, position2)))

			if value >= 1 and v3 then
				maid:Remove(v3)
				v3 = nil
				clone:Destroy()
				task.spawn(function()
					SoundController:PlaySound(ReplicatedStorage.Sounds.Events["North Pole"].CandyCane2, position2)
				end)

				if player == Players.LocalPlayer then
					playScreenCandyCaneAnimation(p2)
				end

				playCharacterAnimation(player, p2)
			end

			debug.profileend()
		end))
	end)
	remoteEvent2.OnClientEvent:Connect(function(name2: string, vector2: Vector3, position: Vector3, p: number, p2: number)
		local clone = script.Drop:Clone()
		clone.Name = name2
		v[name2] = clone
		clone.Parent = workspace
		local proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.Name = "ProximityPrompt"
		proximityPrompt.ActionText = ""
		proximityPrompt.RequiresLineOfSight = false
		proximityPrompt.Enabled = false
		proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
		proximityPrompt:SetAttribute("CustomStyleDisabled", true)
		proximityPrompt.Parent = clone
		local raycastResult = workspace:Raycast(
			position + createVector(0, 10, 0),
			createVector(-0, -30, -0),
			raycastParams
		)

		if raycastResult then
			position = raycastResult.Position or position
		end

		local v2 = vector2 + (position - vector2) * 0.5
		local v3 = math.random(0, 10000)
		local v4 = false
		local v5 = 0
		local postSimulationConnection = RunService.PostSimulation:Connect(function(_: number)
			local v6 = workspace:GetServerTimeNow() - p
			local value = TweenService:GetValue(
				p2 == 0 and 1 or math.clamp(v6 / p2, 0, 1),
				Enum.EasingStyle.Quint,
				Enum.EasingDirection.Out
			)
			local quadBezier = MathUtils.quadBezier(value, vector2, v2, position)
			local v8 = os.clock() + v3
			clone:PivotTo(CFrame.new(quadBezier + Vector3.new(0, math.sin(v8 * 4) * 0.5 + 4, 0)))

			if value >= 1 then
				proximityPrompt.Enabled = true
				local now = os.clock()

				if v4 and now - v5 > 0.2 then
					v5 = now
					remoteEvent3:FireServer(name2)
				end
			end
		end)
		clone.Destroying:Connect(function()
			postSimulationConnection:Disconnect()
		end)
		proximityPrompt.PromptShown:Connect(function()
			v4 = true
		end)
		proximityPrompt.PromptHidden:Connect(function()
			v4 = false
		end)
	end)
	remoteEvent.OnClientEvent:Connect(function(p: string)
		local v2 = v[p]

		if not v2 then
			return
		end

		v2:Destroy()
		v[p] = nil
	end)
end

return WinterHour