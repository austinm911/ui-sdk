"use strong"
import {
  command as commandPrimitive,
  type CommandData,
  type CommandEmptyState,
  type CommandItemProps,
  type CommandItemState,
  type CommandItemTextState,
  type CommandListState,
  type CommandOptions,
  type CommandPageProps,
  type CommandState,
  type CommandShortcutProps,
  type CommandShortcutState,
} from "@ui-sdk/core/command"
import * as React from "octane"
import { isStateFunction, mergeRefs } from "./render-element.tsrx"
import { Placed, usePlaceContent, usePlacedContent } from "./children.tsrx"
import { useControllerEntry } from "./controller-target.tsrx"
import { useItemText } from "./list-text.tsrx"
import {
  createParts,
  useAround,
  useHandle,
  usePart,
  usePrimitive,
  type PartProps,
} from "./use-primitive.tsrx"

const parts = createParts(commandPrimitive, {
  input: "input",
  "item-icon": "span",
  group: "div",
  "group-label": "div",
  separator: "div",
  status: "div",
})

// The page parts sit on: `null` for the first page, undefined outside any page.
const PageContext = React.createContext<string | null | undefined>(undefined)
// Set while rendering data commands, whose shortcuts the root binds.
const DataContext = React.createContext(false)

function useCommand() {
  return useHandle(commandPrimitive)
}

type Clashing = "value" | "defaultValue" | "onChange" | "onSelect" | "onInput"

/**
 * The props of `Command`.
 * @stable
 */
type CommandProps = CommandOptions &
  Omit<PartProps<"div", CommandState>, Clashing>

/**
 * A search field over an always-open list of commands. Renders a `div` around them.
 * @stable
 */
function Command({
  value,
  defaultValue,
  onValueChange,
  query,
  defaultQuery,
  onQueryChange,
  pages,
  defaultPages,
  onPagesChange,
  onAction,
  pendingAnnouncement,
  items,
  emptyItems,
  filter,
  autoHighlight,
  loop,
  status,
  onLoadMore,
  announcement,
  controller,
  debug,
  children,
  ...props
}: CommandProps) {
  const command = usePrimitive(commandPrimitive, {
    value,
    defaultValue,
    onValueChange,
    query,
    defaultQuery,
    onQueryChange,
    pages,
    defaultPages,
    onPagesChange,
    onAction,
    pendingAnnouncement,
    items,
    emptyItems,
    filter,
    autoHighlight,
    loop,
    status,
    onLoadMore,
    announcement,
    controller,
    debug,
  })
  useControllerEntry(controller, command)
  // A data command renders its list, unless the app placed a CommandList,
  // which says so as it mounts.
  const [renderOwn, place] = usePlacedContent()
  const content = (state: CommandState) =>
    isStateFunction(children) ? (
      <Placed value={place}>{children(state)}</Placed>
    ) : (
      <>
        <Placed value={place}>{children}</Placed>
        <Placed value={null}>
          @if (items && renderOwn) {
            <CommandList />
          }
        </Placed>
      </>
    )
  return usePart(command, "root", {}, { ...props, children: content })
}

/**
 * The search field. It keeps focus while arrow keys move the highlight. Name it with `aria-label`.
 * @stable
 */
const CommandInput = parts.Input

/**
 * The listbox. Without children, it renders the command's `items`, ranked as the user types.
 * @stable
 */
function CommandList({
  children,
  ...props
}: PartProps<"div", CommandListState>) {
  usePlaceContent()
  const command = useCommand()
  const content = (state: CommandListState) =>
    isStateFunction(children)
      ? children(state)
      : (children ??
        (command.state.items ? <CommandItems items={state.items} /> : null))
  return usePart(command, "list", {}, { ...props, children: content })
}

/**
 * A command. Pressing it, or Enter while it's highlighted, runs it, with its `value` passed to the command's
 * `onAction`.
 * @stable
 */
function CommandItem({
  value,
  label,
  keywords,
  disabled,
  shortcut,
  page,
  index,
  onSelect,
  render,
  ...props
}: Omit<PartProps<"div", CommandItemState>, Clashing> & CommandItemProps) {
  const command = useCommand()
  const generated = React.useId()
  const group = useAround(commandPrimitive, "group")?.id as string | undefined
  const inPage = React.useContext(PageContext)
  const data = React.useContext(DataContext)
  const key = value ?? generated
  const item = {
    id: key,
    value: key,
    label,
    keywords,
    disabled,
    shortcut,
    page,
    index,
    onSelect,
    group,
    inPage,
    data,
  }
  // The parts inside read its key, label and shortcut.
  return usePart(command, "item", item, { ...props, render })
}

/**
 * The command's text, with the part the search matched in `<mark>`. Without string content, it shows the command's label.
 * @stable
 */
