## 0.7.0

- Add feature to generate a store class using @StoreClass() annotation
- Add a simple temporary document in README
- Bump [crystalline](https://pub.dev/packages/crystalline) to 0.7.0
- Fix bad code in generated code for stores
- Fix missing @override annotation
- Fix builders not generating sometimes
- Add check in shared_store_writer to catch duplicate names for shared data fields
- Complete shared state (previously shared store) feature
- Add shared_store_writer (WIP)
- Add a unified builder to generate SharedStore
- Fix bad generated constructor for Store classes
- Update store_writer so generated Store class passed constructor args to the super constructor
- Fix incorrect store name in generated store mixin
- Fix store_writer to read sub-classes of Data as well
- Remove storeName getter from Store class

## 0.6.0

- Initial version.
