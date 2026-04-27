class_name EvaluationResults

@export var passed : bool = false
@export var mistakes : int = 0
@export var unsubmitted_documents : int = 0

@export var max_mistakes : int = 6
@export var max_unsubmitted_documents : int = 3

func setup(mistakes : int, unsubmitted_documents : int, max_mistakes: int, max_unsubmitted_documents: int) -> void:
	self.mistakes = mistakes
	self.unsubmitted_documents = unsubmitted_documents
	self.max_mistakes = max_mistakes
	self.max_unsubmitted_documents = max_unsubmitted_documents
