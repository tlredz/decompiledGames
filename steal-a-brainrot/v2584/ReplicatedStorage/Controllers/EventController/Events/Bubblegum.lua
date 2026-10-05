local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
game:GetService("Lighting")
game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local Bubblegum = {}
require(ReplicatedStorage.Controllers.AnimalController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
require(ReplicatedStorage.Controllers.CycleController)
local TimeUtils = require(ReplicatedStorage.Utils.TimeUtils)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Net = require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local remoteEvent = Net:RemoteEvent("EventService/Bubblegum/RollAnimation")
local remoteEvent2 = Net:RemoteEvent("EventService/Bubblegum/EmitBurst")
local name = script.Name
local maid = Trove.new()

function Bubblegum.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	maid:Add(Observers.observeTag("BubblegumMachine", function(object)
		return Observers.observeAttribute(object, "Hidden", function(p)
			if p then
				return nil
			end

			local displayText = object.Tank.BillboardGui.DisplayText
			local maid2 = Trove.new()
			local v = {}

			for _, v2 in object:QueryDescendants("BasePart.BubbleGumProgress"), nil, nil do
				v[v2] = {
					Position = v2.Position
				}
			end

			VFX.emit(object.Vfx.Goal)
			maid2:Add(task.spawn(function()
				SoundController:PlaySound("Sounds.Sfx.Bubblegum Machine.Apply", object.Goal.Position)
			end))
			maid2:Add(task.spawn(function()
				SoundController:PlaySound("Sounds.Sfx.Bubblegum Machine.Deactivation", object.Goal.Position)
			end))
			maid2:Add(Timer.Simple(1, function()
				local v2 = math.max(activeEventData.endsAt - workspace:GetServerTimeNow(), 0)
				displayText.Text = TimeUtils:E(v2)

				if not v then
					return
				end

				local v3 = math.lerp(0, 7.3, (math.clamp(v2 / 600, 0, 1)))

				for k, v4 in v do
					local v5 = (v3 - 7.3) / 2
					k.Size = Vector3.new(k.Size.X, k.Size.Y, v3)
					k.Position = v4.Position + createVector(0, 0, 1) * v5
				end
			end, true))
			return maid2:WrapClean()
		end)
	end))
end

function Bubblegum.OnStop(_)
	maid:Destroy()
end

function Bubblegum.OnLoad(_)
	remoteEvent2.OnClientEvent:Connect(function(instance)
		if not instance:GetAttribute("Hidden") then
			VFX.emit(instance.Vfx.bubblegumburst)
		end
	end)
	remoteEvent.OnClientEvent:Connect(function(p)
		local numberValue = Instance.new("NumberValue")

		for _, v in { p.Circle1, p.Circle2 } do
			local v2 = v
			numberValue.Changed:Connect(function(p2: number)
				v2.CFrame = CFrame.new(v2.CFrame.Position) * CFrame.Angles(0, -1.5707963267948966, p2)
			end)
		end

		local tween = TweenService:Create(
			numberValue,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Value = 6.283185307179586
			}
		)
		tween.Completed:Once(function()
			numberValue:Destroy()
		end)
		tween:Play()
	end)
end

return Bubblegum