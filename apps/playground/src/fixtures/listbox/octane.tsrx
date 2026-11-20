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
} from "@ui-sdk/octane/listbox"
import * as React from "octane"
import { createRoot } from "octane"
import { onItemsChange } from "tests/fixtures/items.ts"
import {
  changedToppings,
  listboxAction,
  listboxData,
  listboxFixture as f,
  listboxOptions,
  longToppings,
  type ListboxFixtureItem,
} from "tests/fixtures/listbox.ts"
import { serializeForm } from "tests/fixtures/select.ts"

// A listbox whose `multiple` comes from the page, so it may hold one value or several.
const ManyListbox = Listbox<string, boolean>

const controller = createListboxController<string, boolean>()

function Item({ value, label, disabled }: ListboxFixtureItem) {
  return (
    <ListboxItem className="item" value={value} disabled={disabled}>
      <ListboxItemIcon className="icon" />
      {label}
      <ListboxItemIndicator className="indicator">{"✓"}</ListboxItemIndicator>
    </ListboxItem>
  )
}

// The items, or the groups with ?grouped.
function Items({
  grouped,
  long,
  list,
}: {
  grouped: boolean
  long: boolean
  list: ListboxFixtureItem[]
}) @{
  @if (long) {
    @for (const item of longToppings(); key item.value) {
      <Item {...item} />
    }
  } @else if (!grouped) {
    @for (const item of list; key item.value) {
      <Item {...item} />
    }
  } @else {
    @for (const group of f.groups; key group.label) {
      <>
        @if (group !== f.groups[0]) {
          <ListboxSeparator className="separator" />
        }
        <ListboxGroup className="group">
          <ListboxGroupLabel className="label">{group.label}</ListboxGroupLabel>
          @for (const item of group.items; key item.value) {
            <Item {...item} />
          }
        </ListboxGroup>
      </>
    }
  }
}

function Fixture({ data = false }: { data?: boolean }) {
  const {
    fieldset,
    grouped,
    cancel,
    long,
    controlled,
    defaultValue,
    ...options
  } = React.useInitialValue(listboxOptions)
  const [action, setAction] = React.useState("")
  const [reason, setReason] = React.useState("")
  const [submitted, setSubmitted] = React.useState("")
  const [list, setList] = React.useState<ListboxFixtureItem[]>(f.items)
  React.useEffect(() => onItemsChange(changedToppings, setList))
  const [value, setValue] = React.useState<string | string[] | null>(
    defaultValue ?? (options.multiple ? [] : null)
  )
  const items = data
    ? long
      ? longToppings()
      : grouped
        ? listboxData(true)
        : list
    : undefined
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <form
        className="select-form"
        aria-label={f.formLabel}
        onSubmit={(event: SubmitEvent) => {
          event.preventDefault()
          setSubmitted(serializeForm(event.currentTarget as HTMLFormElement))
        }}
      >
        <Wrap fieldset={fieldset}>
          <ManyListbox
            {...options}
            {...(controlled ? { value } : { defaultValue })}
            className="listbox"
            aria-label={f.label}
            name={f.name}
            controller={controller}
            items={items}
            onValueChange={(next, details) => {
              setReason(details.reason)
              if (cancel) {
                return details.cancel()
              }
              setValue(next)
              setAction(listboxAction(next))
            }}
          >
            <Items grouped={grouped} long={long} list={list} />
          </ManyListbox>
        </Wrap>
        <button type="submit">{"Submit"}</button>
        <button type="reset">{"Reset"}</button>
      </form>
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
      <output role="status" aria-label="Reason">
        {reason}
      </output>
      <output role="status" aria-label="Submitted">
        {submitted}
      </output>
      <button onClick={() => controller.clear()}>{f.clear}</button>
      <button onClick={() => controller.selectAll()}>{f.selectAll}</button>
    </div>
  )
}

// A disabled fieldset around the control, with ?fieldset.
function Wrap({
  fieldset,
  children,
}: {
  fieldset: boolean
  children?: unknown
}) @{
  @if (fieldset) {
    <fieldset disabled>{children}</fieldset>
  } @else {
    <>{children}</>
  }
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
