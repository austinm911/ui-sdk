"use strong"
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandGroupLabel,
  CommandInput,
  CommandItem,
  CommandItemText,
  CommandList,
  CommandPage,
  CommandSeparator,
  CommandShortcut,
  CommandStatus,
  type CommandData,
  type CommandDataItem,
  type CommandListState,
  type CommandStatusState,
} from "@ui-sdk/octane/command"
import * as React from "octane"
import { createRoot } from "octane"
import {
  commandData,
  commandFixture as f,
  commandOptions,
  runAction,
} from "tests/fixtures/command.ts"
import { longItems } from "tests/fixtures/select.ts"

type GroupItem = {
  value: string
  label: string
  keywords?: string[]
  disabled?: boolean
  shortcut?: string
  page?: string
}

// The composed groups, each item with every field it may have.
const groups: { label: string; items: GroupItem[] }[] = f.groups

function Fixture({ data = false }: { data?: boolean }) {
  const { slow, fail, long, highlight, unvalued, ...options } =
    React.useInitialValue(commandOptions)
  const [action, setAction] = React.useState("")
  const [lastHighlight, setLastHighlight] = React.useState("")
  const items = React.useInitialValue(() =>
    long ? longItems() : data ? commandData() : undefined
  )
  const onAction = (value: string) => {
    setAction(`action:${value}`)
    return runAction(slow, fail)
  }
  // Passed as the `children` prop: between tags, Octane would compile it
  // into a render block, which never gets the list's state.
  const commands = items ? (
    (state: CommandListState) => (
      <DataCommands items={state.items} highlight={highlight} />
    )
  ) : (
    <>
      <CommandPage>
        @for (const group of groups; key group.label) {
          <>
            @if (group !== groups[0]) {
              <CommandSeparator className="separator" />
            }
            <CommandGroup>
              <CommandGroupLabel className="label">
                {group.label}
              </CommandGroupLabel>
              @for (const item of group.items; key item.value) {
                <CommandItem
                  className="item"
                  value={unvalued ? undefined : item.value}
                  keywords={item.keywords}
                  disabled={item.disabled}
                  shortcut={item.shortcut}
                  page={item.page}
                >
                  @if (highlight) {
                    <CommandItemText>{item.label}</CommandItemText>
                  } @else {
                    <>{item.label}</>
                  }
                  @if (item.shortcut) {
                    <CommandShortcut className="shortcut" />
                  }
                </CommandItem>
              }
            </CommandGroup>
          </>
        }
      </CommandPage>
      <CommandPage value="theme">
        @for (const item of f.theme; key item.value) {
          <CommandItem className="item" value={item.value}>
            {item.label}
          </CommandItem>
        }
      </CommandPage>
    </>
  )
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Command
        {...options}
        className="command"
        items={items}
        onAction={onAction}
        onValueChange={(value, details) =>
          setLastHighlight(`${value}:${details.reason}`)
        }
      >
        <CommandInput className="input" aria-label={f.input} />
        <CommandEmpty className="empty">{f.empty}</CommandEmpty>
        <CommandStatus className="status">
          {(state: CommandStatusState) => (state.loading ? "Loading…" : "")}
        </CommandStatus>
        <CommandList className="command-list" children={commands} />
      </Command>
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
      <output role="status" aria-label="Last highlight">
        {lastHighlight}
      </output>
    </div>
  )
}

// Separators and unlabeled groups have nothing that names them, so each
// keeps the id it first got.
const entryIds = new WeakMap<object, number>()
const entryCount = { last: 0 }

function entryKey(entry: CommandData[number]) {
  if (typeof entry === "string") {
    return entry
  }
  if ("type" in entry) {
    if (entry.type === "group" && entry.label) {
      return `group-${entry.label}`
    }
    let id = entryIds.get(entry)
    if (id === undefined) {
      entryIds.set(entry, (id = ++entryCount.last))
    }
    return `${entry.type}-${id}`
  }
  return entry.value
}

// The data's commands, groups and separators, styled like the composed ones.
function DataCommands({
  items,
  highlight,
}: {
  items: CommandData
  highlight?: boolean
}) @{
  const rows = items.map((entry) => ({ entry, key: entryKey(entry) }))
  @for (const row of rows; key row.key) {
    <DataCommand entry={row.entry} highlight={highlight} />
  }
}

function DataCommand({
  entry,
  highlight,
}: {
  entry: CommandData[number]
  highlight?: boolean
}) {
  if (typeof entry !== "string" && "type" in entry) {
    if (entry.type === "separator") {
      return <CommandSeparator className="separator" />
    }
    return (
      <CommandGroup>
        @if (entry.label) {
          <CommandGroupLabel className="label">{entry.label}</CommandGroupLabel>
        }
        <DataCommands items={entry.items} highlight={highlight} />
      </CommandGroup>
    )
  }
  const command: CommandDataItem =
    typeof entry === "string" ? { value: entry, label: entry } : entry
  return (
    <CommandItem
      className="item"
      value={command.value}
      label={command.label}
      keywords={command.keywords}
      disabled={command.disabled}
      shortcut={command.shortcut}
    >
      @if (highlight) {
        <CommandItemText>{command.label}</CommandItemText>
      } @else {
        <>{command.label}</>
      }
      @if (command.shortcut) {
        <CommandShortcut className="shortcut" />
      }
    </CommandItem>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
