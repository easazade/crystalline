## 0.9.0

- Bump [crystalline](https://pub.dev/packages/crystalline) to 0.9.0
- Add asListenable() extension on stream objects usable for data classes

## 0.8.0

- Bump [crystalline](https://pub.dev/packages/crystalline) to 0.8.0
- Add new skipOperations argument to streamWith method
- Add streamWith method to Store
- Add initialize method to Store and change init callback method name to onInitialize
- Expose a Listenable from Store class
- Fix Store stream not working

## 0.7.0

- Add feature to generate a store class using @StoreClass annotation
- Add a simple temporary document in README
- Bump [crystalline](https://pub.dev/packages/crystalline) to 0.7.0
- Update Store and builders to override equals == and hashCode
- Make methods that must be used only in Store and its subclasses @protected
- Add logger to Store class so that it can be used internally
- Update Store so it publishes changes after init callback is done
- Add tests for Store class
- Add lifecycle callbacks to Store
- Update Store so it is no longer uses both ChangeNotifier and observer pattern for updates
- Change namings of builder and widgets to be close to flutter conventions
- Fix bad import

## 0.6.0

- Rewrite Store.
- Rename Operation.fetch to Operation.read to match associate with term CRUD.
- Remove Operation.operating state to make Operation class cleaner.
- Introduce DataBinder widgets.
- Add states method to Store class.
- Fix lint issues.
- Fix missing exports & Update example.
- Add more tests for WhenDataBinder.
- Add tests for WhenDataBinder.
- Add storeName getter to Store class.
- Update tests.
- Add StoreBuilder and Update Store.
- Add global logging for all data objects changes.
- Add CrystallineGlobalConfig and CrystallineLogger.

## 0.5.1

- Update crystalline version to to v0.5.1

## 0.5.0

- Update crystalline version to to v0.5.0

## 0.4.0

- Change term onLoading to onOperate
- Bump crystalline version to 0.4.0
- Remove equatable dependency
- Increase test coverage to 100%

## 0.3.0

- Bump crystalline 0.3.0

## 0.2.4

- Add support for custom operations
- Fix builders callbacks not showing the correct data parameter
- Add tests

## 0.1.3

- change name of listen property to observe in builders

## 0.1.2

- Update ChangeNotifierData class
- Fix bug in builders

## 0.0.1

- initial release.
