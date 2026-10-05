local __JECS_HI_COMPONENT_ID = _G.__JECS_HI_COMPONENT_ID or 256
local onAdd = __JECS_HI_COMPONENT_ID + 1
local onRemove = __JECS_HI_COMPONENT_ID + 2
local onSet = __JECS_HI_COMPONENT_ID + 3
local wildcard = __JECS_HI_COMPONENT_ID + 4
local childOf = __JECS_HI_COMPONENT_ID + 5
local component = __JECS_HI_COMPONENT_ID + 6
local onDelete = __JECS_HI_COMPONENT_ID + 7
local onDeleteTarget = __JECS_HI_COMPONENT_ID + 8
local delete = __JECS_HI_COMPONENT_ID + 9
local remove2 = __JECS_HI_COMPONENT_ID + 10
local name = __JECS_HI_COMPONENT_ID + 11
local rest = __JECS_HI_COMPONENT_ID + 12
local frozen = table.freeze({})

local function FLAGS_ADD(flag: boolean)
	local v13 = 0

	if flag then
		return (bit32.bor(v13, 8))
	end

	return v13
end

local function ECS_COMBINE(p: number, p2: number)
	return p * 268435456 + p2 * 16
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function ECS_IS_PAIR(p: number)
	return p > 16777216 and p % 16 // 8 ~= 0
end

local function ECS_GENERATION(p: number)
	if p > 16777216 then
		return p // 16 % 65536
	end

	return 0
end

local function ECS_GENERATION_INC(p: number)
	if not (p > 16777216) then
		return p * 268435456 + 16
	end

	local v13 = p // 16
	local v14 = v13 // 16777216
	local v15 = v13 % 65536 + 1

	if v15 > 65536 then
		return v14
	end

	return v14 * 268435456 + v15 * 16
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function ECS_ENTITY_T_HI(p: number)
	if p > 16777216 then
		return p // 16 % 16777216
	end

	return p
end

local function ECS_ENTITY_T_LO(p: number)
	if p > 16777216 then
		return p // 16 // 16777216
	end

	return p
end

local function _STRIP_GENERATION(p: number)
	if p > 16777216 then
		return p // 16 // 16777216
	end

	return p
end

local function ECS_PAIR(p: number, p2: number)
	if p2 > 16777216 then
		p2 = p2 // 16 // 16777216
	end

	if p > 16777216 then
		p = p // 16 // 16777216
	end

	return p2 * 268435456 + p * 16 + bit32.bor(0, 8)
end

local function entity_index_try_get_any(p, p2: number)
	local sparse_array = p.sparse_array

	if p2 > 16777216 then
		p2 = p2 // 16 // 16777216
	end

	local v13 = sparse_array[p2]

	if not v13 then
		return nil
	end

	if v13 and v13.dense ~= 0 then
		return v13
	end

	return nil
end

local function entity_index_try_get(data, p: number)
	local sparse_array = data.sparse_array
	local v13

	if p > 16777216 then
		v13 = p // 16 // 16777216
	else
		v13 = p
	end

	local v14 = sparse_array[v13]

	if v14 then
		if not v14 or v14.dense == 0 then
			v14 = nil
		end
	else
		v14 = nil
	end

	if not v14 then
		return v14
	end

	local dense = v14.dense

	if data.alive_count < dense or data.dense_array[dense] ~= p then
		return nil
	end

	return v14
end

local function entity_index_get_alive(p, p2: number)
	local sparse_array = p.sparse_array

	if p2 > 16777216 then
		p2 = p2 // 16 // 16777216
	end

	local v13 = sparse_array[p2]

	if v13 then
		if not v13 or v13.dense == 0 then
			v13 = nil
		end
	else
		v13 = nil
	end

	if v13 then
		return p.dense_array[v13.dense]
	end

	return 0
end

local function entity_index_is_alive(data, p: number)
	local sparse_array = data.sparse_array
	local v13

	if p > 16777216 then
		v13 = p // 16 // 16777216
	else
		v13 = p
	end

	local v14 = sparse_array[v13]

	if v14 then
		if not v14 or v14.dense == 0 then
			v14 = nil
		end
	else
		v14 = nil
	end

	if not v14 then
		return v14 ~= nil
	end

	local dense = v14.dense

	if data.alive_count < dense then
		v14 = nil
	elseif data.dense_array[dense] ~= p then
		v14 = nil
	end

	return v14 ~= nil
end

local function entity_index_new_id(state, _)
	local dense_array = state.dense_array
	local alive_count = state.alive_count

	if alive_count == #dense_array then
		local max_id = state.max_id + 1
		state.max_id = max_id
		local v14 = alive_count + 1
		state.alive_count = v14
		dense_array[v14] = max_id
		state.sparse_array[max_id] = {
			dense = v14
		}
		return max_id
	else
		local alive_count2 = alive_count + 1
		state.alive_count = alive_count2
		return dense_array[alive_count2]
	end
end

local function ecs_pair_first(p, p2)
	local entity_index = p.entity_index

	if p2 > 16777216 then
		p2 = p2 // 16 % 16777216
	end

	local sparse_array = entity_index.sparse_array

	if p2 > 16777216 then
		p2 = p2 // 16 // 16777216
	end

	local v13 = sparse_array[p2]

	if v13 then
		if not v13 or v13.dense == 0 then
			v13 = nil
		end
	else
		v13 = nil
	end

	if v13 then
		return entity_index.dense_array[v13.dense]
	end

	return 0
end

local function ecs_pair_second(p, p2)
	local entity_index = p.entity_index

	if p2 > 16777216 then
		p2 = p2 // 16 // 16777216
	end

	local sparse_array = entity_index.sparse_array

	if p2 > 16777216 then
		p2 = p2 // 16 // 16777216
	end

	local v13 = sparse_array[p2]

	if v13 then
		if not v13 or v13.dense == 0 then
			v13 = nil
		end
	else
		v13 = nil
	end

	if v13 then
		return entity_index.dense_array[v13.dense]
	end

	return 0
end

local function archetype_move(p, archetype, row: number, archetype2, row2: number)
	local columns = archetype2.columns
	local columns2 = archetype.columns
	local entities = archetype.entities
	local entities2 = archetype2.entities
	local count = #entities2
	local types = archetype2.types
	local records = archetype.records

	for k, column in columns do
		if column == frozen then
			continue
		end

		local record = records[types[k]]

		if record then
			columns2[record.column][row] = column[row2]
		end

		if row2 ~= count then
			column[row2] = column[count]
		end

		column[count] = nil
	end

	local count2 = #entities2
	local entity = entities2[row2]
	local entity2 = entities2[count2]

	if row2 ~= count2 then
		entities2[row2] = entity2
	end

	entities2[count2] = nil
	entities[row] = entity
	local sparse_array = p.sparse_array

	if entity > 16777216 then
		entity = entity // 16 // 16777216
	end

	local v13 = sparse_array[entity]

	if entity2 > 16777216 then
		entity2 = entity2 // 16 // 16777216
	end

	local v14 = sparse_array[entity2]
	v13.row = row
	v14.row = row2
end

local function archetype_append(p: number, p2)
	local entities = p2.entities
	local v13 = #entities + 1
	entities[v13] = p
	return v13
end

local function new_entity(p: number, p2, archetype)
	local entities = archetype.entities
	local row2 = #entities + 1
	entities[row2] = p
	p2.archetype = archetype
	p2.row = row2
	return p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function entity_move(entity_index, p: number, state, to)
	local row = state.row
	local archetype = state.archetype
	local entities = to.entities
	local row2 = #entities + 1
	entities[row2] = p
	archetype_move(entity_index, to, row2, archetype, row)
	state.archetype = to
	state.row = row2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hash(list)
	return table.concat(list, "_")
