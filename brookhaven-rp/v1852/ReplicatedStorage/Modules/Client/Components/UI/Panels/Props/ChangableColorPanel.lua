local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = nil
local v2 = Component.new({
	Tag = "ChangableColorPanel"
})
local text = nil
local v4 = nil
local v5 = nil

function v2.SetCallbacks(_, p: string, callback, callback2)
	text = p
	v4 = callback
	v5 = callback2
end

function v2:Construct()
	self._Janitor = Janitor.new()
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v = PanelController
end

function v2:Start()
	local textBox = self.Instance:WaitForChild("A"):WaitForChild("B"):WaitForChild("C"):WaitForChild("TextBox")
	local frame = self.Instance:WaitForChild("A"):WaitForChild("B"):WaitForChild("C"):WaitForChild("Frame")
	self._Janitor:Add(textBox.FocusLost:Connect(function()
		v4(textBox.Text)
	end))

	for _, button in frame:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v6 = button
		self._Janitor:Add(button.Activated:Connect(function()
			v5(v6:WaitForChild("Color").Value)
		end))
	end

	local v6 = v.WaitForPanel("MainGUIHandler", "ChangableColorPanel")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fn(_)
		if v4 and v5 then
			textBox.Text = text
		else
			v6:Close()
		end
	end

	v6:RegisterListener(self, v6.Events.Opening, fn)

	if v6:IsOpen() then
		fn() -- equivalent call inferred; original call site unknown
	end

	v6:RegisterListener(self, v6.Events.Closing, function(_)
		textBox.Text = ""
	end)
end

function v2:Stop()
	self._Janitor:Destroy()
end

return v2