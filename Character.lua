--[[

	Character.lua

	Creates characters based on the definition files in 
	EntityDefs.lua


	27 Mar 2023

]]

Character = {}
Character.__index = Character

function Character:Create(def, map)

	-- look up the entity
	local entityDef = Entities[def.entity]
	assert(entityDef)	-- the entitydef should always exist

	local this =
	{
		Entity = Entity:Create(entityDef),
		Anims = def.anims,
		Facing = def.facing,
		DefaultState = def.state,
	}

	setmetatable(this, self)

	-- create the controller states from the def
	-- dependency loop, WaitState and MoveState depend on StateMachine
	-- StateMachine depends on WaitState and MoveState
	-- create empty controller, then add states after
	local states = {}

	-- make the controller state machine from the states
	this.Controller = StateMachine:Create(states)

	for k, name in ipairs(def.controller) do
		-- 'CharacterStates' is global
		local state = CharacterStates[name]
		assert(state)
		assert(states[state.Name] == nil)	-- state already in use
		local instance = state:Create(this, map)
		states[state.Name] = function() return instance end
	end

	this.Controller.states = states

	-- change the statemachine to the initial state
	-- as defined in the def
	this.Controller:Change(def.state)

	return this
end