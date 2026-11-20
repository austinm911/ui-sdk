"use strong"
import {
  createListboxController,
  Listbox,
  ListboxGroup,
  ListboxGroupLabel,
  ListboxItem,
  ListboxItemIcon,
  ListboxItemIndicator,
  ListboxSeparator,
  type ListData,
} from "@ui-sdk/octane/listbox"
import { Field, FieldDescription, FieldLabel } from "@ui-sdk/octane/field"
import * as React from "octane"
import { createRoot } from "octane"
import * as classes from "./classes"
import { kitchenSink, type Env } from "./shell"
import {
  describe,
  groups,
  toppings,
  variantData,
  type Variant,
} from "./variants"

// A listbox of any value, single or multiple as the variant says.
const AnyListbox = Listbox<any, boolean>

function Leaf() {
  return (
    <svg
      aria-hidden="true"
      viewBox="0 0 24 24"
      className="size-3.5"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
    >
      <path d="M5 19c8 0 14-6 14-14C11 5 5 11 5 19Zm0 0 7-7" />
    </svg>
  )
}

function Item({
  value,
  label,
  disabled,
  link,
}: {
  value: unknown
  label: string
  disabled?: boolean
  link?: boolean
}) {
  return (
    <ListboxItem
      className={classes.item}
      value={value}
      disabled={disabled}
      render={
        link
          ? (props) => <a href={`#${String(value)}`} {...props} />
          : undefined
      }
    >
      <ListboxItemIcon className={classes.icon}>
        <Leaf />
      </ListboxItemIcon>
      {label}
      <ListboxItemIndicator className={classes.indicator}>
        {"✓"}
      </ListboxItemIndicator>
    </ListboxItem>
  )
}

function Items({ variant }: { variant: Variant }) @{
  @if (variant.items !== "grouped") {
    @for (const item of toppings; key item.value) {
      <Item {...item} link={variant.links} />
    }
  } @else {
    @for (const group of groups; key group.label) {
      <>
        @if (group !== groups[0]) {
          <ListboxSeparator className={classes.separator} />
        }
        <ListboxGroup className={classes.group}>
          <ListboxGroupLabel className={classes.groupLabel}>
            {group.label}
          </ListboxGroupLabel>
          @for (const item of group.items; key item.value) {
            <Item {...item} />
          }
        </ListboxGroup>
      </>
    }
  }
}

type Entry = ListData<any>[number]

// Separators have nothing that names them, so each keeps the id it first got.
const separatorIds = new WeakMap<object, number>()
const separatorCount = { last: 0 }

// Keyed by label, since values may be objects.
function entryKey(entry: Entry) {
  if (typeof entry === "string") {
    return entry
  }
  if ("type" in entry && entry.type === "separator") {
    let id = separatorIds.get(entry)
    if (id === undefined) {
      separatorIds.set(entry, (id = ++separatorCount.last))
    }
    return `separator-${id}`
  }
  return (entry as { label: string }).label
}

// A data listbox's items, from its state.
function DataItems({ list }: { list: ListData<any> }) @{
  const rows = list.map((entry) => ({ entry, key: entryKey(entry) }))
  @for (const row of rows; key row.key) {
    <DataEntry entry={row.entry} />
  }
}

function DataEntry({ entry }: { entry: Entry }) {
  if (typeof entry === "string") {
    return <Item value={entry} label={entry} />
  }
  if ("type" in entry && entry.type === "separator") {
    return <ListboxSeparator className={classes.separator} />
  }
  if ("type" in entry && entry.type === "group") {
    return (
      <ListboxGroup className={classes.group}>
        <ListboxGroupLabel className={classes.groupLabel}>
          {entry.label}
        </ListboxGroupLabel>
        <DataItems list={entry.items} />
      </ListboxGroup>
    )
  }
  return <Item {...(entry as { value: unknown; label: string })} />
}

function VariantListbox({ variant, env }: { variant: Variant; env: Env }) {
  const { fieldDisabled, ...options } = (variant.options ?? {}) as Record<
    string,
    any
  >
  const [value, setValue] = React.useState<unknown>(() =>
    options.multiple ? [] : null
  )
  const controller = React.useInitialValue(() =>
    variant.controller ? createListboxController<string, true>() : undefined
  )
  React.useEffect(() => {
    if (!controller) {
      return
    }
    env.controls([
      ["selectAll()", () => controller.selectAll()],
      ["clear()", () => controller.clear()],
      ['setValue(["onion"])', () => controller.setValue(["onion"])],
      ["getValue()", () => controller.getValue()],
      ["focus()", () => controller.focus()],
    ])
  })
  // Passed as the `children` prop: between tags, Octane would compile it
  // into a render block, which never gets the list's state.
  const content = variant.data ? (
    (state: { items: unknown }) => (
      <DataItems list={state.items as ListData<any>} />
    )
  ) : (
    <Items variant={variant} />
  )
  const listbox = (
    <AnyListbox
      className={classes.root}
      {...options}
      {...(variant.controlled && { value })}
      aria-label={variant.field ? undefined : "Toppings"}
      controller={controller}
      items={variant.data ? variantData(variant) : undefined}
      onValueChange={(next, details) => {
        if (variant.cancel) {
          return details.cancel()
        }
        if (variant.controlled) {
          setValue(next)
        }
        env.log(
          `valueChange ${describe(next)} (${details.reason}, ${details.source})`
        )
      }}
      children={content}
    />
  )
  if (variant.field) {
    return (
      <Field disabled={!!fieldDisabled} className="flex flex-col gap-1.5">
        <FieldLabel className={classes.label}>{"Toppings"}</FieldLabel>
        {listbox}
        <FieldDescription className={classes.description}>
          {"Pick what goes on top."}
        </FieldDescription>
      </Field>
    )
  }
  if (!variant.form) {
    return listbox
  }
  return (
    <form
      className="flex flex-col items-start gap-2"
      onSubmit={(event: SubmitEvent) => {
        event.preventDefault()
        env.log(
          `submit ${new URLSearchParams(new FormData(event.currentTarget as HTMLFormElement) as never).toString()}`
        )
      }}
      onReset={() => env.log("reset")}
    >
      {listbox}
      <div className="flex gap-2">
        <button className={classes.button}>{"Submit"}</button>
        <button type="reset" className={classes.control}>
          {"Reset"}
        </button>
      </div>
    </form>
  )
}

function mount(root: HTMLElement) {
  kitchenSink(root, "octane", (slot, variant, env) =>
    createRoot(slot).render(<VariantListbox variant={variant} env={env} />)
  )
}

export { mount }
