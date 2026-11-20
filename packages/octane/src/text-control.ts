import type { useFieldControl } from "./field-context.tsrx"
import type { PartProps } from "./use-primitive.tsrx"

// Props an input or textarea takes that the part replaces.
type Native<Tag extends "input" | "textarea", State> = Omit<
  PartProps<Tag, State>,
  "value" | "defaultValue" | "onSelect"
>

// A controlled `value` gets a change handler that does nothing, so it stays
// controlled. `onValueChange` is the change handler here.
const ignore = () => {}

// The native props a text field's state follows, and its change handler.
type TextProps = {
  disabled?: boolean
  readOnly?: boolean
  required?: boolean
  onChange?: unknown
}

// The states a text field's attributes follow, from its own props and its field's.
function controlProps(
  props: TextProps,
  field: ReturnType<typeof useFieldControl>
) {
  return {
    disabled: props.disabled || field?.disabled,
    readOnly: props.readOnly,
    required: props.required,
  }
}

// The element's props: the field's name, the user's props, and the value left
// to Octane, so it stays a native controlled or uncontrolled input.
function elementProps<Props extends TextProps>(
  props: Props,
  field: ReturnType<typeof useFieldControl>,
  value?: string,
  defaultValue?: string
) {
  return {
    name: field?.name,
    ...props,
    value,
    defaultValue,
    onChange: props.onChange ?? (value === undefined ? undefined : ignore),
  }
}

export { controlProps, elementProps, type Native }
