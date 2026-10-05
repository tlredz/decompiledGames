-- equivalent calls inferred from this helper; original call sites unknown
local function insertRight2(left, p)
	local right2 = left.Right2
	p.Right2 = right2
	p.Left2 = left
	left.Right2 = p
	right2.Left2 = p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unlink2(p)
	p.Left2.Right2 = p.Right2
	p.Right2.Left2 = p.Left2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unlink(p)
	unlink2(p) -- equivalent call inferred; original call site unknown
	p.Left1 = nil
	p.Right1 = nil
	p.Left2 = nil
	p.Right2 = nil
end

local function isRed(p)
	if p then
		return p.Color1
	end

	return false
end

local function rotateLeft(left)
	local right1 = left.Right1
	left.Right1 = right1.Left1
	right1.Left1 = left
	right1.Color1 = left.Color1
	left.Color1 = true
	return right1
end

local function rotateRight(right)
	local left1 = right.Left1
	right.Left1 = left1.Right1
	left1.Right1 = right
	left1.Color1 = right.Color1
	right.Color1 = true
	return left1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function flipColors(state)
	state.Color1 = not state.Color1
	local left1 = state.Left1
	left1.Color1 = not left1.Color1
	local right1 = state.Right1
	right1.Color1 = not right1.Color1
end

local function moveRedLeft(left)
	flipColors(left) -- equivalent call inferred; original call site unknown
	local left1 = left.Right1.Left1
	local color1

	if left1 then
		color1 = left1.Color1
	else
		color1 = false
	end

	local right1

	if color1 then
		local right12 = left.Right1
		local left12 = right12.Left1
		right12.Left1 = left12.Right1
		left12.Right1 = right12
		left12.Color1 = right12.Color1
		right12.Color1 = true
		left.Right1 = left12
		right1 = left.Right1
		left.Right1 = right1.Left1
		right1.Left1 = left
		right1.Color1 = left.Color1
		left.Color1 = true
		flipColors(right1) -- equivalent call inferred; original call site unknown
	else
		right1 = left
	end

	return right1
end

local function moveRedRight(right)
	flipColors(right) -- equivalent call inferred; original call site unknown
	local left1 = right.Left1.Left1
	local color1

	if left1 then
		color1 = left1.Color1
	else
		color1 = false
	end

	local left12

	if color1 then
		left12 = right.Left1
		right.Left1 = left12.Right1
		left12.Right1 = right
		left12.Color1 = right.Color1
		right.Color1 = true
		flipColors(left12) -- equivalent call inferred; original call site unknown
	else
		left12 = right
	end

	return left12
end

local function balance(left)
	local right1 = left.Right1
	local color1

	if right1 then
		color1 = right1.Color1
	else
		color1 = false
	end

	local right12

	if color1 then
		right12 = left.Right1
		left.Right1 = right12.Left1
		right12.Left1 = left
		right12.Color1 = left.Color1
		left.Color1 = true
	else
		right12 = left
	end

	local left1 = right12.Left1
	local color12

	if left1 then
		color12 = left1.Color1
	else
		color12 = false
	end

	local left12

	if color12 then
		local left13 = right12.Left1.Left1
		local v

		if left13 then
			v = left13.Color1
		else
			v = false
		end

		if v then
			left12 = right12.Left1
			right12.Left1 = left12.Right1
			left12.Right1 = right12
			left12.Color1 = right12.Color1
			right12.Color1 = true
		else
			left12 = right12
		end
	else
		left12 = right12
	end

	local left13 = left12.Left1
	local v

	if left13 then
		v = left13.Color1
	else
		v = false
	end

	if not v then
		return left12
	end

	local right13 = left12.Right1
	local v2

	if right13 then
		v2 = right13.Color1
	else
		v2 = false
	end

	if v2 then
		flipColors(left12) -- equivalent call inferred; original call site unknown
	end

	return left12
end

local removeMin

