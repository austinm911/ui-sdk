"use strong"
import type { ListData } from "@ui-sdk/core/select"

type Part = (props: any) => unknown

// The parts a list renders its data with, which every list component has.
type ListParts = {
  Item: Part
  Group: Part
  GroupLabel: Part
  Separator: Part
}

type Entry = ListData<any>[number]

// Renders a list's data with its parts: an option per item, groups with their
// labels, and separators. Keyed by each item's key, and each group by its
// label, so a filtered list keeps its options.
function ListItems({
  items,
  parts,
  keyOf,
}: {
  items: readonly Entry[]
  parts: ListParts
  keyOf: (value: unknown) => string
}) @{
  const rows = items.map((entry) => ({ entry, key: entryKey(entry, keyOf) }))
  @for (const row of rows; key row.key) {
    <ListEntry entry={row.entry} parts={parts} keyOf={keyOf} />
  }
}

// Separators and unlabeled groups have nothing that names them, so each
// keeps the id it first got, for as long as the app keeps its object.
const entryIds = new WeakMap<object, number>()
const entryCount = { last: 0 }

function entryKey(entry: Entry, keyOf: (value: unknown) => string) {
  if (typeof entry === "string") {
    return entry
  }
  if ("type" in entry && entry.type === "group" && entry.label) {
    return `group-${entry.label}`
  }
  if ("type" in entry) {
    let id = entryIds.get(entry)
    if (id === undefined) {
      entryIds.set(entry, (id = ++entryCount.last))
    }
    return `${entry.type}-${id}`
  }
  return keyOf((entry as { value: unknown }).value)
}

function ListEntry({
  entry,
  parts,
  keyOf,
}: {
  entry: Entry
  parts: ListParts
  keyOf: (value: unknown) => string
}) {
  const { Item, Group, GroupLabel, Separator } = parts
  if (typeof entry === "string") {
    return <Item value={entry}>{entry}</Item>
  }
  if ("type" in entry && entry.type === "separator") {
    return <Separator />
  }
  if ("type" in entry && entry.type === "group") {
    return (
      <Group>
        @if (entry.label) {
          <GroupLabel>{entry.label}</GroupLabel>
        }
        <ListItems items={entry.items} parts={parts} keyOf={keyOf} />
      </Group>
    )
  }
  const { value, label, disabled, keywords } = entry as {
    value: unknown
    label: string
    disabled?: boolean
    keywords?: string[]
  }
  return (
    <Item
      value={value}
      label={label}
      disabled={disabled}
      {...(keywords && { keywords })}
    >
      {label}
    </Item>
  )
}

export { ListItems, type ListParts }
