--[[

	Util.lua

	GenerateUV function

	generates UV coordinates from texture atlas to display
	correct tiles for map rendering

	Dustin Heyden
	Feb 9, 2023

]]

function GenerateUVs(tileWidth, tileHeight, texture)

	local uvs = {}

	local textureWidth = texture:GetWidth()
	local textureHeight = texture:GetHeight()
	local width = tileWidth / textureWidth
	local height = tileHeight / textureHeight
	local cols = textureWidth / tileWidth
	local rows = textureHeight / tileHeight

	local ux = 0
	local uy = 0
	local vx = width
	local vy = height

	for j = 0, rows - 1 do
		for i = 0, cols - 1 do

			table.insert(uvs, {ux,uy,vx,vy})

			-- advance the UVs to the next column
			ux = ux + width
			vx = vx + width
		end

		-- put the UVs back to the start of the next row

		ux = 0
		vx = width
		uy = uy + height
		vy = vy + height
	end

	return uvs
end



function Teleport(entity, map)
	local x, y = map:GetTileFoot(entity.TileX, entity.TileY)
	entity.Sprite:SetPosition(x, y + entity.Height / 2)
end