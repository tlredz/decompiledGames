local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local gamepad = require(ReplicatedStorage2.client.legacyControllers.InputController):Get("Gamepad")
local localPlayer = game.Players.LocalPlayer
local hud = localPlayer:WaitForChild("PlayerGui"):WaitForChild("hud")
local v = Component.new({
	Tag = "OpenUIPart"
})

function v:Construct()
	self.trove = Trove.new()
	self.open = false
end

function v:Start()
	local maid = self.trove:Extend()

	if not self.Instance:GetAttribute("UI") then
		return
	end

	local child = hud:WaitForChild("safezone"):WaitForChild(self.Instance:GetAttribute("UI"))
	self.trove:Add(self.Instance.Touched:Connect(function(otherPart)
		if otherPart.Name ~= "HumanoidRootPart" or self.Instance:GetAttribute("BlockOpen") then
			return
		end

		local playerFromCharacter = game.Players:GetPlayerFromCharacter(otherPart.Parent)

		if playerFromCharacter and playerFromCharacter == game.Players.LocalPlayer and not self.open then
			self.open = true
			child.Visible = true
		end
	end))
	local MakeOthersButtons

	MakeOthersButtons = function()
		local gift = child:FindFirstChild("Gift", true)
		local close = child:FindFirstChild("Close", true)

		if close then
			maid:Add(close.MouseButton1Click:Connect(function()
				self.open = false
				child.Visible = false
			end))
		end

		if gift then
			maid:Add(gift.MouseButton1Click:Connect(function()
				self.open = false
				child.Visible = false
			end))
		end

		maid:Add(gamepad.ButtonDown:Connect(function(p, flag: boolean?)
			if not (flag ~= true and p == Enum.KeyCode.ButtonB) then
				return
			end

			if child.Visible then
				child.Visible = false
				self.open = false
			end
		end))
		self.trove:Add(child.DescendantAdded:Connect(function(descendant)
			if descendant.Name == "Gift" then
				maid:Add(gift.MouseButton1Click:Connect(function()
					self.open = false
					child.Visible = false
				end))
			elseif descendant.Name == "Close" then
				maid:Add(close.MouseButton1Click:Connect(function()
					self.open = false
					child.Visible = false
				end))
			end
		end))
		self.trove:Add(child.AncestryChanged:Connect(function()
			if not child.Parent then
				self.open = false
				hud = localPlayer:WaitForChild("PlayerGui"):WaitForChild("hud")
				child = hud:WaitForChild("safezone"):WaitForChild(self.Instance:GetAttribute("UI"))
				maid:Clean()
				MakeOthersButtons()
			end
		end))
	end

	MakeOthersButtons()
end

function v.Stop(p)
	p.trove:Destroy()
end

return v