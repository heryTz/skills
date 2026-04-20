# TanStack Form — Setup & Usage

## Before You Start

**Check the project structure before creating any file:**

- **Monorepo / workspace?** Look for a dedicated UI package (e.g., `packages/ui`, `libs/ui`). If one exists, field components and `use-format-error` may belong there instead of inside the app.
- **Existing form setup?** Check if `form-setup.tsx`, `use-format-error.ts`, or field components already exist — extend them rather than recreating.
- **Button component?** Locate the project's `Button` before writing `SubmitButton`. Adapt the import path accordingly.
- **i18n already configured?** Check `package.json` for `react-i18next` before installing.

Adapt all file paths (`src/components/form/`, `src/lib/`) to match the project's actual structure.

## Install

```bash
pnpm add @tanstack/react-form zod
```

Only add i18n packages if the project already uses them:

```bash
pnpm add react-i18next i18next
```

## `use-format-error.ts`

Path: `src/lib/use-format-error.ts`

In this project the file already exists — see `src/lib/use-format-error.ts`.

For a fresh project, create it with this shape:
- Uses `useTranslation("zod")` from `react-i18next` (translation namespace = `zod.json`)
- Messages prefixed `i18n:` are translated; plain strings shown as-is
- **Without i18n:** same hook, drop the import, replace `t(key)` with `key.replace("i18n:", "")`

```ts
import { useTranslation } from "react-i18next";

export function useFormatError() {
  const { t } = useTranslation("zod");
  const fmt = (msg: string) =>
    msg.startsWith("i18n:") ? t(msg.replace("i18n:", "")) : msg;
  return (issues: unknown): string => {
    if (!issues) return "Unknown error";
    if (Array.isArray(issues))
      return issues.map((i) =>
        typeof i === "string" ? fmt(i)
        : i && typeof i === "object" && "message" in i ? fmt((i as {message:string}).message)
        : "Unknown error"
      ).join(", ");
    if (typeof issues === "object" && "message" in issues)
      return fmt((issues as {message:string}).message);
    return fmt(issues as string);
  };
}
```

## `form-setup.tsx`

Central registry — import and register all field components here.

```tsx
import { createFormHook, createFormHookContexts } from "@tanstack/react-form";
import { InputField } from "./input-field";
import { SubmitButton } from "./submit-button";
// import other fields as needed...

const { fieldContext, formContext, useFieldContext, useFormContext } = createFormHookContexts();

const { useAppForm } = createFormHook({
  fieldComponents: { InputField /*, OtherField */ },
  formComponents: { SubmitButton },
  fieldContext,
  formContext,
});

export { useFieldContext, useAppForm, useFormContext };
```

## `submit-button.tsx`

> Use the project's existing `Button` component. Adapt the import path to match.

```tsx
import { ComponentProps } from "react";
import { Button } from "../ui/button"; // adapt to project
import { useFormContext } from "./form-setup";
import { Loader2Icon } from "lucide-react";

type SubmitButtonProps = ComponentProps<typeof Button> & { isLoading?: boolean };

export function SubmitButton({ children, className, isLoading, ...props }: SubmitButtonProps) {
  const form = useFormContext();
  return (
    <form.Subscribe selector={(s) => s.isSubmitting}>
      {(isSubmitting) => (
        <Button type="submit" className={className} {...props} disabled={isSubmitting || isLoading}>
          {(isSubmitting || isLoading) && <Loader2Icon className="animate-spin" />}
          {children}
        </Button>
      )}
    </form.Subscribe>
  );
}
```

## Field Component Pattern

Every field follows this structure — adapt UI components to the project:

```tsx
import { useFieldContext } from "./form-setup";
import { useFormatError } from "src/lib/use-format-error";

export function MyField({ label, required, ...props }: MyFieldProps) {
  const field = useFieldContext<string>(); // T = value type
  const formatError = useFormatError();
  const error = field.state.meta.isValid ? undefined : formatError(field.state.meta.errors);

  return (
    <div>
      <label htmlFor={field.name}>{label}</label>
      <input
        {...props}
        id={field.name}
        name={field.name}
        value={field.state.value ?? ""}
        onChange={(e) => field.handleChange(e.target.value)}
        aria-invalid={!!error}
      />
      {error && <span>{error}</span>}
    </div>
  );
}
```

Then register in `form-setup.tsx` `fieldComponents`.

## Field Usage Examples

```tsx
// InputField
<form.AppField name="name">
  {(field) => <field.InputField label="Name" required placeholder="Enter name" />}
</form.AppField>

// InputPasswordField
<form.AppField name="password">
  {(field) => <field.InputPasswordField label="Password" required />}
</form.AppField>

// TextareaField
<form.AppField name="bio">
  {(field) => <field.TextareaField label="Bio" rows={4} />}
</form.AppField>

// SelectField
<form.AppField name="role">
  {(field) => (
    <field.SelectField
      label="Role"
      placeholder="Select a role"
      options={[{ value: "admin", label: "Admin" }, { value: "user", label: "User" }]}
    />
  )}
</form.AppField>

// MultiSelectField (value: string[])
<form.AppField name="tags">
  {(field) => (
    <field.MultiSelectField
      label="Tags"
      options={[{ value: "react", label: "React" }, { value: "ts", label: "TypeScript" }]}
    />
  )}
</form.AppField>

// CheckboxGroupField (value: string[])
<form.AppField name="permissions">
  {(field) => (
    <field.CheckboxGroupField
      label="Permissions"
      columns={2}
      options={[{ value: "read", label: "Read" }, { value: "write", label: "Write" }]}
    />
  )}
</form.AppField>

// RadioButtonField (value: string | undefined, clearable)
<form.AppField name="plan">
  {(field) => (
    <field.RadioButtonField
      label="Plan"
      options={[{ value: "free", label: "Free" }, { value: "pro", label: "Pro" }]}
    />
  )}
</form.AppField>

// RadioCardField (value: string | undefined, 3-col grid)
<form.AppField name="size">
  {(field) => (
    <field.RadioCardField
      label="Size"
      options={[
        { value: "sm", label: "Small", helper: "Up to 10 users" },
        { value: "lg", label: "Large", helper: "Unlimited" },
      ]}
    />
  )}
</form.AppField>

// InputDatetimeField (value: Date | null)
<form.AppField name="scheduledAt">
  {(field) => <field.InputDatetimeField label="Scheduled At" required />}
</form.AppField>

// SubmitButton — always wrap in form.AppForm
<form.AppForm>
  <form.SubmitButton isLoading={mutation.isPending}>Submit</form.SubmitButton>
</form.AppForm>
```
