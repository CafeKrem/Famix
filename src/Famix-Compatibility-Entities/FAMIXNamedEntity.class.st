Class {
	#name : #FAMIXNamedEntity,
	#superclass : #FAMIXSourcedEntity,
	#traits : 'FamixTCanBeAbstract + FamixTCanBeFinal + FamixTHasVisibility + FamixTInvocationsReceiver + FamixTNamedEntity + FamixTPackageable + FamixTWithAnnotationInstances',
	#classTraits : 'FamixTCanBeAbstract classTrait + FamixTCanBeFinal classTrait + FamixTHasVisibility classTrait + FamixTInvocationsReceiver classTrait + FamixTNamedEntity classTrait + FamixTPackageable classTrait + FamixTWithAnnotationInstances classTrait',
	#category : #'Famix-Compatibility-Entities-Entities'
}

{ #category : #meta }
FAMIXNamedEntity class >> annotation [

	<FMClass: #NamedEntity super: #FAMIXSourcedEntity>
	<package: #FAMIX>
	<generated>
	^self
]

{ #category : #'Moose-Query-Extensions' }
FAMIXNamedEntity class >> belongsToMethod [
	^ self compiledMethodAt: #belongsTo ifAbsent: nil
]

{ #category : #'Famix-Extensions' }
FAMIXNamedEntity >> stubFormattedName [
	 ^ self isStub 
		ifTrue: [ Text 
					string: self name
					attribute: TextEmphasis italic ]
		ifFalse: [ Text fromString: self name ] 
]
