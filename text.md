Create a script in a language of your choice to extract conversation from m3.html and convert it so a human readable markdown file. It is prompt and answer to create an application. See the sample below for the preferred result. You can keep special characters like ✅✏️✓🗑️➕. FiraCode Nerd Font is capable of rendering them. What precious to me are "Executing command: ..." and "```diff ...". Before you start writing the script, please scan the input file if there is anything the sample doesn't cover, and ask me to clarify. For example, user inputs should be prefixed with ">". h1, h2, h3 should be prefixed with #, ##, ###. Answers where CSS is 'p.mb-4' should be in **bold**. CSS 'button > span.truncate' should be prefixed with "-". CSS 'button p.truncate' should be in _italic_. Tables should be converted to markdown tables (There are tables, for example, at line 19152).

::: Sample output :::

> Hello! Please help me scaffold a full-stack PureScript application based on the following requirements.
> ...
> Please generate the file structure and code for Main.purs, the Halogen component(s), and the Mock.purs / Database.purs service files. Include any necessary spago.dhall dependencies (halogen, refs, node-postgres, etc.).

**I'll scaffold a full-stack PureScript application with Halogen frontend and mock/real database implementations.**

- Creating 9 new todos

## Examine existing project structure and dependencies [TODO]

### Examining the project structure to understand the current setup.

- List directory /workspaces/purescript
- Executing command: ls -la
- Executing command: which spago && which purs
- Executing command: npm list -g --depth=0 2>/dev/null | grep -E "(spago|purescript)" || echo "PureScript tools not found globally"
- Advancing to next todo item

## Create database interface and types [TODO]

### Creating the database interface and types module.

- Executing command: mkdir -p src/Database src/Component
- Create file src/Database/Types.purs

_/workspaces/purescript/src/Database/Types.purs_

```diff
+ module Database.Types where
+ import Prelude
+ -- | Customer record type
+ type Customer =
+  { id :: Int
+  , name :: String
+  }
+ -- | Database interface that can be implemented by mock or real database
+ type DatabaseInterface m =
+  { getAllCustomers :: m (Array Customer)
+  , addNewCustomer :: String -> m Unit
+  , updateCustomerName :: { id :: Int, name :: String } -> m Unit
+  }
```

- Advancing to next todo item

...
