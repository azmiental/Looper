// @preview-file on
import { React, toNode } from 'DoraX';
import { Body, BodyMoveType, Entity, EntityEvent, Frame, Observer, TextureFilter, TypeName, Vec2, tolua } from 'Dora';

const MapWidth = 10;
const MapHeight = 10;
const TileSize = 128;
const GroupHide = 0;
const GroupContact = 1;

const colToWidth = (col: number) => -MapWidth * TileSize / 2 + TileSize / 2 + TileSize * col;
const rowToHeight = (row: number) => -MapHeight * TileSize / 2 + TileSize / 2 + TileSize * row;

const tileShapes = [];
let count = 0;
for (let y of $range(0, MapHeight - 1)) {
	for (let x of $range(0, MapWidth - 1)) {
		tileShapes.push(
			<rect-shape
				centerX={rowToHeight(x)}
				centerY={colToWidth(y)}
				width={TileSize} height={TileSize}
				fillColor={count % 2 === y % 2 ? 0xff3f3f3f : 0xff1f1f1f}
			/>
		);
		count++;
	}
}

const world = tolua.cast(toNode(
	<physics-world showDebug>
		<body type={BodyMoveType.Static} group={GroupContact}>
			<rect-fixture centerY={MapHeight * TileSize / 2 + 5} width={MapWidth * TileSize} height={10}/>
			<rect-fixture centerY={-MapHeight * TileSize / 2 - 5} width={MapWidth * TileSize} height={10}/>
			<rect-fixture centerX={MapWidth * TileSize / 2 + 5} width={10} height={MapHeight * TileSize}/>
			<rect-fixture centerX={-MapWidth * TileSize / 2 - 5} width={10} height={MapHeight * TileSize}/>
		</body>
		<draw-node>{tileShapes}</draw-node>
	</physics-world>
), TypeName.PhysicsWorld);

if (!world) {
	error("failed to create world!");
}

world.setShouldContact(GroupContact, GroupContact, true);
world.setShouldContact(GroupContact, GroupHide, false);
world.setShouldContact(GroupHide, GroupHide, false);

Observer(EntityEvent.Add, ['image', 'x', 'y']).watch((entity, image: string, x: number, y: number) => {
	entity.set('body', toNode(
		<body type={BodyMoveType.Dynamic} world={world}
			linearAcceleration={Vec2.zero} fixedRotation
			x={colToWidth(x)} y={rowToHeight(y)}
			group={entity.contactFlag ? GroupContact : GroupHide}
			linearDamping={5}
		>
			<disk-fixture radius={TileSize / 2 - TileSize * 0.2}/>
			<sprite width={TileSize} height={TileSize} filter={TextureFilter.Point}>
				<loop>
					<frame time={0.6} file={`${image}.clip|down-idle`}/>
				</loop>
			</sprite>
		</body>
	));
	return false;
});

enum Direction {Up, Down, Left, Right};

Observer(EntityEvent.Add, [
	'body',
	'x', 'y',
	'loopSpeed',
	'loopDir',
	'loopDistance'
]).watch((entity,
	body: Body.Type,
	x: number, y: number,
	loopSpeed: number,
	loopDir: Direction,
	loopDistance: number
) => {
	const startPos = Vec2(colToWidth(x), rowToHeight(y));
	const delta = 10;
	let forward = true;
	let dir: Vec2.Type;
	switch (loopDir) {
		case Direction.Down: dir = Vec2(0, -1); break
		case Direction.Up: dir = Vec2(0, 1); break
		case Direction.Left: dir = Vec2(-1, 0); break
		case Direction.Right: dir = Vec2(1, 0); break
	}
	const targetPos = startPos.add(dir.mul(loopDistance * TileSize));
	let currentDir: Direction | undefined = undefined;
	body.schedule(() => {
		const {position} = body;
		if (forward) {
			const dist = position.distance(targetPos);
			if (dist < delta) {
				forward = false;
			}
		} else {
			const dist = position.distance(startPos);
			if (dist < delta) {
				forward = true;
			}
		}
		if (forward) {
			body.velocity = targetPos.sub(position).normalize().mul(loopSpeed);
		} else {
			body.velocity = startPos.sub(position).normalize().mul(loopSpeed);
		}
		const sprite = tolua.cast(body.children?.first, TypeName.Sprite);
		if (!sprite) return false;
		const angle = math.deg(body.velocity.angle);
		let vDir: Direction = Direction.Down;
		if (45 <= angle && angle < 135) {
			vDir = Direction.Up;
		} else if (-45 <= angle && angle < 45) {
			vDir = Direction.Right;
		} else if (-135 <= angle && angle < -45) {
			vDir = Direction.Down;
		} else if (angle < -135 || angle >= 135) {
			vDir = Direction.Left;
		}
		if (currentDir !== vDir) {
			currentDir = vDir;
			switch (vDir) {
				case Direction.Down:
					sprite.perform(Frame(`${entity.image}.clip|down-walk`, 0.6), true);
					break;
				case Direction.Up:
					sprite.perform(Frame(`${entity.image}.clip|up-walk`, 0.6), true);
					break;
				case Direction.Left:
					sprite.scaleX = 1;
					sprite.perform(Frame(`${entity.image}.clip|left-walk`, 0.6), true);
					break;
				case Direction.Right:
					sprite.scaleX = -1;
					sprite.perform(Frame(`${entity.image}.clip|left-walk`, 0.6), true);
					break;
			}
		}
		return false;
	});
	return false;
});

Entity({
	image: 'Vomfy1',
	x: 4,
	y: 4,
	contactFlag: true,
	loopSpeed: 200,
	loopDir: Direction.Right,
	loopDistance: 3,
});

Entity({
	image: 'Vomfy2',
	x: 4,
	y: 3,
	contactFlag: true,
	loopSpeed: 200,
	loopDir: Direction.Up,
	loopDistance: 2,
});

Entity({
	image: 'Vomfy4',
	x: 4,
	y: 5,
	contactFlag: true,
});