local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local currentCamera = game.Workspace.CurrentCamera
local _ = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local Observers = require(packages.Observers)
require(packages.Promise)
local Shake = require(packages.Shake)
require(packages.Trove)
local remoteEvent = Net:RemoteEvent("FishPodium/LoadPodium")
local remoteEvent2 = Net:RemoteEvent("FishPodium/Place")
local v = { "Crowned Anglerfish", "Frozen Leviathan", "Magma Leviathan" }
local ChessMinigameFishPodiumController = {
	podiumData = {},
	spinningFish = {}
}

function fastTween(p, p2, p3, _: boolean?)
	local tween = TweenService:Create(p, p2, p3)
	tween:Play()
	tween.Completed:Connect(function()
		tween:Destroy()
	end)
	return tween
end

function ChessMinigameFishPodiumController:PlaceAnimation(p)
	local v2 = self.podiumData[p]
	local podiumModel = v2 and v2.podiumModel

	if not podiumModel then
		return
	end

	local fish = v2.fish

	if fish then
		local scale = fish:GetScale()
		fish:ScaleTo(0.001)
		local numberPose = Instance.new("NumberPose")
		numberPose.Value = 0
		local tween = TweenService:Create(numberPose, TweenInfo.new(2, Enum.EasingStyle.Elastic), {
			Value = scale
		})
		numberPose:GetPropertyChangedSignal("Value"):Connect(function()
			fish:ScaleTo((math.clamp(numberPose.Value, 0.001, 1)))
		end)
		tween:Play()
		tween.Completed:Connect(function()
			numberPose:Destroy()
			tween:Destroy()
		end)
		tween.Destroying:Connect(function()
			numberPose:Destroy()
		end)
	end

	self:LoadPodiumAppearence(p)
	local mainPart = podiumModel:FindFirstChild("MainPart")

	if mainPart then
		local cFrame = mainPart.CFrame + createVector(0, 10, 0)

		local function createSphere()
			local part = Instance.new("Part")
			part.Transparency = 0
			part.Size = createVector(0, 0, 0)
			part.CastShadow = false
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Anchored = true
			part.Shape = Enum.PartType.Ball
			part.Parent = workspace
			Debris:AddItem(part, 1)
			return part
		end

		local part = Instance.new("Part")
		part.Transparency = 0
		part.Size = createVector(0, 0, 0)
		part.CastShadow = false
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Anchored = true
		part.Shape = Enum.PartType.Ball
		part.Parent = workspace
		Debris:AddItem(part, 1)
		part.Transparency = 0
		part.Color = Color3.fromRGB(255, 231, 185)
		part.CFrame = cFrame
		part.Material = Enum.Material.ForceField
		Debris:AddItem(part, 1)
		local part2 = Instance.new("Part")
		part2.Transparency = 0
		part2.Size = createVector(0, 0, 0)
		part2.CastShadow = false
		part2.CanCollide = false
		part2.CanQuery = false
		part2.CanTouch = false
		part2.Anchored = true
		part2.Shape = Enum.PartType.Ball
		part2.Parent = workspace
		Debris:AddItem(part2, 1)
		part2.Transparency = 0.75
		part2.Color = Color3.fromRGB(255, 231, 185)
		part2.CFrame = cFrame
		part2.Material = Enum.Material.Glass
		local part3 = Instance.new("Part")
		part3.Transparency = 0
		part3.Size = createVector(0, 0, 0)
		part3.CastShadow = false
		part3.CanCollide = false
		part3.CanQuery = false
		part3.CanTouch = false
		part3.Anchored = true
		part3.Shape = Enum.PartType.Ball
		part3.Parent = workspace
		Debris:AddItem(part3, 1)
		part3.Transparency = 0
		part3.Color = Color3.fromRGB(212, 197, 183)
		part3.CFrame = cFrame
		part3.Material = Enum.Material.Neon
		fastTween(part, TweenInfo.new(0.5), {
			Size = createVector(45, 45, 45)
		})
		fastTween(part2, TweenInfo.new(0.5), {
			Size = createVector(40, 40, 40)
		})
		fastTween(part3, TweenInfo.new(0.5), {
			Size = createVector(35, 35, 35)
		})
		fastTween(part, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
			Transparency = 1
		})
		fastTween(part2, TweenInfo.new(0.2), {
			Transparency = 1
		})
		fastTween(part3, TweenInfo.new(0.4), {
			Transparency = 1
		})
		local v4 = Shake.new()
		v4.Amplitude = 300
		v4.Frequency = 0.1
		v4.FadeInTime = 0.1
		v4.FadeOutTime = 2.5
		v4.PositionInfluence = createVector(3, 3, 3)
		v4.RotationInfluence = createVector(0.05, 0.05, 0.05)
		v4:Start()
		v4:BindToRenderStep(Shake.NextRenderName(), Enum.RenderPriority.Last.Value, function(p2, p3)
			local _ = (currentCamera.CFrame.Position - cFrame.Position).Magnitude
			local v5 = math.max((currentCamera.CFrame.Position - cFrame.Position).Magnitude, 30)
			local inverseSquare = Shake.InverseSquare(p2, v5)
			local inverseSquare2 = Shake.InverseSquare(p3, v5)
			currentCamera.CFrame *= CFrame.new(inverseSquare) * CFrame.Angles(
				inverseSquare2.X,
				inverseSquare2.Y,
				inverseSquare2.Z
			)
		end)

		repeat
			task.wait()
		until not v4:IsShaking()

		v4:Destroy()
	end