removeMin = function(left)
	if not left.Left1 then
		return nil, left
	end

	local left1 = left.Left1
	local color1

	if left1 then
		color1 = left1.Color1
	else
		color1 = false
	end

	local right1

	if color1 then
		right1 = left
	else
		local left12 = left.Left1.Left1
		local v

		if left12 then
			v = left12.Color1
		else
			v = false
		end

		if v then
			right1 = left
		else
			flipColors(left) -- equivalent call inferred; original call site unknown
			local left13 = left.Right1.Left1
			local v2

			if left13 then
				v2 = left13.Color1
			else
				v2 = false
			end

			if v2 then
				local right12 = left.Right1
				local left14 = right12.Left1
				right12.Left1 = left14.Right1
				left14.Right1 = right12
				left14.Color1 = right12.Color1
				right12.Color1 = true
				left.Right1 = left14
				right1 = left.Right1
				left.Right1 = right1.Left1
				right1.Left1 = left
				right1.Color1 = left.Color1
				left.Color1 = true
				flipColors(right1) -- equivalent call inferred; original call site unknown
			else
				right1 = left
			end
		end
	end

	local left2, v2 = removeMin(right1.Left1)
	right1.Left1 = left2
	return balance(right1), v2
end

local removeMax

removeMax = function(right)
	local left1 = right.Left1
	local color1

	if left1 then
		color1 = left1.Color1
	else
		color1 = false
	end

	local left12

	if color1 then
		left12 = right.Left1
		right.Left1 = left12.Right1
		left12.Right1 = right
		left12.Color1 = right.Color1
		right.Color1 = true
	else
		left12 = right
	end

	if not left12.Right1 then
		return nil, left12
	end

	local right1 = left12.Right1
	local color12

	if right1 then
		color12 = right1.Color1
	else
		color12 = false
	end

	local left13

	if color12 then
		left13 = left12
	else
		local left14 = left12.Right1.Left1
		local v

		if left14 then
			v = left14.Color1
		else
			v = false
		end

		if v then
			left13 = left12
		else
			flipColors(left12) -- equivalent call inferred; original call site unknown
			local left15 = left12.Left1.Left1
			local v2

			if left15 then
				v2 = left15.Color1
			else
				v2 = false
			end

			if v2 then
				left13 = left12.Left1
				left12.Left1 = left13.Right1
				left13.Right1 = left12
				left13.Color1 = left12.Color1
				left12.Color1 = true
				flipColors(left13) -- equivalent call inferred; original call site unknown
			else
				left13 = left12
			end
		end
	end

	local right2, v2 = removeMax(left13.Right1)
	left13.Right1 = right2
	return balance(left13), v2
end

local height

height = function(p)
	if p then
		return math.max(height(p.Left1), height(p.Right1)) + 1
	end

	return -1
end

local isBST

isBST = function(callback, data, p, p2)
	if not data then
		return true
	end

	if p ~= nil and callback(data.Key, p) <= 0 then
		return false
	end

	if p2 == nil or not (callback(data.Key, p2) >= 0) then
		return isBST(callback, data.Left1, p, data.Key) and isBST(callback, data.Right1, data.Key, p2)
	end

	return false
end

local remove

