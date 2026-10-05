local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Signal)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local v4 = require3(ReplicatedStorage2.ClientGameModules.CoreCall)
local v5 = require3(ReplicatedStorage2.Shared.BattlepassUIType)
local v6 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v7 = require3(ReplicatedStorage2.Controllers.ShowRoomController)
local v8 = require3(ReplicatedStorage2.Controllers.UI.UIStateController)
local v9 = require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local v10 = nil
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local v11 = nil
local battlepass = playerGui:WaitForChild("Battlepass")
local battlepassCurrencyShop = playerGui:WaitForChild("BattlepassCurrencyShop")
local background = battlepass.Main.Background
playerGui:WaitForChild("Hotbar")
local voter = localPlayer.PlayerGui:WaitForChild("voter")
local BattlepassViewController = {
	_views = {},
	_selectedView = "NONE",
	CreateView = function(p, p2: string, guiObject)
		local v12 = {
			_instance = guiObject,
			_openSignal = v.new(),
			_closeSignal = v.new()
		}

		if guiObject:IsA("GuiObject") then
			guiObject.Visible = false
		end

		p._views[p2] = v12
		return v12
	end,
	GetView = function(self, p2: string)
		return self._views[p2]
	end,
	OnViewOpen = function(self, p: string)
		local view = self:GetView(p)

		if view then
			return view._openSignal
		end
	end,
	OnViewClosed = function(self, p: string)
		local view = self:GetView(p)

		if view then
			return view._closeSignal
		end
	end
}

function _popView(p, p2: string, _: string?)
	p._closeSignal:Fire(true)

	if p2 ~= "DailyLogin" then
		if p._instance:IsA("GuiObject") then
			p._instance.Visible = false
		else
			p._instance.Enabled = false
		end
	end
end

function _pushView(p)
	p._openSignal:Fire(true)

	if p._instance:IsA("GuiObject") then
		p._instance.Visible = true
	else
		p._instance.Enabled = true
	end
end

function _renderToView(selectedView: string, p: string?)
	local view = BattlepassViewController._selectedView ~= "NONE" and BattlepassViewController:GetView(BattlepassViewController._selectedView)

	if view then
		_popView(view, BattlepassViewController._selectedView, p)
	end

	BattlepassViewController._selectedView = selectedView
	local view2 = BattlepassViewController:GetView(selectedView)

	if view2 then
		_pushView(view2)
	end
end

function BattlepassViewController:OpenView(lastView: string)
	if v5 == "ShowRoom" then
		_renderToView(lastView, self.LastView)
		self.LastView = lastView
	else
		local view = self:GetView(lastView)

		if not view then
			return
		end

		local _instance = view._instance

		if not _instance then
			return
		end

		v6:Open(_instance.Name)
		view._openSignal:Fire(true)
	end
end

function BattlepassViewController.CloseView(object, p: string)
	if v5 == "ShowRoom" then
		local view = object:GetView(p)

		if not view then
			return
		end

		_popView(view)
	else
		local view = object:GetView(p)

		if not view then
			return
		end

		local _instance = view._instance

		if not _instance then
			return
		end

		v6:Close(_instance.Name)
		view._openSignal:Fire(false)
		v6:Open("Battlepass")
	end
end

function BattlepassViewController:Open()
	if v5 == "ShowRoom" then
		v7:Open("Battlepass", "Battlepass", true)
	end
end

function BattlepassViewController:Close()
	if v5 == "ShowRoom" then
		v7:Close()
	end

	if v6:IsOpen("Battlepass") then
		v6:Close("Battlepass")
	end
end

function BattlepassViewController:Start()
	v10 = require3(ReplicatedStorage2.Controllers.Battlepass.BattlepassTierController)
	self.BattlepassShowRoom = assert(v7:Get("Battlepass"), "Battlepass showroom not found")
	v11 = v2.Client:WaitReplion("Data")
	voter:GetPropertyChangedSignal("Enabled"):Connect(function()
		if voter.Enabled and battlepass.Enabled then
			voter.Enabled = false
		end
	end)
	background.Close.Activated:Connect(function()
		self:Close()
	end)
	background.Counter.Icon.Image = v9.SeasonData.Currency.Icon

	local function updateTopbar()
		local v12 = v11:Get("InfiniteBattlepass.Currency") or 0
		background.Counter.Amount.Text = v3.ValueConvertor:AddCommas(v12)
		local visible = v5 ~= "ShowRoom" or (background.Views.Battlepass.Visible or background.Views.SpinGacha.Visible or background.Views.Merchant.Visible or background.Views.MyTeam.Visible) and not background.Views.SpinGacha.Visible
		background.Counter.Visible = visible
		background.FreeGifts.Visible = visible
		local visible2 = v5 ~= "ShowRoom" or not background.Views.SpinGacha.Visible

		if v5 == "ShowRoom" then
			background.TopButtons.Visible = visible2
		end

		background.Close.Visible = visible2
	end

	local counter = background:FindFirstChild("Counter")

	if counter and counter:FindFirstChild("Add") then
		counter.Add.Activated:Connect(function()
			if v5 == "ShowRoom" then
				battlepassCurrencyShop.Enabled = true
			else
				v6:Open(battlepassCurrencyShop.Name, nil, true)
			end
		end)
	end

	v11:OnChange("InfiniteBattlepass.Currency", updateTopbar)

	if v5 == "ShowRoom" then
		background.Views.Battlepass:GetPropertyChangedSignal("Visible"):Connect(updateTopbar)
		background.Views.SpinGacha:GetPropertyChangedSignal("Visible"):Connect(updateTopbar)
		background.Views.Merchant:GetPropertyChangedSignal("Visible"):Connect(updateTopbar)
		background.Views.MyTeam:GetPropertyChangedSignal("Visible"):Connect(updateTopbar)
	end

	task.spawn(updateTopbar)
end

local v12 = {}
v6:OnOpen(function(instance)
	if not instance:GetAttribute("BattlepassCovered") then
		return
	end

	if v5 == "ShowRoom" then
		v8.IsUICovered:SetTag("Battlepass", true)
	end

	if pcall(function()
		v4(Enum.CoreGuiType.PlayerList, false)
		v4(Enum.CoreGuiType.Chat, false)
	end) then
		v12[instance] = true
		instance:GetPropertyChangedSignal("Enabled"):Once(function()
			v12[instance] = nil

			if not next(v12) then
				v4(Enum.CoreGuiType.PlayerList, true)
				v4(Enum.CoreGuiType.Chat, true)
			end
		end)
	end
end)
return BattlepassViewController