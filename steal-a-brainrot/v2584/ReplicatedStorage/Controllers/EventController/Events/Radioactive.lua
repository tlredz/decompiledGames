local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local Observers = require(ReplicatedStorage.Packages.Observers)
local JumpLTMWeather = require(ReplicatedStorage.Controllers.EventController.JumpLTMWeather)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Spr = require(ReplicatedStorage.Packages.Spr)
local VFX = require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local maid = Trove.new()
local Radioactive = {}

function Radioactive.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	local atmosphere = Lighting:FindFirstChild("Atmosphere")

	if atmosphere then
		atmosphere.Parent = script
		maid:Add(function()
			atmosphere.Parent = Lighting
		end)
	end

	local clone_2 = maid:Clone(script.AtmosphereRadioactive)
	clone_2.Parent = Lighting
	local cartoon = Lighting:FindFirstChild("Cartoon")

	if cartoon then
		cartoon.Parent = script
		maid:Add(function()
			cartoon.Parent = Lighting
		end)
	end

	local clone_3 = maid:Clone(script.SkyRadioactive)
	clone_3.Parent = Lighting
	local v = true
	maid:Add(function()
		v = false
	end)
	EffectController:Activate("Blink")
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	EffectController:Run("RadioactiveEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("RadioactiveEvent", "GrassRecolor")
	end)
	EffectController:Run("RadioactiveEvent", "WallRecolor")
	maid:Add(function()
		EffectController:Stop("RadioactiveEvent", "WallRecolor")
	end)
	EffectController:Run("RadioactiveEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("RadioactiveEvent", "WallBottomRecolor")
	end)
	local clone

	if ServerData.IsTsunamiServer() then
		clone = maid:Clone(script.RadioactiveMapTsunami)
	elseif ServerData.IsBiggerServer() then
		clone = maid:Clone(script.RadioactiveMapBigger)
	else
		clone = maid:Clone(script.RadioactiveMap)
	end

	if not ServerData.IsJumpLTMServer() then
		clone.Parent = workspace
	end

	local function updateDisplay()
		if ServerData.IsTsunamiServer() then
			return
		end

		local v2 = math.floor(math.clamp(ReplicatedStorage:GetAttribute("RadioactiveAlpha") or 0, 0, 1) * 10)

		for _, guiObject in clone.CaveSign.PowerGui.SurfaceGui.Bar:GetChildren() do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			if not v then
				break
			end

			local name2 = tonumber(guiObject.Name)

			if not name2 then
				continue
			end

			local visual = guiObject:FindFirstChild("Visual")

			if not visual then
				continue
			end

			local defaultColor = visual:GetAttribute("DefaultColor")

			if not defaultColor then
				defaultColor = visual.BackgroundColor3
				visual:SetAttribute("DefaultColor", defaultColor)
			end

			local target = Spr.target

			if v2 < name2 then
				defaultColor = Color3.new(0, 0, 0)
			end

			target(visual, 1, 2, {
				BackgroundColor3 = defaultColor
			})
			task.wait(0.2)
		end
	end

	task.spawn(function()
		if ServerData.IsTsunamiServer() then
			return
		end

		for _, guiObject in clone.CaveSign.PowerGui.SurfaceGui.Bar:GetChildren() do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			if not guiObject.Visual:GetAttribute("DefaultColor") then
				local backgroundColor3 = guiObject.Visual.BackgroundColor3
				guiObject.Visual:SetAttribute("DefaultColor", backgroundColor3)
			end

			guiObject.Visual.BackgroundColor3 = Color3.new(0, 0, 0)
		end
	end)
	maid:Add(ReplicatedStorage:GetAttributeChangedSignal("RadioactiveAlpha"):Connect(updateDisplay))
	task.spawn(updateDisplay)

	if ServerData.IsJumpLTMServer() then
		maid:Add(JumpLTMWeather.Cover(script.RadioactiveWeather))
	else
		local clone2

		if ServerData.IsTsunamiServer() then
			clone2 = script.RadioactiveWeatherTsunami:Clone()
		else
			clone2 = script.RadioactiveWeather:Clone()
		end

		clone2.Parent = workspace

		if ServerData.IsBiggerServer() then
			ClientEventUtils.resizeEffects(clone2, 2)
		end

		maid:Add(function()
			VFX.disable(clone2)
			task.wait(4)
			clone2:Destroy()
		end)
	end

	maid:Add(Observers.observeTag("HideInRadioactive", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
	CycleController:Update()
	SoundController:UpdateOST()
end

function Radioactive.OnStop(_)
	maid:Destroy()
end

function Radioactive.OnLoad(_) end

return Radioactive