end

local records = nil
local columns = nil
local row = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function fetch(p)
	local v13 = records[p]

	if v13 then
		return columns[v13.column][row]
	end

	return nil
end

local function world_get(p, p2: number, p3: number, p4: number?, p5: number?, p6: number?, p7: number?)
	local entity_index = p.entity_index
	local sparse_array = entity_index.sparse_array
	local v13

	if p2 > 16777216 then
		v13 = p2 // 16 // 16777216
	else
		v13 = p2
	end

	local v14 = sparse_array[v13]

	if v14 then
		if not v14 or v14.dense == 0 then
			v14 = nil
		end
	else
		v14 = nil
	end

	if v14 then
		local dense = v14.dense

		if entity_index.alive_count < dense then
			v14 = nil
		elseif entity_index.dense_array[dense] ~= p2 then
			v14 = nil
		end
	end

	if not v14 then
		return nil
	end

	local archetype = v14.archetype

	if not archetype then
		return nil
	end

	records = archetype.records
	columns = archetype.columns
	row = v14.row
	local selected = fetch(p3) -- equivalent call inferred; original call site unknown

	if not p4 then
		return selected
	end

	if p5 then
		if p6 then
			if p7 then
				error("args exceeded")
				return
			end

			local v16 = fetch(p4) -- equivalent call inferred; original call site unknown
			local selected2 = fetch(p5) -- equivalent call inferred; original call site unknown
			local record = records[p6]

			if record then
				return selected, v16, selected2, columns[record.column][row]
			end

			return selected, v16, selected2, nil
		else
			local selected2 = fetch(p4) -- equivalent call inferred; original call site unknown
			local record = records[p5]

			if record then
				return selected, selected2, columns[record.column][row]
			end

			return selected, selected2, nil
		end
	else
		local record = records[p4]

		if record then
			return selected, columns[record.column][row]
		end

		return selected, nil
	end
end

local function world_get_one_inline(p, p2: number, p3: number)
	local entity_index = p.entity_index
	local sparse_array = entity_index.sparse_array
	local v13

	if p2 > 16777216 then
		v13 = p2 // 16 // 16777216
	else
		v13 = p2
	end

	local v14 = sparse_array[v13]

	if v14 then
		if not v14 or v14.dense == 0 then
			v14 = nil
		end
	else
		v14 = nil
	end

	if v14 then
		local dense = v14.dense

		if entity_index.alive_count < dense then
			v14 = nil
		elseif entity_index.dense_array[dense] ~= p2 then
			v14 = nil
		end
	end

	if not v14 then
		return nil
	end

	local archetype = v14.archetype

	if not archetype then
		return nil
	end

	local record = archetype.records[p3]

	if record then
		return archetype.columns[record.column][v14.row]
	end

	return nil
end

local function world_has_one_inline(p, p2: number, p3: number)
	local entity_index = p.entity_index
	local sparse_array = entity_index.sparse_array
	local v13

	if p2 > 16777216 then
		v13 = p2 // 16 // 16777216
	else
		v13 = p2
	end

	local v14 = sparse_array[v13]

	if v14 then
		if not v14 or v14.dense == 0 then
			v14 = nil
		end
	else
		v14 = nil
	end

	if v14 then
		local dense = v14.dense

		if entity_index.alive_count < dense then
			v14 = nil
		elseif entity_index.dense_array[dense] ~= p2 then
			v14 = nil
		end
	end

	if not v14 then
		return false
	end

	local archetype = v14.archetype

	if archetype then
		return archetype.records[p3] ~= nil
	end

	return false
end

local function world_has(p, p2: number, ...)
	local entity_index = p.entity_index
	local sparse_array = entity_index.sparse_array
	local v13

	if p2 > 16777216 then
		v13 = p2 // 16 // 16777216
	else
		v13 = p2
	end

	local v14 = sparse_array[v13]

	if v14 then
		if not v14 or v14.dense == 0 then
			v14 = nil
		end
	else
		v14 = nil
	end

	if v14 then
		local dense = v14.dense

		if entity_index.alive_count < dense then
			v14 = nil
		elseif entity_index.dense_array[dense] ~= p2 then
			v14 = nil
		end
	end

	if not v14 then
		return false
	end

	local archetype = v14.archetype

	if not archetype then
		return false
	end

	local records2 = archetype.records

	for i = 1, select("#", ...) do
		if not records2[select(i, ...)] then
			return false
		end
	end

	return true
end

local function world_target(p, p2: number, p3: number, value: number?)
	local v13 = value or 0
	local entity_index = p.entity_index
	local sparse_array = entity_index.sparse_array
	local v14

	if p2 > 16777216 then
		v14 = p2 // 16 // 16777216
	else
		v14 = p2
	end

	local v15 = sparse_array[v14]

	if v15 then
		if not v15 or v15.dense == 0 then
			v15 = nil
		end
	else
		v15 = nil
	end

	if v15 then
		local dense = v15.dense

		if entity_index.alive_count < dense then
			v15 = nil
		elseif entity_index.dense_array[dense] ~= p2 then
			v15 = nil
		end
	end

	if not v15 then
		return nil
	end

	local archetype = v15.archetype

	if not archetype then
		return nil
	end

	local componentIndex = p.componentIndex
	local v16 = wildcard

	if v16 > 16777216 then
		v16 = v16 // 16 // 16777216
	end

	if p3 > 16777216 then
		p3 = p3 // 16 // 16777216
	end

	local v17 = componentIndex[v16 * 268435456 + p3 * 16 + bit32.bor(0, 8)]

	if not v17 then
		return nil
	end

	local v18 = v17.cache[archetype.id]

	if not v18 then
		return nil
	end

	local count = v18.count

	if count <= v13 then
		v13 = v13 + count + 1
	end

	local type = archetype.types[v13 + v18.column]

	if not type then
		return nil
	end

	local entity_index2 = p.entity_index

	if type > 16777216 then
		type = type // 16 // 16777216
	end

	local sparse_array2 = entity_index2.sparse_array

	if type > 16777216 then
		type = type // 16 // 16777216
	end

	local v19 = sparse_array2[type]

	if v19 then
		if not v19 or v19.dense == 0 then
			v19 = nil
		end
	else
		v19 = nil
	end

	if v19 then
		return entity_index2.dense_array[v19.dense]
	end

	return 0
end

local function ECS_ID_IS_WILDCARD(p: number)
	local v13 = ECS_ENTITY_T_HI(p)

	if p > 16777216 then
		p = p // 16 // 16777216
	end

	return v13 == wildcard or p == wildcard
end

local function id_record_ensure(state, p: number)
	local componentIndex = state.componentIndex
	local v13 = componentIndex[p]

	if v13 then
		return v13
	end

	local v15 = ECS_ENTITY_T_HI(p)
	local v16 = world_target(state, v15, onDelete, 0)
	local v17 = world_target(state, v15, onDeleteTarget, 0)
	local v18 = v16 == delete or v17 == delete
	local on_add, on_set, on_remove = world_get(state, v15, onAdd, onSet, onRemove)
	local component2 = component
	local entity_index = state.entity_index
	local sparse_array = entity_index.sparse_array
	local v23

	if v15 > 16777216 then
		v23 = v15 // 16 // 16777216
	else
		v23 = v15
	end

	local v24 = sparse_array[v23]

	if v24 then
		if not v24 or v24.dense == 0 then
			v24 = nil
		end
	else
		v24 = nil
	end

	if v24 then
		local dense = v24.dense

		if entity_index.alive_count < dense then
			v24 = nil
		elseif entity_index.dense_array[dense] ~= v15 then
			v24 = nil
		end
	end

	local v25

	if v24 then
		local archetype = v24.archetype

		if archetype then
			v25 = archetype.records[component2] ~= nil
		else
			v25 = false
		end
	else
		v25 = false
	end

	v13 = {
		size = 0,
		cache = {},
		flags = bit32.bor(
			0,
			on_add and 4 or 0,
			on_remove and 16 or 0,
			on_set and 8 or 0,
			v18 and 1 or 0,
			not v25 and 2 or 0
		),
		hooks = {
			on_add = on_add,
			on_set = on_set,
			on_remove = on_remove
		}
	}
	componentIndex[p] = v13
	return v13
