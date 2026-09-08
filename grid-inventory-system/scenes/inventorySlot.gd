class_name InventorySlot
extends ColorRect

@onready var innerRect: ColorRect = $inventorySlot_InnerRect; 

var rectSize: int;
var borderWidth: int; 

func _ready() -> void:
	setSize(rectSize, borderWidth);

func setSize(size, borderWidth):
	custom_minimum_size = Vector2(size, size);
	
	var innerRectSize = size - (2 * borderWidth); 
	innerRect.custom_minimum_size = Vector2(innerRectSize, innerRectSize);
	
	innerRect.offset_left = borderWidth
	innerRect.offset_top = borderWidth
	innerRect.offset_right = -borderWidth
	innerRect.offset_bottom = -borderWidth
