"use strong"
import { createSelectController } from "@ui-sdk/core/select"
import {
  Select,
  SelectClear,
  SelectContent,
  SelectEmpty,
  SelectGroup,
  SelectGroupLabel,
  SelectInput,
  SelectItem,
  SelectItemIndicator,
  SelectItemText,
  SelectLabel,
  SelectList,
  SelectSelectAll,
  SelectSeparator,
  SelectTrigger,
  SelectValue,
  type ListData,
} from "@ui-sdk/octane/select"
import { Field, FieldLabel } from "@ui-sdk/octane/field"
import * as React from "octane"
import { createRoot } from "octane"
import { onItemsChange } from "tests/fixtures/items.ts"
import {
  changedItems,
  longItems,
  selectFixture as f,
  selectOptions,
  serializeForm,
} from "tests/fixtures/select.ts"

const controller = createSelectController<string, boolean>()

// One or several values, as ?multiple says.
const AnySelect = Select<string, boolean>

type ItemData = { value: string; label: string; disabled?: boolean }

function Item({ value, label, disabled }: ItemData) {
  return (
    <SelectItem className="item" value={value} disabled={disabled}>
      <SelectItemText>{label}</SelectItemText>
      <SelectItemIndicator className="indicator">{"✓"}</SelectItemIndicator>
    </SelectItem>
  )
}

// Separators have nothing that names them, so each keeps the id it first got.
const separatorIds = new WeakMap<object, number>()
const separatorCount = { last: 0 }

function entryKey(entry: ListData[number]) {
  if (typeof entry === "string") {
    return entry
  }
  if ("value" in entry) {
    return entry.value
  }
  if (entry.type === "group") {
    return `group-${entry.label}`
  }
  let id = separatorIds.get(entry)
  if (id === undefined) {
    separatorIds.set(entry, (id = ++separatorCount.last))
  }
  return `separator-${id}`
}

// The list's data, rendered like the composed list: items with their check,
// groups with their labels, and separators.
function DataItems({ items }: { items: ListData }) @{
  const rows = items.map((entry) => ({ entry, key: entryKey(entry) }))
  @for (const row of rows; key row.key) {
    <DataEntry entry={row.entry} />
  }
}

function DataEntry({ entry }: { entry: ListData[number] }) {
  if (typeof entry === "string") {
    return <Item value={entry} label={entry} />
  }
  if ("value" in entry) {
    return <Item {...(entry as ItemData)} />
  }
  if (entry.type === "separator") {
    return <SelectSeparator className="separator" />
  }
  return (
    <SelectGroup>
      <SelectGroupLabel className="label">{entry.label}</SelectGroupLabel>
      <DataItems items={entry.items} />
    </SelectGroup>
  )
}

// What the list holds: the items, grouped with ?grouped, each group with its own select-all option.
function Items({
  list,
  grouped,
  selectAll,
}: {
  list: ItemData[]
  grouped: boolean
  selectAll: boolean
}) @{
  @if (!grouped) {
    @for (const item of list; key item.value) {
      <Item {...item} />
    }
  } @else {
    @for (const group of f.groups; key group.label) {
      <>
        @if (group !== f.groups[0]) {
          <SelectSeparator className="separator" />
        }
        <SelectGroup>
          <SelectGroupLabel className="label">{group.label}</SelectGroupLabel>
          @if (selectAll) {
            <SelectSelectAll className="item">
              {`${f.selectAll} ${group.label}`}
            </SelectSelectAll>
          }
          @for (const item of group.items; key item.value) {
            <Item {...item} />
          }
        </SelectGroup>
      </>
    }
  }
}

// ?wrapped renders the data list through a content part wrapped in a
// component of the app's own, as a styled layer does. The select renders it
// and no list of its own.
function StyledContent() {
  return <SelectContent className="popup list-popup" />
}

function Fixture({ data = false }: { data?: boolean }) {
  // The page's options, read once, as the page's URL never changes.
  const wrapped = React.useInitialValue(() =>
    new URLSearchParams(location.search).has("wrapped")
  )
  const {
    fieldset,
    field,
    grouped,
    cancel,
    align,
    long,
    container,
    search,
    selectAll,
    recent,
    max,
    ...options
  } = React.useInitialValue(selectOptions)
  const [action, setAction] = React.useState("")
  const [submitted, setSubmitted] = React.useState("")
  const [list, setList] = React.useState<ItemData[]>(f.items)
  React.useEffect(() => onItemsChange(changedItems, setList))
  const items = long
    ? longItems()
    : grouped
      ? [
          {
            type: "group" as const,
            label: f.groups[0].label,
            items: f.groups[0].items,
          },
          { type: "separator" as const },
          {
            type: "group" as const,
            label: f.groups[1].label,
            items: f.groups[1].items,
          },
        ]
      : list
  const fromData = data || long || recent
  const trigger = (
    <SelectTrigger
      className="trigger"
      controller={field ? controller : undefined}
    >
      <SelectValue className="value" maxLabels={max} />
      <span aria-hidden="true">{"▾"}</span>
    </SelectTrigger>
  )
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
          @if (field) {
            <Field>
              <FieldLabel className="label">{f.label}</FieldLabel>
              {trigger}
            </Field>
          }
          <AnySelect
            {...options}
            name={f.name}
            placeholder={f.placeholder}
            controller={controller}
            container={container}
            items={fromData || wrapped ? items : undefined}
            emptyItems={recent ? f.recent : undefined}
            onValueChange={(value, details) => {
              if (cancel) {
                return details.cancel()
              }
              setAction(
                `value:${Array.isArray(value) ? value.join(",") : String(value)}`
              )
            }}
          >
            @if (!field) {
              <>
                <SelectLabel className="label">{f.label}</SelectLabel>
                {trigger}
              </>
            }
            <SelectClear>{f.clear}</SelectClear>
            @if (wrapped) {
              <StyledContent />
            } @else if (search) {
              <SelectContent
                className="popup list-popup"
                alignItemWithTrigger={align}
              >
                <SelectInput className="input" aria-label={f.search} />
                <SelectEmpty className="empty">{f.empty}</SelectEmpty>
                <SelectList>
                  {(state: { items: unknown }) => (
                    <>
                      @if (selectAll && !grouped) {
                        <SelectSelectAll className="item">
                          {f.selectAll}
                        </SelectSelectAll>
                      }
                      @if (fromData) {
                        <DataItems items={state.items as ListData} />
                      } @else {
                        <Items
                          list={list}
                          grouped={grouped}
                          selectAll={selectAll}
                        />
                      }
                    </>
                  )}
                </SelectList>
              </SelectContent>
            } @else if (fromData) {
              <SelectContent className="popup list-popup">
                {(state: { items: unknown }) => (
                  <>
                    @if (selectAll) {
                      <SelectSelectAll className="item">
                        {f.selectAll}
                      </SelectSelectAll>
                    }
                    <DataItems items={state.items as ListData} />
                  </>
                )}
              </SelectContent>
            } @else {
              <SelectContent
                className="popup list-popup"
                alignItemWithTrigger={align}
              >
                @if (selectAll && !grouped) {
                  <SelectSelectAll className="item">
                    {f.selectAll}
                  </SelectSelectAll>
                }
                <Items list={list} grouped={grouped} selectAll={selectAll} />
              </SelectContent>
            }
          </AnySelect>
        </Wrap>
        <button type="submit">{"Submit"}</button>
        <button type="reset">{"Reset"}</button>
      </form>
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
      <output role="status" aria-label="Submitted">
        {submitted}
      </output>
      <button onClick={() => controller.open()}>
        {"Open with controller"}
      </button>
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
