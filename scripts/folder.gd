class_name Folder

extends Control

@export var documents : Array[DocumentController] = []

func add(doc: DocumentController) -> void:
	documents.append(doc)

func add_docs(docs: Array[DocumentController]) -> void:
	documents = []
	for i in docs:
		documents.append(i)

func remove(doc: DocumentController) -> void:
	var index = documents.find(doc)
	documents.remove_at(index)
