class_name InventorySlot
extends CenterContainer

@export var mainRect: Control;

var rectSize: int;
var borderWidth: int;

@export var hoverColor : Color = Color(Color.YELLOW, 0.8);
@export var takenColor : Color = Color(Color.RED, 0.2);
@export var openColor : Color = Color(Color.GREEN, 0.2);

var currentState: GlobalEnums.SlotState;
var mouseHovering = false; 

var containedItem: Node = null; 

signal mouseEnteredSlot(slot: InventorySlot)
signal mouseExitedSlot(slot: InventorySlot)

signal attemptItemPickup(slot: InventorySlot)

func _ready() -> void:	
	if mainRect == null: 
		mainRect = $inventorySlot_Rect;
		
	setSize(rectSize);
	currentState = GlobalEnums.SlotState.DEFAULT; 
	updateSlotColor(GlobalEnums.SlotState.DEFAULT);

func _process(delta: float) -> void:
	# If the mouse is hovering over the slot, send out the
	# mouse is on the slot signal 
	if (get_global_rect().has_point((get_global_mouse_position()))):
		if mouseHovering == false: 
			mouseHovering = true; 
			emit_signal("mouseEnteredSlot", self)
			
	# Once the mouse leaves, fire the exit signal
	else : 
		if mouseHovering == true: 
			mouseHovering = false; 
			emit_signal("mouseExitedSlot", self)
		
#Adjusts the size of the rectangle to match the slot size
func setSize(size):
	custom_minimum_size = Vector2(size, size);
	mainRect.custom_minimum_size = Vector2(size, size);

#Updates the color of the slot based on its state
func updateSlotColor(state: GlobalEnums.SlotState): 
	match state: 
		GlobalEnums.SlotState.DEFAULT: 
			mainRect.modulate = Color.WHITE;
		GlobalEnums.SlotState.EMPTY: 
			mainRect.modulate = openColor;
		GlobalEnums.SlotState.TAKEN: 
			mainRect.modulate = takenColor; 
		GlobalEnums.SlotState.HOVERED: 
			mainRect.modulate = hoverColor; 

#Adds an item to be contained by the slot
func addItem(item: InventoryItem):
	containedItem = item; 
	
#Removes a contained item from the slot
func removeItem():
	containedItem = null; 
