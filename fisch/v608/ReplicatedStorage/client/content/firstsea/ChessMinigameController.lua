local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local _ = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local chess_piece = ReplicatedStorage.resources.sounds.sfx.chess_piece
local Net = require(packages.Net)
local Observers = require(packages.Observers)
require(packages.Promise)
local Shake = require(packages.Shake)
local Trove = require(packages.Trove)
local remoteEvent = Net:RemoteEvent("ChessMinigame/Interact")
local remoteEvent2 = Net:RemoteEvent("ChessMinigame/MovePiece")
local remoteEvent3 = Net:RemoteEvent("ChessMinigame/OpenGate")
local remoteEvent4 = Net:RemoteEvent("ChessMinigame/ResetPieces")
local remoteEvent5 = Net:RemoteEvent("ChessMinigame/StartTimer")
local v = {
	"Blue",
	"Yellow",
	"Purple",
	"Red"
}
local color = Color3.fromRGB(113, 255, 106)
local ChessMinigameController = {
	timerTrove = Trove.new(),
	gateOpened = false,
	lastTime = 0,
	pieceData = {}
}

function pivotTween(instance, p, cframe: CFrame, flag: boolean?)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = instance:GetPivot()
	local tween = TweenService:Create(cFrameValue, p, {
		Value = cframe
	})
	tween:Play()
	cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
		if not flag then
			instance:PivotTo(cFrameValue.Value)
		end
	end)
	tween.Completed:Connect(function()
		cFrameValue:Destroy()
		tween:Destroy()
	end)
	tween.Destroying:Connect(function()
		cFrameValue:Destroy()
	end)
	return tween, cFrameValue
end

function fastTween(p, p2, p3, _: boolean?)
	local tween = TweenService:Create(p, p2, p3)
	tween:Play()
	tween.Completed:Connect(function()
		tween:Destroy()
	end)
	return tween
end

function applySound(parent, childName: string)
	local child = chess_piece:FindFirstChild(childName)

	if not child then
		return
	end

	local clone = child:Clone()
	clone.Parent = parent
	Debris:AddItem(clone, 2)
	return clone
end

function ChessMinigameController:ResetPieces(p)
	for i = 1, 4 do
		local v2 = self.pieceData[i]

		if not v2 then
			continue
		end

		v2.position = 1
		v2.trove:Clean()
		self.timerTrove:Clean()
		local piece = v2 and v2.piece
		local pieceModel = v2 and v2.pieceModel

		if piece and pieceModel then
			local proximityPrompt = pieceModel:FindFirstChildWhichIsA("ProximityPrompt")

			if proximityPrompt then
				proximityPrompt.Enabled = false
			end

			local originalPosition = pieceModel:GetAttribute("OriginalPosition") or pieceModel:GetPivot()
			math.max((pieceModel:GetPivot().Position - originalPosition.Position).Magnitude / 14, 1)
			local v3 = pivotTween(pieceModel, TweenInfo.new(2, Enum.EasingStyle.Sine), originalPosition)

			if v3 then
				local v4 = proximityPrompt
				v3.Completed:Connect(function()
					if v4 and not self.gateOpened then
						v4.Enabled = true
					end
				end)
				v2.trove:Add(v3)
			end
		end

		if p then
			if not v2.lastIsCorrect then
				self:ApplyEffect(i, true, true)
			end
		else
			self:ApplyEffect(i, false, true)
		end
	end
end

