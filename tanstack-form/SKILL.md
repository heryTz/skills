---
name: tanstack-form
description: Use when creating or modifying forms in the web app - ensures proper usage of useAppForm, dedicated field components, and declarative mutation patterns with onSuccess callbacks
---

# TanStack Form Patterns

Always use `useAppForm` from `src/components/form/form-setup` and field components via `form.AppField`. For setup, new field pattern, and field usage examples see `setup.md`.

## Core Rules

1. **Never write inline field logic** — always create dedicated field components
2. **Register all fields in `form-setup.tsx`**
3. **Use `onSuccess` callbacks** — never try-catch in onSubmit
4. **Wrap `form.SubmitButton` in `form.AppForm`** always

## Form Example

```tsx
import { useAppForm } from "src/components/form/form-setup";
import { useMutation } from "@tanstack/react-query";
import { z } from "zod";

const schema = z.object({ name: z.string().min(1, "i18n:ns.nameRequired") });

export function MyForm() {
  const mutation = useMutation(
    rpc.item.create.mutationOptions({
      onSuccess: (data) => { 
        toast.success("Created!");
        form.reset();
        // Redirect if needed
      },
    })
  );

  const form = useAppForm({
    defaultValues: { name: "" } as z.infer<typeof schema>,
    validators: { onSubmit: schema },
    onSubmit: ({ value }) => mutation.mutate(value),
  });

  return (
    <form onSubmit={(e) => { e.preventDefault(); e.stopPropagation(); form.handleSubmit(); }}>
      <form.AppField name="name">
        {(field) => <field.InputField label="Name" required disabled={mutation.isPending} />}
      </form.AppField>
      <form.AppForm>
        <form.SubmitButton isLoading={mutation.isPending}>Submit</form.SubmitButton>
      </form.AppForm>
    </form>
  );
}
```

## Validation Messages

Prefix with `i18n:` for translation (`zod` namespace → `src/i18n/locales/*/zod.json`):

```tsx
z.string().min(1, "i18n:feature.validation.nameRequired")
// zod.json: { "feature": { "validation": { "nameRequired": "Name is required" } } }
```

## Form Methods

```tsx
form.reset()                       // Reset to defaultValues
form.setFieldValue("field", value) // Set a field programmatically
form.state.isSubmitting            // true during submission
form.state.canSubmit               // true when valid
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Inline field logic | Create dedicated field component |
| `try-catch` in `onSubmit` | Use `onSuccess`/`onError` on mutation |
| `<form.SubmitButton>` unwrapped | Always wrap in `<form.AppForm>` |
| Fields not disabled during submit | Add `disabled={mutation.isPending}` |
| Missing `e.stopPropagation()` | Include both `preventDefault` and `stopPropagation` |
| New field not working | Forgot to register in `form-setup.tsx` `fieldComponents` |
