# Crystalline

<p align="center"> <img alt="CI Build Checks" src="https://img.shields.io/github/actions/workflow/status/easazade/crystalline/build.yaml?branch=main&style=flat-square"> <img alt="Pub Version" src="https://img.shields.io/pub/v/crystalline?style=flat-square"> <img alt="Pub Popularity" src="https://img.shields.io/pub/popularity/crystalline?style=flat-square"> <img alt="Pub Points" src="https://img.shields.io/pub/points/crystalline?style=flat-square"> <img alt="Pub Likes" src="https://img.shields.io/pub/likes/crystalline?style=flat-square"> <img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/easazade/crystalline?style=flat-square"> <img alt="GitHub contributors" src="https://img.shields.io/github/contributors/easazade/crystalline?style=flat-square"> <img alt="Pub Publisher" src="https://img.shields.io/pub/publisher/crystalline?style=flat-square"> <img alt="GitHub" src="https://img.shields.io/github/license/easazade/crystalline?style=flat-square"> </p>

<img src="https://raw.githubusercontent.com/easazade/crystalline/refs/heads/main/banner.png">

> **Note**: This library is currently in early development. Documentation is not yet ready, and the API is subject to changes as I continue to refine the core concepts.

## The Core Idea

Crystalline is a state management solution built on a simple premise: **Everything that exists is data, and everything that is done is a manipulation of that data.**

While many state management libraries focus on complex flows or boilerplate-heavy patterns, Crystalline treats state as a living piece of data that inherently reflects its own lifecycle. Whether data is being read, updated, created, or deleted, those transitions shouldn't just be "side effects"—they should be first-class properties of the state itself.

In Crystalline, state is not just a value; it's a **Data** object that knows its current operation, its failures, and its history. This makes the relationship between data manipulation and the UI observer transparent and effortless.

## Quick Example

Here is how you can manage an asynchronous operation like fetching a user profile.

### 1. Define and Manipulate Data

Instead of manually managing loading booleans and error strings, the `Data` object tracks the state of the operation for you.

```dart
// Define a piece of state for a UserProfile
final userProfile = Data<UserProfile>();

// Perform an async operation
Future<void> fetchUserProfile() async {
  // Set operation to 'read' to indicate loading
  userProfile.operation = Operation.read;

  try {
    final profile = await api.getUserProfile();
    // Setting the value automatically updates observers
    userProfile.value = profile;
  } catch (e) {
    userProfile.failure = Failure(e.toString());
  } finally {
    // Reset operation to 'none' when finished
    userProfile.operation = Operation.none;
  }
}
```

### 2. Observe with DataBuilder

`DataBuilder` gives you full control over how to render the state based on its current properties.

```dart
DataBuilder(
  data: userProfile,
  builder: (context, data) {
    if (data.isReading) return CircularProgressIndicator();
    if (data.hasFailure) return Text('Error: ${data.failure}');
    if (data.hasValue) return Text('Welcome, ${data.value.name}');

    return Text('No profile loaded');
  },
)
```

### 3. Simplify with WhenDataBuilder

For a more declarative approach, you can use `WhenDataBuilder` to handle different states of your data explicitly.

```dart
WhenDataBuilder(
  data: userProfile,
  onRead: (context, data) => CircularProgressIndicator(),
  onFailure: (context, data) => Text('Error: ${data.failure}'),
  onValue: (context, data) => Text('Welcome, ${data.value.name}'),
  onNoValue: (context, data) => Text('No profile loaded'),
)
```

## Features & Roadmap

- **Everything is Data**: Crystalline provides specialized data classes like `Data`, `ListData`, `CollectionData`, and `OperationData` to handle different state shapes.
- **Built-in Builders**: Reactive widgets like `DataBuilder`, `StoreBuilder`, and `WhenDataBuilder` make it easy to consume state changes without manual listeners.
- **Store System**: A structured `Store` class to organize multiple states, with upcoming support for **Code Generation** to automatically produce custom data classes and builders.
- **Semantic Operations**: State naturally tracks whether it is `isReading`, `isUpdating`, or has a `failure`, allowing you to build robust UIs that respond to every stage of a data's lifecycle.

Crystalline exists to make state management feel like what it actually is: simple data manipulation.
