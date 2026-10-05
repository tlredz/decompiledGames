local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Tool)
local Network = require(ReplicatedStorage.Modules.Network)
local _2Difier = ReplicatedStorage.Assets.UI["2Difier"]
local _2DIfy = {}

function _2DIfy:Initialize()
	self.Gui = _2Difier:Clone()
	self.Frame = self.Gui:WaitForChild("Frame")
	self.ConfirmPage = self.Gui:WaitForChild("ConfirmPage")
	self.ResetButton = self.Frame:WaitForChild("Reset")
	self.TextBox = self.Frame:WaitForChild("Input")
	self.Images = self.Frame:WaitForChild("List")

	for _, frame in self.Images:GetChildren() do
		if not (frame:IsA("Frame") and frame:FindFirstChildOfClass("TextButton") and frame:FindFirstChild("Button")) then
			continue
		end

		local v = frame
		frame.Button.MouseButton1Click:Connect(function()
			self.ConfirmPage.ImageLabel.Image = `rbxthumb://type=Asset&id={v:GetAttribute("Id")}&w=420&h=420`
			self.ConfirmPage.Visible = true
			self.Frame.Visible = false
			local mouseButton1ClickConnection = nil
			local mouseButton1ClickConnection2 = nil
			mouseButton1ClickConnection = self.ConfirmPage.Confirm.MouseButton1Click:Once(function()
				self:FireEvent("SetImage", v:GetAttribute("Id"))
				self.ConfirmPage.Visible = false
				self.Frame.Visible = true
				mouseButton1ClickConnection:Disconnect()
				mouseButton1ClickConnection2:Disconnect()
			end)
			mouseButton1ClickConnection2 = self.ConfirmPage.Back.MouseButton1Click:Once(function()
				self.ConfirmPage.Visible = false
				self.Frame.Visible = true
				mouseButton1ClickConnection:Disconnect()
				mouseButton1ClickConnection2:Disconnect()
			end)
		end)
	end

	self.ResetButton.MouseButton1Click:Connect(function()
		self:FireEvent("SetImage")
	end)
	self.TextBox.FocusLost:Connect(function()
		local productInfo = nil
		local _, _ = pcall(function()
			productInfo = MarketplaceService:GetProductInfo(tonumber(self.TextBox.Text), Enum.InfoType.Asset)
		end)

		if productInfo and (productInfo.AssetTypeId == 1 or productInfo.AssetTypeId == 13) then
			self.ConfirmPage.ImageLabel.Image = `rbxthumb://type=Asset&id={self.TextBox.Text}&w=420&h=420`
			self.ConfirmPage.Visible = true
			self.Frame.Visible = false
			local mouseButton1ClickConnection = nil
			local mouseButton1ClickConnection2 = nil

			-- equivalent calls inferred from this helper; original call sites unknown
			local function disconnectBoth()
				mouseButton1ClickConnection:Disconnect()
				mouseButton1ClickConnection2:Disconnect()
			end

			mouseButton1ClickConnection = self.ConfirmPage.Confirm.MouseButton1Click:Once(function()
				self:FireEvent("SetImage", self.TextBox.Text)
				self.ConfirmPage.Visible = false
				self.Frame.Visible = true
				Network:fire("SendIDWebhook", self.TextBox.Text)
				disconnectBoth() -- equivalent call inferred; original call site unknown
			end)
			mouseButton1ClickConnection2 = self.ConfirmPage.Back.MouseButton1Click:Once(function()
				self.ConfirmPage.Visible = false
				self.Frame.Visible = true
				disconnectBoth() -- equivalent call inferred; original call site unknown
			end)
		end
	end)
	local connection = Network:listen("Tool/Event", function(p, p2, p3)
		if p ~= self.Tool then
			return
		end

		if p2 == "FetchImages" then
			self:UpdateImageList(p3)
		end
	end, true)
	local gui = self.Gui
	self.Tool.Destroying:Connect(function()
		gui:Destroy()
		connection:Disconnect()
	end)
end

function _2DIfy.Equipped(p)
	p.Gui.Parent = p.PlayerGui
end

function _2DIfy.Unequipped(player)
	if player.Character and player.Character:GetAttribute("PropMorphed") then
		return
	end

	player.Gui.Parent = player.Tool
end

function _2DIfy:UpdateImageList(p2)
	local v = 1

	for _, frame in self.Images:GetChildren() do
		if not (frame:IsA("Frame") and frame:FindFirstChildOfClass("TextButton") and frame:FindFirstChild("Button")) then
			continue
		end

		local v2 = p2[v]
		local child = self.Images:FindFirstChild((tostring(v)))

		if v2 then
			if child then
				child.Visible = true
				child:SetAttribute("Id", (tostring(v2)))
				local icon = child:FindFirstChild("Icon")

				if icon then
					icon.Image = `rbxthumb://type=Asset&id={v2}&w=420&h=420`
				end
			end

			v += 1
		elseif child then
			child.Visible = false
		end
	end
end

return _2DIfy