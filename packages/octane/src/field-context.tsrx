"use strong"
import type { field } from "@ui-sdk/core/field"
import { fieldControlId, madeLabel, renderVersion } from "@ui-sdk/core/renderer"
import * as React from "octane"
import {
  renderElement,
  slotIn,
  type PartProps,
  type PrimitiveHandle,
  type RenderProp,
} from "./use-primitive.tsrx"

// The field's context, apart from its parts, so a control can join a field
// without bundling the field.
type FieldContextValue = PrimitiveHandle<typeof field> & {
  name?: string
  disabled?: boolean
}

const FieldContext = React.createContext<FieldContextValue | null>(null)

const noop = () => () => {}
const zero = () => 0

/**
 * Controls inside a field take its name and disabled state, and its ids and
 * validity through the field's control slot. Null outside a field. The control
 * re-renders when the field changes, like when its label or errors appear.
 * The control takes the field's id, so the label points at it from the
 * server's HTML on, unless its own props give one. A control whose component
 * makes the id it renders, like a select's trigger, passes those props as `own`.
 * @stable
 */
function useFieldControl(own?: { id?: string }) {
  return useJoinField(React.useContext(FieldContext), own)
}

// `useFieldControl` for one field, or null for none, for a control that joins
// only some of the fields around it, like a radio, which leaves its group's
// field to the group and doesn't re-render with it.
function useJoinField(field: FieldContextValue | null, own?: { id?: string }) {
  const version = field ? () => renderVersion(field.instance) : zero
  React.useSyncExternalStore(
    field ? field.instance.subscribe : noop,
    version,
    version
  )
  if (!field) {
    return null
  }
  return {
    name: field.name,
    disabled: field.disabled,
    // Merges the field's attributes for its control into the control's props,
    // keeping the control's own description ahead of the field's. The field
    // decides the id.
    props: (props: Record<string, any>) => {
      const label = props["aria-labelledby"]
      const merged = slotIn(
        field,
        "control",
        { id: (own ?? props).id, describedBy: props["aria-describedby"] },
        {
          ...props,
          id: undefined,
          "aria-labelledby": madeLabel(label) ? undefined : label,
        }
      )
      // The field's label names the control over the control's own, like a
      // ComboboxLabel's, but not over the author's. The control stays its own
      // part for styling.
      return {
        ...merged,
        "aria-labelledby": merged["aria-labelledby"] ?? label,
        "data-slot": props["data-slot"],
      }
    },
  }
}

/**
 * A control's `render`: its element, with the field's attributes for its
 * control merged in when it's in a field, and then `after`, like the hidden
 * native input of a checkbox.
 */
function controlRender<State>(
  field: ReturnType<typeof useFieldControl>,
  tag: string,
  render?: RenderProp<State>,
  after?: unknown
) {
  if (!field && !after) {
    return render
  }
  return (props: Record<string, any>, state: State) => (
    <>
      {renderElement(tag, field ? field.props(props) : props, render, state)}
      {after}
    </>
  )
}

// Props a button takes that mean something else on a checkbox or a switch.
type ButtonControlProps<State> = Omit<
  PartProps<"button", State>,
  | "value"
  | "name"
  | "form"
  | "defaultChecked"
  | "defaultValue"
  | "onChange"
  | "onInput"
  | "onSelect"
>

function useFieldControlId() {
  const field = React.useContext(FieldContext)
  return field ? fieldControlId(field.api.id) : undefined
}

export {
  type ButtonControlProps,
  controlRender,
  FieldContext,
  type FieldContextValue,
  useFieldControl,
  useFieldControlId,
  useJoinField,
}
