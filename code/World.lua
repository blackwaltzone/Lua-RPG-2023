--[[

	World.lua

	Tracks all items the party picks up, amount of gold, and amount
	of time passed.
	Will also track quests and current party members
	Load/save


	Dustin Heyden

	07 May, 2023

]]


World = {}
World.__index = World

function World:Create()

	local this =
	{
		Time = 0,
		Gold = 0,
		Items =
		{
			{ id = 3, count = 1},
		},
		KeyItems = {},
	}

	setmetatable(this, self)

	return this
end


-- update function
function World:Update(dt)
	self.Time = self.Time + dt
end


-- convert the time passed integer to a string
function World:TimeAsString()
	local time = self.Time
	local hours = math.floor(time / 3600)
	local minutes = math.floor((time % 3600) / 60)
	local seconds = time % 60

	return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end


-- convert gold integer to a string
function World:GoldAsString()
	return string.format("%d", self.Gold)
end


-- add item to database
-- iterate though table to see if we already have item
-- increment amount by count, or add item (if not found)
-- if no count, defaults to 1
function World:AddItem(itemID, count)

	-- default count is 1
	count = count or 1

	assert(ItemDB[itemID].type ~= "key")

	-- 1. does it already exist?
	for k, v in ipairs(self.Items) do
		if v.id == itemID then
			-- 2. yes it does, increment, and exit
			v.count = v.count + count
			return
		end
	end

	-- 3. no it does not
	--    add it as a new item
	table.insert(self.Items,
	{
		id = itemID,
		count = count,
	})
end


-- remove item
-- takes in an item ID and optional amount to remove
-- by default, amount to remove is 1
-- iterates through table until item found
-- if count is then zero, item removed from table
function World:RemoveItem(itemID, amount)

	-- check if item exists
	assert(ItemDB[itemID].type ~= "key")
	amount = amount or 1

	for i = #self.Items, 1, -1 do
		local v = self.Items[i]
		if v.id == itemID then
			v.count = v.count - amount
			assert(v.count >= 0)		-- this should never happen
			if v.count == 0 then
				table.remove(self.Items, i)
			end

			return
		end
	end

	assert(false)	-- shouldn't ever get here
end


-- handle key items

-- see if we have a key item
function World:HasKey(itemID)
	-- loop through all items
	for k, v in ipairs(self.KeyItems) do
		-- check if has keyitem by looking at itemID
		if v.id == itemID then
			-- have  it
			return true
		end
	end
	-- don't have it
	return false
end


-- remove an item
function World:RemoveKey(itemID)
	-- search list of key items
	for i = #self.KeyItems, 1, -1, do
		local v = self.KeyItems[i]

		-- check if itemID exists in keyitem
		if v.id == itemID then
			-- remove it
			table.remove(self.KeyItems, i)
			return
		end
	end
	assert(false)		-- should never get here
end


-- Draw key item
function World:DrawKey(menu, renderer, x, y, item)
	if item then
		local itemDef = ItemDB[item.id]
		renderer:AlignText("left", "center")
		renderer:DrawText2d(x, y, itemDef.name)
	else
		renderer:AlignText("center", "center")
		renderer:DrawText2d(x + menu.SpacingX/2, y, " - ")
	end
end


-- draw regular item
function World:DrawItem(menu, renderer, x, y, item)
	if item then
		local itemDef = ItemDB[item.id]
		local iconSprite = Icons:Get(itemDef.type)
		if iconSprite then
			iconSprite:SetPosition(x + 6, y)
			renderer:DrawSprite(iconSprite)
		end

		renderer:AlignText("left", "center")
		renderer:DrawText2d(x + 18, y, itemDef.name)

		local right = x + menu.SpacingX - 64

		renderer:AlignText("right", "center")
		renderer:DrawText2d(right, y, string.format(":%02d", item.count))
	else
		renderer:AlignText("center", "center")
		renderer:DrawText2d(x + menu.SpacingX/2, y, " - ")
	end
end