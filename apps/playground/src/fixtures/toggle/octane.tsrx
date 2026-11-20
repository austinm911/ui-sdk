"use strong"
import { Button } from "@ui-sdk/octane/button"
import { Separator } from "@ui-sdk/octane/separator"
import {
  Toggle,
  ToggleGroup,
  createToggleGroupController,
} from "@ui-sdk/octane/toggle"
import * as React from "octane"
import { createRoot } from "octane"
import { changedValue, toggleOptions } from "tests/fixtures/page.ts"
import { toggleAction, toggleFixture } from "tests/fixtures/toggle.ts"

const formatting = createToggleGroupController()

// A Promise and the buttons that settle it.
function useGate() {
  const settle = React.useRef<{
    resolve: () => void
    reject: (reason: Error) => void
  } | null>(null)
  return {
    wait: () =>
      new Promise<void>(
        (resolve, reject) => (settle.current = { resolve, reject })
      ),
    resolve: () => settle.current?.resolve(),
    reject: () => settle.current?.reject(new Error("Offline")),
  }
}

type GroupOptions = Omit<
  ReturnType<typeof toggleOptions>,
  "cancel" | "defaultPressed" | "disabled" | "alignment"
>

function Group({
  data: { name, label, items },
  defaultValue,
  values,
  cancel,
  groupOptions,
  setAction,
  multiple,
  disabled,
  controller,
}: {
  data: typeof toggleFixture.alignment
  defaultValue: string[]
  values: { current: Record<string, string[]> }
  cancel: string | null | undefined
  groupOptions: GroupOptions
  setAction: (action: string) => void
  multiple?: boolean
  disabled?: boolean
  controller?: typeof formatting
}) {
  return (
    <ToggleGroup
      className="toggle-group"
      aria-label={label}
      defaultValue={defaultValue}
      {...groupOptions}
      multiple={multiple}
      disabled={disabled}
      controller={controller}
      onValueChange={(value, details) => {
        if (cancel && changedValue(values.current[name]!, value) === cancel) {
          return details.cancel()
        }
        values.current[name] = value
        setAction(toggleAction.group(name, value))
      }}
    >
      @for (const item of items; key item.value) {
        <Toggle className="toggle" value={item.value} disabled={item.disabled}>
          {item.label}
        </Toggle>
      }
    </ToggleGroup>
  )
}

function Fixture() {
  const [action, setAction] = React.useState("")
  const [pressedWith, setPressedWith] = React.useState("")
  const [submissions, setSubmissions] = React.useState(0)
  // The page's options, read once, as the page's URL never changes.
  const { cancel, defaultPressed, disabled, alignment, ...groupOptions } =
    React.useInitialValue(toggleOptions)
  const saving = useGate()
  const publishing = useGate()
  // Each group's value, to tell which toggle a change touches.
  const initial = React.useInitialValue(() => ({
    alignment: alignment ? [alignment] : toggleFixture.alignment.defaultValue,
    formatting: toggleFixture.formatting.defaultValue,
  }))
  const values = React.useLazyRef<Record<string, string[]>>(() => ({
    ...initial,
  }))

  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Toggle
        className="toggle"
        defaultPressed={defaultPressed}
        onPressedChange={(pressed, details) => {
          if (cancel === toggleFixture.toggle.value) {
            return details.cancel()
          }
          setAction(toggleAction.toggle(pressed))
        }}
      >
        {toggleFixture.toggle.label}
      </Toggle>
      <Group
        data={toggleFixture.alignment}
        defaultValue={initial.alignment}
        values={values}
        cancel={cancel}
        groupOptions={groupOptions}
        setAction={setAction}
      />
      <Separator className="rule" orientation="vertical" />
      <Group
        data={toggleFixture.formatting}
        defaultValue={initial.formatting}
        values={values}
        cancel={cancel}
        groupOptions={groupOptions}
        setAction={setAction}
        multiple
        disabled={disabled}
        controller={formatting}
      />
      <form
        aria-label={toggleFixture.form.label}
        onSubmit={(event: SubmitEvent) => {
          event.preventDefault()
          setSubmissions((count) => count + 1)
        }}
      >
        <label>
          {`${toggleFixture.form.field} `}
          <input name="name" defaultValue={toggleFixture.form.defaultName} />
        </label>
        <Button className="button" type="submit" onClick={saving.wait}>
          {"Submit"}
        </Button>
        <Button className="button" type="reset">
          {"Reset"}
        </Button>
        <Button className="button" disabled onClick={() => setAction("delete")}>
          {"Delete"}
        </Button>
        <Button
          className="button"
          type="submit"
          disabled
          focusableWhenDisabled
          onClick={() => setAction("archive")}
        >
          {"Archive"}
        </Button>
      </form>
      <Button
        className="button"
        onClick={(_event, { source }) => {
          setAction("save")
          setPressedWith(source)
        }}
      >
        {"Save"}
      </Button>
      <Button
        className="button"
        onClick={async () => {
          setAction("publishing")
          await publishing.wait()
          setAction("published")
        }}
      >
        {"Publish"}
      </Button>
      <button onClick={() => formatting.setValue([])}>
        {"Clear formatting"}
      </button>
      <button onClick={saving.resolve}>{"Finish saving"}</button>
      <button onClick={publishing.resolve}>{"Finish publishing"}</button>
      <button onClick={publishing.reject}>{"Fail publishing"}</button>
      <Button
        className="button"
        render={(props) => <a {...props} href={toggleFixture.docs.href} />}
      >
        {toggleFixture.docs.label}
      </Button>
      <Button
        className="button"
        disabled
        render={(props) => <a {...props} href={toggleFixture.changelog.href} />}
      >
        {toggleFixture.changelog.label}
      </Button>
      <Separator className="rule" />
      <Separator className="rule" decorative />
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
      <output aria-label="Submissions">{submissions}</output>
      <output aria-label="Pressed with">{pressedWith}</output>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