end

local function archetype_append_to_records(state, p: number, p2, p3: number, column: number)
	local v13 = state.cache[p]

	if v13 then
		v13.count += 1
		return
	end

	local v14 = {
		column = column,
		count = 1
	}
	state.cache[p] = v14
	state.size += 1
	p2[p3] = v14
end

local function archetype_create(state, types, p, _: number?)
	local v13 = state.nextArchetypeId + 1
	state.nextArchetypeId = v13
	local v14 = #types
	local columns2 = table.create(v14)
	local records2 = {}

	for k, v17 in types do
		local v18 = id_record_ensure(state, v17)
		local v19 = v18.cache[v13]

		if v19 then
			v19.count += 1
		else
			local v20 = {
				column = k,
				count = 1
			}
			v18.cache[v13] = v20
			v18.size += 1
			records2[v17] = v20
		end

		if ECS_IS_PAIR(v17) then
			local entity_index = state.entity_index
			local v21 = ECS_ENTITY_T_HI(v17)
			local sparse_array = entity_index.sparse_array

			if v21 > 16777216 then
				v21 = v21 // 16 // 16777216
			end

			local v22 = sparse_array[v21]

			if v22 then
				if not v22 or v22.dense == 0 then
					v22 = nil
				end
			else
				v22 = nil
			end

			local v23 = not v22 and 0 or entity_index.dense_array[v22.dense]
			local entity_index2 = state.entity_index

			if v17 > 16777216 then
				v17 = v17 // 16 // 16777216
			end

			local sparse_array2 = entity_index2.sparse_array

			if v17 > 16777216 then
				v17 = v17 // 16 // 16777216
			end

			local v24 = sparse_array2[v17]

			if v24 then
				if not v24 or v24.dense == 0 then
					v24 = nil
				end
			else
				v24 = nil
			end

			local v25 = not v24 and 0 or entity_index2.dense_array[v24.dense]
			local v26 = wildcard

			if v26 > 16777216 then
				v26 = v26 // 16 // 16777216
			end

			if v23 > 16777216 then
				v23 = v23 // 16 // 16777216
			end

			local v27 = v26 * 268435456 + v23 * 16 + bit32.bor(0, 8)
			local v28 = id_record_ensure(state, v27)
			local v29 = v28.cache[v13]

			if v29 then
				v29.count += 1
			else
				local v30 = {
					column = k,
					count = 1
				}
				v28.cache[v13] = v30
				v28.size += 1
				records2[v27] = v30
			end

			local v30 = wildcard

			if v25 > 16777216 then
				v25 = v25 // 16 // 16777216
			end

			if v30 > 16777216 then
				v30 = v30 // 16 // 16777216
			end

			local v31 = v25 * 268435456 + v30 * 16 + bit32.bor(0, 8)
			local v32 = id_record_ensure(state, v31)
			local v33 = v32.cache[v13]

			if v33 then
				v33.count += 1
			else
				local v34 = {
					column = k,
					count = 1
				}
				v32.cache[v13] = v34
				v32.size += 1
				records2[v31] = v34
			end
		end

		if bit32.band(v18.flags, 2) == 0 then
			columns2[k] = {}
		else
			columns2[k] = frozen
		end
	end

	local v17 = {
		columns = columns2,
		node = {
			add = {},
			remove = {},
			refs = {}
		},
		entities = {},
		id = v13,
		records = records2,
		type = p,
		types = types
	}
	state.archetypeIndex[p] = v17
	state.archetypes[v13] = v17
	return v17
end

local function world_entity(p)
	local entity_index = p.entity_index
	local dense_array = entity_index.dense_array
	local alive_count = entity_index.alive_count

	if alive_count == #dense_array then
		local max_id = entity_index.max_id + 1
		entity_index.max_id = max_id
		local v14 = alive_count + 1
		entity_index.alive_count = v14
		dense_array[v14] = max_id
		entity_index.sparse_array[max_id] = {
			dense = v14
		}
		return max_id
	else
		local alive_count2 = alive_count + 1
		entity_index.alive_count = alive_count2
		return dense_array[alive_count2]
	end
end

local function world_parent(p, p2: number)
	return (world_target(p, p2, childOf, 0))
end

local function archetype_ensure(p, list)
	if #list < 1 then
		return p.ROOT_ARCHETYPE
	end

	local v13 = hash(list) -- equivalent call inferred; original call site unknown
	local v14 = p.archetypeIndex[v13]
	return v14 or archetype_create(p, list, v13)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function find_insert(types, p: number)
	for k, v13 in types do
		if v13 == p then
			return -1
		end

		if p < v13 then
			return k
		end
	end

	return #types + 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function find_archetype_with(p, p2, p3: number)
	local types = p2.types
	local clone = table.clone(p2.types)
	local v13 = find_insert(types, p3) -- equivalent call inferred; original call site unknown

	if v13 == -1 then
		return p2
	end

	table.insert(clone, v13, p3)

	if #clone < 1 then
		return p.ROOT_ARCHETYPE
	end

	local v14 = hash(clone) -- equivalent call inferred; original call site unknown
	local v15 = p.archetypeIndex[v14]
	return v15 or archetype_create(p, clone, v14)
end

local function find_archetype_without(p, p2, p3: number)
	local types = p2.types
	local index = table.find(types, p3)

	if index == nil then
		return p2
	end

	local clone = table.clone(types)
	table.remove(clone, index)

	if #clone < 1 then
		return p.ROOT_ARCHETYPE
	end

	local v13 = hash(clone) -- equivalent call inferred; original call site unknown
	local v14 = p.archetypeIndex[v13]
	return v14 or archetype_create(p, clone, v13)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function archetype_init_edge(from, p, id: number, to)
	p.from = from
	p.to = to
	p.id = id
end

local function archetype_ensure_edge(_, p, p2)
	local v13 = p[p2]

	if not v13 then
		v13 = {}
		p[p2] = v13
	end

	return v13
end

-- equivalent calls inferred from this helper; original call sites unknown
local function init_edge_for_add(_, from, p, id, to)
	archetype_init_edge(from, p, id, to) -- equivalent call inferred; original call site unknown
	local add = from.node.add

	if not add[id] then
		add[id] = {}
	end

	if from ~= to then
		local refs = to.node.refs
		local next = refs.next
		refs.next = p
		p.prev = refs
		p.next = next

		if next then
			next.prev = p
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function init_edge_for_remove(_, from, p, id: number, to)
	archetype_init_edge(from, p, id, to) -- equivalent call inferred; original call site unknown
	local remove = from.node.remove

	if not remove[id] then
		remove[id] = {}
	end

	if from ~= to then
		local refs = to.node.refs
		local prev = refs.prev
		refs.prev = p
		p.next = refs
		p.prev = prev

		if prev then
			prev.next = p
		end
	end
end

local function create_edge_for_add(p, from, p3, id: number)
	local to = find_archetype_with(p, from, id) -- equivalent call inferred; original call site unknown
	init_edge_for_add(nil, from, p3, id, to) -- equivalent call inferred; original call site unknown
	return to
