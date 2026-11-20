"use strong"
import {
  button as buttonPrimitive,
  type ButtonActionDetails,
  type ButtonOptions,
  type ButtonState,
} from "@ui-sdk/core/button"
import {
  renderElement,
  usePart,
  usePrimitive,
  type PartProps,
} from "./use-primitive.tsrx"

type ButtonProps = Omit<PartProps<"button", ButtonState>, "type" | "onClick"> &
  ButtonOptions & {
    /**
     * Runs when the button is pressed. Return a Promise to make the button
     * pending until it settles: it gets `aria-busy`, `aria-disabled` and
     * `data-pending`, keeps focus, ignores presses meanwhile, so a form can't
     * submit twice, and says `pendingAnnouncement` after a second.
     * The event's element is whatever `render` renders, like a link.
     * `details.source` says how it was pressed, for changes made after an `await`.
     */
    onClick?: (event: MouseEvent, details: ButtonActionDetails) => unknown
  }

/**
 * A button, or a link or any element that acts as one through `render`.
 * @stable
 */
function Button({
  disabled,
  focusableWhenDisabled,
  type,
  pendingAnnouncement,
  debug,
  onClick,
  render,
  ...props
}: ButtonProps) {
  const button = usePrimitive(buttonPrimitive, {
    disabled,
    focusableWhenDisabled,
    type,
    pendingAnnouncement,
    debug,
  })
  // Octane hands the handler the DOM's own event, which the part presses with.
  const press = (event: MouseEvent) => {
    button.api.internal.press(event, (details) => onClick?.(event, details))
  }
  return usePart(
    button,
    "root",
    {},
    {
      ...props,
      render: (root: Record<string, any>, state: ButtonState) =>
        renderElement("button", { ...root, onClick: press }, render, state),
    },
    "button"
  )
}

export { Button }
export type {
  ButtonActionDetails,
  ButtonApi,
  ButtonOptions,
  ButtonPrimitive,
  ButtonState,
} from "@ui-sdk/core/button"
