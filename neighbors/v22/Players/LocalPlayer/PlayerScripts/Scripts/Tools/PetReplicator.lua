local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local modules = ReplicatedStorage.Modules
local UI = require(modules.UI)
local localPlayer = Players.LocalPlayer
local assets = ReplicatedStorage.Assets
local animations = assets.Animations
local tools = assets.Tools

local function bindPet(instance)
	local animator = instance:WaitForChild("AnimationController"):WaitForChild("Animator")
	local petName = instance:GetAttribute("PetName")
	local clone = tools.PetBillboard:Clone()
	clone.Adornee = instance:WaitForChild("Head")
	clone.Parent = localPlayer.PlayerGui
	local tween = TweenService:Create(
		clone.ButtonContainer,
		TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{
			Position = UDim2.fromScale(0.5, 0.4),
			GroupTransparency = 1
		}
	)
	local tween2 = TweenService:Create(
		clone.ButtonContainer,
		TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{
			Position = UDim2.fromScale(0.5, 0.5),
			GroupTransparency = 0
		}
	)
	clone.ButtonContainer.Close.Activated:Connect(function()
		tween:Cancel()
		tween2:Cancel()
		clone.ButtonContainer.Position = UDim2.fromScale(0.5, 0.5)
		clone.ButtonContainer.GroupTransparency = 0
		tween:Play()
	end)
	tween.Completed:Connect(function()
		clone.Enabled = false
	end)
	local connections = {}

	for _, v in clone:QueryDescendants("GuiButton") do
		UI:Bind(v)
		UI:AddShadowOnHover(v)

		if v.Name == "Close" then
			continue
		end

		local v2 = v
		v.Activated:Connect(function()
			clone.Enabled = false

			if v2.Name == "Pet" then
				instance.Pet:FireServer()
				return
			end

			if instance:GetAttribute("Owner") ~= localPlayer.Name then
				return
			end

			instance.States:Fire(v2.Name)
		end)
	end

	instance:WaitForChild("ClickRegion"):WaitForChild("ClickDetector").MouseClick:Connect(function()
		local v = instance:GetAttribute("Owner") == localPlayer.Name and "State" or "ServerState"

		if not (instance:GetAttribute(v) ~= "Pet" and instance:GetAttribute(v) ~= "WakingUp") then
			return
		end

		if instance:GetAttribute(v) ~= "Idle" then
			instance.States:Fire()
			return
		end

		tween:Cancel()
		tween2:Cancel()
		clone.ButtonContainer.Position = UDim2.fromScale(0.5, 0.6)
		clone.ButtonContainer.GroupTransparency = 1
		tween2:Play()

		for _, v2 in clone:QueryDescendants("GuiButton") do
			v2.ShadowHover.BackgroundTransparency = 1
		end

		clone.Enabled = true
	end)

	if instance:GetAttribute("Owner") == localPlayer.Name then
		return
	end

	clone.ButtonContainer.Sleep:Destroy()
	clone.ButtonContainer.Sit:Destroy()
	clone.ButtonContainer.Pet.Position = UDim2.fromScale(0.4, 0.5)
	local animationReplicator = instance:WaitForChild("AnimationReplicator")
	local tracksByName = {}

	for _, animation in animations.Pets[petName]:GetChildren() do
		tracksByName[animation.Name] = animator:LoadAnimation(animation)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function playAnimation(p, p2)
		local v = tracksByName[p]

		if v then
			v:Play(p2)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stopAnimation(p, p2)
		local v = tracksByName[p]

		if v then
			v:Stop(p2)
		end
	end

	animationReplicator.OnClientEvent:Connect(function(p: string, ...)
		if p == "PlayAnimation" then
			local v, v2 = ...
			playAnimation(v, v2) -- equivalent call inferred; original call site unknown
		elseif p == "StopAnimation" then
			local v, v2 = ...
			stopAnimation(v, v2) -- equivalent call inferred; original call site unknown
		elseif p == "StopAnimations" then
			for _, v in tracksByName do
				if v.IsPlaying then
					v:Stop(0.5)
				end
			end
		end
	end)

	if not tracksByName.Idle.IsPlaying then
		tracksByName.Idle:Play()
	end

	table.insert(connections, instance.AncestryChanged:Connect(function(_, parent)
		if not parent then
			clone:Destroy()

			for _, connection in connections do
				connection:Disconnect()
			end

			for _, v in tracksByName do
				v:Stop()
				v:Destroy()
			end

			table.clear(connections)
			table.clear(tracksByName)
		end
	end))
end

CollectionService:GetInstanceAddedSignal("Pet"):Connect(bindPet)

for _, v in CollectionService:GetTagged("Pet") do
	bindPet(v)
end