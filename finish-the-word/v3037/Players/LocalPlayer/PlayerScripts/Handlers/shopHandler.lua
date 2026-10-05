local import = _G.import("romodel")
local import2 = _G.import("event")
local import3 = _G.import("modelUtil")
local import4 = _G.import("viewImports")
local blockShopOverlay = import4:get("blockShopOverlay").BlockShopOverlay
local wipeDown = import4:get("wipeDown").WipeDown
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local replicatedAssets = game.ReplicatedStorage.ReplicatedAssets
local v = nil

local function openShop()
	if v then
		return
	end

	v = import.mount(import.make(blockShopOverlay), playerGui)
	import2.fire("setHudVisibility", false)
	import2.fire("hudLock")
	local clone = replicatedAssets.Misc.ShopVisual:Clone()
	clone.Parent = workspace.Meta
end

local function closeShop()
	if not v then
		return
	end

	v:Destroy()
	v = nil
	import2.fire("hudUnlock")
	import2.fire("setHudVisibility", true)
	localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new((workspace.Meta.ShopButton.Trigger.CFrame * CFrame.new(
		2.5,
		0,
		10
	)).p)
	workspace.Meta:FindFirstChild("ShopVisual"):Destroy()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shopPrompt()
	local trigger = workspace.Meta.ShopButton.Trigger
	local proximityPrompt = Instance.new("ProximityPrompt")
	local flag = nil
	proximityPrompt.MaxActivationDistance = 6
	proximityPrompt.PromptShown:Connect(function()
		if flag or v then
			return
		end

		flag = true
		import.mount(import.make(wipeDown, {
			Callback = function()
				flag = false
				openShop()
			end
		}), playerGui)
	end)
	proximityPrompt.Parent = trigger
end

return {
	Priority = 1,
	Run = function()
		import3.getAttribute(workspace, "Mode"):andThen(function(p)
			if p == "RANKED" then
				return
			end

			shopPrompt() -- equivalent call inferred; original call site unknown
		end)
		import2.connect("openShop", openShop, {
			Blocking = true
		})
		import2.connect("closeShop", closeShop, {
			Blocking = true
		})
		import2.connect("setShopTab", function(p)
			if v then
				v:setTab(p)
			end
		end)
	end
}