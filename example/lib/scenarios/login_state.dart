import 'package:example/scenarios/models/user.dart';
import 'package:flutter_crystalline/flutter_crystalline.dart';

/// problem with this state are:
///
/// 1- our state is not valid duration operation. does not show actual state
/// let's say user is un-authenticated now and we try login user
/// our bloc state will go to busy state and during busy state there is no
/// way to understand whether user is authenticated or not
///
/// in general speaking we cannot access data from other types of states when we are in other states
/// like when we cannot access the user when we are in busy mode or.
///
/// let's say we have a user authenticated
/// anonymously we have some data in Authenticated state now we want to login user goes to busy state now
/// other parts of app that were using the data in authenticated state can't access that data while user
/// is still authenticated. and user is still anonymously authenticated.
///
/// like when we call this
///
/// ```dart
/// bool isUserAuthenticated(){
///   try{
///     return !(BlocProvider.of<Authenticate>().state as Authenticated).isAnonymous;
///   }catch(e){
///     return false;
///   }
/// }
/// ```
/// 2- there is no way to distinguish between different operations. what if we had 10 different operations
///
/// 3- in our design we have data for Data, we have operationData to show operations happening to show different operations
/// and we have flag getter methods to show the calculated state of the Store instead of having Authenticated we have isAuthenticated
/// which by the way are still valid during operation

abstract class AuthState {}

class Initializing extends AuthState {}

class Unauthenticated extends AuthState {}

class Busy extends AuthState {}

class Authenticated extends AuthState {
  final User user;

  final bool isAnonymous;

  Authenticated(this.user, this.isAnonymous);
}

class Failure extends AuthState {}

// ####################################################################################
// ####################################################################################
// ####################################################################################
// ####################################################################################

class AuthStore extends Store {
  // we can run operations on user and it will be distinguished from other operations
  // we can access this data while operations are running, ( assuming it is ok to since this is auth store)
  // we can have custom operations if we needed to
  final Data<User> user = Data();

  // we can easily distinguish between operations. operations even can run at the same time
  // we can have custom operations in OperationData if we needed to
  // in fact we can have a single login OperationData with custom Operation('loggingInAnonymously')
  // assuming we would show failure the same way for both operations
  final OperationData login = OperationData();
  final OperationData anonymousLogin = OperationData();

  bool get isAnonymousUser {
    // should calculate from state and return true or false
    // if could be state of this Store or sharedprefs or whatever
    return false;
  }

  bool get isActualUser {
    // should calculate from state and return true or false
    // if could be state of this Store or sharedprefs or whatever
    return false;
  }

  bool get isAdminUser {
    // should calculate from state and return true or false
    // if could be state of this Store or sharedprefs or whatever
    return false;
  }

  bool get isPremiumUser {
    // should calculate from state and return true or false
    // if could be state of this Store or sharedprefs or whatever
    return false;
  }

  @override
  List<Data<Object?>> get states => [user, login, anonymousLogin];
}
