local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GUI = require(ReplicatedStorage.Client.GUI)
local Log = require(ReplicatedStorage.Packages.Log)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local TryCall = require(ReplicatedStorage.Shared.Utils.TryCall)
local v = Log.new()
local v2 = nil
local flag = false
return {
	Start = function()
		local function resolveControls()
			local HUD = GUI.HUD()
			local gameHUD

			if HUD ~= nil then
				gameHUD = HUD:FindFirstChild("GameHUD")
			end

			local leftControls

			if gameHUD ~= nil then
				leftControls = gameHUD:FindFirstChild("LeftControls")
			end

			if leftControls == nil then
				return nil, nil
			end

			local shopBTN = leftControls:FindFirstChild("ShopBTN")
			local indexBTN = leftControls:FindFirstChild("IndexBTN")
			local notificationBadge

			if indexBTN ~= nil then
				notificationBadge = indexBTN:FindFirstChild("NotificationBadge")
			end

			if shopBTN == nil or not shopBTN:IsA("GuiObject") then
				return nil, nil
			end

			if notificationBadge == nil or not notificationBadge:IsA("GuiObject") then
				return shopBTN, nil
			end

			return shopBTN, notificationBadge
		end

		local function buildBadge()
			local controls, v3 = resolveControls()

			if controls == nil or v3 == nil then
				v:AtWarning():Log("Shop CTA badge could not find ShopBTN or the index badge to clone")
				return nil
			end

			local shopCtaBadge = controls:FindFirstChild("ShopCtaBadge")

			if shopCtaBadge ~= nil then
				shopCtaBadge:Destroy()
			end

			local clone = v3:Clone()
			clone.Name = "ShopCtaBadge"

			for _, label in clone:GetDescendants() do
				if label:IsA("TextLabel") then
					label.Text = "!"
				end
			end

			clone.Size = UDim2.new(
				clone.Size.X.Scale * 1.4,
				clone.Size.X.Offset * 1.4,
				clone.Size.Y.Scale * 1.4,
				clone.Size.Y.Offset * 1.4
			)
			clone.Visible = true
			clone.Parent = controls
			return clone
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function destroyBadge()
			v2 = nil
			local controls = resolveControls()
			local shopCtaBadge

			if controls ~= nil then
				shopCtaBadge = controls:FindFirstChild("ShopCtaBadge")
			end

			if shopCtaBadge ~= nil then
				shopCtaBadge:Destroy()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function retire()
			if flag then
				return
			end

			flag = true
			destroyBadge() -- equivalent call inferred; original call site unknown
			TryCall(function()
				return Remotes.ShopCta.FlagSeen:InvokeServer()
			end)
		end

		Tabs.Activated:Connect(function(p: string)
			if p == "Shop" then
				retire() -- equivalent call inferred; original call site unknown
			end
		end)
		task.spawn(function()
			local v3, v4 = TryCall(function()
				return Remotes.ShopCta.FetchState:InvokeServer()
			end)

			if not v3 or v4 ~= true then
				return
			end

			if not flag and Tabs.Active() ~= "Shop" then
				v2 = buildBadge()
				return
			end

			retire() -- equivalent call inferred; original call site unknown
		end)
	end
}