local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local GenerationService = game:GetService("GenerationService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.Packages.Replion)
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Observers)
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(ReplicatedStorage2.Controllers.ShowRoomController)
local v5 = require3(ReplicatedStorage2.Controllers.NotificationController)
local v6 = require3(ReplicatedStorage2.ServerInfo)
require3(ReplicatedStorage2.Controllers.UI.HUDController)
local remoteFunction = v:RemoteFunction("SwordForge/Request")
v:RemoteEvent("SwordForge/UpdateStatus")
local isStudio = RunService:IsStudio()
local localPlayer = Players.LocalPlayer
local swordForge = localPlayer.PlayerGui.SwordForge
local frame = swordForge.Frame
local textBox = frame.Input.Textbox.Textbox.TextBox
local placeholderText = textBox.PlaceholderText
local v7 = nil
local SwordForgeController = {}

function SwordForgeController:_resetUI()
	frame.Header.Title.Text = "Describe the sword you want to forge"
	textBox.PlaceholderText = placeholderText
	textBox.Active = true
	frame.Input.Visible = true
	frame.BTools.Visible = false
	frame.LowerButtons.Visible = false
	frame.CloseButton.Visible = true
	swordForge:SetAttribute("Forging", nil)
end

function SwordForgeController:CreateMesh(p)
	if p == "STUDIO" then
		return script.Test:Clone()
	end

	local success, result = pcall(function()
		return GenerationService:LoadGeneratedMeshAsync(p)
	end)

	if success and result then
		return result
	end

	warn(`Failed to load generated MeshId for {p}`, result)
	return nil
end

function SwordForgeController:LoadSword(p)
	local mesh = self:CreateMesh(p)

	if not mesh then
		v5:SendNotification("Failed to forge sword!")
		return
	end

	mesh.Name = "GeneratedMesh"
	mesh.Anchored = true
	mesh.CanCollide = false
	mesh.CanQuery = false
	mesh.CanTouch = false
	mesh.Parent = workspace
	mesh:PivotTo(workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -5))
	assert(v4:Get("SwordForge"), "SwordForge showroom not found").Info.Render("Sword", {
		Name = "GeneratedMesh",
		Mesh = mesh
	})
	frame.Header.Title.Text = "Adjust the grip of your sword"
	frame.LowerButtons.Visible = true
	frame.BTools.Visible = true
	frame.CloseButton.Visible = false
	frame.Input.Visible = false
end

function SwordForgeController:Open()
	_G.SWORD_FORGE_SAVE = nil

	if v4.UI == "SwordForge" then
		return
	end

	local v8 = assert(v4:Get("SwordForge"), "SwordForge showroom not found")
	v4:Open("SwordForge", "SwordForge", true, true)
	v8.Info.Render("Sword", {
		Name = "Nothing"
	})
end

function SwordForgeController:Close()
	_G.SWORD_FORGE_SAVE = nil

	if v4.UI == "SwordForge" then
		assert(v4:Get("SwordForge"), "SwordForge showroom not found").Info.Render("Sword", {
			Name = "Nothing"
		})
		v4:Close()
	end
end

function SwordForgeController:Start()
	frame.BTools.Visible = false
	frame.LowerButtons.Visible = false
	frame.CloseButton.Activated:Connect(function()
		self:Close()
	end)

	if not v6.isTestGame() then
		return
	end

	v3:OnGuiOpen(swordForge.Name, function()
		self:Open()
	end)
	frame.Input.Forge.Activated:Connect(function()
		if v7 then
			v5:SendNotification("Your sword is already being forged, check back in a few seconds!")
			return
		end

		local text = textBox.Text
		textBox.Text = ""
		textBox.PlaceholderText = "Forging..."
		swordForge:SetAttribute("Forging", true)
		textBox.Active = false
		frame.Input.Visible = false
		frame.Header.Title.Text = "Check back soon for your finished sword!"
		local v8, v9

		if isStudio then
			task.wait(3)
			v8 = true
			v9 = "STUDIO"
		else
			v8, v9 = remoteFunction:InvokeServer(text)
		end

		print("Forge success:", v8, v9)

		if v8 then
			v5:SendNotification("Your sword has been forged!")
		else
			v5:SendNotification(v9 == "Moderation failed" and "Your sword did not pass moderation. Please try again." or "Failed to forge sword!")
		end

		if not (v8 and v9) then
			self:_resetUI()
			return
		end

		v7 = v9
		self:LoadSword(v9)
		v7 = nil
	end)
	local v8 = assert(v4:Get("SwordForge"), "SwordForge showroom not found")
	frame.LowerButtons.Confirm.Activated:Connect(function()
		_G.SWORD_FORGE_SAVE = true
		v8.Info.Render("Sword", {
			Name = "Nothing"
		})
		self:Close()
		self:_resetUI()
	end)
	frame.LowerButtons.Clear.Activated:Connect(function()
		v8.Info.Render("Sword", {
			Name = "Nothing"
		})
		self:_resetUI()
	end)
	v2.observeTagNoAncestry("SwordForgeNPC", function(instance)
		local now = 0

		local function onTouch(p)
			local windowName = instance:GetAttribute("WindowName")
			local playerFromCharacter = Players:GetPlayerFromCharacter(p.Parent)

			if playerFromCharacter and playerFromCharacter == localPlayer and not v3._currentGui and not v3._lockId and tick() - now > 1 and not v3:IsOpen(windowName) then
				self:Open()
			end
		end

		v3:OnGuiClose(swordForge.Name, function()
			now = tick()
		end)
		local touchedConnection = nil
		task.spawn(function()
			local hitbox = instance:WaitForChild("Hitbox", 60)

			if not hitbox then
				return
			end

			touchedConnection = hitbox.Touched:Connect(onTouch)
		end)
		return function()
			if touchedConnection then
				touchedConnection:Disconnect()
				touchedConnection = nil
			end
		end
	end)
end

return SwordForgeController