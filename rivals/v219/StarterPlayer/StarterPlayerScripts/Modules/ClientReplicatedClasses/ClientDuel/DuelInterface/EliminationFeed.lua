local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers.ComplianceController)
local Inset = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Inset)
local eliminationFeedSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("EliminationFeedSlot")
local EliminationFeed = {}
EliminationFeed.__index = EliminationFeed

function EliminationFeed.new(duelInterface)
	local self = setmetatable({}, EliminationFeed)
	self.DuelInterface = duelInterface
	self.Frame = self.DuelInterface.Frame:WaitForChild("EliminationFeed")
	self.List = self.Frame:WaitForChild("List")
	self._destroyed = false
	self._connections = {}
	self:_Init()
	return self
end

function EliminationFeed:PlayRaw(options)
	local v = options or {}
	v.State = v.State or "Default"
	v.VictimText = v.VictimText or "???"
	v.VictimTeamColor = v.VictimTeamColor or DuelLibrary.EMPTY_TEAM_COLOR
	v.EliminatorText = v.EliminatorText or "???"
	v.EliminatorTeamColor = v.EliminatorTeamColor or DuelLibrary.EMPTY_TEAM_COLOR
	v.ViewModelName = v.ViewModelName or nil
	v.IsCritical = v.IsCritical or false
	v.IsBlinded = v.IsBlinded or false
	v.IsNoscope = v.IsNoscope or false
	local v2 = v.ViewModelName and ItemLibrary.ViewModels[v.ViewModelName]
	local image = not v2 and "rbxassetid://91284037292220" or v2.EliminationFeedImage or "rbxassetid://91284037292220"
	local eliminationFeedImageScale = v2 and v2.EliminationFeedImageScale or 1.5
	local clone = eliminationFeedSlot:Clone()
	clone.Container.Container.Eliminator.TextLabel.Text = v.EliminatorText or ""
	clone.Container.Container.Eliminator.Visible = clone.Container.Container.Eliminator.TextLabel.Text ~= ""
	clone.Container.Container.Victim.TextLabel.Text = v.VictimText or "???"
	clone.Container.Container.Weapon.ImageLabel.Image = image
	clone.Container.Container.Weapon.Size = UDim2.new(eliminationFeedImageScale, 0, 1, 0)
	clone.Container.Container.Critical.Visible = v.IsCritical
	clone.Container.Container.Blinded.Visible = v.IsBlinded
	clone.Container.Container.Noscope.Visible = v.IsNoscope
	clone.Container.Background.Outline.Visible = v.State == "LocalElimination"
	clone.Container.Background.Background.ImageColor3 = v.State == "LocalDeath" and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(
		255,
		255,
		255
	)
	clone.Parent = self.List
	BetterDebris:AddItem(clone, 10)
	local imageLabel = clone.Container.Container.Weapon.ImageLabel
	local flag = false

	local function update()
		if self._destroyed or flag then
			return
		end

		flag = true
		task.defer(function()
			if self._destroyed then
				return
			end

			flag = false
			clone.Container.Container.Eliminator.Size = UDim2.new(
				0,
				clone.Container.Container.Eliminator.TextLabel.TextBounds.X,
				0.625,
				0
			)
			clone.Container.Container.Victim.Size = UDim2.new(
				0,
				clone.Container.Container.Victim.TextLabel.TextBounds.X,
				0.625,
				0
			)
			clone.Size = UDim2.new(0, clone.Container.Container.Layout.AbsoluteContentSize.X, clone.Size.Y.Scale, 0)
			local v4 = math.clamp(
				(imageLabel.AbsolutePosition.X + imageLabel.AbsoluteSize.X / 2 - clone.AbsolutePosition.X) / clone.AbsoluteSize.X,
				0.001,
				0.999
			)
			clone.Container.Background.Background.UIGradient.Color = v.State == "LocalDeath" and ColorSequence.new(Color3.fromRGB(
				255,
				255,
				255
			)) or ColorSequence.new({
				ColorSequenceKeypoint.new(0, v.EliminatorTeamColor),
				ColorSequenceKeypoint.new(v4, Color3.fromRGB(0, 0, 0)),
				ColorSequenceKeypoint.new(1, v.VictimTeamColor)
			})
			clone.Container.Background.Background.UIGradient.Transparency = v.State == "LocalDeath" and NumberSequence.new(0) or NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(v4, 0.25),
				NumberSequenceKeypoint.new(1, 0)
			})
		end)
	end

	clone:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
	imageLabel:GetPropertyChangedSignal("AbsolutePosition"):Connect(update)
	imageLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
	clone.Container.Container.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
	clone.Container.Container.Eliminator.TextLabel:GetPropertyChangedSignal("TextBounds"):Connect(update)
	clone.Container.Container.Victim.TextLabel:GetPropertyChangedSignal("TextBounds"):Connect(update)

	if not (self._destroyed or flag) then
		flag = true
		task.defer(function()
			if self._destroyed then
				return
			end

			flag = false
			clone.Container.Container.Eliminator.Size = UDim2.new(
				0,
				clone.Container.Container.Eliminator.TextLabel.TextBounds.X,
				0.625,
				0
			)
			clone.Container.Container.Victim.Size = UDim2.new(
				0,
				clone.Container.Container.Victim.TextLabel.TextBounds.X,
				0.625,
				0
			)
			clone.Size = UDim2.new(0, clone.Container.Container.Layout.AbsoluteContentSize.X, clone.Size.Y.Scale, 0)
			local v4 = math.clamp(
				(imageLabel.AbsolutePosition.X + imageLabel.AbsoluteSize.X / 2 - clone.AbsolutePosition.X) / clone.AbsoluteSize.X,
				0.001,
				0.999
			)
			clone.Container.Background.Background.UIGradient.Color = v.State == "LocalDeath" and ColorSequence.new(Color3.fromRGB(
				255,
				255,
				255
			)) or ColorSequence.new({
				ColorSequenceKeypoint.new(0, v.EliminatorTeamColor),
				ColorSequenceKeypoint.new(v4, Color3.fromRGB(0, 0, 0)),
				ColorSequenceKeypoint.new(1, v.VictimTeamColor)
			})
			clone.Container.Background.Background.UIGradient.Transparency = v.State == "LocalDeath" and NumberSequence.new(0) or NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(v4, 0.25),
				NumberSequenceKeypoint.new(1, 0)
			})
		end)
	end

	if clone:IsDescendantOf(Players.LocalPlayer) then
		clone.Container.Position = UDim2.new(1, 20, 0, 0)
		clone.Container:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quint", 0.25, true)
	end

	task.delay(
		7,
		pcall,
		clone.Container.TweenPosition,
		clone.Container,
		UDim2.new(1, 20, 0, 0),
		"In",
		"Quint",
		0.25,
		true,
		function()
			if self._destroyed then
				return
			end

			clone:TweenSize(UDim2.new(), "Out", "Quint", 0.25, true, function()
				if self._destroyed then
					return
				end

				clone:Destroy()
			end)
		end
	)
