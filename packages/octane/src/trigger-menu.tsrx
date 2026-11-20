"use strong"
import {
  triggerMenu as triggerMenuPrimitive,
  type TriggerMenuContentProps,
  type TriggerMenuContentState,
  type TriggerMenuData,
  type TriggerMenuEmptyState,
  type TriggerMenuHintState,
  type TriggerMenuItemProps,
  type TriggerMenuItemState,
  type TriggerMenuOptions,
  type TriggerMenuStatusState,
} from "@ui-sdk/core/trigger-menu"
import * as React from "octane"
import { isStateFunction } from "./render-element.tsrx"
import { Placed, usePlaceContent, usePlacedContent } from "./children.tsrx"
import { EditorContext } from "./editor-context"
import {
  renderPopup,
  useControllerEntry,
  useOwnContainer,
  usePopupContainer,
  usePopupTree,
  type PopupContainer,
} from "./popup.tsrx"
import { ListItems, type ListParts } from "./list-items.tsrx"
import {
  createParts,
  HandleScope,
  mergeRefs,
  useHandle,
  usePart,
  usePrimitive,
  type PartProps,
} from "./use-primitive.tsrx"

const parts = createParts(triggerMenuPrimitive, {
  input: "textarea",
  item: "div",
  "item-icon": "span",
  group: "div",
  "group-label": "div",
  separator: "div",
})

const ContainerContext = React.createContext<PopupContainer>(undefined)

function useTriggerMenu() {
  return useHandle(triggerMenuPrimitive)
}

type Clashing = "value" | "defaultValue" | "onChange" | "onSelect" | "onInput"

/**
 * The props of `TriggerMenu`.
 * @stable
 */
type TriggerMenuProps<T = string> = TriggerMenuOptions<T> & {
  children?: unknown
}

/**
 * Suggestions opened by a trigger like `@` or `/` in text. Inside a TokenInput
 * it uses that editor; otherwise render a TriggerMenuInput, or pass `editor`.
 * @stable
 */
function TriggerMenu<T = string>({
  children,
  container,
  editor,
  ...options
}: TriggerMenuProps<T>) {
  const inherited = React.useContext(EditorContext)
  const menu = usePrimitive(triggerMenuPrimitive, {
    ...(options as TriggerMenuOptions<any>),
    editor: editor ?? inherited,
  })
  useControllerEntry(options.controller, menu)
  // A data menu renders its list, unless the app placed a
  // TriggerMenuContent, which says so as it mounts.
  const [renderOwn, place] = usePlacedContent()
  return (
    <HandleScope handle={menu}>
      <ContainerContext value={container}>
        <Placed value={place}>{children}</Placed>
        <Placed value={null}>
          @if (renderOwn) {
            <TriggerMenuContent />
          }
        </Placed>
      </ContainerContext>
    </HandleScope>
  )
}

/**
 * The text field the menu suggests into: a `<textarea>`, or an `<input>` through `render`.
 * @stable
 */
const TriggerMenuInput = parts.Input

/**
 * The popup that holds the suggestions, anchored at the caret.
 * @stable
 */
function TriggerMenuContent({
  side,
  align,
  sideOffset,
  alignOffset,
  collisionPadding,
  arrowPadding,
  anchor,
  keepMounted,
  container,
  children = defaultContent,
  ref,
  ...props
}: PartProps<"div", TriggerMenuContentState> & TriggerMenuContentProps) {
  usePlaceContent()
  const target = usePopupContainer(useOwnContainer(container, ContainerContext))
  const tree = usePopupTree()
  const content = {
    side,
    align,
    sideOffset,
    alignOffset,
    collisionPadding,
    arrowPadding,
    anchor,
    keepMounted,
  }
  const element = usePart(triggerMenuPrimitive, "content", content, {
    ...props,
    ref: mergeRefs<HTMLDivElement>(ref, tree.track),
    children,
  })
  return element && renderPopup(element, target, tree)
}

// Without content, the popup shows the list.
function defaultContent() {
  return <TriggerMenuList />
}

/**
 * The listbox. Without children, it renders the current trigger's items, filtered.
 * @stable
 */
function TriggerMenuList({
  children = listItems,
  ...props
}: PartProps<"div", TriggerMenuContentState>) {
  return usePart(triggerMenuPrimitive, "list", {}, { ...props, children })
}

const listItems = (state: TriggerMenuContentState) => (
  <TriggerMenuItems items={state.items} />
)

