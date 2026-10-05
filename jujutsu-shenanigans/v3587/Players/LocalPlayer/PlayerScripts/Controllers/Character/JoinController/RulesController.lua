local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local _ = replicatedStorage.Utils
local _ = replicatedStorage.Sounds
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "RulesController"
})
controller.Rules = require(replicatedStorage.Modules.Rules)

function controller.KnitStart(p)
	local menus = localPlayer.PlayerGui:WaitForChild("Menus")
	local rules = menus.Group.Rules
	rules:SetAttribute("Loaded", true)
	local rule = rules.ScrollingFrame.Rule

	for k, v3 in p.Rules.RuleList do
		local clone = rule:Clone()
		clone.Text = `- {v3}`
		clone.LayoutOrder = k
		clone.Parent = rules.ScrollingFrame
		clone.Text ..= "\n"
	end

	for k, agreement in p.Rules.Agreements do
		local clone = menus.Preset.RuleAgree:Clone()
		clone.Rule.Text = agreement
		clone.LayoutOrder = #p.Rules.RuleList + k
		clone.Parent = rules.ScrollingFrame
		clone.TextButton.MouseButton1Click:Connect(function()
			if clone.TextButton.Text == "" then
				clone.TextButton.Text = "✔️"
			else
				clone.TextButton.Text = ""
			end
		end)
	end

	local lastRulesAccepted = localPlayer:GetAttribute("LastRulesAccepted")

	if not lastRulesAccepted then
		localPlayer:GetAttributeChangedSignal("LastRulesAccepted"):Wait()
		lastRulesAccepted = localPlayer:GetAttribute("LastRulesAccepted")
	end

	if lastRulesAccepted ~= p.Rules.Version then
		rules.Accept.Visible = true
		localPlayer:GetAttributeChangedSignal("LastRulesAccepted"):Once(function()
			lastRulesAccepted = localPlayer:GetAttribute("LastRulesAccepted")

			if lastRulesAccepted == p.Rules.Version then
				for _, child in rules.ScrollingFrame:GetChildren() do
					if child.Name == "RuleAgree" then
						child.Visible = false
					end
				end

				rules.Accept.Visible = false
			end
		end)
	end

	rules.Accept.MouseButton1Click:Connect(function()
		if rules.Accept.Text == "..." then
			return
		end

		local v3 = true

		for _, child in rules.ScrollingFrame:GetChildren() do
			if not (child.Name == "RuleAgree" and child.TextButton.Text ~= "✔️") then
				continue
			end

			v3 = false
			break
		end

		if v3 == false then
			return
		end

		for _, child in rules.ScrollingFrame:GetChildren() do
			if child.Name == "RuleAgree" then
				child.Visible = false
			end
		end

		rules.Accept.Text = "..."
		v.AcceptRules:Fire()
	end)
end

function controller.KnitInit(_)
	v2 = Knit.GetController("FXController")
	v = Knit.GetService("JoinService")
end

return controller