"use strong"
import { useAsyncOptions } from "@ui-sdk/octane/async-options"
import {
  Combobox,
  ComboboxChip,
  ComboboxChipRemove,
  ComboboxChips,
  ComboboxChipsOverflow,
  ComboboxClear,
  ComboboxContent,
  ComboboxCreate,
  ComboboxEmpty,
  ComboboxGroup,
  ComboboxGroupLabel,
  ComboboxInput,
  ComboboxItem,
  ComboboxItemIndicator,
  ComboboxItemText,
  ComboboxLabel,
  ComboboxList,
  ComboboxSelectAll,
  ComboboxSeparator,
  ComboboxStatus,
  ComboboxTrigger,
  ComboboxValue,
  type ComboboxContentState,
  type ComboboxStatusState,
  type ComboboxValueState,
  type ListData,
} from "@ui-sdk/octane/combobox"
import * as React from "octane"
import { createRoot } from "octane"
import { longItems, serializeForm } from "tests/fixtures/select.ts"
import {
  cancelsValue,
  changedItems,
  comboboxFixture as f,
  comboboxOptions,
  createDelay,
  searchCountries,
  searchCountryPages,
} from "tests/fixtures/combobox.ts"
import { onItemsChange } from "tests/fixtures/items.ts"

// A combobox whose `multiple` comes from the page, so it may hold one value or several.
const ManyCombobox = Combobox<string, boolean>

type ItemData = {
  value: string
  label: string
  keywords?: string[]
  disabled?: boolean
}

function Item({
  value,
  label,
  keywords,
  disabled,
  highlight,
}: ItemData & { highlight: boolean }) {
  return (
    <ComboboxItem
      className="item"
      value={value}
      label={label}
      keywords={keywords}
      disabled={disabled}
    >
      @if (highlight) {
        <ComboboxItemText>{label}</ComboboxItemText>
      } @else {
        <>{label}</>
      }
      <ComboboxItemIndicator className="indicator">{"✓"}</ComboboxItemIndicator>
    </ComboboxItem>
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

// The list's data, rendered like the composed list: items with their check, and groups with their labels.
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
    return <Item value={entry} label={entry} highlight={highlight} />
  }
  if ("value" in entry) {
    return <Item {...(entry as ItemData)} highlight={highlight} />
  }
  if (entry.type === "separator") {
    return <ComboboxSeparator />
  }
  return (
    <ComboboxGroup>
      <ComboboxGroupLabel className="label">{entry.label}</ComboboxGroupLabel>
      <DataItems items={entry.items} highlight={highlight} />
    </ComboboxGroup>
  )
}

