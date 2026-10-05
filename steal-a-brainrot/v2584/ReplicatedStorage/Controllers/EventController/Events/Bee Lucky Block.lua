local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
game:GetService("SoundService")
game:GetService("TweenService")
game:GetService("HttpService")
game:GetService("RunService")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
require(ReplicatedStorage.Packages.Serialization)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
require(ReplicatedStorage.Packages.CreateTween)
require(ReplicatedStorage.Packages.TopbarPlus)
local Gradients = require(ReplicatedStorage.Packages.Gradients)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Packages.Moonlite)
require(ReplicatedStorage.Packages.Squash)
local BeeLuckyBlockEventFlags = require(ReplicatedStorage.Shared.Flags.BeeLuckyBlockEventFlags)
require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Spr = require(ReplicatedStorage.Packages.Spr)
local Net = require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Controllers.NotificationController)
require(ReplicatedStorage.Controllers.NewPlayersController)
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
require(ReplicatedStorage.Controllers.CharacterController)
require(ReplicatedStorage.Controllers.SoundController)
require(ReplicatedStorage.Controllers.PlotController)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
require(ReplicatedStorage.Utils.TimeUtils)
require(ReplicatedStorage.Shared.VFX)
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
require(ReplicatedStorage.Shared.Updates)
require(ReplicatedStorage.Shared.Animals)
local Animals = require(ReplicatedStorage.Shared.Animals)
require(ReplicatedStorage.Shared.Index)
require(ReplicatedStorage.Datas.Mutations)
local Rarities = require(ReplicatedStorage.Datas.Rarities)
local Animals2 = require(ReplicatedStorage.Datas.Animals)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local _ = script.Name
require(ReplicatedStorage.Shared.EventTypes)
local BeeLuckyBlock = {
	Setup = function(_)
		local frame = playerGui:WaitForChild("BeeLuckyBlock").Frame
		local spawn = frame.Spawn
		local close = frame.Header.Close
		frame.Visible = false
		local v = InterfaceController:Register("BeeLuckyBlockMachine", frame, "TopQuint")
		v:AttachCloseButton(close)
		v:Close()
		local v2 = Synchronizer:Wait(localPlayer)

		if not v2 then
			return
		end

		local function renderBrainrotAtFrame(mid, p)
			local animal = Animals2[p]

			if not animal then
				return
			end

			local rarity = Rarities[animal.Rarity]
			mid.Title.Text = Animals:GetDisplayName(p)

			if rarity.GradientPreset then
				mid.UIStroke.Color = Color3.new(1, 1, 1)
				mid.Title.TextColor3 = Color3.new(1, 1, 1)
				Gradients.apply(mid.UIStroke, rarity.GradientPreset)
				Gradients.apply(mid.Title, rarity.GradientPreset)
			else
				mid.UIStroke.Color = rarity.Color
				mid.Title.TextColor3 = rarity.Color
			end

			mid.Visible = true
			Animals:AttachOnViewportWithOptimizations(p, mid.ViewportFrame)
		end

		renderBrainrotAtFrame(frame.Mid, "Bee Lucky Block")
		frame.Mid.UIStroke.Color = Color3.fromRGB(255, 224, 64)
		frame.Mid.Title.TextColor3 = Color3.fromRGB(255, 224, 64)
		local v3 = AnimatedButton.new(spawn)
		v3:Animate()
		v3.OnActivated:Connect(function()
			Net:RemoteEvent("EventService/Bee Lucky Block/Spawn"):FireServer()
			InterfaceController:SetState("BeeLuckyBlockMachine", false)
		end)

		local function updateHoney()
			local v4 = BeeLuckyBlockEventFlags.SpawnRequirement:Get()
			local v5 = v2:Get({ "BeeEvent", "Honey" }) or 0
			frame.Subtitle.Text = `Collect <font color="rgb(255, 204, 1)">{v4} Honey</font> to spawn a\n<font color="rgb(255, 214, 51)">Bee Lucky Block</font>`
			frame.Progress.Label.Text = `{NumberUtils:Comma(v5)}/{v4}`
			Spr.target(frame.Progress.Fill, 1, 5, {
				Size = UDim2.fromScale(math.clamp(v5 / v4, 0, 1), 1)
			})
			local interactable = v4 <= v5
			frame.Spawn.Interactable = interactable
			local spawn2 = frame.Spawn
			local backgroundColor

			if interactable then
				backgroundColor = Color3.fromRGB(255, 204, 1)
			else
				backgroundColor = Color3.fromRGB(127, 127, 127)
			end

			spawn2.BackgroundColor3 = backgroundColor
		end

		v2:OnChanged({ "BeeEvent", "Honey" }, updateHoney, true)
		BeeLuckyBlockEventFlags.SpawnRequirement.Changed:Connect(function()
			updateHoney()
		end)
	end
}
local v = Trove.new()