end

local function create_edge_for_remove(p, from, p3, id: number)
	local to = find_archetype_without(p, from, id)
	init_edge_for_remove(nil, from, p3, id, to) -- equivalent call inferred; original call site unknown
	return to
end

local function archetype_traverse_add(p, id: number, p3)
	local from = p3 or p.ROOT_ARCHETYPE
	local add = from.node.add
	local v14 = add[id]

	if not v14 then
		v14 = {}
		add[id] = v14
	end

	local to = v14.to

	if to then
		return to
	end

	local types = from.types
	local clone = table.clone(from.types)
	local v15 = find_insert(types, id) -- equivalent call inferred; original call site unknown

	if v15 == -1 then
		to = from
	else
		table.insert(clone, v15, id)

		if #clone < 1 then
			to = p.ROOT_ARCHETYPE
		else
			local v16 = hash(clone) -- equivalent call inferred; original call site unknown
			to = p.archetypeIndex[v16] or archetype_create(p, clone, v16)
		end
	end

	init_edge_for_add(nil, from, v14, id, to) -- equivalent call inferred; original call site unknown
	return to
end

local function archetype_traverse_remove(p, id: number, p3)
	local from = p3 or p.ROOT_ARCHETYPE
	local remove = from.node.remove
	local v14 = remove[id]

	if not v14 then
		v14 = {}
		remove[id] = v14
	end

	local to = v14.to

	if not to then
		to = find_archetype_without(p, from, id)
		init_edge_for_remove(nil, from, v14, id, to) -- equivalent call inferred; original call site unknown
	end

	return to
end

local function invoke_hook(callback, p, p2)
	callback(p, p2)
end

local function world_add(data, p: number, id: number)
	local entity_index = data.entity_index
	local sparse_array = entity_index.sparse_array
	local v13

	if p > 16777216 then
		v13 = p // 16 // 16777216
	else
		v13 = p
	end

	local v14 = sparse_array[v13]

	if v14 then
		if not v14 or v14.dense == 0 then
			v14 = nil
		end
	else
		v14 = nil
	end

	if v14 then
		local dense = v14.dense

		if entity_index.alive_count < dense then
			v14 = nil
		elseif entity_index.dense_array[dense] ~= p then
			v14 = nil
		end
	end

	if not v14 then
		return
	end

	local archetype = v14.archetype
	local from = archetype or data.ROOT_ARCHETYPE
	local add = from.node.add
	local v16 = add[id]

	if not v16 then
		v16 = {}
		add[id] = v16
	end

	local to = v16.to

	if not to then
		local types = from.types
		local clone = table.clone(from.types)
		local v17 = find_insert(types, id) -- equivalent call inferred; original call site unknown

		if v17 == -1 then
			to = from
		else
			table.insert(clone, v17, id)

			if #clone < 1 then
				to = data.ROOT_ARCHETYPE
			else
				local v18 = hash(clone) -- equivalent call inferred; original call site unknown
				to = data.archetypeIndex[v18] or archetype_create(data, clone, v18)
			end
		end

		init_edge_for_add(nil, from, v16, id, to) -- equivalent call inferred; original call site unknown
	end

	if archetype == to then
		return
	end

	if archetype then
		entity_move(entity_index, p, v14, to) -- equivalent call inferred; original call site unknown
	elseif #to.types > 0 then
		local entities = to.entities
		local row2 = #entities + 1
		entities[row2] = p
		v14.archetype = to
		v14.row = row2
	end

	local on_add = data.componentIndex[id].hooks.on_add

	if on_add then
		on_add(p)
	end
end

local function world_set(data, p: number, id: number, p3)
	local entity_index = data.entity_index
	local sparse_array = entity_index.sparse_array
	local v13

	if p > 16777216 then
		v13 = p // 16 // 16777216
	else
		v13 = p
	end

	local v14 = sparse_array[v13]

	if v14 then
		if not v14 or v14.dense == 0 then
			v14 = nil
		end
	else
		v14 = nil
	end

	if v14 then
		local dense = v14.dense

		if entity_index.alive_count < dense then
			v14 = nil
		elseif entity_index.dense_array[dense] ~= p then
			v14 = nil
		end
	end

	if not v14 then
		return
	end

	local archetype = v14.archetype
	local from = archetype or data.ROOT_ARCHETYPE
	local add = from.node.add
	local v16 = add[id]

	if not v16 then
		v16 = {}
		add[id] = v16
	end

	local to = v16.to

	if not to then
		local types = from.types
		local clone = table.clone(from.types)
		local v17 = find_insert(types, id) -- equivalent call inferred; original call site unknown

		if v17 == -1 then
			to = from
		else
			table.insert(clone, v17, id)

			if #clone < 1 then
				to = data.ROOT_ARCHETYPE
			else
				local v18 = hash(clone) -- equivalent call inferred; original call site unknown
				to = data.archetypeIndex[v18] or archetype_create(data, clone, v18)
			end
		end

		init_edge_for_add(nil, from, v16, id, to) -- equivalent call inferred; original call site unknown
	end

	local v17 = data.componentIndex[id]
	local v18 = bit32.band(v17.flags, 2) ~= 0
	local hooks = v17.hooks

	if archetype == to then
		if v18 then
			return
		end

		local record = to.records[id]
		archetype.columns[record.column][v14.row] = p3
		local on_set = hooks.on_set

		if on_set then
			on_set(p, p3)
		end
	else
		if archetype then
			entity_move(entity_index, p, v14, to) -- equivalent call inferred; original call site unknown
		elseif #to.types > 0 then
			local entities = to.entities
			local row2 = #entities + 1
			entities[row2] = p
			v14.archetype = to
			v14.row = row2
		end

		local on_add = hooks.on_add

		if on_add then
			on_add(p)
		end

		if v18 then
			return
		end

		local record = to.records[id]
		to.columns[record.column][v14.row] = p3
		local on_set = hooks.on_set

		if on_set then
			on_set(p, p3)
		end
	end
end

local function world_component(p)
	local nextComponentId = p.nextComponentId + 1

	if __JECS_HI_COMPONENT_ID < nextComponentId then
		error("Too many components, consider using world:entity() instead to create components.")
	end

	p.nextComponentId = nextComponentId
	return nextComponentId
end

local function world_remove(data, p: number, id: number)
	local entity_index = data.entity_index
	local sparse_array = entity_index.sparse_array
	local v13

	if p > 16777216 then
		v13 = p // 16 // 16777216
	else
		v13 = p
	end

	local v14 = sparse_array[v13]

	if v14 then
		if not v14 or v14.dense == 0 then
			v14 = nil
		end
	else
		v14 = nil
	end

	if v14 then
		local dense = v14.dense

		if entity_index.alive_count < dense then
			v14 = nil
		elseif entity_index.dense_array[dense] ~= p then
			v14 = nil
		end
	end

	if not v14 then
		return
	end

	local archetype = v14.archetype

	if not archetype then
		return
	end

	local from = archetype or data.ROOT_ARCHETYPE
	local remove = from.node.remove
	local v16 = remove[id]

	if not v16 then
		v16 = {}
		remove[id] = v16
	end

	local to = v16.to

	if not to then
		to = find_archetype_without(data, from, id)
		init_edge_for_remove(nil, from, v16, id, to) -- equivalent call inferred; original call site unknown
	end

	if archetype and archetype ~= to then
		local on_remove = data.componentIndex[id].hooks.on_remove

		if on_remove then
			on_remove(p)
		end

		entity_move(entity_index, p, v14, to) -- equivalent call inferred; original call site unknown
	end
end

