local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Signal)
local v2 = require3(ReplicatedStorage2.ClientGameModules.CoreCall)
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(ReplicatedStorage2.Controllers.UI.UIStateController)
local newWelcomeBack = Players.LocalPlayer.PlayerGui:WaitForChild("NewWelcomeBack")
local View = {
	_views = {},
	_selectedView = "NONE",
	CreateView = function(p, p2: string, frame)
		local v5 = {
			_frame = frame,
			_openSignal = v.new(),
			_closeSignal = v.new()
		}
		frame.Visible = false
		p._views[p2] = v5
		return v5
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

function _popView(p, _: string?, _: string?)
	p._closeSignal:Fire(true)
	p._frame.Visible = false
end

function _pushView(p)
	p._openSignal:Fire(true)
	p._frame.Visible = true
end

function _renderToView(selectedView: string, p: string?)
	local view = View._selectedView ~= "NONE" and View:GetView(View._selectedView)

	if view then
		_popView(view, View._selectedView, p)
	end

	View._selectedView = selectedView
	local view2 = View:GetView(selectedView)

	if view2 then
		_pushView(view2)
	end
end

function View:OpenView(lastView: string)
	_renderToView(lastView, self.LastView)
	self.LastView = lastView
end

function View.CloseView(object, p: string)
	local view = object:GetView(p)

	if not view then
		return
	end

	_popView(view)
end

function View:Open()
	v3:Open("NewWelcomeBack", true)
end

function View:Close()
	v3:Close("NewWelcomeBack", true)
end

function View:Start()
	newWelcomeBack.Frame.TopFrame.Close.MouseButton1Click:Connect(function()
		self:Close()
	end)
	v3:OnGuiOpen("WelcomeBack", function()
		v4.IsUICovered:SetTag("WelcomeBack", true)
		pcall(function()
			v2(Enum.CoreGuiType.PlayerList, false)
			v2(Enum.CoreGuiType.Chat, false)
		end)
	end)
	v3:OnGuiClose("WelcomeBack", function()
		v4.IsUICovered:SetTag("WelcomeBack", false)
		pcall(function()
			v2(Enum.CoreGuiType.PlayerList, true)
			v2(Enum.CoreGuiType.Chat, true)
		end)
	end)
end

return View