function Fixture({ data = false }: { data?: boolean }) {
  const {
    fieldset,
    grouped,
    create,
    slow,
    async,
    long,
    late,
    container,
    highlight,
    recent,
    selectAll,
    overflow,
    pages,
    nostatus,
    summary,
    labelsFromItems,
    cancel,
    ...options
  } = React.useInitialValue(comboboxOptions)
  const [action, setAction] = React.useState("")
  const [submitted, setSubmitted] = React.useState("")
  const [created, setCreated] = React.useState<
    { value: string; label: string }[]
  >([])
  const [list, setList] = React.useState<ItemData[]>(f.items)
  // With ?late, there are no items until the first change.
  const [arrived, setArrived] = React.useState(false)
  React.useEffect(() =>
    onItemsChange(changedItems, (items) => {
      setList(items)
      setArrived(true)
    })
  )
  const remote = useAsyncOptions(pages ? searchCountryPages : searchCountries, {
    immediate: async || pages,
  })
  const fromData = data || async || long || recent || pages
  const items =
    async || pages
      ? remote.items
      : long
        ? longItems()
        : grouped
          ? [
              {
                type: "group" as const,
                label: f.groups[0].label,
                items: f.groups[0].items,
              },
              {
                type: "group" as const,
                label: f.groups[1].label,
                items: f.groups[1].items,
              },
            ]
          : [...list, ...created]
  const onCreate = async (query: string) => {
    setAction(`create:${query}`)
    await createDelay(slow)
    setCreated((list) => [
      ...list,
      { value: query.toLowerCase(), label: query },
    ])
  }
  const labels = new Map(
    [...f.items, ...list, ...created].map((item) => [item.value, item.label])
  )
  const all = [...list, ...created]
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
          <ManyCombobox
            {...options}
            name={f.name}
            container={container}
            items={
              late
                ? arrived
                  ? items
                  : undefined
                : fromData
                  ? items
                  : undefined
            }
            emptyItems={recent ? f.recent : undefined}
            filter={async || pages ? false : undefined}
            status={async || pages ? remote.status : undefined}
            onLoadMore={pages ? remote.loadMore : undefined}
            itemToLabel={
              labelsFromItems
                ? undefined
                : (value) => labels.get(value) ?? value
            }
            onValueChange={(value, details) => {
              if (cancelsValue(value, cancel)) {
                return details.cancel()
              }
              setAction(
                `value:${Array.isArray(value) ? value.join(",") : String(value)}`
              )
            }}
            onQueryChange={(query) =>
              (async || pages) && remote.setQuery(query)
            }
          >
            <ComboboxLabel className="label">{f.label}</ComboboxLabel>
            @if (options.multiple) {
              <ComboboxChips
                className={overflow ? "chips chips-line" : "chips"}
              >
                <Chips labels={labels} />
                @if (overflow) {
                  <ComboboxChipsOverflow className="chips-overflow" />
                }
                <ComboboxInput className="input" />
              </ComboboxChips>
            } @else {
              <ComboboxInput className="input" />
            }
            @if (summary) {
              <output aria-label={f.summary}>
                <ComboboxValue maxLabels={summary} />
              </output>
            }
            <ComboboxTrigger aria-label={f.trigger}>{"▾"}</ComboboxTrigger>
            <ComboboxClear>{f.clear}</ComboboxClear>
            @if (late) {
              <ComboboxContent className="popup list-popup" />
            } @else {
              <ComboboxContent
                className={
                  pages ? "popup list-popup list-short" : "popup list-popup"
                }
              >
                @if (!nostatus) {
                  <ComboboxStatus className="status">
                    {(state: ComboboxStatusState) =>
                      state.loading
                        ? pages
                          ? "Loading more…"
                          : "Loading…"
                        : ""
                    }
                  </ComboboxStatus>
                }
                <ComboboxEmpty className="empty">{f.empty}</ComboboxEmpty>
                @if (fromData) {
                  <ComboboxList>
                    {(state: ComboboxContentState) => (
                      <>
                        @if (selectAll) {
                          <ComboboxSelectAll className="item">
                            {f.selectAll}
                          </ComboboxSelectAll>
                        }
                        <DataItems
                          items={state.items as ListData}
                          highlight={highlight}
                        />
                        @if (create) {
                          <ComboboxCreate
                            className="item"
                            onCreate={onCreate}
                          />
                        }
                      </>
                    )}
                  </ComboboxList>
                } @else {
                  <ComboboxList>
                    @if (selectAll && !grouped) {
                      <ComboboxSelectAll className="item">
                        {f.selectAll}
                      </ComboboxSelectAll>
                    }
                    @if (grouped) {
                      @for (const group of f.groups; key group.label) {
                        <ComboboxGroup>
                          <ComboboxGroupLabel className="label">
                            {group.label}
                          </ComboboxGroupLabel>
                          @if (selectAll) {
                            <ComboboxSelectAll className="item">
                              {`${f.selectAll} ${group.label}`}
                            </ComboboxSelectAll>
                          }
                          @for (const item of group.items; key item.value) {
                            <Item {...item} highlight={highlight} />
                          }
                        </ComboboxGroup>
                      }
                    } @else {
                      @for (const item of all; key item.value) {
                        <Item {...item} highlight={highlight} />
                      }
                    }
                    @if (create) {
                      <ComboboxCreate className="item" onCreate={onCreate} />
                    }
                  </ComboboxList>
                }
              </ComboboxContent>
            }
          </ManyCombobox>
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
    </div>
  )
}

// One chip per selected value.
function Chips({ labels }: { labels: Map<string, string> }) {
  return (
    <ComboboxValue>
      {({ value }: ComboboxValueState) => (
        <>
          @for (const item of value as string[]; key item) {
            <ComboboxChip className="chip" value={item}>
              {labels.get(item) ?? item}
              <ComboboxChipRemove
                aria-label={`Remove ${labels.get(item) ?? item}`}
              >
                {"×"}
              </ComboboxChipRemove>
            </ComboboxChip>
          }
        </>
      )}
    </ComboboxValue>
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
