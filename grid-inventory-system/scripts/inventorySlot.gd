class_name InventorySlot
extends CenterContainer

const GlobalEnums = preload("res://scripts/globalEnums.gd");

@onready var mainRect: ColorRect = $inventorySlot_Rect;
@onready var innerRect: ColorRect = $inventorySlot_Rect/inventorySlot_InnerRect; 


var rectSize: int;
var borderWidth: int;

var currentState: GlobalEnums.SlotState;
var mouseHovering = false; 

var containedItem: Node = null; 

signal mouseEnteredSlot(slot: Node)
signal mouseExitedSlot(slot: Node)

signal attemptItemPickup(slot: Node)

func _ready() -> void:	
	setSize(rectSize, borderWidth);
	currentState = GlobalEnums.SlotState.DEFAULT; 
	updateSlotColor(GlobalEnums.SlotState.DEFAULT);

func _process(delta: float) -> void:
	# If the mouse is hovering over the slot, send out the
	# mouse is on the slot signal 
	if (get_global_rect().has_point((get_global_mouse_position()))):
		if mouseHovering == false: 
			mouseHovering = true; 
			emit_signal("mouseEnteredSlot", self)
		if Input.is_action_just_pressed("LMB"):
			if containedItem != null:
				if containedItem.isSelected == false && containedItem.isMovingToGrid == false:
					#print("Sending attempt pickup...");
					emit_signal("attemptItemPickup", self)
					pass;
	# Once the mouse leaves, fire the exit signal
	else : 
		if mouseHovering == true: 
			mouseHovering = false; 
			emit_signal("mouseExitedSlot", self)
		
	
func setSize(size, borderWidth):
	custom_minimum_size = Vector2(size, size);
	mainRect.custom_minimum_size = Vector2(size, size);
	
	var innerRectSize = size - (2 * borderWidth); 
	innerRect.custom_minimum_size = Vector2(innerRectSize, innerRectSize);
	
	innerRect.offset_left = borderWidth
	innerRect.offset_top = borderWidth
	innerRect.offset_right = -borderWidth
	innerRect.offset_bottom = -borderWidth

func updateSlotColor(state: GlobalEnums.SlotState): 
	match state: 
		GlobalEnums.SlotState.DEFAULT: 
			mainRect.color = Color(Color.DIM_GRAY, 0.2);
		GlobalEnums.SlotState.EMPTY: 
			mainRect.color = Color(Color.GREEN, 0.2);
		GlobalEnums.SlotState.TAKEN: 
			mainRect.color = Color(Color.RED, 0.2);
		GlobalEnums.SlotState.HOVERED: 
			mainRect.color = Color(Color.YELLOW, 0.2);
		
func addItem(item: Node):
	containedItem = item; 
	print("New item: " + str(containedItem));
	
func removeItem():
	containedItem = null; 
	print("Item cleared from slot!");
