--[[

	ItemDB.lua

	Lua table containing item definitions database


	Key Item = special item, usually required to progress
	Weapon = Item that can be equipped, special damage properties
	Armor = Item that can be equipped, special damage reduction properties
	Accessory = Item that  can be equipped, special properties
	Usable = Item that can be used during combat / world map


	Str = strength
	Spd = speed
	Int = intelligence
	Att = attack
	Def = defense
	Mag = magic
	Res = resist magic


	Dustin Heyden

	07, May 2023
	
]]

ItemDB =
{
	[-1] =
	{
		name = "",
		description = "",
		special = "",
		stats =
		{
			strength = 0,
			speed = 0,
			intelligence = 0,
			attack = 0,
			defense = 0
			magic = 0,
			resist = 0
		}
	},
	{
		name = "Mysterious Torque",
		type = "accessory",
		description = "A golden torque that giltters.",
		stats =
		{
			strength = 10,
			speed = 10,
		}
	},
	{
		name = "Heal Potion",
		type = "useable",
		description = "Heals a little HP.",
	},
	{
		name = "Bronze Sword",
		type = "weapon",
		description = "A short sword with a dull blade.",
		stats =
		{
			attack = 10,
		}
	},
	{
		name = "Old bone",
		type = "key",
		description = "A calcified human femur",
	},
}

-- empty item
EmptyItem = ItemDB[-1]


-- see if the item has any stats
local function DoesItemHaveStats(item)
	return item.type == "weapon" or
			item.type == "armor" or
			item.type == "accessory"
end


-- if any stat is missing, add it and set it to
-- the value in EmptyItem
-- if you need to add a new stat class,
-- need to add it to EmptyItem and it will get automatically
-- filled in for every other item
for k, v in ipairs(ItemDB) do
	-- see if the item even has stats to add
	if DoesHaveItemStats(v) then
		local stats = v.stats
		-- loop through each stat of an empty item,
		-- then add stats or empty stat
		for k, v in ipairs(EmptyItem) do
			stats[key] = stats[key] or v.stats
		end
	end
end