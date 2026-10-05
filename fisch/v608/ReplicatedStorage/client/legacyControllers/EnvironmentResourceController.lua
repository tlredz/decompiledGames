local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
require(packages.Signal)
require(packages.Trove)
local modules = ReplicatedStorage.shared.modules
local EnvironmentResources = require(modules.EnvironmentResources)
require(modules.EnvironmentResources.Types)
require(modules.Hook)
local module = require("./HudController")
local unreliableRemoteEvent = Net:UnreliableRemoteEvent("EnvironmentResource/UpdateValue")
local remoteEvent = Net:RemoteEvent("EnvironmentResource/UpdateValue")
local remoteEvent2 = Net:RemoteEvent("EnvironmentResource/UpdateState")
local clone = script.resourcesBillboard:Clone()
local clone2 = script.resourcesBillboard:Clone()
clone2.StudsOffset = vector.create(2, 0, 0)
clone2.container.AnchorPoint = Vector2.new(0, 0)
clone2.container.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
local v = false
local EnvironmentResourceController = {}
local resourceData = {}
EnvironmentResourceController.ResourceData = resourceData

function EnvironmentResourceController:CreateBar(p)
	local clone3 = script.barTemplate:Clone()
	clone3.Name = p.Name
	clone3.LayoutOrder = p.Config.DisplayOrder
	clone3.Visible = false
	local inner = clone3.inner
	inner.icon.Image = p.Config.Icon
	inner.textDisplay.Visible = p.Config.TextFormat ~= nil

	if p.Config.TextFormat ~= nil then
		inner.textDisplay.TextColor3 = p.Config.HighlightColor
		inner.textDisplay.UIStroke.Color = p.Config.BackgroundColor
	end

	inner.bg.BackgroundColor3 = p.Config.BackgroundColor
	inner.bg.UIStroke.Color = p.Config.BackgroundColor
	inner.bg.Bar.UIGradient.Color = p.Config.BarColor
	inner.bg.Bar.Top.BackgroundColor3 = p.Config.HighlightColor
	return clone3
end

function EnvironmentResourceController:AddBars(p)
	local bar = EnvironmentResourceController:CreateBar(p)
	local clone3 = bar:Clone()
	local deviceInsetGui = module:GetDeviceInsetGui()
	local v3 = p.Config.RightSide and clone2 or clone
	local resourcesRight = p.Config.RightSide and deviceInsetGui.resourcesRight or deviceInsetGui.resourcesLeft
	bar.Parent = v3.container
	clone3.Parent = resourcesRight
	p.BillboardBar = bar
	p.ScreenBar = clone3
end

function EnvironmentResourceController:SetupCharacter(instance)
	clone2.Adornee = instance:WaitForChild("HumanoidRootPart")
	clone.Adornee = instance:WaitForChild("HumanoidRootPart")
end

function EnvironmentResourceController:IsFirstPerson()
	local currentCamera = workspace.CurrentCamera
	local head = localPlayer.Character and localPlayer.Character:FindFirstChild("Head")
	return currentCamera and head and (currentCamera.CFrame.Position - head.Position).Magnitude < 3
end

function EnvironmentResourceController:UpdateFramePosition()
	local quests = module:GetDeviceInsetGui():WaitForChild("quests")
	local resourcesLeft = module:GetDeviceInsetGui():WaitForChild("resourcesLeft")
	local resourcesRight = module:GetDeviceInsetGui():WaitForChild("resourcesRight")
	local uDim = UDim2.fromScale(-0.7, 0.5)
	local uDim2 = UDim2.fromScale(1.7, 0.5)

	if EnvironmentResourceController:IsFirstPerson() then
		clone2.Enabled = false
		clone.Enabled = false
		v = true

		if quests:GetAttribute("Toggle") == false then
			uDim = UDim2.fromScale(0.05, 0.5)
		else
			uDim = UDim2.fromScale(quests.Size.X.Scale + 0.03, 0.5)
		end

		uDim2 = UDim2.fromScale(0.99, 0.5)
	else
		v = false
		clone2.Enabled = true
		clone.Enabled = true
	end

	if resourcesLeft.Position ~= uDim then
		TweenService:Create(resourcesLeft, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = uDim
		}):Play()
		TweenService:Create(resourcesRight, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = uDim2
		}):Play()
	end
end

function EnvironmentResourceController:GetResource(p: string)
	if EnvironmentResourceController.ResourceData[p] then
		return EnvironmentResourceController.ResourceData[p]
	end

	local resource = EnvironmentResources.Resources[p]
	local baseMin = resource.InverseDirection and resource.BaseMin or resource.BaseMax
	local v3 = {
		Name = resource.Name,
		Config = resource,
		Enabled = false,
		IsStable = false,
		MaxedFor = 0,
		ServerValue = baseMin,
		Value = baseMin,
		DrainRate = 0,
		LastUpdate = nil,
		Min = resource.BaseMin,
		Max = resource.BaseMax,
		InverseDirection = resource.InverseDirection,
		BarVelocity = 0,
		GlowTransparency = 0
	}
	EnvironmentResourceController:AddBars(v3)
	EnvironmentResourceController.ResourceData[p] = v3
	return v3
end

function EnvironmentResourceController:ActivateBar(state)
	state.IsStable = false
	local screenBar = v and state.ScreenBar or state.BillboardBar
	local billboardBar = v and state.BillboardBar or state.ScreenBar
	screenBar.inner.Position = UDim2.fromOffset(state.Config.RightSide and 2000 or -2000, 0)
	screenBar.Visible = true
	TweenService:Create(screenBar.inner, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new()
	}):Play()
	billboardBar.Visible = true
	billboardBar.inner.Position = UDim2.new()
end

