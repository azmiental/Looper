-- [tsx]: init.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 2
local React = ____DoraX.React -- 2
local toNode = ____DoraX.toNode -- 2
local ____Dora = require("Dora") -- 3
local Entity = ____Dora.Entity -- 3
local Frame = ____Dora.Frame -- 3
local Observer = ____Dora.Observer -- 3
local Vec2 = ____Dora.Vec2 -- 3
local tolua = ____Dora.tolua -- 3
local MapWidth = 10 -- 5
local MapHeight = 10 -- 6
local TileSize = 128 -- 7
local GroupHide = 0 -- 8
local GroupContact = 1 -- 9
local function colToWidth(col) -- 11
	return -MapWidth * TileSize / 2 + TileSize / 2 + TileSize * col -- 11
end -- 11
local function rowToHeight(row) -- 12
	return -MapHeight * TileSize / 2 + TileSize / 2 + TileSize * row -- 12
end -- 12
local tileShapes = {} -- 14
local count = 0 -- 15
for y = 0, MapHeight - 1 do -- 15
	for x = 0, MapWidth - 1 do -- 15
		tileShapes[#tileShapes + 1] = React.createElement( -- 18
			"rect-shape", -- 18
			{ -- 18
				centerX = rowToHeight(x), -- 18
				centerY = colToWidth(y), -- 18
				width = TileSize, -- 18
				height = TileSize, -- 18
				fillColor = count % 2 == y % 2 and 4282335039 or 4280229663 -- 18
			} -- 18
		) -- 18
		count = count + 1 -- 26
	end -- 26
end -- 26
local world = tolua.cast( -- 30
	toNode(React.createElement( -- 30
		"physics-world", -- 30
		{showDebug = true}, -- 30
		React.createElement( -- 30
			"body", -- 30
			{type = "Static", group = GroupContact}, -- 30
			React.createElement("rect-fixture", {centerY = MapHeight * TileSize / 2 + 5, width = MapWidth * TileSize, height = 10}), -- 30
			React.createElement("rect-fixture", {centerY = -MapHeight * TileSize / 2 - 5, width = MapWidth * TileSize, height = 10}), -- 30
			React.createElement("rect-fixture", {centerX = MapWidth * TileSize / 2 + 5, width = 10, height = MapHeight * TileSize}), -- 30
			React.createElement("rect-fixture", {centerX = -MapWidth * TileSize / 2 - 5, width = 10, height = MapHeight * TileSize}) -- 30
		), -- 30
		React.createElement("draw-node", nil, tileShapes) -- 30
	)), -- 30
	"PhysicsWorld" -- 40
) -- 40
if not world then -- 40
	error("failed to create world!") -- 43
