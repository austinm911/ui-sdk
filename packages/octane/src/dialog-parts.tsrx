"use strong"
import type {
  AlertDialogController,
  dialog as dialogPrimitive,
  DialogBackdropState,
  DialogCloseProps,
  DialogCloseState,
  DialogContentProps,
  DialogContentState,
  DialogController,
  DialogOptions,
  DialogShortcutProps,
  DialogShortcutState,
  DialogTriggerProps,
  DialogTriggerState,
} from "@ui-sdk/core/dialog"
import * as React from "octane"
import {
  Connected,
  renderPopup,
  useOwnContainer,
  usePopupContainer,
  usePopupTree,
  useControllerEntry,
  type PopupContainer,
  type sheetViewport,
} from "./popup.tsrx"
import {
  createParts,
  HandleScope,
  mergeRefs,
  renderElement,
  useHandle,
  useNearest,
  usePart,
  usePrimitive,
  type PartProps,
} from "./use-primitive.tsrx"

type TriggerPartProps = Omit<
  PartProps<"button", DialogTriggerState>,
  "value" | "defaultValue" | "onChange" | "onInput"
> &
  Omit<DialogTriggerProps, "controller">
type ContentPartProps<Payload = unknown> = PartProps<
  "div",
  DialogContentState<Payload>
> &
  DialogContentProps
type ClosePartProps = Omit<
  PartProps<"button", DialogCloseState>,
  "value" | "action"
> &
  DialogCloseProps
type ShortcutPartProps = PartProps<"span", DialogShortcutState> &
  DialogShortcutProps

// The trigger a Shortcut part sits in, which may be outside its dialog, and its shortcut.
const TriggerContext = React.createContext<{ shortcut?: string } | null>(null)

const text = (state: DialogShortcutState) => state.text

// Dialog and AlertDialog render the same parts over their own primitive.
// `viewport` renders the viewport around the content, for a dialog that can present as a sheet.
function dialogParts(
  primitive: typeof dialogPrimitive,
  name: string,
  viewport?: typeof sheetViewport
) {
  const parts = createParts(primitive, {
    title: "h2",
    description: "p",
    close: "button",
    trigger: "button",
  })
  const TriggerPart = parts.Trigger
  // Where the popup renders. Set on the root or the content.
  const ContainerContext = React.createContext<PopupContainer>(undefined)

  function Root({
    children,
    container,
    ...options
  }: DialogOptions & { children?: unknown }) {
    const handle = usePrimitive(primitive, options)
    useControllerEntry(options.controller, handle)
    return (
      <HandleScope handle={handle}>
        <ContainerContext value={container}>{children}</ContainerContext>
      </HandleScope>
    )
  }

  function Trigger({
    controller,
    ...props
  }: TriggerPartProps & {
    controller?: DialogController<any, any> | AlertDialogController<any, any>
  }) {
    const {
      disabled,
      focusableWhenDisabled,
      payload: _,
      shortcut,
      render,
      ...rest
    } = props
    // Until the dialog it names mounts, a trigger outside the dialog is a plain button.
    const unconnected = () =>
      renderElement(
        "button",
        {
          type: "button",
          disabled: disabled && !focusableWhenDisabled,
          "aria-disabled": (disabled && focusableWhenDisabled) || undefined,
          ...rest,
        },
        render,
        {
          open: false,
          disabled: !!disabled,
        }
      )
    return (
      <TriggerContext value={{ shortcut }}>
        <Connected
          primitive={primitive}
          controller={controller}
          fallback={unconnected}
        >
          <TriggerPart {...props} />
        </Connected>
      </TriggerContext>
    )
  }

  function Backdrop({ ref, ...props }: PartProps<"div", DialogBackdropState>) {
    const target = usePopupContainer(React.useContext(ContainerContext))
    const tree = usePopupTree()
    const element = usePart(
      primitive,
      "backdrop",
      {},
      {
        ...props,
        ref: mergeRefs<HTMLDivElement>(ref ?? null, tree.track),
      }
    )
    return element && renderPopup(element, target, tree)
  }

  function Content<Payload = unknown>({
    initialFocus,
    finalFocus,
    keepMounted,
    inline,
    container,
    render,
    ref,
    ...props
  }: ContentPartProps<Payload>) {
    const handle = useHandle(primitive)
    const target = usePopupContainer(
      useOwnContainer(container, ContainerContext)
    )
    const tree = usePopupTree()
    // The payload's type is the app's, from `Payload`; the part hands its state on as it is.
    const partProps = {
      ...props,
      ref: inline ? ref : mergeRefs<HTMLDivElement>(ref ?? null, tree.track),
      render: viewport ? viewport(handle, render) : render,
    } as ContentPartProps
    const element = usePart(
      handle,
      "content",
      { initialFocus, finalFocus, keepMounted, inline },
      partProps
    )
    return element && (inline ? element : renderPopup(element, target, tree))
  }

  function Shortcut(props: ShortcutPartProps) {
    const trigger = React.useContext(TriggerContext)
    if (useNearest(primitive)) {
      return <ShortcutPart inherited={trigger?.shortcut} {...props} />
    }
    // Inside a trigger whose dialog hasn't mounted yet, there's no shortcut to show.
    if (trigger) {
      return null
    }
    throw new Error(`${name} parts must be used inside <${name}>.`)
  }

  function ShortcutPart({
    inherited,
    shortcut,
    children = text,
    ...props
  }: ShortcutPartProps & { inherited?: string | undefined }) {
    return usePart(
      primitive,
      "shortcut",
      { shortcut: shortcut ?? inherited },
      { ...props, children },
      "span"
    )
  }

  return {
    Root,
    Trigger,
    Backdrop,
    Content,
    Title: parts.Title,
    Description: parts.Description,
    Close: parts.Close,
    Shortcut,
  }
}

export {
  type ClosePartProps,
  type ContentPartProps,
  dialogParts,
  type ShortcutPartProps,
  type TriggerPartProps,
}
