local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local _ = game.Players.LocalPlayer.PlayerGui
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local rods = require(ReplicatedStorage.shared.modules.library.rods)
require(ReplicatedStorage.shared.modules.GeneralUIModule)
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local module = require("../HudController")
local v = {
	Winter = {
		Icon = "rbxassetid://96573108635127",
		Gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(105, 215, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(75, 147, 255))
		})
	},
	Spring = {
		Icon = "rbxassetid://139646996345309",
		Gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(128, 255, 153)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(133, 234, 56))
		})
	},
	Summer = {
		Icon = "rbxassetid://110423884585357",
		Gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 229, 99)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(238, 124, 49))
		})
	},
	Autumn = {
		Icon = "rbxassetid://129768906947391",
		Gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(230, 130, 63)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(197, 67, 27))
		})
	},
	Nightly = {
		Icon = "rbxassetid://91514794056774",
		Gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(112, 99, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(89, 31, 235))
		})
	}
}
return {
	Start = function(_)
		local safeZone = module:GetSafeZone()
		local UI = script:WaitForChild("UI")
		local scrollingFrame = safeZone:WaitForChild("equipment").Container.Rods.Main.ScrollingFrame

		local function isSpiritOfTheForest(instance)
			if instance.Name ~= "Spirit of the Forest" then
				return
			end

			local stats = instance:FindFirstChild("Stats")

			if not stats or stats:FindFirstChild("spiritStats") then
				return
			end

			local clone = UI.spiritStats:Clone()
			clone.Parent = stats
			local spirits = rods["Spirit of the Forest"].FishingPassives.Spirits

			local function updateTooltipText(p)
				local name = p.Name
				local spirit = spirits.Spirits[name]
				local v2 = v[name]
				local v3 = (DataController.PlayerDataReplicator:TryIndex({ "ActiveSpirits", name }) or 0) / spirit.Max
				p.Icon.Hover:SetAttribute(
					"TooltipText",
					(`<b>{FischUtils.GradientRichText(`{name} Spirit:`, v2.Gradient)}</b> Boosts {spirit.StatBoost[1] == "Lure" and "Lure Speed" or spirit.StatBoost[1] == "ProgressSpeed" and "Progress Speed" or spirit.StatBoost[1]} ({math.round(v3 * 100)}%)`)
				)
			end

			for k, _ in spirits.Spirits do
				local v2 = v[k]
				local clone2 = UI.spiritSample:Clone()
				clone2.Name = k
				clone2.Icon.Image = v2.Icon or ""
				clone2.Bar.Fill.Size = UDim2.fromScale(0, 1)
				updateTooltipText(clone2)
				clone2.Icon.Hover:SetAttribute("TooltipColor", v2.Gradient)
				clone2.Icon.Hover:AddTag("HoverTooltip")
				local uIGradient = Instance.new("UIGradient")
				uIGradient.Color = v2.Gradient
				uIGradient.Parent = clone2.Bar.Fill
				clone2.Parent = clone.Container
			end

			DataController.PlayerDataReplicator:Observe({ "ActiveSpirits" }, function(items)
				if not items then
					return
				end

				for childName, item in items do
					local child = clone.Container:FindFirstChild(childName)

					if not child then
						continue
					end

					local max = spirits.Spirits[childName].Max
					GeneralUtils.fastTween(
						child.Bar.Fill,
						TweenInfo.new(2.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
						{
							Size = UDim2.fromScale(item / max, 1)
						}
					)
					updateTooltipText(child)
				end
			end)
		end

		scrollingFrame.ChildAdded:Connect(isSpiritOfTheForest)

		for _, frame in scrollingFrame:GetChildren() do
			if frame:IsA("Frame") then
				task.spawn(isSpiritOfTheForest, frame)
			end
		end
	end
}