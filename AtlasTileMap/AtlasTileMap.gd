extends TileMap


func _on_AtlasArea_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	self.position.x += int(self.cell_quadrant_size * len(self.get_used_cells()) * 3)