function BeeLuckyBlock.OnStart(_) end

function BeeLuckyBlock.OnStop(_)
	v:Clean()
end

function BeeLuckyBlock.OnLoad(p)
	task.spawn(p.Setup, p)
	Observers.observeTag("BeeLuckyBlockAmount", function(instance)
		local maid = Trove.new()
		local count = 0

		local function resize()
			count += 1
			local v2 = count
			task.spawn(function()
				local parent = instance.Parent
				local imageLabel = instance:FindFirstChild("ImageLabel")

				if v2 ~= count or not (parent and parent:IsA("BillboardGui") and imageLabel and imageLabel:IsA("ImageLabel")) then
					return
				end

				local getTextBoundsParams = Instance.new("GetTextBoundsParams")
				getTextBoundsParams.Text = instance.Text
				getTextBoundsParams.Font = instance.FontFace
				getTextBoundsParams.RichText = instance.RichText
				getTextBoundsParams.Size = 100
				local success, textBoundsAsync = pcall(TextService.GetTextBoundsAsync, TextService, getTextBoundsParams)
				getTextBoundsParams:Destroy()

				if not success or textBoundsAsync.Y <= 0 then
					return
				end

				local scale = instance.Size.Y.Scale
				local v3 = parent.Size.Y.Scale / parent.Size.X.Scale
				local v4 = scale * (textBoundsAsync.X / textBoundsAsync.Y) * v3
				local v5 = scale * v3
				local v6 = v5 * 0.15
				instance.Size = UDim2.fromScale(v4, scale)
				instance.Position = UDim2.fromScale(0.5 + (v5 + v6) / 2, instance.Position.Y.Scale)
				imageLabel.AnchorPoint = Vector2.new(1, 0.5)
				imageLabel.Position = UDim2.fromScale(-v6 / v4, 0.5)
				imageLabel.Size = UDim2.fromScale(0.9, 0.9)
				imageLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
			end)
		end

		maid:Add(instance:GetPropertyChangedSignal("Text"):Connect(resize))
		maid:Add(function()
			count += 1
		end)
		count += 1
		local v2 = count
		task.spawn(function()
			local parent = instance.Parent
			local imageLabel = instance:FindFirstChild("ImageLabel")

			if v2 ~= count or not (parent and parent:IsA("BillboardGui") and imageLabel and imageLabel:IsA("ImageLabel")) then
				return
			end

			local getTextBoundsParams = Instance.new("GetTextBoundsParams")
			getTextBoundsParams.Text = instance.Text
			getTextBoundsParams.Font = instance.FontFace
			getTextBoundsParams.RichText = instance.RichText
			getTextBoundsParams.Size = 100
			local success, textBoundsAsync = pcall(TextService.GetTextBoundsAsync, TextService, getTextBoundsParams)
			getTextBoundsParams:Destroy()

			if not success or textBoundsAsync.Y <= 0 then
				return
			end

			local scale = instance.Size.Y.Scale
			local v3 = parent.Size.Y.Scale / parent.Size.X.Scale
			local v4 = scale * (textBoundsAsync.X / textBoundsAsync.Y) * v3
			local v5 = scale * v3
			local v6 = v5 * 0.15
			instance.Size = UDim2.fromScale(v4, scale)
			instance.Position = UDim2.fromScale(0.5 + (v5 + v6) / 2, instance.Position.Y.Scale)
			imageLabel.AnchorPoint = Vector2.new(1, 0.5)
			imageLabel.Position = UDim2.fromScale(-v6 / v4, 0.5)
			imageLabel.Size = UDim2.fromScale(0.9, 0.9)
			imageLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
		end)
		maid:Add(task.spawn(function()
			local v3 = Synchronizer:Wait(localPlayer)

			if not v3 then
				return
			end

			local function updateHoney()
				local v4 = BeeLuckyBlockEventFlags.SpawnRequirement:Get()
				instance.Text = `{NumberUtils:Comma(v3:Get({ "BeeEvent", "Honey" }) or 0)}/{v4}`
			end

			maid:Add(v3:OnChanged({ "BeeEvent", "Honey" }, updateHoney, true))
			maid:Add(BeeLuckyBlockEventFlags.SpawnRequirement.Changed:Connect(function()
				updateHoney()
			end))
		end))
		return maid:WrapClean()
	end)
	Observers.observeTag("BeeLuckyBlockMachinePrompt", function(p2)
		local triggeredConnection = p2.Triggered:Connect(function()
			if not Synchronizer:Get(localPlayer) then
				return
			end

			InterfaceController:Toggle("BeeLuckyBlockMachine")
		end)
		return function()
			triggeredConnection:Disconnect()
		end
	end)
end

return BeeLuckyBlock