remove = function(callback, state, p)
	local v

	if not state then
		return state, v
	end

	local right1

	if callback(state.Key, p) > 0 then
		local left1 = state.Left1
		local v2

		if left1 then
			v2 = left1.Color1
		else
			v2 = false
		end

		if v2 then
			right1 = state
		else
			local left12 = state.Left1.Left1
			local v3

			if left12 then
				v3 = left12.Color1
			else
				v3 = false
			end

			if v3 then
				right1 = state
			else
				flipColors(state) -- equivalent call inferred; original call site unknown
				local left13 = state.Right1.Left1
				local v4

				if left13 then
					v4 = left13.Color1
				else
					v4 = false
				end

				if v4 then
					local right12 = state.Right1
					local left14 = right12.Left1
					right12.Left1 = left14.Right1
					left14.Right1 = right12
					left14.Color1 = right12.Color1
					right12.Color1 = true
					state.Right1 = left14
					right1 = state.Right1
					state.Right1 = right1.Left1
					right1.Left1 = state
					right1.Color1 = state.Color1
					state.Color1 = true
					flipColors(right1) -- equivalent call inferred; original call site unknown
				else
					right1 = state
				end
			end
		end

		local left
		left, v = remove(callback, right1.Left1, p)
		right1.Left1 = left
	else
		local left1 = state.Left1
		local color1

		if left1 then
			color1 = left1.Color1
		else
			color1 = false
		end

		local left12

		if color1 then
			left12 = state.Left1
			state.Left1 = left12.Right1
			left12.Right1 = state
			left12.Color1 = state.Color1
			state.Color1 = true
		else
			left12 = state
		end

		if callback(left12.Key, p) == 0 and not left12.Right1 then
			unlink(left12) -- equivalent call inferred; original call site unknown
			return nil, left12
		else
			if left12.Right1 then
				local right12 = left12.Right1
				local v2

				if right12 then
					v2 = right12.Color1
				else
					v2 = false
				end

				if v2 then
					right1 = left12
				else
					local left13 = left12.Right1.Left1
					local v3

					if left13 then
						v3 = left13.Color1
					else
						v3 = false
					end

					if v3 then
						right1 = left12
					else
						flipColors(left12) -- equivalent call inferred; original call site unknown
						local left14 = left12.Left1.Left1
						local v4

						if left14 then
							v4 = left14.Color1
						else
							v4 = false
						end

						if v4 then
							right1 = left12.Left1
							left12.Left1 = right1.Right1
							right1.Right1 = left12
							right1.Color1 = left12.Color1
							left12.Color1 = true
							flipColors(right1) -- equivalent call inferred; original call site unknown
						else
							right1 = left12
						end
					end
				end
			else
				right1 = left12
			end

			if callback(right1.Key, p) == 0 then
				local left13 = right1.Left1
				local right12 = right1.Right1
				local color12 = right1.Color1
				unlink(right1) -- equivalent call inferred; original call site unknown

				if left13 and right12 then
					local right, v3 = removeMin(right12)
					v3.Right1 = right
					v3.Left1 = left13
					v3.Color1 = color12
					v = right1
					right1 = v3
				else
					local v2 = left13 or right12
					v2.Color1 = color12
					v = right1
					right1 = v2
				end
			else
				local right
				right, v = remove(callback, right1.Right1, p)
				right1.Right1 = right
			end
		end
	end

	state = balance(right1)
	return state, v
end

local insert

insert = function(callback, state, left, p, p2)
	if state then
		local flag = false
		local v = callback(state.Key, p)
		local v2

		if v == 0 then
			state.Value = p2
			v2 = state
		else
			if v > 0 then
				local left2
				left2, v2, flag = insert(callback, state.Left1, state.Left2, p, p2)
				state.Left1 = left2
			else
				local right
				right, v2, flag = insert(callback, state.Right1, state, p, p2)
				state.Right1 = right
			end

			if flag then
				state = balance(state)
			end
		end

		return state, v2, flag
	else
		local v = {
			Color1 = true,
			Key = p,
			Value = p2,
			Left2 = nil,
			Right2 = nil
		}
		insertRight2(left, v) -- equivalent call inferred; original call site unknown
		return v, v, true
	end
end

local isBalanced

isBalanced = function(data, p: number)
	if not data then
		return p == 0
	end

	local v

	if data then
		v = data.Color1
	else
		v = false
	end

	if not v then
		p -= 1
	end

	return isBalanced(data.Left1, p) and isBalanced(data.Right1, p)
end

local size

size = function(p)
	local v = 0

	if p then
		return v + 1 + size(p.Left1) + size(p.Right1)
	end

	return v
end

local selectRank

selectRank = function(data, p: number)
	if not data then
		return nil
	end

	local left1 = data.Left1
	local v = 0

	if left1 then
		v = v + 1 + size(left1.Left1) + size(left1.Right1)
	end

	if p < v then
		return selectRank(data.Left1, p)
	end

	if v < p then
		return selectRank(data.Right1, p - v - 1)
	end

	return data.Key
