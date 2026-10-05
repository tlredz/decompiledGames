game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local localPlayer = game.Players.LocalPlayer
local v = Component.new({
	Tag = "ZeusPuzzle_CodePanel"
})

function v:Construct()
	self.trove = Trove.new()
	self.Buttons = self.Instance.Parent.Buttons
	self.CodeLabel = self.Instance.Main.CodeLabel
	self.CanDigit = true
end

function v:Check()
	self.CanDigit = false

	if Net:RemoteFunction("ZeusPuzzle/GetDoorState"):InvokeServer() == false then
		if Net:RemoteFunction("ZeusPuzzle/CheckCode"):InvokeServer(self.CodeLabel.Text) then
			self.CodeLabel.TextColor3 = Color3.fromRGB(106, 213, 158)
			self.CodeLabel.Parent.Parent.Correct:Play()
		else
			self.CodeLabel.TextColor3 = Color3.fromRGB(176, 0, 62)
			self.CodeLabel.Parent.Parent.Error:Play()
		end
	end

	task.delay(1, function()
		self.CodeLabel.TextColor3 = Color3.fromRGB(27, 161, 176)
		self.CodeLabel.Text = ""
		self.CanDigit = true
	end)
end

function v:Start()
	local flag = false
	local v2 = {}

	local function CreateButton(instance)
		if v2[instance] then
			return
		end

		v2[instance] = true
		self.trove:Add(instance:WaitForChild("ClickDetector").MouseClick:Connect(function(p)
			if flag then
				return
			end

			flag = true
			task.delay(1, function()
				flag = false
			end)

			if not (self.CanDigit and p == localPlayer) then
				return
			end

			if string.len(self.CodeLabel.Text) < 8 then
				self.CodeLabel.Text = self.CodeLabel.Text .. instance.Name
				self.CodeLabel.Parent.Parent.Press:Play()

				if string.len(self.CodeLabel.Text) >= 8 then
					self:Check(self.CodeLabel.Text)
				end
			end
		end))
	end

	if self.Buttons then
		for _, child in self.Buttons:GetChildren() do
			task.spawn(CreateButton, child)
		end

		self.trove:Add(self.Buttons.ChildAdded:Connect(CreateButton))
	end
end

function v.Stop(p)
	p.trove:Destroy()
end

return v