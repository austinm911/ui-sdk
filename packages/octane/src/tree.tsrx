"use strong"
import {
  tree as treePrimitive,
  type TreeItemData,
  type TreeItemProps,
  type TreeItemState,
  type TreeOptions,
  type TreeState,
  type TreeMode,
} from "@ui-sdk/core/tree"
import * as React from "octane"
import {
  createParts,
  readIn,
  useHandle,
  usePart,
  usePrimitive,
  type PartProps,
} from "./use-primitive.tsrx"

const parts = createParts(treePrimitive, {
  label: "span",
  indicator: "span",
  checkbox: "span",
  group: "div",
})

// The item the items in a group belong to.
const ItemContext = React.createContext<string | null>(null)
// How a TreeGroup tells the item around it that it's there.
const GroupContext = React.createContext<(() => () => void) | null>(null)

// How many groups an item holds. A store, so a group mounting re-renders
// its item through useSyncExternalStore, not a state update from an effect.
function groupStore() {
  let count = 0
  const listeners = new Set<() => void>()
  const notify = () => listeners.forEach((listener) => listener())
  return {
    subscribe(listener: () => void) {
      listeners.add(listener)
      return () => {
        listeners.delete(listener)
      }
    },
    grouped: () => count > 0,
    register() {
      count++
      notify()
      return () => {
        count--
        notify()
      }
    },
  }
}

// Element props that mean something else on a tree part.
type Clashing =
  | "value"
  | "defaultValue"
  | "defaultChecked"
  | "onChange"
  | "onInput"
  | "onSelect"

/**
 * The props of `Tree`.
 * @stable
 */
type TreeProps<Mode extends TreeMode = "single"> = Omit<
  PartProps<"div", TreeState>,
  Clashing | keyof TreeOptions
> &
  TreeOptions<Mode> & {}

/**
 * A tree of items that expand and collapse, with one tab stop and arrow keys between its items.
 * @stable
 */
function Tree<Mode extends TreeMode = "single">({
  items,
  paths,
  mode,
  value,
  defaultValue,
  onValueChange,
  activation,
  expanded,
  defaultExpanded,
  onExpandedChange,
  expandOnPress,
  checkable,
  checked,
  defaultChecked,
  onCheckedChange,
  checkStrategy,
  onAction,
  pendingAnnouncement,
  loadChildren,
  current,
  onHighlight,
  disabled,
  focusableWhenDisabled,
  keepMounted,
  hiddenUntilFound,
  announcement,
  controller,
  debug,
  children,
  ...props
}: TreeProps<Mode>) {
  const tree = usePrimitive(treePrimitive, {
    items,
    paths,
    mode,
    value,
    defaultValue,
    onValueChange,
    activation,
    expanded,
    defaultExpanded,
    onExpandedChange,
    expandOnPress,
    checkable,
    checked,
    defaultChecked,
    onCheckedChange,
    checkStrategy,
    onAction,
    pendingAnnouncement,
    loadChildren,
    current,
    onHighlight,
    disabled,
    focusableWhenDisabled,
    keepMounted,
    hiddenUntilFound,
    announcement,
    controller,
    debug,
  } as TreeOptions)
  // Without children, a data tree renders its items.
  const data = readIn(tree, () => tree.api.internal.items())
  const content = children ?? (data && <TreeItems items={data} />)
  const element = usePart(tree, "root", {}, { ...props, children: content })
  return <ItemContext value={null}>{element}</ItemContext>
}

/**
 * An item. Put its text in a `TreeItemLabel` and its children in a
 * `TreeGroup`, which makes it a branch. Set `branch` for one whose children
 * load later, or whose group is inside a component of your own.
 * @stable
 */
function TreeItem({
  value,
  branch,
  disabled,
  label,
  children,
  ...props
}: Omit<PartProps<"div", TreeItemState>, Clashing> &
  Omit<TreeItemProps, "parent">) {
  const parent = React.useContext(ItemContext)
  // A branch is one with a group among its children. Octane can't read the
  // children, so a TreeGroup registers as it commits, which re-renders the
  // item as a branch.
  const groups = React.useInitialValue(groupStore)
  const grouped = React.useSyncExternalStore(groups.subscribe, groups.grouped)
  const item = {
    value,
    parent,
    branch: branch ?? (grouped || undefined),
    disabled,
    label,
  }
  const element = usePart(treePrimitive, "item", item, { ...props, children })
  return (
    <ItemContext value={value}>
      <GroupContext value={groups.register}>{element}</GroupContext>
    </ItemContext>
  )
}

/**
 * The item's text, which names it. Render it as a link to make the item one.
 * @stable
 */
const TreeItemLabel = parts.Label

/**
 * The arrow that expands and collapses a branch. Alt or Option expands everything in it.
 * @stable
 */
const TreeItemIndicator = parts.Indicator

/**
 * The item's checkbox, with `checkable`. Screen readers hear the item's checked state instead.
 * @stable
 */
const TreeItemCheckbox = parts.Checkbox

/**
 * A branch's children. Rendered while the branch is expanded or animating closed.
 * @stable
 */
function TreeGroup(props: Parameters<typeof parts.Group>[0]) {
  const register = React.useContext(GroupContext)
  React.useLayoutEffect(() => register?.())
  const Group = parts.Group
  return <Group {...props} />
}

/**
 * Renders data items. Used by data trees, and available for custom layouts.
 * @stable
 */
function TreeItems({ items }: { items: TreeItemData[] }) @{
  const tree = useHandle(treePrimitive)
  const checkable = tree.state.checkable
  @for (const item of items; key item.value) {
    <TreeItem
      value={item.value}
      branch={item.children !== undefined}
      disabled={item.disabled}
    >
      @if (checkable) {
        <TreeItemCheckbox />
      }
      <TreeItemLabel render={item.href ? linkTo(item.href) : undefined}>
        {item.label}
      </TreeItemLabel>
      @if (item.children) {
        <TreeGroup>
          <TreeItems items={item.children} />
        </TreeGroup>
      }
    </TreeItem>
  }
}

// A label rendered as a link to `href`.
const linkTo = (href: string) => (props: Record<string, any>) => (
  <a {...props} href={href} />
)

export {
  createTreeController,
  toggleTreeChecked,
  treeCheckedStates,
  treeFromPaths,
  visibleTreeRows,
} from "@ui-sdk/core/tree"
export type {
  ListHighlightDetails,
  TreeActionDetails,
  TreeAnnouncement,
  TreeApi,
  TreeChangeOptions,
  TreeCheckStrategy,
  TreeCheckedChangeReason,
  TreeCheckedState,
  TreeCollection,
  TreeCollectionNode,
  TreeController,
  TreeExpandedChangeReason,
  TreeGroupProps,
  TreeGroupState,
  TreeItemData,
  TreeItemPartProps,
  TreeItemProps,
  TreeItemState,
  TreeOptions,
  TreePrimitive,
  TreeState,
  TreeRow,
  TreeMode,
  TreeValue,
  TreeValueChangeReason,
} from "@ui-sdk/core/tree"

export {
  Tree,
  TreeGroup,
  TreeItem,
  TreeItemCheckbox,
  TreeItemIndicator,
  TreeItemLabel,
  TreeItems,
  type TreeProps,
}
