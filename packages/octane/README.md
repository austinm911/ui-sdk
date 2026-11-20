# @ui-sdk/octane

UI SDK for Octane. A library of behaviors to build your components.

```bash
npm install @ui-sdk/octane @ui-sdk/core
```

It needs Octane 0.18.0 or later. The components are Strong-mode `.tsrx`, published as source, so your Octane compiler builds them with your app.

The API follows `@ui-sdk/react`, with two differences that come from Octane:

- `render` takes a function, `(props, state) => <a {...props} />`, not an element.
- A component never reads its children. Write text that a part reads, like a `SelectItemText` label, as a string or a `label` prop.

See [contributing/octane.md](../../contributing/octane.md) for how the adapter is built.