/**
 * A suggestion. Choosing it inserts it into the text.
 * @stable
 */
const TriggerMenuItem = parts.Item as <T = string>(
  props: Omit<PartProps<"div", TriggerMenuItemState>, Clashing> &
    TriggerMenuItemProps<T>
) => unknown

/**
 * An icon inside a suggestion. Screen readers, typeahead and filtering skip it, and `mirror` flips
 * it in right-to-left text.
 * @stable
 */
const TriggerMenuItemIcon = parts.ItemIcon

/**
 * A group of items, named by its `TriggerMenuGroupLabel`.
 * @stable
 */
const TriggerMenuGroup = parts.Group

/**
 * The group's heading, which names the group.
 * @stable
 */
const TriggerMenuGroupLabel = parts.GroupLabel

/**
 * A line between items or groups, hidden from screen readers.
 * @stable
 */
const TriggerMenuSeparator = parts.Separator

/**
 * Shown while no item matches. Rendering it keeps the menu open with no matches; without it, the menu closes until something matches.
 * @stable
 */
function TriggerMenuEmpty({
  children,
  ...props
}: PartProps<"div", TriggerMenuEmptyState>) {
  const content = (state: TriggerMenuEmptyState) =>
    isStateFunction(children) ? children(state) : state.empty ? children : null
  return usePart(
    triggerMenuPrimitive,
    "empty",
    {},
    { ...props, children: content }
  )
}

/**
 * A polite status, outside the popup. Without children, it says the count and the keys once typing pauses.
 * @stable
 */
function TriggerMenuStatus(props: PartProps<"div", TriggerMenuStatusState>) {
  return usePart(
    triggerMenuPrimitive,
    "status",
    { text: props.children === undefined },
    props
  )
}

/**
 * Ghost text at the caret for the arguments still to type, like `<name>`. Without children, the hints.
 * @stable
 */
function TriggerMenuHint(props: PartProps<"span", TriggerMenuHintState>) {
  return usePart(
    triggerMenuPrimitive,
    "hint",
    { text: props.children === undefined },
    props,
    "span"
  )
}

/**
 * Renders data items. Used by data menus, and available for custom layouts.
 * @stable
 */
function TriggerMenuItems({ items }: { items: TriggerMenuData<any> }) {
  const menu = useTriggerMenu()
  return (
    <ListItems
      items={items}
      parts={listParts}
      keyOf={menu.api.internal.keyOf}
    />
  )
}

const listParts: ListParts = {
  Item: TriggerMenuItem,
  Group: TriggerMenuGroup,
  GroupLabel: TriggerMenuGroupLabel,
  Separator: TriggerMenuSeparator,
}

export {
  createTriggerMenuController,
  textFieldAdapter,
} from "@ui-sdk/core/trigger-menu"
export type {
  EditorChange,
  EditorReplaceOptions,
  ListFilter,
  ListItem,
  ListSeparator,
  TextEditorAdapter,
  TextRange,
  TextRect,
  Token,
  TokenInsert,
  TriggerAfter,
  TriggerArgument,
  TriggerBoundary,
  TriggerDefinition,
  TriggerItemsLoader,
  TriggerMatch,
  TriggerMenuApi,
  TriggerMenuChangeOptions,
  TriggerMenuContentProps,
  TriggerMenuContentState,
  TriggerMenuController,
  TriggerMenuData,
  TriggerMenuDataGroup,
  TriggerMenuDataItem,
  TriggerMenuDismissReason,
  TriggerMenuEmptyState,
  TriggerMenuHintState,
  TriggerMenuInputState,
  TriggerMenuItemIconProps,
  TriggerMenuItemIconState,
  TriggerMenuItemProps,
  TriggerMenuItemState,
  TriggerMenuOpenChangeReason,
  TriggerMenuOptions,
  TriggerMenuPrimitive,
  TriggerMenuQueryChangeReason,
  TriggerMenuSelectDetails,
  TriggerMenuStatusState,
  TriggerRule,
} from "@ui-sdk/core/trigger-menu"

export {
  TriggerMenu,
  TriggerMenuContent,
  TriggerMenuEmpty,
  TriggerMenuGroup,
  TriggerMenuGroupLabel,
  TriggerMenuHint,
  TriggerMenuInput,
  TriggerMenuItem,
  TriggerMenuItemIcon,
  TriggerMenuItems,
  TriggerMenuList,
  type TriggerMenuProps,
  TriggerMenuSeparator,
  TriggerMenuStatus,
}
