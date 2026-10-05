local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local cache = legacyLocalPlayerData.fetch():WaitForChild("Cache")
local _ = Players.LocalPlayer
local v = Component.new({
	Tag = "FinalKrakenGateThing"
})
local flag = false

function v:Construct()
	self.trove = Trove.new()
	self.tracks = {}
	self.positions = {}
end

function v:PlayKillAnimation()
	flag = true
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quint)

	for k, position in self.positions do
		TweenService:Create(k.PrimaryPart, tweenInfo, {
			CFrame = position[true]
		}):Play()
	end

	task.wait(0.75)

	for _, track in self.tracks do
		track:Play()
	end

	ReplicatedStorage.events.drown:FireServer()
	task.wait(5)
	flag = false

	for _, track in self.tracks do
		track:Stop()
	end

	for k, position in self.positions do
		if k and k.Parent and k.PrimaryPart then
			k.PrimaryPart.CFrame = position[false]
		end
	end
end

function v.RenderSteppedUpdate(p, _)
	if not workspace.CurrentCamera then
		return
	end

	local primaryPart = p.Instance.PrimaryPart

	if not primaryPart then
		return
	end

	local visualHint = p.Instance:FindFirstChild("VisualHint")

	if not visualHint then
		return
	end

	local Z = primaryPart.CFrame:PointToObjectSpace(workspace.CurrentCamera.CFrame.Position).Z
	local localTransparencyModifier = math.clamp(math.map(Z, -120, -70, 0, 1), 0, 1)
	visualHint.LocalTransparencyModifier = localTransparencyModifier

	for _, descendant in visualHint:GetDescendants() do
		if descendant:IsA("Beam") then
			descendant.LocalTransparencyModifier = localTransparencyModifier
		elseif descendant:IsA("Light") then
			descendant.Brightness = (1 - localTransparencyModifier) * 0.25
		end
	end
end

function v:Start()
	for _, child in self.Instance:WaitForChild("Tentacles"):GetChildren() do
		local animator = child:WaitForChild("AnimationController"):WaitForChild("Animator")
		self.tracks[child] = animator:LoadAnimation(script.IdleLeg)
		self.positions[child] = {
			[false] = child.PrimaryPart.CFrame,
			[true] = child:GetAttribute("GoalCFrame")
		}
	end

	self.trove:Add(self.Instance.PrimaryPart.Touched:Connect(function(otherPart)
		if flag then
			return
		end

		local character = Players.LocalPlayer.Character

		if not (character and otherPart:IsDescendantOf(character)) then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if not humanoid or humanoid.Health <= 0 then
			return
		end

		if not cache:FindFirstChild("Door.KrakenPuzzleDoor2") then
			self:PlayKillAnimation()
		end
	end))
end

function v:Stop()
	self.trove:Clean()
end

return v