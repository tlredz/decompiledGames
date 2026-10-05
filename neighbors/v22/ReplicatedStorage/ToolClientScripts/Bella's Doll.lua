local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.Modules
require(modules.Tool)
local _ = {
	HugText = "%s to give %s a hug!",
	JumpscareChance = 0.15
}
local BellaSDoll = {}

function BellaSDoll:Initialize()
	self.DollModel = nil
	self.JumpscareInProgress = false
	self.JumpscareRig = self.Tool:WaitForChild("JumpscareRig")
	self.GUI = Players.LocalPlayer.PlayerGui.DollGui
	local tool = self.Tool
	ContentProvider:PreloadAsync({ tool:FindFirstChild("JumpscareAnimation") })
	tool.ChildAdded:Connect(function(dollModel)
		if dollModel.Name == "DollModel" then
			self.DollModel = dollModel
			self:ShowGUI()
		end
	end)
	tool.ChildRemoved:Connect(function(child)
		if child.Name == "DollModel" then
			self.DollModel = nil
			self:ShowGUI()
		end
	end)
	tool.Unequipped:Once(function()
		self.DollModel = nil
		self.GUI.Enabled = false
		self.GUI.Vignette.ImageTransparency = 1
	end)
	tool.Activated:Connect(function()
		self:OnActivated()
	end)
end

function BellaSDoll:ShowGUI()
	if not self.DollModel then
		self.GUI.Enabled = false
		return
	end

	local formatted = ("%s to give %s a hug!"):format(
		UserInputService.TouchEnabled and "Tap" or "Click",
		Players:GetPlayerByUserId(self.DollModel:GetAttribute("ID")).DisplayName
	)
	self.GUI.Hug.Text = formatted
	self.GUI.Enabled = true
end

function BellaSDoll:OnActivated()
	if self.JumpscareInProgress or not self.DollModel then
		return
	end

	self.JumpscareInProgress = true
	task.delay(2, function()
		self.JumpscareInProgress = false
	end)

	if self.DollModel:FindFirstChildOfClass("Humanoid") and math.random() <= 0.15 then
		self:PlayJumpscare()
	end
end

function BellaSDoll:PlayJumpscare()
	if not self.DollModel then
		return
	end

	local currentCamera = workspace.CurrentCamera
	local clone = self.JumpscareRig:Clone()
	local clone2 = self.DollModel:Clone()
	local humanoid = clone2:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	if clone:FindFirstChild("DisplayName", true) then
		clone:FindFirstChild("DisplayName", true).Group:Destroy()
	end

	if clone2.PrimaryPart:FindFirstChild("DollWeld") then
		clone2.PrimaryPart.DollWeld:Destroy()
	end

	local weld = Instance.new("Weld")
	clone2:PivotTo(clone:FindFirstChild("HumanoidRootPart").CFrame)
	weld.Part0 = clone:FindFirstChild("HumanoidRootPart")
	weld.Part1 = clone2.PrimaryPart
	weld.Parent = weld.Part1
	clone2.Parent = clone
	clone.Parent = currentCamera
	local animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return
	end

	local track = animator:LoadAnimation(self.Tool:FindFirstChild("JumpscareAnimation"))
	track:Play(0)
	clone:PivotTo(CFrame.new(0, 1000, 0))
	task.delay(0.03333333333333333, function()
		SoundService:PlayLocalSound(ReplicatedStorage.Assets.Tools["Bella's Doll"].Jumpscare)
		task.spawn(function()
			TweenService:Create(self.GUI.Vignette, TweenInfo.new(0.25), {
				ImageTransparency = 0
			}):Play()
		end)
		RunService:BindToRenderStep("BellasDoll", Enum.RenderPriority.Camera.Value + 1, function()
			clone:PivotTo(currentCamera.CFrame)
		end)
	end)
	track.Stopped:Connect(function()
		RunService:UnbindFromRenderStep("BellasDoll")
		clone:Destroy()
		TweenService:Create(self.GUI.Vignette, TweenInfo.new(0.5), {
			ImageTransparency = 1
		}):Play()
	end)
end

return BellaSDoll