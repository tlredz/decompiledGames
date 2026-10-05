local ViewportOverlay = {
	HIGHEST_DISPLAY_ORDER = -1
}
local Lock = require(game.ReplicatedStorage.Modules.Util.Lock)
local v = Lock.new()
local v2 = nil
local v3 = nil
local v4 = nil
local displayOrder = nil
local displayOrder2 = nil

function ViewportOverlay:SetDisplayOrder(displayOrder3: number)
	displayOrder2 = v2.DisplayOrder
	v2.DisplayOrder = displayOrder3
	displayOrder = displayOrder3
	v3.DisplayOrder = displayOrder + 1
	return self
end

function ViewportOverlay:Lock(p: string)
	v:Lock(p)
end

function ViewportOverlay:Unlock(p: string)
	v:Unlock(p)
end

function ViewportOverlay:Connect(p)
	return v:Connect(p)
end

function ViewportOverlay.OnStart(_)
	local PlayerUtil = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PlayerUtil"))
	PlayerUtil.ScreenReady({ "ViewportOverlay", "Prompt", "Notifications" }, function(data)
		v2 = assert(data.ViewportOverlay, "bad ViewportOverlay")
		v3 = assert(data.Notifications, "bad package.Notifications")
		v4 = assert(data.Prompt, "bad package.Prompt")
		ViewportOverlay.HIGHEST_DISPLAY_ORDER = v4.DisplayOrder
		displayOrder = v2.DisplayOrder
		displayOrder2 = displayOrder
		v2.Enabled = v:IsLocked() == true
		ViewportOverlay:Connect(function(_)
			v2.Enabled = v:IsLocked() == true

			if not v2.Enabled then
				displayOrder = -10
				v2.DisplayOrder = displayOrder
				task.defer(function()
					v3.DisplayOrder = displayOrder
				end)
			end
		end)
		game.GuiService.MenuOpened:Connect(function()
			v:ClearLocks()
		end)
		game.Players.LocalPlayer:GetAttributeChangedSignal("RobuxPurchasePrompt"):Connect(function()
			if not game.Players.LocalPlayer:GetAttribute("RobuxPurchasePrompt") then
				v:Unlock("RobuxPurchasePrompt")
				return
			end

			ViewportOverlay:SetDisplayOrder(ViewportOverlay.HIGHEST_DISPLAY_ORDER + 1)
			v:Lock("RobuxPurchasePrompt")
		end)
	end, (`Init {script.Name}`))
end

return ViewportOverlay