end -- 43
world:setShouldContact(GroupContact, GroupContact, true) -- 46
world:setShouldContact(GroupContact, GroupHide, false) -- 47
world:setShouldContact(GroupHide, GroupHide, false) -- 48
Observer("Add", {"image", "x", "y"}):watch(function(entity, image, x, y) -- 50
	entity:set( -- 51
		"body", -- 51
		toNode(React.createElement( -- 51
			"body", -- 51
			{ -- 51
				type = "Dynamic", -- 51
				world = world, -- 51
				linearAcceleration = Vec2.zero, -- 51
				fixedRotation = true, -- 51
				x = colToWidth(x), -- 51
				y = rowToHeight(y), -- 51
				group = entity.contactFlag and GroupContact or GroupHide, -- 51
				linearDamping = 5 -- 51
			}, -- 51
			React.createElement("disk-fixture", {radius = TileSize / 2 - TileSize * 0.2}), -- 51
			React.createElement( -- 51
				"sprite", -- 51
				{width = TileSize, height = TileSize, filter = "Point"}, -- 51
				React.createElement( -- 51
					"loop", -- 51
					nil, -- 51
					React.createElement("frame", {time = 0.6, file = image .. ".clip|down-idle"}) -- 51
				) -- 51
			) -- 51
		)) -- 51
	) -- 51
	return false -- 66
end) -- 50
local Direction = Direction or ({}) -- 69
Direction.Up = 0 -- 69
Direction[Direction.Up] = "Up" -- 69
Direction.Down = 1 -- 69
Direction[Direction.Down] = "Down" -- 69
Direction.Left = 2 -- 69
Direction[Direction.Left] = "Left" -- 69
Direction.Right = 3 -- 69
Direction[Direction.Right] = "Right" -- 69
Observer("Add", { -- 71
	"body", -- 72
	"x", -- 73
	"y", -- 73
	"loopSpeed", -- 74
	"loopDir", -- 75
	"loopDistance" -- 76
}):watch(function(entity, body, x, y, loopSpeed, loopDir, loopDistance) -- 76
	local startPos = Vec2( -- 84
		colToWidth(x), -- 84
		rowToHeight(y) -- 84
	) -- 84
	local delta = 10 -- 85
	local forward = true -- 86
	local dir -- 87
	repeat -- 87
		local ____switch9 = loopDir -- 87
		local ____cond9 = ____switch9 == Direction.Down -- 87
		if ____cond9 then -- 87
			dir = Vec2(0, -1) -- 89
			break -- 89
		end -- 89
		____cond9 = ____cond9 or ____switch9 == Direction.Up -- 89
		if ____cond9 then -- 89
			dir = Vec2(0, 1) -- 90
			break -- 90
		end -- 90
		____cond9 = ____cond9 or ____switch9 == Direction.Left -- 90
		if ____cond9 then -- 90
			dir = Vec2(-1, 0) -- 91
			break -- 91
		end -- 91
		____cond9 = ____cond9 or ____switch9 == Direction.Right -- 91
		if ____cond9 then -- 91
			dir = Vec2(1, 0) -- 92
			break -- 92
		end -- 92
	until true -- 92
	local targetPos = startPos:add(dir:mul(loopDistance * TileSize)) -- 94
	local currentDir = nil -- 95
	body:schedule(function() -- 96
		local ____body_0 = body -- 97
		local position = ____body_0.position -- 97
		if forward then -- 97
			local dist = position:distance(targetPos) -- 99
			if dist < delta then -- 99
				forward = false -- 101
			end -- 101
		else -- 101
			local dist = position:distance(startPos) -- 104
			if dist < delta then -- 104
				forward = true -- 106
			end -- 106
		end -- 106
		if forward then -- 106
			body.velocity = targetPos:sub(position):normalize():mul(loopSpeed) -- 110
		else -- 110
			body.velocity = startPos:sub(position):normalize():mul(loopSpeed) -- 112
		end -- 112
		local ____tolua_cast_3 = tolua.cast -- 114
		local ____opt_1 = body.children -- 114
		local sprite = ____tolua_cast_3(____opt_1 and ____opt_1.first, "Sprite") -- 114
		if not sprite then -- 114
			return false -- 115
		end -- 115
		local angle = math.deg(body.velocity.angle) -- 116
		local vDir = Direction.Down -- 117
		if 45 <= angle and angle < 135 then -- 117
			vDir = Direction.Up -- 119
		elseif -45 <= angle and angle < 45 then -- 119
			vDir = Direction.Right -- 121
		elseif -135 <= angle and angle < -45 then -- 121
			vDir = Direction.Down -- 123
		elseif angle < -135 or angle >= 135 then -- 123
			vDir = Direction.Left -- 125
		end -- 125
		if currentDir ~= vDir then -- 125
			currentDir = vDir -- 128
			repeat -- 128
				local ____switch23 = vDir -- 128
				local ____cond23 = ____switch23 == Direction.Down -- 128
				if ____cond23 then -- 128
					sprite:perform( -- 131
						Frame( -- 131
							tostring(entity.image) .. ".clip|down-walk", -- 131
							0.6 -- 131
						), -- 131
						true -- 131
					) -- 131
					break -- 132
				end -- 132
				____cond23 = ____cond23 or ____switch23 == Direction.Up -- 132
				if ____cond23 then -- 132
					sprite:perform( -- 134
						Frame( -- 134
							tostring(entity.image) .. ".clip|up-walk", -- 134
							0.6 -- 134
						), -- 134
						true -- 134
					) -- 134
					break -- 135
				end -- 135
				____cond23 = ____cond23 or ____switch23 == Direction.Left -- 135
				if ____cond23 then -- 135
					sprite.scaleX = 1 -- 137
					sprite:perform( -- 138
						Frame( -- 138
							tostring(entity.image) .. ".clip|left-walk", -- 138
							0.6 -- 138
						), -- 138
						true -- 138
					) -- 138
					break -- 139
				end -- 139
				____cond23 = ____cond23 or ____switch23 == Direction.Right -- 139
				if ____cond23 then -- 139
					sprite.scaleX = -1 -- 141
					sprite:perform( -- 142
						Frame( -- 142
							tostring(entity.image) .. ".clip|left-walk", -- 142
							0.6 -- 142
						), -- 142
						true -- 142
					) -- 142
					break -- 143
				end -- 143
			until true -- 143
		end -- 143
		return false -- 146
	end) -- 96
	return false -- 148
end) -- 77
Entity({ -- 151
	image = "Vomfy1", -- 152
	x = 4, -- 153
	y = 4, -- 154
	contactFlag = true, -- 155
	loopSpeed = 200, -- 156
	loopDir = Direction.Right, -- 157
	loopDistance = 3 -- 158
}) -- 158
Entity({ -- 161
	image = "Vomfy2", -- 162
	x = 4, -- 163
	y = 3, -- 164
	contactFlag = true, -- 165
	loopSpeed = 200, -- 166
	loopDir = Direction.Up, -- 167
	loopDistance = 2 -- 168
}) -- 168
Entity({image = "Vomfy4", x = 4, y = 5, contactFlag = true}) -- 171
return ____exports -- 171