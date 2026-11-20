"use strong"
import {
  Menu,
  MenuCheckboxItem,
  MenuContent,
  MenuItem,
  MenuRadioGroup,
  MenuRadioItem,
  MenuSeparator,
  MenuSub,
  MenuSubContent,
  MenuSubTrigger,
  MenuTrigger,
} from "@ui-sdk/octane/menu"
import { Menubar, createMenubarController } from "@ui-sdk/octane/menubar"
import * as React from "octane"
import { createRoot } from "octane"
import { menubarFixture as f, menubarOptions } from "tests/fixtures/menubar.ts"

const controller = createMenubarController()
;(window as unknown as { __menubar: typeof controller }).__menubar = controller

function Fixture() {
  const [action, setAction] = React.useState("")
  // The page's options, read once, as the page's URL never changes.
  const options = React.useInitialValue(menubarOptions)
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Menubar
        className="menubar"
        aria-label={f.label}
        controller={controller}
        {...options}
      >
        <Menu onAction={setAction}>
          <MenuTrigger>{f.file.trigger}</MenuTrigger>
          <MenuContent className="popup">
            @for (const item of f.file.items; key item.value) {
              <MenuItem
                className="item"
                value={item.value}
                shortcut={item.shortcut}
              >
                {item.label}
              </MenuItem>
            }
            <MenuSub>
              <MenuSubTrigger className="item">
                {f.file.share.trigger}
              </MenuSubTrigger>
              <MenuSubContent className="popup">
                @for (const item of f.file.share.items; key item.value) {
                  <MenuItem className="item" value={item.value}>
                    {item.label}
                  </MenuItem>
                }
              </MenuSubContent>
            </MenuSub>
            <MenuSeparator className="separator" />
            <MenuItem className="item" value={f.file.print.value}>
              {f.file.print.label}
            </MenuItem>
          </MenuContent>
        </Menu>
        <Menu onAction={setAction}>
          <MenuTrigger>{f.edit.trigger}</MenuTrigger>
          <MenuContent className="popup">
            @for (const item of f.edit.items; key item.value) {
              <MenuItem
                className="item"
                value={item.value}
                disabled={item.disabled}
              >
                {item.label}
              </MenuItem>
            }
          </MenuContent>
        </Menu>
        <Menu
          onCheckedChange={(checked, { value }) =>
            setAction(`${value}: ${checked ? "on" : "off"}`)
          }
        >
          <MenuTrigger shortcut={f.view.shortcut}>{f.view.trigger}</MenuTrigger>
          <MenuContent className="popup">
            @for (const item of f.view.checkboxes; key item.value) {
              <MenuCheckboxItem
                className="item"
                value={item.value}
                defaultChecked={item.defaultChecked}
              >
                {item.label}
              </MenuCheckboxItem>
            }
          </MenuContent>
        </Menu>
        <Menu>
          <MenuTrigger>{f.profiles.trigger}</MenuTrigger>
          <MenuContent className="popup">
            <MenuRadioGroup
              defaultValue={f.profiles.defaultValue}
              onValueChange={(value) => setAction(`profile: ${value}`)}
            >
              @for (const item of f.profiles.items; key item.value) {
                <MenuRadioItem className="item" value={item.value}>
                  {item.label}
                </MenuRadioItem>
              }
            </MenuRadioGroup>
          </MenuContent>
        </Menu>
        <Menu onAction={setAction}>
          <MenuTrigger disabled>{f.help.trigger}</MenuTrigger>
          <MenuContent className="popup">
            @for (const item of f.help.items; key item.value) {
              <MenuItem className="item" value={item.value}>
                {item.label}
              </MenuItem>
            }
          </MenuContent>
        </Menu>
      </Menubar>
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
