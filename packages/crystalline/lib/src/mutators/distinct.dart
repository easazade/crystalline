// import 'package:crystalline/src/data_types/data.dart';

// class Distinct<T1, D1 extends Data<T1>> {
//   Distinct(this.origin) {
//     distinct = origin.copy() as D1;
//     origin.addObserver(() {
//       if(origin.valueOrNull != _lastValue){
//         _lastValue
//       }
//     });
//   }


//   final D1 origin;
//   late D1 distinct;

//   T1? _lastValue;
// }

// extension DataX<T1, T2, D1 extends ReadableObservableData<T1>> on Data<T1> {
//   /// distinct function
//   D2 map<D2 extends Data<T2>>(
//     D2 mapData,
//     void Function(D1 origin, D2 mutated) mapper,
//   ) {
//     return Mapper<T1, T2, D1, D2>(this as D1, mapData, mapper).mapData;
//   }
// }
