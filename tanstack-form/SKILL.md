---
name: tanstack-form
description: Use when creating or modifying forms in the web app - ensures proper usage of useAppForm, dedicated field components, and declarative mutation patterns with onSuccess callbacks
---

# TanStack Form Patterns

Use `useAppForm` from `form-setup`. For initial setup see `setup.md`.

## Rules

1. Never inline field logic — always a dedicated field component
2. Register all fields in `form-setup.tsx`
3. Use `useMutation` for server calls — side effects in `onSuccess`/`onError`, `onSubmit` just calls `mutation.mutate`
4. Wrap `form.SubmitButton` in `form.AppForm`

## Adding a Field — 4 Steps

**1. Create `<name>-field.tsx` in the form components directory**

```tsx
type MyFieldProps = { label: string } & Omit<ComponentProps<typeof UiComponent>, "value" | "onChange" | "onBlur">;

export function MyField({ label, ...props }: MyFieldProps) {
  const field = useFieldContext<string>();
  const formatError = useFormatError();
  const error = field.state.meta.isValid ? undefined : formatError(field.state.meta.errors);
  return (
    <FormField label={label} error={error}>
      <UiComponent {...props} id={field.name} value={field.state.value}
        onChange={(e) => field.handleChange(e.target.value)}
        onBlur={field.handleBlur} aria-invalid={!!error || undefined} />
    </FormField>
  );
}
```

For pickers/comboboxes: adapt `onChange` to the component's API, omit `aria-invalid`.

**2. Register in `form-setup.tsx` `fieldComponents`**

**3. Add to schema (named const above component) and inline `defaultValues` inside `useAppForm` — no separate variable**

**4. Use — pass all UI props at the call site, never inside the field component**

```tsx
<form.AppField name="x">
  {(field) => <field.MyField label="X" placeholder="…" options={…} />}
</form.AppField>
```

## Form Shape

```tsx
const schema = z.object({ name: z.string().min(1) });

const mutation = useMutation({
  mutationFn: myServerFn,
  onSuccess: () => { /* redirect, invalidate queries… */ },
});

const form = useAppForm({
  defaultValues: { name: "" },
  validators: { onSubmit: schema },
  onSubmit: ({ value }) => mutation.mutate({ data: value }),
});

// JSX
<form onSubmit={(e) => { e.preventDefault(); e.stopPropagation(); form.handleSubmit(); }}>
  <form.AppField name="name">{(field) => <field.InputField label="Name" />}</form.AppField>
  {mutation.isError && <p className="text-sm text-destructive">Something went wrong.</p>}
  <form.AppForm><form.SubmitButton isLoading={mutation.isPending}>Submit</form.SubmitButton></form.AppForm>
</form>
```

## Common Mistakes

| Mistake | Fix |
|---|---|
| Inline field logic | Dedicated component |
| UI props hardcoded in field component | Pass at call site |
| Server call in onSubmit | Use `useMutation`, call `mutation.mutate` in onSubmit |
| SubmitButton unwrapped | Wrap in `form.AppForm` |
| New field not working | Register in `form-setup.tsx` |
| `const defaultValues = {…}` outside `useAppForm` | Inline into `defaultValues: {…}` directly |
| Missing stopPropagation | Add both preventDefault + stopPropagation |