local function archetype_fast_delete_last(items, p: number, _, _: number)
	for _, item in items do
		if item ~= frozen then
			item[p] = nil
		end
	end
end

local function archetype_fast_delete(items, p: number, p2, _, _)
	for _, item in items do
		if item == frozen then
			continue
		end

		item[p2] = item[p]
		item[p] = nil
	end
end

local function archetype_delete(p, archetype, row2: number, _: boolean?)
	local entity_index = p.entity_index
	local columns2 = archetype.columns
	local types = archetype.types
	local entities = archetype.entities
	local count = #entities
	local count2 = #entities
	local entity = entities[count2]
	local entity2 = entities[row2]
	entities[row2] = entity
	entities[count2] = nil

	if row2 ~= count2 then
		local sparse_array = entity_index.sparse_array

		if entity > 16777216 then
			entity = entity // 16 // 16777216
		end

		local v13 = sparse_array[entity]

		if v13 then
			if not v13 or v13.dense == 0 then
				v13 = nil
			end
		else
			v13 = nil
		end

		if v13 then
			v13.row = row2
		end
	end

	for _, type in types do
		local onRemove2 = onRemove
		local entity_index2 = p.entity_index
		local sparse_array = entity_index2.sparse_array
		local v14

		if type > 16777216 then
			v14 = type // 16 // 16777216
		else
			v14 = type
		end

		local v15 = sparse_array[v14]

		if v15 then
			if not v15 or v15.dense == 0 then
				v15 = nil
			end
		else
			v15 = nil
		end

		if v15 then
			local dense = v15.dense

			if entity_index2.alive_count < dense then
				v15 = nil
			elseif entity_index2.dense_array[dense] ~= type then
				v15 = nil
			end
		end

		local v16

		if v15 then
			local archetype2 = v15.archetype

			if archetype2 then
				local record = archetype2.records[onRemove2]

				if record then
					v16 = archetype2.columns[record.column][v15.row]
				end
			end
		end

		if v16 then
			v16(entity2)
		end
	end

	if row2 == count2 then
		for _, column in columns2 do
			if column ~= frozen then
				column[count] = nil
			end
		end
	else
		for _, column in columns2 do
			if column == frozen then
				continue
			end

			column[row2] = column[count]
			column[count] = nil
		end
	end
end

local function world_clear(p, p2: number)
	local entity_index = p.entity_index
	local sparse_array = entity_index.sparse_array
	local v13

	if p2 > 16777216 then
		v13 = p2 // 16 // 16777216
	else
		v13 = p2
	end

	local v14 = sparse_array[v13]

	if v14 then
		if not v14 or v14.dense == 0 then
			v14 = nil
		end
	else
		v14 = nil
	end

	if v14 then
		local dense = v14.dense

		if entity_index.alive_count < dense then
			v14 = nil
		elseif entity_index.dense_array[dense] ~= p2 then
			v14 = nil
		end
	end

	if not v14 then
		return
	end

	local archetype = v14.archetype
	local row2 = v14.row

	if archetype then
		archetype_delete(p, archetype, row2)
	end

	v14.archetype = nil
	v14.row = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function archetype_disconnect_edge(p)
	local next = p.next
	local prev = p.prev

	if next then
		next.prev = prev
	end

	if prev then
		prev.next = next
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function archetype_remove_edge(p, p2: number, p3)
	archetype_disconnect_edge(p3) -- equivalent call inferred; original call site unknown
	p[p2] = nil
end

local function archetype_clear_edges(data)
	local node = data.node
	local add = node.add
	local remove = node.remove
	local refs = node.refs

	for k, v13 in add do
		archetype_remove_edge(add, k, v13) -- equivalent call inferred; original call site unknown
	end

	for k, v13 in remove do
		archetype_remove_edge(remove, k, v13) -- equivalent call inferred; original call site unknown
	end

	local next = refs.next

	while next do
		local next2 = next.next
		archetype_remove_edge(next.from.node.add, next.id, next) -- equivalent call inferred; original call site unknown
		next = next2
	end

	local prev = refs.prev

	while prev do
		local prev2 = prev.prev
		archetype_remove_edge(prev.from.node.remove, prev.id, prev) -- equivalent call inferred; original call site unknown
		prev = prev2
	end

	refs.next = nil
	refs.prev = nil
end

local function archetype_destroy(data, archetype)
	if archetype == data.ROOT_ARCHETYPE then
		return
	end

	local componentIndex = data.componentIndex
	archetype_clear_edges(archetype)
	local id = archetype.id
	data.archetypes[id] = nil
	data.archetypeIndex[archetype.type] = nil
	local records2 = archetype.records

	for k in records2 do
		local v13 = componentIndex[k]
		v13.cache[id] = nil
		v13.size -= 1
		records2[k] = nil

		if v13.size == 0 then
			componentIndex[k] = nil
		end
	end
end

