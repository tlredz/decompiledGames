local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local Net = require(packages:WaitForChild("Net"))
local parent = script.Parent
local LeversPuzzle = require(parent:WaitForChild("LeversPuzzle"))
local legacyControllers = ReplicatedStorage.client.legacyControllers
local NotificationController = require(legacyControllers:WaitForChild("NotificationController"))
local CutsceneController = require(legacyControllers:WaitForChild("CutsceneController"))
local PlayerController = require(legacyControllers:WaitForChild("PlayerController"))
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local remoteFunction = Net:RemoteFunction("FrozenLeverPuzzle/ActiveLever")
local remoteFunction2 = Net:RemoteFunction("FrozenLeverPuzzle/RequestLeverState")
local v = nil
local track = nil
local leverpull = ReplicatedStorage:WaitForChild("resources"):WaitForChild("animations"):WaitForChild("player"):WaitForChild("leverpull")
local name = nil
local localPlayer = Players.LocalPlayer
local v2 = {
	[true] = createVector(1.194, 8.343, 1.618),
	[false] = createVector(0.01, 0.01, 0.01)
}
local v3 = {
	[false] = 0,
	[true] = 45
}
local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear)
local enabled = legacyLocalPlayerData.fetch():WaitForChild("Stats"):WaitForChild("hasbodylantern"):WaitForChild("enabled")
local v4 = Component.new({
	Tag = "FrozenLever"
})

function v4:ResetToDefault()
	local weld = self.Instance:WaitForChild("Main"):WaitForChild("Weld")
	weld.C1 = CFrame.Angles(0, 0, (math.rad(v3[self.activated])))
	workspace.CurrentCamera = Enum.CameraType.Custom
	local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")

	if humanoid then
		workspace.CurrentCamera.CameraSubject = humanoid
	end

	PlayerController:ToggleControls(true)
end

function v4:ToggleIce(_: boolean)
	local v5 = self.iceDurability / 100
	local lerped = v2[false]:Lerp(v2[true], v5)
	self.ice.Size = lerped

	if not (self.iceDurability <= 35) then
		self.prompt.Enabled = false
	elseif self.activated == true then
		self.prompt.Enabled = false
	else
		self.prompt.Enabled = true
	end
end

function v4:Toggle(activated: boolean, flag: boolean?)
	if self.activated == activated and flag ~= true then
		return
	end

	self.activated = activated

	if self.activated == true then
		self.prompt.Enabled = false
	end

	local weld = self.Instance:WaitForChild("Main"):WaitForChild("Weld")

	if flag == true then
		weld.C1 = CFrame.Angles(0, 0, (math.rad(v3[self.activated])))
		return
	end

	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local animator = humanoid:FindFirstChild("Animator")

	if not animator then
		return
	end

	PlayerController:ToggleControls(false)
	humanoid:UnequipTools()

	if character ~= v then
		v = character
		track = animator:LoadAnimation(leverpull)
	end

	CutsceneController:Fade(1, 0.2, 0.2)
	task.wait(0.2)

	if not (character and character.Parent) then
		self:ResetToDefault()
		return
	end

	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	local position = self.Instance:WaitForChild("Root").Position
	local position2 = (self.Instance:WaitForChild("Root").CFrame * CFrame.new(createVector(1.945, 2.18, 2.191))).Position
	humanoidRootPart.CFrame = CFrame.new(position2, (Vector3.new(position.X, position2.Y, position.Z)))
	local v5 = self.Instance:WaitForChild("Root").CFrame * CFrame.new(-6, 8, -6)
	local cframe = CFrame.lookAt(v5.Position, position2)
	workspace.CurrentCamera.CFrame = cframe
	task.wait(0.5)

	if not (character and character.Parent) then
		self:ResetToDefault()
		return
	end

	CutsceneController:ShowBars(4, 0.01, 0.1)
	track:Play()
	task.wait(1.3)
	TweenService:Create(weld, tweenInfo, {
		C1 = CFrame.Angles(0, 0, (math.rad(v3[self.activated])))
	}):Play()

	for _, sound in self.Instance:GetDescendants() do
		if sound:IsA("Sound") and sound.Name == "Toggle" then
			sound:Play()
		end
	end

	task.wait(1.5)
	CutsceneController:Fade(1, 0.2, 0.2)
	task.wait(0.2)
	PlayerController:ToggleControls(true)
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	local humanoid2 = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")

	if humanoid2 then
		workspace.CurrentCamera.CameraSubject = humanoid2
	end
end

function v4:Construct()
	self.trove = Trove.new()
	self.prompt = self.Instance:WaitForChild("Root"):WaitForChild("Active")
	self.activated = remoteFunction2:InvokeServer(self.Instance.Name) == true
	self.ice = self.Instance:WaitForChild("Ice")
	self.iceDurability = 100
end

function v4:Start()
	self:Toggle(self.activated, true)
	local prompt = self.prompt
	self.trove:Add(prompt.Triggered:Connect(function()
		local v5, v6 = remoteFunction:InvokeServer(self.Instance.Name)
		local v7 = v5 == true

		if v6 then
			NotificationController:Notify(v6, 5)
		end

		for _, v8 in LeversPuzzle:GetAll() do
			local v9 = v8
			task.spawn(function()
				v9:SetLightState(self.Instance.Name, v7)
			end)
		end

		self:Toggle(v7)
	end))
	self.trove:Add(RunService.RenderStepped:Connect(function(dt: number)
		local v5 = 1
		local character = localPlayer.Character

		if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				local magnitude = (self.Instance:WaitForChild("Root").Position - humanoidRootPart.Position).Magnitude

				if magnitude <= 15 then
					if magnitude <= 10 and name ~= self.Instance.Name then
						name = self.Instance.Name

						if enabled.Value == true then
							NotificationController:Notify(
								"It looks like the light from my lantern is melting the ice!",
								10
							)
						else
							NotificationController:Notify("Maybe if I find a source of heat, I can thaw the lever!", 10)
						end
					end

					v5 = enabled.Value == true and -1 or v5
				end
			end
		end

		local v6 = v5 * 5 * dt
		self.iceDurability = math.clamp(self.iceDurability + v6, 0, 100)
		self:ToggleIce(dt)
	end))
end

function v4.Stop(p)
	p.trove:Destroy()
end

return v4