end

local rank

rank = function(callback, p, data)
	if not data then
		return 0
	end

	local v = callback(data.Key, p)

	if v > 0 then
		return rank(callback, p, data.Left1)
	end

	if v < 0 then
		local left1 = data.Left1
		local v2 = 0

		if left1 then
			v2 = v2 + 1 + size(left1.Left1) + size(left1.Right1)
		end

		return v2 + 1 + rank(callback, p, data.Right1)
	else
		local left1 = data.Left1
		local v2 = 0

		if left1 then
			return v2 + 1 + size(left1.Left1) + size(left1.Right1)
		end

		return v2
	end
end

local is23

is23 = function(p, data)
	if not data then
		return true
	end

	local right1 = data.Right1
	local v

	if right1 then
		v = right1.Color1
	else
		v = false
	end

	if v then
		return false
	end

	if data == p then
		return is23(p, data.Left1) and is23(data.Right1)
	end

	local v2

	if data then
		v2 = data.Color1
	else
		v2 = false
	end

	if not v2 then
		return is23(p, data.Left1) and is23(data.Right1)
	end

	local left1 = data.Left1
	local v3

	if left1 then
		v3 = left1.Color1
	else
		v3 = false
	end

	if v3 then
		return false
	end

	return is23(p, data.Left1) and is23(data.Right1)
end

local v = {}
local frozen = table.freeze({
	__index = v
})

function v:Insert(p, p2)
	local root, v3, v4 = insert(self.Comparator, self.Root, self.List, p, p2)
	root.Color1 = false
	self.Root = root

	if v4 then
		self.Size += 1
	end

	return v3, v4
end

function v:Remove(p)
	local root = self.Root
	local v2

	if not root then
		return v2
	end

	local left1 = root.Left1
	local v3

	if left1 then
		v3 = left1.Color1
	else
		v3 = false
	end

	if not v3 then
		local right1 = root.Right1
		local v4

		if right1 then
			v4 = right1.Color1
		else
			v4 = false
		end

		if not v4 then
			root.Color1 = true
		end
	end

	local root2
	root2, v2 = remove(self.Comparator, root, p)

	if root2 then
		root2.Color1 = false
	end

	self.Root = root2

	if v2 then
		self.Size -= 1
	end

	return v2
end

function v:RemoveMin()
	local root = self.Root
	local v2

	if not root then
		return v2
	end

	local left1 = root.Left1
	local v3

	if left1 then
		v3 = left1.Color1
	else
		v3 = false
	end

	if not v3 then
		local right1 = root.Right1
		local v4

		if right1 then
			v4 = right1.Color1
		else
			v4 = false
		end

		if not v4 then
			root.Color1 = true
		end
	end

	local root2
	root2, v2 = removeMin(root)

	if root2 then
		root2.Color1 = false
	end

	self.Root = root2

	if v2 then
		self.Size -= 1
	end

	return v2
end

function v:RemoveMax()
	local root = self.Root
	local v2

	if not root then
		return v2
	end

	local left1 = root.Left1
	local v3

	if left1 then
		v3 = left1.Color1
	else
		v3 = false
	end

	if not v3 then
		local right1 = root.Right1
		local v4

		if right1 then
			v4 = right1.Color1
		else
			v4 = false
		end

		if not v4 then
			root.Color1 = true
		end
	end

	local root2
	root2, v2 = removeMax(root)

	if root2 then
		root2.Color1 = false
	end

	self.Root = root2

	if v2 then
		self.Size -= 1
	end

	return v2
end

function v.Min(p)
	local list = p.List
	local left1 = list.Left1

	if left1 == list then
		return nil
	end

	return left1
end

function v.Max(p)
	local list = p.List
	local right1 = list.Right1

	if right1 == list then
		return nil
	end

	return right1
end

function v.GetSize(p)
	return p.Size
end

