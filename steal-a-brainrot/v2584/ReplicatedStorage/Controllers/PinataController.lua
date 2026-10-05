local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local MathUtils = require(ReplicatedStorage.Utils.MathUtils)
local Net = require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local remoteEvent = Net:RemoteEvent("PinataService/DestroyGear")
local remoteEvent2 = Net:RemoteEvent("PinataService/SpawnGear")
local remoteEvent3 = Net:RemoteEvent("PinataService/PickGear")
local remoteEvent4 = Net:RemoteEvent("PinataService/Blink")
local remoteEvent5 = Net:RemoteEvent("PinataService/Burst")
local remoteEvent6 = Net:RemoteEvent("PinataService/Hit")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace:WaitForChild("Map"), workspace:WaitForChild("Plots") }
return {
	Start = function(_)
		remoteEvent4.OnClientEvent:Connect(function()
			EffectController:Activate("Blink")
		end)
		remoteEvent5.OnClientEvent:Connect(function(p)
			EffectController:Activate("Blink")
			ClientEventUtils.playBurst(script.Burst, p)
		end)
		remoteEvent6.OnClientEvent:Connect(function(position)
			local clone = script.Hit:Clone()
			clone.Position = position
			clone.Parent = workspace
			VFX.emit(clone)
			Debris:AddItem(clone, 7)
		end)
		local v = {}
		remoteEvent2.OnClientEvent:Connect(function(name: string, p: string, vector2: Vector3, position: Vector3, p2: number, p3: number)
			local clone = script.GearVisuals[p]:Clone()
			clone.Name = name
			v[name] = clone
			local primaryPart = clone.PrimaryPart or clone:FindFirstChild("Handle")

			if primaryPart then
				primaryPart.Anchored = true
				local attachment = Instance.new("Attachment")
				attachment.Name = "Attachment0"
				attachment.Position = createVector(0, 1, 0)
				attachment.Parent = primaryPart
				local attachment2 = Instance.new("Attachment")
				attachment2.Name = "Attachment1"
				attachment2.Position = createVector(0, -1, 0)
				attachment2.Parent = primaryPart
				local trail = Instance.new("Trail")
				trail.Name = "Trail"
				trail.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 119, 248)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(105, 255, 243))
				})
				trail.Attachment0 = attachment
				trail.Attachment1 = attachment2
				trail.Lifetime = 0.35
				trail.LightInfluence = 1
				trail.Parent = clone
			end

			clone.Parent = workspace
			local proximityPrompt = Instance.new("ProximityPrompt")
			proximityPrompt.Name = "ProximityPrompt"
			proximityPrompt.ActionText = "Grab"
			proximityPrompt.RequiresLineOfSight = false
			proximityPrompt.Enabled = false
			proximityPrompt.Parent = primaryPart
			local scale = clone:GetScale()
			local raycastResult = workspace:Raycast(
				position + createVector(0, 10, 0),
				createVector(-0, -30, -0),
				raycastParams
			)

			if raycastResult then
				position = raycastResult.Position or position
			end

			local v2 = vector2 + (position - vector2) * 0.6 + Vector3.new(0, (position - vector2).Magnitude, 0)
			local v3 = position + Vector3.new(0, clone:GetExtentsSize().Y * 0.5, 0)
			local v4 = math.random(0, 10000)
			local postSimulationConnection = RunService.PostSimulation:Connect(function(_: number)
				local v5 = workspace:GetServerTimeNow() - p2
				local v6 = p3 == 0 and 1 or math.clamp(
					TweenService:GetValue(v5 / p3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					0,
					1
				)
				local quadBezier = MathUtils.quadBezier(v6, vector2, v2, v3)
				clone:ScaleTo((math.lerp(scale * 2, scale, v6)))
				local v7 = os.clock() + v4
				clone:PivotTo(CFrame.new(quadBezier + Vector3.new(0, math.sin(v7 * 2) + 1.5, 0)) * CFrame.Angles(
					0,
					v7 % 6.283185307179586,
					0
				))

				if v6 >= 1 then
					proximityPrompt.Enabled = true
				end
			end)
			clone.Destroying:Connect(function()
				postSimulationConnection:Disconnect()
			end)
			proximityPrompt.Triggered:Connect(function()
				remoteEvent3:FireServer(name)
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
}