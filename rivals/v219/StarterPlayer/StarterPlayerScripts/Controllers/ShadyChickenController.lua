local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local PreloadController = require(Players.LocalPlayer.PlayerScripts.Controllers.PreloadController)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._shady_chicken_enabled = false
	self:_Init()
	return self
end

function class:_UpdateChickenState(p2)
	if self._shady_chicken_enabled or not PlayerDataController:Get("ShadyChickenMissionStarted") then
		return
	end

	local v = CollectionService:GetTagged("LobbyShadyChicken")[1]

	if not v then
		return
	end

	self._shady_chicken_enabled = true
	task.defer(function()
		Utility:RenderstepForLoop(0, 100, p2 and 100 or 1, function(p3)
			local localTransparencyModifier = p3 / 100

			for i = 1, 3 do
				local waitForChild = v:WaitForChild("Hologram"):WaitForChild("Neon"):WaitForChild(i)
				waitForChild.LocalTransparencyModifier = localTransparencyModifier
			end
		end)
	end)

	if not p2 then
		Utility:CreateSound("rbxassetid://92573395473684", 1, 1, script, true, 10)

		for i = 1, 14 do
			local text = string.rep("•", i - 1) .. string.sub("ILOVERIVALS628", i, i)
			local title = v:WaitForChild("Screen"):WaitForChild("Board"):WaitForChild("SurfaceGui"):WaitForChild("LoginScreen"):WaitForChild("LoginWindow"):WaitForChild("Login"):WaitForChild("Title")
			title.Text = text
			wait(0.1847857142857143)
		end

		local loginWindow = v:WaitForChild("Screen"):WaitForChild("Board"):WaitForChild("SurfaceGui"):WaitForChild("LoginScreen"):WaitForChild("LoginWindow")
		loginWindow.Visible = false
		local dots = v:WaitForChild("Screen"):WaitForChild("Board"):WaitForChild("SurfaceGui"):WaitForChild("LoginScreen"):WaitForChild("Dots")
		dots.Visible = true
		v:WaitForChild("Screen"):WaitForChild("Board"):WaitForChild("SurfaceGui"):WaitForChild("LoginScreen"):WaitForChild("Dots"):AddTag("UILoadingDots")
		wait(4)
		Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
		Utility:CreateSound("rbxassetid://85855678277731", 1.5, 1, script, true, 5)
	end

	v:WaitForChild("Screen"):WaitForChild("Board"):WaitForChild("SurfaceGui"):WaitForChild("LoginScreen"):WaitForChild("Dots"):RemoveTag("UILoadingDots")
	local loginScreen = v:WaitForChild("Screen"):WaitForChild("Board"):WaitForChild("SurfaceGui"):WaitForChild("LoginScreen")
	loginScreen.Visible = false
	local errorScreen = v:WaitForChild("Screen"):WaitForChild("Board"):WaitForChild("SurfaceGui"):WaitForChild("ErrorScreen")
	errorScreen.Visible = true
	local surfaceLight = v:WaitForChild("Screen"):WaitForChild("Board"):WaitForChild("SurfaceLight")
	surfaceLight.Color = Color3.fromRGB(255, 50, 50)
	local imageLabel = v:WaitForChild("Pad"):WaitForChild("Part"):WaitForChild("SurfaceGui"):WaitForChild("ImageLabel")
	imageLabel.ImageColor3 = Color3.fromRGB(255, 50, 50)

	if not p2 then
		task.spawn(Utility.RenderstepForLoop, Utility, 0, 100, 2, function(p3)
			local v2 = 40 * (1 - (p3 / 100) ^ 2)
			local uDim = UDim2.new(0.5, v2 * (math.random() - 0.5), 0.5, v2 * 0.25 * (math.random() - 0.5))
			local loginWindow = v:WaitForChild("Screen"):WaitForChild("Board"):WaitForChild("SurfaceGui"):WaitForChild("ErrorScreen"):WaitForChild("LoginWindow")
			loginWindow.Position = uDim
		end)
		wait(1.5)
	end

	pcall(function()
		v:WaitForChild("Rig"):WaitForChild("Humanoid"):LoadAnimation(PreloadController:GetPreloadedAnimation("ShadyChickenIdle")):Play(0)
	end)
	local broken = v:WaitForChild("Vent"):WaitForChild("Broken")
	broken.Transparency = 0
	v:WaitForChild("Vent"):WaitForChild("NotBroken"):Destroy()

	if not p2 then
		Utility:PlayParticles(v:WaitForChild("Vent"):WaitForChild("VFX"))
		Utility:CreateSound("rbxassetid://73297732048740", 2, 1, script, true, 10)
		Utility:CreateSound("rbxassetid://122754850804619", 1, 1, script, true, 10)
		pcall(function()
			v:WaitForChild("Rig"):WaitForChild("Humanoid"):LoadAnimation(PreloadController:GetPreloadedAnimation("ShadyChickenAppear")):Play(0)
		end)
		wait(2)
		wait(5)
	end

	local proximityPrompt = v:WaitForChild("Prompt"):WaitForChild("ProximityPrompt")
	proximityPrompt.MaxActivationDistance = 16
end

function class._ChickenAdded(_, instance)
	pcall(function()
		instance:WaitForChild("Rig"):WaitForChild("Humanoid"):LoadAnimation(PreloadController:GetPreloadedAnimation("ShadyChickenIdleVent")):Play(0)
	end)
end

function class:_UpdateLoginPrompts()
	local maxActivationDistance = PlayerDataController:Get("ShadyChickenMissionStarted") and 0 or 16

	for _, v2 in pairs(CollectionService:GetTagged("LobbyShadyChickenPrompt")) do
		v2.MaxActivationDistance = maxActivationDistance
	end
end

function class:_LoginPromptAdded(p)
	p.Triggered:Connect(function()
		ReplicatedStorage.Remotes.Misc.StartShadyChickenMission:FireServer()
	end)
	self:_UpdateLoginPrompts()
end

function class:_Init() end

return class._new()