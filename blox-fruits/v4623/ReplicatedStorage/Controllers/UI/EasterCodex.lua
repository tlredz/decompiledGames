local EasterCodex = {
	_Close = nil
}
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local createElement = React.createElement
local HUD = require(game.ReplicatedStorage.Controllers.UI.HUD)
local EasterCodex2 = require(game.ReplicatedStorage.React.Components.EasterCodex)
local EasterNetwork = require(script.EasterNetwork)
EasterNetwork._Start()
local v = nil

function EasterCodex:Close()
	if EasterCodex._Close then
		EasterCodex._Close()
	end
end

function EasterCodex.Toggle(_)
	if EasterCodex.IsOpen() then
		EasterCodex:Close()
	else
		EasterCodex:Open()
	end
end

function EasterCodex.IsOpen()
	return v ~= nil
end

function EasterCodex:Open()
	if EasterCodex.IsOpen() then
		return
	end

	if v then
		v:Destroy()
	end

	if not EasterNetwork.IsClaimingEnabled() then
		return
	end

	local Global = require(game.ReplicatedStorage.Global)
	Global.closeOthers()
	local screenGui = Instance.new("ScreenGui")
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	screenGui.IgnoreGuiInset = true
	screenGui.Name = "EasterCodex"
	local Players = game:GetService("Players")
	screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	screenGui.DisplayOrder = 1
	screenGui.Enabled = true
	screenGui.ResetOnSpawn = false
	local root = ReactRoblox.createRoot(screenGui)
	local element = createElement(function()
		local state, setState = React.useState(true)

		function EasterCodex._Close()
			if not state then
				return
			end

			setState(false)
		end

		return createElement(EasterCodex2, {
			IsOpen = state,
			OnFinish = function()
				if not state and v then
					v:Destroy()
					root:unmount()
					screenGui:Destroy()
				end
			end,
			OnClaim = function(p)
				if EasterNetwork.TryClaimReward(p) then
					local Sound = require(game.ReplicatedStorage.Util.Sound)
					Sound:Play("Berries.Collect.Default")
				end
			end,
			OnClose = EasterCodex._Close
		})
	end)
	local maid = Trove.new()
	maid:Add(function()
		v = nil
		EasterCodex._Close = nil

		for _, v2 in pairs(EasterNetwork.GetData().Index) do
			v2.IsNew = nil
		end
	end)
	v = maid
	root:render(element)
	task.spawn(function()
		while not HUD.IsInitialized do
			task.wait()
		end

		assert(HUD.IsInitialized, "bad HUD")
		HUD:RegisterPage("EasterCodex", function(...)
			return self:Open(...)
		end, function(...)
			return self:Close(...)
		end, function()
			return self:IsOpen()
		end)
	end)
end

return EasterCodex