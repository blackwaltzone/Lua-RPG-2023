--[[

	ItemMenuState.lua

	Item Menu


	Dustin Heyden

	08 May, 2023

]]

ItemMenuState = {}
ItemMenuState.__index = ItemMenuState

function ItemMenuState:Create(parent)

	local layout = MenuLayout:Create()
	layout:Contract('screen', 118, 40)
	layout:SplitHorizontal('screen', "top", "bottom", 0.12, 2)
	layout:SplitVertical('top', "title", "category", 0.6, 2)
	layout:SplitHorizontal('bottom', "mid", "inv", 0.14, 2)

	local this = 
	{
		Parent = parent,
		Stack = parent.Stack,
		StateMachine = parent.StateMachine,

		Layout = layout,
		Panels =
		{
			layout:CreatePanel("title"),	-- item menu
			layout:CreatePanel("category"),	-- item categories
			layout:CreatePanel("mid"),		-- item description
			layout:CreatePanel("inv"),		-- inventory list
		},

		Scrollbar = Scrollbar:Create(Texture.find("scrollbar.png"), 228),

		ItemMenus =
		{
			-- regular items
			Selection:Create
			{
				data = World.Items,
				spacingX = 256,
				columns = 2,
				displayRows = 8,
				spacingY = 28,
				rows = 20,
				RenderItem = function(self, renderer, x, y, item)
					World:DrawItem(self, renderer, x, y, item)
				end
			},
			-- key items
			Selection:Create
			{
				data = World.KeyItems,
				spacingX = 256,
				columns = 2,
				displayRows = 8,
				spacingY = 28,
				rows = 20,
				RenderItem = function(self, renderer, x, y, item)
					World:DrawKey(self, renderer, x, y, item)
				end
			},
		},

		-- vertical selection menu
		CategoryMenu = SelectionCreate
		{
			data = {"Use", "Key Items"},
			OnSelection = function(...) this:OnCategorySelect(...) end,
			spacingX = 150,
			columns = 2,
			rows = 1,
		},

		-- controls which selection menu player interacts with
		-- changing moves focus from category menu to item menus
		InCategoryMenu = true
	}

	for k, v in ipairs(this.ItemMenus) do
		v:HideCursor()
	end

	setmetatable(this, self)

	return this
end


-- functions
function ItemMenuState:Enter() end

function ItemMenuState:Exit() end


-- selected category
-- index = item selected
-- value = value of the item at that index ("Use", or "Key Items")
-- 1 = Use
-- 2 = KeyItems
function ItemMenuState:OnCategorySelect(index, value)
	-- category menu is losing focus
	self.CategoryMenu:HideCursor()
	self.InCategoryMenu = false

	-- bottom panel gaining focus
	local menu = self.ItemMenus[index]
	menu:ShowCursor()
end


-- render
function ItemMenuState:Render(renderer)

	-- draw all backing panels
	for k, v in ipairs(self.Panels) do
		v:Render(renderer)
	end

	-- draw title
	local titleX = self.Layout.MidX("title")
	local titleY = self.Layout.MixY("title")
	renderer:ScaleText(1.5, 1.5)
	renderer:AlignText("center", "center")
	renderer:DrawText2d(titleX, titleY, "Items")

	-- draw category menu
	renderer:AlignText("left", "center")
	local categoryX = self.Layout:Left("category") + 5
	local categoryY = self.Layout:MidY("category")
	renderer:ScaleText(1.5, 1.5)
	self.CategoryMenu:Render(renderer)
	self.CategoryMenu:SetPosition(categoryX, categoryY)

	-- get description position (center left of "mid" panel)
	local descX = self.Layout.Left("mid") + 10
	local descY = self.Layout.MidY("mid")
	renderer:ScaleText(1, 1)

	-- get correct menu focus
	local menu = self.ItemMenus[self.CategoryMenu:GetIndex()]

	-- which item is selected? get description
	-- by looking up in DB table
	if not self.InCategoryMenu then
		local description = ""
		local selectedItem = menu:SelectedItem()

		if selectedItem then
			local itemDef = ItemDB[selectedItem.id]
			description = itemDef.description
		end

		renderer:DrawText2d(descX, descY, description)
	end

	-- get inventory position
	local itemX = self.Layout:Left("inv") - 6
	local itemY = self.Layout:Top("inv") - 20

	-- draw inventory menu from top left of "inv" panel
	menu:SetPosition(itemX, itemY)
	menu:Render(renderer)

	-- draw scrollbar
	local scrollX = self.Layout:Right("inv") - 14
	local scrollY = self.Layout:MidY("inv")
	self.Scrollbar:SetPosition(scrollX, scrollY)
	self.Scrollbar:Render(renderer)
end



-- update
function ItemMenuState:Update(dt)

	local menu = self.ItemMenus[self.CategoryMenu:GetIndex()]

	-- if in category menu, input is passed to category selection menu
	if self.InCategoryMenu then
		if Keyboard.JustReleased(KEY_BACKSPACE) or
			Keyboard.JustReleased(KEY_ESCAPE) then
			
			self.StateMachine:Change("frontmenu")
		end

		self.CategoryMenu:HandleInput()
	else
		-- otherwise we look up active item menu and tell it to handle
		-- it's input
		if Keyboard.JustReleased(KEY_BACKSPACE) or
			Keyboard.JustReleased(KEY_ESCAPE) then
			
			self:FocusOnCategoryMenu()
		end

		menu:HandleInput()
	end

	-- update scrollbar and position accordingly
	local scrolled = menu:PercentageScrolled()
	self.Scrollbar:SetScrollCaretScale(menu:PercentageShown())
	self.Scrollbar:SetNormalValue(scrolled)

end


-- move focus back to category menu
-- 	- flip InCategoryMenu = true
--  - hide item menu cursor
--  - show the cursor for the category menu
function ItemMenuState:FocusOnCategoryMenu()
	self.InCategoryMenu = true
	local menu = self.ItemMenus[self.CategoryMenu:GetIndex()]
	menu:HideCursor()
	self.CategoryMenu:ShowCursor()
end