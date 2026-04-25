class_name SubmissionFolder

extends Folder

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func evaluate(docs_to_submit: Array[DocumentController]):
	var misstakes: int = 0
	misstakes += docs_to_submit.filter(func(doc): return doc not in documents).size()
	misstakes += documents.filter(func(doc): return doc not in docs_to_submit).size()
	for i in documents:
		var misstake_in_document = i.evaluate()
		misstakes += misstake_in_document
	
	return misstakes