local function world_cleanup(p)
	local archetypes = p.archetypes

	for _, archetype in archetypes do
		if #archetype.entities == 0 then
			archetype_destroy(p, archetype)
		end
	end

	local archetypes2 = table.create(#archetypes)
	local archetypesByType = {}

	for k, archetype in archetypes do
		archetypes2[k] = archetype
		archetypesByType[archetype.type] = archetype
	end

	p.archetypes = archetypes2
	p.archetypeIndex = archetypesByType
end

local world_delete

world_delete = function(data, id: number, flag: boolean?)
	local entity_index = data.entity_index
	local sparse_array = entity_index.sparse_array
	local v13

	if id > 16777216 then
		v13 = id // 16 // 16777216
	else
		v13 = id
	end

	local v14 = sparse_array[v13]

	if v14 then
		if not v14 or v14.dense == 0 then
			v14 = nil
		end
	else
		v14 = nil
	end

	if v14 then
		local dense = v14.dense

		if entity_index.alive_count < dense then
			v14 = nil
		elseif entity_index.dense_array[dense] ~= id then
			v14 = nil
		end
	end

	if not v14 then
		return
	end

	local archetype = v14.archetype
	local row2 = v14.row

	if archetype then
		archetype_delete(data, archetype, row2, flag)
	end

	local componentIndex = data.componentIndex
	local archetypes = data.archetypes
	local v15 = wildcard
	local v16

	if id > 16777216 then
		v16 = id // 16 // 16777216
	else
		v16 = id
	end

	if v15 > 16777216 then
		v15 = v15 // 16 // 16777216
	end

	local v17 = componentIndex[v16 * 268435456 + v15 * 16 + bit32.bor(0, 8)]
	local v18 = componentIndex[id]

	if v18 then
		local entities = {}

		for k in v18.cache do
			for _, entity in archetypes[k].entities do
				table.insert(entities, entity)
			end
		end

		if bit32.band(v18.flags, 1) == 0 then
			for _, v19 in entities do
				world_remove(data, v19, id)
			end
		else
			for _, v19 in entities do
				world_delete(data, v19)
			end
		end
	end

	if v17 then
		for k in v17.cache do
			local archetype2 = archetypes[k]
			local types = archetype2.types
			local entities = {}

			for _, entity in archetype2.entities do
				table.insert(entities, entity)
			end

			for _, type in types do
				if not ECS_IS_PAIR(type) then
					continue
				end

				local entity_index2 = data.entity_index
				local v21

				if type > 16777216 then
					v21 = type // 16 // 16777216
				else
					v21 = type
				end

				local sparse_array2 = entity_index2.sparse_array

				if v21 > 16777216 then
					v21 = v21 // 16 // 16777216
				end

				local v22 = sparse_array2[v21]

				if v22 then
					if not v22 or v22.dense == 0 then
						v22 = nil
					end
				else
					v22 = nil
				end

				if (not v22 and 0 or entity_index2.dense_array[v22.dense]) ~= id then
					continue
				end

				if bit32.band(componentIndex[type].flags, 1) == 0 then
					for _, v23 in entities do
						world_remove(data, v23, type)
					end
				else
					for _, v23 in entities do
						world_delete(data, v23, flag)
					end

					break
				end
			end

			archetype_destroy(data, archetype2)
		end
	end

	local dense_array = entity_index.dense_array
	local dense = v14.dense
	local alive_count = entity_index.alive_count
	entity_index.alive_count = alive_count - 1
	local v19 = dense_array[alive_count]
	local sparse_array2 = entity_index.sparse_array
	local v20

	if v19 > 16777216 then
		v20 = v19 // 16 // 16777216
	else
		v20 = v19
	end

	local v21 = sparse_array2[v20]

	if v21 then
		if not v21 or v21.dense == 0 then
			v21 = nil
		end
	else
		v21 = nil
	end

	v21.dense = dense
	v14.archetype = nil
	v14.row = nil
	v14.dense = alive_count
	dense_array[dense] = v19
	local v22

	if id > 16777216 then
		local v23 = id // 16
		v22 = v23 // 16777216
		local v24 = v23 % 65536 + 1

		if not (v24 > 65536) then
			v22 = v22 * 268435456 + v24 * 16
		end
	else
		v22 = id * 268435456 + 16
	end

	dense_array[alive_count] = v22
end

local function world_contains(p, p2)
	local entity_index = p.entity_index
	local sparse_array = entity_index.sparse_array
	local v13

	if p2 > 16777216 then
		v13 = p2 // 16 // 16777216
	else
		v13 = p2
	end

	local v14 = sparse_array[v13]

	if v14 then
		if not v14 or v14.dense == 0 then
			v14 = nil
		end
	else
		v14 = nil
	end

	if not v14 then
		return v14 ~= nil
	end

	local dense = v14.dense

	if entity_index.alive_count < dense then
		v14 = nil
	elseif entity_index.dense_array[dense] ~= p2 then
		v14 = nil
	end

	return v14 ~= nil
end

local function NOOP() end

local function ARM(p, ...)
	return p
end

local v13 = {}
local v14 = {
	__iter = function()
		return NOOP
	end,
	iter = function()
		return NOOP
	end,
	with = ARM,
	without = ARM,
	archetypes = function()
		return v13
	end
}
setmetatable(v14, v14)

local function query_iter_init(state)
	local compatible_archetypes = state.compatible_archetypes
	local v15 = 1
	local compatible_archetype = compatible_archetypes[1]

	if not compatible_archetype then
		return NOOP
	end

	local columns2 = compatible_archetype.columns
	local entities = compatible_archetype.entities
	local count = #entities
	local records2 = compatible_archetype.records
	local ids = state.ids
	local v16, v17, v18, v19, v20, v21, v22, v23, v24 = unpack(ids)
	local v25 = nil
	local v26 = nil
	local v27 = nil
	local v28 = nil
	local v29 = nil
	local v30 = nil
	local v31 = nil
	local v32 = nil

	if v17 then
		if v18 then
			if v19 then
				if v20 then
					if v21 then
						if v22 then
							if v23 then
								if not v24 then
									v25 = columns2[records2[v16].column]
									v26 = columns2[records2[v17].column]
									v27 = columns2[records2[v18].column]
									v28 = columns2[records2[v19].column]
									v29 = columns2[records2[v20].column]
									v30 = columns2[records2[v21].column]
									v31 = columns2[records2[v22].column]
									v32 = columns2[records2[v23].column]
								end
							else
								v25 = columns2[records2[v16].column]
								v26 = columns2[records2[v17].column]
								v27 = columns2[records2[v18].column]
								v28 = columns2[records2[v19].column]
								v29 = columns2[records2[v20].column]
								v30 = columns2[records2[v21].column]
								v31 = columns2[records2[v22].column]
							end
						else
							v25 = columns2[records2[v16].column]
							v26 = columns2[records2[v17].column]
							v27 = columns2[records2[v18].column]
							v28 = columns2[records2[v19].column]
							v29 = columns2[records2[v20].column]
							v30 = columns2[records2[v21].column]
						end
					else
						v25 = columns2[records2[v16].column]
						v26 = columns2[records2[v17].column]
						v27 = columns2[records2[v18].column]
						v28 = columns2[records2[v19].column]
						v29 = columns2[records2[v20].column]
					end
				else
					v25 = columns2[records2[v16].column]
					v26 = columns2[records2[v17].column]
					v27 = columns2[records2[v18].column]
					v28 = columns2[records2[v19].column]
				end
			else
				v25 = columns2[records2[v16].column]
				v26 = columns2[records2[v17].column]
				v27 = columns2[records2[v18].column]
			end
		else
			v25 = columns2[records2[v16].column]
			v26 = columns2[records2[v17].column]
		end
	else
		v25 = columns2[records2[v16].column]
	end

	local world_query_iter_next

	if v17 then
		if v18 then
			if v19 then
				if v20 then
					local v33 = {}

					world_query_iter_next = function()
						local entity = entities[count]

						while entity == nil do
							v15 += 1
							compatible_archetype = compatible_archetypes[v15]

							if not compatible_archetype then
								return nil
							end

							entities = compatible_archetype.entities
							count = #entities
							entity = entities[count]
							columns2 = compatible_archetype.columns
							local records3 = compatible_archetype.records

							if v21 then
								if v22 then
									if v23 then
										if not v24 then
											v25 = columns2[records3[v16].column]
											v26 = columns2[records3[v17].column]
											v27 = columns2[records3[v18].column]
											v28 = columns2[records3[v19].column]
											v29 = columns2[records3[v20].column]
											v30 = columns2[records3[v21].column]
											v31 = columns2[records3[v22].column]
											v32 = columns2[records3[v23].column]
										end
									else
										v25 = columns2[records3[v16].column]
										v26 = columns2[records3[v17].column]
										v27 = columns2[records3[v18].column]
										v28 = columns2[records3[v19].column]
										v29 = columns2[records3[v20].column]
										v30 = columns2[records3[v21].column]
										v31 = columns2[records3[v22].column]
									end
								else
									v25 = columns2[records3[v16].column]
									v26 = columns2[records3[v17].column]
									v27 = columns2[records3[v18].column]
									v28 = columns2[records3[v19].column]
									v29 = columns2[records3[v20].column]
									v30 = columns2[records3[v21].column]
								end
							else
								v25 = columns2[records3[v16].column]
								v26 = columns2[records3[v17].column]
								v27 = columns2[records3[v18].column]
								v28 = columns2[records3[v19].column]
								v29 = columns2[records3[v20].column]
							end
						end

						local v34 = count
						count -= 1

						if not v21 then
							return entity, v25[v34], v26[v34], v27[v34], v28[v34], v29[v34]
						end

						if not v22 then
							return entity, v25[v34], v26[v34], v27[v34], v28[v34], v29[v34], v30[v34]
						end

						if not v23 then
							return entity, v25[v34], v26[v34], v27[v34], v28[v34], v29[v34], v30[v34], v31[v34]
						end

						if not v24 then
							return
								entity,
								v25[v34],
								v26[v34],
								v27[v34],
								v28[v34],
								v29[v34],
								v30[v34],
								v31[v34],
								v32[v34]
						end

						local records3 = compatible_archetype.records

						for k, id in ids do
							v33[k] = columns2[records3[id].column][v34]
						end

						return entity, unpack(v33)
					end
				else
					world_query_iter_next = function()
						local entity = entities[count]

						while entity == nil do
							v15 += 1
							compatible_archetype = compatible_archetypes[v15]

							if not compatible_archetype then
								return nil
							end

							entities = compatible_archetype.entities
							count = #entities
							entity = entities[count]
							columns2 = compatible_archetype.columns
							local records3 = compatible_archetype.records
							v25 = columns2[records3[v16].column]
							v26 = columns2[records3[v17].column]
							v27 = columns2[records3[v18].column]
							v28 = columns2[records3[v19].column]
						end

						local v33 = count
						count -= 1
						return entity, v25[v33], v26[v33], v27[v33], v28[v33]
					end
				end
			else
				world_query_iter_next = function()
					local entity = entities[count]

					while entity == nil do
						v15 += 1
						compatible_archetype = compatible_archetypes[v15]

						if not compatible_archetype then
							return nil
						end

						entities = compatible_archetype.entities
						count = #entities
						entity = entities[count]
						columns2 = compatible_archetype.columns
						local records3 = compatible_archetype.records
						v25 = columns2[records3[v16].column]
						v26 = columns2[records3[v17].column]
						v27 = columns2[records3[v18].column]
					end

					local v33 = count
					count -= 1
					return entity, v25[v33], v26[v33], v27[v33]
				end
			end
		else
			world_query_iter_next = function()
				local entity = entities[count]

				while entity == nil do
					v15 += 1
					compatible_archetype = compatible_archetypes[v15]

					if not compatible_archetype then
						return nil
					end

					entities = compatible_archetype.entities
					count = #entities
					entity = entities[count]
					columns2 = compatible_archetype.columns
					local records3 = compatible_archetype.records
					v25 = columns2[records3[v16].column]
					v26 = columns2[records3[v17].column]
				end

				local v33 = count
				count -= 1
				return entity, v25[v33], v26[v33]
			end
		end
	else
		world_query_iter_next = function()
			local entity = entities[count]

			while entity == nil do
				v15 += 1
				compatible_archetype = compatible_archetypes[v15]

				if not compatible_archetype then
					return nil
				end

				entities = compatible_archetype.entities
				count = #entities
				entity = entities[count]
				columns2 = compatible_archetype.columns
				local records3 = compatible_archetype.records
				v25 = columns2[records3[v16].column]
			end

			local v33 = count
			count -= 1
			return entity, v25[v33]
		end
	end

	state.next = world_query_iter_next
	return world_query_iter_next
end

local function query_iter(p)
	return p.next or query_iter_init(p)
end

local function query_without(p, ...)
	local compatible_archetypes = p.compatible_archetypes
	local v15 = select("#", ...)

	for i = #compatible_archetypes, 1, -1 do
		local records2 = compatible_archetypes[i].records
		local flag = false

		for i2 = 1, v15 do
			if not records2[select(i2, ...)] then
				continue
			end

			flag = true
			break
		end

		if not flag then
			continue
		end

		local count = #compatible_archetypes

		if count ~= i then
			compatible_archetypes[i] = compatible_archetypes[count]
		end

		compatible_archetypes[count] = nil
	end

	if #compatible_archetypes == 0 then
		return v14
	end

	return p
end

local function query_with(p, ...)
	local compatible_archetypes = p.compatible_archetypes
	local v15 = select("#", ...)

	for i = #compatible_archetypes, 1, -1 do
		local records2 = compatible_archetypes[i].records
		local flag = false

		for i2 = 1, v15 do
			if records2[select(i2, ...)] then
				continue
			end

			flag = true
			break
		end

		if not flag then
			continue
		end

		local count = #compatible_archetypes

		if count ~= i then
			compatible_archetypes[i] = compatible_archetypes[count]
		end

		compatible_archetypes[count] = nil
	end

	if #compatible_archetypes == 0 then
		return v14
	end

	return p
end

local function query_archetypes(p)
	return p.compatible_archetypes
end

local class = {}
class.__index = class
class.__iter = query_iter
class.iter = query_iter_init
class.without = query_without
class.with = query_with
class.archetypes = query_archetypes

local function world_query(p, ...)
	local ids = { ... }
	local archetypes = p.archetypes
	local componentIndex = p.componentIndex
	local v16 = nil
	local count = 0
	local archetypes2 = {}

	for _, v17 in ids do
		local v18 = componentIndex[v17]

		if not v18 then
			return v14
		end

		if v16 == nil or v18.size < v16.size then
			v16 = v18
		end
	end

	if not v16 then
		return v14
	end

	for k in v16.cache do
		local archetype = archetypes[k]

		if #archetype.entities == 0 then
			continue
		end

		local records2 = archetype.records
		local v17 = false

		for _, v19 in ids do
			if records2[v19] then
				continue
			end

			v17 = true
			break
		end

		if v17 then
			continue
		end

		count += 1
		archetypes2[count] = archetype
	end

	if count == 0 then
		return v14
	end

	return (setmetatable({
		compatible_archetypes = archetypes2,
		ids = ids
	}, class))
end

local class2 = {}
class2.__index = class2
class2.entity = world_entity
class2.query = world_query
class2.remove = world_remove
class2.clear = world_clear
class2.delete = world_delete
class2.component = world_component
class2.add = world_add
class2.set = world_set
class2.get = world_get
class2.has = world_has
class2.target = world_target
class2.parent = world_parent
class2.contains = world_contains
class2.cleanup = world_cleanup

if _G.__JECS_DEBUG then
	local function throw(message: string)
		local v15 = 1

		repeat
			v15 += 1
		until debug.info(v15, "s") ~= debug.info(1, "s")

		if warn then
			error(message, v15)
		else
			print((`[jecs] error: {message}\n`))
		end
	end

	local function ASSERT(p, p2: string)
		if p then
			return
		end

		throw(p2)
	end

	local get_name

	get_name = function(p, p2)
		local v15 = nil

		if ECS_IS_PAIR(p2) then
			local v20 = get_name(p, (ECS_ENTITY_T_HI(p2)))
			local v22

			if p2 > 16777216 then
				v22 = p2 // 16 // 16777216
			else
				v22 = p2
			end

			v15 = `pair({v20}, {get_name(p, v22)})`
		else
			local name2 = name
			local entity_index = p.entity_index
			local sparse_array = entity_index.sparse_array
			local v18

			if p2 > 16777216 then
				v18 = p2 // 16 // 16777216
			else
				v18 = p2
			end

			local v19 = sparse_array[v18]

			if v19 then
				if not v19 or v19.dense == 0 then
					v19 = nil
				end
			else
				v19 = nil
			end

			if v19 then
				local dense = v19.dense

				if entity_index.alive_count < dense then
					v19 = nil
				elseif entity_index.dense_array[dense] ~= p2 then
					v19 = nil
				end
			end

			local v20

			if v19 then
				local archetype = v19.archetype

				if archetype then
					local record = archetype.records[name2]

					if record then
						v20 = archetype.columns[record.column][v19.row]
					end
				end
			end

			if v20 then
				v15 = `${v20}`
			end
		end

		return v15 or `${p2}`
	end

	local function ID_IS_TAG(p, p2)
		if p2 > 16777216 then
			p2 = p2 // 16 % 16777216
		end

		local component2 = component
		local entity_index = p.entity_index
		local sparse_array = entity_index.sparse_array
		local v16

		if p2 > 16777216 then
			v16 = p2 // 16 // 16777216
		else
			v16 = p2
		end

		local v17 = sparse_array[v16]

		if v17 then
			if not v17 or v17.dense == 0 then
				v17 = nil
			end
		else
			v17 = nil
		end

		if v17 then
			local dense = v17.dense

			if entity_index.alive_count < dense then
				v17 = nil
			elseif entity_index.dense_array[dense] ~= p2 then
				v17 = nil
			end
		end

		local v18

		if v17 then
			local archetype = v17.archetype

			if archetype then
				v18 = archetype.records[component2] ~= nil
			else
				v18 = false
			end
		else
			v18 = false
		end

		return not v18
	end

	function class2.query(p, ...)
		if not ... then
			throw("Requires at least a single component")
		end

		return world_query(p, ...)
	end

	function class2.set(p, p2: number, id: number, p4)
		local v15 = ECS_ENTITY_T_HI(id)
		local component2 = component
		local entity_index = p.entity_index
		local sparse_array = entity_index.sparse_array
		local v17

		if v15 > 16777216 then
			v17 = v15 // 16 // 16777216
		else
			v17 = v15
		end

		local v18 = sparse_array[v17]

		if v18 then
			if not v18 or v18.dense == 0 then
				v18 = nil
			end
		else
			v18 = nil
		end

		if v18 then
			local dense = v18.dense

			if entity_index.alive_count < dense then
				v18 = nil
			elseif entity_index.dense_array[dense] ~= v15 then
				v18 = nil
			end
		end

		local v19

		if v18 then
			local archetype = v18.archetype

			if archetype then
				v19 = archetype.records[component2] ~= nil
			else
				v19 = false
			end
		else
			v19 = false
		end

		local v20 = not v19

		if v20 and p4 == nil then
			world_add(p, p2, id)
			get_name(p, p2)
			get_name(p, id)
			throw("cannot set component value to nil")
		else
			if p4 == nil or not v20 then
				world_set(p, p2, id, p4)
				return
			end

			world_add(p, p2, id)
			local v21 = get_name(p, p2)
			local v22 = get_name(p, id)
			throw(`cannot set a component value because {v22} is a tag` .. `\n[jecs] note: consider using "world:add({v21}, {v22})" instead`)
		end
	end

	function class2.add(p, p2: number, id: number, p4: nil)
		if p4 == nil then
			world_add(p, p2, id)
			return
		end

		throw("You provided a value when none was expected. " .. `Did you mean to use "world:add({get_name(p, p2)}, {get_name(p, id)})"`)
	end

	function class2.get(p, p2: number, ...)
		local v15 = select("#", ...)

		if not (v15 < 5) then
			throw("world:get does not support more than 4 components")
		end

		local v16 = nil

		for i = 1, v15 do
			local v17 = select(i, ...)

			if world_has(p, v17, component) then
				continue
			end

			local v18 = get_name(p, v17)
			v16 = v16 or get_name(p, p2)
			throw(`cannot get (#{i}) component {v18} value because it is a tag.` .. `\n[jecs] note: If this was intentional, use "world:has({v16}, {v18}) instead"`)
		end

		return world_get(p, p2, ...)
	end
end

function class2.new()
	local entity_index = {
		dense_array = {},
		sparse_array = {},
		alive_count = 0,
		max_id = 0
	}
	local self = setmetatable({
		archetypeIndex = {},
		archetypes = {},
		componentIndex = {},
		entity_index = entity_index,
		nextArchetypeId = 0,
		nextComponentId = 0,
		nextEntityId = 0,
		ROOT_ARCHETYPE = nil
	}, class2)
	self.ROOT_ARCHETYPE = archetype_create(self, {}, "")

	for _ = 1, __JECS_HI_COMPONENT_ID do
		local dense_array = entity_index.dense_array
		local alive_count = entity_index.alive_count
		local max_id

		if alive_count == #dense_array then
			max_id = entity_index.max_id + 1
			entity_index.max_id = max_id
			local v17 = alive_count + 1
			entity_index.alive_count = v17
			dense_array[v17] = max_id
			entity_index.sparse_array[max_id] = {
				dense = v17
			}
		else
			local alive_count2 = alive_count + 1
			entity_index.alive_count = alive_count2
			max_id = dense_array[alive_count2]
		end

		world_add(self, max_id, component)
	end

	for _ = __JECS_HI_COMPONENT_ID + 1, rest do
		local dense_array = entity_index.dense_array
		local alive_count = entity_index.alive_count

		if alive_count == #dense_array then
			local max_id = entity_index.max_id + 1
			entity_index.max_id = max_id
			local v17 = alive_count + 1
			entity_index.alive_count = v17
			dense_array[v17] = max_id
			entity_index.sparse_array[max_id] = {
				dense = v17
			}
		else
			local alive_count2 = alive_count + 1
			entity_index.alive_count = alive_count2
			local _ = dense_array[alive_count2]
		end
	end

	world_add(self, name, component)
	world_add(self, onSet, component)
	world_add(self, onAdd, component)
	world_add(self, onRemove, component)
	world_add(self, wildcard, component)
	world_add(self, rest, component)
	world_set(self, onAdd, name, "jecs.OnAdd")
	world_set(self, onRemove, name, "jecs.OnRemove")
	world_set(self, onSet, name, "jecs.OnSet")
	world_set(self, wildcard, name, "jecs.Wildcard")
	world_set(self, childOf, name, "jecs.ChildOf")
	world_set(self, component, name, "jecs.Component")
	world_set(self, onDelete, name, "jecs.OnDelete")
	world_set(self, onDeleteTarget, name, "jecs.OnDeleteTarget")
	world_set(self, delete, name, "jecs.Delete")
	world_set(self, remove2, name, "jecs.Remove")
	world_set(self, name, name, "jecs.Name")
	world_set(self, rest, rest, "jecs.Rest")
	local v18 = onDeleteTarget
	local v19 = delete

	if v19 > 16777216 then
		v19 = v19 // 16 // 16777216
	end

	if v18 > 16777216 then
		v18 = v18 // 16 // 16777216
	end

	world_add(self, childOf, v19 * 268435456 + v18 * 16 + bit32.bor(0, 8))
	return self
end

return {
	World = class2,
	OnAdd = onAdd,
	OnRemove = onRemove,
	OnSet = onSet,
	ChildOf = childOf,
	Component = component,
	Wildcard = wildcard,
	w = wildcard,
	OnDelete = onDelete,
	OnDeleteTarget = onDeleteTarget,
	Delete = delete,
	Remove = remove2,
	Name = name,
	Rest = rest,
	pair = ECS_PAIR,
	ECS_ID = ECS_ENTITY_T_LO,
	ECS_GENERATION_INC = ECS_GENERATION_INC,
	ECS_GENERATION = ECS_GENERATION,
	ECS_ID_IS_WILDCARD = ECS_ID_IS_WILDCARD,
	IS_PAIR = ECS_IS_PAIR,
	pair_first = ecs_pair_first,
	pair_second = ecs_pair_second,
	entity_index_get_alive = entity_index_get_alive,
	archetype_append_to_records = archetype_append_to_records,
	id_record_ensure = id_record_ensure,
	archetype_create = archetype_create,
	archetype_ensure = archetype_ensure,
	find_insert = find_insert,
	find_archetype_with = find_archetype_with,
	find_archetype_without = find_archetype_without,
	archetype_init_edge = archetype_init_edge,
	archetype_ensure_edge = archetype_ensure_edge,
	init_edge_for_add = init_edge_for_add,
	init_edge_for_remove = init_edge_for_remove,
	create_edge_for_add = create_edge_for_add,
	create_edge_for_remove = create_edge_for_remove,
	archetype_traverse_add = archetype_traverse_add,
	archetype_traverse_remove = archetype_traverse_remove,
	entity_index_try_get = entity_index_try_get,
	entity_index_try_get_any = entity_index_try_get_any,
	entity_index_is_alive = entity_index_is_alive,
	entity_index_remove = entity_index_remove,
	entity_index_new_id = entity_index_new_id
}