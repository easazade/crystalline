# Crystalline

**Crystalline:** Simple yet Powerful state management solution

Crystalline is a comprehensive state management library designed to simplify and enhance your state management practices. By providing a structured approach to defining state objects, Crystalline helps you build more robust, maintainable, and testable applications.

### Why Use Crystalline?

#### Key Benefits

- **Enhanced Code Clarity:** Crystalline streamlines state management code and state objects for improved readability.

- **Comprehensive State Definition:** Define all necessary elements within your state, including data, status, operations, errors, and events, using a unified and efficient approach.

- **Comprehensive State Tracking:** Crystalline empowers you to represent the entire lifecycle of a `Store` within your state. Whether an operation is in progress, completed successfully, or has encountered an error, you can explicitly define these states using Crystalline data types designed for defining state objects. This level of granularity can be applied to the entire state or only specific parts of it.

- **State Composition:** Compose a state from smaller, more manageable states.

- **Shared State:** Seamlessly share states or parts of states across multiple `Stores` without compromising loose coupling or testability.

- **Custom Operations:** Crystalline supports generic operations CRUD operations. However, it also allows you to easily define any custom operations tailored to specific scenarios, such as "request access right", "apply coupon" and so forth.

## Some examples

# For Docs

- [ ] create a doc for scenarios and use cases added in example

- [ ] define crystal-clear state objects across all state management libraries.

- [ ] add badges including coverage badge. checkout faker_x
- [ ] refer to built in events as semantic events as they are semantics. create a table for all semantic events

- [ ] State definition library that makes your states, reflective and crystal clear, no matter what state management library you use.

- [ ] Checkout actual use-cases in code where crystalline saves you

- [ ] Why use this?

- [ ] Quick example

- [ ] Everything is data

- [ ] Different Data types

- [ ] Use with all state management libraries

- [ ] Easy to test

- [ ] the root cause of a lot of unclean unreadable code is bad defined state. a bad defined state makes developers to move some of the state inside ui layer inside repositories even and in simple word make it scattered in many different places in app. this in turn causes the logic to manipulate these states be scattered a cross the application as well. when you have logics scattered across different layers and components it is much harder to understand the logic or even the business logic of the app.

- [ ] Makes loading parts of the ui in parallel much easier. if a page shows a lot of different items like for example homepage of a shop application we can load the differently and show each when it is loading. this is very ideal when we are using shimmers for each of those parts instead of showing a loader for the entire page.