function CommandItemText({
  children,
  ref,
  ...props
}: PartProps<"span", CommandItemTextState>) {
  const item = useAround(commandPrimitive, "item")
  if (!item) {
    throw new Error("<CommandItemText> must be used inside <CommandItem>.")
  }
  const label = (item.label as string | undefined) ?? (item.value as string)
  const itemText = useItemText(children, item.value as string, label)
  const part = { id: item.value as string, text: itemText.text }
  const content = isStateFunction(children)
    ? children
    : (state: CommandItemTextState) => itemText.content(state.segments)
  return usePart(
    commandPrimitive,
    "item-text",
    part,
    {
      ...props,
      ref: mergeRefs<HTMLSpanElement>(ref, itemText.ref),
      children: content,
    },
    "span"
  )
}

/**
 * An icon inside a command. Screen readers, typeahead and filtering skip it, and `mirror` flips it
 * in right-to-left text.
 * @stable
 */
const CommandItemIcon = parts.ItemIcon

/**
 * The keys of a command's shortcut, formatted for the platform. Inside a command, its `shortcut`.
 * @stable
 */
function CommandShortcut({
  shortcut,
  children = text,
  ...props
}: PartProps<"span", CommandShortcutState> & CommandShortcutProps) {
  const inherited = useAround(commandPrimitive, "item")?.shortcut as
    string | undefined
  return usePart(
    commandPrimitive,
    "shortcut",
    { shortcut: shortcut ?? inherited },
    { ...props, children },
    "span"
  )
}

const text = (state: CommandShortcutState) => state.text

/**
 * Commands shown while this page is on top. Without `value`, it's the first page. Renders no element.
 * @stable
 */
function CommandPage({
  value,
  children,
}: CommandPageProps & { children?: unknown }) {
  // Its presence, without an element.
  const page = () => <PageContext value={value ?? null}>{children}</PageContext>
  return usePart(commandPrimitive, "page", { value }, { render: page })
}

/**
 * A group of commands. It hides while none of its commands matches the search.
 * @stable
 */
const CommandGroup = parts.Group

/**
 * A group's heading, which names it.
 * @stable
 */
const CommandGroupLabel = parts.GroupLabel

/**
 * A line between groups. Composed separators hide while the list is filtered.
 * @stable
 */
const CommandSeparator = parts.Separator

/**
 * Shown while no command matches. Its message is announced when it appears. Place it outside the list.
 * @stable
 */
function CommandEmpty({
  children,
  ...props
}: PartProps<"div", CommandEmptyState>) {
  const content = (state: CommandEmptyState) =>
    isStateFunction(children) ? children(state) : state.empty ? children : null
  return usePart(commandPrimitive, "empty", {}, { ...props, children: content })
}

/**
 * A polite live region for loading and result counts. Its content is yours, usually a function of its state.
 * @stable
 */
const CommandStatus = parts.Status

/**
 * Renders data commands. Used by data command lists, and available for custom layouts.
 * @stable
 */
function CommandItems({ items }: { items: CommandData }) @{
  const rows = items.map((entry) => ({ entry, key: commandKey(entry) }))
  <DataContext value={true}>
    @for (const row of rows; key row.key) {
      <CommandEntry entry={row.entry} />
    }
  </DataContext>
}

// Separators and unlabeled groups have nothing that names them, so each
// keeps the id it first got, for as long as the app keeps its object.
const entryIds = new WeakMap<object, number>()
const entryCount = { last: 0 }

function commandKey(entry: CommandData[number]) {
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
  return entry.value
}

function CommandEntry({ entry }: { entry: CommandData[number] }) {
  if (typeof entry === "string") {
    return <CommandItem value={entry}>{entry}</CommandItem>
  }
  if ("type" in entry && entry.type === "separator") {
    return <CommandSeparator />
  }
  if ("type" in entry && entry.type === "group") {
    return (
      <CommandGroup>
        @if (entry.label) {
          <CommandGroupLabel>{entry.label}</CommandGroupLabel>
        }
        <CommandItems items={entry.items} />
      </CommandGroup>
    )
  }
  return (
    <CommandItem
      value={entry.value}
      label={entry.label}
      keywords={entry.keywords}
      disabled={entry.disabled}
      shortcut={entry.shortcut}
    >
      {entry.label}
    </CommandItem>
  )
}

export { createCommandController } from "@ui-sdk/core/command"
export type {
  CommandActionDetails,
  CommandApi,
  CommandChangeOptions,
  CommandController,
  CommandData,
  CommandDataGroup,
  CommandDataItem,
  CommandEmptyState,
  CommandInputState,
  CommandItemIconProps,
  CommandItemIconState,
  CommandItemProps,
  CommandItemState,
  CommandItemTextState,
  CommandListState,
  CommandOptions,
  CommandPageProps,
  CommandPagesChangeReason,
  CommandPrimitive,
  CommandQueryChangeReason,
  CommandState,
  CommandShortcutProps,
  CommandShortcutState,
  CommandStatusState,
  CommandValueChangeDetails,
  CommandValueChangeReason,
  ListAnnouncement,
  ListFilter,
  ListSeparator,
  MatchSegment,
  SearchFilter,
} from "@ui-sdk/core/command"

export {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandGroupLabel,
  CommandInput,
  CommandItem,
  CommandItemIcon,
  CommandItems,
  CommandItemText,
  CommandList,
  CommandPage,
  type CommandProps,
  CommandSeparator,
  CommandShortcut,
  CommandStatus,
}
