local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SGAwards = {}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Utils = require(ReplicatedStorage2.Common.Utils)
local Players = game:GetService("Players")
Players = Players.LocalPlayer
local ServerInfo = require(ReplicatedStorage.ServerInfo)
local v = {}

function Utils.Network.Events.ShowAwardItem(icon: string, ...)
	if not icon:find("rbxassetid://") then
		icon = Utils.Icons:GetIcon(icon)
	end

	SGAwards:ShowAwardItem(icon, ...)
end

function SGAwards:ShowAwardItem(p, p2, p3, _)
	v[#v + 1] = {
		p,
		p2,
		p3,
		true
	}
end

function SGAwards:Binder()
	self.Enabled = true
	local maid = Utils.Maid.new()

	if ServerInfo.isDungeonsMatchServer() then
		self.List.Position += UDim2.fromScale(0, 0.11)
	end

	function SGAwards.ShowAwardItem(_, p2, p3, value, p4)
		local formatted = ("<stroke color=\"#000000\" joins=\"miter\" thickness=\"2\" transparency=\"0.5\">%s</stroke>"):format(value or "%s")
		local v2 = false

		for _, frame in pairs(self.List:GetChildren()) do
			if not frame:IsA("Frame") or frame:GetAttribute("Invalid") or frame.Name == "AwardDisplayFrame" then
				continue
			end

			v2 = true
			break
		end

		if v2 and not p4 then
			v[#v + 1] = {
				p2,
				p3,
				formatted,
				true
			}
			return
		end

		local maid2 = Utils.Maid.new()
		local clone = self.List.AwardDisplayFrame:Clone()
		clone.Name = "Award"
		maid2.Frame = clone
		local v4 = 0
		local target = clone:GetAttribute("Target")
		local v5 = 0
		local visible

		if p2 then
			if p2 == "rbxassetid://0" then
				visible = false
			else
				visible = p2 ~= Utils.Icons:GetIcon("DEFAULT_MISSING")
			end
		else
			visible = p2
		end

		clone.Icon.Image = not visible and "" or p2
		clone.Icon.Visible = visible

		local function Animate()
			for _, frame in pairs(self.List:GetChildren()) do
				if frame:IsA("Frame") then
					frame.LayoutOrder += 1
				end
			end

			clone.LayoutOrder = 1
			v4 = v5
			target = (clone:GetAttribute("Target") or 0) - v5
			maid2.Close = nil
			maid2.TweenText = Utils.Thread.LoopFor(math.min(p3 == 1 and 0.1 or target, 0.75), function(p5)
				v5 = v4 + target * p5
				clone.AmountText.Text = formatted:format(Utils.ValueConvertor:AddCommas((math.floor(v5))))

				if p5 == 1 then
					task.spawn(function()
						local v7 = table.remove(v, 1)

						if not v7 then
							return
						end

						SGAwards:ShowAwardItem(table.unpack(v7))
					end)
					clone:SetAttribute("Invalid", true)
					maid2.Close = Utils.Thread.Delay(2, function()
						maid2:Destroy()
					end)
				end
			end)
		end

		Animate()
		maid2.TargetChanged = clone:GetAttributeChangedSignal("Target"):Connect(function()
			Animate()
		end)
		clone.Visible = true
		clone.Parent = self.List
		maid2.Frame:SetAttribute("Target", (maid2.Frame:GetAttribute("Target") or 0) + p3)
	end

	return maid
end

return SGAwards