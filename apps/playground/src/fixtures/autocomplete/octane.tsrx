"use strong"
import { useAsyncOptions } from "@ui-sdk/octane/async-options"
import {
  Autocomplete,
  AutocompleteClear,
  AutocompleteContent,
  AutocompleteEmpty,
  AutocompleteGroup,
  AutocompleteGroupLabel,
  AutocompleteInput,
  AutocompleteItem,
  AutocompleteItemText,
  AutocompleteLabel,
  AutocompleteList,
  AutocompleteSeparator,
  AutocompleteStatus,
  AutocompleteTrigger,
  type AutocompleteContentState,
  type AutocompleteStatusState,
  type ListData,
} from "@ui-sdk/octane/autocomplete"
import * as React from "octane"
import { createRoot } from "octane"
import {
  autocompleteFixture as f,
  autocompleteOptions,
  changedItems,
  searchFruits,
} from "tests/fixtures/autocomplete.ts"
import { onItemsChange } from "tests/fixtures/items.ts"
import { serializeForm } from "tests/fixtures/select.ts"

type ItemData = {
  value: string
  label: string
  keywords?: string[]
  disabled?: boolean
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

// The list's data, rendered like the composed list: items, and groups with their labels.
function DataItems({
  items,
  highlight,
}: {
  items: ListData
  highlight: boolean
}) @{
  const rows = items.map((entry) => ({ entry, key: entryKey(entry) }))
  @for (const row of rows; key row.key) {
    <DataEntry entry={row.entry} highlight={highlight} />
  }
}

function DataEntry({
  entry,
  highlight,
}: {
  entry: ListData[number]
  highlight: boolean
}) {
  if (typeof entry === "string") {
    return <DataItem value={entry} label={entry} highlight={highlight} />
  }
  if ("value" in entry) {
    return <DataItem {...(entry as ItemData)} highlight={highlight} />
  }
  if (entry.type === "separator") {
    return <AutocompleteSeparator />
  }
  return (
    <AutocompleteGroup>
      <AutocompleteGroupLabel className="label">
        {entry.label}
      </AutocompleteGroupLabel>
      <DataItems items={entry.items} highlight={highlight} />
    </AutocompleteGroup>
  )
}

function DataItem({ highlight, ...item }: ItemData & { highlight: boolean }) {
  return (
    <AutocompleteItem className="item" {...item}>
      @if (highlight) {
        <AutocompleteItemText>{item.label}</AutocompleteItemText>
      } @else {
        <>{item.label}</>
      }
    </AutocompleteItem>
  )
}

function Fixture({ data = false }: { data?: boolean }) {
  const {
    fieldset,
    grouped,
    async,
    late,
    container,
    highlight,
    recent,
    nostatus,
    ...options
  } = React.useInitialValue(autocompleteOptions)
  const [action, setAction] = React.useState("")
  const [submitted, setSubmitted] = React.useState("")
  const remote = useAsyncOptions(searchFruits, { immediate: async })
  const [list, setList] = React.useState<ItemData[]>(f.items)
  // With ?late, there are no items until the first change.
  const [arrived, setArrived] = React.useState(false)
  React.useEffect(() =>
    onItemsChange(changedItems, (items) => {
      setList(items)
      setArrived(true)
    })
  )
  const items = async
    ? remote.items
    : grouped
      ? f.groups.map((group) => ({
          type: "group" as const,
          label: group.label,
          items: group.items,
        }))
      : list
  const fromData = data || async || recent
  // Passed as the `children` prop: between tags, Octane would compile it
  // into a render block, which never gets the list's state.
  const listContent = fromData ? (
    (state: AutocompleteContentState) => (
      <DataItems items={state.items as ListData} highlight={highlight} />
    )
  ) : (
    <>
      @if (grouped) {
        @for (const group of f.groups; key group.label) {
          <AutocompleteGroup>
            <AutocompleteGroupLabel className="label">
              {group.label}
            </AutocompleteGroupLabel>
            @for (const item of group.items; key item.value) {
              <AutocompleteItem
                className="item"
                value={item.value}
                label={item.label}
              >
                {item.label}
              </AutocompleteItem>
            }
          </AutocompleteGroup>
        }
      } @else {
        @for (const item of list; key item.value) {
          <AutocompleteItem
            className="item"
            value={item.value}
            label={item.label}
            keywords={item.keywords}
            disabled={item.disabled}
          >
            @if (highlight) {
              <AutocompleteItemText>{item.label}</AutocompleteItemText>
            } @else {
              <>{item.label}</>
            }
          </AutocompleteItem>
        }
      }
    </>
  )
  const control = (
    <Autocomplete
      {...options}
      name={f.name}
      container={container}
      items={
        late ? (arrived ? items : undefined) : fromData ? items : undefined
      }
      emptyItems={recent ? f.recent : undefined}
      filter={async ? false : undefined}
      status={async ? remote.status : undefined}
      onValueChange={(value, details) => {
        setAction(`value:${value}:${details.reason}`)
        if (async) {
          remote.setQuery(value)
        }
      }}
      onSubmit={(value) => setAction(`submit:${value}`)}
    >
      <AutocompleteLabel className="label">{f.label}</AutocompleteLabel>
      <AutocompleteInput className="input" />
      <AutocompleteTrigger aria-label={f.trigger}>{"▾"}</AutocompleteTrigger>
      <AutocompleteClear>{f.clear}</AutocompleteClear>
      @if (late) {
        <AutocompleteContent className="popup list-popup" />
      } @else {
        <AutocompleteContent className="popup list-popup">
          @if (!nostatus) {
            <AutocompleteStatus className="status">
              {(state: AutocompleteStatusState) =>
                state.loading ? "Loading…" : ""
              }
            </AutocompleteStatus>
          }
          <AutocompleteEmpty className="empty">{f.empty}</AutocompleteEmpty>
          <AutocompleteList children={listContent} />
        </AutocompleteContent>
      }
    </Autocomplete>
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
        @if (fieldset) {
          <fieldset disabled>{control}</fieldset>
        } @else {
          <>{control}</>
        }
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
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