end

function EliminationFeed:Play(instance, instance2, p, viewModelName, isCritical, isBlinded, isNoscope)
	self:PlayRaw({
		State = instance == Players.LocalPlayer and "LocalDeath" or (instance2 == Players.LocalPlayer or p == Players.LocalPlayer) and "LocalElimination" or "Default",
		VictimText = instance and ComplianceController:GetName(instance),
		VictimTeamColor = DuelLibrary:GetTeamColor(instance:GetAttribute("TeamID")),
		EliminatorText = ((not instance2 or instance2 == instance) and "" or ComplianceController:GetName(instance2) or "") .. ((not p or p == instance2 or p == instance) and "" or " + " .. ComplianceController:GetName(p) or ""),
		EliminatorTeamColor = DuelLibrary:GetTeamColor(instance2:GetAttribute("TeamID")),
		ViewModelName = viewModelName,
		IsCritical = isCritical,
		IsBlinded = isBlinded,
		IsNoscope = isNoscope
	})
end

function EliminationFeed:Update()
	self.Frame.Visible = not (self.DuelInterface:IsPageOpen() or self.DuelInterface.FinalResults:IsActive())
end

function EliminationFeed:UpdatePosition()
	self.Frame.Position = UDim2.new(1, 0, 0, Inset.MainFrame.AbsoluteSize.Y)
end

function EliminationFeed:Destroy()
	self._destroyed = true

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}
end

function EliminationFeed._Debug(_) end

function EliminationFeed._UpdatePosition(_) end

function EliminationFeed:_Init()
	self.DuelInterface.FinalResults.Activated:Connect(function()
		self:Update()
	end)
	self:UpdatePosition()
	task.defer(self._Debug, self)
end

return EliminationFeed