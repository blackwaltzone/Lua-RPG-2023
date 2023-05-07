--[[

	Selection.lua

	Implementation of selection menu
	Can be used for textboxes, browsing inventory,
	Can be overridden

	Supports lists made from multiple columns, can scroll
	long lists


	Dustin Heyden

	26 April, 2023

]]--

Selection = {}
Selection.__index = Selection

function Selection:Create(params)

	local this =
	{
		X = 0,
		Y = 0,
		DataSource = params.data,
		Columns = params.columns or 1,
		FocusX = 1,
		FocusY = 1,
		SpacingY = params.spacingY or 24,
		SpacingX = params.spacingX or 128,
		Cursor = Sprite:Create(),
		ShowCursor = true,
		MaxRows = params.rows or #params.data,
		DisplayStart = 1,
		Scale = 1,
		OnSelection = params.OnSelection or function() end
	}

	this.DisplayRows = params.DisplayRows or this.MaxRows

	local cursorTexture = Texture.Find(params.cursor or "cursor.png")
	this.Cursor:SetTexture(cursorTexture)
	this.CursorWidth = cursorTexture:GetWidth()

	setmetatable(this, self)

	this.RenderItem = params.RenderItem or this.RenderItem
	this.Width = this:CalcWidth(Renderer)
	this.Height = this:CalcHeight()

	return this
end


function Selection:Render(renderer)

	-- when displayRows < maxRows, only display a subset
	-- to fit on screen
	local displayStart = self.DisplayStart
	local displayEnd = displayStart + self.DisplayRows - 1

	local x = self.X
	local y = self.Y

	local cursorWidth = self.CursorWidth * self.Scale
	local cursorHalfWidth = cursorWidth / 2

	local colWidth = (self.SpacingX * self.Scale)
	local rowHeight = (self.SpacingY * self.Scale)

	self.Cursor:SetScale(self.Scale, self.Scale)

	local itemIndex = ((displayStart - 1) * self.Columns) + 1
	
	-- iterate through and display the items
	-- draw rows
	for i = displayStart, displayEnd do
		-- draw columns
		for j = 1, self.Columns do
			-- if the current items has focus...
			if i == self.FocusY and j == self.FocusX and
				self.CursorShow then
					-- draw the cursor
					self.Cursor:SetPosition(x + cursorHalfWidth, y)
					renderer:DrawSprite(self.Cursor)
			end

			local item = self.DataSource[itemIndex]
			self:RenderItem(renderer, x + cursorWidth, y, item)

			x = x + colWidth
			itemIndex = itemIndex + 1
		end

		y = y - rowHeight
		x = self.X
	end
end


-- draw each item in the selection menu
function Selection:RenderItem(renderer, x, y, item)
	if not item then
		-- draw empty slot
		renderer:DrawText2d(x, y, "---")
	else
		renderer:DrawText2d(x, y, item)
	end
end


-- handle user input
function Selection:HandleInput()
	if Keyboard.JustPressed(KEY_UP) then
		self:MoveUp()
	elseif Keyboard.JustPressed(KEY_DOWN) then
		self:MoveDown()
	elseif Keyboard.JustPressed(KEY_LEFT) then
		self:MoveLeft()
	elseif Keyboard.JustPressed(KEY_RIGHT) then
		self:MoveRight()
	elseif Keyboard.JustPressed(KEY_SPACE) then
		self:OnClick()
	end
end


-- move cursor up
function Selection:MoveUp()
	self.FocusY = math.max(self.FocusY - 1, 1)
	if self.FocusY < self.DisplayStart then
		self:MoveDisplayUp()
	end
end


-- move cursor down
function Selection:MoveDown()
	self.FocusY = math.min(self.FocusY + 1, self.MaxRows)
	if self.FocusY >= self.DisplayStart + self.DisplayRows then
		self:MoveDisplayDown()
	end
end


-- move left a column
function Selection:MoveLeft()
	self.FocusX = math.max(self.FocusX - 1, 1)
end


-- move right a column
function Selection:MoveRight()
	self.FocusX = math.min(self.FocusX + 1, self.Columns)
end


-- select the item highlighted
function Selection:OnClick()
	local index = self:GetIndex()
	self.OnSelection(index, self.DataSource[index])
end


-- move the items displayed up a row
function Selection:MoveDisplayUp()
	self.DisplayStart = self.DisplayStart - 1
end


-- move the items displayed down a row
function Selection:MoveDisplayDown()
	self.DisplayStart = self.DisplayStart + 1
end


-- get the index of the highlighted item
function Selection:GetIndex()
	return self.FocusX + ((self.FocusY - 1) * self.Columns)
end


-- get the width of the list
function Selection:GetWidth()
	return self.Width * self.Scale
end


-- get the height of a row
function Selection:GetHeight()
	return self.Height * self.Scale
end


-- if the RenderItem function is overwritten
-- this won't give the correct result
function Selection:CalcWidth(renderer)
	if self.Columns == 1 then
		local maxEntryWidth = 0

		for k, v in ipairs(self.DataSource) do
			local width = renderer:MeasureText(tostring(v)):X()
			maxEntryWidth = math.max(width, maxEntryWidth)
		end

		return maxEntryWidth + self.CursorWidth
	else
		return self.ColWidth * self.Columns
	end
end


function Selection:CalcHeight()
	local height = self.DisplayRows * self.SpacingY
	return height - self.SpacingY / 2
end


function Selection:ShowCursor()
	self.ShowCursor = true
end


function Selection:HideCursor()
	self.ShowCursor = false
end


function Selection:SetPosition(x, y)
	self.X = x
	self.Y = y
end


function Selection:PercentageShown()
	return self.DisplayRows / self.MaxRows
end


function Selection:PercentageScrolled()
	local onePercent = 1 / self.MaxRows
	local currentPecent = self.FocusY / self.MaxRows

	-- allows a 0 value to be returned
	if currentPercent <= onePercent then
		currentPercent = 0
	end
	
	return currentPercent
end


function Selection:SelectedItem()
	return self.DataSource[self:GetIndex()]
end