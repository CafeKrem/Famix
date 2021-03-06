Class {
	#name : #FamixJavaNamespace,
	#superclass : #FamixJavaContainerEntity,
	#traits : 'FamixTNamespace + FamixTWithGlobalVariables',
	#classTraits : 'FamixTNamespace classTrait + FamixTWithGlobalVariables classTrait',
	#instVars : [
		'#childNamespaces => FMMany type: #FamixJavaNamespace opposite: #parentNamespace',
		'#parentNamespace => FMOne type: #FamixJavaNamespace opposite: #childNamespaces'
	],
	#category : #'Famix-Java-Entities-Entities'
}

{ #category : #meta }
FamixJavaNamespace class >> annotation [

	<FMClass: #Namespace super: #FamixJavaContainerEntity>
	<package: #'Famix-Java-Entities'>
	<generated>
	^self
]

{ #category : #'Famix-Extensions-metrics' }
FamixJavaNamespace >> abstractness [
	"Abstractness is the ratio between the number of abstract classes and the total number of classes in a package, in the range [0, 1]. 0 means the package is fully concrete, 1 it is fully abstract."

	<FMProperty: #abstractness type: #Number>
	<derived>
	<FMComment: 'Abstractness of a namespace'>
	| nsClasses |
	nsClasses := self allClasses.
	nsClasses size == 0 ifTrue: [ ^ nil ].

	^ (nsClasses select: [ :c | c isAbstract ]) size / nsClasses size asFloat
]

{ #category : #'Famix-Extensions-metrics' }
FamixJavaNamespace >> abstractness: aNumber [
	self cacheAt: #abstractness put: aNumber
]

{ #category : #adding }
FamixJavaNamespace >> addChildNamespace: anObject [
	<generated>
	^ self childNamespaces add: anObject
]

{ #category : #'Famix-Extensions-metrics' }
FamixJavaNamespace >> afferentCoupling [
	<FMProperty: #afferentCoupling type: #Number>
	<derived>
	<FMComment: 'Afferent Coupling of a namespace Afferent is the number of classes that depend upon this namespace'>
	^ ((self queryAllIncoming atScope: FamixTType) outOfParentUsing: FamixTNamespace) size
]

{ #category : #'Famix-Extensions-metrics' }
FamixJavaNamespace >> afferentCoupling: aNumber [
	self cacheAt: #afferentCoupling put: aNumber
]

{ #category : #accessing }
FamixJavaNamespace >> allClasses [
	| result |
	result := OrderedCollection new.
	self withAllChildScopesDo: [ :each | result addAll: each classes ].
	^ result
]

{ #category : #accessing }
FamixJavaNamespace >> allClassesGroup [
	<navigation: 'All classes'>
	^ FamixTypeGroup withAll: self allClasses withDescription: 'All classes from ', self printString
]

{ #category : #'Famix-Extensions' }
FamixJavaNamespace >> allParentsUpTo: aNamespace [
	(self parentScope isNil or: [self parentScope = aNamespace ]) ifTrue: [ ^ OrderedCollection new ].
	^ self parentScope withAllParentsUpTo: aNamespace
]

{ #category : #'Famix-Extensions-metrics' }
FamixJavaNamespace >> bunchCohesion [
	"Computing cohesion (Bunch formula)"

	<FMProperty: #bunchCohesion type: #Number>
	<derived>
	<FMComment: 'Bunch Cohesion of a namespace. It is also considered anonymous and inner classes.'>
	| myClasses intraConnectivities |
	(myClasses := self classes) union: (myClasses flatCollect: [ :c | c allRecursiveTypes ]).
	myClasses size == 0
		ifTrue: [ ^ nil ].
	intraConnectivities := (myClasses collect: [ :c | (c queryAllOutgoing atScope: FamixTType) withinParentUsing: FamixTNamespace ]) inject: 0 into: [ :subTotal :each | subTotal + each size ].
	^ intraConnectivities / myClasses size squared asFloat
]

{ #category : #'Famix-Extensions-metrics' }
FamixJavaNamespace >> bunchCohesion: aNumber [
	self cacheAt: #bunchCohesion put: aNumber
]

{ #category : #'Famix-Extensions-metrics' }
FamixJavaNamespace >> bunchCouplingWith: aNamespace [
	"Computing coupling (Bunch formula) between receiver and aNamespace"

	| myClasses otherClasses interConnectivities |
	myClasses := self classes.
	myClasses := myClasses union: (myClasses flatCollect: [ :c | c allRecursiveTypes ]).
	otherClasses := aNamespace classes.
	otherClasses := otherClasses union: (otherClasses flatCollect: [ :c | c allRecursiveTypes ]).
	(myClasses size == 0 or: [ otherClasses size == 0 ])
		ifTrue: [ ^ nil ].

	"All outgoing dependencies"
	interConnectivities := (myClasses collect: [ :c | (c queryAllOutgoing atScope: FamixTType) within: aNamespace ]) inject: 0 into: [ :subTotal :each | subTotal + each size ].

	"Plus all incoming dependencies"
	interConnectivities := interConnectivities
		+ ((myClasses collect: [ :c | (c queryAllIncoming atScope: FamixTType) within: aNamespace ]) inject: 0 into: [ :subTotal :each | subTotal + each size ]).
	^ interConnectivities / (2 * myClasses size * otherClasses size) asFloat
]

{ #category : #'Famix-Extensions-metrics' }
FamixJavaNamespace >> bunchCouplingWithAll [
	"Computing coupling (Bunch formula) between receiver and all namespaces"

	| myClasses interConnectivities allClasses |
	myClasses := self classes.
	myClasses := myClasses union: (myClasses flatCollect: [ :c | c allRecursiveTypes ]).
	allClasses := self mooseModel allModelNamespaces flatCollect: [ :aNamespace | aNamespace classes ].
	allClasses := allClasses union: (allClasses flatCollect: [ :aClass | aClass allRecursiveTypes ]).
	(myClasses isEmpty or: [ allClasses isEmpty ]) ifTrue: [ ^ nil ].

	"All outgoing dependencies"
	interConnectivities := (myClasses collect: [ :c | (c queryAllOutgoing atScope: FamixTType) outOfParentUsing: FamixTNamespace ]) inject: 0 into: [ :subTotal :each | subTotal + each size ].

	"Plus all incoming dependencies"
	interConnectivities := interConnectivities
		+ ((myClasses collect: [ :c | (c queryAllIncoming atScope: FamixTType) outOfParentUsing: FamixTNamespace ]) inject: 0 into: [ :subTotal :each | subTotal + each size ]).
	^ interConnectivities / (2 * myClasses size * (allClasses size - myClasses size)) asFloat
]

{ #category : #accessing }
FamixJavaNamespace >> childNamespaces [
	"Relation named: #childNamespaces type: #FamixJavaNamespace opposite: #parentNamespace"

	<generated>
	<FMComment: 'Namespaces embedded in this namespace, if any.'>
	<derived>
	^ childNamespaces
]

{ #category : #accessing }
FamixJavaNamespace >> childNamespaces: anObject [

	<generated>
	childNamespaces value: anObject
]

{ #category : #'Famix-Extensions-accessing' }
FamixJavaNamespace >> containedEntities [
	^self types
]

{ #category : #'Famix-Extensions-accessing' }
FamixJavaNamespace >> containedEntities: collection [
	self types: collection.
]

{ #category : #'Famix-Extensions-metrics' }
FamixJavaNamespace >> distance [
	"D = A + I - 1. A package should be balanced between abstractness and instability, i.e., somewhere between abstract and stable or concrete and unstable. This rule defines the main sequence by the equation A + I - 1 = 0. D is the distance to the main sequence."
	<FMProperty: #distance type: #Number>
	<derived>
	<FMComment: 'Distance of a namespace'>

	| abstractness instability |
	abstractness := self abstractness.
	instability := self instability.
	
	(abstractness isNil or: [instability isNil]) ifTrue: [^ nil].
	^ abstractness + instability - 1
]

{ #category : #accessing }
FamixJavaNamespace >> distance: aNumber [
	self cacheAt: #distance put: aNumber
]

{ #category : #'Famix-Extensions-metrics' }
FamixJavaNamespace >> efferentCoupling [
	"Efferent coupling for a module is the number of classes it depends upon"

	<FMProperty: #efferentCoupling type: #Number>
	<derived>
	<FMComment: 'Efferent coupling for a module is the number of classes it depends upon'>
	^ ((self queryAllOutgoing outOfParentUsing: FamixTNamespace) atScope: FamixTType) size
]

{ #category : #'Famix-Extensions-metrics' }
FamixJavaNamespace >> efferentCoupling: aNumber [
	self cacheAt: #efferentCoupling put: aNumber
]

{ #category : #'Famix-Extensions-metrics' }
FamixJavaNamespace >> instability [
	"I =	Ce(P)/(Ce(P)+Ca(P)), in the range [0, 1]. 0 means package is maximally stable (i.e., no dependency to other packages and can not change without big consequences), 1 means it is unstable."
	<FMProperty: #instability type: #Number>
	<derived>
	<FMComment: 'Instability of a namespace'>
	
	| efferentCoupling afferentCoupling |
	
	efferentCoupling := self efferentCoupling.
	afferentCoupling := self afferentCoupling.
	(efferentCoupling + afferentCoupling) == 0 ifTrue: [^ nil].
	^ efferentCoupling / (efferentCoupling + afferentCoupling) asFloat
]

{ #category : #'Famix-Extensions-metrics' }
FamixJavaNamespace >> instability: aNumber [
	self cacheAt: #instability put: aNumber
]

{ #category : #'Famix-Extensions-metrics' }
FamixJavaNamespace >> martinCohesion [
	"Computing cohesion as described by Robert C. Martin"

	<FMProperty: #martinCohesion type: #Number>
	<derived>
	<FMComment: 'Cohesion as defined by Robert C. Martin.'>
	| intraConnectivities myClasses |
	myClasses := self classes.
	myClasses := myClasses union: (myClasses flatCollect: [ :c | c allRecursiveTypes ]).
	myClasses size == 0 ifTrue: [ ^ nil ].
	intraConnectivities := (myClasses collect: [ :c | (c queryAllOutgoing atScope: FamixTType) withoutSelfLoops withinParentUsing: FamixTNamespace ]) inject: 0 into: [ :subTotal :each | subTotal + each size ].
	^ ((intraConnectivities + 1) / myClasses size) asFloat
]

{ #category : #printing }
FamixJavaNamespace >> mooseNameOn: aStream [ 
	| parent |
	parent := self belongsTo.
	parent ifNotNil: 
		[ parent mooseNameOn: aStream.
		aStream
			nextPut: $:;
			nextPut: $: ].
	self name ifNotNil: [aStream nextPutAll: self name]
]

{ #category : #'Famix-Extensions' }
FamixJavaNamespace >> numberOfAttributes [
"	<property: #NOA longName: 'Number of attributes' description:
			'The number of attributes in a namespace'>"

	<FMProperty: #numberOfAttributes type: #Number>
	<derived>
	<FMComment: 'The number of attributes in a namespace'>
	
	^ self
		lookUpPropertyNamed: #numberOfAttributes
		computedAs: [self types inject: 0 into: [ :sum :each | sum + each numberOfAttributes] ]
]

{ #category : #'Famix-Extensions' }
FamixJavaNamespace >> numberOfAttributes: aNumber [
	self cacheAt: #numberOfAttributes put: aNumber
]

{ #category : #'Famix-Extensions' }
FamixJavaNamespace >> numberOfClasses: aNumber [
	self cacheAt: #numberOfClasses put: aNumber
]

{ #category : #accessing }
FamixJavaNamespace >> numberOfMethods [
	<FMProperty: #numberOfMethods type: #Number>
	<derived>
	<FMComment: 'The number of methods in a namespace'>
	
	^self
		lookUpPropertyNamed: #numberOfMethods
		computedAs: [self types inject: 0 into: [ :sum :each | sum + each numberOfMethods ]]
]

{ #category : #accessing }
FamixJavaNamespace >> numberOfMethods: aNumber [
	self cacheAt: #numberOfMethods put: aNumber
]

{ #category : #'Famix-Extensions-metrics' }
FamixJavaNamespace >> numberOfNonInterfacesClasses [
	<FMProperty: #numberOfNonInterfacesClasses type: #Number>
	<derived>
	<FMComment: 'The number of non interfaces classes in a namespace'>
	
	^self
		lookUpPropertyNamed: #numberOfNonInterfacesClasses
		computedAs: [(self types reject: #isInterface) size]
]

{ #category : #'Famix-Extensions-metrics' }
FamixJavaNamespace >> numberOfNonInterfacesClasses: aNumber [
	self cacheAt: #numberOfNonInterfacesClasses put: aNumber
]

{ #category : #accessing }
FamixJavaNamespace >> parentNamespace [
	"Relation named: #parentNamespace type: #FamixJavaNamespace opposite: #childNamespaces"

	<generated>
	<FMComment: 'Parent namespace embedding this namespace, if any.'>
	<container>
	^ parentNamespace
]

{ #category : #accessing }
FamixJavaNamespace >> parentNamespace: anObject [

	<generated>
	parentNamespace := anObject
]

{ #category : #navigation }
FamixJavaNamespace >> parentNamespaceGroup [
	<generated>
	<navigation: 'ParentNamespace'>
	^ MooseSpecializedGroup with: self parentNamespace
]

{ #category : #printing }
FamixJavaNamespace >> printOn: aStream [ 
	self belongsTo ifNotNil: [:parent |
		parent printOn: aStream.
		aStream
			nextPut: $:;
			nextPut: $: ].
	self name ifNotNil: [ aStream nextPutAll: self name ].
	aStream nextPutAll: ' (Namespace)'
]

{ #category : #accessing }
FamixJavaNamespace >> root [
	^ self isRoot
		ifTrue: [ self ]
		ifFalse: [ ^ self parentNamespace root ]
]

{ #category : #accessing }
FamixJavaNamespace >> structuralChildren [ 
	^ (OrderedCollection withAll: self childScopes), self classes 
]

{ #category : #'Famix-Extensions' }
FamixJavaNamespace >> withAllChildrenOfType: anSTClass [
	| all |
	all := OrderedCollection new.
	self withAllChildScopesDo: [ :each | each class = anSTClass ifTrue: [ all add: each ] ].
	^ (Smalltalk at: (anSTClass name , 'Group') asSymbol ifAbsent: [ MooseGroup ]) withAll: all
]

{ #category : #'Famix-Extensions' }
FamixJavaNamespace >> withAllParentsUpTo: aNamespace [
	^ (self parentScope allParentsUpTo: aNamespace) addFirst: self; yourself
]
