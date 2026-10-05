local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local InterfaceController = require(ReplicatedStorage.Controllers.InterfaceController)
local Animals = require(ReplicatedStorage.Shared.Animals)
local Index = require(ReplicatedStorage.Shared.Index)
local BaseSkins = require(ReplicatedStorage.Shared.BaseSkins)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Gradients = require(ReplicatedStorage.Packages.Gradients)
local Updates = require(ReplicatedStorage.Shared.Updates)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Spr = require(ReplicatedStorage.Packages.Spr)
local Net = require(ReplicatedStorage.Packages.Net)
local Rarities = require(ReplicatedStorage.Datas.Rarities)
local Animals2 = require(ReplicatedStorage.Datas.Animals)
local Index2 = require(ReplicatedStorage.Datas.Index)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local remoteEvent = Net:RemoteEvent("BaseIndexService/Claim")

local function resolveFramePath(p, value: string)
	for k in string.gmatch(value, "[^%.]+") do
		p = p[k]
	end

	return p
end

local function renderBrainrotAtFrame(clone, p: string)
	local animal = Animals2[p]

	if not animal then
		return
	end

	local rarity = Rarities[animal.Rarity]
	clone.Title.Text = Animals:GetDisplayName(p)
	clone.RarityLabel.Text = animal.Rarity

	if rarity.GradientPreset then
		clone.RarityLabel.TextColor3 = Color3.new(1, 1, 1)
		Gradients.apply(clone.RarityLabel, rarity.GradientPreset)
	else
		clone.RarityLabel.TextColor3 = rarity.Color
	end

	clone.Visible = true
	Animals:AttachOnViewportWithOptimizations(p, clone.ViewportFrame)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupMotorAnimation(maid, motorTag: string)
	maid:Add(Observers.observeTag(motorTag, function(p)
		local v = os.clock() + 15
		local v2 = nil
		local v3 = nil
		local now = os.clock()
		local postSimulationConnection = RunService.PostSimulation:Connect(function()
			local now2 = os.clock()
			p.Transform = CFrame.new(0, math.sin(now2 * 2) * 0.25, 0)

			if v < now2 then
				v3 = 0
				v = now2 + 15
			elseif v3 ~= nil then
				local v4 = now2 - now
				v3 += v4
				local v5 = v3 / 2
				local value = TweenService:GetValue(v5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
				p.Transform *= CFrame.Angles(0, value * 3 * 3.141592653589793 * 2, 0)

				if v5 > 0.75 and not v2 then
					v2 = 0
				end

				if v3 >= 2 then
					v3 = nil
				end
			end

			if v2 ~= nil then
				v2 += now2 - now
				local v4

				if v3 == nil then
					v4 = 1 - math.clamp(v2 / 2, 0, 1)
				else
					v4 = math.clamp((v3 / 2 - 0.5) / 0.5, 0, 1)
				end

				local v5 = now2 * 14
				local v6 = 0.04 * v4
				local v7 = 0.025 * v4
				local v8 = CFrame.new(math.noise(v5, 0, 0) * v6, math.noise(0, v5, 0) * v6, 0) * CFrame.Angles(
					math.noise(v5, v5, 0) * v7,
					0,
					math.noise(0, v5, v5) * v7
				)
				p.Transform *= v8

				if v3 == nil and v2 >= 2 then
					v2 = nil
				end
			end

			now = now2
		end)
		return function()
			postSimulationConnection:Disconnect()
			p.Transform = CFrame.identity
		end
	end))
end

return {
	Register = function(self, data)
		local maid = Trove.new()
		maid:Add(task.spawn(function()
			local child = playerGui:WaitForChild(data.ScreenGuiName)
			local framePath = data.FramePath

			for k in string.gmatch(framePath, "[^%.]+") do
				child = child[k]
			end

			child.Visible = false
			local v = InterfaceController:Get(data.ScreenGuiName)
			local v2 = v or InterfaceController:Register(data.ScreenGuiName, child, "TopQuint")

			if not v then
				v2:AttachCloseButton(child.Main.Header.Close)
			end

			v2:Close()
			local v3 = Synchronizer:Wait(localPlayer)

			if not v3 then
				return
			end

			local maid2 = maid:Extend()

			local function updateBrainrots()
				maid2:Clean()
				local list = child.Main.Content.Holder.List

				for _, guiObject in list:GetChildren() do
					if guiObject:IsA("GuiObject") and guiObject.Name ~= "Template" then
						guiObject:Destroy()
					end
				end

				local list2 = Animals:GetList("Generation", true)
				local v4 = assert(Index2[data.IndexName].Index)

				for i = 1, #list2 do
					local name = list2[i]

					if not (v4[name] and Animals2[name]) then
						continue
					end

					local clone = maid2:Clone(child.Main.Content.Holder.List.Template)
					clone.Name = name
					clone.LayoutOrder = i
					renderBrainrotAtFrame(clone, name)
					clone.Visible = true
					local viewportFrame = clone.ViewportFrame
					local name2 = name
					local indexName = data.IndexName

					local function updateAnimal()
						local v10 = v3:Get({ "Index", name2 })
						local visible = v10 ~= nil and v10[indexName] or nil
						clone.Title.Visible = visible
						viewportFrame.ImageColor3 = not visible and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(
							255,
							255,
							255
						)
					end

					maid2:Add(v3:OnChanged({ "Index", name }, updateAnimal, true))
					task.spawn(updateAnimal)
					clone.Parent = list
				end
			end

			updateBrainrots()
			local skinName = data.SkinName
			local id = data.Id

			local function updateProgress()
				local indexAnimals, v4, v5 = Index:GetIndexAnimals(localPlayer, data.IndexName)
				assert(indexAnimals, v4, v5)
				local v6 = v3:Get((`ClaimedBaseSkins.{skinName}`)) == true or BaseSkins.Owns(v3, skinName)
				child.Main.Content.Base.AmountLabel.Text = `{indexAnimals}/{v4}`
				child.Main.Content.Base.Claim.Label.Text = v6 and "Claimed" or "Claim"
				local target = Spr.target
				local claim = child.Main.Content.Base.Claim
				local backgroundColor

				if v4 <= indexAnimals and not v6 then
					backgroundColor = Color3.fromRGB(81, 158, 86)
				else
					backgroundColor = Color3.fromRGB(112, 112, 112)
				end

				target(claim, 1, 5, {
					BackgroundColor3 = backgroundColor
				})
			end

			maid:Add(child.Main.Content.Base.Claim.Activated:Connect(function()
				remoteEvent:FireServer(id)
			end))
			maid:Add(v3:OnChanged("AnimalAddedOrRemoved", updateProgress))
			maid:Add(v3:OnDictionaryInserted("UnlockedBaseSkins", updateProgress))
			maid:Add(v3:OnDictionaryRemoved("UnlockedBaseSkins", updateProgress))
			maid:Add(v3:OnDictionaryInserted("BaseSkinInventory", updateProgress))
			maid:Add(v3:OnDictionaryRemoved("BaseSkinInventory", updateProgress))
			maid:Add(v3:OnDictionaryInserted("ClaimedBaseSkins", updateProgress))
			maid:Add(Updates.OnUpdateEnabled:Connect(function()
				updateBrainrots()
				updateProgress()
			end))
			maid:Add(Updates.OnUpdateDisabled:Connect(function()
				updateBrainrots()
				updateProgress()
			end))
			updateProgress()
		end))
		maid:Add(Observers.observeTag(data.PromptTag, function(p)
			local triggeredConnection = p.Triggered:Connect(function()
				if not Synchronizer:Get(localPlayer) then
					return
				end

				InterfaceController:Toggle(data.ScreenGuiName)
			end)
			return function()
				triggeredConnection:Disconnect()
			end
		end))

		if data.MotorTag then
			setupMotorAnimation(maid, data.MotorTag) -- equivalent call inferred; original call site unknown
		end

		return maid
	end
}