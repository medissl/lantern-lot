extends Node2D

var yard: bool = false
const INK := Color("172829")
const WOOD := Color("ad784b")
const GOLD := Color("e4b866")
const MINT := Color("8ab8aa")

func _draw() -> void:
	draw_rect(Rect2(0, 0, 180, 108), INK)
	# Original procedural placeholder diorama, independent of concealed values.
	if yard:
		draw_rect(Rect2(10, 12, 160, 75), Color("3e5557"))
		draw_rect(Rect2(15, 17, 150, 67), Color("223637"))
		for x in range(15, 165, 12):
			draw_line(Vector2(x, 17), Vector2(x, 83), Color("2c4242"))
		draw_rect(Rect2(8, 82, 164, 6), WOOD)
		draw_rect(Rect2(8, 10, 164, 6), WOOD)
		kettle(Vector2(32, 42))
		stool(Vector2(79, 45))
		fan(Vector2(130, 34))
		for x in [28, 77, 123]:
			draw_rect(Rect2(x, 67, 30, 19), Color("735b46"))
			draw_rect(Rect2(x + 2, 69, 26, 15), Color("aa875b"))
			draw_line(Vector2(x + 15, 69), Vector2(x + 15, 84), GOLD, 2)
	else:
		draw_rect(Rect2(14, 10, 152, 70), Color("49615b"))
		for x in range(14, 170, 19):
			draw_line(Vector2(x, 80), Vector2(x - 22, 106), Color("3b4a43"), 1)
		for y in [81, 92, 104]:
			draw_line(Vector2(0, y), Vector2(180, y), Color("3b4a43"), 1)
		for x in [23, 115]:
			draw_rect(Rect2(x, 27, 42, 47), WOOD)
			for y in [31, 48, 65]:
				draw_rect(Rect2(x + 3, y, 36, 12), Color("2d403a"))
			draw_rect(Rect2(x + 8, 33, 8, 10), MINT)
			draw_rect(Rect2(x + 22, 35, 9, 8), GOLD)
			draw_rect(Rect2(x + 9, 51, 12, 8), Color("c58062"))
		kettle(Vector2(128, 54))
		draw_rect(Rect2(57, 77, 65, 23), Color("6d4e36"))
		draw_rect(Rect2(53, 75, 73, 7), WOOD)
		draw_rect(Rect2(64, 67, 13, 8), INK)
		draw_rect(Rect2(66, 69, 9, 4), GOLD)
		# Protected walkway remains clear in this non-editable prototype.
		draw_rect(Rect2(82, 29, 18, 36), Color("263c37"))
	for x in [16, 163]:
		draw_line(Vector2(x, 0), Vector2(x, 15), WOOD)
		draw_rect(Rect2(x - 4, 15, 9, 13), GOLD)
		draw_rect(Rect2(x - 2, 17, 5, 9), Color("f3d695"))

func kettle(origin: Vector2) -> void:
	draw_rect(Rect2(origin + Vector2(0, 5), Vector2(15, 12)), MINT)
	draw_rect(Rect2(origin + Vector2(2, 2), Vector2(11, 3)), GOLD)
	draw_rect(Rect2(origin + Vector2(15, 6), Vector2(5, 4)), MINT)
	draw_rect(Rect2(origin + Vector2(-4, 5), Vector2(4, 9)), WOOD)
	draw_rect(Rect2(origin + Vector2(-2, 7), Vector2(2, 5)), INK)

func stool(origin: Vector2) -> void:
	draw_rect(Rect2(origin, Vector2(23, 5)), WOOD)
	draw_line(origin + Vector2(3, 5), origin + Vector2(18, 22), GOLD, 3)
	draw_line(origin + Vector2(20, 5), origin + Vector2(5, 22), GOLD, 3)

func fan(origin: Vector2) -> void:
	draw_circle(origin + Vector2(10, 10), 11, WOOD)
	draw_circle(origin + Vector2(10, 10), 9, MINT)
	draw_line(origin + Vector2(2, 10), origin + Vector2(18, 10), INK, 2)
	draw_line(origin + Vector2(10, 2), origin + Vector2(10, 18), INK, 2)
	draw_rect(Rect2(origin + Vector2(9, 21), Vector2(3, 9)), WOOD)
	draw_rect(Rect2(origin + Vector2(3, 29), Vector2(16, 3)), WOOD)
