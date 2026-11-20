"use strong"
import {
  readIn,
  slotIn,
  usePart,
  type PrimitiveHandle,
} from "./use-primitive.tsrx"

// The hidden inputs that take part in a form for a list's root, like a
// select's: one for the value, or one more per value with `multiple`. Next to
// the root, outside it, so they take its handle.
function FormInputs({ handle }: { handle: PrimitiveHandle<any> }) {
  const inputs = ({ value, ...input }: Record<string, any>) => (
    <>
      <textarea {...input} defaultValue={value} />
      @if (handle.state.multiple) {
        @for (const key of readIn(
          handle,
          () => handle.api.internal.serialized() as string[]
        ); key key) {
          <HiddenInput handle={handle} value={key} />
        }
      }
    </>
  )
  return usePart(handle, "form-input", {}, { render: inputs }, "textarea")
}

function HiddenInput({
  handle,
  value: key,
}: {
  handle: PrimitiveHandle<any>
  value: string
}) {
  const { value, ...hidden } = slotIn(handle, "value-input", {
    id: key,
    value: key,
  })
  return <input {...hidden} defaultValue={value} />
}

export { FormInputs }