function ChessMinigameController:MovePiece(p, position, p2)
	local v2 = self.pieceData[p]
	local pieceModel = v2 and v2.pieceModel

	if not pieceModel then
		return
	end

	local proximityPrompt = pieceModel:FindFirstChildWhichIsA("ProximityPrompt")

	if proximityPrompt then
		proximityPrompt.Enabled = false
	end

	v2.trove:Clean()
	local position2 = v2.position
	v2.position = position
	local originalPosition = pieceModel:GetAttribute("OriginalPosition") or pieceModel:GetPivot()
	local v3 = (position - 1) * 3
	local v4, v5 = pivotTween(
		pieceModel,
		TweenInfo.new(0.5, Enum.EasingStyle.Linear),
		originalPosition * CFrame.new(v3, 0, 0),
		true
	)
	local v6 = nil
	local v7 = nil
	local v8 = Shake.new()
	v8.Amplitude = 0.05
	v8.Frequency = 0.3
	v8.FadeInTime = 0.1
	v8.FadeOutTime = 0.75
	v8:Start()
	v8:BindToRenderStep(Shake.NextRenderName(), Enum.RenderPriority.Last.Value + 1, function(p3, p4)
		v6 = p3
		v7 = p4
	end)

	if v5 then
		v5:GetPropertyChangedSignal("Value"):Connect(function()
			if v6 and v7 then
				pieceModel:PivotTo(v5.Value * CFrame.new(v6) * CFrame.Angles(v7.X, v7.Y, v7.Z))
			else
				pieceModel:PivotTo(v5.Value)
			end
		end)
	end

	if v2.lastIsCorrect and not p2 then
		self:ApplyEffect(p, p2)
	end

	v4.Completed:Connect(function()
		if v8 then
			v8:Destroy()
		end

		self:ApplyEffect(p, p2)

		if proximityPrompt and not self.gateOpened then
			proximityPrompt.Enabled = true
		end
	end)
	v2.trove:Add(v4)
	local v9 = position - position2

	if pieceModel.PrimaryPart and v9 ~= 0 then
		local v10 = v9 > 0 and "moving" or "moving2"
		local v11 = applySound(pieceModel.PrimaryPart, v10)

		if not v11 then
			return
		end

		v11.TimePosition = 0.1
		v11.Volume = 0
		v11:Play()
		fastTween(v11, TweenInfo.new(0.25), {
			Volume = 0.5
		})
		task.delay(0.25, function()
			if not v11.Parent then
				return
			end

			fastTween(v11, TweenInfo.new(0.5), {
				Volume = 0
			})
		end)
	end
end

function ChessMinigameController:ApplyEffect(p2, p3, p4)
	local v2 = self.pieceData[p2]

	if not v2 then
		return
	end

	if (v2.lastIsCorrect or p4) and not p3 then
		v2.lastIsCorrect = false
		v2.effectTrove:Clean()
	elseif (not v2.lastIsCorrect or p4) and p3 then
		v2.lastIsCorrect = true
		v2.effectTrove:Clean()
		local piece = v2.piece
		local pieceModel = v2.pieceModel
		local colorPart = pieceModel and pieceModel:FindFirstChild("ColorPart")
		local originalColor = pieceModel and pieceModel:GetAttribute("OriginalColor")

		if piece and pieceModel then
			local chessSlot = piece:FindFirstChild("ChessSlot")

			if chessSlot then
				local part = Instance.new("Part")
				part.Color = color
				part.Size = Vector3.new(chessSlot.Size.X - 0.5, chessSlot.Size.Y - 0.6, 0)
				part.CFrame = chessSlot.CFrame * CFrame.new(0, 0, (chessSlot.Size.Z - 0.75) / 2)
				part.Material = Enum.Material.Neon
				part.Anchored = true
				part.Parent = piece
				local v3 = chessSlot.Size.Z - 0.75
				fastTween(part, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					Size = part.Size + Vector3.new(0, 0, v3),
					Position = part.CFrame:PointToWorldSpace(-Vector3.new(0, 0, v3) / 2)
				})

				if colorPart and originalColor then
					local v4 = fastTween(colorPart, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						Color = color
					})
					v2.effectTrove:Add(v4)
				end

				v2.effectTrove:Add(function()
					fastTween(part, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
						Transparency = 1
					})

					if colorPart and originalColor then
						fastTween(colorPart, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							Color = originalColor
						})
					end

					Debris:AddItem(part, 1)
				end)
			end

			local v3 = pieceModel.PrimaryPart and applySound(pieceModel.PrimaryPart, "right-position")

			if not v3 then
				return
			end

			v3.TimePosition = 0.1
			v3:Play()
		end
	end
end

function ChessMinigameController:OpenGate()
	self.timerTrove:Clean()
	self.gateOpened = true
	self.lastTime = 0

	for _, v2 in self.pieceData do
		local pieceModel = v2.pieceModel

		if not pieceModel then
			continue
		end

		pieceModel:GetPivot()
		local proximityPrompt = pieceModel:FindFirstChildWhichIsA("ProximityPrompt")

		if proximityPrompt then
			proximityPrompt.Enabled = false
		end
	end

	self:ResetPieces(true)
end

