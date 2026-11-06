# Profile — frontend

**Read this when you write or change code in a web frontend.**

## Structure

- Group by feature, not by file type. A feature owns its component, its state,
  its styles, and its tests.
- A shared component goes to the shared folder only after the second use.
- One component per file. The filename matches the component name.

## State

- Keep state as local as it can be. Lift it only when a second component needs it.
- Server data and client state are different things. Do not store a fetched
  response in the same place as a form value.
- Every asynchronous read has three visible states: loading, error, and empty.
  A design that shows only the success state is incomplete.

## Types

- No implicit `any`. A type that is hard to write signals an unclear contract.
- Generate the API types from the backend contract when one exists. Do not
  hand-copy a response shape.

## Styling

- Use the project's token system. No hard-coded colour, spacing, or font size.
- Every interactive element is reachable by keyboard and has a visible focus state.
- Check contrast. Check it in both themes if the project has two.

## Testing

- Test behaviour through the rendered output, not through internal state.
- A test queries by role or by label, not by a CSS class.
- Cover the error and empty states, not only the happy path.

## Performance

- Measure before you optimise. Name the metric you improved.
- Lazy-load a route, not a button.
- An image needs explicit dimensions, a modern format, and a size budget.

## Before handover

Run the project lint and the test suite. Check the browser console for a
warning you introduced.
