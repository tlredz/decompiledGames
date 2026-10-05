local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local SupportClass = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local flag = false

function TweenSolidColorSequence(colorSequences, p, p2, p3, duration)
	local color3Value = Instance.new("Color3Value")
	color3Value.Value = p2
	local tween = TweenService:Create(color3Value, TweenInfo.new(duration), {
		Value = p3
	})
	color3Value.Changed:Connect(function()
		colorSequences[p] = ColorSequence.new(color3Value.Value)
	end)
	tween:Play()
	tween.Completed:Connect(function()
		color3Value:Destroy()
	end)
	return tween
end

function NewBeam(player)
	local attachment = Instance.new("Attachment")
	attachment.Parent = workspace.Terrain
	local attachment2 = Instance.new("Attachment")
	attachment2.Parent = workspace.Terrain
	local supportBeam = ReplicatedStorage.Assets.Particles.SupportBeam
	local clones = {}

	for _, child in pairs(supportBeam:GetChildren()) do
		local clone = child:Clone()

		if clone.Name == "Beam1" then
			clone.Attachment0 = attachment
			clone.Attachment1 = attachment2
		else
			clone.Attachment0 = attachment2
			clone.Attachment1 = attachment
		end

		clone.Parent = workspace.Particles
		table.insert(clones, clone)
	end

	task.spawn(function()
		while clones do
			local pivot = localPlayer.Character and localPlayer.Character:GetPivot()
			local pivot2 = player.Character and player.Character:GetPivot()
			local v = 0
			local v2

			if pivot and pivot2 then
				attachment.WorldCFrame = pivot
				attachment2.WorldCFrame = pivot2
				local magnitude = (pivot.Position - pivot2.Position).Magnitude
				local v3 = localPlayer:GetAttribute("Class") == "Support" and (localPlayer:GetAttribute("ClassLevel") or 1) >= 3 and 0.965 or 1
				local v4 = math.clamp(magnitude, 0, 150) / 150 * (v3 - 0.75) + 0.75

				for _, v5 in pairs(clones) do
					v5.Transparency = NumberSequence.new(v4)
				end

				v2 = magnitude > 190 and v4 >= 1 and 1 or v
			else
				for _, v3 in pairs(clones) do
					v3.Transparency = NumberSequence.new(1)
				end

				v2 = 1
			end

			task.wait(v2)
		end
	end)

	local function flashBeamsRed()
		for _, v in pairs(clones) do
			TweenSolidColorSequence(v, "Color", Color3.fromRGB(255, 255, 255), Color3.new(1, 0, 0.0156863), 0.2)
			local v2 = v
			task.spawn(function()
				wait(0.2)

				if v2 then
					TweenSolidColorSequence(v2, "Color", Color3.fromRGB(255, 0, 4), Color3.new(1, 1, 1), 0.2)
				end
			end)
		end
	end

	local supportPlayerDamagedConnection = Client.Events.SupportPlayerDamaged:Connect(function(p)
		if p == localPlayer or p == player then
			flashBeamsRed()
		end
	end)
	return function()
		supportPlayerDamagedConnection:Disconnect()

		for _, v in pairs(clones) do
			v:Destroy()
		end

		clones = nil
		attachment:Destroy()
		attachment2:Destroy()
	end
end

function MakeBeam(player)
	if not player then
		return
	end

	Client.Sound.Play("TetherCreated")
	local v = NewBeam(player)
	task.spawn(function()
		for _, child in pairs(ReplicatedStorage.Assets.Particles.SupportSparkle:GetChildren()) do
			local clone = child:Clone()
			local clone2 = child:Clone()

			if localPlayer.Character.HumanoidRootPart:FindFirstChild("RootAttachment") then
				clone.Parent = localPlayer.Character.HumanoidRootPart.RootAttachment
				clone:Emit(clone:GetAttribute("EmitCount"))
			end

			if not player.Character.HumanoidRootPart:FindFirstChild("RootAttachment") then
				continue
			end

			clone2.Parent = player.Character.HumanoidRootPart.RootAttachment
			clone2:Emit(clone:GetAttribute("EmitCount"))
		end
	end)
	return function()
		v()
	end
end

function LoadSupportEffects()
	local v = nil
	localPlayer:GetAttributeChangedSignal("SupportingPlayer"):Connect(function()
		if v then
			v()
			v = nil
		end

		local supportingPlayer = localPlayer:GetAttribute("SupportingPlayer")
		local playerByUserId = supportingPlayer and game.Players:GetPlayerByUserId(supportingPlayer)

		if playerByUserId then
			v = MakeBeam(playerByUserId)
		end
	end)
	local v2 = nil
	localPlayer:GetAttributeChangedSignal("SupportedBy"):Connect(function()
		if v2 then
			v2()
			v2 = nil
		end

		local supportedBy = localPlayer:GetAttribute("SupportedBy")
		local playerByUserId = supportedBy and game.Players:GetPlayerByUserId(supportedBy)

		if playerByUserId then
			v2 = MakeBeam(playerByUserId)
		end
	end)
end

function EnableClass()
	if flag then
		return
	end

	flag = true
end

function SupportClass.Init()
	task.spawn(function()
		LoadSupportEffects()
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function check()
		if localPlayer:GetAttribute("Class") == "Support" then
			EnableClass()
		end
	end

	localPlayer:GetAttributeChangedSignal("Class"):Connect(check)
	localPlayer:GetAttributeChangedSignal("ClassLevel"):Connect(check)
	check() -- equivalent call inferred; original call site unknown
end

return SupportClass