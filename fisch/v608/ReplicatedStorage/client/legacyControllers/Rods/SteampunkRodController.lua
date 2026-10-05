local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = game.Players.LocalPlayer.PlayerGui
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local module = require("../HudController")
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 206, 61)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 120, 40))
})
local formatted = `<b>{FischUtils.GradientRichText("Steampunk Energy:", colorSequence)}</b>`
return {
	Start = function(_)
		local safeZone = module:GetSafeZone()
		local UI = ReplicatedStorage.client.legacyControllers:WaitForChild("Rods"):WaitForChild("SpiritPassiveController"):WaitForChild("UI")
		local scrollingFrame = safeZone:WaitForChild("equipment").Container.Rods.Main.ScrollingFrame

		local function isSteampunkRod(instance)
			if instance.Name ~= "Steampunk Rod" then
				return
			end

			local stats = instance:FindFirstChild("Stats")

			if not stats or stats:FindFirstChild("spiritStats") then
				return
			end

			local clone = UI.spiritStats:Clone()
			clone.Parent = stats
			local clone2 = UI.spiritSample:Clone()
			clone2.Name = "SteampunkEnergy"
			clone2.Icon.Image = "rbxassetid://77215890862281"
			clone2.Bar.Fill.Size = UDim2.fromScale(0, 1)
			clone2.Icon.Hover:SetAttribute("TooltipColor", colorSequence)
			clone2.Icon.Hover:AddTag("HoverTooltip")
			local uIGradient = Instance.new("UIGradient")
			uIGradient.Color = colorSequence
			uIGradient.Parent = clone2.Bar.Fill
			clone2.Parent = clone.Container

			local function updateBar(value: number?)
				local v = math.clamp(value or 0, 0, 1)
				GeneralUtils.fastTween(
					clone2.Bar.Fill,
					TweenInfo.new(2.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
					{
						Size = UDim2.fromScale(v, 1)
					}
				)
				clone2.Icon.Hover:SetAttribute("TooltipText", (`{formatted} {math.round(v * 100)}%`))
			end

			playerDataReplicator:Observe({ "SteampunkEnergy" }, updateBar)
		end

		scrollingFrame.ChildAdded:Connect(isSteampunkRod)

		for _, frame in scrollingFrame:GetChildren() do
			if frame:IsA("Frame") then
				task.spawn(isSteampunkRod, frame)
			end
		end
	end
}