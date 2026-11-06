# Profile — Spring Boot

**Read this when you write or change code in a Spring Boot service.**

## Structure

- Group by feature first, by layer second. One feature lives in one package.
- A configuration class belongs next to the feature it configures, not in a
  global `config` package.
- One public type per file.

## Dependency injection

- Constructor injection only. No field injection.
- Keep the constructor short. More than five dependencies signals a class doing
  too much.
- Do not inject the application context to look a bean up at runtime.

## Configuration

- Bind configuration to a typed `@ConfigurationProperties` record, not to
  scattered `@Value` annotations.
- Every property gets a default or a validation annotation. A missing property
  must fail at startup, never at the first request.
- Never read an environment variable directly in business code.

## Persistence

- Keep the query out of the service. A repository owns the query.
- A native query needs a comment that states why the JPA equivalent did not work.
- Every schema change goes through the migration tool. No automatic schema update.

## Web layer

- A controller validates, delegates, and maps. It contains no business rule.
- Map an exception to a response in one place — a `@RestControllerAdvice`.
- Return a typed error body. Never let a stack trace reach the client.

## Testing

- A unit test uses no Spring context.
- An integration test starts the smallest context that proves the behaviour.
- Use a real database in a container, not an in-memory substitute, when the code
  depends on database behaviour.
- An integration test must pass on a clean machine. It may not depend on your
  local ports, your local credentials, or a running service.

## Observability

- Log at the boundary, not in every layer.
- A log line for a failure must carry the identifier needed to find the record.
- Never log a secret, a token, or a full request body that can hold personal data.

## Before handover

Run the checklist in `.agents/procedures/pre-commit-review.md`. Pay attention to
error handling — it is the most common gap.