function v:ForEach(callback)
	assert(type(callback) == "function")
	local list = self.List
	local right2 = list

	while true do
		right2 = right2.Right2

		if right2 == list then
			break
		end

		callback(right2.Key, right2.Value)
	end
end

function v.Next(p, list)
	local list2 = p.List

	if list == nil then
		list = p.List
	end

	local right2 = list.Right2

	if right2 == list2 then
		return nil, nil
	end

	return right2, right2
end

function v.Iterator(p)
	return p.Next, p
end

function v:IsBST()
	local comparator = self.Comparator
	local root = self.Root
	local v2

	if not root then
		v2 = true
		return true
	end

	v2 = isBST(comparator, root.Left1, nil, root.Key)
	return v2 and isBST(comparator, root.Right1, root.Key, nil)
end

function v:IsSizeConsistent()
	local size2 = self.Size
	local root = self.Root
	local v2 = 0

	if root then
		v2 = v2 + 1 + size(root.Left1) + size(root.Right1)
	end

	if size2 ~= v2 then
		return false
	end

	local list = self.List
	local right2 = list
	local count = 0

	while true do
		right2 = right2.Right2

		if right2 == list then
			break
		end

		count += 1
	end

	return size2 == count
end

function v:IsRankConsistent()
	for i = 0, self.Size - 1 do
		local root = self.Root
		local key

		if root then
			local left1 = root.Left1
			local v2 = 0

			if left1 then
				v2 = v2 + 1 + size(left1.Left1) + size(left1.Right1)
			end

			if i < v2 then
				key = selectRank(root.Left1, i)
			elseif v2 < i then
				key = selectRank(root.Right1, i - v2 - 1)
			else
				key = root.Key
			end
		end

		if i ~= rank(self.Comparator, key, self.Root) then
			return false
		end
	end

	self:ForEach(function(p, _)
		local v2 = rank(self.Comparator, p, self.Root)
		local root = self.Root
		local key

		if root then
			local left1 = root.Left1
			local v3 = 0

			if left1 then
				v3 = v3 + 1 + size(left1.Left1) + size(left1.Right1)
			end

			if v2 < v3 then
				key = selectRank(root.Left1, v2)
			elseif v3 < v2 then
				key = selectRank(root.Right1, v2 - v3 - 1)
			else
				key = root.Key
			end
		end

		if self.Comparator(key, p) == 0 then
			return
		else
			return false
		end
	end)
	return true
end

function v:Is23()
	return (is23(self.Root, self.Root))
end

function v:IsBalanced()
	local root = self.Root
	local left1 = root
	local v2 = 0

	while left1 do
		local v3

		if left1 then
			v3 = left1.Color1
		else
			v3 = false
		end

		if not v3 then
			v2 += 1
		end

		left1 = left1.Left1
	end

	local v3

	if not root then
		return v2 == 0
	end

	local v4

	if root then
		v4 = root.Color1
	else
		v4 = false
	end

	if not v4 then
		v2 -= 1
	end

	v3 = isBalanced(root.Left1, v2)
	return v3 and isBalanced(root.Right1, v2)
end

function v:Check()
	if not self:IsBST() then
		return false, "Not in symmetric order"
	end

	if not self:IsSizeConsistent() then
		return false, "Subtree counts not consistent"
	end

	if not self:IsRankConsistent() then
		return false, "Ranks not consistent"
	end

	if not self:Is23() then
		return false, "Not a 2-3 tree"
	end

	if self:IsBalanced() then
		return true
	end

	return false, "Not balanced"
end

table.freeze(v)
return table.freeze({
	Compare = function(p, p2)
		if p < p2 then
			return -1
		end

		if p2 < p then
			return 1
		end

		return 0
	end,
	new = function(comparator, _, _)
		assert(type(comparator) == "function")
		local v2 = {
			Color1 = false,
			Key = nil,
			Value = nil
		}
		v2.Left2 = v2
		v2.Right2 = v2
		return (setmetatable({
			Comparator = comparator,
			Root = nil,
			List = v2,
			Size = 0
		}, frozen))
	end
})