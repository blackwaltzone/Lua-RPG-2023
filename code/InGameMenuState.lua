--[[

	InGameMenuState.lua

	Menu that works as a quick heads-up to show pertinent info:
		gold
		play time
		party status
		sub menus

	When player opens menu, push InGameMenuState onto stack
	When player closes, pop it off

	Uses a statemachine to handle submenus


	Dustin Heyden

	06 May, 2023

]]

InGameMenuState = {}
InGameMenuState.__index = InGameMenuState

function InGameMenuState:Create(stack)

	local this =
	{
		Stack = stack,
	}

	this.StateMachine = StateMachine:Create
	{
		-- displays a list of submenus and important game info
		['frontmenu'] =
		function()
			return FrontMenuState:Create(this)
		end,
		['items'] =
		function()
			return ItemMenuState:Create(this)
		end,
		['magic'] =
		function()
			-- return MagicMenuState:Create(this)
			return this.StateMachine.Empty
		end,
		['equp'] =
		function()
			-- return EquipMenuState:Create(this)
			return this.StateMachine.Empty
		end,
		['status'] =
		function()
			-- return StatusMenuState:Create(this)
			return this.StateMachine.Empty
		end
	}

	this.StateMachine:Change('frontmenu')

	setmetatable(this, self)

	return this
end


-- update the top menu
function InGameMenuState:Update(dt)
	if self.Stack:Top() == self then
		self.StateMachine:Update(dt)
	end
end


-- render the menus
function InGameMenuState:Render(renderer)
	self.StateMachine:Render(renderer)
end


function InGameMenuState:Enter() end

function InGameMenuState:Exit() end

function InGameMenuState:HandleInput() end