end

function ChessMinigameFishPodiumController:LoadPodiumAppearence(p)
	local v2 = self.podiumData[p]

	if not v2 then
		return
	end

	v2.placed = true
	local podiumModel = v2 and v2.podiumModel

	if podiumModel then
		local fish = v2 and v2.fish

		if fish then
			for _, part in fish:GetDescendants() do
				if not part:IsA("BasePart") then
					continue
				end

				local originalTransparency = part:GetAttribute("OriginalTransparency")

				if originalTransparency then
					part.Transparency = originalTransparency
				end
			end
		end

		local mainPart = podiumModel:FindFirstChild("MainPart")
		local overhead = mainPart and mainPart:FindFirstChild("Overhead")

		if overhead then
			overhead.Main.List.Visible = false
			overhead.Shine.Visible = false
		end

		local proximityPrompt = podiumModel:FindFirstChild("ProximityPrompt", true)

		if proximityPrompt then
			proximityPrompt.Enabled = false
		end

		self:AddFishToSpin(fish)
	end
end

function ChessMinigameFishPodiumController:AddFishToSpin(instance)
	local count = 0

	for _, _ in self.spinningFish do
		count += 1
	end

	if not self.spinningFish[instance] then
		local pivot = instance:GetPivot()
		self.spinningFish[instance] = {
			pivot = pivot,
			baseY = pivot.Position.Y
		}
	end

	instance.DescendantRemoving:Connect(function()
		if self.spinningFish[instance] then
			self.spinningFish[instance] = nil
			local count2 = 0

			for _, _ in self.spinningFish do
				count2 += 1
			end

			if count2 == 0 and self.spinningConnection then
				self.spinningConnection:Disconnect()
				self.spinningConnection = nil
			end
		end
	end)

	if count == 0 or not self.spinningConnection then
		if self.spinningConnection then
			self.spinningConnection:Disconnect()
		end

		self.spinningConnection = RunService.RenderStepped:Connect(function(dt: number)
			local now = tick()

			for k, v2 in self.spinningFish do
				if not k.PrimaryPart then
					continue
				end

				local v3 = k:GetPivot() * CFrame.Angles(0, math.rad(dt * 60 * 0.25), 0)
				local position = v3.Position
				local v4 = v2.baseY + math.sin(now * 1) * 1
				k:PivotTo(CFrame.new(position.X, v4, position.Z) * (v3 - v3.Position))
			end
		end)
	end
end

function ChessMinigameFishPodiumController:SetUpPodiumData(instance)
	local podiums = instance and instance:FindFirstChild("Podiums")

	for _, childName in v do
		local v2 = self.podiumData[childName]

		if not v2 then
			self.podiumData[childName] = {
				placed = false
			}
			v2 = self.podiumData[childName]
		end

		if not v2 then
			break
		end

		local child = podiums and podiums:FindFirstChild(childName)

		if not child then
			continue
		end

		v2.podiumModel = child
		local fish = child and child:FindFirstChild("Fish")

		if not fish then
			continue
		end

		v2.fish = fish

		if v2.placed then
			self:LoadPodiumAppearence(childName)
		end
	end
end

function ChessMinigameFishPodiumController:Start()
	remoteEvent.OnClientEvent:Connect(function(p: string)
		self:LoadPodiumAppearence(p)
	end)
	remoteEvent2.OnClientEvent:Connect(function(p: string)
		self:PlaceAnimation(p)
	end)
	Observers.observeTag("FishPodiumBase", function(p)
		local parent = p.Parent

		if not parent:IsA("Model") then
			return
		end

		self:SetUpPodiumData(parent)
		return function()
			if self.spinningConnection then
				self.spinningConnection:Disconnect()
				self.spinningConnection = nil
			end
		end
	end)
	self:SetUpPodiumData()
end

return ChessMinigameFishPodiumController