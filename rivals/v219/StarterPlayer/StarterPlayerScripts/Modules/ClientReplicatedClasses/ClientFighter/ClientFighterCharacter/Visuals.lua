local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local blindedGui = Players.LocalPlayer.PlayerScripts.UserInterface.BlindedGui
local Visuals = {}
Visuals.__index = Visuals

function Visuals.new(clientFighterCharacter)
	local self = setmetatable({}, Visuals)
	self.ClientFighterCharacter = clientFighterCharacter
	self._destroyed = false
	self._red_figure_highlight = nil
	self:_Init()
	return self
end

function Visuals:SetRedFigureMode(p, p2)
	if p and not self._red_figure_highlight then
		self._red_figure_highlight = Instance.new("Highlight")
		self._red_figure_highlight.FillColor = Color3.fromRGB(255, 0, 0)
		self._red_figure_highlight.FillTransparency = 0.25
		self._red_figure_highlight.OutlineColor = Color3.fromRGB(255, 112, 112)
		self._red_figure_highlight.OutlineTransparency = 0
		local _red_figure_highlight = self._red_figure_highlight
		local depthMode

		if p2 then
			depthMode = Enum.HighlightDepthMode.AlwaysOnTop
		else
			depthMode = Enum.HighlightDepthMode.Occluded
		end

		_red_figure_highlight.DepthMode = depthMode
		self._red_figure_highlight.Adornee = self.ClientFighterCharacter.Model
		self._red_figure_highlight.Parent = self.ClientFighterCharacter.Model
	elseif not p and self._red_figure_highlight then
		self._red_figure_highlight:Destroy()
		self._red_figure_highlight = nil
	end
end

function Visuals:BlindedEffect(p2)
	local lastTime = tick()
	local clone = blindedGui:Clone()
	clone.Parent = self.ClientFighterCharacter.Model:FindFirstChild("Head") or self.ClientFighterCharacter.RootPart
	BetterDebris:AddItem(clone, p2)
	local imageLabel = clone.ImageLabel

	while not self._destroyed and tick() < lastTime + p2 do
		imageLabel.ImageTransparency = math.min(1, (tick() - lastTime) / p2) ^ 5
		RunService.RenderStepped:Wait()
	end

	clone:Destroy()
end

function Visuals.HurtEffect(p, ...)
	local v = (...)[utf8.char(0)] / p.ClientFighterCharacter.Humanoid.MaxHealth

	if p.ClientFighterCharacter.ClientFighter.FighterInterface then
		task.spawn(
			p.ClientFighterCharacter.ClientFighter.FighterInterface.HurtEffect,
			p.ClientFighterCharacter.ClientFighter.FighterInterface,
			...
		)
	end

	for k in pairs(p.ClientFighterCharacter.ClientFighter:GetEquippedItems()) do
		k.ViewModel:ApplyRecoil(Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 1.5 * v)
	end

	if p.ClientFighterCharacter.ClientFighter:Get("IsSpectating") then
		CameraController:ShakeOnce(60 * v, 10, 0, 0.4, createVector(0.25, 0.25, 0), createVector(0, 0, 0))
	end
end

function Visuals.Update(_, _, _) end

function Visuals:Destroy()
	self._destroyed = true
end

function Visuals:_Init()
	self.ClientFighterCharacter.HealthChanged:Connect(function()
		self:SetRedFigureMode(false)
	end)
end

return Visuals