local createVector = vector.create
local ChatBubbleMover = {}
ChatBubbleMover.__index = ChatBubbleMover

function ChatBubbleMover.new(clientFighterCharacter)
	local self = setmetatable({}, ChatBubbleMover)
	self.ClientFighterCharacter = clientFighterCharacter
	self._chat_bubble_mover = Instance.new("Part")
	self._chat_bubble_mover_weld = nil
	self:_Init()
	return self
end

function ChatBubbleMover.Update(_, _, _) end

function ChatBubbleMover:Destroy()
	if self._chat_bubble_mover then
		self._chat_bubble_mover:Destroy()
	end
end

function ChatBubbleMover:_Update()
	if self._destroyed then
		return
	end

	local isMatchmaking = self.ClientFighterCharacter.ClientFighter:Get("IsMatchmaking")

	if isMatchmaking and self._chat_bubble_mover.Parent or not (isMatchmaking or self._chat_bubble_mover.Parent) then
		return
	end

	pcall(function()
		self._chat_bubble_mover.Parent = isMatchmaking and self.ClientFighterCharacter.RootPart or nil
	end)

	if isMatchmaking then
		if self._chat_bubble_mover_weld then
			self._chat_bubble_mover_weld:Destroy()
		end

		self._chat_bubble_mover.CFrame = self.ClientFighterCharacter.RootPart.CFrame + createVector(0, 5, 0)
		self._chat_bubble_mover_weld = Instance.new("WeldConstraint")
		self._chat_bubble_mover_weld.Part0 = self.ClientFighterCharacter.RootPart
		self._chat_bubble_mover_weld.Part1 = self._chat_bubble_mover
		self._chat_bubble_mover_weld.Parent = self._chat_bubble_mover
	end
end

function ChatBubbleMover:_SafeUpdate()
	task.defer(self._Update, self)
end

function ChatBubbleMover:_Setup()
	self._chat_bubble_mover.CanCollide = false
	self._chat_bubble_mover.CanTouch = false
	self._chat_bubble_mover.CanQuery = false
	self._chat_bubble_mover.Massless = true
	self._chat_bubble_mover.Transparency = 1
	self._chat_bubble_mover.Size = createVector(1, 1, 1)
end

function ChatBubbleMover:_Init()
	self.ClientFighterCharacter:AddConnection(self.ClientFighterCharacter.ClientFighter:GetDataChangedSignal("IsMatchmaking"):Connect(function()
		self:_SafeUpdate()
	end))
	self:_Setup()
	self:_SafeUpdate()
end

return ChatBubbleMover