local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local Nests = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Nests"))
local services = ReplicatedStorage:WaitForChild("Services")
local String = require(services:WaitForChild("String"))
local ForgeVFX = require(services:WaitForChild("ForgeVFX"))
local CameraShaker = require(services:WaitForChild("CameraShaker"))
local assets = ReplicatedStorage:WaitForChild("Assets")
local unlockNest = assets:WaitForChild("Prompts"):WaitForChild("UnlockNest")
local sparkles = assets:WaitForChild("Effects"):WaitForChild("Sparkles")
local reveal = SoundService:WaitForChild("SFX"):WaitForChild("RNGReveal"):WaitForChild("Reveal")
local nests = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("Plot"):WaitForChild("Nests")
local plots = workspace:WaitForChild("Plots")
ForgeVFX.init()
local v = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1, function(p)
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera.CFrame *= p
	end
end)
v:Start()
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function RemovePrompt(child)
	local v3 = v2[child]

	if v3 then
		v2[child] = nil
		v3.Enabled = false
		v3:Destroy()
	end
end

local function CreatePrompt(child)
	if v2[child] then
		return
	end

	local price = Nests.Prices[tonumber(child.Name)]

	if not price or price <= 0 then
		return
	end

	local locked = child:FindFirstChild("Locked")
	local lockedMain = locked and locked:FindFirstChild("Main")

	if lockedMain then
		local clone = unlockNest:Clone()
		clone.ObjectText = String:FormatCurrency(price)
		clone.Triggered:Connect(function()
			nests:FireServer((tonumber(child.Name)))
		end)
		clone.Parent = lockedMain
		v2[child] = clone

		if RunService:IsStudio() then
			print(string.format("[Nests] unlock prompt created for nest %s at %s", child.Name, (tostring(price))))
		end
	elseif RunService:IsStudio() then
		warn(string.format("[Nests] nest %s has no Locked/Main to hang the unlock prompt on", child.Name))
	end
end

local function RefreshPlotPrompts(instance)
	local v3 = instance:GetAttribute("NestsOwnerLoaded") == localPlayer.UserId
	local nests2 = instance:FindFirstChild("Nests")

	if not nests2 then
		return
	end

	if RunService:IsStudio() and instance:FindFirstChild("Data") and instance.Data:FindFirstChild("Owner") and instance.Data.Owner.Value == localPlayer then
		print(string.format(
			"[Nests] refresh on my plot: NestsOwnerLoaded=%s (mine=%d)",
			tostring(instance:GetAttribute("NestsOwnerLoaded")),
			localPlayer.UserId
		))
	end

	for _, child in nests2:GetChildren() do
		if v3 and not child:GetAttribute("Unlocked") then
			CreatePrompt(child)
		else
			RemovePrompt(child) -- equivalent call inferred; original call site unknown
		end
	end
end

local function WatchPlot(instance)
	local nests2 = instance:WaitForChild("Nests", 15)

	if not nests2 then
		return
	end

	instance:GetAttributeChangedSignal("NestsOwnerLoaded"):Connect(function()
		RefreshPlotPrompts(instance)
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function WatchNest(child)
		child:GetAttributeChangedSignal("Unlocked"):Connect(function()
			RefreshPlotPrompts(instance)
		end)
	end

	nests2.ChildAdded:Connect(function(child)
		WatchNest(child) -- equivalent call inferred; original call site unknown
		RefreshPlotPrompts(instance)
	end)

	for _, child in nests2:GetChildren() do
		child:GetAttributeChangedSignal("Unlocked"):Connect(function()
			RefreshPlotPrompts(instance)
		end)
	end

	RefreshPlotPrompts(instance)
end

for _, child in plots:GetChildren() do
	task.spawn(WatchPlot, child)
end

plots.ChildAdded:Connect(function(child)
	task.spawn(WatchPlot, child)
end)

local function FadeOutHighlight(highlight)
	local tween = TweenService:Create(highlight, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
		FillTransparency = 1
	})
	tween:Play()
	tween.Completed:Once(function()
		highlight.Enabled = false
		highlight.FillTransparency = 0
	end)
end

local function AnimateLockFall(folder)
	local clone = folder:Clone()

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
		elseif descendant:IsA("ProximityPrompt") then
			descendant:Destroy()
		end
	end

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Transparency = 1
		part.CanCollide = false
	end

	clone.Parent = workspace
	local pivot = clone:GetPivot()
	local numberValue = Instance.new("NumberValue")
	numberValue.Changed:Connect(function(p)
		clone:PivotTo(pivot - Vector3.new(0, p * 10, 0))
	end)
	TweenService:Create(numberValue, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Value = 1
	}):Play()

	for _, part in clone:GetDescendants() do
		if part:IsA("BasePart") then
			TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
				Transparency = 1
			}):Play()
		end
	end

	task.delay(0.5, function()
		numberValue:Destroy()
		clone:Destroy()
	end)
end

local function PlayRevealBurst(child)
	local instanceModel = child:FindFirstChild("Model") or child
	local clone = sparkles:Clone()
	clone.CFrame = clone.CFrame.Rotation + instanceModel:GetPivot().Position
	clone.Anchored = true
	clone.Parent = workspace
	local clone2 = reveal:Clone()
	clone2.Parent = clone
	clone2:Play()
	ForgeVFX.emit(clone)
	task.delay(6, function()
		clone:Destroy()
	end)
	local currentCamera = workspace.CurrentCamera
	local magnitude = currentCamera and (instanceModel:GetPivot().Position - currentCamera.CFrame.Position).Magnitude

	if magnitude and magnitude <= 80 then
		v:Shake(CameraShaker.Presets.SmallShake)
	end

	local highlight = Instance.new("Highlight")
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillColor = Color3.new(1, 1, 1)
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.FillTransparency = 0
	highlight.OutlineTransparency = 1
	highlight.Adornee = instanceModel
	highlight.Parent = instanceModel
	local tween = TweenService:Create(highlight, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
		FillTransparency = 1
	})
	tween:Play()
	tween.Completed:Once(function()
		highlight:Destroy()
	end)
end

local function PlayUnlockSequence(instance, p)
	local nests2 = instance:FindFirstChild("Nests")
	local child = nests2 and nests2:FindFirstChild((tostring(p)))

	if not child then
		return
	end

	RemovePrompt(child) -- equivalent call inferred; original call site unknown
	local model = child:FindFirstChild("Model")
	local highlight = model and model:FindFirstChild("Highlight")
	local locked = child:FindFirstChild("Locked")

	if highlight and highlight.Enabled then
		FadeOutHighlight(highlight)
	end

	if locked then
		AnimateLockFall(locked)
	end

	task.delay(0.1, function()
		if child.Parent then
			PlayRevealBurst(child)
		end
	end)
end

nests.OnClientEvent:Connect(function(instance, p)
	if typeof(instance) ~= "Instance" or not tonumber(p) then
		return
	end

	PlayUnlockSequence(instance, p)
end)