function EnvironmentResourceController:DeactivateBar(data)
	local screenBar = v and data.ScreenBar or data.BillboardBar
	local billboardBar = v and data.BillboardBar or data.ScreenBar
	local v3 = data.Config.RightSide and 2000 or -2000
	TweenService:Create(screenBar.inner, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Position = UDim2.fromOffset(v3, 0)
	}):Play()
	task.delay(0.5, function()
		if not data.Enabled or data.IsStable then
			screenBar.Visible = false
		end
	end)
	billboardBar.Visible = false
	billboardBar.inner.Position = UDim2.fromOffset(v3, 0)
end

function EnvironmentResourceController:CheckBarStates(p)
	if p.Enabled and not p.IsStable then
		EnvironmentResourceController:ActivateBar(p)
	else
		EnvironmentResourceController:DeactivateBar(p)
	end
end

function EnvironmentResourceController._OnValuePacket(p: string, data)
	local resource = EnvironmentResourceController:GetResource(p)
	resource.ServerValue = data.Value
	resource.DrainRate = data.DrainRate
	resource.LastUpdate = data.Time
end

function EnvironmentResourceController._OnStatePacket(p: string, data)
	local resource = EnvironmentResourceController:GetResource(p)
	resource.Max = data.Max

	if data.Enabled ~= resource.Enabled then
		resource.Enabled = data.Enabled

		if resource.Enabled and not data.IsStable then
			EnvironmentResourceController:ActivateBar(resource)
		elseif not resource.Enabled or data.IsStable then
			EnvironmentResourceController:DeactivateBar(resource)
		end
	end
end

function EnvironmentResourceController.AddCustomEntry(_, p, p2, flag: boolean)
	local deviceInsetGui = module:GetDeviceInsetGui()
	local resourcesRight = flag and deviceInsetGui.resourcesRight or deviceInsetGui.resourcesLeft
	p2.Parent = (flag and clone2 or clone).container
	p.Parent = resourcesRight
end

local v3 = nil

function EnvironmentResourceController._Tick(p: number)
	if workspace.CurrentCamera then
		local isFirstPerson = EnvironmentResourceController:IsFirstPerson()

		if isFirstPerson ~= nil and isFirstPerson ~= v3 then
			EnvironmentResourceController:UpdateFramePosition()

			for _, v4 in resourceData do
				EnvironmentResourceController:CheckBarStates(v4)
			end

			v3 = isFirstPerson
		end
	end

	for _, v4 in resourceData do
		if not (v4.LastUpdate and v4.Enabled) then
			continue
		end

		local v5 = v4.DrainRate * (v4.InverseDirection and 1 or -1)
		v4.Value = v4.ServerValue + (workspace:GetServerTimeNow() - v4.LastUpdate) * v5

		if v4.InverseDirection then
			v4.Value = math.max(v4.Value, v4.Min)
		else
			v4.Value = math.min(v4.Value, v4.Max)
		end

		local screenBar = v and v4.ScreenBar or v4.BillboardBar

		if v4.Config.TextFormat then
			screenBar.inner.textDisplay.Text = v4.Config.TextFormat:format(v4.Value)
		end

		if v4.InverseDirection and v4.Value <= v4.Min or not v4.InverseDirection and v4.Value >= v4.Max then
			v4.MaxedFor += p

			if not v4.IsStable and v4.MaxedFor >= 1 then
				v4.IsStable = true
				EnvironmentResourceController:DeactivateBar(v4)
			end
		else
			v4.MaxedFor = 0

			if v4.IsStable then
				v4.IsStable = false
				EnvironmentResourceController:ActivateBar(v4)
			end
		end

		local v6 = math.clamp(math.map(v4.Value, v4.Min, v4.Max, 0, 1), 0, 1)
		local smoothDamp, barVelocity = TweenService:SmoothDamp(
			screenBar.inner.bg.Bar.Size.Y.Scale,
			v6,
			v4.BarVelocity,
			0.1,
			nil,
			p
		)
		v4.BarVelocity = barVelocity
		screenBar.inner.bg.Bar.Size = UDim2.fromScale(1, smoothDamp)
		local v8 = math.clamp(v6, 0, 1)

		if v4.InverseDirection then
			v8 = 1 - v8
		end

		v4.GlowTransparency += p / math.map(v8, 0, 0.2, 0.15, 1)
		local v9 = math.abs(v4.GlowTransparency % 2 - 1) * math.clamp(math.map(v8, 0.2, 0.1, 0, 1), 0, 1)
		screenBar.inner.shine.ImageTransparency = 1 - v9
	end
end

function EnvironmentResourceController.Start(_)
	clone2.Parent = module:GetPlayerGui()
	clone.Parent = module:GetPlayerGui()
	localPlayer.CharacterAdded:Connect(function(character)
		EnvironmentResourceController:SetupCharacter(character)

		for _, v4 in resourceData do
			EnvironmentResourceController:CheckBarStates(v4)
		end
	end)

	if localPlayer.Character then
		task.spawn(EnvironmentResourceController.SetupCharacter, EnvironmentResourceController, localPlayer.Character)
	end

	module:GetDeviceInsetGui():WaitForChild("quests"):GetAttributeChangedSignal("Toggle"):Connect(function()
		EnvironmentResourceController:UpdateFramePosition()
	end)
	EnvironmentResourceController:UpdateFramePosition()
	RunService.RenderStepped:Connect(EnvironmentResourceController._Tick)
	unreliableRemoteEvent.OnClientEvent:Connect(EnvironmentResourceController._OnValuePacket)
	remoteEvent.OnClientEvent:Connect(EnvironmentResourceController._OnValuePacket)
	remoteEvent2.OnClientEvent:Connect(EnvironmentResourceController._OnStatePacket)
end

return EnvironmentResourceController