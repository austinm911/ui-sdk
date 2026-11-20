"use strong"
import { Menu, MenuContent, MenuItem, MenuTrigger } from "@ui-sdk/octane/menu"
import { NumberInput, NumberInputControl } from "@ui-sdk/octane/number-input"
import { Toggle, ToggleGroup } from "@ui-sdk/octane/toggle"
import {
  Toolbar,
  ToolbarButton,
  ToolbarGroup,
  ToolbarInput,
  ToolbarLink,
  ToolbarSeparator,
  createToolbarController,
} from "@ui-sdk/octane/toolbar"
import * as React from "octane"
import { createRoot } from "octane"
import {
  toolbarFixture as f,
  toolbarLocked,
  toolbarOptions,
} from "tests/fixtures/toolbar.ts"

const controller = createToolbarController()

// Wraps an item in a disabled group while locked, for ?locked.
function Lock({
  label,
  lockable,
  locked,
  children,
}: {
  label: string
  lockable: boolean
  locked: boolean
  children?: unknown
}) @{
  @if (lockable) {
    <ToolbarGroup aria-label={label} disabled={locked}>
      {children}
    </ToolbarGroup>
  } @else {
    <>{children}</>
  }
}

function Group({
  data: { label, defaultValue, items },
  multiple,
  setAction,
}: {
  data: typeof f.style
  multiple: boolean
  setAction: (action: string) => void
}) {
  return (
    <ToggleGroup
      className="toggle-group"
      aria-label={label}
      multiple={multiple}
      defaultValue={defaultValue}
      onValueChange={(value) =>
        setAction(`${label}: ${value.join(", ") || "none"}`)
      }
    >
      @for (const item of items; key item.value) {
        <Toggle
          className="toggle"
          value={item.value}
          disabled={"disabled" in item && item.disabled}
        >
          {item.label}
        </Toggle>
      }
    </ToggleGroup>
  )
}

function Fixture() {
  const [action, setAction] = React.useState("")
  // The page's options, read once, as the page's URL never changes.
  const lockable = React.useInitialValue(toolbarLocked)
  const options = React.useInitialValue(toolbarOptions)
  const [locked, setLocked] = React.useState(lockable)

  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Toolbar
        className="toolbar"
        aria-label={f.label}
        controller={controller}
        {...options}
      >
        <Lock label="Locked style" lockable={lockable} locked={locked}>
          <Group data={f.style} multiple setAction={setAction} />
        </Lock>
        <ToolbarSeparator />
        <Group data={f.alignment} multiple={false} setAction={setAction} />
        <ToolbarSeparator />
        <Menu onAction={(value) => setAction(`font: ${value}`)}>
          <ToolbarButton render={(props) => <MenuTrigger {...props} />}>
            {f.font.trigger}
          </ToolbarButton>
          <MenuContent className="popup">
            @for (const item of f.font.items; key item) {
              <MenuItem className="item" value={item}>
                {item}
              </MenuItem>
            }
          </MenuContent>
        </Menu>
        <NumberInput
          defaultValue={f.size.defaultValue}
          onValueChange={(value) => setAction(`size: ${value}`)}
        >
          <ToolbarInput
            render={(props) => (
              <NumberInputControl {...props} aria-label={f.size.label} />
            )}
          />
        </NumberInput>
        <ToolbarInput
          aria-label={f.comment.label}
          defaultValue={f.comment.defaultValue}
        />
        <ToolbarGroup
          className="toolbar-group"
          aria-label={f.history.label}
          disabled={lockable && locked}
        >
          @for (const item of f.history.items; key item.label) {
            <ToolbarButton
              disabled={"disabled" in item && item.disabled}
              onClick={() => setAction(item.label.toLowerCase())}
            >
              {item.label}
            </ToolbarButton>
          }
        </ToolbarGroup>
        <Lock label="Locked proofing" lockable={lockable} locked={locked}>
          <Toggle
            className="toggle"
            onPressedChange={(pressed) =>
              setAction(`spellcheck: ${pressed ? "on" : "off"}`)
            }
          >
            {f.spellcheck.label}
          </Toggle>
        </Lock>
        <Lock label="Locked help" lockable={lockable} locked={locked}>
          <ToolbarLink href={f.help.href}>{f.help.label}</ToolbarLink>
        </Lock>
      </Toolbar>
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
      <button onClick={() => controller.focus()}>{"Focus toolbar"}</button>
      <button onClick={() => setLocked(false)}>{"Unlock"}</button>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
