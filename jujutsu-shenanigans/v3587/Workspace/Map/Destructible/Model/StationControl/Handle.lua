-- equivalent calls inferred from this helper; original call sites unknown
local function handle(child)
	local wire = child:WaitForChild("Wire", 1)
	wire.SourceInstance = script.Parent.Mic.AudioEqualizer
end

script.Parent.Speakers.ChildAdded:Connect(handle)

for _, child in script.Parent.Speakers:GetChildren() do
	handle(child) -- equivalent call inferred; original call site unknown
end

script.Parent.Mic.ChildAdded:Connect(function(child)
	if child.Name ~= "Head" then
		return
	end

	local wire = child:WaitForChild("Wire", 1)
	wire.TargetInstance = script.Parent.Mic.AudioFader
end)
script.Mic_Air.OnClientEvent:Connect(function(p)
	local mic = script.Parent.Mic

	if p == 1 then
		mic.JingleAir:Play()
	elseif p == 2 then
		mic.JingleOff:Play()
	else
		mic.Train:Play()
	end
end)

local function handle2(instance)
	local button = instance:WaitForChild("Button", 1)
	button.Enabled = not instance:WaitForChild("Status", 1).Enabled
	instance:WaitForChild("Status", 1):GetPropertyChangedSignal("Enabled"):Connect(function()
		button.Enabled = not instance:WaitForChild("Status", 1).Enabled
	end)
	button.Triggered:Connect(function()
		if instance.Parent.Name == "ButtonAir" then
			script.Mic_Air:FireServer()
		else
			script.Train:FireServer()
		end
	end)
end

script.Parent.ButtonTrain.ChildAdded:Connect(function(child)
	if child.Name ~= "Button" then
		return
	end

	handle2(child)
end)
handle2(script.Parent.ButtonTrain.Button)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }
local TweenService = game:GetService("TweenService")
script.Train.OnClientEvent:Connect(function()
	task.wait(0.25)
	local clone = game.ReplicatedStorage.Utils.Misc.Train:Clone()
	clone.Parent = workspace.Effects
	TweenService:Create(clone, TweenInfo.new(3, Enum.EasingStyle.Linear), {
		CFrame = clone.CFrame + clone.CFrame.LookVector * 1200
	}):Play()

	for _, sound in clone:GetChildren() do
		if not sound:IsA("Sound") then
			continue
		end

		sound.SoundGroup = game.SoundService.Effect
		sound:Play()
	end

	task.wait(5)
	clone:Destroy()
end)
local audioEqualizer = script.Parent.Mic.AudioEqualizer
audioEqualizer:GetPropertyChangedSignal("Bypass"):Connect(function()
	if audioEqualizer.Bypass == false then
		audioEqualizer.HighGain = 0
		audioEqualizer.LowGain = 0
		audioEqualizer.MidGain = 0
		TweenService:Create(audioEqualizer, TweenInfo.new(0.5), {
			HighGain = -80,
			LowGain = -20,
			MidGain = -80
		}):Play()
	end
end)

while task.wait(0.1) do
	pcall(function()
		local position = workspace.CurrentCamera.CFrame.Position
		local bypass = false

		for _, child in script.Parent.Speakers:GetChildren() do
			if (child.Position - position).Magnitude > 300 then
				continue
			end

			local raycastResult = workspace:Raycast(position, child.Position - position, raycastParams)

			if not (not raycastResult or raycastResult.Instance.Name == "Speaker") then
				continue
			end

			bypass = true
			break
		end

		script.Parent.Mic.AudioEqualizer.Bypass = bypass
	end)
end