function ChessMinigameController:SetUpTimer(instance)
	local surfaceGui = instance and instance:FindFirstChild("SurfaceGui")

	if self.lastTime <= workspace:GetServerTimeNow() or not surfaceGui then
		return
	end

	self.timerTrove:Clean()
	surfaceGui.CanvasGroup.TextLabel.Text = ""
	surfaceGui.CanvasGroup.GroupTransparency = 1
	local v2 = fastTween(surfaceGui.CanvasGroup, TweenInfo.new(1, Enum.EasingStyle.Sine), {
		GroupTransparency = 0
	})
	self.timerTrove:Add(v2)
	self.timerTrove:Add(function()
		if surfaceGui and surfaceGui.Parent then
			fastTween(surfaceGui.CanvasGroup, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				GroupTransparency = 1
			})
		end
	end)
	local lastTime = self.lastTime
	local total = 0
	self.timerTrove:Connect(RunService.RenderStepped, function(p)
		total += p

		if total < 0.5 then
			return
		end

		total = 0
		local v3 = math.floor(lastTime - workspace:GetServerTimeNow())

		if v3 > 0 then
			surfaceGui.CanvasGroup.TextLabel.Text = self.ConvertSeconds(v3)
		else
			self.timerTrove:Clean()
		end
	end)
end

function ChessMinigameController:SetUpPieceData(instance)
	local pieces = instance and instance:FindFirstChild("Pieces")

	for i = 1, 4 do
		local v2 = self.pieceData[i]

		if not v2 then
			self.pieceData[i] = {
				trove = Trove.new(),
				effectTrove = Trove.new(),
				position = 1
			}
			v2 = self.pieceData[i]

			if not v2 then
				continue
			end
		end

		local child = pieces and pieces:FindFirstChild(v[i])
		local piece = child and child:FindFirstChild("Piece")

		if not piece then
			continue
		end

		v2.piece = child
		v2.pieceModel = piece
		local proximityPrompt = piece:FindFirstChildWhichIsA("ProximityPrompt")

		if proximityPrompt then
			if v2.triggeredConnection then
				v2.triggeredConnection:Disconnect()
			end

			local v3 = i
			v2.triggeredConnection = proximityPrompt.Triggered:Connect(function(player)
				remoteEvent:FireServer(v3)
			end)
			local _ = {
				prompt = proximityPrompt,
				cframe = piece:GetPivot()
			}
		end

		if v2.lastIsCorrect then
			self:ApplyEffect(i, true, true)
		end

		self:MovePiece(i, v2.position, v2.lastIsCorrect)
	end

	local timer = instance and instance:FindFirstChild("Timer")

	if timer then
		self:SetUpTimer(timer)
	end
end

function ChessMinigameController.ConvertSeconds(value)
	if typeof(value) ~= "number" then
		return
	end

	local v2 = math.floor(value % 3600 / 60)
	local v3 = value % 60
	return string.format("%02i:%02i", v2, v3)
end

function ChessMinigameController:Start()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:WaitForChild("HumanoidRootPart")
	localPlayer.CharacterAdded:Connect(function()
		humanoidRootPart = character and character:WaitForChild("HumanoidRootPart")
	end)
	remoteEvent4.OnClientEvent:Connect(function(_: number, _: number, _: boolean)
		self:ResetPieces()
	end)
	remoteEvent2.OnClientEvent:Connect(function(p: number, p2: number, flag: boolean)
		self:MovePiece(p, p2, flag)
	end)
	remoteEvent3.OnClientEvent:Connect(function()
		self:OpenGate()
	end)
	remoteEvent5.OnClientEvent:Connect(function(lastTime: number)
		if not lastTime then
			return
		end

		self.lastTime = lastTime
		local tagged = CollectionService:GetTagged("ChessMinigameBoard")

		if not tagged or #tagged <= 0 then
			return
		end

		local parent = tagged[1] and tagged[1].Parent

		if not parent:IsA("Model") then
			return
		end

		local timer = parent:FindFirstChild("Timer")

		if timer then
			self:SetUpTimer(timer)
		end
	end)
	Observers.observeTag("ChessMinigameBoard", function(p)
		local parent = p.Parent

		if not parent:IsA("Model") then
			return
		end

		self:SetUpPieceData(parent)
		return function()
			self.timerTrove:Clean()
		end
	end)
	self:SetUpPieceData()
	self:ResetPieces()
end

return ChessMinigameController