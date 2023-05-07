--[[

	FrontMenuState.lua

	Displays a list of submenus and important game info


	Dustin Heyden

	06 May, 2023

]]

FrontMenuState = {}
FrontMenuState.__index = FrontMenuState

function FrontMenuState:Create(parent, world)

	local layout = MenuLayout:Create()
	layout:Contract('screen', 118, 40)
	layout:SplitHorizontal('screen', 'top', 'bottom', 0.12, 2)
	layout:SplitVertical('bottom', 'left', 'party', 0.726, 2)
	layout:SplitHorizontal('left', 'menu', 'gold', 0.7, 2)

	local this = 
	{
		Parent = parent,
		Stack = parent.Stack,
		StateMachine = parent.StateMachine,
		Layout = layout,
	
		Selections = Selection:Create
		{
			spacingY = 32,
			data =
			{
				"Items",
				--"Magic",
				--"Equipment",
				--"Status",
				--"Save",
			},
			OnSelection = function(...) this:OnMenuClick(...) end
		},

		Panels =
		{
			layout:CreatePanel('gold'),
			layout:CreatePanel('top'),
			layout:CreatePanel('party'),
			layout:CreatePanel('menu'),
		},

		TopBarText = "Current Map Name",
	}

	setmetatable(this, self)

	return this
end


-- update
function FrontMenuState:Update(dt)
	
	self.Selections:HandleInput()

	-- pop off the stack
	if Keyboard.JustPressed(KEY_BACKSPACE) or
		Keyboard.JustPressed(KEY_ESCAPE) then
			self.Stack:Pop()
	end
end


-- render
function FrontMenuState:Render(renderer)

	-- render each panel
	for k, v in ipairs(self.Panels) do
		v:Render(renderer)
	end

	-- display menu selections
	renderer:ScaleText(1.5, 1.5)
	renderer:AlignText('left', 'center')
	local menuX = self.Layout:Left('menu') - 16
	local menuY = self.Layout:Top('menu') - 24
	self.Selections:SetPosition(menuX, menuY)
	self.Selections:Render(renderer)

	-- display the top bar
	local nameX = self.Layout:MidX('top')
	local nameY = self.Layout:MidY('top')
	renderer:AlignText('center', 'center')
	renderer:DrawText2d(nameX, nameY, self.TopBarText)

	-- find gold position
	local goldX = self.Layout:MidX('gold') - 22
	local goldY = self.Layout:MidY('gold') + 22

	-- display gold and time
	renderer:ScaleText(1.22, 1.22)
	-- right-align labels
	renderer:AlignText('right', 'top')
	renderer:DrawText2d(goldX, goldY, "GP:")
	renderer:DrawText2d(goldX, goldY - 25, "TIME:")
	-- left-align values
	renderer:AlignText('left', 'top')
	renderer:DrawText2d(goldX + 10, goldY, "0")
	renderer:DrawText2d(goldX + 10, goldY - 25, "0")
end


-- when the user selects a menu item
function FrontMenuState:OnMenuClick(index)

	local ITEMS = 1

	if index == ITEMS then
		return self.StateMachine:Change('items')
	end
end


function FrontMenuState:Enter() end

function FrontMenuState:Exit() end