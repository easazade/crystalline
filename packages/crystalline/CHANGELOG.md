## 0.6.0

- **REFACTOR**(crystalline): Rename clearAllSideEffects to removeAllSideEffects.
- **REFACTOR**: Rename Operation.fetch to Operation.read to match associate with term CRUD.
- **REFACTOR**(crystalline): Remove Operation.operating state to make Operation class cleaner.
- **REFACTOR**(crystalline): Restructure Data class base interfaces.
- **FIX**(crystalline): Update code doc on mutators.
- **FIX**(crystalline): Remove listening to events of original data in mirror mutator function since updateFrom method already listens to events.
- **FIX**(crystalline): Fix mirrored data objects not getting notified for events.
- **FIX**(crystalline): Fix mutators incorrect generic type mapping.
- **FIX**(crystalline): Fix ContextData not copying sideEffects when copy method was called.
- **FEAT**(flutter_crystalline): Update tests.
- **FEAT**(crystalline): Add global logging for all data objects changes.
- **FEAT**: Add CrystallineGlobalConfig and CrystallineLogger.

## 0.5.1

- Add name to Data type for debugging
- Add semantic events
- Improve test coverage to 100% and add relevant groups in test suites
- Fix observers, eventListeners & sideEffects could have been mutated manually
- Fix CollectionData & ListData not updating when added item using [] operator

## 0.5.0

- Move test observers from crystalline/test to crystalline/lib & Add tests for them
- Restyle tests
- Add cause to Failure
- Change mutator name map() to mapTo to avoid conflict with CollectionData map()
- Add events
- Update events to be consumable
- Add missing event arg in event listener callbacks
- Add extension on Iterable<T> to map to data objects
- Refactor term error to failure in all packages

## 0.4.0

- Add sideEffects to Data types
- Add OperationData
- Data.updateFrom() method can now read from ReadableData instead of just Data
- Fix data types updateFrom method not updating sideEffects & add OperationData.from() factory method
- Change type name EditableData to ModifiableData
- Fix bug in ListData not setting side effects
- Increase test coverage to 100%
- Remove throwing CannotUpdateFromTypeException in CollectionData.updateFrom(other)
- change term loading to operating
- Fix bug in Data.isLoading getter method not returning true when operation was custom
- Update Data.valueEqualsTo(otherData) method
- Change DataError with Failure
- Improve toString() implementation on Data and Failure for better/readable/clear logging
- Fix bug in CollectionData.hasValue method returning false when list has items & Add more tests for ListData
- Fix builders not updating from new data when data object instance changes
- Fix bug in WhenBuilder sometimes not calling onCustomOperation callback when needed to && Add more tests for WhenBuilder
- Add extension methods toOperationData() and unModifiable() on Data<T>

## 0.3.0

- Add ContextData type
- Add support for mutators
- Add map(), distinct(), mirror() mutators
- Add modify(), modifyAsync() to data types
- Add updateFrom() to Data types
- Update toString() method on Data for better logging
- Change name of type ReadableObservableData to UnModifiableData

## 0.2.3

- Refactor Operation class and add support for custom operations
- Override copy() method for CollectionData and ListData
- Update example
- Update dart/flutter sdk version
- Replace term available with hasValue for clarity
- Update melos scripts
- Add tests
- Update and fixes CollectionData class
- Add ListData class
- Change listeners names to observers

## 0.1.2

- Update Data class
- Add CollectionData class
- Add observe feature for Data types to observe changes

## 0.0.1

- Initial version.
