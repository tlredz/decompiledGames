local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local AssetItems = require(ReplicatedStorage.Shared.Util.AssetItems)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
require(script.Parent.Types.Interface)
local color = Color3.fromRGB(60, 255, 0)
local color2 = Color3.fromRGB(136, 255, 0)
local color3 = Color3.fromRGB(190, 255, 180)
local color4 = nil
local color5 = nil

local function applyClaimableLook(claim, active: boolean)
	local uIGradient = claim:FindFirstChildOfClass("UIGradient")

	if uIGradient ~= nil then
		if color4 == nil then
			color4 = uIGradient.Color
		end

		if active then
			local claimableColorStart = claim:GetAttribute("ClaimableColorStart")
			local claimableColorEnd = claim:GetAttribute("ClaimableColorEnd")
			uIGradient.Color = ColorSequence.new(claimableColorStart or color, claimableColorEnd or color2)
		else
			uIGradient.Color = color4
		end
	end

	local uIStrokeClr = claim:FindFirstChild("UIStrokeClr")

	if uIStrokeClr == nil or not uIStrokeClr:IsA("UIStroke") then
		return
	end

	if color5 == nil then
		color5 = uIStrokeClr.Color
	end

	if active then
		uIStrokeClr.Color = claim:GetAttribute("ClaimableStrokeColor") or color3
	else
		uIStrokeClr.Color = color5
	end
end

return {
	Render = function(p, p2, flag: boolean, active: boolean)
		t.strict(t.boolean)(flag)
		t.strict(t.boolean)(active)
		local claim = p.Claim
		claim.Active = active

		if p2 == nil then
			claim.TextLabel.Text = "CLAIM!"
			local uIGradient = claim:FindFirstChildOfClass("UIGradient")

			if uIGradient ~= nil then
				if color4 == nil then
					color4 = uIGradient.Color
				end

				uIGradient.Color = color4
			end

			local uIStrokeClr = claim:FindFirstChild("UIStrokeClr")

			if uIStrokeClr ~= nil then
				if not uIStrokeClr:IsA("UIStroke") then
					return
				end

				if color5 == nil then
					color5 = uIStrokeClr.Color
				end

				uIStrokeClr.Color = color5
			end
		else
			p.Rewards.SpeedReward.TextLabel.Text = "+" .. Simple.FormatCompact(
				AssetItems.IndexSpeedReward(p2.Category),
				".#"
			)
			p.Rewards.MoneyReward.TextLabel.Text = "$" .. Simple.FormatCompact(
				AssetItems.IndexMoneyReward(p2.Category),
				".#"
			)
			claim.TextLabel.Text = flag and "CLAIMED!" or "CLAIM!"
			applyClaimableLook(claim, active)
		end
	end
}