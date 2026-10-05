local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Janitor = require(ReplicatedStorage.Modules.Janitor)
local House = require(ReplicatedStorage.Modules.Neighbors.House)
local maid = Janitor.new()
local playerGui = Players.LocalPlayer.PlayerGui
local misc = ReplicatedStorage.Assets.Misc
local colorsByDescendant = {}
local model = nil

local function enable(folder, blackout)
	local currentHouse = House:GetCurrentHouse()

	if workspace.Terrain:FindFirstChild("BLACKOUT_VFX") then
		workspace.Terrain.BLACKOUT_VFX:Destroy()
	end

	TweenService:Create(
		playerGui.Blackout.ImageLabel,
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{
			ImageTransparency = blackout and 0.25 or 1
		}
	):Play()

	if blackout then
		script.Glow:Play()
		local BLACKOUT_VFX = workspace.Terrain:FindFirstChild("BLACKOUT_VFX") or misc.BLACKOUT_VFX:Clone()
		BLACKOUT_VFX.Parent = workspace.Terrain
		BLACKOUT_VFX:PivotTo(currentHouse and currentHouse.Model.PrimaryPart.CFrame * CFrame.new(0, 10, 0) or folder:GetPivot())
		task.spawn(function()
			for _, emitter in BLACKOUT_VFX:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Rate = 0
				end
			end

			for i = 1, 5 do
				if not BLACKOUT_VFX.Parent then
					break
				end

				for _, emitter in BLACKOUT_VFX:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Rate = i
					end
				end

				task.wait(30)
			end
		end)
	else
		script.Glow:Stop()
	end

	_G.Blackout = blackout

	if folder then
		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("Light") then
				descendant.Enabled = not blackout
			elseif descendant:IsA("BasePart") and descendant.Material == Enum.Material.Neon then
				if not colorsByDescendant[descendant] then
					colorsByDescendant[descendant] = descendant.Color
				end

				descendant.Color = blackout and Color3.fromRGB(0, 0, 0) or colorsByDescendant[descendant]
			elseif descendant:IsA("Beam") then
				descendant.Enabled = not blackout
			end
		end
	end
end

local function run()
	maid:Cleanup()
	local currentPrefab = House:GetCurrentPrefab()
	local currentHouse = House:GetCurrentHouse()

	if model then
		enable(model, false)
	end

	model = currentPrefab and currentPrefab.Model
	local model2 = currentHouse and currentHouse.Model

	if model2 then
		enable(currentPrefab.Model, model2:GetAttribute("Blackout") ~= nil)
		maid:Add(model2:GetAttributeChangedSignal("Blackout"):Connect(function()
			enable(currentPrefab.Model, model2:GetAttribute("Blackout") ~= nil)
		end))
	end
end

House.ActiveHouseChanged:Connect(run)
House.ActiveSkinChanged:Connect(run)